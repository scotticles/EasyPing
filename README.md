# EasyPing

#### Version 0.2

## TODO
* implement GD
    * small button with green or red status (used for a website link)
    * a status page png file that can be embedded
    * documentation on how to use the images
        * apache/nginx
        * scp to webhost
* logrotate example

## Description

EasyPing was written to ping devices such as network switches or critical points on a network and notify me and any co-worker(s) when the devices went up or down. I already use monitoring tools but those collect more then just a ping and are often a bother to do a simple ping task. I needed to have a ping solution that would notify me. There are plenty of tools out there that already do this but I wanted a simple script to do it without having a database backend service and having a web gui.

I picked a CSV file as the database table so that its easy to edit in a text editor such as vim or nano.

My current setup sends me emails for some of the devices and for more critical, I use my Pushover for my more critical things. I implemented Web checks and Script running which has made it a wrapper for cron job scripts with better notifications.

This system works well and hopefully it will help you out if you go with it.

I am open to improvements and feature requests.

## Features

* Ping Checks (ipv4, I dont think ipv6 will work)
* Web Checks (http, https)
* Scripts
* Parallelism - runs multiple checks at the same time (x workers)
* CSV Backend (SUPER Easy to edit)
* Groups for Cron jobs - put hosts in groups and run them when you want to check that group
* Notifications ( SMTP/Email, Pushover )
* Notification on Fail (Retries x times and if it fails, it will then send the email but you'll only receive one)
* Notificaiton on Recovery
* Easy to deploy

**I will eventually get around to adding a license on to this.**

## How to Install

#### Requirements: 

 * Linux
 * Perl 5.10+
 * SMTP Server (Does not do user/pass or TLS/SSL at this time)

To install extract the release with tar xvzf EasyPing_0.1.tar.gz or git clone
`git clone https://github.com/scotticles/EasyPing.git`

* `cd EasyPing dir`
* `sudo apt-get install libdev-ssl` or `libssl-dev` depending on distribution
* `sudo apt-get install zlib1g-dev` or a variant of that
* `sudo apt-get install carton`
* `carton install --deployment` <-- run this after updating from git

![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/screenshot-1.png "Carton Install")

* `cp easyping-example.conf easyping.conf`
* `cp db/hosts-example.csv db/hosts.csv`
* edit the easyping.conf and adjust the following fields

| Field                 | Description   |
| ---------------       |---------------|
| smtp_server           | 192.168.1.10                                          |
| smtp_server_port      | 25,587                                                | 
| smtp_server_type      | plain,tls (google is tls)                             | 
| smtp_server_username  | required if using tls                                 |
| smtp_server_password  | required if using tls                                 |
| from_address          | The email used for the from address                   |
| retry_attempts        | How many attempts before moving on to the next host   |
| retry_wait            | How many seconds to sleep before each retry attempt   |
| max_workers           | How many parallel workers do you want? (start with 3) |

* edit the db/hosts.csv and add in the hosts and for email you can do one email address or multiple
by "foo@bar.com,foo2@bar.com" 
** Do not put spaces, and you must wrap in quotes. **

id,name,ip,status,type_check,email

| Field          | Description   |
| ---------------|---------------|
| id         | A unique id for each host                                                         |
| group      | Group Name to put the host in                                                     |
| name       | Name of the host                                                                  |
| target     | IP Address of the host, website, or script to run                                 |
| status     | up,down, set it to up                                                             |
| type_check | ping, potential for other type of checks in future versions                       |
| email      | the email to send the notifications to "foo@bar.com" or "foo@bar.com,foo2@bar.com"|
| pushover   | the field needs to have the "token:user" and for multiple, "token:user,token:user", example  "23dfe234fds:23423d2f23" |


Once the config and hosts have been created you can run the script with the following command:
* edit easyping.cron.sh to match the paths
* `sudo chmod +x easyping.cron.sh` make it executable
* `carton exec /path/to/easyping.pl` this needs to be the full path


![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/screenshot.png "Run Screenshot")

This should output SUCCESS, FAIL or RECOVERED.
 

## Running Scripts
The scripts will run and needs the full path to the script in the target field wrapped in quotes. Example: `perl /path/to/script.pl`.

The script needs an exit code of 0 to be successful. Make sure it has an exit code of 0. If the script does fail to run it will also fail.

## How to Cron
* `vim /etc/cron.d/easyping`
* Without Groups
    * `*/5 * * * * scott /opt/EasyPing/cron.sh > /tmp/easyping.log`
* With Groups
    * `*/10 * * * * scott /opt/EasyPing/cron.sh groupA > /tmp/easyping.log`
    * `0 1 * * * scott /opt/EasyPing/cron.sh webHosts > /tmp/easyping.log`

This will output data that is seen from running it manual to the /tmp/easyping.log file. This could 
be helpful for troubleshooting later on or to check the return times of success pings.

## Logrotate
You will want to add in logrotate file to keep the logs from eating up storage.

## Status Page and Button
If set in settings PNG files will be created after a run that can be used on websites.
### Deployment Options

Because of browser caching, you'll want to append a timestamp on the page load. You'll want it to be something like this below. Adds a ` ?timestamp=x `, this will gurantee no caching.
 
` <img src='myeasypingurl/statusButton.png?timestamp=324324242'> `

#### Apache/Nginx
You could use apache/nginx to server the output directory and then from the website load the img tags
* ` <img src='myeasypingurl/statusButton.png'> `
* ` <img src='myeasypingurl/statusOverview.png'> `
* ` <img src='myeasypingurl/statusGroupA.png'> `

#### SCP/SFTP
You could scp the output folder to the webserver and then create a cron task to put them where they need to go on the webserver.