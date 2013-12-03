MINECRAFT_USER := minecraft
MINECRAFT_HOME := /home/$(MINECRAFT_USER)
MINECRAFT_SERVER := /etc/init.d/minecraft_server
BASH_COMPLETION := /etc/bash_completion.d/mscs_completion

.PHONY: install clean

install: $(MINECRAFT_HOME) $(MINECRAFT_SERVER) $(BASH_COMPLETION)

clean:
	update-rc.d -f minecraft_server remove
	rm -f $(MINECRAFT_SERVER) $(BASH_COMPLETION)

$(MINECRAFT_HOME):
	adduser --disabled-password --gecos ",,," --quiet $(MINECRAFT_USER)

$(MINECRAFT_SERVER): minecraft_server
	install -m 0755 minecraft_server $(MINECRAFT_SERVER)
	update-rc.d minecraft_server defaults

$(BASH_COMPLETION): mscs_completion
	install -m 0644 mscs_completion $(BASH_COMPLETION)

