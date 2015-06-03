##
 # Copyright (c) 2015 Google Inc.
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 # 1. Redistributions of source code must retain the above copyright notice,
 # this list of conditions and the following disclaimer.
 # 2. Redistributions in binary form must reproduce the above copyright notice,
 # this list of conditions and the following disclaimer in the documentation
 # and/or other materials provided with the distribution.
 # 3. Neither the name of the copyright holder nor the names of its
 # contributors may be used to endorse or promote products derived from this
 # software without specific prior written permission.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 # AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 # THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 # PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 # CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 # PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 # OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 # WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 # OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 # ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ##

TOPDIR := ${shell pwd}

OUTROOT := build

#  VERBOSE==1:  Echo commands
#  VERBOSE!=1:  Do not echo commands
ifeq ($(VERBOSE),1)
export Q :=
else
export Q := @
endif

include $(TOPDIR)/.config

CONFIG_ARCH_CHIP  := $(patsubst "%",%,$(strip $(CONFIG_ARCH_CHIP)))
CHIP_DIR := $(TOPDIR)/chips/$(CONFIG_ARCH_CHIP)

include $(CHIP_DIR)/Make.defs

_dummy := $(shell [ -d $(OUTROOT) ] || mkdir -p $(OUTROOT))
include $(TOPDIR)/Sources.mk
_dummy := $(foreach d,$(SRCDIRS), \
		  $(shell [ -d $(OUTROOT)/$(d) ] || mkdir -p $(OUTROOT)/$(d)))

BIN = $(OUTROOT)/bootrom

all: $(BIN)

$(BIN): $(AOBJS) $(COBJS)
	@ echo Linking $@
	$(Q) $(LD) -T $(LDSCRIPT) $(LINKFLAGS) -o $@ $(AOBJS) $(COBJS)
	$(Q) $(OBJCOPY) $(OBJCOPYARGS) -O binary $(BIN) $(BIN).bin

-include $(COBJS:.o=.d) $(AOBJS:.o=.d)

build/%.o: %.c
	@ echo Compiling $<
	$(Q) $(CC) $(CFLAGS) -MM -MT $@ -MF $(patsubst %.o,%.d,$@) -c $<
	$(Q) $(CC) $(CFLAGS) -o $@ -c $<

build/%.o: %.S
	@ echo Assembling $<
	$(Q) $(CC) $(AFLAGS) -MM -MT $@ -MF $(patsubst %.o,%.d,$@) -c $<
	$(Q) $(CC) $(AFLAGS) -o $@ -c $<

clean:
	$(Q) -rm -rf $(OUTROOT)

distclean: clean
	$(Q) -rm -rf .config