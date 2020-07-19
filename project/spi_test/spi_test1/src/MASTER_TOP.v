`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/07 15:59:26
// Design Name: 
// Module Name: MASTER_TOP
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


module MASTER_TOP
(
	input                       SYS_CLK0,	
	input                       RESET_N,
	
	output                      SPI_CS,
	output                      SPI_SCK,
	output                      SPI_MOSI,
	input                       SPI_MISO
); 

wire    sys_clk;
wire    rst_n;
wire    o_cs;
wire    o_sck;
wire    o_mosi;
wire    i_miso;
wire    rw_start;
//	assign sys_clk = CLK;
	assign rst_n   = RESET_N;
	assign SPI_CS  = o_cs;
	assign SPI_SCK = o_sck;
	assign SPI_MOSI= o_mosi;
	assign i_miso= SPI_MISO;
wire pre_start;	
wire    rw_ack;		//结束标志
wire	[15:0]	rxdata;
wire	[15:0]	txdata = 16'h0023;
wire	[7:0]	addr ;
reg	[63:0]	cnt;	

	always@(posedge sys_clk or negedge rst_n)
	begin
	   if(!rst_n)
	       begin
	           cnt <= 'd0;
	       end
	   else
	       begin
	    	    if(pre_start == 1)
	    	      begin
	                   cnt <= cnt+1'b1;
	               end
	            else
	                   cnt <= 'd0;
	       end
	   end
	  
	           
       assign    rw_start = (cnt =='d3)? 1'b1 : 1'b0;
       assign    addr = 8'h81;
//--------------------------

  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(sys_clk),     // output clk_out1
   // Clock in ports
    .clk_in1(SYS_CLK0));      // input clk_in1	
//--------------------------------

ila_0 ila_master (
	.clk(sys_clk), // input wire clk


	.probe0(pre_start), // input wire [0:0]  probe0  
	.probe1(o_cs), // input wire [0:0]  probe1 
	.probe2(o_sck), // input wire [0:0]  probe2 
	.probe3(o_mosi), // input wire [0:0]  probe3 
	.probe4(i_miso), // input wire [0:0]  probe4 
	.probe5(rw_start), // input wire [0:0]  probe5 
	.probe6(txdata), // input wire [15:0]  probe6 
	.probe7(rxdata), // input wire [15:0]  probe7 
	.probe8(addr), // input wire [7:0]  probe8
	.probe9(cnt) // input wire [63:0]  probe9
);


vio_0 your_instance_name (
  .clk(sys_clk),                // input wire clk
  .probe_out0(pre_start)  // output wire [0 : 0] probe_out0
);

//---------------------------------
spi_master 
    #(
        .DATA_WIDTH    (16),
        .ADDR_WIDTH    (8 )
    )
    spi_master_inst
    (
        .sys_clk    (sys_clk),    
        .rst_n        (rst_n),
    
        .spi_cs        (o_cs),
        .spi_sck    (o_sck),
        .spi_mosi    (o_mosi),
        .spi_miso    (i_miso),
    
        .CPOL        (1'b0),        //极性
        .CPHA        (1'b0),        //相位
        .clk_div    (16'h0002),    //spi_sclk = clk/((clk_div+2)*2)
        .rw_start    (rw_start),
        .rw_ack        (rw_ack),        //结束标志
        .miso_valid    (),
        .mosi_valid    (),
        .addr          (addr),
        .txdata        (txdata),
        .rxdata        (rxdata)
    );
endmodule
