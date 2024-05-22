module top (
    input clk,
    // OUTPUTS - HDMI
    // output       tmds_clk_p, 
    // output       tmds_clk_n,
    // output [2:0] tmds_data_p,
    // output [2:0] tmds_data_n,
    // OUTPUTS - LEDS
    output [5:0] led
);

// ###### CONFIGURACAO DE CLOCK #######
// https://juj.github.io/gowin_fpga_code_generators/pll_calculator.html
wire clk_90Mhz, clk_9Mhz;
rPLL pll(
	    .CLKOUT(clk_90Mhz),  // 90MHz
		.CLKIN(clk),
		.CLKOUTD(clk_9Mhz),  //  9MHz
		.CLKFB(GND),
		.RESET_P(GND),
		.RESET(GND),
		.FBDSEL({GND,GND,GND,GND,GND,GND}),
		.IDSEL({GND,GND,GND,GND,GND,GND}),
		.ODSEL({GND,GND,GND,GND,GND,GND}),
		.DUTYDA({GND,GND,GND,GND}),
		.PSDA({GND,GND,GND,GND}),
		.FDLY({GND,GND,GND,GND})
	);
	defparam pll.DEVICE = `PLL_DEVICE;
	defparam pll.FCLKIN = `PLL_FCLKIN;
	defparam pll.FBDIV_SEL = `PLL_FBDIV_SEL_LCD;
	defparam pll.IDIV_SEL =  `PLL_IDIV_SEL_LCD;
	defparam pll.ODIV_SEL =  8;           // 90MHz sys clock
	defparam pll.CLKFB_SEL="internal";
	defparam pll.CLKOUTD3_SRC="CLKOUT";
	defparam pll.CLKOUTD_BYPASS="false";
	defparam pll.CLKOUTD_SRC="CLKOUT";
	defparam pll.CLKOUTP_BYPASS="false";
	defparam pll.CLKOUTP_DLY_STEP=0;
	defparam pll.CLKOUTP_FT_DIR=1'b1;
	defparam pll.CLKOUT_BYPASS="false";
	defparam pll.CLKOUT_DLY_STEP=0;
	defparam pll.CLKOUT_FT_DIR=1'b1;
	defparam pll.DUTYDA_SEL="1000";
	defparam pll.DYN_DA_EN="false";
	defparam pll.DYN_FBDIV_SEL="false";
	defparam pll.DYN_IDIV_SEL="false";
	defparam pll.DYN_ODIV_SEL="false";
	defparam pll.DYN_SDIV_SEL=10;      // 90MHz / 10 = 9MHz --- pixel clock
	defparam pll.PSDA_SEL="0000";

// ####################################

	localparam WAIT_TIME = 13500000;

	reg [31:0] counter1;
	reg [31:0] counter2;
	reg [2:0] group_led1 = 0;
	reg [2:0] group_led2 = 0;

	always @(posedge clk_9Mhz) begin
		counter1 <= counter1 +1;
		if(counter1 == WAIT_TIME)begin
			counter1 <= 0;
			group_led1 = group_led1 + 1;
		end
	end

	always @(posedge clk_90Mhz) begin
		counter2 <= counter2 +1;
		if(counter2 == WAIT_TIME)begin
			counter2 <= 0;
			group_led2 = group_led2 + 1;
		end
	end

	assign led = {group_led1, group_led2};

endmodule