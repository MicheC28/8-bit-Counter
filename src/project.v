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

    wire [7:0] load = 8'b11000101;
    wire [7:0] value;
    counter c1(value, clk, rst_n, ena, load);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ena ? value : 8'bz;
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  // wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule





module counter (
    output reg [7:0] out,
    input clk,
    input reset,
    input enable,
    input [7:0] load // Load value
);
    
    reg [7:0] out_next; // Next value to be assigned
    parameter [7:0] DEFAULT_LOAD_VALUE = 8'b0; // Default load value
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out <= DEFAULT_LOAD_VALUE;
            out_next <= DEFAULT_LOAD_VALUE;
        end else if (!enable) begin
            // Hold value or add custom logic if needed
        end else begin
            out <= out_next;
            out_next <= out_next + 1;
        end
    end

    // Optional: logic to load a value
    always @(posedge clk) begin
        if (load) begin
            out_next <= load;
        end
    end
endmodule

