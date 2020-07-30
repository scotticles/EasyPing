#!/usr/bin/perl
use Modern::Perl;
use Time::HiRes qw(gettimeofday tv_interval);
use LWP::UserAgent;
use Config::Tiny;
use Getopt::Long;
use Data::Dumper;


#Local Lib
use FindBin;                 # locate this script
use lib "$FindBin::Bin";  # use the parent directory

use lib::Database;
use lib::Checker;
use lib::Notification::Email;
use lib::Notification::Pushover;
use lib::Common;
use lib::Host;

my $group;
my $menu_group;
my $menu_banner;
my $menu_cron;
my $menu_host;
my $menu_help;
#GET ARGS
GetOptions (
            "group=s" => \$menu_group,
            "nobanner"   => \$menu_banner,
            "cron" => \$menu_cron,
            "host=s" => \$menu_host,
            "help" => \$menu_help,
           )
or die("Error in command line arguments, type --help for the menu.\n");
$group = $menu_group;
if($menu_help)
{
    print("======== COMMANDS ========\n");
    print("-g --group <group>       picks the group to run\n");
    print("-n --nobanner            removes the banner\n");
    print("-c --cron                used for cron mode (removes banner and start,stop execution times\n");
    print("-h --host <add|remove|list> manage hosts\n");
    exit;
}

if(!$menu_cron && !$menu_banner) {
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
}
my $startTime;
if(!$menu_cron) {
    $startTime = [gettimeofday];
}

#Create objects
my $config = Config::Tiny->read( 'easyping.conf' );
my $checker = lib::Checker->new( config => $config  );
my $db = lib::Database->new( config => $config );
my $email = lib::Notification::Email->new( config => $config );
my $common = lib::Common->new( config => $config );
my $pushover = lib::Notification::Pushover->new(config => $config);
my $host = lib::Host->new();

my ($hosts, $totalHost) = $db->getHosts($group);

my $lwp  = LWP::UserAgent->new(
    protocols_allowed => ['http', 'https'],
    timeout           => 10,
);

#Constants
my $RETRY_ATTEMPTS = $config->{_}->{retry_attempts};
my $RETRY_WAIT = $config->{_}->{retry_wait};
my $MAX_WORKERS = $config->{_}->{max_workers};
my $attempts = $RETRY_ATTEMPTS;

#host menu
if($menu_host)
{
    if($menu_host eq 'add')
    {
        $host->addHostMenu();
    }
    elsif($menu_host eq 'list')
    {
        $host->getHostMenu();
    }
    elsif($menu_host eq 'remove')
    {
        $host->removeHostMenu();
    }
}


#MCE Config
use MCE::Loop;

MCE::Loop->init(
   max_workers => $MAX_WORKERS, chunk_size => 1
);

