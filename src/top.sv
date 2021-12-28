// top level :)
module top(

	input MAX10_CLK1_50,
	
	/* DE-10 I/O */
	input [1:0] KEY,	// top button is KEY[0], bottom button is KEY[1]. active low (low when pressed).
	input [9:0] SW,
	output [9:0] LEDR,
	
	/* HEX */
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5,
	
	/* SDRAM */	
	output DRAM_CLK,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CS_N,
	inout [15:0] DRAM_DQ,
	output DRAM_LDQM,
	output DRAM_UDQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	
	/* I/O BOARD */
	inout [15:0] ARDUINO_IO,
	inout ARDUINO_RESET_N,
	
	/* VGA OUTPUT */
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B,
	output VGA_HS,
	output VGA_VS
	
);

logic nes_clk, cpu_clk, ppu_clk, vga_clk;

logic [1:0] KEY_sync;
sync2 KEY_SYNC (.Clk (nes_clk), .in (KEY), .out (KEY_sync));

logic [9:0] SW_sync;
sync10 SW_SYNC (.Clk (nes_clk), .in (SW), .out (SW_sync));

assign LEDR = cpu_addr[9:0];

/* MISC */
logic [31:0] keycode;

/* SDRAM */
logic [1:0] sdram_wire_dqm;
assign DRAM_LDQM = sdram_wire_dqm[0];
assign DRAM_UDQM = sdram_wire_dqm[1];

/* SPI */
logic spi0_MISO, spi0_MOSI, spi0_SCLK, spi0_SS_n;
assign ARDUINO_IO[10] = spi0_SS_n;
assign ARDUINO_IO[13] = spi0_SCLK;
assign ARDUINO_IO[11] = spi0_MOSI;
assign ARDUINO_IO[12] = 1'bZ;
assign spi0_MISO = ARDUINO_IO[12];

/* USB */
logic usb_gpx_export, usb_irq_export, usb_rst_export;
assign ARDUINO_IO[9] = 1'bZ; 
assign usb_irq_export = ARDUINO_IO[9];
assign ARDUINO_RESET_N = usb_rst_export;
assign ARDUINO_IO[7] = usb_rst_export;
assign ARDUINO_IO[8] = 1'bZ;	// this is GPX?
assign usb_gpx_export = 1'b0;	// and GPX is not needed

assign ARDUINO_IO[6] = 1'b1;	// uSD card

