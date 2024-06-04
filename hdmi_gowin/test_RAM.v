module test_RAM (
    input i_clk, 
    input [8:0] mem_address,
    output reg [7:0] out_data
);
    reg [7:0] Memory [0:200]; // a Memory of BITS_SIZE bits with  WIDTH
    // Define the colors for the squares
    parameter BLACK   = 8'b00000000;
    parameter WHITE   = 8'b11111111;
    parameter RED     = 8'b11100000;
    parameter GREEN   = 8'b00011100;
    parameter BLUE    = 8'b00000011;
    parameter YELLOW  = 8'b11111100;
    parameter MAGENTA = 8'b11100011;
    parameter CYAN    = 8'b00011111;
    parameter ORANGE  = 8'b11110000;
    
    integer i, j;
    
    // Initialize memory with colors for a 20x20 RGB squares
   initial begin  
       for (i = 0; i < 20; i = i + 1) begin
           for (j = 0; j < 20; j = j + 1) begin
               case ({i, j})
                   8'b0000_0000: Memory[i*20+j] = BLACK;
                   8'b0000_0001: Memory[i*20+j] = WHITE;
                   8'b0000_0010: Memory[i*20+j] = RED;
                   8'b0000_0011: Memory[i*20+j] = GREEN;
                   8'b0000_0100: Memory[i*20+j] = BLUE;
                   8'b0000_0101: Memory[i*20+j] = YELLOW;
                   8'b0000_0110: Memory[i*20+j] = MAGENTA;
                   8'b0000_0111: Memory[i*20+j] = CYAN;
                   8'b00001000: Memory[i*20+j] = ORANGE;
                   default: Memory[i*20+j] = WHITE; // Default to black
               endcase
           end
       end
   end

//    integer idx;
//    initial begin
//        for (i=0; i<40; i=i+1) 
//            $display("result = %b", Memory[i]);
//    end
    // initial $readmemb("mario8bit.txt", Memory);
    // Sync output with clock
    // always @(posedge i_clk) begin
    //     out_data <= Memory[mem_address];
    // end

    wire bound = (mem_address < 511);
    assign out_data = GREEN;


endmodule

