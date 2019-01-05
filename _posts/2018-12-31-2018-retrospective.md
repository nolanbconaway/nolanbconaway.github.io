---
title: Learning devops in 2018.
excerpt: Learning devops in 2018.
tags: retrospective, devops
season: Winter 2019
type: blog
layout: post
---

2018 was my first full year as a professional data scientist. I finished my postdoc work in [Joe's awesome lab](http://alab.psych.wisc.edu/) in late 2017. I started at Shutterstock soon after.

I found that full time data science is similar to academic work in many ways. But I found that I needed to do more to maximize the reach of my work within the company.

For my first handful of months at Shutterstock, data science work was primarily made available to internal consumers through manual requests. Imagine emails like, "Hey can I get X data? As a CSV with columns ...". That sort of thing is not at all my style: I don't like CSV formats and I _really_ don't like manual processes.

In 2018, I learned a lot about how to make my work available to consumers through REST APIs and webapps using our in-house Kubernetes pipeline. I generally think of this type of knowledge as "devops" but I don't know if that's the right term. It was a lot to learn for me, but _very_ worth the investment.

In this post I share some of my accomplishments having to do with, or owing to, my learnings in devops.

## Deploying personal projects on Heroku.

For years I've maintained a private MySQL database to hold all of the data I collect for my various projects. In 2018 I got comfortable with using Heroku to build flask apps around that database.

I built out a few apps to make my daily life just a little bit easier.

 - **Dogwalker Checker**. My dog walker has a website that says whether My dog, Patches, has been taken out. But, it does not say _when_. I set up my raspberry pi to check the website every half hour and write a database entry if a new walk is posted. I made a quick flask app to query that database so that I can check anytime. [You can check too](https://dogwalker-checker.herokuapp.com/)!
- **Q Train Forecaster**. Most mornings I take the Q train from Brooklyn to Manhattan. I _could_ take the 5 train if I knew that the Q was going to be slammed with delays, but MTA warnings usually come too late. I built a Slack app to keep track of whether the Q was slammed, and to query the MTA API right before I leave for work. With enough data, I'll forecast whether my commute would be better if I take the 5. [Usually my rides are OK](https://how-was-the-q.herokuapp.com/).
- **Apartment Thermometer**. Honestly I just wanted some hard data on my apartment's temperature. I often feel like it's super cold but I don't trust my judgement. I hooked up a raspberry pi with a thermometer to record the temperature every minute. Then I built a little flask app to show me the temperature over the last 24 hours. [It isn't as cold as I think it is](https://temp-in-nolans-apartment.herokuapp.com/).

All of those are basically views of fairly straightforward data, either as a table or as a basic Chart.js plot. I would absolutely _love_ to work on a larger scale project in 2019.

## Unit testing.

I'll be the first to point out that my code is garbage. As an academic, I almost never had to edit to the abominations I had written months prior.

I find that I often have to do this as a data scientist, for example when someone asks for a new feature on a report that's generated every month. Editing this code can be stressful business since I probably won't remember how breakable it all is.

In 2018 I learned to alleviate that stress through unit tests. So when I ruin my own code, there's a remote possibility that I had the foresight to write a test for it. I like using the python builtin [`unittest`](https://docs.python.org/3/library/unittest.html) with [`tox`](https://tox.readthedocs.io/en/latest/).

Here are some things I wrote tests for:


- **jarjar slack notifier**. Last year I spent a lot of time on the Jarjar python module that Jeff Zemla and I originally developed in the (Star Wars-themed) Austerweil lab. Testing for the module had always been manual and super annoying. I learned about using Travis CI by [writing real tests](https://travis-ci.org/AusterweilLab/jarjar) for the module.
- **`months` python module**. At work I end up writing a lot of scheduled jobs that run monthly, or aggregate over month-long increments of time, etc. I [opened a PR](https://travis-ci.org/kstark/months/builds/429131191) to `kstark`'s months module to add some common functionality that I use all the time.
- **freezable dict**. A friend was talking to me about how he wants to use a python dictionary as a key to yet another dictionary, but can't because dictionary keys must be immutable objects. Being generally interested in making all things immutable, I [wrote up a dictionary subclass](https://travis-ci.org/nolanbconaway/freezable_dict) that you can freeze and unfreeze.

In 2019 I'd like to learn how to apply this ethos to testing flask apps and other more complex pieces of code.