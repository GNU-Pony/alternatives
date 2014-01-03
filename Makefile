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
INFO = /info
INFODIR = $(DATADIR)$(INFO)
ALTERNATIVES = /alternatives
PROVIDERS = /alternatives.providers
PKGNAME = alternatives
COMMAND = alternatives


.PHONY: all
all: alternatives

.PHONY: doc
doc: info

.PHONY: info
info: alternatives.info

%.texinfo.install: %.texinfo
	cp "$<" "$@"
	sed -i 's:/alternatives\.providers:$(PROVIDERS):g' "$@"
	sed -i 's:/alternatives:$(ALTERNATIVES):g' "$@"
	sed -i 's:/$(shell echo "$(ALTERNATIVES)" | sed -e 's:\.:\\\.:g')\.:/alternatives\.:g' "$@"
	sed -i 's:/etc:$(SYSCONFDIR):g' "$@"

%.info: info/%.texinfo.install
	makeinfo "$<"

.PHONY: pdf
pdf: alternatives.pdf
%.pdf: info/%.texinfo
	texi2pdf "$<"


alternatives: alternatives.bash
	cp "$<" "$@"
	sed -i 's:/alternatives\.providers:$(PROVIDERS):g' "$@"
	sed -i 's:/alternatives:$(ALTERNATIVES):g' "$@"
	sed -i 's:/$(shell echo "$(ALTERNATIVES)" | sed -e 's:\.:\\\.:g')\.:/alternatives\.:g' "$@"
	sed -i 's:/etc:$(SYSCONFDIR):g' "$@"


.PHONY: install
install: alternatives alternatives.info
	install -Dm755 -- alternatives "$(DESTDIR)$(SBINDIR)/$(COMMAND)"
	install -Dm644 -- alternatives.info "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	install -Dm644 -- COPYING LICENSE "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: uninstall
uninstall:
	-rm "$(DESTDIR)$(SBINDIR)/$(COMMAND)"
	-rm "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm  "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rm -d "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: clean
clean:
	-rm alternatives {*,*/*}.{aux,cp,fn,info,ky,log,pdf,ps,dvi,pg,toc,tp,vr,gz}

