FROM java:8
#This dockerfile setup the basic things need for mscs to run inside a docker container.


#Install pre requirements
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys AB6EAF871F4C1BCE \
	&& echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list.d/overviewer.list \
    && apt-get update \
	&& apt-get update && apt-get install -y perl python make wget rdiff-backup socat iptables minecraft-overviewer \
	&& rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV gosu_version=1.7

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && apt-get update && apt-get install -y curl rsync tmux && rm -rf /var/lib/apt/lists/* \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$gosu_version/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$gosu_version/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

#Install Mscs
RUN mkdir -p /usr/src/mscs /opt/mscs/worlds /opt/mscs/maps /opt/mscs/backups
ADD . /usr/src/mscs
WORKDIR /usr/src/mscs
RUN make install

WORKDIR /opt/mscs

VOLUME ['/opt/mscs/worlds', '/opt/mscs/maps', '/opt/mscs/backups']

EXPOSE 25565

CMD mscs start $WORLD && sleep 3 && mscs watch $WORLD