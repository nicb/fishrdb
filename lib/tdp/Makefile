#
# $Id: Makefile 369 2009-04-17 03:40:30Z nicb $
#
SUBDIRS=tape

all:
		for i in $(SUBDIRS);\
		do\
			$(MAKE) -C $$i -$(MAKEFLAGS);\
		done

clean:
		for i in $(SUBDIRS);\
		do\
			$(MAKE) -C $$i -$(MAKEFLAGS) $@;\
		done

.PHONY: all
