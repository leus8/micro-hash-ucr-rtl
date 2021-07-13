`timescale 1ns/100ps

`include "source/sistema_area.v"
// Testbench
module test;

    reg clk, active;
    reg [7:0] target;
    reg [95:0] payload;
    wire terminado;
    wire [23:0] hashOut;
    wire [31:0] nonceOut;
    integer i;

    //DUT instance
    sistema_area sa(clk, payload, active, target, terminado, nonceOut, hashOut);

    initial begin

        $dumpfile("sistema_area.vcd"); $dumpvars;

        for (i = 0; i < 32; i = i + 1) $dumpvars(0,sa.sa_hash.w[i]);
        for (i = 0; i < 3; i = i + 1) $dumpvars(0,sa.sa_hash.h[i]);
        
        active <= 0;
        payload <= 96'h397d9f2f40ca9e6c6b1f3324;
        target <= 8'h0a;
        @(posedge clk);

        active <= 1;
        @(posedge clk);

        while (~terminado) @(posedge clk);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $finish;

    end

    // clk generation
    initial clk <= 0;
    always #1 clk <= ~clk;


endmodule