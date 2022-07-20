all:
	./sock-puppet-pull.sh || ./sock-puppet-build.sh
	@echo Please run "make install"

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

install:
	@if [ ! -d "$(PREFIX)" ]; then echo Error: need a $(PREFIX) directory; exit 1; fi
	@mkdir -p $(BINDIR)
	cp sock-puppet-forward.sh $(BINDIR)/sock-puppet-forward
	cp sock-puppet-mount.sh $(BINDIR)/sock-puppet-mount
	cp sock-puppet-pull.sh $(BINDIR)/sock-puppet-pull
