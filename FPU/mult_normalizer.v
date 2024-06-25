
module mult_normalizer #(
    parameter SIZE_MANTISSA_2X =  48,
    parameter SIZE_EXP =  8
)(
    input wire                  rst_n,
    input wire                  clk,
    input wire  [SIZE_EXP-1:0]         in_exp, 
    input wire  [SIZE_MANTISSA_2X-1:0] in_unorm, 
    output reg  [SIZE_EXP-1:0]         out_exp, 
    output wire  [SIZE_MANTISSA_2X-1:0] out_norm,
    output wire [32:0]                 dbg_counter
);

    integer i;

    
    reg [32:0] counter; // size of total size shift
    reg [SIZE_MANTISSA_2X-1:0] norm;

    assign dbg_counter = counter;
    assign out_norm = norm;
    

    // counter acc logic
    always @(posedge clk) begin 
        if(~rst_n) begin
            counter <= 0;
            norm <= 10;
        end else begin
           casex (in_unorm)
            48'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 0;
            48'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 1;
            48'b001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 2;
            48'b0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 3;
            48'b0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 4;
            48'b0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 5;
            48'b0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 6;
            48'b0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 7;
            48'b0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 8;
            48'b0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 9;
            48'b0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 10;
            48'b0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 11;
            48'b0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 12;
            48'b0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 13;
            48'b0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 14;
            48'b0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 15;
            48'b0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 16;
            48'b0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 17;
            48'b0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 18;
            48'b0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 19;
            48'b0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 20;
            48'b0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 21;
            48'b0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 22;
            48'b0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 23;
            48'b0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 24;
            48'b0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 25;
            48'b0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 26;
            48'b0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx_xxxx: counter = 27;
            48'b0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx_xxxx: counter = 28;
            48'b0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx_xxxx: counter = 29;
            48'b0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx_xxxx: counter = 30;
            48'b0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx_xxxx: counter = 31;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx_xxxx: counter = 32;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx_xxxx: counter = 33;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx_xxxx: counter = 34;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx_xxxx: counter = 35;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx_xxxx: counter = 36;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx_xxxx: counter = 37;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx_xxxx: counter = 38;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx_xxxx: counter = 39;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx_xxxx: counter = 40;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx_xxxx: counter = 41;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x_xxxx: counter = 42;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_xxxx: counter = 43;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1xxx: counter = 44;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01xx: counter = 45;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001x: counter = 46;
            48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001: counter = 47;
            default: counter <= 0;
        endcase
        norm <= (in_unorm << counter);
        out_exp <= in_exp + (counter-1);
        end // if-rst
    end

    

endmodule