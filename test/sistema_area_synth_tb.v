`include "osu018_stdcells.v"
`include "source/sistema_area.v"
`include "synthesis/sistema_area_synth.rtlnopwr.v"

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

    // Synthetized DUT instance
    sistema_area_synth sas(clk, payload, active, target, terminado, nonceOut, hashOut);

    initial begin

        $dumpfile("sistema_area_synth.vcd"); $dumpvars;

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
    always #1 clk <= ~clk;


endmodule