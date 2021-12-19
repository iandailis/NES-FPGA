
module NIOSIIe (
	clk_clk,
	cpu_clk,
	hex_wire_export,
	key_wire_export,
	keycode_export,
	led_wire_export,
	nes_clk,
	ppu_clk,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	sw_wire_export,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export,
	vga_clk);	

	input		clk_clk;
	output		cpu_clk;
	output	[23:0]	hex_wire_export;
	input	[1:0]	key_wire_export;
	output	[31:0]	keycode_export;
	output	[9:0]	led_wire_export;
	output		nes_clk;
	output		ppu_clk;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input	[9:0]	sw_wire_export;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
	output		vga_clk;
endmodule
