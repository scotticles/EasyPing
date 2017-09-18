package Ping;
use strict;
use warnings FATAL => 'all';

use Moo;
use Net::Ping;
use namespace::clean;

sub pingHost()
{
    my ($self, $host) = @_;

    my $p = Net::Ping->new('external');
    $p->hires();
    my ($ret, $duration, $ip) = $p->ping($host, 5.5);
    if ($ret)
    {
        #printf("$host [ip: $ip] is alive (packet return time: %.2f ms)\n", 1000 * $duration);
        return 1000 * $duration;
    }
    else
    {
        return 0;
    }
    $p->close();
}

1;