# NES-FPGA
NES emulator in SystemVerilog for a Intel/Altera Max10 FPGA on a Terasic DE-10 Lite

Uses a custom I/O expansion board with a MAX3421E USB controller for keyboard support.

Folders:
* cart_init: cartridge initialization, includes a python parser that generates prg.mif and chr.mif using a provided hex dump
* eclipse: working directory for the USB controller programmed in C.
* qsys: generated files for the NIOS-IIe and the PLLs.
* software: C source code for the USB controller
* src: hardware description of the NES

To load a game:
1. Download a NES ROM.
2. Create a hex dump of the ROM using VSCode.
3. Figure out the mapper information from the iNES header (https://wiki.nesdev.org/w/index.php/INES)
4. Change the input file and the starting address in cart_init/python parsing/parse.py 
5. Run the python parser with "python parse.py"

To use a provided ROM, change the source file and the starting address in the python parser to the address specified in CONFIG.txt, then run the parser.

To run:
1. Open NES.qpf in Intel Quartus (tested on version 18.1)
2. Compile
3. Program the FPGA. Make sure SW[0] is flipped on.
5. Launch NIOS-II Build Tools for Eclipse, with working directory eclipse/
6. Press "Run Configurations" then "Run." Once the NIOS-II console is showing the pressed keycodes, you can begin to play!

Controls:
SW[0]: CPU Reset (active low)
WASD: Arrow keys
J: A
K: B
I: Select
O: Start

Enjoy!
**Ian D**
