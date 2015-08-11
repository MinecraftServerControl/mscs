MSCS_USER := minecraft
MSCS_HOME := /opt/mscs

MSCTL := /usr/local/bin/msctl
MSCS := /usr/local/bin/mscs
MSCS_SERVICE := /lib/systemd/system/mscs.service
MSCS_COMPLETION := /etc/bash_completion.d/mscs

.PHONY: install update clean

install: update
	adduser --system --group --home $(MSCS_HOME) --quiet $(MSCS_USER)
	if which systemctl; then \
		systemctl -f enable mscs.service; \
	fi

update:
	install -m 0755 msctl $(MSCTL)
	install -m 0755 mscs $(MSCS)
	install -m 0644 mscs.completion $(MSCS_COMPLETION)
	if which systemctl; then \
		install -m 0644 mscs.service $(MSCS_SERVICE); \
	fi

clean:
	if which systemctl; then \
		systemctl -f disable mscs.service; \
		rm -f $(MSCS_SERVICE); \
	fi
	rm -f $(MSCTL) $(MSCS) $(MSCS_SERVICE) $(MSCS_COMPLETION)
