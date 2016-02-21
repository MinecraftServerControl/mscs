FROM debian:jessie
#This dockerfile setup the basic things need for mscs to run inside a docker container.


#Install pre requirements
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys AB6EAF871F4C1BCE \
	&& echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list.d/overviewer.list \
    && apt-get update \
	&& apt-get update && apt-get install -y default-jre perl python make wget rdiff-backup socat iptables minecraft-overviewer \
	&& rm -rf /var/lib/apt/lists/*

#Install Mscs
RUN mkdir -p /usr/src/mscs /opt/mscs/worlds /opt/mscs/maps /opt/mscs/backups
ADD . /usr/src/mscs
WORKDIR /usr/src/mscs
RUN make install
RUN chmod -R u+w /opt/mscs && chown -R minecraft:minecraft /opt/mscs
USER minecraft

#This container will assume there are a valid mscs world setup ready for it. This can be 
#done by -v <volume>:/opt/mscs at runtime.


#If you would like to also make a world inside of the container check the docker file in
# myWorld in this directory.



EXPOSE 25565

ENTRYPOINT ["mscs","-f"]
CMD ["start"]