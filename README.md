# 65c816_to_Xilinx
Connect a 65c816 to a Xilinx CMOD A7 35T using internal SRAM and UART. The 65c816 is the 8/16-bit big brother of the 65c02, used in the SNES and Apple II GS. It also boots in a 65c02 emulation mode, so you can run all your 65c02 code on it, ab initio. https://www.westerndesigncenter.com/wdc/documentation/w65c816s.pdf

Right now, you can connect a 65c816 directly to a Xilinx CMOD A7 using the CMOD SRAM and internal UART to communicate with your PC via a terminal program. The CMOD has a small monitor in ROM ($C000-$FFFF), an ACIA at $8000, and RAM from $0000-$7FFF. The LEDs indicate reset status and the e-bit status. The constraints file shows which pins to connect from the 'c816 to the CMOD.

Note: the monitor implements Woz's "Sweet 16" at $C000, if you want to use that. The monitor resides in the COE file.

This design also requires a 1.8432mhz external oscillator (clock) to be connected to the CMOD A7 so that the ACIA will work properly.

Note: You must clock the device itself ABOVE 2mhz. I've tested it up to 6mhz.

There is a thread discussing this project, with diagrams, at http://forum.6502.org/viewtopic.php?f=1&t=6788#p87188

You can load your programs into RAM as .prg files. Enter "X" at the monitor prompt, and you can load your program via the XMODEM protocol. I use ExtraPuTTY. Note: you can control where in RAM your programs load via your .prg files. I've been coding using Visual Studio and RetroAssembler. https://enginedesigns.net/retroassembler/

Run your program by using the address + "R" at the monitor prompt. For example, if you load your program at $1000, you would type 1000R and then enter. Make sure to jump or rts out to $C385 at the end of your program. This is the exit point that will return you to your monitor.

"L" clears the Zero Page and resets the stack.

The other monitor function work as a typical WozMon would: (e.g.), https://www.sbprojects.net/projects/apple1/wozmon.php

Feel free to contact me through the 6502 forum: http://forum.6502.org/memberlist.php?mode=viewprofile&u=3597
