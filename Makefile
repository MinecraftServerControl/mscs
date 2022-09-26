MSCS_USER := minecraft
MSCS_HOME := /opt/mscs

MSCTL := /usr/local/bin/msctl
MSCS := /usr/local/bin/mscs
MSCS_INIT_D := /etc/init.d/mscs
MSCS_SERVICE := /etc/systemd/system/mscs.service
MSCS_SERVICE_TEMPLATE := /etc/systemd/system/mscs@.service
MSCS_COMPLETION := /etc/bash_completion.d/mscs

UPDATE_D := $(wildcard update.d/*)

.PHONY: install adduser update clean

install: adduser update
	if which systemctl; then \
		systemctl -f enable mscs.service; \
	else \
		ln -s $(MSCS) $(MSCS_INIT_D); \
		update-rc.d mscs defaults; \
	fi 

adduser:
	useradd --system --user-group --create-home -K UMASK=0022 --home $(MSCS_HOME) $(MSCS_USER)

update:
	install -m 0755 msctl $(MSCTL)
	install -m 0755 mscs $(MSCS)
	install -m 0644 mscs.completion $(MSCS_COMPLETION)
	if which systemctl; then \
		install -m 0644 mscs.service $(MSCS_SERVICE); \
		install -m 0644 mscs@.service $(MSCS_SERVICE_TEMPLATE); \
	fi
	@for script in $(UPDATE_D); do \
		sh $$script; \
	done; true;
	ln -sf $(shell pwd) $(MSCS_HOME)/mscs_install_dir

clean:
	if which systemctl; then \
		systemctl -f disable mscs.service; \
		rm -f $(MSCS_SERVICE) $(MSCS_SERVICE_TEMPLATE); \
	else \
		update-rc.d mscs remove; \
		rm -f $(MSCS_INIT_D); \
	fi
	rm -f $(MSCTL) $(MSCS) $(MSCS_COMPLETION)
