


// IEEE Float-point standard for 32 bits
`define FP_SIGN  31          
`define FP_EXP   30:23 
`define FP_FRCT  22:0      //also known as mantissa, significant or fraction

//  Floating-point control and status register(read RISCV manual cpt.8)
`define FRM 7:5         //Rounding Mode
`define RNE 3'b000      //Round to Nearest, ties to Even
`define RTZ 3'b001      //Round towards Zero
`define RDN 3'b010      //Round Down (towards −∞)
`define RUP 3'b011      //Round Up (towards +∞)
`define RMM 3'b100      //Round to Nearest, ties to Max Magnitude

// Intruction Composition
`define INSTR_FUNCT5 31:27 
`define INSTR_FMT    26:25
`define INSTR_RS2    24:20
`define INSTR_RS1    19:15
`define INSTR_RM     14:12
`define INSTR_RD     11:7
`define INSTR_OPCODE  6:0


// Floating Point Operation Instrcutions funct5 definition
`define SIZE_FUNCT5 5
`define FADD 5'b00001
`define FSUB 5'b00010
`define FCMP 5'b00011
`define FMUL 5'b00100
`define FDIV 5'b00101
`define FMIN 5'b00110
`define FMAX 5'b00111



