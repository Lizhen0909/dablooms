HELPTEXT = "\
\n dablooms Makefile usage       \
\n                               \
\n  Options (current value)      \
\n                               \
\n    BLDDIR     ($(BLDDIR))     \
\n    DESTDIR    ($(DESTDIR))    \
\n    prefix     ($(prefix))     \
\n    libdir     ($(libdir))     \
\n    includedir ($(includedir)) \
\n                               \
\n    CC         ($(CC))         \
\n    CFLAGS     ($(ALL_CFLAGS)) \
\n    LDFLAGS    ($(ALL_LDFLAGS))\
\n    INSTALL    ($(INSTALL))    \
\n                               \
\n    PYTHON     ($(PYTHON))     \
\n    PY_MOD_DIR ($(PY_MOD_DIR)) \
\n                               \
\n  Targets                      \
\n                               \
\n    all        (c libdablooms) \
\n    install                    \
\n    test                       \
\n    clean                      \
\n    help                       \
\n                               \
\n    pydablooms                 \
\n    install_pydablooms         \
\n    test_pydablooms            \
\n\n"

prefix = /usr/local
libdir = $(prefix)/lib
includedir = $(prefix)/include
DESTDIR =
BLDDIR = build

ifdef USE_MEMORY_MAP
CFLAGS = -g -Wall -O2 -DUSE_MEMORY_MAP
else
CFLAGS = -g -Wall -O2
endif 
LDFLAGS = 
ALL_CFLAGS = -fPIC $(CFLAGS)
ALL_LDFLAGS = -lm $(LDFLAGS)

INSTALL = install
CC = gcc
AR = ar

### dynamic shared object ###

# shared-object version does not follow software release version
SO_VER_MAJOR = 1
SO_VER_MINOR = 1

SO_VER = $(SO_VER_MAJOR).$(SO_VER_MINOR)
SO_NAME = so
SO_CMD = -soname
SO_EXT_MAJOR = $(SO_NAME).$(SO_VER_MAJOR)
SO_EXT = $(SO_NAME).$(SO_VER)
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
	SO_NAME = dylib
	SO_CMD = -install_name
	SO_EXT_MAJOR = $(SO_VER_MAJOR).$(SO_NAME)
	SO_EXT = $(SO_VER).$(SO_NAME)
endif
SHARED_LDFLAGS = -shared -Wl,$(SO_CMD),libdablooms.$(SO_EXT_MAJOR)

### sources and outputs ###

SRCS_LIBDABLOOMS = dablooms.c murmur.c

OBJS_LIBDABLOOMS = $(patsubst %.c, $(BLDDIR)/%.o, $(SRCS_LIBDABLOOMS))

ifdef USE_MEMORY_MAP
SRCS_TESTS = test_dablooms.c
else
SRCS_TESTS = test_dablooms2.c
endif 
OBJS_TESTS = $(patsubst %.c, $(BLDDIR)/%.o, $(SRCS_TESTS))

LIB_SYMLNKS = libdablooms.$(SO_NAME) libdablooms.$(SO_EXT_MAJOR)
LIB_FILES = libdablooms.a libdablooms.$(SO_EXT) $(LIB_SYMLNKS)

JNIFLAGS= -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux

# for tests
WORDS = /usr/share/dict/words

### rules ###

# default target (needs to be first target)
all: libdablooms

# sort removes duplicates
DEPS := $(sort $(patsubst %.o, %.o.deps, $(OBJS_LIBDABLOOMS) $(OBJS_TESTS)))
-include $(DEPS)

libdablooms: $(patsubst %, $(BLDDIR)/%, $(LIB_FILES))

install: install_libdablooms

install_libdablooms: $(patsubst %, $(DESTDIR)$(libdir)/%, $(LIB_FILES)) $(DESTDIR)$(includedir)/dablooms.h

$(DESTDIR)$(libdir)/libdablooms.a: $(BLDDIR)/libdablooms.a

$(DESTDIR)$(libdir)/libdablooms.$(SO_EXT): $(BLDDIR)/libdablooms.so

$(patsubst %, $(DESTDIR)$(libdir)/%, $(LIB_SYMLNKS)): %: $(DESTDIR)$(libdir)/libdablooms.$(SO_EXT)
	@echo " SYMLNK " $@
	@$(INSTALL) -d $(dir $@)
	@ln -fs $(notdir $<) $@

$(DESTDIR)$(includedir)/dablooms.h: src/dablooms.h 

$(DESTDIR)$(prefix)/%:
	@echo " INSTALL " $@
	@$(INSTALL) -d $(dir $@)
	@$(INSTALL) $< $@

$(BLDDIR)/%.o: src/%.c
	@echo " CC " $@
	@mkdir -p $(dir $@)
	@$(CC) -o $@ -c $< $(ALL_CFLAGS) -MMD -MF $@.deps

$(BLDDIR)/libdablooms.a: $(OBJS_LIBDABLOOMS)
	@echo " AR " $@
	@rm -f $@
	@$(AR) rcs $@ $^

$(BLDDIR)/libdablooms.$(SO_EXT): $(OBJS_LIBDABLOOMS)
	@echo " SO " $@
	@$(CC) -o $@ $(ALL_CFLAGS) $(SHARED_LDFLAGS) $(ALL_LDFLAGS) $^


$(patsubst %, $(BLDDIR)/%, $(LIB_SYMLNKS)): %: $(BLDDIR)/libdablooms.$(SO_EXT)
	@echo " SYMLNK " $@
	@mkdir -p $(dir $@)
	@ln -fs $(notdir $<) $@

$(BLDDIR)/test_dablooms: $(OBJS_TESTS) $(BLDDIR)/libdablooms.a
	@echo " LD " $@
	@$(CC) -o $@ $(ALL_CFLAGS) $(ALL_LDFLAGS) $(OBJS_TESTS) $(BLDDIR)/libdablooms.a -lm

test: $(BLDDIR)/test_dablooms
ifdef USE_MEMORY_MAP
	@$(BLDDIR)/test_dablooms $(BLDDIR)/testbloom.bin $(WORDS)
else
	@$(BLDDIR)/test_dablooms $(WORDS)
endif
 
help:
	@printf $(HELPTEXT)

jni: $(BLDDIR)/libdablooms_jni.so
$(BLDDIR)/libdablooms_jni.so: $(OBJS_LIBDABLOOMS)  src/dablooms_wrap.c
	@echo " SO " $@
	@$(CC) -o $@ $(JNIFLAGS) $(ALL_CFLAGS) $(SHARED_LDFLAGS) $(ALL_LDFLAGS) $^
	cp build/libdablooms_jni.so jdablooms/src/main/resources/native/

src/dablooms_wrap.c: dablooms.i
	swig -package com.github.jdablooms -outdir jdablooms/src/main/java/com/github/jdablooms -Isrc   -o src/dablooms_wrap.c -java dablooms.i 

clean:
	rm -f $(DEPS) $(OBJS_LIBDABLOOMS) $(patsubst %, $(BLDDIR)/%, $(LIB_FILES)) $(OBJS_TESTS) $(BLDDIR)/test_dablooms $(BLDDIR)/testbloom.bin src/dablooms_wrap.c
	rm -fr $(BLDDIR)

.PHONY: all clean help install test libdablooms install_libdablooms

