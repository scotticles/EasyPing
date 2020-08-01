package lib::Notification::GoogleChat;
use Modern::Perl;
use Moo;
use Config::Tiny;
use Net::Pushover;
use JSON;
use namespace::clean;

has config => (
  is => 'ro',
);

=head
http_obj.request(
  uri=THE_SAVED_URL,
  method='POST',
  headers=message_headers,
  body=dumps(bot_message),
)
=cut
sub sendMessage {
    my ($self, $webhook, $message) = @_;
    my $ua  = LWP::UserAgent->new(
        protocols_allowed => ['https'],
       # default_header    => 'content_type' => 'application/json; charset=UTF-8'
    );
    $ua->default_header('content_type' => 'application/json');

    my $gmessage = { 
                    'text' => $message
                   };
    
    my $res = $ua->post( $webhook, Content => encode_json($gmessage));
    if($res->{'_rc'} != 200)
    {
        warn "Error with Google Chat Webhook, unable to send message!";
    }
}

1;