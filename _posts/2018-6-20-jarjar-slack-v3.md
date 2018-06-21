---
title: Jarjar Version 3 Released.
excerpt: Major updates to the jarjar slack notifier.
tags: python, slack
season: Summer 2018
type: code
layout: external
external_url: https://github.com/AusterweilLab/jarjar
---

Nearly a full year after releasing the second version of the jarjar package (the first publicly released from the [Austerweil Lab](http://alab.psych.wisc.edu/)), [Jeff](http://chil.rice.edu/jzemla/) and I have released the next major version!

In addition to a bounty of bugs squashed, we've totally revamped the command line tool. A summary of the improvements:

- Pure python (no more wrapping around curl)! Which enables all of the following...
- Automatic installation via pip (no more copying the file to your bin).
- Exit status and elapsed time in your slack message.
- Good names for task screens.
- Handling of older AND newer screen versions.


So go ahead!

```sh
pip install jarjar --force-reinstall --upgrade
```

Then

```
jarjar sleep 1 -m 'Meesa took a nap!'
```

And...

![](https://jarjar.readthedocs.io/en/v3.0/_images/nap.png)