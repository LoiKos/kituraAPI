FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get update

RUN apt-get install libpq-dev -y

ENV DATABASE_DB=mbaoDB
ENV DATABASE_HOST=database
ENV DATABASE_PASSWORD=3If6IPF6VgNIOGMvPbkPaDfBW94I9
ENV DATABASE_PORT=5432
ENV DATABASE_USER=Supervisor

