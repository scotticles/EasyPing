# EasyPing

#### Version 0.4
![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/screenshot.png "Run Screenshot")
## Description

EasyPing was written to ping devices such as network switches or critical points on a network and notify me and any co-worker(s) when the devices went up or down. I already use monitoring tools but those collect more then just a ping and are often a bother to do a simple ping task. I needed to have a ping solution that would notify me without the hassle. There are plenty of tools out there that already do this but I wanted a simple script to do it without having a database backend service and having a web gui.

I picked a CSV file as the database table so that its easy to edit in a text editor such as vim or nano.

My current setup sends me emails for some of the devices, I use Pushover for my more critical things. I implemented Web checks and Script running which has made it a wrapper for cron job scripts with better notifications.

This system works well and hopefully it will help you out if you go with it.

I am open to improvements and feature requests.

## Features

* Ping Checks (ipv4, I dont think ipv6 will work)
* Web Checks (http, https)
* Script Running
* Parallelism - runs multiple checks at the same time (x workers)
* CSV Backend (SUPER Easy to edit)
* Groups for Cron jobs - put hosts in groups and run them when you want to check that group
* Notifications ( SMTP/Email, Pushover )
* Notification on Fail (Retries x times and if it fails, it will then send the email but you'll only receive one)
* Notification on Recovery
* Easy to deploy
* Dockerhub Image so you can launch it with docker or podman

### Demo
![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/demo.gif "Demo")

### Docker Demo
![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/docker.gif "Docker")

## Requirements: 

 * Linux
 * (Optional) Containers (docker or podman)
 * Perl 5.10+
 * Notification Types:
    * (optional) SMTP Server
    * (optional) Pushover
    * (optional) Slack
    * (optional) GSuite Chat Room / google chat
    * (optional) Discord

## Wiki
Please refer to the [wiki](https://github.com/scotticles/EasyPing/wiki) for how to install and use.