mce_loop {
   my ($mce, $chunk_ref, $chunk_id) = @_;
    my $hosts = $common->flattenHash($_);
    my @pushovers = undef;
    my @emails = undef;
    if($hosts->{'pushover'})
    {
        @pushovers = split(",", $hosts->{'pushover'});
    }
    if($hosts->{'email'})
    {
        @emails = split(",", $hosts->{'email'});
    }
    if($hosts->{'type_check'} eq 'ping')
    {
        my $pingIP = $hosts->{'host'};
        $pingIP =~ s/^\s+|\s+$//g;
        CHECK_LOOP: while(1) {
            my $result = $checker->pingHost($pingIP);
            #If Success
            if ($result) {
                if($hosts->{'status'} eq 'down')
                {
                    my $message = sprintf(localtime()." - $hosts->{'name'} - $hosts->{'host'} (packet return time: %.2f ms) - RECOVERED\n", $result);
                    print $message;
                    $db->updateHost($hosts->{'id'}, 'up');
                    foreach (@emails) {
                        if(defined($_))
                        {
                            $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'up', $message);
                        }
                    }
                    foreach(@pushovers)
                    {
                        if(defined($_))
                        {
                            my @pushoverData = split(":", $_);
                            $pushover->sendMessage($pushoverData[0], $pushoverData[1], "recovered", $message);
                        }
                    }
                }
                else
                {
                    printf (localtime()." - $hosts->{'name'} - $hosts->{'host'} (packet return time: %.2f ms) - SUCCESS\n", $result);
                    $db->updateHost($hosts->{'id'}, 'up');
                }
                last; #exit loop
            }
            else {
                my $message = localtime()." - $hosts->{'name'} - $hosts->{'host'} - FAILED!\n";
                print $message;
                if($attempts > 0)
                {
                    sleep $RETRY_WAIT;
                    $attempts--;
                    redo CHECK_LOOP;
                }
                $attempts = $RETRY_ATTEMPTS;

                $db->updateHost($hosts->{'id'}, 'down');
                if($hosts->{'status'} eq 'up')
                    {
                        foreach (@emails) {
                            if(defined($_))
                            {
                                $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'down', $message);
                            }
                        }
                        foreach(@pushovers)
                        {
                            if(defined($_))
                            {
                                my @pushoverData = split(":", $_);
                                $pushover->sendMessage($pushoverData[0], $pushoverData[1], "down", $message);
                            }
                        }
                    }
                last; #exit loop
            }
        }
    }
    elsif($hosts->{'type_check'} eq 'web')
    {
        #my @emails = split(",", $hosts->{'email'});
        CHECK_LOOP: while(1) {
            my $response = $lwp->head($hosts->{'host'});
            #warn Dumper($response);
            if($response->{'_rc'} eq '200')
            {
                if($hosts->{'status'} eq 'down')
                {
                    my $message = sprintf (localtime()." - $hosts->{'name'} - $hosts->{'host'} (web response ok) - RECOVERED\n");
                    print $message;
                    $db->updateHost($hosts->{'id'}, 'up');
                    foreach (@emails) {
                        if(defined($_))
                        {
                            $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'up', $message);
                        }
                    }
                    foreach(@pushovers)
                    {
                        if(defined($_))
                        {
                            my @pushoverData = split(":", $_);
                            $pushover->sendMessage($pushoverData[0], $pushoverData[1], "recovered", $message);
                        }
                    }
                }
                else
                {
                    printf (localtime()." - $hosts->{'name'} - $hosts->{'host'} (web response ok) - SUCCESS\n");
                    $db->updateHost($hosts->{'id'}, 'up');
                }
                last; #exit loop
            }
            else
            {
                my $message = localtime()." - $hosts->{'name'} - $hosts->{'host'} (web response ".$response->{'_rc'}.") - FAILED!";
                say $message;
                if($attempts > 0)
                {
                    sleep $RETRY_WAIT;
                    $attempts--;
                    redo CHECK_LOOP;
                }
                $attempts = $RETRY_ATTEMPTS;
                $db->updateHost($hosts->{'id'}, 'down');
                if($hosts->{'status'} eq 'up')
                {
                    foreach (@emails) {
                        if(defined($_))
                        {
                            $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'down', $message);
                        }
                    }
                    foreach(@pushovers)
                    {
                        if(defined($_))
                        {
                            my @pushoverData = split(":", $_);
                            $pushover->sendMessage($pushoverData[0], $pushoverData[1], "down", $message);
                        }
                    }
                }
                last; #exit loop
            }
        }
    }
    elsif($hosts->{'type_check'} eq 'script')
    {
        use Capture::Tiny qw/capture/;

        CHECK_LOOP: while(1) {
        #my $response = $lwp->head($hosts->{'host'});
        my ($stdout, $stderr) = capture {
                #system ( "snmpwalk -v $version -c $community $hostname $oid" );
                #qx($hosts->{'host'});
                system($hosts->{"host"});
            };
        #warn $stdout;
        my $exit = $? >> 8;

        #warn Dumper($response);
        if($exit == 0)
        {
            if($hosts->{'status'} eq 'down')
            {
                my $message = sprintf (localtime()." - $hosts->{'name'} - $hosts->{'host'} - RECOVERED\n");
                if($config->{SCRIPTING}->{'ONSUCCESS_STDOUT'} && $stdout)
                {
                    $message .= "STDOUT: ".$stdout."\n";
                }
                print $message;
                $db->updateHost($hosts->{'id'}, 'up');
                foreach (@emails) {
                    if(defined($_))
                    {
                        $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'up', $message);
                    }
                }
                foreach(@pushovers)
                {
                    if(defined($_))
                    {
                        my @pushoverData = split(":", $_);
                        $pushover->sendMessage($pushoverData[0], $pushoverData[1], "recovered", $message);
                    }
                }
            }
            else
            {
                printf (localtime()." - $hosts->{'name'} - $hosts->{'host'} - SUCCESS\n");
                if($config->{SCRIPTING}->{'ONSUCCESS_STDOUT'} && $stdout)
                {
                    say "STDOUT: ".$stdout;
                }
                $db->updateHost($hosts->{'id'}, 'up');
            }
            last; #exit loop
        }
        else
        {
            my $message = localtime()." - $hosts->{'name'} - $hosts->{'host'} - FAILED!
Exit Code: ".$exit."
-------------------
STDOUT: ".$stdout."
-------------------
STDERR: ".$stderr;
            say $message;
            if($attempts > 0)
            {
                sleep $RETRY_WAIT;
                $attempts--;
                redo CHECK_LOOP;
            }
            $attempts = $RETRY_ATTEMPTS;
            $db->updateHost($hosts->{'id'}, 'down');
            if($hosts->{'status'} eq 'up')
            {
                foreach (@emails) {
                    if(defined($_))
                    {
                        $email->sendMessage($_, $hosts->{'name'}, $hosts->{'host'}, 'down', $message);
                    }
                }
                foreach(@pushovers)
                {
                    if(defined($_))
                    {
                        my @pushoverData = split(":", $_);
                        $pushover->sendMessage($pushoverData[0], $pushoverData[1], "down", $message);
                    }
                }
            }
            last; #exit loop
        }
        }
    }
} $hosts;

#Print out the duration of the script, this needs to be under the amount of time cron is set so that it has time to execute
#If it ends up being slow, Async will need to be applied.
if(!$menu_cron) {
    my $elapsed = tv_interval($startTime, [gettimeofday]);
    print "Execution Time: ".$elapsed."\n";
}