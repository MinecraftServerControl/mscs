Minecraft Server Control Script
=============================

A powerful command-line control script for UNIX and Linux powered Minecraft servers.


## Index
* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [Server Customization](#server-customization)
* [License](LICENSE)
* [Issues](#issues)


## Features
* Run multiple Minecraft worlds.
* Start, stop, and restart single or multiple worlds.
* Create, delete, disable, and enable worlds.
* Supports [CraftBukkit](http://bukkit.org/) in addition to the standard Mojang server distribution.
* Users automatically notified of important server events.
* Uses the Minecraft [Query protocol](http://wiki.vg/Query) to keep track of current server conditions.
* LSB-compatible init script, allows for seamless integration with your server's startup and shutdown sequences.
* Map worlds using the [Minecraft Overviewer](http://overviewer.org/) mapping software.
* Backup worlds, and remove backups older than X days.
* Update the server and client software automatically.
* Send commands to a world server from the command line.

See the [Usage](#usage) section below for a description on how to use these features.


## Installation

### Download
You can download the script from the following locations:

* Get a [zip file](https://github.com/sandain/MinecraftServerControlScript/archive/master.zip):

        wget https://github.com/sandain/MinecraftServerControlScript/archive/master.zip

* Make a clone of the [git repository](https://github.com/sandain/MinecraftServerControlScript.git):

        git clone https://github.com/sandain/MinecraftServerControlScript.git

### Configuration
To get your server to run the script on startup, and cleanly down the server
on shutdown, the `minecraft_server` script must be copied to `/etc/init.d`,
have its execute permissions set, and the system must be instructed to use
the script on startup and shutdown.  For Bash programmable completion
support, the `mscs_completion` script must be copied to
`/etc/bash_completion.d`.  For security reasons, the script uses a user
account named `minecraft` rather than `root` and the account must be created
before the script is used.

This can all be done automatically with the included Makefile in Debian and
Ubuntu like environments by running:

    sudo make install

It can also be accomplished manually with the following commands:

    sudo cp minecraft_server /etc/init.d/minecraft_server
    sudo cp mscs_completion /etc/bash_completion.d/mscs_completion
    sudo chmod 755 /etc/init.d/minecraft_server
    sudo update-rc.d minecraft_server defaults
    sudo adduser minecraft

The Minecraft server software will be automatically downloaded to the
following location on the first run:

    /home/minecraft/minecraft_server/

### EULA
As of Minecraft version 1.7.10, Mojang requires that users of their software read and agree to their [EULA](https://account.mojang.com/documents/minecraft_eula).  After you have read through the document, you need to modify the `eula.txt` file in your world's folder, changing the value of the `eula` variable from `false` to `true`.

    #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
    eula=true

### Requirements
We've made an attempt to utilize only features that are normally installed in
most Linux and UNIX environments in this script, but there are a few
requirements that this script has that may not already be in place:
* Java JRE     - The Minecraft server software requires this.
* Perl         - Most, if not all, Unix and Linux like systems have this
                 preinstalled.
* Python       - Required by the Minecraft Overviewer mapping software.
* GNU Wget     - Allows the script to download software updates via the
                 internet.
* rdiff-backup - Allows the script to efficiently run backups.
* Socat        - Allows the script to communicate with the Minecraft server.
* Iptables     - Although not explicitly required, a good firewall should be
                 installed.

If you are running Debian or Ubuntu, you can make sure that these are
installed by running:

    sudo apt-get install default-jre perl python wget rdiff-backup socat iptables

### Mapping Software
The script uses the [Minecraft Overviewer](http://overviewer.org) mapping
software to generate maps of your worlds.  Minecraft Overviewer is a
command-line tool for rendering high-resolution maps of Minecraft worlds. It
generates a set of static html and image files and uses the Google Maps API to
display a nice interactive map.

You can [download](http://overviewer.org/downloads) premade binaries for
supported systems, or build your own binary from source if needed.

Repositories for automatic installation are also available:
* [Debian/Ubuntu](http://overviewer.org/debian/info)
* [RHEL/CentOS/Fedora](http://overviewer.org/rpms/info)

### Firewall / NAT
If you have a firewall installed on your computer, or a router using NAT
installed in your network, you will need to route some ports to your server.
Instructions on how to accomplish this are beyond the scope of this post, but
here are some things you will need to know:
* The default port for the Minecraft server is: `25565`.
* If you wish to run multiple world servers using this script, you will
  want to open a range of ports (for example `25565 - 25575`).

See the [iptables.rules](iptables.rules)
file for a very basic set of rules that you can use with the Iptables firewall.


## Usage

### Permissions
All commands below assume that you are running them as either the `minecraft`
user or as `root` (through sudo).

Note: If the script is run as the `root` user, all important server processes
will be started using the `minecraft` user instead for security purposes.

    su minecraft
    /etc/init.d/minecraft_server [option]

or

    sudo /etc/init.d/minecraft_server [option]

### Options
* start [world]

    Start the Minecraft world server.  Start all worlds by default.

* stop [world]

    Stop the Minecraft world server.  Stop all worlds by default.

* force-stop [world]

    Forcibly stop the Minecraft world server.  Forcibly stop all worlds by
    default.

* restart [world]

    Restart the Minecraft world server.  Restart all worlds by default.

* force-restart [world]

    Forcibly restart the Minecraft world server.  Forcibly restart all
    worlds by default.

* create [world] [port] [ip]

    Create a Minecraft world server.  The world name and port must be
    provided, the IP address is usually blank.

* delete [world]

    Delete a Minecraft world server.

* disable [world]

    Temporarily disable a world server.

* enable [world]

    Enable a disabled world server.

* list [option]

    Display a list of worlds.
    Options:

    * enabled

        Display a list of enabled worlds, default.

    * disabled

        Display a list of disabled worlds.

    * running

        Display a list of running worlds.

    * stopped

        Display a list of stopped worlds.

* status [world]

    Display the status of the Minecraft world server.  Display the
    status of all worlds by default.

* broadcast [command]

    Broadcast a command to all running Minecraft world servers.

* send [world] [command]

    Send a command to a Minecraft world server.

* logrotate [world]

    Rotate the server.log file.  Rotate the server.log file for all
    worlds by default.

* backup [world]

    Backup the Minecraft world.  Backup all worlds by default.

* list-backups [world]

    List the datetime of the backups for the world.

* restore-backup [world] [datetime]

    Restore a backup for a world that was taken at the datetime.

* console [world]

    Connect to the Minecraft world server's console.  Hit [Ctrl-D] to detach.

* watch [world]

    Watch the log file for the Minecraft world server.

* map [world]

    Run the Minecraft Overviewer mapping software on the Minecraft world.
    Map all worlds by default.

* update

    Update the client and server software packages.

### Examples

To start all of the world servers, issue the command:

    /etc/init.d/minecraft_server start

To create a world named alpha, issue the command:

    /etc/init.d/minecraft_server create alpha 25565

To start just the world named alpha, issue the command:

    /etc/init.d/minecraft_server start alpha

To send a command to a world server, issue the command:

    /etc/init.d/minecraft_server send [world] [command]

ie.

    /etc/init.d/minecraft_server send alpha say Hello world!


### Import Existing Worlds

You just need to create a new directory in the worlds folder for the world you wish to import.
Suppose the world you wish to import is called `alpha`, you would create a new folder in
`/home/minecraft/worlds`, then copy the data files over to that directory.

If the directory containing the world `alpha` you wish to import looks like this:

    $ ls
    alpha
    banned-ips.txt
    banned-players.txt
    crash-reports
    logs
    ops.txt
    server.properties
    white-list.txt

You can just copy your world into the worlds directory:

    mkdir /home/minecraft/worlds/alpha
    cp -R * /home/minecraft/worlds/alpha

Make sure you check `server-port` and `query.port` in `server.properties` to make sure it does not overlap with other servers created by the MSCS script. Also ensure that `enable-query` is set to `true`.  If you do not have `enable-query` and a `query.port` set, you will not be able to check the status of the world with the script.


## Server Customization

The default values in the script can be overwritten by modifying the
`/etc/default/minecraft_server` file.

For example, to modify the default MAPS_URL variable, add the following line
to the file:

    MAPS_URL="http://server.com/minecraft/maps"

The server settings for each world can be customized by adding certain
key/value pairs to the world's `server.properties` file.

The following keys are available:
* mscs-version-type - Assign the version type (release or snapshot).
* mscs-client-version - Assign the version of the client software.
* mscs-client-jar - Assign the .jar file for the client software.
* mscs-client-url - Assign the download URL for the client software.
* mscs-client-location - Assign the location of the client .jar file.
* mscs-server-version - Assign the version of the server software.
* mscs-server-jar - Assign the .jar file for the server software.
* mscs-server-url - Assign the download URL for the server software.
* mscs-server-args - Assign the arguments to the server.
* mscs-initial-memory - Assign the initial amount of memory for the server.
* mscs-maximum-memory - Assign the maximum amount of memory for the server.
* mscs-server-location - Assign the location of the server .jar file.
* mscs-server-command - Assign the command to run for the server.

The following variables may be used in some of the values of the above keys:
* $JAVA - The Java virtual machine.
* $CURRENT_VERSION - The current Mojang Minecraft release version.
* $CLIENT_VERSION - The version of the client software.
* $SERVER_VERSION - The version of the server software.
* $SERVER_JAR - The .jar file to run for the server.
* $SERVER_ARGS - The arguments to the server.
* $INITIAL_MEMORY - The initial amount of memory for the server.
* $MAXIMUM_MEMORY - The maximum amount of memory for the server.
* $SERVER_LOCATION - The location of the server .jar file.

### Example key/value pairs

Equivalent to the default values:

    mscs-version-type=release
    mscs-client-version=$CURRENT_VERSION
    mscs-client-jar=$CLIENT_VERSION.jar
    mscs-client-url=https://s3.amazonaws.com/Minecraft.Download/versions/$CLIENT_VERSION/$CLIENT_VERSION.jar
    mscs-client-location=/home/minecraft/.minecraft/versions/$CLIENT_VERSION
    mscs-server-version=$CURRENT_VERSION
    mscs-server-jar=minecraft_server.$SERVER_VERSION.jar
    mscs-server-url=https://s3.amazonaws.com/Minecraft.Download/versions/$SERVER_VERSION/minecraft_server.$SERVER_VERSION.jar
    mscs-server-args=nogui
    mscs-initial-memory=128M
    mscs-maximum-memory=2048M
    mscs-server-location=/home/minecraft/minecraft_server
    mscs-server-command=$JAVA -Xms$INITIAL_MEMORY -Xmx$MAXIMUM_MEMORY -jar $SERVER_LOCATION/$SERVER_JAR $SERVER_ARGS

Run a Minecraft version 1.6.4 server:

    mscs-client-version=1.6.4
    mscs-server-version=1.6.4

Use the latest CraftBukkit recommended build:

    mscs-server-jar=craftbukkit.jar
    mscs-server-url=http://dl.bukkit.org/latest-rb/craftbukkit.jar
    mscs-server-args=
    mscs-initial-memory=128M
    mscs-maximum-memory=2048M

Use the latest BungeeCord successful build:

    mscs-server-jar=BungeeCord.jar
    mscs-server-url=http://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar


## License

See [LICENSE](LICENSE)


## Issues

We have only tested this code in a Debian/Ubuntu environment, but there is no
reason that it shouldn't work in any appropriately configured UNIX-like
environment, including Apple Mac OSX and the other BSD variants, with only
minor modifications.  If you experience errors running this script, please
post a copy of the error message and a note detailing the operating
environment where the error occurs to the support thread, and we will try to
work out a solution with you.

Support thread:  http://www.minecraftforum.net/viewtopic.php?f=10&t=129833

Github Issues:  https://github.com/sandain/MinecraftServerControlScript/issues
