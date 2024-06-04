// display_signal module converts a pixel clock into a hsync+vsync+disp_enable+x+y structure.
module display_signal #(parameter
  H_RESOLUTION    = 640,
  V_RESOLUTION    = 480,
  H_FRONT_PORCH   = 16,
  H_SYNC          = 96,
  H_BACK_PORCH    = 48,
  V_FRONT_PORCH   = 10,
  V_SYNC          = 2,
  V_BACK_PORCH    = 33,
  H_SYNC_POLARITY = 1'b0,   // 0: neg, 1: pos
  V_SYNC_POLARITY = 1'b0    // 0: neg, 1: pos
)
(
  input  i_pixel_clk,
  input  i_reset,               // reset is active high
  output [2:0] o_hvesync,       // { display_enable, vsync, hsync} . hsync is active at desired H_SYNC_POLARITY and vsync is active at desired V_SYNC_POLARITY, display_enable is active high, low in blanking
  output o_frame_start,         // counts high for one pixel clock of a frame (inside blanking)
  output reg signed [32:0] o_x, // screen x coordinate (negative in blanking, nonneg in visible picture area)
  output reg signed [32:0] o_y  // screen y coordinate (negative in blanking, nonneg in visible picture area)
);

  // A horizontal scanline consists of sequence of regions: front porch -> sync -> back porch -> display visible
  localparam signed H_START       = -H_BACK_PORCH - H_SYNC - H_FRONT_PORCH;
  localparam signed HSYNC_START   = -H_BACK_PORCH - H_SYNC;
  localparam signed HSYNC_END     = -H_BACK_PORCH;
  localparam signed HACTIVE_START = 0;
  localparam signed HACTIVE_END   = H_RESOLUTION - 1;
  // Vertical image frame has the same structure, but counts scanlines instead of pixel clocks.
  localparam signed V_START       = -V_BACK_PORCH - V_SYNC - V_FRONT_PORCH;
  localparam signed VSYNC_START   = -V_BACK_PORCH - V_SYNC;
  localparam signed VSYNC_END     = -V_BACK_PORCH;
  localparam signed VACTIVE_START = 0;
  localparam signed VACTIVE_END   = V_RESOLUTION - 1;

  // generate display_enable, vsync and hsync signals with desired polarity
    wire v_mid_sinc = (o_y >= VSYNC_START && o_y < VSYNC_END);
    wire h_mid_sinc = (o_x >= HSYNC_START && o_x < HSYNC_END);

    assign o_hvesync = {o_x >= 0 && o_y >= 0,
                       V_SYNC_POLARITY ^ (o_y >= VSYNC_START && o_y < VSYNC_END),
                       H_SYNC_POLARITY ^ (o_x >= HSYNC_START && o_x < HSYNC_END)};

  // counts high for one pixel clock at the beginning of a new frame (inside hblank and vblank)
  assign o_frame_start = (o_y == V_START && o_x == H_START);

  // count frame x & y pixel coordinates. Values < 0 denote pixels inside blanking/vsync area,
  // values >= 0 denote visible image. (x,y)==(0,0) is top left.
  always @(posedge i_pixel_clk) begin
    if (i_reset) begin
      o_x <= H_START;
      o_y <= V_START;
    end else begin
      if (o_x == HACTIVE_END) begin
        o_x <= H_START;
        o_y <= o_y == VACTIVE_END ? V_START : o_y + 1'b1;
      end else
        o_x <= o_x + 1'b1;
    end
  end
endmodule