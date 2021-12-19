	component NIOSIIe is
		port (
			clk_clk          : in    std_logic                     := 'X';             -- clk
			cpu_clk          : out   std_logic;                                        -- clk
			hex_wire_export  : out   std_logic_vector(23 downto 0);                    -- export
			key_wire_export  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			keycode_export   : out   std_logic_vector(31 downto 0);                    -- export
			led_wire_export  : out   std_logic_vector(9 downto 0);                     -- export
			nes_clk          : out   std_logic;                                        -- clk
			ppu_clk          : out   std_logic;                                        -- clk
			reset_reset_n    : in    std_logic                     := 'X';             -- reset_n
			sdram_clk_clk    : out   std_logic;                                        -- clk
			sdram_wire_addr  : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n : out   std_logic;                                        -- cas_n
			sdram_wire_cke   : out   std_logic;                                        -- cke
			sdram_wire_cs_n  : out   std_logic;                                        -- cs_n
			sdram_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n : out   std_logic;                                        -- ras_n
			sdram_wire_we_n  : out   std_logic;                                        -- we_n
			spi0_MISO        : in    std_logic                     := 'X';             -- MISO
			spi0_MOSI        : out   std_logic;                                        -- MOSI
			spi0_SCLK        : out   std_logic;                                        -- SCLK
			spi0_SS_n        : out   std_logic;                                        -- SS_n
			sw_wire_export   : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- export
			usb_gpx_export   : in    std_logic                     := 'X';             -- export
			usb_irq_export   : in    std_logic                     := 'X';             -- export
			usb_rst_export   : out   std_logic;                                        -- export
			vga_clk          : out   std_logic                                         -- clk
		);
	end component NIOSIIe;

	u0 : component NIOSIIe
		port map (
			clk_clk          => CONNECTED_TO_clk_clk,          --        clk.clk
			cpu_clk          => CONNECTED_TO_cpu_clk,          --        cpu.clk
			hex_wire_export  => CONNECTED_TO_hex_wire_export,  --   hex_wire.export
			key_wire_export  => CONNECTED_TO_key_wire_export,  --   key_wire.export
			keycode_export   => CONNECTED_TO_keycode_export,   --    keycode.export
			led_wire_export  => CONNECTED_TO_led_wire_export,  --   led_wire.export
			nes_clk          => CONNECTED_TO_nes_clk,          --        nes.clk
			ppu_clk          => CONNECTED_TO_ppu_clk,          --        ppu.clk
			reset_reset_n    => CONNECTED_TO_reset_reset_n,    --      reset.reset_n
			sdram_clk_clk    => CONNECTED_TO_sdram_clk_clk,    --  sdram_clk.clk
			sdram_wire_addr  => CONNECTED_TO_sdram_wire_addr,  -- sdram_wire.addr
			sdram_wire_ba    => CONNECTED_TO_sdram_wire_ba,    --           .ba
			sdram_wire_cas_n => CONNECTED_TO_sdram_wire_cas_n, --           .cas_n
			sdram_wire_cke   => CONNECTED_TO_sdram_wire_cke,   --           .cke
			sdram_wire_cs_n  => CONNECTED_TO_sdram_wire_cs_n,  --           .cs_n
			sdram_wire_dq    => CONNECTED_TO_sdram_wire_dq,    --           .dq
			sdram_wire_dqm   => CONNECTED_TO_sdram_wire_dqm,   --           .dqm
			sdram_wire_ras_n => CONNECTED_TO_sdram_wire_ras_n, --           .ras_n
			sdram_wire_we_n  => CONNECTED_TO_sdram_wire_we_n,  --           .we_n
			spi0_MISO        => CONNECTED_TO_spi0_MISO,        --       spi0.MISO
			spi0_MOSI        => CONNECTED_TO_spi0_MOSI,        --           .MOSI
			spi0_SCLK        => CONNECTED_TO_spi0_SCLK,        --           .SCLK
			spi0_SS_n        => CONNECTED_TO_spi0_SS_n,        --           .SS_n
			sw_wire_export   => CONNECTED_TO_sw_wire_export,   --    sw_wire.export
			usb_gpx_export   => CONNECTED_TO_usb_gpx_export,   --    usb_gpx.export
			usb_irq_export   => CONNECTED_TO_usb_irq_export,   --    usb_irq.export
			usb_rst_export   => CONNECTED_TO_usb_rst_export,   --    usb_rst.export
			vga_clk          => CONNECTED_TO_vga_clk           --        vga.clk
		);

