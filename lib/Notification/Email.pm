package lib::Notification::Email;
use Modern::Perl;
use Moo;
use Net::SMTP;
use Net::SMTPS;
use Config::Tiny;
use namespace::clean;

has config => (
  is => 'ro',
);

sub sendMessage()
{
    my ($self, $to, $name, $ip, $status, $message) = @_;
    my $timestamp = localtime();
    my $smtp;
    if($self->config->{SMTP}->{server_type} eq 'plain')
    {
        $smtp = Net::SMTP->new($self->config->{SMTP}->{server_address}, Debug => 0, Port => $self->config->{SMTP}->{server_port}, Timeout => 60);
    }
    elsif($self->config->{SMTP}->{server_type} eq 'tls')
    {
        $smtp = Net::SMTPS->new($self->config->{SMTP}->{server_address}, 
        Debug => 0, Port => $self->config->{SMTP}->{server_port}, doSSL=> 'starttls');
        $smtp->auth($self->config->{SMTP}->{server_username}, $self->config->{SMTP}->{server_password}, "LOGIN");
    }
    $smtp->mail($self->config->{SMTP}->{from_address});

    if ($smtp->to($to)) {
        $smtp->data();
        $smtp->datasend("To: $to");
        $smtp->datasend("\n");
        $smtp->datasend("From: ".$self->config->{SMTP}->{from_address});
        $smtp->datasend("\n");
        if($status eq 'down')
        {
            $smtp->datasend("Subject: $name failed!");
            $smtp->datasend("\n");
            $smtp->datasend("\n");
            $smtp->datasend($message);
        }
        else
        {
            $smtp->datasend("Subject: $name has recovered!");
            $smtp->datasend("\n");
            $smtp->datasend("\n");
            $smtp->datasend($message);
        }
        $smtp->datasend("\n");
        $smtp->dataend();
    } else {
        print "Error: ", $smtp->message();
    }

    $smtp->quit;
}


1;