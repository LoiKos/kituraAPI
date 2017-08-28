FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get update

RUN apt-get install libpq-dev -y

ENV DATABASE_DB=
ENV DATABASE_HOST=
ENV DATABASE_PASSWORD=
ENV DATABASE_PORT=
ENV DATABASE_USER=

