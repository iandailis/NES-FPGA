# NES-FPGA
NES (Nintendo Entertainment System) emulator in SystemVerilog for an Intel/Altera Max10 FPGA on a Terasic DE-10 Lite.

https://en.wikipedia.org/wiki/Nintendo_Entertainment_System

Uses a custom I/O expansion board with a MAX3421E USB controller for keyboard support.

I made everything except for the 6502 CPU core which I took from a previous revision of the MISTer NES (which they adapted from opencores.org), and I adapted some assets provided by my university (VGA display controller, Hex display driver, and the MAX3421E USB controller driver).

![Project Image](https://github.com/iandailis/NES-FPGA/blob/main/docs/IMG_20220826_020011.jpg)
![Project Image](https://github.com/iandailis/NES-FPGA/blob/main/docs/IMG_20220826_021004.jpg)
![Project Image](https://github.com/iandailis/NES-FPGA/blob/main/docs/resources.JPG)

Folders:
- cart_init: Cartridge initialization, includes a python parser that generates prg.mif and chr.mif using a provided hex dump.
- eclipse: Working directory for the USB controller programmed in C.
- qsys: Generated files for the NIOS-IIe and the PLLs, and C source code for the usb controller
- src: Hardware description of the NES.

To load a game (optional, by default the emulator loads Super Mario Bros):
1. Download a NES ROM.
2. Create a hex dump of the ROM using VSCode. 
3. Delete the first line with offset information.
4. Place the dump into cart_init/python parsing/dumps and name it [dump_name_no_spaces]_dump.txt
5. Go to cart_init/python parsing and run the python parser with "python parse.py [dump_name_no_spaces]"

This initializes prg.mif and chr.mif, which is used by Quartus to initialize the cartridge roms. Look at the provided dumps to see the expected format for the parser. The iNES header should be the first line of the dump.

To run:
1. Open NES.qpf in Intel Quartus (tested on version 18.1).
2. Compile.
3. Program the FPGA.
5. Launch NIOS-II Build Tools for Eclipse, with working directory eclipse/
6. Mouse over "Run" then press "Run Configurations" then press "Run" 

Once the hex displays or the NIOS-II console is showing the pressed keycodes, you can begin to play!

Controls:
- KEY[0]: CPU Reset
- WASD: Arrow keys
- G: Select
- H: Start
- K: B
- L: A

Issues:
- No vertical scrolling.
- No audio support.
- Sprite 0 hit needs more work, flashing detatched backgrounds break the sync.
- CPU uses too much RAM. The CPU only needs a 2 kB RAM and a 32 kB program ROM, currently it uses a 64kB RAM for everything. 
- Second tile in the line is incorrect when scrolling
- Only supports mapper 0 (NROM) with vertical mirroring, and many other mapper specifics are also unsupported.
- No 8x16 sprite support
- No PPUMASK support
- Display is not centered on screen

Enjoy!

-Ian D
