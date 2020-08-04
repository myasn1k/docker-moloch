FROM ubuntu:18.04

# Install dependencies that are needed, but not set in the moloch.deb file
RUN apt-get -qq update && \
    apt-get install -yq curl libmagic-dev wget logrotate

# Declare args
ARG MOLOCH_VERSION=2.3.2
ARG UBUNTU_VERSION=18.04
ARG MOLOCH_DEB_PACKAGE="moloch_"$MOLOCH_VERSION"-1_amd64.deb"
ARG ES_HOST=elasticsearch
ARG ES_PORT=9200
ARG MOLOCH_INTERFACE=eth0
ARG MOLOCH_PASSWORD=changeme

# Declare envs vars for each arg
ENV MOLOCH_VERSION $MOLOCH_VERSION
ENV ES_HOST $ES_HOST
ENV ES_PORT $ES_PORT
ENV MOLOCH_LOCALELASTICSEARCH no
ENV MOLOCH_ELASTICSEARCH "http://"$ES_HOST":"$ES_PORT
ENV MOLOCH_INTERFACE $MOLOCH_INTERFACE
ENV MOLOCH_PASSWORD $MOLOCH_PASSWORD
ENV MOLOCH_ADMIN_PASSWORD $MOLOCH_PASSWORD
ENV MOLOCH_HOSTNAME "moloch"
ENV MOLOCHDIR "/data/moloch"
ENV CAPTURE "on"
ENV VIEWER "on"

# Install Moloch
RUN mkdir -p /data && \
    cd /data && \
    curl -C - -O "https://files.molo.ch/builds/ubuntu-"$UBUNTU_VERSION"/"$MOLOCH_DEB_PACKAGE && \
    dpkg -i $MOLOCH_DEB_PACKAGE || true && \
    apt-get install -yqf && \
    mv $MOLOCHDIR/etc /data/config && \
    ln -s /data/config $MOLOCHDIR/etc && \
    ln -s /data/logs $MOLOCHDIR/logs && \
    ln -s /data/pcap $MOLOCHDIR/raw
# clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* && \
    rm /data/$MOLOCH_DEB_PACKAGE

# add scripts
ADD /scripts /data/
RUN chmod 755 /data/*.sh

VOLUME ["/data/pcap", "/data/config", "/data/logs"]
EXPOSE 8005
WORKDIR $MOLOCHDIR

ENTRYPOINT ["/data/startmoloch.sh"]
