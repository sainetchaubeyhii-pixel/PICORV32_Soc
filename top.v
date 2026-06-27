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

    // 2nd spi
    // second SPI flash pins
    output flash2_csb,
    output flash2_clk,
    inout  flash2_io0,
    inout  flash2_io1,
    inout  flash2_io2,
    inout  flash2_io3,

    output [49:0] gpio_pins
);

    //spi signals 
    //wire spimem_ready;
    //wire [31:0] spimem_rdata;
    //

    wire spimem0_sel, spimem1_sel;

    wire spimem0_ready;
    wire [31:0] spimem0_rdata;

    wire spimem1_ready;
    wire [31:0] spimem1_rdata;

    //
    wire mem_valid;
    wire mem_instr;
    wire mem_ready;

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;

    reg [31:0] memory [0:255];

    //Uart memory mapping
    localparam UART_BASE = 32'h02000000;
    localparam UART_END  = 32'h020000FF;
    wire uart_sel;

    // Gpio
    wire gpio_sel;
    wire gpio_ready;
    wire [31:0] gpio_rdata;

    // gpio memory  mapping
    localparam GPIO_BASE = 32'h10000000;
    localparam GPIO_END  = 32'h100000FF;

    // Memory ready logic
    assign mem_ready = spimem0_sel ? spimem0_ready :
                       spimem1_sel ? spimem1_ready :
                       gpio_sel    ? gpio_ready :
                       mem_valid;

    //now Ram will not respond to all address
    always @(*) begin
        if (uart_sel)
            mem_rdata = 32'b0;

        else if (spimem0_sel)
            mem_rdata = spimem0_rdata;

        else if (spimem1_sel)
            mem_rdata = spimem1_rdata;

        else if (gpio_sel)
            mem_rdata = gpio_rdata;

        else
            mem_rdata = memory[mem_addr[9:2]];
    end

    // Address decoding

    assign uart_sel =
        mem_valid &&
        (mem_addr >= UART_BASE) &&
        (mem_addr <= UART_END);

    assign spimem0_sel =
        mem_valid &&
        (mem_addr >= 32'h01000000) &&
        (mem_addr <  32'h02000000);

    assign spimem1_sel =
        mem_valid &&
        (mem_addr >= 32'h03000000) &&
        (mem_addr <  32'h04000000);

    assign gpio_sel =
        mem_valid &&
        (mem_addr >= GPIO_BASE) &&
        (mem_addr <= GPIO_END);

    // CPU Instance

    //wire spimem_sel;

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

    // UART Instance
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

    // SPI0 Flash Interface
    
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

    assign flash_io0_di = flash_io0;
    assign flash_io1_di = flash_io1;
    assign flash_io2_di = flash_io2;
    assign flash_io3_di = flash_io3;

    spimemio spimemio0 (
        .clk            (clk),
        .resetn         (resetn),

        .valid          (spimem0_sel),
        .ready          (spimem0_ready),

        .addr           (mem_addr),
        .rdata          (spimem0_rdata),

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

    // SPI1 Flash Interface
    //tri state wires
    wire flash2_io0_oe, flash2_io0_do, flash2_io0_di;
    wire flash2_io1_oe, flash2_io1_do, flash2_io1_di;
    wire flash2_io2_oe, flash2_io2_do, flash2_io2_di;
    wire flash2_io3_oe, flash2_io3_do, flash2_io3_di;

    assign flash2_io0 = flash2_io0_oe ? flash2_io0_do : 1'bz;
    assign flash2_io1 = flash2_io1_oe ? flash2_io1_do : 1'bz;
    assign flash2_io2 = flash2_io2_oe ? flash2_io2_do : 1'bz;
    assign flash2_io3 = flash2_io3_oe ? flash2_io3_do : 1'bz;

    assign flash2_io0_di = flash2_io0;
    assign flash2_io1_di = flash2_io1;
    assign flash2_io2_di = flash2_io2;
    assign flash2_io3_di = flash2_io3;

    spimemio spimemio1 (
        .clk            (clk),
        .resetn         (resetn),

        .valid          (spimem1_sel),
        .ready          (spimem1_ready),

        .addr           (mem_addr),
        .rdata          (spimem1_rdata),

        .flash_csb      (flash2_csb),
        .flash_clk      (flash2_clk),

        .flash_io0_oe   (flash2_io0_oe),
        .flash_io0_do   (flash2_io0_do),
        .flash_io0_di   (flash2_io0_di),

        .flash_io1_oe   (flash2_io1_oe),
        .flash_io1_do   (flash2_io1_do),
        .flash_io1_di   (flash2_io1_di),

        .flash_io2_oe   (flash2_io2_oe),
        .flash_io2_do   (flash2_io2_do),
        .flash_io2_di   (flash2_io2_di),

        .flash_io3_oe   (flash2_io3_oe),
        .flash_io3_do   (flash2_io3_do),
        .flash_io3_di   (flash2_io3_di)
    );

    // GPIO Instance
    gpio gp (
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

    // initializing the ram
    initial begin
        //spi0 testing
        //memory[0] = 32'h010000B7; // lui x1,0x01000
        //memory[1] = 32'h0000A103; // lw x2,0(x1)
        //memory[2] = 32'h0000006F; // jal x0,0

        //spi1 testing
        //memory[0] = 32'h030000B7; // lui x1,0x03000
        //memory[1] = 32'h0000A103; // lw x2,0(x1)
        //memory[2] = 32'h0000006F; // jal x0,0

        //spi1 testing

        // lower 32 bit  for gpio test 
        //memory[0] = 32'h100000B7; // lui x1,0x10000
        //memory[1] = 32'h0AA00113; // addi x2,x0,0xAA
        //memory[2] = 32'h0020A023; // sw x2,0(x1)
        //memory[3] = 32'h0000006F; // jal x0,0

        //output = AA

        //For upper GPIO pins [49:32],needed address 0x10000004:

        memory[0] = 32'h100000B7; // lui x1,0x10000
        memory[1] = 32'h3FF00113; // addi x2,x0,0x3FF
        memory[2] = 32'h0020A223; // sw x2,4(x1)
        memory[3] = 32'h0000006F; // jal x0,0

        //output = 3FF
    end

    //assign spimem_ready = 1'b1;
    //assign spimem_rdata = 32'h12345678;

endmodule