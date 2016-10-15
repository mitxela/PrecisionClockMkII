# Precision Clock Mk II
Code for the ATtiny2313 used in my [Precision Clock Mk II](https://mitxela.com/projects/precision_clock_mk_ii). Uses a cheap GPS module to grab a very accurate timestamp and then compensates for daylight saving time in a ridiculous manner involving a lookup table with precalculated changeover dates for the next 75 years. Displays are driven with MAX7219 chips and auto-brightness is done in analog with an LDR and transistors as a current mirror. 

Last modified 27 Sep 2015