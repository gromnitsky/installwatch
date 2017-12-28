out := _build
cache := $(out)/.cache
ver=$(shell cat VERSION)

CFLAGS_COMMON := -Wall -I$(cache) -DVERSION=\"$(ver)\"
CFLAGS := $(CFLAGS_COMMON) -D_GNU_SOURCE -DPIC -fPIC -D_REENTRANT
LDFLAGS := -ldl -lc

$(out)/installwatch: $(out)/installwatch.so installwatch
	sed 's/%%VERSION%%/$(ver)/' installwatch > $@
	chmod +x $@

$(out)/installwatch.so: $(cache)/installwatch.o
	$(LD) -shared -o $@ $< $(LDFLAGS)

$(cache)/installwatch.o: installwatch.c $(cache)/localdecls.h
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(cache)/localdecls.h: create-localdecls libctest.c libcfiletest.c
	@mkdir -p $(dir $@)
	cp $(filter %.c, $^) $(dir $@)
	cd $(dir $@) && ../../$<



test: $(out)/installwatch
	$(CC) $(CFLAGS_COMMON) $(LDFLAGS) -o $(cache)/test-installwatch test-installwatch.c -DLIBDIR=\"$(out)\"
	$(out)/installwatch $(cache)/test-installwatch
