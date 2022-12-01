# log_parser
Parse email message log and view logs via web server.

Perl requirements installation:
cpan DBI
cpan DBD::Pg

Create database tables:
perl populate_database.pl

Parse message log:
perl parser.pl <log filename>

Lauch postgresql server:
docker-compose up log_postgresql

Launch web server:
docker-compose up server

Web server is launched at 127.0.0.1:8080