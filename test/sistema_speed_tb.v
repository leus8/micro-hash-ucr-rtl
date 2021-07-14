`timescale 1 ns / 1 ps
`include "source/sistema_speed.v"

// Testbench
module test;
    reg clk, active;
    reg [7:0] target;
    reg [95:0] payload;
    wire terminado;
    wire [23:0] hashOut;
    wire [31:0] nonceOut;

    //DUT instance
    sistema_speed ss(clk, payload, active, target, terminado, nonceOut, hashOut);

    initial begin

        $dumpfile("sistema_speed.vcd"); $dumpvars;
        
        active <= 0;
        @(posedge clk);

        active <= 1;
        payload <= 96'h397d9f2f40ca9e6c6b1f3324;
        target <= 8'h0a;
        @(posedge clk);

        while (~terminado) @(posedge clk);

        $finish;

    end

    // clk generation
    initial clk <= 0;
    always #5 clk <= ~clk;
endmodule