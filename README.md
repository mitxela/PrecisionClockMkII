# Precision Clock Mk II

Code for the ATtiny2313 used in both the [Precision Clock Mk II½](https://mitxela.com/projects/precision_clock_mk_iii) and [its predecessor](https://mitxela.com/projects/precision_clock_mk_ii). 

The code is compatible with the ATiny2313, ATtiny2313A and ATtiny4313. The only difference between the chips is the amount of memory, and the code is short enough to fit onto the smaller chip. There is a variable in the makefile to set the chip, but it's only really needed to stop avrdude complaining about the chip signature.

Timezones and daylight saving is now configured by compile-time definitions. The makefile handles this seamlessly, but if you're not interested in setting up the environment there are pre-built hex files for all locations in the build folder. I will expand the list of generated hex files as needed. If you want to add a different timezone, the format should be quite easy to understand, feel free to submit a pull request.

To configure the build environment you only need avrasm2.exe and make. On linux I run avrasm2 under wine, I have a script in /usr/bin that looks like

```
#!/bin/sh
wine ~/avrasm/avrasm2.exe -I ~/avrasm $*
```

The makefile greps through the source code for the timezone definitions, and builds each one using a pattern. You can then flash a specific timezone by typing for instance

```
make flash-us_central
```

`make flash` defaults to London. 