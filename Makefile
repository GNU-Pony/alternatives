# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


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
DOC = /doc
DOCDIR = $(DATADIR)$(DOC)
INFO = /info
INFODIR = $(DATADIR)$(INFO)
ALTERNATIVES = /alternatives
PROVIDERS = /alternatives.providers
PKGNAME = alternatives
COMMAND = alternatives


.PHONY: default
default: command info

.PHONY: all
all: command doc

.PHONY: doc
doc: info pdf dvi ps

.PHONY: command
command: alternatives

obj/%.texinfo: info/%.texinfo
	mkdir -p obj
	cp "$<" "$@"
	sed -i 's:/alternatives\.providers:$(PROVIDERS):g' "$@"
	sed -i 's:/alternatives:$(ALTERNATIVES):g' "$@"
	sed -i 's:/$(shell echo "$(ALTERNATIVES)" | sed -e 's:\.:\\\.:g')\.:/alternatives\.:g' "$@"
	sed -i 's:/etc:$(SYSCONFDIR):g' "$@"

obj/fdl.texinfo: info/fdl.texinfo
	mkdir -p obj
	cp "$<" "$@"

.PHONY: info
info: alternatives.info
%.info: obj/%.texinfo obj/fdl.texinfo
	makeinfo "$<"

.PHONY: pdf
pdf: alternatives.pdf
%.pdf: obj/%.texinfo obj/fdl.texinfo
	cd obj ; yes X | texi2pdf ../$<
	mv obj/$@ $@

.PHONY: dvi
dvi: alternatives.dvi
%.dvi: obj/%.texinfo obj/fdl.texinfo
	cd obj ; yes X | $(TEXI2DVI) ../$<
	mv obj/$@ $@

.PHONY: ps
ps: alternatives.ps
%.ps: obj/%.texinfo obj/fdl.texinfo
	cd obj ; yes X | texi2pdf --ps ../$<
	mv obj/$@ $@


alternatives: alternatives.bash
	cp "$<" "$@"
	sed -i 's:/alternatives\.providers:$(PROVIDERS):g' "$@"
	sed -i 's:/alternatives:$(ALTERNATIVES):g' "$@"
	sed -i 's:/$(shell echo "$(ALTERNATIVES)" | sed -e 's:\.:\\\.:g')\.:/alternatives\.:g' "$@"
	sed -i 's:/etc:$(SYSCONFDIR):g' "$@"


.PHONY: install
install: install-base install-info

.PHONY: install-all
install-all: install-base install-doc

.PHONY: install-base
install-base: install-command install-license

.PHONY: install-command
install-command: alternatives
	install -Dm755 -- "$<" "$(DESTDIR)$(SBINDIR)/$(COMMAND)"

.PHONY: install-license
install-license:
	install -Dm644 -- COPYING LICENSE "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"

.PHONY: install-doc
install-doc: install-info install-pdf install-dvi install-ps

.PHONY: install-info
install-info: alternatives.info
	install -Dm644 -- "$<" "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"

.PHONY: install-pdf
install-pdf: alternatives.pdf
	install -Dm644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"

.PHONY: install-dvi
install-dvi: alternatives.dvi
	install -Dm644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"

.PHONY: install-ps
install-ps: alternatives.ps
	install -Dm644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"


.PHONY: uninstall
uninstall:
	-rm "$(DESTDIR)$(SBINDIR)/$(COMMAND)"
	-rm "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"
	-rm "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"
	-rm "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"
	-rm "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm  "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rm -d "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: clean
clean:
	-rm -r alternatives obj *.{info,pdf,ps,dvi}

