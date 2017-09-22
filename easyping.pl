#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Time::HiRes qw(gettimeofday tv_interval);

use Data::Dumper;
print '
8888888888                        8888888b. d8b
888                               888   Y88bY8P
888                               888    888
8888888    8888b. .d8888b 888  888888   d88P88888888b.  .d88b.
888           "88b88K     888  8888888888P" 888888 "88bd88P"88b
888       .d888888"Y8888b.888  888888       888888  888888  888
888       888  888     X88Y88b 888888       888888  888Y88b 888
8888888888  Y888888 88888P    Y88888888     888888   888 Y88888
                               888                          888
                          Y8b d88P                     Y8b d88P
                            Y88P                         Y88P  '."\n\n\n";
my $startTime = [gettimeofday];

#Local Lib
use lib::Database;
use lib::Ping;
use lib::Email;

#Create objects
my $ping = Ping->new();
my $db = Database->new();
my $email = Email->new();

my $hosts = $db->getHosts();
my $settings = $db->getSettings();

#Constants
my $SMTP_SERVER = $settings->{'smtp_server'};
my $FROM_ADDRESS = $settings->{'from_address'};
my $RETRY_ATTEMPTS = $settings->{'retry_attempts'};
my $RETRY_WAIT = $settings->{'retry_wait'};
my $attempts = $RETRY_ATTEMPTS;

#Loop through each host
CHECK_LOOP: foreach my $key ( keys %{ $hosts } ) {
    if (${$hosts}{$key}->{'type_check'} eq 'ping') {
        #print "key: $key, value: ${$hosts}{$key}->{'ip'}\n";
        my @users = split(",", ${$hosts}{$key}->{'email'});
        my $pingIP = ${$hosts}{$key}->{'ip'};
        $pingIP =~ s/^\s+|\s+$//g;
        my $result = $ping->pingHost($pingIP);
        #If Success
        if ($result) {
            printf ("SUCCESS ${$hosts}{$key}->{'name'} \@ ${$hosts}{$key}->{'ip'} (packet return time: %.2f ms)\n", $result);
            if(${$hosts}{$key}->{'status'} eq 'down')
            {
                $db->updateHost(${$hosts}{$key}->{'id'}, 'up');
                foreach (@users) {
                        $email->sendMessage($SMTP_SERVER, $FROM_ADDRESS, $_, ${$hosts}{$key}->{'name'}, ${$hosts}{$key}->{'ip'}, 'up');
                }
            }
            else
            {
                $db->updateHost(${$hosts}{$key}->{'id'}, 'up');
            }
        }
        else {
            print "FAIL ${$hosts}{$key}->{'name'} \@ ${$hosts}{$key}->{'ip'}\n";
            if($attempts > 0)
            {
                sleep $RETRY_WAIT;
                $attempts--;
                redo CHECK_LOOP;
            }
            $attempts = $RETRY_ATTEMPTS;
            foreach (@users) {
                if(${$hosts}{$key}->{'status'} eq 'up')
                {
                    $db->updateHost(${$hosts}{$key}->{'id'}, 'down');
                    $email->sendMessage($SMTP_SERVER, $FROM_ADDRESS, $_, ${$hosts}{$key}->{'name'}, ${$hosts}{$key}->{'ip'}, 'down');
                }
            }
        }
    }
}

#Print out the duration of the script, this needs to be under the amount of time cron is set so that it has time to execute
#If it ends up being slow, Async will need to be applied.
my $elapsed = tv_interval($startTime, [gettimeofday]);
print "Execution TIme: ".$elapsed."\n";