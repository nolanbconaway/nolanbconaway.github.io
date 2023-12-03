---
title: My dbt continuous integration setup
date: 2023-11-15
category: blog
keywords: dbt, database, ci
---

I love what [dbt](https://www.getdbt.com/) has done for the host of data professions from which I earn a living. I don't know how people were managing databases before dbt, because in that era I was merely a _consumer_ of data. Learning dbt was key to my transition to a maintainer of tables; someone an organization could rely on to produce useful data.

Reliability is key in this space, after all. Ensuring a data pipeline is well tested is difficult given the number of external services that need to be mocked, but I find that struggle pays off every time.

For the longest time, dbt models had been a final untested link in my data pipelines. I would write [dbt tests](https://docs.getdbt.com/reference/commands/test) which run in airflow DAGs; but ensuring the tests pass _prior_ to merge was always done manually.

I've even seen situations in which the convention was to _paste local terminal output in the PR description_. ::skull_and_cross_bones::

There has to be a better way!

<iframe src="https://giphy.com/embed/5yaCPstUOV9Kw" width="480" height="360" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/obama-thanks-5yaCPstUOV9Kw">via GIPHY</a></p>

This post contains an overview of the solution I've been circling for a few years now.

## Why running dbt in CI difficult?

### Schema management

In local development dbt uses a host of schemas in a development database (`dbt_nolan`, `dbt_nolan_staging`, etc) which are automatically built to populate/test tables. The base prefix for all these tables is set via the `schema` in the [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#understanding-target-schemas).

Running in CI requires dynamically setting the schema prefix based on the PR number, git hash, branch name, etc. This can be done with [`envvars`](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var). The important thing is to pick something that won't collide with any other CI runs or user development.

Not only does a CI solution need to generate the schema name on the fly, but it should have a system to drop the schemas after the fact so that the dev database doesn't store a bunch of old schemas from historical CI runs.

### Testing changed models

In my experience its basically unthinkable (for database load, cost, time, etc, reasons) to run an entire dbt project when it reaches even medium sizes. So running only the affected models is important.

dbt is able to identify local files that have changed compared to a [manifest/state file](https://docs.getdbt.com/reference/artifacts/manifest-json). The state file is typically used to store the _main branch state_ (or whatever the merge target), so that dbt can isolate the current changes.

_If such a file should be available_, the following dbt invocation can be run to test the changed files and first level dependents of them:

```zsh
dbt build --select state:modified+1 --defer --favor-state --state=path/to/state
```

> Note: The `--defer --favor-state` arguments are used to ensure that the production versions of unchanged models are used instead of development versions.

This seems perfect, _if such a file should be available_. Alas, the manifest file is something that needs to be *produced*. 

Generating the manifest file is as easy as running a `dbt compile` command; in which case it lands (by default) in `target/manifest.json`. The manifest for the _current production state_ is what is needed in the CI environment; so most solutions involve periodically building the file and storing it externally, then downloading it on the fly in the CI pipeline.

### Summary of the challenge

Clearly, a fair amount of orchestrating is required just to run the correct models in the correct place!

1. Make a schema name that won't interfere with any other work; export it to the correct envvar to populate it in the dbt profiles.yml.
2. Obtain a local a manifest file from the target branch, so that changed models can be detected.
3. Regardless of what happens, make sure to drop all the schemas which were created as a part of the CI run.

## A GitHub actions solution

[dbt Cloud](https://www.getdbt.com/product/dbt-cloud) has a streamlined offering that does all of the above; but an additional provider might not be desirable if your organization is running the other CI elements on GitHub.

The general architecture of my setup is as follows:

1. On push to `main`, run `dbt compile` to generate the manifest file. Save that file as a [actions artifact](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts).
2. On each CI run, download the manifest artifact from the _latest_ compile run. I found the [GitHub cli](https://cli.github.com/) made this easy.
3. Wrap subsequent dbt commands in a script which sets up schemas and tears them down afterwards.

### Setting up `profiles.yml`

No matter what the solution, the CI runner will need to have access to the data warehouse. Which means passing around authentication secrets.

In local development, database secrets are usually stored in plaintext in a file like [`~/.dbt/profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml). GitHub will need a similar file to to connect to the data warehouse; but this one will need to be special to avoid saving secrets into the repository. The easiest way is to export [GitHub actions secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) to envvars, and pick those up in the yml file.

Below is an example setup for a snowflake database:

```yaml
default:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('DBT_ACCOUNT') }}"
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASSWORD') }}"
      role: "{{ env_var('DBT_ROLE') }}"
      database: "{{ env_var('DBT_DATABASE') }}"
      schema: "{{ env_var('DBT_SCHEMA') }}"
      warehouse: "{{ env_var('DBT_WAREHOUSE') }}"
```

A file like that will need to be committed to the dbt GitHub repository and the secrets will need to be orchestrated appropriately.

### The compile workflow

This step is about saving the production manifest to some external storage so that it can be retrieved later to determine which models have changed.

Compiling is usually pretty quick and the manifest is only a handful of megabytes, so this should be a quick and cheap workflow.

An action like below can be used to save the manifest as an actions artifact, but one could imagine saving to cloud object storage, etc. The advantage of using an actions artifact is that, presumably, developers already have access to the GitHub repository and will not need additional authorization to download the files.

```yaml
name: Main Branch DBT State

on:
  push:
    branches:
      - main

jobs:
  run:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v4
      with:
        python-version: '3.10'

    - name: Setup dbt
      run: |
        pip install -r requirements.txt
        dbt deps

    - name: Compile
      run: dbt compile --profiles-dir=/path/to/directory/containing/profilesyml
      env:
        DBT_ACCOUNT: ${{ secrets.DBT_ACCOUNT }}
        DBT_USER: ${{ secrets.DBT_USER }}
        DBT_PASSWORD: ${{ secrets.DBT_PASSWORD }}
        DBT_ROLE: ${{ secrets.DBT_ROLE }}
        DBT_DATABASE: ${{ secrets.DBT_DATABASE }}
        DBT_SCHEMA: ${{ secrets.DBT_SCHEMA }}
        DBT_WAREHOUSE: ${{ secrets.DBT_WAREHOUSE }}

    - name: Upload manifest.json to GH Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: dbt_manifest_json
        path: target/manifest.json
        if-no-files-found: error
```

In the above, I set up a python environment with dbt installed, then ran a simple `compile` command to generate file `target/manifest.json`. That file is uploaded as an artifact so it can be downloaded later.

### Pulling the latest manifest

This step may not be needed depending on how the manifest file is stored. It is required in the case of GitHub artifacts.

By default, GitHub actions will save artifacts from workflow runs going back 90 days. The manifest from the _latest_ run presumably contains the desired comparison state; so the CI pipeline needs to figure out which version of the `dbt_manifest_json` artifact is the latest one.

I found is straightforward enough to do so via the [GitHub cli](https://cli.github.com/); which is easy to install locally and comes preinstalled in most GitHub actions runners. The below approach uses the cli to first list runs, and then grab the manifest from the latest one.

The following invocation will list the last 500 runs of the "Main Branch DBT State" action:

```zsh
gh run list \
    --limit=500 \
    --branch=main \
    --status=completed \
    --workflow='Main Branch DBT State' \
    --json=databaseId,createdAt
```

> The `--json=databaseId,createdAt` flag tells the CLI to return JSON data, and to include the run ID as well as the timestamp of the run. Make sure the workflow and branch setting match the compile action's configuration.

The resultant data look like this:

```json
[
    {"createdAt": "2023-06-02T00:00:00Z", "databaseId": 123}
    {"createdAt": "2023-06-01T00:00:00Z", "databaseId": 122}
]
```

In my experience, the records have been in reverse chronological order (latest first), but I was [unable to find a guarantee](https://github.com/cli/cli/issues/6678#issuecomment-1334156674) about this. So instead I chose to pull a lot of runs (500) and hope that the latest one is in there.

One can sort through the records in lots of ways. Here's how [`jq`](https://github.com/jqlang/jq) could be used:

```zsh
runs=$(
    gh run list \
    --limit=500 \
    --branch=main \
    --status=completed \
    --workflow='Main Branch DBT State' \
    --json=databaseId,createdAt
)

# get latest run
latest=$(echo $runs | jq 'sort_by(.createdAt) | reverse' | jq '.[0]')
run_id=$(echo $latest | jq '.databaseId')
run_created_at=$(echo $latest | jq '.createdAt')
echo "Latest run id: $run_id (created at $run_created_at)"
```

Given a `databaseId`, one can download the artifact like:

```zsh
gh run download --name=dbt_manifest_json --dir=manifest/ $run_id
```

 > The manifest.json will appear at `manifest/manifest.json` if successful.

A script doing the above should be committed into the dbt GitHub repository (something like `download-production-manifest.sh`), so that it can be reused in the CI environment as well as local development.

### The dbt build wrapper

The next step is to write a wrapper around `dbt build` which manages the schemas created by dbt. The idea is to generate random unused schema names for dbt to use temporarily, and then drop anything dbt created after the fact. Eventually, the downloaded state and the custom profiles.yml will be passed to this script as well.

This script can get a little long, so I'll paste a version below. The general idea is as follows:

1. Write a function which **lists schemas with a given prefix** (`list_schemas_with_prefix`). This will be used to determine if a given proposed schema name has any collisions, and also to list schemas that need to be dropped when everything is finished.
2. Use that function in another function which **generates random schema names** (`get_schema_prefix`) until an unused one is found. This will be used to assign a `DBT_SCHEMA` envvar to be used by dbt later.
3. Use that function in another function which **drops schemas with a given prefix** (`drop_schemas_with_prefix`). This is used to cleanup after runs.
4. Generate a `subprocess.check_call` command based on user-provided paths to the downloaded manifest and profiles.yml, exporting a generated `DBT_SCHEMA` envvar.
5. Wrap that `check_call` in a try/except statement, dropping the schemas in the `finally` clause.

Here is one way to do it:

```py
#! /usr/bin/env python3
"""Run a DBT in an ephemeral schema.

Call like:

    ./dbt-ci.py --select=... --state=/path/to/state --profiles-dir=/path/to/profiles

Requires the following environment variables:

    - DBT_USER
    - DBT_PASSWORD
    - DBT_ACCOUNT
    - DBT_ROLE
    - DBT_DATABASE
"""

import argparse
import datetime
import os
import subprocess
import uuid
from pathlib import Path

from snowflake.connector import connect as snowflake_connect


def snowflake_query(sql: str, *args, **kwargs) -> list[dict]:
    """Run a raw query against Snowflake, returning a dict for each row."""
    with snowflake_connect(
        user=os.environ["DBT_USER"],
        password=os.environ["DBT_PASSWORD"],
        account=os.environ["DBT_ACCOUNT"],
        role=os.environ["DBT_ROLE"],
        database=os.environ["DBT_DATABASE"],
    ) as conn:
        cur = conn.cursor()
        cur.execute(sql, *args, **kwargs)
        cols = [col[0] for col in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]


def list_schemas_with_prefix(prefix: str) -> list[dict]:
    """Check if a schema prefix collides with existing schemas.

    Returns True if there are any collisions, False otherwise.
    """
    db_name = os.environ["DBT_DATABASE"]

    # terse limits total data returned. like is case insensitive.
    # docs: https://docs.snowflake.com/en/sql-reference/sql/show-schemas#parameters
    sql = f"show terse schemas like '{prefix}%' in database {db_name}"
    return snowflake_query(sql)


def get_schema_prefix() -> str:
    """Make a random schema prefix that doesn't collide with existing ones."""
    date_str = datetime.date.today().strftime("%y%m%d")
    uuid_str = str(uuid.uuid4()).replace("-", "")[:8]
    schema = f"dbt_{date_str}_{uuid_str}"
    print(f"Using prefix {schema}")

    while any(list_schemas_with_prefix(schema)):
        print(f"Detected collision with {schema}, getting new uuid.")
        uuid_str = str(uuid.uuid4()).replace("-", "")[:8]
        schema = f"dbt_{date_str}_{uuid_str}"

    print(f"Using prefix {schema}")
    return schema


def drop_schemas_with_prefix(prefix: str) -> None:
    """Drop all schemas with a given prefix."""
    print(f"Dropping all schemas with prefix {prefix}.")
    schemas = list_schemas_with_prefix(prefix)
    if schemas:
        print(f"Found {len(schemas)} schemas with prefix {prefix}, dropping them.")
        for schema in schemas:
            name = schema["name"]
            print(f"Dropping schema {name}")
            snowflake_query(f"drop schema {name} cascade")
            print(f"Schema {name} dropped.")
    else:
        print(f"No schemas with prefix {prefix} found.")


def parse_args() -> argparse.Namespace:
    """Make a parser and parse arguments."""
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("-s", "--select", type=str, help="DBT selector.", required=True)
    parser.add_argument("--state", type=Path, help="Path to state.", required=True)
    parser.add_argument(
        "--profiles-dir", type=Path, help="Path to profiles.", required=True
    )
    return parser.parse_args()


def main():
    args = parse_args()

    command = [
        "dbt",
        "build",
        "--defer",
        "--favor-state",
        f"--state={args.state}",
        f"--profiles-dir={args.profiles_dir}",
        f"--select={args.select}",
    ]

    schema_prefix = get_schema_prefix()

    print(f"Running command: {' '.join(command)}")

    try:
        subprocess.check_call(command, env={**os.environ, "DBT_SCHEMA": schema_prefix})
    except:
        raise
    finally:
        # teardown no matter what
        drop_schemas_with_prefix(schema_prefix)


if __name__ == "__main__":
    main()

```

> The above version is set up for snowflake, but only imports and a couple functions (`snowflake_query`, `list_schemas_with_prefix`, `drop_schemas_with_prefix`) would need changes to support another warehouse type.

### The CI workflow

At this point, the following are available:

1. A way to authorize GitHub actions to connect to the data warehouse (via actions secrets and a custom profiles.yml).
2. A scheduled job to save the production manifest to external storage (the "Main Branch DBT State" action).
3. A little script to locate and download the latest manifest file (`download-production-manifest.sh`).
4. A bigger script to wrap dbt commands to use random, ephemeral schemas (`dbt-ci.py`).

The final step is to write a workflow to put it all together.

THe below workflow first sets up a dbt python environment, then downloads the state, then runs the dbt build wrapper (making sure to pass in the correct paths to the state and profiles.

```yaml
name: CI

on:
  push

jobs:
  run:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v4
      with:
        python-version: '3.10'

    - name: Setup dbt
      run: |
        pip install -r requirements.txt
        dbt deps

    - name: Download Manifest
      run: ./download-production-manifest.sh
      env:
        GH_TOKEN: ${{ github.token }}  # needed for gh cli in gh actions

    - name: dbt build
      run: ./dbt-ci.py --select=state:modified+1 --state=/path/to/state --profiles-dir=/path/to/profiles
      env:
        DBT_ACCOUNT: ${{ secrets.DBT_ACCOUNT }}
        DBT_USER: ${{ secrets.DBT_USER }}
        DBT_PASSWORD: ${{ secrets.DBT_PASSWORD }}
        DBT_ROLE: ${{ secrets.DBT_ROLE }}
        DBT_DATABASE: ${{ secrets.DBT_DATABASE }}
        DBT_SCHEMA: ${{ secrets.DBT_SCHEMA }}
        DBT_WAREHOUSE: ${{ secrets.DBT_WAREHOUSE }}
```

> I like to use `--select=state:modified+1` to run all changes files and first-level dependencies, but there are lots of ways to manage this selector.

After all that setup, the final action looks really simple! But it took a lot to get there.

## Summary

No matter what the solution, running dbt in a CI environments *must* involve managing secrets, state files, and teardown of database runs. This will in turn require writing some custom dbt wrappers, or some *narsty* shell scripts. I could imagine dbt may one day add a "temporary-build" command specifically for CI purposes (in which the schema is created and town down within in the run); which will remove the need for the `dbt-ci.py` file above.

This setup mirrors what a lot of other people use (just google "dbt continuous integration"); likely because everyone needs to match up the way that dbt works with running an efficient testing pipeline. I can only hope some analytics engineer somewhere found my walkthrough to be more cogent than the rest.
