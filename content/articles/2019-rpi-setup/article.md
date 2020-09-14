---
title: Configuring a headless raspberry pi on your home network.
date: 2019-03-06
category: blog
slug: rpi-setup
keywords: raspberry pi, headless, tutorial
---

I do a lot of projects that involve raspberry pis. At this point, there are three tucked away in different corners of my apartment (one runs an online [temperature sensor](/blog/2018/apartment-temp)). They all run headless and I SSH into them occasionally to see if anything has broken.

I recently set up a fresh Raspberry Pi 3 B+. The project was to hook up a [PiTFT display](https://www.adafruit.com/product/2097) and use it to show upcoming Manhattan-bound Q trains.

The initial setup for a headless raspberry pi can be tricky. Since I've done this more than a handful of times, I thought I'd record the steps I take to configure my new machine.

## Install Raspbian

I have never been able to remember the syntax to `dd`, so I just head over to raspberrypi.org and follow [their instructions](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).

As for the Raspbian distribution, I choose the latest "lite" version (right now it is "Raspbian Stretch Lite") because I don't use the desktop environment. But you do you.

### Before you proceed ...

Consider the catch-22 situation you're in. In order to connect to a headless pi, you need to have set up ssh. But you also need to connect to it _in order to set up ssh_. Luckily, there's a little trick to set up ssh before the first boot.

Simply add a blank file, `ssh`, to the root of the SD card. I never can remember where my SD card mount lives in the mac filesystem, so I navigate my finder to the mounted SD card and use [Go2Shell](https://zipzapmac.com/Go2Shell) to put my terminal there. Then a simple `touch ssh` command will do the trick.

If you want to connect to your pi via wifi, you've arrived at yet another catch-22 situation. As far as I know, you need to be able to connect to your pi in order to configure the wifi connection. What a nightmare.

I don't know any tricks here; for the time being, you'll need to connect to the pi via ethernet. I'll run through how to set up wifi later in this post.

## Boot it up

With SSH enabled, you should be able to connect to the pi remotely via ethernet the very first time you boot it up. You won't know the machine's IP address ahead of time, but you can get that info a bunch of different ways (I use [iNet Network Scanner](https://inetapp.de/en/inetx.html)).

Once you discover the IP address, ssh in. The default username and password are, of course, `pi` and `raspberry`.

```sh
ssh pi@<IP Address>
```

## Step 1: update / upgrade

Get this out of the way. Should take a few mins, depending on the speed of your network.

```sh
sudo apt-get update && sudo apt-get upgrade -y
```

## Step 2: raspi-config

By default the locale for raspberry pis are set to `en_GB.UTF8`. I, like many other people, live in NYC. So I need to change the locale (keyboard layout, character set, timezone, etc) for myself. Do this with the built-in GUI tool `raspi-config`. Run it under sudo:

```sh
sudo raspi-config
```

You'll get a display that looks like:

![Raspi Config]({attach}main.png)

I end up doing a lot of tinkering in here.

1. __Network Options -> Hostname__. So that my machine has an informative name on my network.
2. __Advanced Options -> Expand Filesystem__. Gimme _all_ that sweet, sweet SD memory.

Whatever you do, you want to make sure to hit __Localisation Options__.

![Localisation]({attach}localisation.png)

When you hit the "Change Locale" menu, you'll get a very long list of possible locales. Scroll with your arrow keys (it sucks and takes forever) and press spacebar on the to select / deselect.

Personally, I deselect `en_GB.UTF-8 UTF-8` and then select `en_US.UTF-8 UTF-8`.

When you're done, hit OK (skip there by pressing TAB). The next screen lets you choose your default locale. Just highlight the one you want and TAB to OK. You should be good to go.

Next, change your timezone. This works a lot like setting your locale; highlight your region and TAB to OK.

## Step 3: Set up wifi connection

If you want to connect to your raspberry pi on your wifi network, you'll want configure the connection earlier rather than later. I cannot tell you how many times I have lost all ability to connect to my machine (ethernet or otherwise) after messing up the network configuration in an attempt to set up the darn wifi.

If you might break it all, you'll want to do it _before_ you invest a lot of time into configuration.

 There are [like a million posts on how to configure a wifi connection](https://www.google.com/search?q=raspberry+pi+wireless+connection). The [authoritative guide on the subject](https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md) can be found on raspberrypi.org, and you might just want to do that.

As for me, I don't know how _not_ to break this stuff. So I just copy over config from another, working, raspberry pi. My config looks like:

### `/etc/network/interfaces`

```text
source-directory /etc/network/interfaces.d

auto wlan0
iface wlan0 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

### `/etc/wpa_supplicant/wpa_supplicant.conf`

```text
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
	ssid="network name"
	psk="password"
}
```

### Reboot

This is the moment of truth. Did you break everything? There's no shame in it. If so, hopefully you can still connect via ethernet, in which case you can tinker around until you get a wifi connection.


## Step 4: Set up a static IP.

If you didn't ruin everything in step 3, you should be able to ssh in your pi again.

At this point, your raspberry pi will be assigned an IP address each time it connects to your network. The address could change across reboots and I don't like having to check the address each time.

The solution is to configure a static IP address. If you like pain, there is a way to configure the static address on your raspberry pi. But, to me, that has always felt _way_ too complicated, [see this Stack Exchange post](https://raspberrypi.stackexchange.com/questions/37920/how-do-i-set-up-networking-wifi-static-ip-address).

I find it much easier to do this via my router's admin panel. Most routers will have a section in which you can specify a DHCP reservation for a specific MAC address. This is just a fancy way of making sure your router assigns a specific IP address to your raspberry pi, and that it never assigns any other device to that address.

I use an Apple Airport Express, here's what that configuration screen looks like:

![airport express network options](https://discussions.apple.com/content/attachment/466201040)

## Step 5: Enable passwordless ssh.

I hate typing my passwords so I make sure to set up passwordless ssh.

The idea here is that you create a `key` on the machine you are using to ssh into the pi _from_ (that is, the computer you are in front of). Then you paste that key in a special place on the pi. When you try to log in, ssh will compare the keys and let you in without a password if they match.

First thing, you'll need to make your key. Keys are unique to the machine you are ssh-ing _from_, so if you've done this before you don't need to do it again. [Here's a tutorial on how you'd make an ssh key on a mac](https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-mac-os-x).

Your key will probably live in `~/.ssh/id_rsa.pub` and will look something like:

```sh
ssh-rsa <lots of letters and numbers>== user@host
```

One you have that key copy-pasteable, you can run this command on your raspberry pi:

```sh
cd && mkdir .ssh && nano .ssh/authorized_keys
```

Paste the key from your computer in that bad boy, save the file (`ctrl-O`), then log out and log back in. When you log back in, you shouldn't be asked for your password.

## Step 6: Change the username and password.

Everybody knows the default login for a raspberry pi (or at least, lots of people). So for security you'll want to change them. Changing the username can be a bit of a hassle since you need to move around the user home, etc, so I only change the username if I plan on opening my firewall to allow outside connections (gotta have that _extra_ security).

In either case, _definitely_ change the password. You can do that with:

```sh
passwd
```

So easy.

## Step 7: Installations

At this point:

1. Your raspberry pi has updated packages and the right locale.
2. The network connectivity is in place.
3. The same IP address is assigned to your machine each time you reboot.
4. It is at least kind of secure with a nondefault password.

Now you get to install the stuff you want to use for your projects. Each project requires different tooling, so below I'll list some of the common items I install each time:

### mailutils

I run a lot of stuff in cron and I want to make sure I get notified if a job fails. If you install mailtutils, cron errors will automatically go to mail and you'll get an indicator if there was a failure when you log in.

```sh
sudo apt-get install mailutils
```

### zsh, oh-my-zsh

I love zsh. _Love it_. It's even better when you use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) as a configuration manager.

```sh
sudo apt-get install zsh;
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

That's all. Have fun spending the next hour [picking your theme](https://github.com/robbyrussell/oh-my-zsh/wiki/Themes).

### python

> **Dec 2019**: these days I am all about pyenv and I would probably opt for that instead.

I use python for basically everything. I prefer to keep the raspberry pi pre-installed python clean, so I opt to install my own python.

There are a bunch if tutorials on how to build a python distribution on a raspberry pi. [Here is one](https://gist.github.com/SeppPenner/6a5a30ebc8f79936fa136c524417761d). Even if you know what you're doing, it takes freaking forever to `configure && make && make install` the thing. If you do not know what you are doing (I do not know what _I_ am doing), it'll take you that amount of freaking forever to learn something is wrong and that you have to do a different `configure && make && make install`.

Learn from my mistakes. Use [Berryconda](https://github.com/jjhelmus/berryconda). Berryconda is pre-built conda distribution for raspberry pi. It only takes a few minutes to set up and it "just works". Follow the instructions on the github page to install. It should be something like:

```sh
wget https://github.com/jjhelmus/berryconda/releases/download/v2.0.0/Berryconda3-2.0.0-Linux-armv7l.sh && \
chmod +x Berryconda3-2.0.0-Linux-armv7l.sh && \
./Berryconda3-2.0.0-Linux-armv7l.sh
```

That'll walk you through the installation.

If you installed zsh, you'll want to make sure to put the berryconda binary directory on your path (so that zsh knows what to do when you refer to `python`). Add a line like this to your `~/.zshrc`:

```sh
export PATH="$PATH:$HOME/berryconda3/bin"
```

Where `$HOME/berryconda3/bin` is wherever you decided to install berryconda. Then, you should confirm that your python3 command refers to the berryconda install:

```sh
which python3
```
Should output something like `/home/pi/berryconda3/bin/python3` not `/usr/bin/python3`.
