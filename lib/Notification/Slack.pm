package lib::Notification::Slack;
use Modern::Perl;
use Moo;
use Config::Tiny;
use Slack::Notify;
use namespace::clean;

has config => (
  is => 'ro',
);

sub sendMessage {
    my ($self, $webhook, $message) = @_;
    my $n = Slack::Notify->new(
        hook_url => $webhook
    );

    my $return = $n->post(
        text => $message,
    );

    if($return->{'status'} != 200)
    {
        warn "Error with Slack Webhook, unable to send message!";
    }
}

1;