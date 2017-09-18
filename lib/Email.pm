package Email;
use strict;
use warnings FATAL => 'all';
use Moo;
use Net::SMTP;
use namespace::clean;

sub sendMessage()
{
    my ($self, $smtp_server, $from, $to, $name, $ip) = @_;
    my $datestring = localtime();
    my $smtp = Net::SMTP->new($smtp_server, Debug => 0);
    $smtp->mail($from);
    $smtp->to($to);
    $smtp->data("Subject: $name is down!\nThe Host: $name \@ [$ip] went down on $datestring\r\n");
    $smtp->dataend;
    $smtp->quit;
}


1;