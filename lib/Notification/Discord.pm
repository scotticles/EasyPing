package lib::Notification::Discord;
use Modern::Perl;
use Moo;
use Config::Tiny;
use WebService::Discord::Webhook;
use namespace::clean;

has config => (
  is => 'ro',
);

sub sendMessage {
    my ($self, $webhook, $message) = @_;
    $discord = WebService::Discord::Webhook->new( $webhook );

    my $result = eval {
        $discord->execute(content => $message);
    };
 
    if ($@) {
        # do something with the error here
        warn "Execute of Discord failed with error: $@";
    }
}

1;