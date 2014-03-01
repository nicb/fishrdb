#
# $Id: Makefile 369 2009-04-17 03:40:30Z nicb $
#
SOURCES=tdp.racc tcp.racc tbp.racc
TARGETS=$(SOURCES:.racc=.tab.rb)
RACC=racc
RACC_DEBUG=#-g
RACCFLAGS=$(RACC_DEBUG) -v


all: 	$(TARGETS)

clean:
		$(RM) $(TARGETS) $(SOURCES:.racc=.output)

.SUFFIXES: .tab.rb .racc

%.tab.rb: 	%.racc
	$(RACC) $(RACCFLAGS) $<
