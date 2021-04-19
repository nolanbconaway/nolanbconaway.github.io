---
title: Notifications for unknown SSH logins on your headless machines.
date: 2021-04-20
category: blog
keywords: ssh, security, raspberry pi, headless
---

I have four Linux servers (raspberry pi or otherwise) scattered around my apartment, and the thought of someone breaking into them can be pretty unsettling ::smiling_face_with_open_mouth_cold_sweat::. Besides all the usual steps one takes to secure machines like this (firewalls, disabling password authentication, port obfuscation, etc) I thought of one last precaution to help myself sleep better at night: **send an email notification whenever there's an SSH login from an unknown IP address**.

My various servers should only be logged into by me on my personal computer, or by each other in a cronjob situation. I've assigned each of these a static IP address using my router, so there's a very finite number of addresses that should be used to SSH into each.

## How it works

I add a shell script to the home directory of each server called `check-ssh-address`. The script uses a text file to remember all the historical addresses that have been used to log in via SSH.

If the current session is an SSH session, the script checks the IP address of the client against the known IP addresses. If the client is new, it sends an email and appends a new record to the text file. If the client is known, the script exits early.

Here's what that looks like:

```sh
#!/bin/bash

# set these
EMAIL_ADDR=''
EMAIL_PASS='' # you need an app password. NOT your gmail password.
KNOWN_ADDRESSES_FILE="$HOME/.ssh/known_addresses"

# exit if not ssh
if [ -z "$SSH_CONNECTION" ]; then exit 0; fi

# get IP address
IP_ADDRESS=`echo $SSH_CONNECTION | cut -d " " -f 1`

# make sure file exists, then read it
[ ! -f $KNOWN_ADDRESSES_FILE ] && touch $KNOWN_ADDRESSES_FILE
KNOWN_IPS=$(cat $KNOWN_ADDRESSES_FILE)

# check if the user IP is known
if [[ "$KNOWN_IPS" == *"$IP_ADDRESS"* ]]; then exit 0; fi

# add IP to known addresses
echo $IP_ADDRESS >> $KNOWN_ADDRESSES_FILE

# send an email
EMAIL_TEXT="\
From: $EMAIL_ADDR
To: $EMAIL_ADDR
Subject: SSH Session with unknown IP Address

A new IP address was used to log into $(hostname)!

User: $(whoami)
Date: $(date)
Address: $IP_ADDRESS

If it is you, that is great! Otherwise LOCK DOWN THAT MACHINE.
"

curl \
    --url "smtps://smtp.gmail.com:465"\
    --silent --show-error\
    --ssl-reqd \
    --mail-from "$EMAIL_ADDR" \
    --mail-rcpt "$EMAIL_ADDR" \
    --user "$EMAIL_ADDR:$EMAIL_PASS" \
    -T <(echo -e "$EMAIL_TEXT")
```

The last trick is to get that check to run each time there is an SSH login. You could add a call to `.bash_profile` or whatever, but I think it makes sense to put this in `~/.ssh/rc`.

```sh
$ touch $HOME/check-ssh-address
# ...
# Paste that file in, edit your email and APP PASSWORD (not your real password).
# ...
$ chmod +x $HOME/check-ssh-address
```

Then add this line to your `~/.ssh.rc`:

```sh
$HOME/check-ssh-address
```

To this date I have never been informed of a new login that was _not_ me, and here's hoping that I never do! ::folded_hands::.