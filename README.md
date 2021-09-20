# 65c816_to_Xilinx
Connect a 65c816 to a Xilinx CMOD A7 35T using internal SRAM and UART

Right now, you can connect a 65c816 directly to a Xilinx CMOD A7 using the CMOD SRAM and internal UART to communicate with your PC via a terminal program. The CMOD has a small monitor in ROM ($C000-$FFFF), an ACIA at $8000, and RAM from $0000-$7FFF. The LEDs indicate reset status and the e-bit status. The constraints file shows which pins to connect from the 'c816 to the CMOD.

Note: the monitor implements Woz's "Sweet 16" at $C000, if you want to use that. The monitor resides in the COE file.

This design also requires a 1.8432mhz external oscillator (clock) to be connected to the CMOD A7 so that the ACIA will work properly.

Note: You must clock the device itself ABOVE 2mhz. I've tested it up to 6mhz.

There is a thread discussing this project, with diagrams, at http://forum.6502.org/viewtopic.php?f=1&t=6788#p87188
