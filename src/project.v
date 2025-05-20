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
  wire T_0, T_1, T_2, T_3, T_4, T_5, T_6, T_7;
  wire Q_0, Q_1, Q_2, Q_3, Q_4, Q_5, Q_6, Q_7;
  wire ena_0, ena_1, ena_2, ena_3, ena_4, ena_5, ena_6, ena_7;
  wire l0, l1, l2, l3, l4, l5, l6, l7;


  assign l0 = base[0] ^ Q_0;
  assign l1 = base[1] ^ Q_1;
    assign l2 = base[2] ^ Q_2;  
    assign l3 = base[3] ^ Q_3;
    assign l4 = base[4] ^ Q_4;
    assign l5 = base[5] ^ Q_5;
    assign l6 = base[6] ^ Q_6;
    assign l7 = base[7] ^ Q_7;



  assign ena_0 = ena;
  assign ena_1 = ena && Q_0;
  assign ena_2 = ena && Q_0 && Q_1;
  assign ena_3 = ena && Q_0 && Q_1 && Q_2;
  assign ena_4 = ena && Q_0 && Q_1 && Q_2 && Q_3;
  assign ena_5 = ena && Q_0 && Q_1 && Q_2 && Q_3 && Q_4;
  assign ena_6 = ena && Q_0 && Q_1 && Q_2 && Q_3 && Q_4 && Q_5;
  assign ena_7 = ena && Q_0 && Q_1 && Q_2 && Q_3 && Q_4 && Q_5 && Q_6;


  
  // Instantiate T flip-flops

  t_flip_flop tff_0(.clk(clk), .reset(~rst_n), .T(T_0), .Q(Q_0));
  t_flip_flop tff_1(.clk(clk), .reset(~rst_n), .T(T_1), .Q(Q_1));
  t_flip_flop tff_2(.clk(clk), .reset(~rst_n), .T(T_2), .Q(Q_2));
  t_flip_flop tff_3(.clk(clk), .reset(~rst_n), .T(T_3), .Q(Q_3));
  t_flip_flop tff_4(.clk(clk), .reset(~rst_n), .T(T_4), .Q(Q_4));
  t_flip_flop tff_5(.clk(clk), .reset(~rst_n), .T(T_5), .Q(Q_5));
  t_flip_flop tff_6(.clk(clk), .reset(~rst_n), .T(T_6), .Q(Q_6));
  t_flip_flop tff_7(.clk(clk), .reset(~rst_n), .T(T_7), .Q(Q_7));

    // Instantiate 8 2-to-1 multiplexers

  mux2to1 mux_0(.sel(load), .a(ena_0), .b(l0), .y(T_0));
  mux2to1 mux_1(.sel(load), .a(ena_1), .b(l1), .y(T_1));
  mux2to1 mux_2(.sel(load), .a(ena_2), .b(l2), .y(T_2));
  mux2to1 mux_3(.sel(load), .a(ena_3), .b(l3), .y(T_3));
  mux2to1 mux_4(.sel(load), .a(ena_4), .b(l4), .y(T_4));
  mux2to1 mux_5(.sel(load), .a(ena_5), .b(l5), .y(T_5));
  mux2to1 mux_6(.sel(load), .a(ena_6), .b(l6), .y(T_6));
  mux2to1 mux_7(.sel(load), .a(ena_7), .b(l7), .y(T_7));
  


  

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uo_out = ena? {Q_7, Q_6, Q_5, Q_4, Q_3, Q_2, Q_1, Q_0} : 8'bz; // Example: ou_out is the output of the T flip-flop
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
  