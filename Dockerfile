FROM swift:latest

MAINTAINER Loic LE PENN <loic.lepenn@orange.com>

RUN apt-get upgrade

RUN apt-get update

RUN apt-get install libpq-dev -y

