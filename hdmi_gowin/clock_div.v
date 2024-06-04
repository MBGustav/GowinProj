module clock_div #(
    parameter DIV = 5'd5
)
(
    input in_clk,
    input rst,
    output clk_out
);

    reg [2:0] aux_ctr = 0;
    always@(posedge in_clk) begin
        if(rst) aux_ctr <= 0;
        else begin
            if (aux_ctr >= DIV) aux_ctr <= 0;
            else aux_ctr <= aux_ctr + 1'b1;
        end
    end
    assign clk_out = (aux_ctr == DIV - 1);
endmodule