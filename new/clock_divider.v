`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2021 02:55:23 PM
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider(
  input i_Clk_12MHz,
  output reg  phi2,
  output wire phi_enable);

  reg       r_Clock_En    = 1'b0;
  reg [1:0] r_Clock_Count = 2'b00;
  reg [2:0] r_Test        = 3'b000;

  always @(posedge i_Clk_12MHz)
  begin

    // Default Assignment
    r_Clock_En <= 1'b0;

    if (r_Clock_Count == 0)
    begin
      phi2 <= 1'b0;  // Can be used externally
    end
    else if (r_Clock_Count == 2)
    begin
      phi2 <= 1'b1;
      r_Clock_En  <= 1'b1;
    end
    
    r_Clock_Count <= r_Clock_Count + 1;
    
  end  
  
  assign phi_enable = r_Clock_En;
  
  // Internally use Clock_En, never use output of Flip-Flop as internal clock.
  always @(posedge i_Clk_12MHz)
    if (r_Clock_En)
    begin
      // ADC Logic, runs effectively at 10 MHz
      r_Test <= r_Test + 1;
    end

endmodule
