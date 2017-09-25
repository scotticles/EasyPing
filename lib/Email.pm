package Email;
use strict;
use warnings FATAL => 'all';
use Moo;
use Net::SMTP;
use Net::SMTPS;
use namespace::clean;

sub sendMessage()
{
    my ($self, $smtp_server, $smtp_server_port, $smtp_server_type, $smtp_server_username, $smtp_server_password, $from, $to, $name, $ip, $status) = @_;
    my $datestring = localtime();
    my $smtp;
    if($smtp_server_type eq 'plain')
    {
        $smtp = Net::SMTP->new($smtp_server, Debug => 0, Port => $smtp_server_port);
    }
    elsif($smtp_server_type eq 'tls')
    {
        $smtp = Net::SMTPS->new($smtp_server, Debug => 0, Port => $smtp_server_port, doSSL=> 'starttls');
        $smtp->auth($smtp_server_username, $smtp_server_password);
    }

    $smtp->mail($from);

    if ($smtp->to($to)) {
        $smtp->data();
        $smtp->datasend("To: $to");
        $smtp->datasend("\n");
        $smtp->datasend("From: $from");
        $smtp->datasend("\n");
        if($status eq 'down')
        {
            $smtp->datasend("Subject: $name is down!");
            $smtp->datasend("\n");
            $smtp->datasend("\n");
            $smtp->datasend("$name - $ip went down on $datestring");
        }
        else
        {
            $smtp->datasend("Subject: $name has recovered!");
            $smtp->datasend("\n");
            $smtp->datasend("\n");
            $smtp->datasend("$name - $ip recovered on $datestring");
        }
        $smtp->datasend("\n");
        $smtp->dataend();
    } else {
        print "Error: ", $smtp->message();
    }

    $smtp->quit;
}


1;