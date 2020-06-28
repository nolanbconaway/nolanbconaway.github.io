---
title: Deploying my Pelican website to Github Pages.
date: 2020-01-01
category: blog
keywords: pelican, github actions
---

::party_popper:: If you're reading this, you're looking at my new website! ::party_popper::

I ditched Jekyll because I didn't want to have to maintain a ruby installation on my machine. My new site runs on Pelican and I hacked together a deployment flow to Github pages. Here's that hack:

```yaml
name: Main Workflow

on:
  push:
    branches:
      - dev

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - uses: actions/setup-python@v1
        with:
          python-version: "3.7"

      - name: Install Dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Build Production Site
        run: |
          make publish
          cp readme.md output/readme.md
          touch output/.nojekyll

      - name: Deploy To Master Branch
        uses: peaceiris/actions-gh-pages@v3
        with:
          publish_branch: master
          publish_dir: ./output
          personal_token: ${{ secrets.PERSONAL_TOKEN }}

```


### Translation...

On push to the `dev` branch, Github will set up a python 3.7 environment with my requirements.txt. It'll build the static site into an `output` directory using `make publish`. I added a `.nojekyll` file so that Github knows it's not working with a Jekyll page.

I found an [action](https://github.com/peaceiris/actions-gh-pages) that will publish a directory to github pages. I set that up to send the static site directory to the `master` branch. Github will then automatically deploy the site since i am using my `username.github.io` repo! ::confetti_ball::

So the flow is that I make all updates to `dev` which propagate automatically to `master` and then deployment on push. Beautiful! You can check out the source code on [github](https://github.com/nolanbconaway/nolanbconaway.github.io/tree/dev).