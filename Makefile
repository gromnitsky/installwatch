out := _build
cache := $(out)/.cache
src := src
ver=$(shell cat VERSION)

CFLAGS_COMMON := -Wall -I$(cache) -DVERSION=\"$(ver)\"
CFLAGS := $(CFLAGS_COMMON) -D_GNU_SOURCE -DPIC -fPIC -D_REENTRANT
LDFLAGS := -ldl -lc

$(out)/installwatch: $(src)/installwatch $(out)/installwatch.so
	sed 's/%%VERSION%%/$(ver)/' $< > $@
	chmod +x $@

$(out)/installwatch.so: $(cache)/installwatch.o
	$(LD) -shared -o $@ $< $(LDFLAGS)

$(cache)/installwatch.o: $(src)/installwatch.c $(cache)/localdecls.h
	$(COMPILE.c) $(OUTPUT_OPTION) $<

bootstrap := $(addprefix $(src)/, create-localdecls libctest.c libcfiletest.c)
$(cache)/localdecls.h: $(bootstrap)
	@mkdir -p $(dir $@)
	cp $(filter %.c, $^) $(dir $@)
	cd $(dir $@) && ../../src/create-localdecls



.PHONY: test
test: $(out)/installwatch
	$(CC) $(CFLAGS_COMMON) $(LDFLAGS) -o $(cache)/test-installwatch test/test-installwatch.c -DLIBDIR=\"$(out)\"
	$(out)/installwatch $(cache)/test-installwatch
