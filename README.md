# EasyPing

#### Version 0.3

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

**I will eventually get around to adding a license on to this.**

## Requirements: 

 * Linux
 * Perl 5.10+
 * (optional) SMTP Server (Does not do user/pass or TLS/SSL at this time)
 * (optional) Pushover

## WIKI Menu
* [Installation](https://github.com/scotticles/EasyPing/wiki/Installation)
* [Adding Hosts](https://github.com/scotticles/EasyPing/wiki/Adding-hosts)
* [Cron Scheduling Runs](https://github.com/scotticles/EasyPing/wiki/Cron-Scheduling-Runs)
* [Writing and Running Scripts](https://github.com/scotticles/EasyPing/wiki/Writing-and-Running-Scripts)
* [Command Line Commands](https://github.com/scotticles/EasyPing/wiki/Command-line-Commands)

#### TODO / thoughts:
* implement GD
    * small button with green or red status (used for a website link)
    * a status page png file that can be embedded
    * documentation on how to use the images
        * apache/nginx
        * scp to webhost
* logrotate example
##### Logrotate
You will want to add in logrotate file to keep the logs from eating up storage.

##### Status Page and Button
If set in settings PNG files will be created after a run that can be used on websites.

##### Deployment Options
Because of browser caching, you'll want to append a timestamp on the page load. You'll want it to be something like this below. Adds a ` ?timestamp=x `, this will gurantee no caching.
 
` <img src='myeasypingurl/statusButton.png?timestamp=324324242'> `

###### Apache/Nginx
You could use apache/nginx to server the output directory and then from the website load the img tags
* ` <img src='myeasypingurl/statusButton.png'> `
* ` <img src='myeasypingurl/statusOverview.png'> `
* ` <img src='myeasypingurl/statusGroupA.png'> `

##### SCP/SFTP
You could scp the output folder to the webserver and then create a cron task to put them where they need to go on the webserver.