
module debug;

  /* Make a reset that pulses once. */
  reg reset = 0;
  initial begin
     # 17 reset = 1;
     # 11 reset = 0;
     # 29 reset = 1;
     # 11 reset = 0;
     # 200 $stop;
  end

  /* Make a regular pulsing clock. */
      reg clock = 0, exp_clk;
  always #10 clock = !clock;
  always #25 exp_clk = !exp_clk;

    wire val=0;
    
    naivePLL uut1 (
        .clk_in(clock),
        .clk_out(val)
    );

    sdpll uut2 (
        .i_clk(clock),
        .o_err(val)
    );

    initial
    $monitor("At time %t, value = %b",
            $time, val, exp_clk);

    initial begin 
        $dumpfile("dump.vcd");
        $dumpvars(0, uut);
    end
endmodule