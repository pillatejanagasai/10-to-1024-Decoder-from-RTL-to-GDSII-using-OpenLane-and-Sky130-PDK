`timescale 1ns/1ps

module tb_decoder_10_1024;

    // Inputs to DUT
    reg [9:0] in_addr;
    reg       en;

    // Outputs from DUT
    wire [1023:0] out_data;

    integer i;
    integer errors = 0;

    // Instantiate the Device Under Test (DUT)
    decoder_10_1024 dut (
        .in_addr(in_addr),
        .en(en),
        .out_data(out_data)
    );

    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("tb_decoder.vcd");
        $dumpvars(0, tb_decoder_10_1024);

        $display("Starting 10:1024 Decoder Simulation...");

        // --- TEST 1: Enable is LOW ---
        // The output MUST remain completely zero regardless of the address
        en = 1'b0;
        in_addr = 10'd500; // Arbitrary address
        #10;
        
        if (out_data !== 1024'b0) begin
            $display("ERROR: Output bus is not zero when EN=0.");
            errors = errors + 1;
        end else begin
            $display("PASS: Enable LOW test handled correctly.");
        end
        #10;

        // --- TEST 2: Exhaustive Address Sweep (EN = 1) ---
        // We test every single address from 0 to 1023
        $display("Sweeping all 1024 addresses with EN=1...");
        en = 1'b1;
        for (i = 0; i < 1024; i = i + 1) begin
            in_addr = i[9:0];
            #1; // Wait 1 timestep for the combinational logic to resolve

            // The output should be exactly '1' shifted left by 'i' positions.
            // If any other bit is high, or the target bit is low, it fails.
            if (out_data !== (1024'b1 << i)) begin
                $display("ERROR at address %0d: Incorrect decode.", i);
                errors = errors + 1;
            end
        end
        $display("Sweep complete.");
        #10;

        // --- TEST 3: Dynamic Enable Toggle ---
        // Ensure the decoder can turn on and off rapidly at a specific address
        $display("Testing dynamic Enable toggle at address 850...");
        in_addr = 10'd850;
        
        en = 1'b1; #10;
        if (out_data[850] !== 1'b1) errors = errors + 1;
        
        en = 1'b0; #10; // Turn it off
        if (out_data !== 1024'b0) errors = errors + 1;
        
        en = 1'b1; #10; // Turn it back on
        if (out_data[850] !== 1'b1) errors = errors + 1;

        if (errors == 0) $display("PASS: Dynamic toggle handled correctly.");

        // --- FINAL RESULTS ---
        #10;
        if (errors == 0) begin
            $display("======================================");
            $display("          ALL TESTS PASSED!           ");
            $display("======================================");
        end else begin
            $display("======================================");
            $display("      TESTS FAILED with %0d errors.   ", errors);
            $display("======================================");
        end

        $finish;
    end

endmodule
