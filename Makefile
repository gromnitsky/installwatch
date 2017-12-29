out := _build
cache := $(out)/.cache
src := src
ver=$(shell cat VERSION)

mk.dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
mkdir = @mkdir -p $(dir $@)

CFLAGS := -Wall -I$(cache) -DVERSION=\"$(ver)\"
LDFLAGS := -ldl -lc

# cancel built-ins
%: %.c
%.o: %.c

all: $(addprefix $(out)/, installwatch installwatch.so)

$(out)/installwatch: $(src)/installwatch
	$(mkdir)
	sed 's/%%VERSION%%/$(ver)/' $< > $@
	chmod +x $@

$(out)/installwatch.so: $(cache)/installwatch.o
	$(LD) -shared -o $@ $< $(LDFLAGS)

$(cache)/installwatch.o: CFLAGS += -D_GNU_SOURCE -DPIC -fPIC -D_REENTRANT
$(cache)/installwatch.o: $(src)/installwatch.c $(cache)/localdecls.h
	$(COMPILE.c) $(OUTPUT_OPTION) $<

bootstrap := $(addprefix $(src)/, create-localdecls libctest.c libcfiletest.c)
$(cache)/localdecls.h: $(bootstrap)
	$(mkdir)
	cp $(filter %.c, $^) $(dir $@)
	cd $(dir $@) && $(mk.dir)/src/create-localdecls



.PHONY: test
test: $(out)/installwatch
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(cache)/test-installwatch test/test-installwatch.c -DLIBDIR=\"$(out)\"
	$(out)/installwatch $(cache)/test-installwatch
