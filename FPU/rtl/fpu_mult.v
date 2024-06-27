`include "constraint.vh"
`include "mult_normalizer.v"

module fpu_mult #(
        parameter BIT_WIDTH = 32
    )(
        input wire                 clk,
        input wire                 rst_n,
        input wire                 tick_exec,
        input wire [5:0]           reg_params, // [is_inf, is_NaN, is_zero]
        input wire [BIT_WIDTH-1:0] reg1, reg2,
        output reg oveflow, underflow, invalid_op,  //control signals
        output reg instr_finished,
        output reg [BIT_WIDTH-1:0] reg_lo, reg_hi
    );

    parameter FSM_IDLE        = 3'd0, 
              FSM_NORM_AB     = 3'd1, 
              FSM_SKIP        = 3'd2, // when we have special cases : NaN, inf or zero. 
              FSM_NORM_RES1    = 3'd3,
              FSM_NORM_RES2    = 3'd4,
              FSM_ROUND       = 3'd5,
              FSM_EXCEPT      = 3'd6, //ToDo: implement overlow/underflow cases
              FSM_READY       = 3'd7;
    reg [3:0] state;

    reg  [47:0] prod;
    wire [47:0] prod_normalized;
    
    reg sign_out, ready;
    
    //exponential register intermediaries
    reg [9:0] exp_b, exp_a,exp_out, exp_unorm; // TODO: need to deal with overflow(10bit)
    wire[9:0] exp_norm;

    // mantissas
    wire [23:0] mant_a, mant_b;// 1.0 + mant == 24 bits
    reg  [23:0] mant_out; // 23 bits(mantissa)
    // expoent  -- with norm. offset (-126 <-> +127)
    wire [1:0] is_inf,is_NaN, is_zero, is_normalized;
    
    // wire [24:0] new_mantissa = prod[46:24];

    assign {is_inf, is_NaN, is_zero}= reg_params;
    assign mant_b = {1'b1,reg2[`FP_FRCT]}; 
    assign mant_a = {1'b1,reg1[`FP_FRCT]};
    assign is_normalized = 2'b11; // TODO: develop step to normalize prev. numbers


    //FSM Logical Implementation
    always @(posedge clk) begin
        if(~rst_n) begin 
            state<= FSM_IDLE;
            instr_finished<=0; 
        end else begin
            case(state)
                FSM_IDLE    :state <= ( ~tick_exec) ? FSM_IDLE : |is_normalized?  
                                                      FSM_SKIP : FSM_NORM_AB ;
                FSM_NORM_AB :state <= FSM_SKIP;
                FSM_SKIP    :state <= (|reg_params)  ?  FSM_READY: FSM_NORM_RES1; 
                // FSM_NORM_RES:state <= FSM_ROUND;  
                FSM_ROUND   :state <= FSM_READY;// TODO: how to think about this ???
                FSM_READY   :state <= FSM_IDLE ;
                default     :state <= state;
            endcase
        end
    end

    
    always @(posedge clk) begin
        case(state)
            FSM_IDLE: begin 
                //reset signals
                oveflow        <= 0;
                underflow      <= 0;
                invalid_op     <= 0;
                instr_finished <= 0; 
            end
            FSM_SKIP: begin
                casex ({|is_inf, |is_NaN, |is_zero})//ToDo: include is_one [or even better is_2multiple]..
                    
                    // [inf, const, zero]  x NaN => NaN
                    3'bx_1_x: {sign_out,exp_out, mant_out} = {1'b1, 8'hff, 23'b01}; 
                    
                    // [zero] x inf => NaN
                    3'b1_0_1: {sign_out,exp_out, mant_out} <= {1'b1, 8'hff, 23'b01};
                    
                    // [alpha != 0] x inf => inf
                    3'b1_0_0: {sign_out,exp_out, mant_out} <= {sign_out, 8'hff, 23'b0};

                    // [+/-alpha ] x +/-zero => +/-zero
                    3'b0_0_1: {sign_out,exp_out, mant_out} <= {32'b0};
                    
                    3'b0_0_0 : begin  // not special case - propagate signals
                        prod   <= mant_a * mant_b;
                        exp_unorm <= (reg1[`FP_EXP]) + (reg2[`FP_EXP])- 126;
                    end
                    default: begin end
                endcase
                sign_out  <= reg1[`FP_SIGN] ^ reg2[`FP_SIGN];
            
            end // FSM_SKIP
            FSM_NORM_RES1: begin
                // prod <= prod_normalized;
                // exp_unorm <=  exp_norm;
                if(prod[47] == 0) begin 
                    prod      <= prod << 1;
                    exp_unorm <= exp_unorm - 1;
                end else begin
                    state <= FSM_NORM_RES2;
                end
        
            end //FSM_NORM_RES
            
            FSM_NORM_RES2: begin
                if($signed(exp_out) < -126) begin
                    exp_out <= exp_out +1;
                    mant_out <= mant_out>>1;
                end else begin
                    state <= FSM_ROUND;
                end
                // if(prod_normalized[47] == 0) begin 
                //     prod      <= prod << 1;
                //     exp_unorm <= exp_unorm - 1;
                // end else begin 
                // // mant_out = prod_normalized[46:24];
                // // exp_out  <= exp_norm;
                // end
            end
            FSM_ROUND: begin  // need to check how is defined Fcsr first
                if(prod [23] == 1) begin 
                    prod[46:24] <= prod[46:24] + 1;
                end
            end
            FSM_READY: begin
                    reg_lo <= (|reg_params) ? {sign_out, exp_out[7:0] , mant_out[23:0]} :
                                              {sign_out, exp_unorm[7:0],  prod[46:24]};
                    instr_finished <=1;
            end
            default: begin 
            end
        endcase
    end


    // mult_normalizer m_norm(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .in_unorm(prod), 
    //     .out_norm(prod_normalized), 
    //     .in_exp(exp_unorm), //TODO: corrigir erro de impedancia do sinal out_exp normalizado
    //     .out_exp(exp_norm));

endmodule