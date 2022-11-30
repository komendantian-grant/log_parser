# log_parser
Parse email message log and view logs via web server.

Perl requirements installation:
cpan DBI
cpan DBD::Pg

Create database tables:
perl populate_database.pl

Parse message log:
perl parser.pl

Lauch postgresql server:
docker-compose up log_postgresql

Launch web server:
docker-compose up server
