`include "osu018_stdcells.v"
`include "source/sistema_speed.v"
`include "synthesis/sistema_speed_synth.rtlbb.v"
// Testbench
module test;
  reg a, b, c;
  wire s, carry;
  
  // DUT instance
  sistema_speed ss (a, b, c, s, carry);

  // Synthesized DUT instance
  sistema_speed_synth sss (a, b, c, s, carry);
  
  initial begin
    $dumpfile("sistema_speed_synth.vcd"); $dumpvars;
    {a, b, c} <= 3'b000;
    #1 {a, b, c} <= 3'b001;
    #1 {a, b, c} <= 3'b010;
    #1 {a, b, c} <= 3'b011;
    #1 {a, b, c} <= 3'b100;
    #1 {a, b, c} <= 3'b101;
    #1 {a, b, c} <= 3'b110;
    #1 {a, b, c} <= 3'b111;
    #1 {a, b, c} <= 3'b111;
  end
endmodule