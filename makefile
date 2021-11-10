# Timezones are extracted from the #ifdef list in the .asm file
# To flash a given timezone, type e.g.
#		make flash-us_eastern

# Cross-platform solution is to have a different wrapper script on each machine
# On linux /usr/bin/avrasm2 looks like:
#		#!/bin/sh
#		wine ~/avrasm/avrasm2.exe -I ~/avrasm $*

CHIP = 2313

hexes := $(shell perl -lne 'm[ifdef TZ_(\w+)] and print lc("build/$$1.hex")' GPSClock.asm)


.PHONY: all clean fuses osccal
all: $(hexes)

build:
	mkdir build
	mkdir build/with_crystal

$(hexes): %.hex: GPSClock.asm build
	avrasm2 -fI -i"tn$(CHIP)def.inc" \
	-D$(shell echo "$@" | perl -lne 'm[build/(.*)\.hex] and print uc("TZ_$$1")') \
	$< -o $@
	avrasm2 -fI -i"tn$(CHIP)def.inc" \
	-DUSE_CRYSTAL \
	-D$(shell echo "$@" | perl -lne 'm[build/(.*)\.hex] and print uc("TZ_$$1")') \
	$< -o $(shell echo "$@" | sed 's|build/|build/with_crystal/|')

flash-%: build/%.hex
	avrdude -c usbasp -p t$(CHIP) -U flash:w:$<:i

flash: flash-london

clean:
	rm -rf build/
	rm osccal.hex

fuses:
	avrdude -p t$(CHIP) -B2000 -U lfuse:w:0xe4:m

# EESAVE set hfuse = 0x9F
osccal:
	avrasm2 -fI -i"tn$(CHIP)def.inc" osccal.asm -o osccal.hex
	avrdude -c usbasp -p t$(CHIP) -U flash:w:osccal.hex:i -U hfuse:w:0x9f:m
