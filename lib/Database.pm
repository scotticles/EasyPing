package lib::Database;
use Modern::Perl;
use Moo;
use DBI;
use namespace::clean;

sub _getDB
{
    # See "Creating database handle" below
    my $dbh = DBI->connect ("dbi:CSV:f_dir=data/db", undef, undef, {
            f_ext      => ".csv/r",
            RaiseError => 1,
        }) or die "Cannot connect: $DBI::errstr";
    return $dbh;

}

sub getHosts 
{
    my ($self, $group) = @_;
    my $dbh = $self->_getDB();
    my $query = "SELECT * FROM hosts";
    if($group)
    {
        $query .= " where group = ?";
    }
    $query .= " ORDER BY id";
    my $sth = $dbh->prepare ($query);
    if($group)
    {
        $sth->execute($group);
    }
    else
    {
        $sth->execute();
    }
    
    my $data = $sth->fetchall_hashref('id');
    my $hosts = $sth->rows;
    $sth->finish ();
    return ($data, $hosts);
}

sub updateHost()
{
    my ($self, $id, $status) = @_;
    my $dbh = $self->_getDB();
    my $sth = $dbh->prepare ("UPDATE hosts SET status = ? WHERE id = ?");
    $sth->execute ($status, $id);
    $sth->finish;
    $dbh->disconnect;
}
sub removeHost
{
    my $self = shift;
    my $id = shift;
    my $dbh = $self->_getDB();
    my $sth = $dbh->prepare ("DELETE FROM hosts WHERE id = ?");
    $sth->execute ($id);
    $sth->finish;
    $dbh->disconnect;
}
sub addHost()
{
    my ($self, $group, $name, $host, $type_check, $email, $pushover, $webhook) = @_;
    my $dbh = $self->_getDB();
    my $sth = $dbh->prepare("select max(id) from hosts");
    $sth->execute();
    my $max = $sth->fetchrow_hashref->{'MAX'};
    my $id = $max+1;
    $sth = $dbh->prepare ("INSERT INTO hosts (
    id,group,name,host,status,type_check,email,pushover,webhook)
    VALUES (?, ?, ?, ?, 'up', ?, ?, ?, ?)");
    $sth->execute ($id,$group, $name, $host, $type_check, $email, $pushover, $webhook);
    $sth->finish;
    $dbh->disconnect;
}
1;