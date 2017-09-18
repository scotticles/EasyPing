# EasyPing

#### Version 0.1

## How to Install

#### Requirements: 

 * Linux
 * Perl 5.24+
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
* edit the db/hosts.csv and add in the hosts and for email you can do one email address or multiple
by "email1@domain.com,email2@domain.com" Do not put spaces, but wrap in quotes.

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
* `*/5 * * * * scott /opt/EasyPing/easyping.sh > /tmp/easyping.log`

This will output data that is seen from running it manual to the /tmp/easyping.log file. This could 
be helpful for troubleshooting later on or to check the return times of success pings.