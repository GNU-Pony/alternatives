PREFIX = /usr
EXEC_PREFIX = $(PREFIX)
SBIN = /sbin
SBINDIR = $(EXEC_PREFIX)$(SBINDIR)
DATA = /share
DATADIR = $(PREFIX)$(DATA)
LICENSES = /licenses
LICENSEDIR = $(DATADIR)$(LICENSES)
SYSCONF = /etc
SYSCONFDIR = $(SYSCONF)
ALTERNATIVES = /alternatives
PROVIDERS = /alternatives.providers
PKGNAME = alternatives
COMMAND = alternatives


.PHONY: all
all: alternatives


alternatives: alternatives.bash
	cp "$<" "$@"
	sed -i 's:/alternatives.providers:$(PROVIDERS):g' "$@"
	sed -i 's:/alternatives:$(ALTERNATIVES):g' "$@"
	sed -i 's:/etc:$(SYSCONFDIR):g' "$@"


.PHONY: install
install: alternatives
	install -Dm755 -- alternatives "$(DESTDIR)$(SBINDIR)/$(COMMAND)"
	install -Dm644 -- COPYING LICENSE "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: uninstall
uninstall:
	-rm "$(DESTDIR)$(SBINDIR)/$(COMMAND)"
	-rm "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm  "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rm -d "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: clean
clean:
	-rm alternatives

