module ppu (

	input ppu_clk, nes_clk, vga_clk, cpu_clk,
	input [15:0] addr,
	input [7:0] din,
	input wren,
	output [7:0] dout,
	
	output nmi,
	
	output [7:0] oam_addr0,
	input [7:0]	oam_dout0,
	
	output [7:0] oam_addr1,
	output [7:0] oam_din1,
	output oam_wren1,
	input [7:0] oam_dout1,
	
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B,
	output VGA_HS,
	output VGA_VS,
	
	output [23:0] debug,
	input select
);



logic [7:0] PPUCTRL;		/* $XX00 */
logic [7:0] PPUMASK;		/* $XX01 */
logic [7:0] PPUSTATUS;	/* $XX02 */
logic [7:0] OAMADDR;		/* $XX03 */
logic [7:0] OAMDATA;		/* $XX04 */
//logic [15:0] PPUSCROLL;	/* $XX05 */
logic [15:0] PPUADDR;	/* $XX06 */
logic [7:0] PPUDATA;		/* $XX07 */	/* WRITE DATA */	

logic [7:0] readdata;					/* READ DATA */
logic [7:0] oam_readdata;
logic [7:0] scroll_x, scroll_y;

logic addr_latch;
logic [15:0] addr_final;
logic ppu_wren;	/* TELL THE PPU IF WE ARE WRITING DATA AT PPUADDR */
logic inc_addr;

