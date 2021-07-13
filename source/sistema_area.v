/* sistema_area.v
* This file contains all modules related to the
* rtl design of micro-ucr-hash optimized for area
*/


/*
* Module concatenador
* This module takes a payload (12 bytes) and a nonce (4 bytes) and
* concatenates them into a bloque (16 bytes)
*/
module concatenador (clk, payload, active, nonce, bloque);

    input clk, active;
    input [95:0] payload;
    input [31:0] nonce;
    output reg [127:0] bloque;

    always @(posedge clk) begin

        if (~active) begin
            bloque <= 0;
        end
        else begin
            bloque <= {payload,nonce};
        end
    end

endmodule


/*
* Module nextNonce
* nextNonce calculates the next nonce
* based on the current nonce.
* On the back-end is a binary counter.
*/
module nextNonce (clk, active, nonce);

    input clk, active;
    output reg [31:0] nonce;

    always @(posedge clk) begin
        if (~active) nonce <= 32'h01001b23 - 16'h03e8;
        else nonce <= nonce + 1;  // 32'hfded873c; 32'h01001b23;
    end

endmodule

/* 
* Module validateOutput
* validateOutput takes a HashOutput (3 bytes) and a target (1 byte) and returns true
* if the first two bytes (little endian) are below the target.
*/
module validateOutput (clk, active, target, hashOutput, terminado, validNonce, nonceOut, hashOut);

    input clk, active;
    input [7:0] target;
    input [23:0] hashOutput;
    input [31:0] validNonce;
    output reg terminado;
    output reg [23:0] hashOut;
    output reg [31:0] nonceOut;

    reg terminado_i;
    reg [23:0] hash_i;
    reg [31:0] nonce_i;

    always @(*) begin

        if (~active) begin

            terminado = 0;
            nonceOut = 0;
            hashOut = 0;

        end
        else begin

            if (hashOutput[23:16] < target && hashOutput[15:8] < target && ~terminado) begin
                terminado = 1;
                hashOut = hashOutput;
                nonceOut = validNonce;
            end
        end

    end


endmodule

/* Module micro_ucr_hash
* micro_ucr_hash is the main hashing function, it takes a bloque (16 bytes),
* makes some predefined bitwise operations and returns a HashOutput (3 bytes).
*/
module micro_ucr_hash (clk, active, bloque, hashOutput, validNonce);

    input clk, active;
    input [127:0] bloque;
    output reg [23:0] hashOutput;
    output reg [31:0] validNonce;

    reg [7:0] w [31:0];
    reg [7:0] h [2:0];
    reg [7:0] a, b, c, k, q;
    integer i;

    always @(*) begin

        if (~active) begin
            for (i = 0; i < 32; i = i+1) begin
                w[i] = 0;
            end

            for (i = 0; i < 3; i = i+1) begin
                h[i] = 8'hff;
            end

            a = 0;
            b = 0;
            c = 0;
            k = 0;
            q = 0;
        end
        else begin
            
            w[15] = bloque[7:0];
            w[14] = bloque[15:8];
            w[13] = bloque[23:16];
            w[12] = bloque[31:24];
            w[11] = bloque[39:32];
            w[10] = bloque[47:40];
            w[9] = bloque[55:48];
            w[8] = bloque[63:56];
            w[7] = bloque[71:64];
            w[6] = bloque[79:72];
            w[5] = bloque[87:80];
            w[4] = bloque[95:88];
            w[3] = bloque[103:96];
            w[2] = bloque[111:104];
            w[1] = bloque[119:112];
            w[0] = bloque[127:120];

            for (i = 16; i < 32; i = i + 1) begin
                w [i] = w[i-3] | (w[i-9] ^ w[i-14]);
            end

            h[0] = 8'h01;
            h[1] = 8'h89;
            h[2] = 8'hfe;

            a = h[0];
            b = h[1];
            c = h[2];

            for (i = 0; i < 32; i = i + 1) begin
                
                if (i <= 16) begin
                    k = 8'h99;
                    q = a ^ b;
                end
                else begin
                    k = 8'ha1;
                    q = a | b;
                end

                a = b ^ c;
                b = c << 4;
                c = q + k + w [i];
            end

            h[0] = h[0] + a;
            h[1] = h[1] + b;
            h[2] = h[2] + c;
        end
    end

    always @(posedge clk) begin
        if (~active) begin

            hashOutput <= 24'hffffff;
            validNonce <= 0;

        end 
        else begin

            hashOutput <= {h[0],h[1],h[2]};
            validNonce <= {w[12],w[13],w[14],w[15]};

        end
    end

endmodule

module sistema_area (clk, payload, active, target, terminado, nonceOut, hashOut);
    input clk, active;
    input [95:0] payload;
    input [7:0] target;
    output terminado;
    output [23:0] hashOut;
    output [31:0] nonceOut;
    wire [31:0] nonce;
    wire [23:0] hashOutput;
    wire [31:0] validNonce;
    wire [127:0] bloque;

    nextNonce sa_nxtn(clk, active, nonce);
    concatenador sa_cat(clk, payload, active, nonce, bloque);
    micro_ucr_hash sa_hash(clk, active, bloque, hashOutput, validNonce);
    validateOutput sa_validate(clk, active, target, hashOutput, terminado, validNonce, nonceOut, hashOut);
    
endmodule