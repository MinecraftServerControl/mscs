Minecraft Server Control Script
=============================

A powerful command-line control script for UNIX and Linux powered Minecraft servers.


# Index
* [Features](#features)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [First-time Usage](#first-time-usage)
* [Server Customization](#server-customization)
* [License](LICENSE)
* [Issues](#issues)


## Features
* Run multiple Minecraft worlds.
* Start, stop, and restart single or multiple worlds.
* Create, delete, disable, and enable worlds.
* Includes support for additional server types: [Forge](http://www.minecraftforge.net/), [BungeeCord](http://www.spigotmc.org/wiki/bungeecord/), [SpigotMC](http://www.spigotmc.org/wiki/spigot/), etc.
* Users automatically notified of important server events.
* Uses the Minecraft [Query protocol](http:b //wiki.vg/Query) to keep track of current server conditions.
* LSB and systemd compatible init script, allows for seamless integration with your server's startup and shutdown sequences.
* Map worlds using the [Minecraft Overviewer](http://overviewer.org/) mapping software.
* Backup worlds, and remove backups older than X days.
* Update the server and client software automatically.
* Send commands to a world server from the command line.

See the [Usage](#usage) section below for a description on how to use these features.


## Prerequisites
Ensure that you have done the following before installing MSCS:

### Required Programs
We've made an attempt to utilize only features that are normally installed in
most Linux and UNIX environments in this script. However, there may be a few
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
    
### Configuring the Firewall / NAT
If you have a firewall installed on your computer, or a router using NAT
installed in your network, you will need to route some ports to your server.
Instructions on how to accomplish this are beyond the scope of this post, but
here are some things you will need to know:
* The default port for the Minecraft server is: `25565`.
* If you wish to run multiple world servers using this script, you will
  want to open a range of ports (for example `25565 - 25575`).

See the [iptables.rules](iptables.rules)
file for a very basic set of rules that you can use with the Iptables firewall.

### Mapping Software (Optional)
The script uses the [Minecraft Overviewer](http://overviewer.org) mapping
software to generate maps of your worlds.  Minecraft Overviewer is a
command-line tool for rendering high-resolution maps of Minecraft worlds. It
generates a set of static html and image files and uses the Google Maps API to
display a nice interactive map.

If you wish to use the mapping software, you can [download](http://overviewer.org/downloads) premade binaries for
supported systems, or build your own binary from source if needed.

Repositories for automatic installation are also available:
* [Debian/Ubuntu](http://overviewer.org/debian/info)
* [RHEL/CentOS/Fedora](http://overviewer.org/rpms/info)

## Installation
### Downloading the script
The easiest way to download the script is to make a clone of the [git
repository](https://github.com/sandain/MinecraftServerControlScript.git). You must have git installed first. To install git:

        sudo apt-get install git
        
Then:

        git clone https://github.com/sandain/MinecraftServerControlScript.git
        
Note that it will be downloaded into the current directory which you are working in. 

##### Other ways to download

* Get the latest stable [release](https://github.com/sandain/MinecraftServerControlScript/releases).

* Get the development version as a [zip file](https://github.com/sandain/MinecraftServerControlScript/archive/master.zip):

        wget https://github.com/sandain/MinecraftServerControlScript/archive/master.zip



### Configuration

Navigate to the `MinecraftServerControlScript` directory that you just downloaded. Configuration can be done with the included Makefile in Debian and
Ubuntu like environments by running:

        sudo make install
Then, type
        chmod -R u+w /opt/mscs
        chown -R minecraft:minecraft /opt/mscs
This will give the user you created in the config (by default, the user `minecraft`) access to write in the `/opt/mscs` folder. If you configured MSCS manually when you installed the script, then replace `minecraft` with the name of the user you made.

That's it!
If you wish to configure the script manually, please visit the [wiki page](https://github.com/Roflicide/MinecraftServerControlScript/wiki/Manual-Configuration).


## First-time Usage
So you successfully installed the script--great! 
There are a few important locations that you should know when using MinecraftServerControlScript:

* `/usr/local/bin` -- This contains the `MSCS` and `MSCTL` scripts used to power MinecraftServerControlScript. When modifying the script, you're going to want to modify one of these files (more in the adjusting options section).
* `/opt/mscs/worlds` -- All of your worlds are stored in here. 

From here, you probably want to [create a new world](#create-new-world) or [import an existing world](#import-existing-world) into the script. Then, you should adjust the [amount of RAM and other settings for the server](#adjusting-server-options).

### Create new world
The command to create a new world is:

        mscs create [world] [port] <ip>
  
Where `world` is the name of the world you specify, and `port` is the server port (by default, use 25565).
`ip` is optional and will be used if you wish to create multiple worlds across different servers. For now, leave it blank.

Afterwards, simply start the server via `mscs start [world]` where `world` is the name of the world. 

**Finally, accept the EULA**.
As of Minecraft version 1.7.10, Mojang requires that users of their software read and agree to their [EULA](https://account.mojang.com/documents/minecraft_eula).  After the first time you start the server, you need to modify the `eula.txt` file in your world's folder, changing the value of the `eula` variable from `false` to `true`.

The EULA can be found in `/opt/mscs/worlds/myWorld` where `myWorld` is the name given to the world you created.

After accepting the EULA simply start the server using the same command above, and you're all set!

### Import existing world
Suppose you want to import a world folder named `world` into MSCS, and that you want MSCS to recognize this world by the name "vanillaMC".
1. First, if you don't have one already, create a `worlds` folder in /opt/mscs/.

2. Create a new folder **within the `/opt/mscs/worlds/` directory that is the name you want MSCS to recongize for the
world.**. For this example, I chose "vanillaMC". So for instance, I created a new directory `vanillaMC` within the `/opt/mscs/worlds` directory, so the path would be `/opt/mscs/worlds/vanillaMC`. 

3. Drag the folder of the world you wish to move into the folder you just created. So I would drag the world `world` into the `vanillaMC` folder. The path of `world` (the actual world folder) would now be `/opt/mscs/worlds/vanillaMC/myWorld/`.

The finished file structure should be as follows with a world named `world` and a containing folder name "vanillaMC":
````
/opt/mscs/vanillaMC       // The path

world                     // The actual world folder
server.properties
banned-ips.json
ops.json
eula.text
whitelist.json
and more files...
````
Again, the most important thing to note here is that your actual world folder is within a containing folder that is inside of the `worlds/` subdirectory. The name of the containing folder of `world` is the name which you will use within MSCS commands to manipulate that world--so in this case, when referring to the world above you will use the name `vanillaMC`, not the actual name of the world folder--`world`.

After you've set up the file structure, you now need to create a world entry into MSCS. Do this via:

        mscs create [world] [port] <ip>
  
Where `world` is the **name of the containing folder you created** (so it would be "vanillaMC" from the previous example", and `port` is the server port (by default, use 25565).
`ip` is optional and will be used if you wish to create multiple worlds across different servers. For now, leave it blank.

Afterwards, simply start the server via `mscs start [world]` where `world` is the name of the containing world's folder (again, it would be "vanillaMC" from the last example).

**Finally, accept the EULA**.
As of Minecraft version 1.7.10, Mojang requires that users of their software read and agree to their [EULA](https://account.mojang.com/documents/minecraft_eula).  After the first time you start the server, you need to modify the `eula.txt` file in your world's folder, changing the value of the `eula` variable from `false` to `true`.
The EULA can be found in `/opt/mscs/worlds/vanillaMC` where `vanillaMC` is the name you gave to to the world you imported.

After accepting the EULA simply start the server using the same command above, and you're all set!

## Adjusting server options
There are two ways of adjusting the options through MSCS: changing values in the mscs.properties file and/or editing the msctl file directly.

### The mscs.properties file
The `mscs.properties` file can be found in every world folder (for instance, if you had a world called `myWorld`, the path would be `/opt/mscs/worlds/myWorld/mscs.properties`).

By default, the file only has one line in it: `mscs-enabled=true`. You can add a variety of flags to this file and set them as true/false to your liking.

The following flags are available:
* mscs-enabled - Enable or disable the world server.
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
### The msctl file


## Scheduling Backups

#### EULA
As of Minecraft version 1.7.10, Mojang requires that users of their software read and agree to their [EULA](https://account.mojang.com/documents/minecraft_eula).  After you have read through the document, you need to modify the `eula.txt` file in your world's folder, changing the value of the `eula` variable from `false` to `true`.

    #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
    eula=true


## Usage

### Permissions
All commands below assume that you are running them as either the `minecraft`
user or as `root` (through sudo).

Note: If the script is run as the `root` user, all important server processes
will be started using the `minecraft` user instead for security purposes.

    sudo mscs [option]

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

    sudo mscs start

To create a world named alpha, issue the command:

    sudo mscs create alpha 25565

To start just the world named alpha, issue the command:

    sudo mscs start alpha

To send a command to a world server, issue the command:

    sudo mscs send [world] [command]

ie.

    sudo mscs send alpha say Hello world!


### Import Existing Worlds

You just need to create a new directory in the worlds folder for the world you wish to import.
Suppose the world you wish to import is called `alpha`, you would create a new folder in
`/opt/mscs/worlds`, then copy the data files over to that directory.

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

    mkdir /opt/mscs/worlds/alpha
    cp -R * /opt/mscs/worlds/alpha

Make sure you check `server-port` and `query.port` in `server.properties` to make sure it does not overlap with other servers created by the MSCS script. Also ensure that `enable-query` is set to `true`.  If you do not have `enable-query` and a `query.port` set, you will not be able to check the status of the world with the script.


## Server Customization

The default values in the script can be overwritten by modifying the
`/etc/default/mscs` file.

For example, to modify the default MAPS_URL variable, add the following line
to the file:

    MAPS_URL="http://server.com/minecraft/maps"

The server settings for each world can be customized by adding certain
key/value pairs to the world's `mscs.properties` file.




### Additional documentation

More examples and documentation on server customization can be found on the [wiki](https://github.com/sandain/MinecraftServerControlScript/wiki/Server-Customization-Examples) page.

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
