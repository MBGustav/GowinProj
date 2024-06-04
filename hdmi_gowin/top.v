// top: Generates a test picture on HDMI output.

module top(
  input clk,
  input reset_button,

  // HDMI output pins: ch0, ch1, ch2 and clock
  output [3:0] hdmi_tx_n,
  output [3:0] hdmi_tx_p
);

  wire hdmi_clk;                   // 25.2MHz. (HDMI pixel clock for 640x480@60Hz would ideally be 25.175MHz)
  wire hdmi_clk_5x;                // 126MHz. 5x pixel clock for 10:1 DDR serialization
  wire hdmi_clk_lock;              // true when PLL lock has been established

  // Produce a 5x HDMI clock for pixel serialization (Gowin FPGA Designer/Sipeed Tang Nano 4K specific module)
  // CLKOUT frequency=(FCLKIN*(FBDIV_SEL+1))/(IDIV_SEL+1) = 27*(13+1)/(2+1) = 126 MHz
rPLL #( // For GW1NR-9 C6/I5
  .FCLKIN("27"),
  .IDIV_SEL(0), // -> PFD = 9 MHz (range: 3-400 MHz)
  .FBDIV_SEL(4) // -> CLKOUT = 126 MHz (range: 3.125-500 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
    .CLKIN(clk),
    .CLKOUT(hdmi_clk_5x),
    .LOCK(hdmi_clk_lock)
);

  wire reset = ~hdmi_clk_lock | ~reset_button;
  wire signed [32:0] x, y;        // horizontal and vertical screen position (signed), -4096 - +4095
  wire [2:0] hve_sync;            // pack the image sync signals to one vector: { display enable, vsync, hsync}
  assign hdmi_clk = clk;

  // Generate a display sync signal on top of the HDMI pixel clock.
  display_signal #(               // 640x480  800x600 1280x720 1920x1080
      .H_RESOLUTION(640),         //     640      800     1280      1920
      .V_RESOLUTION(480),         //     480      600      720      1080
      .H_FRONT_PORCH(16),         //      16       40      110        88
      .H_SYNC(96),                //      96      128       40        44
      .H_BACK_PORCH(48),          //      48       88      220       148
      .V_FRONT_PORCH(10),         //      10        1        5         4
      .V_SYNC(2),                 //       2        4        5         5
      .V_BACK_PORCH(33),          //      33       23       20        36
      .H_SYNC_POLARITY(1'b0),     //       0        1        1         1
      .V_SYNC_POLARITY(1'b0)      //       0        1        1         1
  )ds(
    .i_pixel_clk(hdmi_clk),
    .i_reset(reset),
    .o_hvesync(hve_sync),
    .o_frame_start(),
    .o_x(x),
    .o_y(y)
  );

    wire [23:0] rgb_channel; 
    wire  [7:0] memo_output;
    wire [8:0] vaddr; 
    wire [5:0] row, col;       
    
    // downsampling:
    assign row = (y>>5); // 32 pixels
    assign col = (x>>5); // 32 pixels 
    assign vaddr = col + (row<<4) + (row<<2); // addr = col + row x 20
    
  //Here we define an 8 bit image 20 x 20
  
  test_RAM memo 
  ( 
    .i_clk(hdmi_clk), 
    .mem_address( vaddr ),
    .out_data(memo_output)
  );
  
  //replicate bits to fill..
  wire [7:0] r = {memo_output[5:4], 6'b1};
  wire [7:0] g = {memo_output[3:2], 6'b1};
  wire [7:0] b = {memo_output[1:0], 6'b1};
  assign rgb_channel = {r,g,b};


  // Produce HDMI output
  hdmi hdmi_out(
    .reset(reset),
    .hdmi_clk(hdmi_clk),
    .hdmi_clk_5x(hdmi_clk_5x),
    .hve_sync(hve_sync),
    .rgb(rgb_channel),
    .hdmi_tx_n(hdmi_tx_n),
    .hdmi_tx_p(hdmi_tx_p));

endmodule