`include "src/hash_speed/hash_speed.v"
// Testbench
module test;
  reg a, b, c;
  wire s, carry;
  
  //DUT instance
  full_adder fa (a, b, c, s, carry);
  
  initial begin
    $dumpfile("hash_speed.vcd"); $dumpvars;
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