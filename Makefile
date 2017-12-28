out := _build
ver=$(shell cat VERSION)

CFLAGS_COMMON := -Wall -I$(out) -DVERSION=\"$(ver)\"
CFLAGS := $(CFLAGS_COMMON) -D_GNU_SOURCE -DPIC -fPIC -D_REENTRANT
LDFLAGS := -ldl -lc

$(out)/installwatch: $(out)/installwatch.so installwatch
	sed 's/%%VERSION%%/$(ver)/' installwatch > $@
	chmod +x $@

$(out)/installwatch.so: $(out)/installwatch.o
	$(LD) -shared -o $@ $< $(LDFLAGS)

$(out)/installwatch.o: installwatch.c $(out)/localdecls.h
	$(COMPILE.c) $(OUTPUT_OPTION) $<

$(out)/localdecls.h: create-localdecls libctest.c libcfiletest.c
	@mkdir -p $(dir $@)
	cp $(filter %.c, $^) $(dir $@)
	cd $(out) && ../$<



test: $(out)/installwatch
	$(CC) $(CFLAGS_COMMON) $(LDFLAGS) -o $(out)/test-installwatch test-installwatch.c -DLIBDIR=\"$(out)\"
	$(out)/installwatch $(out)/test-installwatch
