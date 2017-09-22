# EasyPing

#### Version 0.1

## Description

EasyPing was written to ping devices such as network switches or critical points on a network and notify me if they went up or down. I already use monitoring tools but
those collect more then just a ping and for devices I do not own; I just needed a ping solution. There are plenty 
of tools out there that already do this but I wanted a simple script to do it and did not want to install something that required config editing that took documentation reading to do so, 
a database backend or provided a GUI.

I picked CSV as the database so that its easy to edit in a text editor such as VIM. 

I hope this is easy for those that attempt to get going on it. If there is a request to add SMTP to Google, make the issue and it 
can probably be easily added.

My current setup send me emails on some devices and to more critical, I used my Pushover email alias to receive a more alerting notification.

**I will eventually get around to adding a license on to this.**

## How to Install

#### Requirements: 

 * Linux
 * Perl 5.10+
 * SMTP Server (Does not do user/pass or TLS/SSL at this time)

To install extract the release with tar xvzf EasyPing_0.1.tar.gz or git clone
`git clone https://github.com/scotticles/EasyPing.git`

* `cd EasyPing dir`
* `sudo apt-get install libdev-ssl` <--not sure if needed but Net::SMTP requires it...
* `sudo apt-get install carton`
* `carton install --deployment`

![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/screenshot-1.png "Carton Install")

* `cp db/settings-example.csv db/settings.csv`
* `cp db/hosts-example.csv db/hosts.csv`
* edit the db/settings.csv to set the SMTP IP address and the from email address.

| Field          | Description   |
| ---------------|---------------|
| smtp_server    | 192.168.1.10                                        |
| from_address   | The email used for the from address                 |
| retry_attempts | How many attempts before moving on to the next host |
| retry_wait     | How many seconds to sleep before each retry attempt |

* edit the db/hosts.csv and add in the hosts and for email you can do one email address or multiple
by "foo@bar.com,foo2@bar.com" Do not put spaces, but wrap in quotes.

id,name,ip,status,type_check,email

| Field          | Description   |
| ---------------|---------------|
| id         | A unique id for each host                                                         |
| name       | Name of the host                                                                  |
| ip         | IP Address of the host                                                            |
| status     | up,down, set it to up                                                             |
| type_check | ping, potential for other type of checks in future versions                       |
| email      | the email to send the notifications to "foo@bar.com" or "foo@bar.com,foo2@bar.com"|


Once the settings and hosts have been created you can run the script with the following command:
* edit cron.sh to match the paths
* `sudo chmod +x cron.sh` make it executable
* `carton exec /path/to/easyping.pl` this needs to be the full path


![alt text](https://github.com/scotticles/EasyPing/raw/master/screenshots/screenshot.png "Run Screenshot")

This should output SUCCESS or FAIL and end with an execution time, you want to keep
the execution time under the time it takes for the cron to run. If you check every 5 minutes, 
the script shouldn't take 5 minutes to run.
 
##How to Cron
* `vim /etc/cron.d/easyping`
* `*/5 * * * * scott /opt/EasyPing/cron.sh > /tmp/easyping.log`

This will output data that is seen from running it manual to the /tmp/easyping.log file. This could 
be helpful for troubleshooting later on or to check the return times of success pings.