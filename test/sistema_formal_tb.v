`include "sistema_speed.v"

// Testbench for formal verification
module test (
    input clk, active,
    input [7:0] target,
    input [95:0] payload,
    output reg terminado,
    output reg [23:0] hashOut,
    output reg [31:0] nonceOut
);

    //DUT instance, speed design is used with 2^7=128 submodules
    sistema_speed #(7) ss(clk, payload, active, target, terminado, nonceOut, hashOut);

    reg init=1;
    always @(posedge clk) begin
        // sistema_speed needs at least one clock cycle to load 
        // initial nonces to every submodule
        if (init) assume (!active);
        else assume(active);
        init <= 0;
        // Once its active, assume a target range
        if (active) begin
            assume (target > 8'h09 && target < 8'h10);
        end
        // When finished, assert valid hash results
        if (terminado) begin
            case (target) // assert hash result for every target case
                10: assert(hashOut[23:16] < 10 && hashOut[15:8] < 10);
                11: assert(hashOut[23:16] < 11 && hashOut[15:8] < 11);
                12: assert(hashOut[23:16] < 12 && hashOut[15:8] < 12);
                13: assert(hashOut[23:16] < 13 && hashOut[15:8] < 13);
                14: assert(hashOut[23:16] < 14 && hashOut[15:8] < 14);
                15: assert(hashOut[23:16] < 15 && hashOut[15:8] < 15);
                default: assert(0); // target shoudn't be out of this case range
            endcase
        end
    end
endmodule