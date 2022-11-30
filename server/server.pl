#!/usr/bin/perl
package LogServer;
 
use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);

use Data::Dumper;

use lib ".";
use DatabaseConnector;
 
my %dispatch = (
	'/' => \&address_form,
    '/log_table' => \&log_table
    # ...
);
 
sub handle_request {
    my $self = shift;
    my $cgi  = shift;
   
    my $path = $cgi->path_info();
    my $handler = $dispatch{$path};
 
    if (ref($handler) eq "CODE") {
        print "HTTP/1.0 200 OK\r\n";
        $handler->($cgi);
         
    } else {
        print "HTTP/1.0 404 Not found\r\n";
        print $cgi->header,
              $cgi->start_html('Page not found'),
              $cgi->h1('Page not found'),
              $cgi->end_html;
    }
}

# Generate html table out of retrieved html data
sub generate_table {
	my ($prepared_query) = @_;
	
	my @table_data   = @{ $prepared_query->fetchall_arrayref({}) };
	my @columns  = @{ $prepared_query->{NAME} };
	
	my $table_head = join('', map {"<td>$_</td>"} @columns);
	
	my @rows = ();
	for my $hr (@table_data) {
	    push @rows, join('', map {"<td>$_</td>"} @{$hr}{@columns});
	}
	
	my $table_body = join ('', map {"<tr>$_</tr>"} @rows);
	
	
	my $html = qq|
		<center> 
			<table border=\"1\"> 
				<thead> 
					$table_head 
				</thead> 
				<tbody> 
					$table_body 
				</tbody> 
			</table> 
		</center>
	|;
	
	return $html;
}


# Generate initial address form to input the desired email address.
sub address_form {
    my $cgi  = shift;
    return if !ref $cgi;
    
    print $cgi->header;
    print $cgi->start_html("Address form");
    print "<center>";
    print $cgi->h1("Enter recepient address:"); 
    print $cgi->start_form(
    -name    => 'address_form',
    -method  => 'POST',
    -enctype => &CGI::URL_ENCODED,
    -action => '/log_table',
    );
    
    print $cgi->textfield(
    -name      => 'address',
    -value     => 'Email address',
    -size      => 20,
    );
    print "</center>";
    print $cgi->end_html;
}


# Generate result table html
sub log_table {
	my $cgi = shift;
	return if !ref $cgi;

	# Gather log data with chosen addres from the database and generate a html table
	my $address = $cgi->param('address');
    my $log_table_query = "SELECT created AS \"Creation datetime\", str AS \"Log string\" FROM log WHERE address=? ORDER BY int_id, created;";
    my $database_connection = DatabaseConnector::get_dbi_connection();
	my $prepared_log_table_query = $database_connection->prepare($log_table_query);
	$prepared_log_table_query->execute($address);
	my $log_table_html = generate_table($prepared_log_table_query);

	# Output table page html
	print $cgi->header;
	print $cgi->start_html("Log table");
	print "<center>";
    print $cgi->h1("Message log:");
	print $log_table_html;
    print "</center>"; 
    print $cgi->end_html;
}

my $LogServer = LogServer->new(8080);
$LogServer->run();