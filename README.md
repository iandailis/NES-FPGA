# NES-FPGA
NES (Nintendo Entertainment System) emulator in SystemVerilog for an Intel/Altera Max10 FPGA on a Terasic DE-10 Lite.

https://en.wikipedia.org/wiki/Nintendo_Entertainment_System

Uses a custom I/O expansion board with a MAX3421E USB controller for keyboard support.

Folders:
* cart_init: Cartridge initialization, includes a python parser that generates prg.mif and chr.mif using a provided hex dump.
* eclipse: Working directory for the USB controller programmed in C.
* qsys: Generated files for the NIOS-IIe and the PLLs.
* software: C source code for the USB controller.
* src: Hardware description of the NES.

To load a game (by default the emulator loads Super Mario Bros):
1. Download a NES ROM.
2. Create a hex dump of the ROM using VSCode.
3. Figure out the mapper information from the iNES header (https://wiki.nesdev.org/w/index.php/INES).
4. Change the input file and the starting address in cart_init/python parsing/parse.py
5. Run the python parser with "python parse.py"

To use a provided ROM, change the source file and the starting address in the python parser to the address specified in CONFIG.txt, then run the parser.

To run:
1. Open NES.qpf in Intel Quartus (tested on version 18.1).
2. Compile.
3. Program the FPGA. Make sure SW[0] is flipped on.
5. Launch NIOS-II Build Tools for Eclipse, with working directory eclipse/
6. Press "Run Configurations" then "Run" 

Once the hex displays or the NIOS-II console is showing the pressed keycodes, you can begin to play!

Controls:
- SW[0]: CPU Reset (active low)
- WASD: Arrow keys
- J: A
- K: B
- I: Select
- O: Start

Issues:
- No vertical scrolling.
- No audio support.
- Sprite 0 hit needs more work, flashing detatched backgrounds break the sync.
- Uses too much RAM. the CPU doesnt need 64kB, it should only need 2 kB RAM and 32 kB of prgrom. 
- Multi-tile mario top of head doesn't render properly.
- Tile prefetch when scrolling doesn't work properly for the first tile in a line
- No easy abstraction to implement other mappers.
- No 8x16 sprite support
- No PPUMASK support

Enjoy!

-Ian D