NIOSIIe NIOSIIe (

	.clk_clk(MAX10_CLK1_50),
	.reset_reset_n(1'b1),
	
	.key_wire_export(KEY_sync),	// KEY
	.sw_wire_export(SW_sync),		// SW
	
	.led_wire_export(),	// LEDR
	.hex_wire_export(), // {hex5_v, hex4_v, hex3_v, hex2_v, hex1_v, hex0_v}
	
	.keycode_export(keycode),
	
	.nes_clk(nes_clk),
	.cpu_clk(cpu_clk),
	.ppu_clk(ppu_clk),
	.vga_clk(vga_clk),
		
	.sdram_clk_clk(DRAM_CLK),
	.sdram_wire_addr(DRAM_ADDR),
	.sdram_wire_ba(DRAM_BA),
	.sdram_wire_cas_n(DRAM_CAS_N),
	.sdram_wire_cke(DRAM_CKE),
	.sdram_wire_cs_n(DRAM_CS_N),
	.sdram_wire_dq(DRAM_DQ),
	.sdram_wire_dqm(sdram_wire_dqm),
	.sdram_wire_ras_n(DRAM_RAS_N),
	.sdram_wire_we_n(DRAM_WE_N),
	
	.spi0_MISO(spi0_MISO),
	.spi0_MOSI(spi0_MOSI),
	.spi0_SCLK(spi0_SCLK),
	.spi0_SS_n(spi0_SS_n),
	
	.usb_gpx_export(usb_gpx_export),
	.usb_irq_export(usb_irq_export),
	.usb_rst_export(usb_rst_export)
	
);


logic [3:0] hex5_v, hex4_v, hex3_v, hex2_v, hex1_v, hex0_v;

HexDriver hex0 ( .in(hex0_v), .out(HEX0) );
HexDriver hex1 ( .in(hex1_v), .out(HEX1) );
HexDriver hex2 ( .in(hex2_v), .out(HEX2) );
HexDriver hex3 ( .in(hex3_v), .out(HEX3) );
HexDriver hex4 ( .in(hex4_v), .out(HEX4) );
HexDriver hex5 ( .in(hex5_v), .out(HEX5) );


logic cpu_reset, cpu_enable, cpu_rdy;
logic cpu_irq, cpu_nmi, cpu_read;
logic [23:0] cpu_addr;
logic [7:0] cpu_din, cpu_dout;

T65 cpu (
	.mode   (2'b0),		// 6502 mode
	.BCD_en (1'b0),		// idk but this is right
	
	.clk    (cpu_clk),		// clock

	.res_n  (cpu_reset),		// cpu reset 
	.enable (cpu_enable),	// enable (cpu doesnt continue unless this is high)
	.rdy    (cpu_rdy),		// ready (cpu doesnt continue with some extra steps)

	.IRQ_n  (cpu_irq),		// beta interrupt (interrupt request)
	.NMI_n  (cpu_nmi),		// alpha interrupt https://en.wikipedia.org/wiki/Non-maskable_interrupt
	
	.R_W_n  (cpu_read),	// read = 1, write = 0
	.A      (cpu_addr),	// address in DRAM
	.DI     (cpu_din),	// data in
	.DO     (cpu_dout)	// data out
);


logic [15:0] ppu_addr;
logic [7:0] ppu_din, ppu_dout;
logic ppu_wren, ppu_nmi;

logic [7:0] ppu_oam_addr0, ppu_oam_addr1;
logic [7:0] ppu_oam_dout0, ppu_oam_dout1;
logic	[7:0] ppu_oam_din1;
logic ppu_oam_wren1;

ppu ppu (
	.ppu_clk		(ppu_clk),
	.nes_clk		(nes_clk),
	.vga_clk		(vga_clk),
	.cpu_clk		(cpu_clk),
	.addr			(ppu_addr),
	.din			(ppu_din),
	.wren			(ppu_wren),
	.dout			(ppu_dout),
	.nmi			(ppu_nmi),
	
	.oam_addr0	(ppu_oam_addr0),
	.oam_dout0	(ppu_oam_dout0),
	
	.oam_addr1	(ppu_oam_addr1),
	.oam_din1	(ppu_oam_din1),
	.oam_wren1	(ppu_oam_wren1),
	.oam_dout1	(ppu_oam_dout1),
	
	.VGA_R		(VGA_R),
	.VGA_G		(VGA_G),
	.VGA_B		(VGA_B),
	.VGA_HS		(VGA_HS),
	.VGA_VS		(VGA_VS),
	.debug		(),
	.select		(~KEY_sync[0])
);


logic [7:0] ram_din, ram_dout;
logic [15:0] ram_addr;
logic ram_wren;

ram ram (
	.address (ram_addr),
	.clock (nes_clk),
	.data (ram_din) ,
	.wren (ram_wren),
	.q (ram_dout)
);

logic [7:0] controller_dout;
controller controller (
	.clk	(cpu_clk),
	.addr	(cpu_addr),
	.keycode	(keycode),
	.wren	(~cpu_read),
	.dout	(controller_dout)
);

logic [7:0] oam_addr0, oam_addr1;
logic [7:0] oam_din0, oam_din1;
logic [7:0] oam_dout0, oam_dout1;
logic oam_wren0, oam_wren1;

OAM OAM (
	.clock_a		(vga_clk),
	.address_a	(oam_addr0),
	.data_a		(oam_din0),
	.wren_a		(oam_wren0),
	.q_a			(oam_dout0),
	
	.clock_b		(nes_clk),
	.address_b	(oam_addr1),
	.data_b		(oam_din1),
	.wren_b		(oam_wren1),
	.q_b			(oam_dout1)
); 

logic [9:0] dma_count;
logic [7:0] dma_reg;
logic dma, dma_finish;
logic [15:0] dma_ram_addr;
logic [7:0] dma_oam_addr;
initial begin
	dma = 0;
	dma_finish = 1'b1;
end
always_ff @ (posedge cpu_clk) begin
	dma = ~dma_finish;
end
always_ff @ (posedge nes_clk) begin
	if (cpu_addr == 16'h4014 && ~dma) begin
		dma_finish <= 0;
		dma_count <= 0;
		dma_reg <= cpu_dout;
		dma_ram_addr <= {dma_reg, 8'd0};
		dma_oam_addr <= 0;
	end
	
	if (dma) begin
		if (dma_count == 10'h200) begin
			dma_finish <= 1;
		end else begin
			dma_count <= dma_count + 1'd1;
			case (dma_count[0])
				1'b0 :
					begin
						dma_ram_addr <= dma_ram_addr + 1'd1;
					end
				1'b1:
					begin
						dma_oam_addr <= dma_oam_addr + 1'd1;
					end
			endcase
		end
	end
end
always_comb begin

	{hex5_v, hex4_v, hex3_v, hex2_v, hex1_v, hex0_v} = keycode[31:8];

	oam_addr0 = ppu_oam_addr0;
	oam_din0 = 0;
	oam_wren0 = 0;
	ppu_oam_dout0 = oam_dout0;
	
	if (dma) begin
	
		oam_addr1 = dma_oam_addr;
		oam_din1 = ram_dout;
		if (dma_count < 10'h200) begin
			oam_wren1 = 1'd1;
		end else begin
			oam_wren1 = 1'd0;
		end
		
	end else begin
	
		oam_addr1 = ppu_oam_addr1;
		oam_wren1 = ppu_oam_wren1;
		oam_din1 = ppu_oam_din1;
		
	end
	ppu_oam_dout1 = oam_dout1;
end

logic [7:0] databus;

always_comb begin
	if (dma) begin
		ram_addr = dma_ram_addr;
		ram_din = 1'b0;
		ram_wren = 1'b0;
	end else begin
		ram_addr = cpu_addr[15:0];
		ram_din = cpu_dout;
		ram_wren = ~cpu_read;
	end
	
	ppu_addr = cpu_addr[15:0];
	ppu_din = cpu_dout;
	ppu_wren = ~cpu_read;
	
	if (cpu_addr >= 16'h2000 && cpu_addr <= 16'h3FFF) begin
		databus = ppu_dout;
	end else if (16'h4016 <= cpu_addr && cpu_addr <= 16'h4017) begin
		databus = controller_dout;
	end else begin
		databus = ram_dout;
	end
	
end

always_comb begin
	
	if (~cpu_read) begin	
		cpu_din = cpu_dout;	/* WRITING */
	end else begin			
		cpu_din = databus;	/* READING */
	end
	
	cpu_reset = SW_sync[0];
	cpu_enable = ~dma;
	cpu_rdy = 1'b1;
	cpu_irq = 1'b1;
	cpu_nmi = ~ppu_nmi;

end

endmodule

/*	NOTES
		
	MEMORY: 2KB. ADDRESS 0x0000 --> 0x1FFF MIRRORED FROM MAPPED 0x0000 --> 0x07FF

	APU: 0x4000 --> 0x4017
	
	CARTRIDGE: PROGRAM ROM 0x4020 --> 0xFFFF
		MAPPERS: BANK SWITCHING: cpu configures mapper on cartridge to take different data
			different lvls on different banks on cartridge - can have significantly larger games
	
	PPU: 0x2000 --> 0x2007. 16KB addressable range - clocked at 3x speed of CPU
		PATTERN: 0x0000 --> 0x1FFF	STORED ON CARTRIDGE
		NAMETABLE: 0x2000 --> 0x2FFF - 2d arrays storing IDs of which patterns to show 
		PALETTES: 0x3F00 --> 0x3FFF
		VRAM: 2KB: 0x2000 --> 0x27FF
		
		OAM: stores locations of sprites: 
			DMA - suspends CPU to transfer memory to OAM
*/
