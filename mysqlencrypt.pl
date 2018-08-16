#!/usr/bin/perl
#vi: set tabstop=3 autoindent


use Getopt::Std;
use DBI;

my %options;

my $dbh;
my $sth;

getopts ("h:u:p:vis", \%options);

my $host = $options{h} || "localhost";
my $user = $options{u} || "";
my $password = $options{p} || "";
my $showencstatus = $options{s} ? 1 : 0;

my $database = shift;

my @tables = @ARGV;

$dbh = DBI->connect ("dbi:mysql:host=" . $host . ":database=" . $database, $user, $password);

if (@tables == 0) {
   $sth = $dbh->prepare ("SHOW TABLES");
   $sth->execute;
   while (@row = $sth->fetchrow_array ()) {
	push @tables, @row;
   }
   $sth->finish;
}

foreach $table (@tables) {
   if ($showencstatus)
   {
      $sth = $dbh->prepare ("SELECT create_options FROM information_schema.tables WHERE table_schema = '$database' AND table_name = '$table'");
      if ($sth->execute) {
         @row = $sth->fetchrow_array ();
         printf "Table $database.$table has options %s\n", $database, $tables, @row;
      }
   }
   else
   {
      $sth = $dbh->prepare ("ALTER TABLE " . $table . " ENCRYPTION = 'Y'");
      if ($sth->execute) {
         printf "Encrypted %s.%s succesfully\n", $database, $table;
      }
      $sth->finish;
   }
}

$dbh->disconnect ();

exit 0;
