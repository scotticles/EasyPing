#!/usr/bin/perl
use Modern::Perl;
use Time::HiRes qw(gettimeofday tv_interval);
use LWP::UserAgent;
use Config::Tiny;
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
use FindBin;                 # locate this script
use lib "$FindBin::Bin";  # use the parent directory

use lib::Database;
use lib::Checker;
use lib::Notification::Email;
use lib::Notification::Pushover;
use lib::Common;

#GET ARGS
my $group;
if($ARGV[0])
{
    $group = $ARGV[0];
}

#Create objects
my $config = Config::Tiny->read( 'easyping.conf' );
my $checker = lib::Checker->new( config => $config  );
my $db = lib::Database->new( config => $config );
my $email = lib::Notification::Email->new( config => $config );
my $common = lib::Common->new( config => $config );
my $pushover = lib::Notification::Pushover->new(config => $config);

my ($hosts, $totalHost) = $db->getHosts($group);
my $settings = $db->getSettings();
my $lwp  = LWP::UserAgent->new(
    protocols_allowed => ['http', 'https'],
    timeout           => 10,
);

#Constants
my $RETRY_ATTEMPTS = $config->{_}->{retry_attempts};
my $RETRY_WAIT = $config->{_}->{retry_wait};
my $MAX_WORKERS = $config->{_}->{max_workers};
my $attempts = $RETRY_ATTEMPTS;

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
        my $pingIP = $hosts->{'target'};
        $pingIP =~ s/^\s+|\s+$//g;
        CHECK_LOOP: while(1) {
            my $result = $checker->pingHost($pingIP);
            #If Success
            if ($result) {
                if($hosts->{'status'} eq 'down')
                {
                    my $message = sprintf(localtime()." - $hosts->{'name'} - $hosts->{'target'} (packet return time: %.2f ms) - RECOVERED\n", $result);
                    print $message;
                    $db->updateHost($hosts->{'id'}, 'up');
                    foreach (@emails) {
                        if(defined($_))
                        {
                            $email->sendMessage($_, $hosts->{'name'}, $hosts->{'target'}, 'up', $message);
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
                    printf (localtime()." - $hosts->{'name'} - $hosts->{'target'} (packet return time: %.2f ms) - SUCCESS\n", $result);
                    $db->updateHost($hosts->{'id'}, 'up');
                }
                last; #exit loop
            }
            else {
                my $message = localtime()." - $hosts->{'name'} - $hosts->{'target'} - FAILED!\n";
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
                                $email->sendMessage($_, $hosts->{'name'}, $hosts->{'target'}, 'down', $message);
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
            my $response = $lwp->head($hosts->{'target'});
            #warn Dumper($response);
            if($response->{'_rc'} eq '200')
            {
                if($hosts->{'status'} eq 'down')
                {
                    my $message = sprintf (localtime()." - $hosts->{'name'} - $hosts->{'target'} (web response ok) - RECOVERED\n");
                    print $message;
                    $db->updateHost($hosts->{'id'}, 'up');
                    foreach (@emails) {
                        if(defined($_))
                        {
                            $email->sendMessage($_, $hosts->{'name'}, $hosts->{'target'}, 'up', $message);
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
                    printf (localtime()." - $hosts->{'name'} - $hosts->{'target'} (web response ok) - SUCCESS\n");
                    $db->updateHost($hosts->{'id'}, 'up');
                }
                last; #exit loop
            }
            else
            {
                my $message = localtime()." - $hosts->{'name'} - $hosts->{'target'} (web response ".$response->{'_rc'}.") - FAILED!";
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
                                $email->sendMessage($_, $hosts->{'name'}, $hosts->{'target'}, 'down', $message);
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

        my ($stdout, $stderr) = capture {
            #system ( "snmpwalk -v $version -c $community $hostname $oid" );
            #qx($hosts->{'target'});
            system ($hosts->{"target"});
        };
        warn $stdout;
        my $exit = $? >> 8;
=head 
        if(!$output)
        {
            warn "ERROR IN SCRIPT";
            
        }
        else{
            my $exit = $? >> 8;
            warn "EXIT CODE: ".$exit;
        }
=cut
        #warn $out;
        #warn "EXIT CODE: ".$exit;
    }
} $hosts;

#Print out the duration of the script, this needs to be under the amount of time cron is set so that it has time to execute
#If it ends up being slow, Async will need to be applied.
my $elapsed = tv_interval($startTime, [gettimeofday]);
print "Execution Time: ".$elapsed."\n";

#my $out = system "perl testscript.pl";
#say $? >> 8;

#my $out = `perl testscript.pl`;
#say $out;
