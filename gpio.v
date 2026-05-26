`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 05:12:52 PM
// Design Name: 
// Module Name: gpio
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


module gpio(
input clk,
input resetn,
//siganls for native memory interface
input iomem_valid,
output reg iomem_ready,
input [31:0] iomem_addr,
input [31:0] iomem_wdata,
input [3:0] iomem_wstrb,
output reg [31:0] iomem_rdata,
//
output [7:0] gpio_pins
    );
    
    reg [7:0] gpio_reg;
    
    always@(posedge clk) begin
    if (!resetn) 
    begin
    gpio_reg <= 8'b0;
    iomem_ready <= 1'b0; // gpio not ready
    iomem_rdata <= 32'h0;
    end
    
    else begin
    iomem_ready <= 1'b0;
    
    if(iomem_valid) begin
    iomem_ready <= 1'b1;
    
    //write
    if(iomem_wstrb != 4'b0000 && iomem_addr == 32'h1000_0000)
    gpio_reg <= iomem_wdata[7:0];
    
    //read
    if(iomem_addr == 32'h1000_0000)
    iomem_rdata <= {24'b0,gpio_reg};
    else
    iomem_rdata <= 32'h0;
    end
    end
    end
    
    assign gpio_pins = gpio_reg;
    
endmodule
