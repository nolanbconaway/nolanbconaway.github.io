---
title: A workon script for everyday living
date: 2022-10-01
category: blog
keywords: utility, scripting
---


A regrettable scenario I commonly find myself in:

> I'm doing research in my jupyter environment when I realize some of the data I need are not available in the datalake. So I hop into the dbt project and edit a couple data models, when I realize much of the source data haven't been backfilled from s3. So I hop over to the etl environment and start writing a adhoc run to backfill, when....


And so on.

Each of these hops involves getting a terminal to the right workspace and opening my editor (vscode) to the project root. For years my workflow had been:

1. Realize I need to change contexts
2. _arrow up_ history print until I find the correct `cd` command (or type in the path as a last resort).
3. `code .`
4. Start work.

I realized that, as a data scientist, the number of projects on which I work are very countable and do not commonly expand. I could automate the above workflow if I only _registered_ the projects and wrapped that workflow in a shell script. Once that is done, you can imagine [`alfred`](https://www.alfredapp.com/) or [`ulauncher`](https://ulauncher.io/) completions for launching a workspace.

## Station registry

I added a python script to `~/.local/bin` on my `PATH` called `get-station-path`. This script contains a mapping of paths to locations where I commonly work:

```py
#! /usr/bin/python3
# $HOME/.local/bin/get-station-path
import sys
import argparse
from pathlib import Path

HOME = Path.home().resolve()
REPOS = HOME / "Documents/repos"
APPS = HOME / "Documents/apps"

STATIONS = {
    "scripts": HOME / "Documents/scripts",
    "dotfiles": HOME / ".dotfiles",
}

for p in REPOS.iterdir():
    if p.is_dir() and p.name not in STATIONS and p not in STATIONS.values():
        STATIONS[p.name] = p

for p in APPS.iterdir():
    if p.is_dir() and p.name not in STATIONS and p not in STATIONS.values():
        STATIONS[p.name] = p


def print_stations():
    for k, v in sorted(STATIONS.items(), key=lambda x: x[1]):
        print(f"{k:<25} {v}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("station", nargs="?")
    parser.add_argument("-l", dest="list_", action="store_true", help="List stations")
    args = parser.parse_args()

    if args.list_:
        print_stations()
        sys.exit(0)

    if args.station in STATIONS:
        print(STATIONS[args.station])
        sys.exit(0)
    else:
        print(f"Station {args.station} not found! Try one of:")
        print()
        print_stations()
        sys.exit(1)


if __name__ == "__main__":
    main()
```

The idea is to start with stations you want to manually name (dotfiles management, etc), and then programatically append stations from known directories; like where you might `git clone` everything.

Calling the script will only print out the location of the workstation requested:

```sh
$ get-station-path dotfiles
/home/nolan/.dotfiles
```

## `zsh` function

We can now obtain the path to a project on the basis of a name, so all that is needed is a quick function to `cd` and open up `vscode`:


```zsh
workon () {
	arg="$1"
	if [ ${arg:0:1} = "-" ]
	then
		$HOME/.local/bin/get-station-path "$@";         # pass if this is like -l
	else
        # get the path
		p=$($HOME/.local/bin/get-station-path "$1")
		if [ "$?" = "0" ]
		then
			cd "$p" && /usr/bin/code .;                 # cd and open code if success
		else
			echo $p;                                    # echo the error if fail
		fi
	fi
}
```

You can imagine editing the text editor, customizing maybe opening a new shell, etc. Personally, I've wrapped my [`ulauncher`](https://ulauncher.io/) to open vscode to the right spot in case I wasn't already in my terminal.

## Usage

```sh
$ workon <project-name>
```

I put that `workon` in my `.zshrc` (or functions file or whatever), and usage is frankly liberating. Opening up the project to write this post was as easy as `workon nolanbconaway.github.io`.

Even easier, I can arrow-up locate the `workon` command if I don't want to type it out (or don't recall my project name).

It only saves a handful of keypresses, but the mental burden of remembering where things are absolutely vanishes. Now I can focus more on the work being done, and less on how to get started.