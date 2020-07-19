package lib::Common;
use Modern::Perl;
use Moo;
use namespace::clean;

sub flattenHash {
    my $self = shift;
    my $hash = shift;
    my $newHash;
    foreach my $key ( keys %{ $hash } ) {
        $newHash = ${$hash}{$key};
    }
    return $newHash;
}

1;