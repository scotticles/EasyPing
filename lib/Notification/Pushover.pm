package lib::Notification::Pushover;
use Modern::Perl;
use Moo;
use Config::Tiny;
use Net::Pushover;
use namespace::clean;

has config => (
  is => 'ro',
);

sub sendMessage {
    my ($self, $token, $user, $status, $message) = @_;
    # new object with auth parameters
    my $push = Net::Pushover->new(
        token => $token,
        user  => $user
    );
    my $priority = "-1";
    if($status eq "down")
    {
        $priority = 1;
    }
 
    # send a notification
    $push->message( 
    title => "EasyPing - ".localtime(), 
    text => $message,
    priority => $priority #1 = alert, -1 = normal no red 
    );
=head
    use WebService::Pushover;
 
    my $push = WebService::Pushover->new(
        user_token => 'a2xx2c1h58tb8g6wozvvffos5ukj9u',
        api_token  => 'gqtfw7t2oodcnmi63ekxi6zad6wcmv',
        debug => 'true',
    ) or die( "Unable to instantiate WebService::Pushover.\n" );
    my %params = (
        message  => 'test test test',
        priority => 1,
    );
    
    my $status = $push->message( %params );
=cut
}

1;