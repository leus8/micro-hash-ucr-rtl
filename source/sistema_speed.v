// Design
module half_adder (a, b, s, carry);
  input  a, b;
  output s, carry;
 
  assign s   = a ^ b;
  assign carry = a & b;
endmodule 

module sistema_speed (a, b, c, s, carry);
  input  a, b, c;
  output s, carry;
 
  half_adder ha0 (a, b, s0, c0);
  half_adder ha1 (s0, c, s, c1);
  assign carry = c0 || c1;
endmodule