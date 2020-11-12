FROM ubuntu:20.04

RUN apt-get update
ENV TZ="UTC"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install libssl-dev zlib1g-dev carton make gcc inetutils-ping -y \
&& apt-get clean && rm -rf /var/lib/apt/lists
RUN adduser --disabled-password --disabled-login --gecos "easyping user" --home /easyping/ easyping

WORKDIR /easyping
COPY cpanfile cpanfile
RUN carton install
COPY lib lib
COPY easyping.pl easyping.pl
COPY easyping.sh easyping.sh
COPY easyping.cron.sh easyping.cron.sh
RUN chmod +x easyping.pl
RUN chmod +x easyping.sh
RUN chmod +x easyping.cron.sh
ENTRYPOINT ["/easyping/easyping.cron.sh"]