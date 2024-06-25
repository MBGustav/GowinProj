`include "FPU_top.v"
`timescale 1ps/1ps

module tb_FPU;

localparam CLK_PERIOD = 10;


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
    $dumpvars(0, exp_res);
end

initial begin
    #2// rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD) rst_n<=0;
    #(CLK_PERIOD*2) rst_n<=1;clk<=0;
    #1
    //1
    test_operation(`FMUL,
                32'h3f800000, //1.0
                32'h3f800000, //1.0
                32'h3f800000);//1.0

    //2
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

    //5
    test_operation(`FMUL,
                   32'h7f800000,    // inf
                   32'h00000000,    // 0.0
                   32'h7f800001);   // NaN

    //6
    test_operation(`FMUL,
                   32'hbe99999a,    // -0.3
                   32'h43fa2000,    // +500.25
                   32'hc316c000);   // -150.75
    //7
    test_operation(`FMUL,
                   32'h410e147b,    // 8.88
                   32'h42814af5,    // 64.6464
                   32'h440f83d8);   // 574.060032     

    rst_n<=1;
    #(CLK_PERIOD*100) $finish(2);
end

task test_operation;
    input  [4:0] opcode;
    input [31:0] r1, r2, exp_val;
    begin 

        total_test=total_test+1;
        // tick_exec<=1;
        $display("-------Check Nro %0d----------", total_test);
        
        instr_received<=1; 
        op_mask <= opcode;reg1 <= r1; reg2 <= r2;exp_res <= exp_val;  
        #(CLK_PERIOD) instr_received<=0;
        #(CLK_PERIOD*10) // wait for execution
        // instr_received<=0;

        $write("value 1: ");print_converted(r1);
        $write("Value 2: ");print_converted(r2);
        $write("Result : ");print_converted(reg_lo);
        $write("Expect : ");print_converted(exp_val);
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

        end else if (exp >= 8'h00 && exp < 8'hFF) begin
            // Normalized value
            fp_value = (1.0 + mant /2.0**23) * (2.0 ** ($signed({1'b0,exp}) - 127));
            $display("%+3.4f \t %b_%b_%b", fp_value, sign,exp,mant);
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

