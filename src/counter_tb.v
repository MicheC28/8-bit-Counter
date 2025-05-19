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

  // Instantiate the DUT
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

  // Generate 10ns clock
  always #5 clk = ~clk;

  initial begin
    // VCD Dump
    $dumpfile("test.vcd");
    $dumpvars(0, tb_tt_um_example);

    $display("Starting enhanced testbench...");

    // Initialization
    clk = 0;
    rst_n = 0;
    ena = 1;
    ui_in = 8'b0;
    uio_in = 8'b0;  // Load low

    // Reset sequence
    #10 rst_n = 1;
    #10;

    // === COUNT FROM 0 to 0xFF ===
    $display("Counting from 0 to 0xFF");
    repeat (256) begin
      #10;
      $display("Counter = %02h", uo_out);
    end

    // === WRAP-AROUND OBSERVATION ===
    repeat (5) begin
      #10;
      $display("Wrap-around: Counter = %02h", uo_out);
    end

    // === LOAD NEW VALUE ===
    $display("Loading value 0xAA");
    ui_in = 8'hAA;
    uio_in = 8'hFF;  // Assert load
    #10;
    uio_in = 8'h00;  // Deassert load
    #10;
    $display("After load: Counter = %02h", uo_out);

    // === CONTINUE COUNTING ===
    repeat (10) begin
      #10;
      $display("Post-load counting: Counter = %02h", uo_out);
    end

    // === DISABLE COUNTER ===
    $display("Disabling counter for 10 cycles");
    ena = 0;
    repeat (10) begin
      #10;
      $display("While disabled: Counter = %02h", uo_out);
    end

    // === RE-ENABLE COUNTER ===
    $display("Re-enabling counter");
    ena = 1;
    repeat (10) begin
      #10;
      $display("After re-enable: Counter = %02h", uo_out);
    end

    $display("Testbench complete.");
    $finish;
  end

endmodule
