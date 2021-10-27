`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2021 03:16:14 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//  MIT License
//
//  Copyright (c) 2021 Jonathan Stein (New York, USA)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//////////////////////////////////////////////////////////////////////////////////


module top(
    input logic clk,
    input logic acia_clk,
    input logic e_bit,
    input logic vpa, 
    input logic vda,
    input logic reset,
    input logic rwb,
    input logic [15:0] ab,
    inout logic [7:0] db,
    output logic phi2,
    output logic nmib,
    output logic irqb,   
    output logic resb, 
    //mode_2
    //inout logic [7:0] data,
    //output logic acia_e,
    
    //sram IO
    inout wire [7:0] dio_a,
    output reg [15:0] ad,
    output reg oe_n,
    output reg we_n,
    output reg ce_a_n,
    
    //ACIA IO
    //output wire rts,
    //output wire tx,
    //input wire rx,
    //input wire cts,
    
    //UART
    output wire uart_tx,
    input wire uart_rx,
    
    //LEDs
    output wire LED_A,
    output wire LED_B
    
    );
  
  //UART
  logic rts;
  logic tx;
  logic rx;
  logic cts;
  
  logic vpvda;
  logic [7:0] bank; 
  logic bank_enable;
  logic db_enable;
  logic rom_enable;
  logic ram_enable;
  logic [7:0] data_w;
  logic [7:0] data_r; 
  logic [7:0] read_data;
  
  logic [15:0] address;
  logic [7:0] rom_out; 
  
  logic mrd_n, mrw_n;
  logic [7:0] ram_in;
  logic [7:0] ram_out; 
  logic [7:0] acia_in;
  logic [7:0] acia_out; 
  logic acia_irq; 
  logic phi_enable; 
  logic [1:0] reg_select;
  
  //fixed
  assign vpvda = (vpa || vda) ? 1'b1 : 1'b0; 
  assign bank_enable = (~phi2) ? 1'b1 : 1'b0; 
  assign db_enable = (~phi2) ? 1'b0 : 1'b1; 
  assign mrw_enable = (phi2) ? 1'b1 : 1'b0;
  assign data_rw = (rwb) ? 1'b1 : 1'b0;
  
  assign address = ab;
  assign rom_enable = (address >= 16'hC000  && vpvda) ? 1'b1 : 1'b0;
  assign ram_enable = (address < 16'h8000 && vpvda) ? 1'b1 : 1'b0;
  assign acia_enable = (address >= 16'h8000 && address < 16'h8010 && vpvda) ? 1'b1 : 1'b0;
  
  //mode_2
  assign acia_e = ~acia_enable;
  
  //mrd and mrw signals
  assign mwr_n = (mrw_enable && ~rwb) ? 1'b0 : 1'b1; 
  assign mrd_n = (mrw_enable && rwb) ? 1'b0 : 1'b1; 
  
  //LED Signals
  assign LED_A = reset;
  assign LED_B = e_bit;
  
  //bank address latch
  always_latch begin
  if (bank_enable) begin
     bank = db;
  end
  //No else clause so a_latch's value
  //is not always defined, so it holds its value
end

/* base model
  assign db = (db_enable) ? (rwb ? read_data : 'bz): 'bZ,
    data_w = (db_enable) ? (~rwb ? db : 'bZ) : 'bZ,
    resb = ~reset,
    irqb = 1,
    nmib = 1;   
*/

  assign db = (db_enable) ? (rwb ? (rom_enable ? rom_out : (ram_enable ? ram_out : (acia_enable ? acia_out : 'bZ))) : 'bZ) : 'bZ,
    data_w = (db_enable) ? (~rwb ? db : 'bZ) : 'bZ,
    resb = ~reset,
    irqb = 1,
    nmib = 1;   
    
  assign ram_in = (ram_enable && ~rwb) ? data_w : 'bZ; 
  assign acia_in = (acia_enable && ~rwb) ? data_w : 'bZ; 
  
  /*
  //mode_2
  assign data = (data_rw) ? 'bZ : acia_in; 
  assign acia_out = (data_rw) ? data : 'bZ;
  */
  
  assign reg_select = address[1:0];

  //UART Logic


Xilinx_UART UART_A(
  .m_rxd(uart_rx), // Serial Input (required)
  .m_txd(uart_tx), // Serial Output (required)
  .m_rtsn(cts), // Request to Send out(optional)
  .m_ctsn(rts), // Clear to Send in(optional)
//  additional ports here
  .acia_tx(tx),
  .acia_rx(rx)

);

  ACIA acia_a(
    .RESET(resb),
    .PHI2(phi2),
    .phi_enable(phi_enable),
    .CS(acia_e),
    .RWN(rwb),
    .RS(reg_select),
    .DATAIN(acia_in),
    .DATAOUT(acia_out),
    .XTLI(acia_clk),
    .RTSB(rts),
    .CTSB(cts),
    .DTRB(),
    .RXD(rx),
    .TXD(tx),
    .IRQn(1'b1)
   );

sram_ctrl5 ram_0(
        .clk(phi2), 
        .rw(rwb), 
        .wr_n(mwr_n), 
        .rd_n(mrd_n), 
        .ram_e(ram_enable), 
        .address_input(address), 
        .data_f2s(ram_in), 
        .data_s2f(ram_out), 
        .address_to_sram_output(ad), 
        .we_to_sram_output(we_n), 
        .oe_to_sram_output(oe_n), 
        .ce_to_sram_output(ce_a_n), 
        .data_from_to_sram_input_output(dio_a)
        );


dist_mem_gen_0 rom_0(
    .a(address),
    .spo(rom_out)
  );

/*
//Clock Divider
clock_divider three_mhz_clk(
  .i_Clk_12MHz(clk),
  .phi2(phi2),
  .phi_enable(phi_enable)
  );
  */

//Clock Generator
clk_wiz_0 clock_a(
  // Clock out ports
  .phi2(phi2),
  // Status and control signals
  .reset(reset),
  .locked(),
 // Clock in ports
  .clk(clk)
 );

//fixed   
   /* 
vio_0 debug_core(
    .clk(clk),
    .probe_in0(ab),
    .probe_in1(db),
    .probe_in2(rwb),
    .probe_in3(acia_e),
    .probe_in4(vda),
    .probe_in5(vpa),
    .probe_in6(reset),
    .probe_in7(bank),
    .probe_in8(data_w),
    .probe_in9(data),
    .probe_out0(phi2)
    );
    */
    
endmodule
