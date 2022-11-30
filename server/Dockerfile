# syntax=docker/dockerfile:1
FROM perl:latest
WORKDIR /src
RUN cpan HTTP::Server::Simple::CGI
RUN cpan DBI
RUN cpan DBD::Pg
COPY . .
CMD ["perl", "/src/server.pl"]
#CMD ["/bin/bash"]