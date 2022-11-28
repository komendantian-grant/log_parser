use warnings;
use strict;

use lib ".";
use DatabaseConnector;

my $dbh = DatabaseConnector::get_dbi_connection();

my $create_message_table = $dbh->prepare('
	CREATE TABLE IF NOT EXISTS message (
		created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
		id VARCHAR NOT NULL,
		int_id CHAR(16) NOT NULL,
		str VARCHAR NOT NULL,
		status BOOL,
		CONSTRAINT message_id_pk PRIMARY KEY(id)
	);
	CREATE INDEX IF NOT EXISTS message_created_idx ON message (created);
	CREATE INDEX IF NOT EXISTS message_int_id_idx ON message (int_id);
');

my $create_log_table = $dbh->prepare('
	CREATE TABLE IF NOT EXISTS log (
		created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
		int_id CHAR(16) NOT NULL,
		str VARCHAR,
		address VARCHAR
	);
	CREATE INDEX IF NOT EXISTS log_address_idx ON log USING hash (address);
');

my $clean_data = $dbh->prepare('
	DELETE FROM message;
	DELETE FROM log;
');

$create_message_table->execute();
$create_log_table->execute();


