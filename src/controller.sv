module controller (
	input clk,
	input [15:0] addr,
	input [31:0] keycode,
	input wren,
	output [7:0] dout
);

logic [7:0] data;

always_ff @ (posedge clk) begin
	if (16'h4016 <= addr && addr <= 16'h4017) begin
		if (wren) begin
			data <= controller_din << 1;
			dout <= {7'h00, controller_din[7]};
		end else begin
			dout <= {7'h00, data[7]};
			data <= data << 1;
		end
	end	
end

logic[7:0] controller_din;

always_comb begin
	controller_din = 0;
	
 /* https://wiki.nesdev.org/w/index.php?title=Controller_reading_code */
	if (keycode[31:24] == 8'h1A || keycode[23:16] == 8'h1A || keycode[15:8] == 8'h1A || keycode[7:0] == 8'h1A) /* W --> UP*/
	begin
		controller_din[3] = 1;
	end
	if (keycode[31:24] == 8'h16 || keycode[23:16] == 8'h16 || keycode[15:8] == 8'h16 || keycode[7:0] == 8'h16) /* S --> DOWN*/
	begin
		controller_din[2] = 1;
	end
	if (keycode[31:24] == 8'h04 || keycode[23:16] == 8'h04 || keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04) /* A --> LEFT*/
	begin
		controller_din[1] = 1;
	end
	if (keycode[31:24] == 8'h07 || keycode[23:16] == 8'h07 || keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07) /* D --> RIGHT*/
	begin
		controller_din[0] = 1;
	end
	if (keycode[31:24] == 8'h0F || keycode[23:16] == 8'h0F || keycode[15:8] == 8'h0F || keycode[7:0] == 8'h0F) /* L --> A */
	begin
		controller_din[7] = 1;
	end
	if (keycode[31:24] == 8'h0E || keycode[23:16] == 8'h0E || keycode[15:8] == 8'h0E || keycode[7:0] == 8'h0E) /* K --> B */
	begin
		controller_din[6] = 1;
	end
	if (keycode[31:24] == 8'h0A || keycode[23:16] == 8'h0A || keycode[15:8] == 8'h0A || keycode[7:0] == 8'h0A) /* G --> SELECT */
	begin
		controller_din[5] = 1;
	end
	if (keycode[31:24] == 8'h0B || keycode[23:16] == 8'h0B || keycode[15:8] == 8'h0B || keycode[7:0] == 8'h0B) /* H --> START */
	begin
		controller_din[4] = 1;
	end
end
	
endmodule