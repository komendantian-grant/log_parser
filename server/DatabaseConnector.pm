use warnings;
use strict;

package DatabaseConnector;
my $LEVEL = 1;

use DBI;

# Connect to postgresql container
sub get_dbi_connection() {
	my $user = "postgres";
	my $password = "postgres";
	my $database = "log_base";
	my $host = "log_postgresql";
	my $port = "5432";
	my $database_connection = DBI->connect(
	    "DBI:Pg:dbname=$database;host=$host;port=$port",
	    $user, $password,
	    {
	        RaiseError => 1,
	        PrintError => 1,
	    }
	) or die $DBI::errstr;	
	return $database_connection
}


1;