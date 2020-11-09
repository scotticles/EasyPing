FROM ubuntu:20.04

RUN apt-get update
ENV TZ="UTC"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install libdev-ssl zlib1g-dev carton make gcc cron\
&& apt-get clean && rm -rf /var/lib/apt/lists
RUN adduser --disabled-password --disabled-login --gecos "easyping user" --home /easyping/ easyping
USER easyping
WORKDIR /easyping
#COPY cpanfile cpanfile
RUN carton install
#http://manpages.ubuntu.com/manpages/groovy/man8/cron.8.html
ENTRYPOINT ["cron", "-f"]
