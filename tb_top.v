`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 05:33:31 PM
// Design Name: 
// Module Name: tb_top
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


module tb_top;
    reg clk;
    reg resetn;
    reg ser_rx;
    wire ser_tx;
    
    wire flash_csb;
 wire flash_clk;
wire  flash_io0;
wire  flash_io1;
wire  flash_io2;
wire  flash_io3;
    
    top dut(
    clk,
    resetn,
    ser_rx,
    ser_tx,
    flash_csb,
    flash_clk,
    flash_io0,
    flash_io1,
    flash_io2,
    flash_io3
    );
    
    
    always #5 clk = ~clk;
    
    initial begin
    clk = 1'b0;
    resetn = 1'b0;
    ser_rx = 1'b1;
    #100;
    
    resetn = 1'b1;
    #5000;
    $finish;
    end
    
    
    // dump waves
    initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
end

endmodule
