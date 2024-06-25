`include "mult_normalizer.v"
// `default_nettype none

module tb_mult_normalizer;
reg clk;
reg rst_n;
reg  [47:0] unorm;
wire [47:0] norm;

mult_normalizer DUT 
(
    .clk(clk),
    .rst_n(rst_n),
    .in_unorm(unorm),
    .out_norm(norm)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;


initial begin
    $dumpfile("tb_mult_normalizer.vcd");
    $dumpvars(0, tb_mult_normalizer);
    clk=0; rst_n<=0;
    #(CLK_PERIOD) rst_n<=1;

end


initial begin
    #2
    #(CLK_PERIOD) unorm <= 48'hffffffffffff;

    #(CLK_PERIOD) unorm <= 48'h1fffffffffff;

    #(CLK_PERIOD) unorm <= 48'h2fffffffffff;

    #(CLK_PERIOD) unorm <= 48'h0fffffffffff;
    
    #(CLK_PERIOD) unorm <= 48'h00ffffffffff;

    #(CLK_PERIOD) unorm <= 48'h004fffffffff;

    #(CLK_PERIOD) unorm <= 48'h000000000100;

    #(CLK_PERIOD) unorm <= 48'h000000000010;

    #(CLK_PERIOD) unorm <= 48'h000000000004;

    #(CLK_PERIOD) unorm <= 48'h000000000002;

    #(CLK_PERIOD) unorm <= 48'h000000000001;

    #(CLK_PERIOD) unorm <= 48'h000000000000;

    #(CLK_PERIOD*1000) $finish(2);
end

endmodule
