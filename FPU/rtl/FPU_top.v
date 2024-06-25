`include "constraint.vh"
`include "fpu_mult.v"


module FPU_top #(
    parameter BIT_WIDTH  = 32,
    parameter OP_WIDTH = `SIZE_FUNCT5
) (
    input wire                 clk,
    input wire                 rst_n,
    input wire                 instr_received,
    input wire [OP_WIDTH-1 :0] op_mask,
    input wire [BIT_WIDTH-1:0] input_1, input_2,
    output reg unit_busy,
    output reg [BIT_WIDTH-1:0] reg_lo, reg_hi
);

    localparam FSM_IDLE  = 3'd0,
               FSM_OPER  = 3'd1, 
               FSM_READY = 3'd2,
               FSM_EXCEP = 3'd3;
    
    reg [4:0] fsm_state;
    reg tick_mult;
    reg instr_except;
    wire instr_finished;
    reg [31:0] fcsr; //aka register control status.
    reg [OP_WIDTH-1:0] actual_op;
    reg [BIT_WIDTH-1:0] reg1, reg2;

    reg mul_tick;

    wire[BIT_WIDTH-1:0]add_lo, add_hi,
                       sub_lo, sub_hi,
                       cmp_lo, cmp_hi,
                       mul_lo, mul_hi,
                       div_lo, div_hi,
                       min_lo, min_hi,
                       max_lo, max_hi;
    // wire instr_received;

    // signals for both numbers (rs1 and rs2)
    wire [1:0] exp_max = {&reg1[`FP_EXP],  &reg2[`FP_EXP]}; 
    wire [1:0] exp_min ={~|reg1[`FP_EXP], ~|reg2[`FP_EXP]}; //NOR bits
    wire [1:0] frct_min = {~|reg1[`FP_FRCT], ~|reg2[`FP_FRCT]};

    wire [1:0] is_inf  = exp_max && frct_min;
    wire [1:0] is_NaN  = exp_max && reg1[`FP_FRCT] != 0;
    wire [1:0] is_zero = exp_min;
    wire [5:0] reg_params = {is_inf, is_NaN, is_zero};
    
    // wire [BIT_WIDTH-1:0] mul_lo, mul_hi;

    // trigger to activate FPU
    // assign instr_received = (op_mask == `FADD ? 1'b1 :
    //                          op_mask == `FSUB ? 1'b1 :
    //                          op_mask == `FCMP ? 1'b1 :
    //                          op_mask == `FMUL ? 1'b1 :
    //                          op_mask == `FDIV ? 1'b1 :
    //                          op_mask == `FMIN ? 1'b1 :
    //                          op_mask == `FMAX ? 1'b1 : 1'b0);

    //FSM Logic
    always @(posedge clk ) begin
        case (fsm_state) 
            FSM_IDLE : fsm_state <= instr_received ? FSM_OPER  : FSM_IDLE;
            FSM_OPER : fsm_state <= instr_finished ? FSM_READY : FSM_OPER;
            FSM_READY: fsm_state <= FSM_IDLE; // ToDo: exception
            default:   fsm_state <= FSM_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(~rst_n) begin
            {reg_hi, reg_lo, tick_mult} <= 0;
            // instr_finished <=0;
            instr_except <=0;
            // instr_received <=0;
            fsm_state <= FSM_IDLE;

        end else begin
            case (fsm_state)
                FSM_IDLE : begin
                    unit_busy <=0;
                    // reg_lo    <= 0;
                    // reg_hi    <= 0;
                    actual_op <= op_mask;
                    reg1      <= input_1; //store value from input
                    reg2      <= input_2; 
                end

                FSM_OPER : begin
                    unit_busy <=1;
                    mul_tick <= 1'b1;

                end
                FSM_READY : begin
                    case (actual_op)
                        `FADD: {reg_lo,reg_hi} <= {add_lo, add_hi};
                        `FSUB: {reg_lo,reg_hi} <= {sub_lo, sub_hi};
                        `FCMP: {reg_lo,reg_hi} <= {cmp_lo, cmp_hi};
                        `FMUL: {reg_lo,reg_hi} <= {mul_lo, mul_hi};
                        `FDIV: {reg_lo,reg_hi} <= {div_lo, div_hi};
                        `FMIN: {reg_lo,reg_hi} <= {min_lo, min_hi};
                        `FMAX: {reg_lo,reg_hi} <= {max_lo, max_hi};
                        default: {reg_lo,reg_hi} <= 0;
                    endcase
                    actual_op <= {OP_WIDTH{1'b1}};//clean value from op
                    unit_busy <=0;
                    mul_tick <= 1'b0;
                end
                // FSM_EXCEP : begin end
                // default: begin end
            endcase
        end // rst
    end //always
    
    fpu_mult #(
        .BIT_WIDTH(BIT_WIDTH)
    )mult_module (
        .clk(clk),
        .rst_n(rst_n),
        .tick_exec(instr_received && (op_mask & `FMUL)),
        .instr_finished(instr_finished),
        .reg_params(reg_params),
        .reg1(reg1),
        .reg2(reg2),
        .reg_lo(mul_lo),
        .reg_hi(mul_hi)
    );

endmodule 