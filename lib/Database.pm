package lib::Database;
use Modern::Perl;
use Moo;
use DBI;
use namespace::clean;

sub _getDB
{
    # See "Creating database handle" below
    my $dbh = DBI->connect ("dbi:CSV:f_dir=db", undef, undef, {
            f_ext      => ".csv/r",
            RaiseError => 1,
        }) or die "Cannot connect: $DBI::errstr";
    return $dbh;

}

sub createTables
{
    my $self = shift;
    my $dbh = $self->_getDB();
    $dbh->do ("CREATE TABLE hosts (
        id INTEGER, 
        group CHAR (10), 
        name CHAR (10), 
        ip CHAR (10), 
        status Char (10),
        type_check Char (10),
        email Char (10), 
        max_workers CHAR(10)
        )");
}

sub getSettings
{
    my $self = shift;
    my $dbh = $self->_getDB();
    my $query = "SELECT * FROM settings";
    my $sth   = $dbh->prepare ($query);
    $sth->execute ();
    my $data = $sth->fetchrow_hashref();
    $sth->finish ();
    return $data;
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

1;