always_ff @ (posedge cpu_clk) begin	// REGISTERS
	ppu_wren <= 0;
	oam_wren1 <= 0;
	if (DrawX == 512) begin
		OAMADDR <= 0;
	end
	if (inc_addr) begin
		if (PPUCTRL[2]) begin
			addr_final <= addr_final + 6'd32;
		end else begin
			addr_final <= addr_final + 1'd1;
		end
		inc_addr <= 0;
	end
	if (16'h2000 <= addr && addr <= 16'h3FFF) begin
		if (wren) begin	/* WRITING */
			case (addr[2:0])
				3'h0 :	/* CONTROL */
					begin
						PPUCTRL <= din;
					end
				3'h1 :	/* MASK */
					begin
						PPUMASK <= din;
					end
				3'h3 :
					begin
						OAMADDR <= din;
					end
				3'h4 :
					begin
						OAMDATA <= din;
						OAMADDR <= OAMADDR + 1'd1;
						oam_wren1 <= 1;
					end
				3'h5 :	/* SCROLL */
					begin
						if (addr_latch == 0) begin
							scroll_x <= din;
							addr_latch <= 1;
						end else begin
							scroll_y <= din;
							addr_latch <= 0;
						end
					end
				3'h6 :	/* ADDRESS */
					begin
						if (addr_latch == 0) begin
							PPUADDR[15:8] <= din;
							addr_latch <= 1;
						end else begin
							PPUADDR[7:0] <= din;
							addr_latch <= 0;
							addr_final <= {PPUADDR[13:8], din};
						end		
					end
				3'h7 :	/* DATA */
					begin
						ppu_wren <= 1;
						PPUDATA <= din;
						inc_addr <= 1;
					end
			endcase
		end else begin	/* READING */
			case (addr[2:0])
				3'h2 :	/* PPUSTATUS */
					begin
						dout <= PPUSTATUS;
						addr_latch <= 0;
					end
				3'h4 :
					begin
						dout <= oam_readdata;
						OAMADDR <= OAMADDR + 1'd1;
					end
				3'h7 :	/* PPUDATA */
					begin
						dout <= readdata;
						inc_addr <= 1;
					end
			endcase
		end
	end

	if (DrawY == 480) begin
		PPUSTATUS[7] <= 1;
	end else if ((16'h2000 <= addr && addr <= 16'h3FFF && addr[2:0] == 3'h2) || ~v_blank) begin
		PPUSTATUS[7] <= 0;
	end
	
end

always_comb begin	/* REGISTERS COMB */
	PPUSTATUS[4:0] = PPUDATA[4:0];
	
	oam_addr1 = OAMADDR;
	oam_din1 = OAMDATA;
	oam_readdata = oam_dout1;
	
	debug = 0;
	
end





logic [7:0] ppu_databus;
logic read_done;
always_ff @ (posedge nes_clk) begin
	
	if (read_done && ~wren) begin
		readdata <= ppu_databus;
		read_done <= 0;
	end
	
	if (addr_final <= 16'h1FFF) begin
		if (~ppu_wren) begin
			ppu_databus <= chr_dout0;
			read_done <= 1;
		end
	end else if (16'h2000 <= addr_final && addr_final <= 16'h3EFF) begin
		if (~ppu_wren) begin
			ppu_databus <= vram_dout0;
			read_done <= 1;
		end
	end else if (16'h3F00 <= addr_final && addr_final <= 16'h3FFF) begin
		if (ppu_wren) begin
			if (addr_final[4:0] == 5'h10 || addr_final[4:0] == 5'h00) begin
				palette_mem[0] <= PPUDATA;
			end else begin
				palette_mem[addr_final[4:0]] <= PPUDATA;
			end
		end else begin
			if (addr_final[4:0] == 5'h10 || addr_final[4:0] == 5'h00) begin
				ppu_databus <= palette_mem[0];
			end else begin
				ppu_databus <= palette_mem[addr_final[4:0]];
			end
			read_done <= 1;
		end
	end
			
end

logic [15:0] vaddr0_mirror;
logic [15:0] vaddr0;

always_comb begin

	vram_wren0 = 0;
	vram_din0 = PPUDATA;
	vram_addr0 = 0;
	vaddr0_mirror = 0;
	
	vaddr0 = addr_final & 16'h2FFF;	/* MIRORRS UPPER RANGE */ 
	
	chr_addr0 = 0;
	
	if (16'h000 <= addr_final && addr_final <= 16'h1FFF) begin

		chr_addr0 = addr_final[12:0];
		
	end else if (16'h2000 <= addr_final && addr_final <= 16'h3EFF) begin
		
		vram_wren0 = ppu_wren;
		
//		/* VERTICAL MIRROR */
	
		if (16'h2000 <= vaddr0 && vaddr0 < 16'h2400) begin				/* nt1 */
			vaddr0_mirror = vaddr0 - 16'h2000;
		end else if (16'h2400 <= vaddr0 && vaddr0 < 16'h2800) begin	/* nt2 */ 
			vaddr0_mirror = vaddr0 - 16'h2000;
		end else if (16'h2800 <= vaddr0 && vaddr0 < 16'h2C00) begin	/* MIRROR TO nt1 */
			vaddr0_mirror = vaddr0 - 16'h2800;
		end else begin																					/* MIRROR TO nt2 */
			vaddr0_mirror = vaddr0 - 16'h2800;
		end
		
		vram_addr0 = vaddr0_mirror[10:0];
			
	end

end

logic [12:0] chr_addr0, chr_addr1;
logic [7:0] chr_dout0, chr_dout1;

chrrom chrrom (
	.clock_a		(nes_clk),
	.address_a	(chr_addr0),
	.data_a		(8'h00),
	.wren_a		(1'b0),
	.q_a			(chr_dout0),
	
	.clock_b		(vga_clk),
	.address_b	(chr_addr1),
	.data_b		(8'h00),
	.wren_b		(1'b0),
	.q_b			(chr_dout1)
);

logic [10:0] vram_addr0, vram_addr1;
logic [7:0] vram_din0, vram_dout0, vram_din1, vram_dout1;
logic vram_wren0, vram_wren1;

vram vram (
	.clock_a		(nes_clk),
	.address_a	(vram_addr0),
	.data_a		(vram_din0),
	.wren_a		(vram_wren0),
	.q_a			(vram_dout0),
	
	.clock_b		(vga_clk),
	.address_b	(vram_addr1),
	.data_b		(vram_din1),
	.wren_b		(vram_wren1),
	.q_b			(vram_dout1)
);


logic [7:0] next_msTile, next_lsTile, curr_msTile, curr_lsTile, next_chr;
logic [7:0] next_paletteID, curr_paletteID;
logic [9:0] nextline;
logic [9:0] nexttile;

logic [7:0] sprite_ls [8];
logic [7:0] sprite_ms [8];

always_ff @ (posedge vga_clk) begin
	if (0 <= DrawX && DrawX <= 511 || DrawX >= 768) begin
		case (x_final[3:1])
			3'h1 :
				begin
					next_chr <= vram_dout1;
				end
			3'h3 :
				begin
					next_paletteID <= vram_dout1;
				end
			3'h5 :
				begin
					next_lsTile <= chr_dout1;
				end
			3'h7 :
				begin
					next_msTile <= chr_dout1;
				end
		endcase
		if (x_final[3:0] == 4'hF) begin
			curr_paletteID <= next_paletteID;
			curr_lsTile <= next_lsTile;
			curr_msTile <= next_msTile;
		end
	end else begin
		if (DrawX[4:2] <= sprite_count) begin
			case (DrawX[1:0])
				2'b01 :
					begin
						sprite_ls[DrawX[4:2]] <= chr_dout1;
					end
				2'b11 :
					begin
						sprite_ms[DrawX[4:2]] <= chr_dout1;
					end
			endcase
		end
	end
end

logic [10:0] vram_addr_tile;
logic [10:0] vram_addr_attr;

logic[9:0] x_final, y_final;

always_comb begin
	vram_wren1 = 0;
	vram_din1 = 0;
	vram_addr_tile = 0;
	vram_addr_attr = 0;
	vram_addr1 = 0;
	
	x_final = DrawX + {scroll_x, 1'b0};
	y_final = DrawY + {scroll_y, 1'b0};
	
	chr_addr1 = 0;
	nextline = y_final + 1'd1;
	nexttile = x_final + 5'b10000;
	if (0 <= DrawX && DrawX < 512 || DrawX >= 768) begin
		case (x_final[3:2])
			2'h0 :	/* NAMETABLE ADDR */
				begin
					if (DrawX > 512) begin
						vram_addr_tile = {nextline[8:4], scroll_x[7:3]};
					end else begin	
						if (x_final + 16 >= 512) begin	/* fetch at next nametable */
							if (x_final + 16 < 528) begin
								vram_addr_tile = {y_final[8:4], x_final[8:4]} + 1'd1 + 11'h0400 - 6'd32;
							end else begin
								vram_addr_tile = {y_final[8:4], x_final[8:4]} + 1'd1 + 11'h0400;
							end
						end else begin
							vram_addr_tile = {y_final[8:4], x_final[8:4]} + 1'd1;
						end	
					end
				end
			2'h1 :	/* ATTRIBUTE TABLE ADDR */
				begin
					if (DrawX > 512) begin
						vram_addr_attr = 11'h03C0 + (nextline[8:6] * 4'd8) + scroll_x[7:5];
					end else begin
						if (x_final + 10'd16 >= 512) begin
							vram_addr_attr = 11'h03C0 + nexttile[8:6] + (y_final[8:6] * 4'd8) + 11'h0400;
						end else begin
							vram_addr_attr = 11'h03C0 + nexttile[8:6] + (y_final[8:6] * 4'd8);
						end
						
					end
				end
			2'h2 :
				begin
					if (DrawX > 512) begin
						chr_addr1 = {PPUCTRL[4], 12'h000} + next_chr * 5'd16 + nextline[3:1];
					end else begin
						chr_addr1 = {PPUCTRL[4], 12'h000} + next_chr * 5'd16 + y_final[3:1];
					end
				end
			2'h3 :
				begin
					if (DrawX > 512) begin
						chr_addr1 = {PPUCTRL[4], 12'h000} + next_chr * 5'd16 + nextline[3:1] + 4'd8;
					end else begin
						chr_addr1 = {PPUCTRL[4], 12'h000} + next_chr * 5'd16 + y_final[3:1] + 4'd8;
					end
				end
		endcase
	end else begin
		if (DrawX[4:2] <= sprite_count && DrawY < 512) begin
			case (DrawX[1])
				1'b0 :
					begin
						if (sprite_attr[DrawX[4:2]][7]) begin
							chr_addr1 = {PPUCTRL[3], 12'h000} + (sprite_tile[DrawX[4:2]] * 5'd16) + (3'd7 - (DrawY[8:1] - sprite_y[DrawX[4:2]]));
						end else begin
							chr_addr1 = {PPUCTRL[3], 12'h000} + (sprite_tile[DrawX[4:2]] * 5'd16) + (DrawY[8:1] - sprite_y[DrawX[4:2]]);
						end
					end
				1'b1 :
					begin
						if (sprite_attr[DrawX[4:2]][7]) begin
							chr_addr1 = {PPUCTRL[3], 12'h000} + (sprite_tile[DrawX[4:2]] * 5'd16) + (3'd7 - (DrawY[8:1] - sprite_y[DrawX[4:2]])) + 4'd8;
						end else begin
							chr_addr1 = {PPUCTRL[3], 12'h000} + (sprite_tile[DrawX[4:2]] * 5'd16) + (DrawY[8:1] - sprite_y[DrawX[4:2]]) + 4'd8;
						end
					end
			endcase
		end
	end
	
		/* VERTICAL MIRROR */
		
	if (vram_addr_tile) begin
	
		case (PPUCTRL[1:0])
			2'b00 :
				begin
					vram_addr1 = vram_addr_tile;
				end
			2'b01 :
				begin
					vram_addr1 = 11'h0400 + vram_addr_tile;
				end
			2'b10 :
				begin
					vram_addr1 = vram_addr_tile;
				end
			2'b11 :
				begin
					vram_addr1 = 11'h0400 + vram_addr_tile;
				end
		endcase
	
	end else if (vram_addr_attr) begin
		case (PPUCTRL[1:0])
			2'b00 :
				begin
					vram_addr1 = vram_addr_attr;
				end
			2'b01 :
				begin
					vram_addr1 = 11'h0400 + vram_addr_attr;
				end
			2'b10 :
				begin
					vram_addr1 = vram_addr_attr;
				end
			2'b11 :
				begin
					vram_addr1 = 11'h0400 + vram_addr_attr;
				end
		endcase
	end
end		

logic [3:0] sprite_size;
logic [7:0] sprite_y [8];		/* Y POSITION */
logic [7:0] sprite_tile [8];	/* [7:1]  IS TILE ID, [0] IS BANK */
logic [7:0] sprite_attr [8];	/* [7]: FLIP VERT [6]: FLIP HORZ [5]: PRIO (1 = BEHIND BACKGR) {1'b1, [1:0]}: PALETTE */
logic [7:0] sprite_x [8];		/* X POSITION */

logic [7:0] sprite_y_next [8];
logic [7:0] sprite_tile_next [8];
logic [7:0] sprite_attr_next [8];
logic [7:0] sprite_x_next [8];


logic sprite_add;
logic sprite_zero_rendered, sprite_zero_rendered_next;
logic [3:0] sprite_count, sprite_count_next;
always_ff @ (posedge vga_clk) begin	/* SPRITE EVALUATION */
	
	if (DrawX >= 768) begin
		PPUSTATUS[5] <= 0;
	end
	if (DrawX == 512) begin
		sprite_count <= sprite_count_next;
		sprite_y <= sprite_y_next;
		sprite_tile <= sprite_tile_next;
		sprite_attr <= sprite_attr_next;
		sprite_x <= sprite_x_next;
		sprite_zero_rendered <= sprite_zero_rendered_next;
	end
	if (DrawX == 513) begin
		sprite_count_next <= 0;
		sprite_zero_rendered_next <= 0;
	end
	if (0 <= DrawX && DrawX < 512 && DrawY < 512) begin
		case (DrawX[2:0])	
			3'h1 :
				begin
					if (y_pos_in_sprite <= sprite_size && oam_dout0 != 8'hFF) begin
						if (sprite_count_next < 8) begin
							if (chr_addr0 == 0) begin
								sprite_zero_rendered_next <= 1;
							end
							sprite_y_next[sprite_count_next] <= oam_dout0;
							sprite_add <= 1;
						end else begin
							PPUSTATUS[5] <= 1;
						end
					end
				end
			3'h3 :
				begin
					if (sprite_add) begin
						sprite_tile_next[sprite_count_next] <= oam_dout0;
					end
				end
			3'h5 :
				begin
					if (sprite_add) begin
						sprite_attr_next[sprite_count_next] <= oam_dout0;
					end
				end
			3'h7 :
				begin
					if (sprite_add) begin
						sprite_x_next[sprite_count_next] <= oam_dout0;
						sprite_count_next <= sprite_count_next + 1'd1;
						sprite_add <= 0;
					end
				end
		endcase
	end
end

logic[8:0] y_pos_in_sprite;
always_comb begin

	oam_addr0 = DrawX[8:1];
	y_pos_in_sprite = DrawY[8:1] - oam_dout0;
	
	if (PPUCTRL[5]) begin
		sprite_size = 4'b1111;
	end else begin
		sprite_size = 4'b0111;
	end
end



logic [7:0] palette_mem[32];

logic [2:0] paletteID_b, paletteID;
logic [2:0] paletteID_s [8];
logic [1:0] pixel;
logic [5:0] palette_mem_addr;

logic msb_b, lsb_b;
logic msb_s [8], lsb_s [8];

logic sprite_zhit, sprite_zhit_sync;

always_comb begin
	
	paletteID_s[0] = 0;
	paletteID_s[1] = 0;
	paletteID_s[2] = 0;
	paletteID_s[3] = 0;
	paletteID_s[4] = 0;
	paletteID_s[5] = 0;
	paletteID_s[6] = 0;
	paletteID_s[7] = 0;
	
	msb_b = curr_msTile[7-(x_final[3:1])];
	lsb_b = curr_lsTile[7-(x_final[3:1])];
	
	pixel = {msb_b, lsb_b};
	paletteID = paletteID_b;
	
	sprite_zhit = 0;
	
	msb_s[0] = 0;
	msb_s[1] = 0;
	msb_s[2] = 0;
	msb_s[3] = 0;
	msb_s[4] = 0;
	msb_s[5] = 0;
	msb_s[6] = 0;
	msb_s[7] = 0;
	
	lsb_s[0] = 0;
	lsb_s[1] = 0;
	lsb_s[2] = 0;
	lsb_s[3] = 0;
	lsb_s[4] = 0;
	lsb_s[5] = 0;
	lsb_s[6] = 0;
	lsb_s[7] = 0;
	
	case ({y_final[5], x_final[5]})
		2'b00 :
			begin
				paletteID_b = {1'b0, curr_paletteID[1:0]};
			end
		2'b01 :
			begin
				paletteID_b = {1'b0, curr_paletteID[3:2]};
			end
		2'b10 :
			begin
				paletteID_b = {1'b0, curr_paletteID[5:4]};
			end
		2'b11 :
			begin
				paletteID_b = {1'b0, curr_paletteID[7:6]};
			end
	endcase
	
	if (DrawX[8:1] - sprite_x[0] >= 0 && DrawX[8:1] - sprite_x[0] < 8 && sprite_count > 0) begin
			if (sprite_attr[0][6]) begin
				lsb_s[0] = sprite_ls[0][DrawX[8:1]-sprite_x[0]];
				msb_s[0] = sprite_ms[0][DrawX[8:1]-sprite_x[0]];
			end else begin
				lsb_s[0] = sprite_ls[0][7 - (DrawX[8:1]-sprite_x[0])];
				msb_s[0] = sprite_ms[0][7 - (DrawX[8:1]-sprite_x[0])];
			end
			paletteID_s[0] = {1'b1, sprite_attr[0][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[1] >= 0 && DrawX[8:1] - sprite_x[1] < 8 && sprite_count > 1) begin
			if (sprite_attr[1][6]) begin
				lsb_s[1] = sprite_ls[1][DrawX[8:1]-sprite_x[1]];
				msb_s[1] = sprite_ms[1][DrawX[8:1]-sprite_x[1]];
			end else begin
				lsb_s[1] = sprite_ls[1][7 - (DrawX[8:1]-sprite_x[1])];
				msb_s[1] = sprite_ms[1][7 - (DrawX[8:1]-sprite_x[1])];
			end
			paletteID_s[1] = {1'b1, sprite_attr[1][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[2] >= 0 && DrawX[8:1] - sprite_x[2] < 8 && sprite_count > 2) begin
			if (sprite_attr[2][6]) begin
				lsb_s[2] = sprite_ls[2][DrawX[8:1]-sprite_x[2]];
				msb_s[2] = sprite_ms[2][DrawX[8:1]-sprite_x[2]];
			end else begin
				lsb_s[2] = sprite_ls[2][7 - (DrawX[8:1]-sprite_x[2])];
				msb_s[2] = sprite_ms[2][7 - (DrawX[8:1]-sprite_x[2])];
			end
			paletteID_s[2] = {1'b1, sprite_attr[2][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[3] >= 0 && DrawX[8:1] - sprite_x[3] < 8 && sprite_count > 3) begin
			if (sprite_attr[3][6]) begin
				lsb_s[3] = sprite_ls[3][DrawX[8:1]-sprite_x[3]];
				msb_s[3] = sprite_ms[3][DrawX[8:1]-sprite_x[3]];
			end else begin
				lsb_s[3] = sprite_ls[3][7 - (DrawX[8:1]-sprite_x[3])];
				msb_s[3] = sprite_ms[3][7 - (DrawX[8:1]-sprite_x[3])];
			end
			paletteID_s[3] = {1'b1, sprite_attr[3][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[4] >= 0 && DrawX[8:1] - sprite_x[4] < 8 && sprite_count > 4) begin
			if (sprite_attr[4][6]) begin
				lsb_s[4] = sprite_ls[4][DrawX[8:1]-sprite_x[4]];
				msb_s[4] = sprite_ms[4][DrawX[8:1]-sprite_x[4]];
			end else begin
				lsb_s[4] = sprite_ls[4][7 - (DrawX[8:1]-sprite_x[4])];
				msb_s[4] = sprite_ms[4][7 - (DrawX[8:1]-sprite_x[4])];
			end
			paletteID_s[4] = {1'b1, sprite_attr[4][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[5] >= 0 && DrawX[8:1] - sprite_x[5] < 8 && sprite_count > 5) begin
			if (sprite_attr[5][6]) begin
				lsb_s[5] = sprite_ls[5][DrawX[8:1]-sprite_x[5]];
				msb_s[5] = sprite_ms[5][DrawX[8:1]-sprite_x[5]];
			end else begin
				lsb_s[5] = sprite_ls[5][7 - (DrawX[8:1]-sprite_x[5])];
				msb_s[5] = sprite_ms[5][7 - (DrawX[8:1]-sprite_x[5])];
			end
			paletteID_s[5] = {1'b1, sprite_attr[5][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[6] >= 0 && DrawX[8:1] - sprite_x[6] < 8 && sprite_count > 6) begin
			if (sprite_attr[6][6]) begin
				lsb_s[6] = sprite_ls[6][DrawX[8:1]-sprite_x[6]];
				msb_s[6] = sprite_ms[6][DrawX[8:1]-sprite_x[6]];
			end else begin
				lsb_s[6] = sprite_ls[6][7 - (DrawX[8:1]-sprite_x[6])];
				msb_s[6] = sprite_ms[6][7 - (DrawX[8:1]-sprite_x[6])];
			end
			paletteID_s[6] = {1'b1, sprite_attr[6][1:0]};
	end 
	if (DrawX[8:1] - sprite_x[7] >= 0 && DrawX[8:1] - sprite_x[7] < 8 && sprite_count > 7) begin
			if (sprite_attr[7][6]) begin
				lsb_s[7] = sprite_ls[7][DrawX[8:1]-sprite_x[7]];
				msb_s[7] = sprite_ms[7][DrawX[8:1]-sprite_x[7]];
			end else begin
				lsb_s[7] = sprite_ls[7][7 - (DrawX[8:1]-sprite_x[7])];
				msb_s[7] = sprite_ms[7][7 - (DrawX[8:1]-sprite_x[7])];
			end
			paletteID_s[7] = {1'b1, sprite_attr[7][1:0]};
	end

	if (DrawX[8:1] == 88 && DrawY[8:1] == 30) begin	/* SMB ZHIT */
		sprite_zhit = 1'b1;
	end
	
//	if (DrawX[8:1] == 2 && DrawY[8:1] == 64) begin	/* KUNG FU ZHIT, NMI TIMING WRONG THOUGH */
//		sprite_zhit = 1;
//	end
	
	if (msb_s[0] || lsb_s[0]) begin
		if (~(sprite_attr[0][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[0], lsb_s[0]};
			paletteID = paletteID_s[0];
		end 
		
	end else if (msb_s[1] || lsb_s[1]) begin
		if (~(sprite_attr[1][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[1], lsb_s[1]};
			paletteID = paletteID_s[1];
		end
	end else if (msb_s[2] || lsb_s[2]) begin
		if (~(sprite_attr[2][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[2], lsb_s[2]};
			paletteID = paletteID_s[2];
		end
	end else if (msb_s[3] || lsb_s[3]) begin
		if (~(sprite_attr[3][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[3], lsb_s[3]};
			paletteID = paletteID_s[3];
		end
	end else if (msb_s[4] || lsb_s[4]) begin
		if (~(sprite_attr[4][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[4], lsb_s[4]};
			paletteID = paletteID_s[4];
		end
	end else if (msb_s[5] || lsb_s[5]) begin
		if (~(sprite_attr[5][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[5], lsb_s[5]};
			paletteID = paletteID_s[5];
		end
	end else if (msb_s[6] || lsb_s[6]) begin
		if (~(sprite_attr[6][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[6], lsb_s[6]};
			paletteID = paletteID_s[6];
		end
	end else if (msb_s[7] || lsb_s[7]) begin
		if (~(sprite_attr[7][5] && (msb_b || lsb_b))) begin
			pixel = {msb_s[7], lsb_s[7]};
			paletteID = paletteID_s[7];
		end
	end
	
	if (pixel) begin	/* mirroring the fourth palette with the background color for transparency */
		palette_mem_addr = {paletteID, pixel};
	end else begin
		palette_mem_addr = 0;
	end
end

always_ff @ (posedge nes_clk) begin
	PPUSTATUS[6] <= sprite_zhit_sync;
end

always_ff @ (posedge vga_clk) begin
	if (sprite_zhit) begin
		sprite_zhit_sync <= 1;
	end else if (DrawY == 500) begin
		sprite_zhit_sync <= 0;
	end
	if (v_blank || h_blank) begin	/* hide glitch on first pixel */
		VGA_R <= 4'h0;
		VGA_G <= 4'h0;
		VGA_B <= 4'h0;
	end else begin
		VGA_R <= palettes[palette_mem[palette_mem_addr]][23:20];
		VGA_G <= palettes[palette_mem[palette_mem_addr]][15:12];
		VGA_B <= palettes[palette_mem[palette_mem_addr]][7:4];
	end 
end

logic v_blank, h_blank;
logic [9:0] DrawX, DrawY;

VGA_Controller VGA_Controller (
	.vga_clk (vga_clk),
	.Reset	(1'b0),     
	.hs		(VGA_HS),        
	.vs		(VGA_VS),       
	.v_blank	(v_blank),     
	.h_blank	(h_blank), 
	.DrawX	(DrawX),  
	.DrawY	(DrawY)
);

always_comb begin	
	if (v_blank && PPUCTRL[7]) begin
		nmi = 1;
	end else begin
		nmi = 0;
	end
end

logic [23:0] palettes [64];

always_comb begin
	palettes[0] = {8'd84, 8'd84, 8'd84};
	palettes[1] = {8'd0, 8'd30, 8'd116};
	palettes[2] = {8'd8, 8'd16, 8'd144};
	palettes[3] = {8'd48, 8'd0, 8'd136};
	palettes[4] = {8'd68, 8'd0, 8'd100};
	palettes[5] = {8'd92, 8'd0, 8'd48};
	palettes[6] = {8'd84, 8'd4, 8'd0};
	palettes[7] = {8'd60, 8'd24, 8'd0};
	palettes[8] = {8'd32, 8'd42, 8'd0};
	palettes[9] = {8'd8, 8'd58, 8'd0};
	palettes[10] = {8'd0, 8'd64, 8'd0};
	palettes[11] = {8'd0, 8'd60, 8'd0};
	palettes[12] = {8'd0, 8'd50, 8'd60};
	palettes[13] = {8'd0, 8'd0, 8'd0};
	palettes[14] = {8'd0, 8'd0, 8'd0};
	palettes[15] = {8'd0, 8'd0, 8'd0};
	
	palettes[16] = {8'd152, 8'd150, 8'd152};
	palettes[17] = {8'd8, 8'd76, 8'd196};
	palettes[18] = {8'd48, 8'd50, 8'd236};
	palettes[19] = {8'd92, 8'd30, 8'd228};
	palettes[20] = {8'd136, 8'd20, 8'd176};
	palettes[21] = {8'd160, 8'd20, 8'd100};
	palettes[22] = {8'd152, 8'd34, 8'd32};
	palettes[23] = {8'd120, 8'd60, 8'd0};
	palettes[24] = {8'd84, 8'd90, 8'd0};
	palettes[25] = {8'd40, 8'd114, 8'd0};
	palettes[26] = {8'd8, 8'd124, 8'd0};
	palettes[27] = {8'd0, 8'd118, 8'd40};
	palettes[28] = {8'd0, 8'd102, 8'd120};
	palettes[29] = {8'd0, 8'd0, 8'd0};
	palettes[30] = {8'd0, 8'd0, 8'd0};
	palettes[31] = {8'd0, 8'd0, 8'd0};
	
	palettes[32] = {8'd236, 8'd238, 8'd236};
	palettes[33] = {8'd76, 8'd154, 8'd236};
	palettes[34] = {8'd120, 8'd124, 8'd236};
	palettes[35] = {8'd176, 8'd98, 8'd236};
	palettes[36] = {8'd228, 8'd84, 8'd236};
	palettes[37] = {8'd236, 8'd88, 8'd180};
	palettes[38] = {8'd236, 8'd106, 8'd100};
	palettes[39] = {8'd212, 8'd136, 8'd32};
	palettes[40] = {8'd160, 8'd170, 8'd0};
	palettes[41] = {8'd116, 8'd196, 8'd0};
	palettes[42] = {8'd76, 8'd208, 8'd32};
	palettes[43] = {8'd56, 8'd204, 8'd108};
	palettes[44] = {8'd56, 8'd180, 8'd204};
	palettes[45] = {8'd60, 8'd60, 8'd60};
	palettes[46] = {8'd0, 8'd0, 8'd0};
	palettes[47] = {8'd0, 8'd0, 8'd0};
	
	palettes[48] = {8'd236, 8'd238, 8'd236};
	palettes[49] = {8'd168, 8'd204, 8'd236};
	palettes[50] = {8'd188, 8'd188, 8'd236};
	palettes[51] = {8'd212, 8'd178, 8'd236};
	palettes[52] = {8'd236, 8'd174, 8'd236};
	palettes[53] = {8'd236, 8'd174, 8'd212};
	palettes[54] = {8'd236, 8'd180, 8'd176};
	palettes[55] = {8'd228, 8'd196, 8'd144};
	palettes[56] = {8'd204, 8'd210, 8'd120};
	palettes[57] = {8'd180, 8'd222, 8'd120};
	palettes[58] = {8'd168, 8'd226, 8'd144};
	palettes[59] = {8'd152, 8'd226, 8'd180};
	palettes[60] = {8'd160, 8'd214, 8'd228};
	palettes[61] = {8'd160, 8'd162, 8'd160};
	palettes[62] = {8'd0, 8'd0, 8'd0};
	palettes[63] = {8'd0, 8'd0, 8'd0};
	
end


endmodule