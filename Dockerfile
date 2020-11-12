FROM ubuntu:20.04

RUN apt-get update
ENV TZ="UTC"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install libssl-dev zlib1g-dev carton make gcc cron inetutils-ping -y \
&& apt-get clean && rm -rf /var/lib/apt/lists
#RUN adduser --disabled-password --disabled-login --gecos "easyping user" --home /easyping/ easyping
#USER root
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
#http://manpages.ubuntu.com/manpages/groovy/man8/cron.8.html
#ENTRYPOINT ["cron", "-f"]
# > /proc/1/fd/1 2>/proc/1/fd/2
#https://lostindetails.com/articles/How-to-run-cron-inside-Docker

#/var/spool/cron/crontabs/easyping
#sudo docker run -it -v ~/Programming/easypingtest/data:/easyping/data -v ~/Programming/easypingtest/cron:/var/spool/cron/crontabs --name test easyping
