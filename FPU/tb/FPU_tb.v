`include "FPU_top.v"
`timescale 1ps/1ps

module tb_FPU;

localparam CLK_PERIOD = 10;

`define INFO;
`define WARN;



reg clk = 0;
reg rst_n  =0;
reg [4:0]  op_mask =0;
reg [31:0] reg1 =0;
reg [31:0] reg2 =0;
reg [31:0] exp_res;

reg instr_received;
wire[31:0] reg_lo;
wire[31:0] reg_hi;

integer total_test =0;


always #(CLK_PERIOD/2) clk=~clk;

initial begin
    clk<=0;instr_received <=0;
    $dumpfile("tb_.vcd");
    $dumpvars(0, tb_FPU);
end

initial begin
    #2// rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD) rst_n<=0;
    #(CLK_PERIOD*2) rst_n<=1;clk<=0;
    #1
    //[special case] -1
    test_operation(`FMUL,
                    32'h3f800000, //1.0
                    32'h3f800000, //1.0
                    32'h3f800000);//1.0

    //[special case] 2
    test_operation(`FMUL,
                    32'h3f828f5c,
                    32'h3f800000,
                    32'h3f828f5c);
    //3
    test_operation(`FMUL,
                    32'h3f828f5c,    //1.02
                    32'h3f800000,    //1.00[s=0,exp=127,m=0]
                    32'h3f828f5c);   //1.02
    //4
    test_operation(`FMUL,
                    32'h7f800000,    // inf
                    32'h3fc00000,    // 1.5
                    32'h7f800000);   // inf
    // 5 - NaN
    test_operation(`FMUL,
                    32'h7f800100,    // NaN
                    32'h3fc00000,    // 1.5
                    32'h7f800100);   // NaN

    //6
    test_operation(`FMUL,
                    32'h7f800000,    // inf
                    32'h00000000,    // 0.0
                    32'h7f800001);   // NaN

    //6
    test_operation(`FMUL,
                    32'hbf000000,    // -0.5
                    32'h43fa2000,    // +500.25
                    32'hc37a2000);   // -250.125
    //7
    test_operation(`FMUL,
                    32'h410e147b,    // 8.88
                    32'h42814af5,    // 64.6464
                    32'h440f83d8);   // 574.060032     
    
    //8 - some random numbers
    test_operation(`FMUL,
                    32'h3e05c28f,    // 0.130625
                    32'h447a0000,    // 1000.00
                    32'h4302999A);   // 130.625     

    test_operation(`FMUL,
                32'h3E3FE28F,    // 0.18738769
                32'h447A0000,    // 1000.00
                32'h433B6340);   // 187.3877

    test_operation(`FMUL,
                32'h3E3FE28F,    // 0.18738769
                32'h447A0000,    // 1000.00
                32'h433B6340);   // 187.3877

    test_operation(`FMUL,
                32'h291AA753,    // 3.434E-14
                32'h628810E3,    // 1.254987E+21
                32'h4C24662F);   // 43096252.0

    test_operation(`FMUL,
                32'h29000001,    // 2.8421713E-14
                32'h62800001,    // 1.1805918E+21
                32'h4C000002);   // 33554440.0
    rst_n<=1;
    #(CLK_PERIOD*100) $finish(2);
end

task test_operation;
    input  [4:0] opcode;
    input [31:0] r1, r2, exp_val;
    begin 
        
        total_test=total_test+1;
        instr_received<=1; 
        op_mask <= opcode;reg1 <= r1; reg2 <= r2;exp_res <= exp_val;  
        #(CLK_PERIOD) instr_received<=0;
        #(CLK_PERIOD*10) // wait for execution
        // instr_received<=0;

        // `ifdef INFO
        $display("[INFO] -------Check - %0d----------", total_test);
        $write  ("[INFO] value 1: ");print_converted(r1);
        $write  ("[INFO] Value 2: ");print_converted(r2);
        // `else
        $write  ("[INFO] Result : ");print_converted(reg_lo);
        $write  ("[INFO] Expect : ");print_converted(exp_val);
        // `endif
    end
endtask

task print_converted;
    input [31:0] float_val;

    reg [22:0] mant;
    reg  [7:0]  exp;
    reg        sign;
    real fp_value;

    begin
        sign = float_val[31];
        exp  = float_val[30:23];
        mant = float_val[22:0];

        // Calculate the floating-point value
        if (exp == 8'h00 && mant == 23'h00) begin
            // Special value: +-0
            fp_value = (sign == 1'b1) ? -0.0 : 0.0;
            $display("%+3.4f", fp_value);
        end else if (exp == 8'hFF) begin
            // Special value (NaN or Inf)
            if (mant == 23'h000000) $display("Inf (Infinity)");
            else                    $display("NaN (Not a Number)");

        end else if (exp > 8'h00 && exp < 8'hFF) begin
            // Normalized value
            fp_value = (1.0 + mant /2.0**23) * (2.0 ** ($signed({1'b0,exp}) - 127));
            // $display("%+3.4f \t %h", fp_value, {sign,exp,mant});
            if(fp_value > 10000.0 || fp_value < 0.002)     $display("%+5.4e \t %b_%b_%b", fp_value, sign,exp,mant);
            else $display("%+5.4f \t %b_%b_%b", fp_value, sign,exp,mant); 
        end
    end
endtask


FPU_top DUT (
    .clk(clk),
    .rst_n(rst_n),
    .op_mask(op_mask),
    .instr_received(instr_received),
    .input_1(reg1),
    .input_2(reg2),
    .reg_lo(reg_lo), 
    .reg_hi(reg_hi));


endmodule

