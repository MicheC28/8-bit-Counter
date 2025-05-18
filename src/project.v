/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire load = uio_in;
  wire [7:0] base = ui_in[7:0]; 
  wire T_0;
  wire Q_0;

  mux2to1 mux_0(
    .sel(load),
    .a(ena),
    .b(base[0]),
    .y(T_0)
  );

  t_flip_flop tff_0(
    .clk(clk),
    .reset(~rst_n),
    .T(T_0),
    .Q(Q_0)
  );




  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uo_out  = Q_0; // Example: ou_out is the output of the T flip-flop
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule


module t_flip_flop (
    input wire clk,
    input wire reset, // asynchronous reset
    input wire T,
    output reg Q
);

always @(posedge clk or posedge reset) begin
    if (reset)
        Q <= 1'b0;
    else if (T)
        Q <= ~Q; // Toggle
    // else Q stays the same
end

endmodule


module mux2to1 (
    input wire sel,        // Select line
    input wire a, b,       // Inputs
    output wire y          // Output
);

assign y = sel ? b : a;    // If sel = 0, y = a; if sel = 1, y = b

endmodule
  