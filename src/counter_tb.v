`timescale 1ns / 1ps
`default_nettype none

module tb_tt_um_example;

  reg [7:0] ui_in;
  wire [7:0] uo_out;
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  reg ena;
  reg clk;
  reg rst_n;

  // Instantiate the design under test (DUT)
  tt_um_example dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  initial begin
   // VCD dump for waveform
    $dumpfile("test.vcd");  // Name of the output VCD file
    $dumpvars(0, tb_tt_um_example);     // Dump everything under this testbench

    $display("Starting testbench...");

    // Initialize signals
    clk = 0;
    rst_n = 0;
    ena = 1;         // Enable always high
    ui_in = 8'b0;
    uio_in = 8'b0;   // Load = 0 => count mode

    // Reset the design
    #10;
    rst_n = 1;       // Release reset
    #10;

    // === COUNTING MODE TEST ===
    $display("Testing counting...");
    repeat (8) begin
      #10;
      $display("Counter = %b", uo_out);
    end

    // === LOAD MODE TEST ===
    $display("Testing loading...");

    // Set load signal (uio_in) high
    uio_in = 8'b11111111;

    // Load the value
    ui_in = 8'b10101010;  // Value to load
    #10;                  // One clock edge
    uio_in = 8'b00000000; // Back to count mode

    #10;
    $display("After load: Counter = %b", uo_out);

    // Count a few more times
    repeat (4) begin
      #10;
      $display("Counter = %b", uo_out);
    end

    $display("Testbench complete.");
    $finish;
  end

endmodule
