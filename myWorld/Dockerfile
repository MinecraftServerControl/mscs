FROM egut/mscs
#This is an example container that setup a example world. 

#Variables that you should override in docker container that depend on this container.
ENV WORLD=myWorld

#To enable the world you need to change the following line to ENV EULA=ture
#This also implicate that you accept Mojang's EULA.
ENV EULA=false

# This will create a world for you and use the parent start command to also start it. 
RUN mscs create $WORLD 25565
RUN echo "eula=$EULA" > /opt/mscs/worlds/$WORLD/eula.txt

#Here you can add more environment options and adding files to your world.