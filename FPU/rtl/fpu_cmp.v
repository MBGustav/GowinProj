`include "constraint.vh"


module fpu_cmp #(
        parameter BIT_WIDTH = 32
    )(
        input wire                 clk,
        input wire                 rst_n,
        input wire                 instr_received,
        
        input wire [5:0]           reg_params, // [is_inf, is_NaN, is_zero]
        input wire [BIT_WIDTH-1:0] reg1, reg2,
        output reg instr_finished,
        output reg [BIT_WIDTH-1:0] reg_lo, reg_hi
    );

    wire [1:0] is_inf, is_NaN, is_zero;    

    wire [2:0] equal = {    reg1[`FP_SIGN] == reg2[`FP_SIGN], 
                            reg1[`FP_EXP]  == reg1[`FP_EXP], 
                            reg1[`FP_FRCT] == reg2[`FP_FRCT]};
    
    wire [2:0] bigger = {   reg1[`FP_SIGN] > reg2[`FP_SIGN], 
                            reg1[`FP_EXP]  > reg1[`FP_EXP], 
                            reg1[`FP_FRCT] > reg2[`FP_FRCT]};


    assign {is_inf, is_NaN, is_zero}= reg_params;

    always @(posedge clk ) begin
        if(~rst_n || ~instr_received) begin
            instr_finished <= 0;
        end else begin
            if(|is_NaN) begin //special case - left reg
                reg_lo <= reg1;
            end else begin
                casex (equal)
                3'b1xx :reg_lo <= bigger[0] ? reg1 : reg2;
                3'b01x :reg_lo <= bigger[1] ? reg1 : reg2;
                3'b001 :reg_lo <= bigger[2] ? reg1 : reg2;
                default:reg_lo <= reg1; //number is equal
                endcase

                instr_finished <= 1;
                // if(reg1[`FP_SIGN] != reg2[`FP_SIGN])    // Compare sign.
                //     reg_lo <=  (~reg1[`FP_SIGN] & reg2[`FP_SIGN]) ? reg1 : reg2;
                
                // else if(reg1[`FP_EXP] != reg1[`FP_EXP]) // Compare exp.
                //     reg_lo <= (reg1[`FP_EXP] > reg2[`FP_EXP])     ? reg1 : reg2;
                
                // else begin                              // Compare mantissa.
                //     reg_lo <= (reg1[`FP_FRCT] > reg2[`FP_FRCT])   ? reg1 : reg2;
                // end

            end // NaN
        end //rst
    end //always

endmodule