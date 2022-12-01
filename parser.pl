use strict;
use warnings;
use feature qw(say);

use lib ".";
use DatabaseConnector;

my $dbh = DatabaseConnector::get_dbi_connection();

my $query = 'INSERT INTO message (id, int_id, str) VALUES (?, 1, "haha")';
my $sth  = $dbh->prepare($query);

my $clean_message_query = '
	DELETE FROM message;
';
my $prepared_clean_message_query = $dbh->prepare($clean_message_query);
$prepared_clean_message_query->execute();

my $clean_log_query = '
	DELETE FROM log;
';
my $prepared_clean_log_query = $dbh->prepare($clean_log_query);
$prepared_clean_log_query->execute();


my $insert_query_message = 'INSERT INTO message (created, id, int_id, str, status) VALUES (?, ?, ?, ?, ?)';
my $prepared_insert_query_message = $dbh->prepare($insert_query_message);
my $insert_query_log = 'INSERT INTO log (created, int_id, str, address) VALUES (?, ?, ?, ?)';
my $prepared_insert_query_log = $dbh->prepare($insert_query_log);

my $log_filename = $ARGV[0];

open(LOGFILE, "<", $log_filename);

my $line_counter = 0;
my $counter = 0;
my ($created_date, $created_time, $internal_id, $flag, $misc);
my $str_no_datetime;
my $int_id;
my $address_receiver;
while(<LOGFILE>) {
	$line_counter++;
	my @values = split(' ', $_);
	my $flag = $values[3]; 
	if ($flag eq '<=') {
		$counter++;
		($created_date, $created_time, $internal_id, $flag, $misc) = $_ =~ /(\S+)\s(\S+)\s(\S+)\s(\S+)\s(.+)/;
		($int_id) = $misc =~ /id=(\d+)/;
		($str_no_datetime) = $_ =~ /\S+\s\S+(.+)/;
		$int_id = '0' if (!defined($int_id));	
		$prepared_insert_query_message->execute($created_date . " " . $created_time, $internal_id, $int_id, $str_no_datetime, 0);
	} elsif ($flag eq '=>' or $flag eq '->' or $flag eq '**' or $flag eq '==') {
		($created_date, $created_time, $internal_id, $flag, $address_receiver, $misc) = $_ =~ /(\S+)\s(\S+)\s(\S+)\s(\S+)\s(\S+)\s(.+)/;
		($str_no_datetime) = $_ =~ /\S+\s\S+(.+)/;
		$prepared_insert_query_log->execute($created_date . " " . $created_time, $internal_id, $str_no_datetime, $address_receiver);
	} elsif ($flag eq 'Completed') {
		($created_date, $created_time, $internal_id, $flag) = $_ =~ /(\S+)\s(\S+)\s(\S+)\s(\S+)/;
		($str_no_datetime) = $_ =~ /\S+\s\S+(.+)/;
		$prepared_insert_query_log->execute($created_date . " " . $created_time, $internal_id, $str_no_datetime, ''	);
	}
}

