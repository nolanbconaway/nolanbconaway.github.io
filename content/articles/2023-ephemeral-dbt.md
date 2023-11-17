---
title: My dbt continuous integration setup.
date: 2023-11-15
category: blog
keywords: dbt, database, ci
---

I love what [dbt](https://www.getdbt.com/) has done for the host of data professions from which I earn a living. I don't know how people were managing databases before dbt because in that era I was merely a _consumer_ of data. Learning dbt was key to my transition to a maintainer of tables; someone an organization could _rely_ on to produce useful data.

Reliability is key in this space, after all. Ensuring a data pipeline is well tested is difficult given the number of external services that need to be mocked, but I find that struggle pays off every time.

For the longest time, dbt models had been a final untested link in my data pipelines. I would write [dbt tests](https://docs.getdbt.com/reference/commands/test) which run in airflow DAGs; but ensuring the tests pass _prior_ to merge was always done manually.

In one organization the convention was to _paste local terminal output in the PR description_.

There has to be a better way!

## Why running dbt in CI difficult?

### Schema management

In local development you use a host of schemas in a development database (`dbt_nolan`, `dbt_nolan_staging`, etc) which dbt automatically builds to populate/test tables. The base prefix for all these tables is set via the `schema` in your [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#understanding-target-schemas). 

Running in CI requires dynamically setting the schema prefix based on the PR number, git hash, branch name, etc. This can be done with [envvars](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var). The important thing is to pick something that won't collide with any other CI runs or user development. 

Not only do you need to generate the schema name on the fly, but you also would want to drop the schemas after the fact so that your dev database doesn't store a bunch of old schemas from historical CI runs.

### Testing changed models

In my experience its basically unthinkable (for database load, cost, time, etc, reasons) to run an entire dbt project when it reaches even medium sizes. So running only the affected models is important.

dbt is able to identify local files that have changed compared to a [manifest/state file](https://docs.getdbt.com/reference/artifacts/manifest-json). The state file is typically used to store the _main branch state_ (or whatever the merge target), so that dbt can isolate the current changes.

_If you have such a file_, you can run the following to test the changed files and first level dependents of them:

```sh
dbt build --select state:modified+1 --defer --favor-state --state=path/to/state
```

> Note: The `--defer --favor-state` arguments are used to ensure that the production versions of unchanged models are used instead of development versions.

This seems perfect, _if you have the state file available_. In a CI environment, you need a system to pull the correct state file to which to point dbt. This involves automatically building and storing the file in a separate workflow; so that it can be retrieved in the CI workflow.

### Summary of the challenge

All of this means that you need to do a fair amount of orchestrating just to run the correct models in the correct place!

1. Make a schema name that won't interfere with any other work; export it to the correct envvar to populate it in the dbt profiles.yml.
2. Build and make local a state file from the target branch into which you want to merge changes.
3. Regardless of what happens, make sure to drop all the schemas which were created as a part of the CI run.

## A github actions solution

[dbt Cloud](https://www.getdbt.com/product/dbt-cloud) has a streamlined offering that does all of the above; but an additional provider might not be desirable if you're running the rest of your CI on github.

The general architecture of my setup is as follows:

1. On push to `main`, run `dbt compile` to generate the manifest file. Save that file as a [actions artifact](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts).
2. On each CI run, download the manifest artifact from the _latest_ compile run. I found the [github cli](https://cli.github.com/) made this easy.
3. Wrap subsequent dbt commands in a script which sets up schemas and tears them down afterwards.

### Setting up `profiles.yml`

### The compile workflow

### Pulling the latest artifact

### The dbt build wrapper

## Summary