package Email;
use strict;
use warnings FATAL => 'all';
use Moo;
use Net::SMTP;
use namespace::clean;

sub sendMessage()
{
    my ($self, $smtp_server, $from, $to, $name, $ip, $status) = @_;
    my $message;
    my $datestring = localtime();
    if($status eq 'down')
    {
        $message = "Subject: $name is down!\nThe Host: $name \@ [$ip] went down on $datestring\r\n";
    }
    else
    {
        $message = "Subject: $name has recovered!\nThe Host: $name \@ [$ip] recovered on $datestring\r\n"
    }

    my $smtp = Net::SMTP->new($smtp_server, Debug => 0);
    $smtp->mail($from);
    $smtp->to($to);
    $smtp->data($message);
    $smtp->dataend;
    $smtp->quit;
}


1;