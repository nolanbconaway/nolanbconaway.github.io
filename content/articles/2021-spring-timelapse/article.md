---
title: Watching spring arrive from my home office.
date: 2021-06-19
category: blog
keywords: timelapse,raspberry pi
---

During the winter of 2020, I hooked up a camera to a Raspberry Pi and started writing [python modules](https://github.com/nolanbconaway/rpi-camera) to do time lapse photography. Early on, I made some films of [winter storms](https://www.youtube.com/watch?v=8ykslLDXHdA) coming in over the course of 4-12 hour periods.

At the start of spring, I set up for a longer time lapse; I wanted to film the start of spring as seen from the window of my home office. There's a lot of greenery outside so I was hoping to quantify the proportion of the color space occupied by green over time.

Here's what I got:

<iframe width="720" height="405" src="https://www.youtube.com/embed/TQsMR8QJxsw" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

It can be a little difficult to see the greenery come in, so I made another version which clips to the focal regions:

<iframe width="720" height="405" src="https://www.youtube.com/embed/S1OscbAJsFM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

It can't hurt to look at a little before/after action. These two photos were taken at Noon.

<table style=>
<tr>
<th>April 7</th><th>April 25</th>
</tr>
<tr>
<td><img src={attach}2021-04-07.jpg></td>
<td><img src={attach}2021-04-25.jpg></td>
</tr>
</table>

Even here we're still only using Human vision to see how much green there is. I used opencv to do a really dumb calculation: the proportion of the RBG color volume that lies in the G channel each day:

<object type="image/svg+xml" data="{attach}timeline.svg"></object>

> NOTE: I do not know very much about computer vision; don't @ me.

The green channel gains dominance over time but it's not crazy evident. Probably what I am seeing as "green" is actually a mixture of lots of colors in the RGB space. 

In any case, if time lapse content is your jam, be on the lookout for another film of my tomatoes coming in!