package lib::Host;
use Modern::Perl;
use Moo;
use lib::Database;
use namespace::clean;

sub removeHostMenu {
    my $self = shift;

    print "Enter the ID of the host?";
    my $id = <STDIN>;
    chomp($id);
    my $db = lib::Database->new();
    $db->removeHost($id);
    print "Host has been removed!\n";
    exit;
}

sub addHostMenu {
    my $self = shift;
    print "What is the Host group (enter for none)? ";
    my $group = <STDIN>;
    chomp($group);
    print "What is the Host name? ";
    my $name = <STDIN>;
    chomp($name);
    print "What is the Host (ip address of host, url of host, script path)? ";
    my $host = <STDIN>;
    chomp($host);
    print "What is the Host type (ping,web,script)? ";
    my $type = <STDIN>;
    chomp($type);
    print "What email addresses should be used for contact (enter for none)? ";
    my $email = <STDIN>;
    chomp($email);
    print "What pushover addresses should be used for contact (enter for none)? ";
    my $pushover = <STDIN>;
    chomp($pushover);
    print "What webhook addresses should be used for contact (enter for none)? ";
    my $webhook = <STDIN>;
    chomp($webhook);

    my $db = lib::Database->new();
    $db->addHost($group, $name, $host, $type, $email, $pushover, $webhook);

    print "Host has been added\n";
    
    exit;
}

sub getHostMenu
{
    my $self = shift;
    my $db = lib::Database->new();
    use lib::Common;
    my ($hosts, $totalHost) = $db->getHosts();
    use Term::Table2;
    my @data;
    foreach my $id (sort keys %{$hosts})
    {
        my @row = (
            $hosts->{$id}->{'id'}, 
            $hosts->{$id}->{'status'}, 
            $hosts->{$id}->{'type_check'}, 
            $hosts->{$id}->{'group'}, 
            $hosts->{$id}->{'name'},
            $hosts->{$id}->{'host'},
            $hosts->{$id}->{'email'},
            $hosts->{$id}->{'pushover'}
            $hosts->{$id}->{'webhook'}
            );
       push @data, \@row;
    }

    my $table = Term::Table2->new(            # based on array of rows
    header      => [                        # defaults to output without header
    'ID',
    'Status',
    'Type Check',
    'Group',
    'Name',
    'Host',
    'Email',
    'Pushover',
    'Webhook'
  ],
  rows        => \@data,
  #broad_column => ["CUT", "CUT", "CUT", "CUT", "CUT", "CUT"],  # defaults to wrap for all values in columns
  #broad_header => ["CUT", "CUT", "CUT", "CUT", "CUT", "CUT"],  # defaults to wrap for all values in headers
  #broad_row    => 'CUT',                    # defaults to row wrap; supports split to other page, too
  collapse     => [0, 0, 1, 1, 1, 1, 1, 0, 0],           # defaults to no collapse for all columns
  column_width => [2, 6, 10, 10, 20, 20, 20, 30, 30],     # defaults to maximum text length within header / values
  pad          => 2,                      # defaults to 1 for each side
  page_height  => 100,                    # defaults to 0 (no paging)
  table_width  => 180,                    # defaults to screen size
);
 
say while $table->fetch();
    exit;
}

1;