<p align="center">
  <img src="http://i.imgur.com/fUM7Ne8.png" />
</p>

# Index
* [Overview](#overview)
* [Prerequisites for installation](#prerequisites-for-installation)
  * [Required programs](#required-programs)
  * [Configuring the firewall / NAT](#configuring-the-firewall--nat)
  * [Mapping software (optional)](#mapping-software-optional)
* [Installation](#installation)
  * [Downloading the script](#downloading-the-script)
  * [Configuration](#configuration)
* [Getting started guide](#getting-started-guide)
  * [Create new world](#create-new-world)
  * [Import existing world](#import-existing-world)
  * [Adjusting world properties](#adjusting-world-properties)
  * [Enabling Forge, BungeeCord, and other server software](#enabling-forge-bungeecord-and-other-server-software
  * [Adjusting global server options](#adjusting-global-server-settings)
* [Automated backups and restarts](#automated-backups-and-restarts)
  * [Scheduling backups](#scheduling-backups)
  * [Removing backups after X days](#removing-backups-after-x-days)
  * [Scheduling restarts](#scheduling-restarts)
* [Mapping the world](#mapping-the-world)
* [Command reference](#command-reference)
  * [Examples](#examples)
* [License](LICENSE)
* [Issues](#issues)

## Overview
**M**inecraft **S**erver **C**ontrol **S**cript (**MSCS**) is a server-management script for UNIX and Linux powered Minecraft servers. 
Features include:

* Run multiple Minecraft worlds.
* Start, stop, and restart single or multiple worlds.
* Create, delete, disable, and enable worlds.
* Includes support for additional server types: [Forge](http://www.minecraftforge.net/), [BungeeCord](http://www.spigotmc.org/wiki/bungeecord/), [SpigotMC](http://www.spigotmc.org/wiki/spigot/), etc.
* Users automatically notified of important server events.
* LSB and systemd compatible init script, allows for seamless integration with your server's startup and shutdown sequences.
* Map worlds using the [Minecraft Overviewer](http://overviewer.org/) mapping software.
* Automatically backup worlds, remove backups older than X days, and restart worlds.
* Update the server and client software automatically.
* Send commands to a world server from the command line.

## Prerequisites for installation
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
    
### Configuring the firewall / NAT
If you have a firewall installed on your computer, or a router using NAT
installed in your network, you will need to route some ports to your server.
Instructions on how to accomplish this are beyond the scope of this post, but
here are some things you will need to know:
* The default port for the Minecraft server is: `25565`.
* If you wish to run multiple world servers using this script, you will
  want to open a range of ports (for example `25565 - 25575`).

See the [iptables.rules](iptables.rules)
file for a very basic set of rules that you can use with the Iptables firewall.

### Mapping software (optional)
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
If you wish to configure the script manually, please visit the [wiki page](https://github.com/sandain/MinecraftServerControlScript/wiki/Manual-Configuration).


## Getting started guide
So you successfully installed the script--great! 

At first, you probably want to [create a new world](#create-new-world) or [import an existing world](#import-existing-world) into the script. 

Then, you should adjust the [settings for the server](#adjusting-server-options) as needed.

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

1. First, if you don't have one already, create a `worlds` folder in `/opt/mscs/`.

2. Create a new folder **within the `/opt/mscs/worlds/` directory that is the name you want MSCS to use for the world**. For this example, I chose "vanillaMC". So, I created a new directory `vanillaMC` within the `/opt/mscs/worlds` directory, so the path would be `/opt/mscs/worlds/vanillaMC`. 

3. Drag the folder of the world you wish to move into the folder you just created. So I would drag the world `world` into the `vanillaMC` folder. The path of `world` (the actual world folder) would now be `/opt/mscs/worlds/vanillaMC/world/`.

The finished file structure should resemble the following, with a world named `world` and a containing folder name "vanillaMC":
````
/opt/mscs/vanillaMC       // The path

world                     // The actual world folder
server.properties         
other world files... (in no particular order)
````

After you've set up the file structure, you now need to create a world entry into MSCS. Do this via:

        mscs create [world] [port] <ip>
  
Where `world` is the **name of the containing folder you created** (so it would be "vanillaMC" from the previous example", and `port` is the server port (by default, use 25565).
`ip` is optional and will be used if you wish to create multiple worlds across different servers. For now, leave it blank.

Afterwards, simply start the server via `mscs start [world]` where `world` is the name of the containing world's folder (again, it would be "vanillaMC" from the last example). Then, accept the EULA, run the start command again, and you're good to go!

As a last note, make sure you check `server-port` and `query.port` in `server.properties` to make sure it does not overlap with other servers created by the MSCS script. Also ensure that `enable-query` is set to `true`.  If you do not have `enable-query` and a `query.port` set, you will not be able to check the status of the world with the script.

### Adjusting world properties
The `mscs.properties` file can be found in every world folder (for instance, if you had a world called `myWorld`, the path would be `/opt/mscs/worlds/myWorld/mscs.properties`). This file allows you to adjust many different properties for each world you have.

By default, the file only has one line in it: `mscs-enabled=true`. You can add a variety of flags to this file and set them as to a true/false boolean or a variable to your liking.

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

#### Example key/value pairs

    mscs-enabled=true
    mscs-version-type=release
    mscs-client-version=$CURRENT_VERSION
    mscs-client-jar=$CLIENT_VERSION.jar
    mscs-client-url=https://s3.amazonaws.com/Minecraft.Download/versions/$CLIENT_VERSION/$CLIENT_VERSION.jar
    mscs-client-location=/opt/mscs/client/$CLIENT_VERSION
    mscs-server-version=$CURRENT_VERSION
    mscs-server-jar=minecraft_server.$SERVER_VERSION.jar
    mscs-server-url=https://s3.amazonaws.com/Minecraft.Download/versions/$SERVER_VERSION/minecraft_server.$SERVER_VERSION.jar
    mscs-server-args=nogui
    mscs-initial-memory=128M
    mscs-maximum-memory=2048M
    mscs-server-location=/opt/mscs/server
    mscs-server-command=$JAVA -Xms$INITIAL_MEMORY -Xmx$MAXIMUM_MEMORY -jar $SERVER_LOCATION/$SERVER_JAR $SERVER_ARGS

### Enabling Forge, BungeeCord, and other server software
Please visit the [wiki](https://github.com/sandain/MinecraftServerControlScript/wiki/Server-Customization-Examples) for additional information.

### Adjusting global server settings
In tandem with the `mscs.properties` file--which handles options for individual worlds--is the `mscs.conf` or simply `mscs` file, which handles global server settings.

**You must create this file**. By default, MSCS looks for this file in three places (in this order):

1. `$HOME/**mscs.conf**` 

2. `$HOME/.config/mscs/**mscs.conf**`

3. `/etc/default/**mscs**`-- **if you save it in this location it is only called `mscs`, NOT `mscs.conf`**

It doesn't matter where you create the file, as long as you put it in one of the above places.

Please note: `$HOME` represents the home directory of the user that is responsible for the script--if you followed the configuration above, then that would be the `minecraft` user. To print the home directory of the `minecraft` user type:

`eval echo ~$minecraft`

Then simply `cd` into the directory it outputs and create the file.

Once you've created the file, you need to populate it with a list of properties. Copy/paste the list of properties, which can be found [here](https://github.com/sandain/MinecraftServerControlScript/wiki).

## Automated backups and restarts

### Scheduling backups
MSCS uses [**cron**](https://en.wikipedia.org/wiki/Cron), a scheduler software that can run programs on a set interval of time. Below is an example of one way how you could setup backups via cron to backup a world every 2 hours:

Type the following (in any directory): 

  ````
  export EDITOR=vim
  crontab -e
  ````
  Page down until you get to an empty line. Then paste the following:
  
  ````
  0 */2 * * *  /usr/local/bin/mscs backup myWorld
  ````
  * `0 */2 * * *` is the time interval to backup. This particular expression means backup every 2 hours. You can change this to 3, 4, 5 or whatever amount of hours to backup X amount of hours. You can also backup according to days, minutes, seconds, the time of the day, and more. See [the wiki page](https://github.com/sandain/MinecraftServerControlScript/wiki/Backup-and-Restore) for more information.
  * `myWorld` is the name of the world you wish to backup. Omitting this will backup all worlds.

  Finally, press escape, then type
  `:wq`
  to save and quit.
  
  The backups will be saved in `/opt/mscs/backups`. 
  
### Removing backups after X days
You can specify how long to keep backups by changing the `BACKUP_DURATION` in the `mscs.conf` or `mscs` file (see [adjusting global server settings](#adjusting-global-server-settings).

### Scheduling restarts
You can schedule restarts for the server following the same method as outlined in [scheduling backups](#scheduling-backups).   Simply change the scheduled command from `backup <myWorld>` to `restart <myWorld>`. `myWorld` is the name of world you wish to restart; omit if you wish to restart all worlds.

## Mapping the world
Minecraft Server Control Script uses [overviewer](http://docs.overviewer.org/en/latest/) to generate minecraft maps. First, follow the [instructions](http://docs.overviewer.org/en/latest/installing/) on their site to install overviewer. 

Then, once you have it installed, modify the settings (if necessary) found in the `mscs.conf` or `mscs` file (see [adjusting global server settings](#adjusting-global-server-settings):

 ````
 OVERVIEWER_BIN=$(which overviewer.py)
 OVERVIEWER_URL="http://overviewer.org"
 MAPS_URL="my.minecraftserver.com"
 MAPS_LOCATION="$LOCATION/maps"
 ````

After you've tinkered the settings to your liking, run
`mscs map <world>`
where `world` is the name of the world you would like to get mapped. Omit the world name to map all worlds.
By default maps are saved into `/opt/mscs/maps`.


## Command Reference

All commands below assume that you are running them as either the `minecraft`
user or as `root` (through sudo).

Note: If the script is run as the `root` user, all important server processes
will be started using the `minecraft` user instead for security purposes.

    sudo mscs [option]

````
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
````

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
