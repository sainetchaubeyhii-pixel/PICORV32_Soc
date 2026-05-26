`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2026 01:03:43 PM
// Design Name: 
// Module Name: top
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


module top (
    input clk,
    input resetn,
    //uart connect 
    input ser_rx,
    output ser_tx,
    //spi flash connect pins 
    output flash_csb,
 output flash_clk,
inout  flash_io0,
inout  flash_io1,
inout  flash_io2,
inout  flash_io3,

output [7:0] gpio_pins
);
//spi signals 
wire spimem_ready;
wire [31:0] spimem_rdata;
//

    wire mem_valid;
    wire mem_instr;
    wire mem_ready;

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg [31:0] mem_rdata;

reg [31:0] memory [0:255];

localparam UART_DATA = 32'h02000008;
wire uart_sel;

//assign mem_ready =
//    spimem_sel ? spimem_ready :
//    mem_valid;

assign mem_ready = spimem_sel ? spimem_ready : gpio_sel   ? gpio_ready : mem_valid;
    
//now Ram will not respond to all address
always @(*) begin

    if (uart_sel)
        mem_rdata = 32'b0;

    else if (spimem_sel)
        mem_rdata = spimem_rdata;

else if (gpio_sel)
        mem_rdata = gpio_rdata;

    else
        mem_rdata = memory[mem_addr[9:2]];

end

wire spimem_sel;

    picorv_32 cpu (
        .clk(clk),
        .resetn(resetn),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),

        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .irq(32'b0),
        .eoi()
    );

    simpleuart uart (
    .clk(clk),
    .resetn(resetn),

    .ser_tx(ser_tx),
    .ser_rx(ser_rx),

    .reg_dat_we(uart_sel && |mem_wstrb),
    .reg_dat_di(mem_wdata),

 .reg_div_we(4'b0000), // Later software should configure divider
 .reg_div_di(32'd434),

    .reg_dat_re(1'b0),

    .reg_dat_do(),
    .reg_dat_wait()
);

////spi flash
//wire [3:0] flash_io_di;
//wire [3:0] flash_io_do;
//wire [3:0] flash_io_oe;
wire flash_io0_oe;
wire flash_io0_do;
wire flash_io0_di;

wire flash_io1_oe;
wire flash_io1_do;
wire flash_io1_di;

wire flash_io2_oe;
wire flash_io2_do;
wire flash_io2_di;

wire flash_io3_oe;
wire flash_io3_do;
wire flash_io3_di;
//assign flash_io_di = {flash_io3, flash_io2, flash_io1, flash_io0};
assign flash_io0 = flash_io0_oe ? flash_io0_do : 1'bz;
assign flash_io1 = flash_io1_oe ? flash_io1_do : 1'bz;
assign flash_io2 = flash_io2_oe ? flash_io2_do : 1'bz;
assign flash_io3 = flash_io3_oe ? flash_io3_do : 1'bz;
//assign flash_io0 = flash_io_oe[0] ? flash_io_do[0] : 1'bz;
//assign flash_io1 = flash_io_oe[1] ? flash_io_do[1] : 1'bz;
//assign flash_io2 = flash_io_oe[2] ? flash_io_do[2] : 1'bz;
//assign flash_io3 = flash_io_oe[3] ? flash_io_do[3] : 1'bz;

spimemio spimemio (
    .clk            (clk),
    .resetn         (resetn),

    .valid          (spimem_sel),
    .ready          (spimem_ready),

    .addr           (mem_addr),
    .rdata          (spimem_rdata),

    .flash_csb      (flash_csb),
    .flash_clk      (flash_clk),

    .flash_io0_oe   (flash_io0_oe),
    .flash_io0_do   (flash_io0_do),
    .flash_io0_di   (flash_io0_di),

    .flash_io1_oe   (flash_io1_oe),
    .flash_io1_do   (flash_io1_do),
    .flash_io1_di   (flash_io1_di),

    .flash_io2_oe   (flash_io2_oe),
    .flash_io2_do   (flash_io2_do),
    .flash_io2_di   (flash_io2_di),

    .flash_io3_oe   (flash_io3_oe),
    .flash_io3_do   (flash_io3_do),
    .flash_io3_di   (flash_io3_di)
);

assign uart_sel = mem_valid &&
                  (mem_addr == UART_DATA);


assign spimem_sel =
    mem_valid &&
    (mem_addr >= 32'h01000000) &&
    (mem_addr <  32'h02000000);
    
    
    //initializing the  ram 
    initial begin
//    memory[0] = 32'h00000093; // addi x1,x0,0
//    memory[1] = 32'h07b00113; // addi x2,x0,123
//    memory[2] = 32'h0020a023; // sw x2,0(x1)
//    memory[3] = 32'h0000a183; // lw x3,0(x1)
//    memory[4] = 32'h0000006f; // jal x0,0

//instruction for spi flash
//memory[0] = 32'h010000B7;  // lui x1,0x01000
//memory[1] = 32'h0000A103;   // lw x2,0(x1)
//memory[2] = 32'h0000006F;   // jal x0,0

// gpio test

    memory[0] = 32'h100000B7; // lui x1,0x10000
    memory[1] = 32'h0AA00113; // addi x2,x0,0xAA
    memory[2] = 32'h0020A023; // sw x2,0(x1)
    memory[3] = 32'h0000006F; // jal x0,0

end


// Gpio
wire gpio_sel;
wire gpio_ready;
wire [31:0] gpio_rdata;

localparam GPIO_ADDR = 32'h1000_0000; // gpio memory  mapping

assign gpio_sel =
    mem_valid &&
    (mem_addr == GPIO_ADDR);
    
gpio gp(
.clk(clk),
.resetn(resetn),
//siganls for native memory interface
.iomem_valid(gpio_sel),
.iomem_ready(gpio_ready),
.iomem_addr(mem_addr),
.iomem_wdata(mem_wdata),
.iomem_wstrb(mem_wstrb),
.iomem_rdata(gpio_rdata),
//
.gpio_pins(gpio_pins)
    );
endmodule
