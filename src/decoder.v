// ========================================================
// Sub-module: 8-to-256 Decoder
// ========================================================
module decoder_8_256 (
    input  wire [7:0]   in_addr,
    input  wire         en,
    output reg  [255:0] out_data
);
    always @(*) begin
        out_data = 256'd0;
        if (en) begin
            // Synthesizable dynamic bit-shift for decoding
            out_data[in_addr] = 1'b1; 
        end
    end
endmodule

// ========================================================
// Top-module: 10-to-1024 Decoder (Wrapper)
// ========================================================
module decoder_10_1024 (
    input  wire [9:0]    in_addr,
    input  wire          en,
    output wire [1023:0] out_data
);
    // 2-to-4 pre-decoding logic for block enables
    wire en0 = en & (in_addr[9:8] == 2'b00);
    wire en1 = en & (in_addr[9:8] == 2'b01);
    wire en2 = en & (in_addr[9:8] == 2'b10);
    wire en3 = en & (in_addr[9:8] == 2'b11);

    // Instantiate four 8:256 decoders
    decoder_8_256 dec0 (
        .in_addr(in_addr[7:0]), 
        .en(en0), 
        .out_data(out_data[255:0])
    );
    
    decoder_8_256 dec1 (
        .in_addr(in_addr[7:0]), 
        .en(en1), 
        .out_data(out_data[511:256])
    );
    
    decoder_8_256 dec2 (
        .in_addr(in_addr[7:0]), 
        .en(en2), 
        .out_data(out_data[767:512])
    );
    
    decoder_8_256 dec3 (
        .in_addr(in_addr[7:0]), 
        .en(en3), 
        .out_data(out_data[1023:768])
    );
endmodule
