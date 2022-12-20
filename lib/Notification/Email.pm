package lib::Notification::Email;
use Modern::Perl;
use Moo;
use Email::Sender::Transport::SMTP;
use Email::Stuffer;
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
    my $smtpTransport;
    if($self->config->{SMTP}->{server_type} eq 'plain')
    {
        $smtpTransport = Email::Sender::Transport::SMTP->new(
            host => $self->config->{SMTP}->{server_address},
            port => $self->config->{SMTP}->{server_port},
            helo => $self->config->{SMTP}->{server_domain}
        );
    }
    elsif($self->config->{SMTP}->{server_type} eq 'tls')
    {
        $smtpTransport = Email::Sender::Transport::SMTP->new(
            host => $self->config->{SMTP}->{server_address},
            port => $self->config->{SMTP}->{server_port},
            ssl => 'starttls',
            helo => $self->config->{SMTP}->{server_domain},
            username => $self->config->{SMTP}->{server_username},
            password => $self->config->{SMTP}->{server_password}
        );
    }
    my $subject;
    if($status eq 'down')
    {
        $subject = "EasyPing - $name failed!";
    }
    else
    {
        $subject = "EasyPing - $name has recovered!";
    }
    Email::Stuffer->transport($smtpTransport)
              ->from        ($self->config->{SMTP}->{from_address})
              ->subject     ($subject)
              ->to          ($to)
              ->text_body   ($message)
              ->send_or_die;
}


1;