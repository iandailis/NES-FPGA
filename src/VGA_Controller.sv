//-------------------------------------------------------------------------
//      VGA controller                                                   --
//      Kyle Kloepper                                                    --
//      4-05-2005                                                        --
//                                                                       --
//      Modified by Stephen Kempf 04-08-2005                             --
//                                10-05-2006                             --
//                                03-12-2007                             --
//      Translated by Joe Meng    07-07-2013                             --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      Used standard 640x480 vga found at epanorama                     --
//                                                                       --
//      reference: http://www.xilinx.com/bvdocs/userguides/ug130.pdf     --
//                 http://www.epanorama.net/documents/pc/vga_timing.html --
//                                                                       --
//      note: The standard is changed slightly because of 25 mhz instead --
//            of 25.175 mhz pixel clock. Refresh rate drops slightly.    --
//                                                                       --
//      For use with ECE 385 Lab 7 and Final Project                     --
//      ECE Department @ UIUC                                            --
//-------------------------------------------------------------------------


/* EDITED TO USE MORE ACCURATE PLL CLOCK */
/* REMOVED SYNC COMPLETELY */
/* SPLIT BLANK INTO V_BLANK AND H_BLANK */
/* MADE BLANK ACTIVE HIGH */

module  VGA_Controller ( input        vga_clk,   // 25.175 MHz Clock
                                      Reset,     // reset signal
                         output logic hs,        // Horizontal sync pulse.  Active low
								              vs,        // Vertical sync pulse.  Active low
												  v_blank,     // Blanking interval indicator.  Active high.
												  h_blank,
												 
								 output [9:0] DrawX,     // horizontal coordinate
								              DrawY );   // vertical coordinate
    
    // 800 horizontal pixels indexed 0 to 799
    // 525 vertical pixels indexed 0 to 524
    parameter [9:0] hpixels = 10'b1100011111;
    parameter [9:0] vlines = 10'b1000001100;
	 
	 // horizontal pixel and vertical line counters
    logic [9:0] hc, vc;
	 
	//Runs the horizontal counter  when it resets vertical counter is incremented
   always_ff @ (posedge vga_clk or posedge Reset )
	begin: counter_proc
		  if ( Reset ) 
			begin 
				 hc <= 10'b0000000000;
				 vc <= 10'b0000000000;
			end
				
		  else 
			 if ( hc == hpixels )  //If hc has reached the end of pixel count
			  begin 
					hc <= 10'b0000000000;
					if ( vc == vlines )   //if vc has reached end of line count
						 vc <= 10'b0000000000;
					else 
						 vc <= (vc + 1'd1);
			  end
			 else 
				  hc <= (hc + 1'd1);  //no statement about vc, implied vc <= vc;
	 end 
   
    assign DrawX = hc;
    assign DrawY = vc;
   
	 //horizontal sync pulse is 96 pixels long at pixels 656-752
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge vga_clk )
    begin : hsync_proc
        if ( Reset ) 
            hs <= 1'b0;
        else  
            if ((((hc + 1) >= 10'b1010010000) & ((hc + 1) < 10'b1011110000))) 
                hs <= 1'b0;
            else 
				    hs <= 1'b1;
    end
	 
    //vertical sync pulse is 2 lines(800 pixels) long at line 490-491
    //(signal is registered to ensure clean output waveform)
    always_ff @ (posedge Reset or posedge vga_clk )
    begin : vsync_proc
        if ( Reset ) 
           vs <= 1'b0;
        else 
            if ( ((vc + 1) == 9'b111101010) | ((vc + 1) == 9'b111101011) ) 
			       vs <= 1'b0;
            else 
			       vs <= 1'b1;
    end
       
    //only display pixels between horizontal 0-639 and vertical 0-479 (640x480)
    //(This signal is registered within the DAC chip, so we can leave it as pure combinational logic here)    
    always_comb
    begin 
        if ( (hc >= 10'd512)) 
            h_blank = 1'b1;
        else 
            h_blank = 1'b0;
			
			if (vc >= 10'd480) begin
				v_blank = 1'b1;
			end else begin
				v_blank = 1'b0;
			end
    end 
    

endmodule
