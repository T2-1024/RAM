`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/09 10:53:37
// Design Name: 
// Module Name: spi_M_S_tb
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



module spi_M_S_tb;
	reg			rst_n;
	reg			clk;
	reg			start;
	wire			spi_rw_flag_S;
	reg	[15:0]	t_data_M;				//master send
	reg	[7:0]	t_addr_M;				//master send

	reg	[15:0]	tx_data_S;				//slave send

	wire			rw_ack;
	wire	[15:0]	rx_data_M;			//master receive
	wire	[7:0]	r_addr_S;
	wire	[15:0]	r_data_S;

	wire		spi_miso;
	wire	      	spi_mosi;
	wire	      	spi_cs;
	wire	      	spi_sclk;
	wire	      	spi_over_S;

	always #20 clk = ~clk;

	initial 
		begin
		clk = 0;
		//first transmittal
			#100 rst_n = 1'b0;
			#1000;
				rst_n = 1'b1;
				start = 1'b0;
				t_data_M = 16'h1234; 
				t_addr_M = 8'b00111100 ;	//8'h3c
				tx_data_S = 16'h2222;
			#100  start = 1'b1;
			#1000  start = 1'b0;//低于一个SPI传输周期的触发长度(40ns)
	 
		//second transmittal
			#18000
				  t_data_M = 16'h4321;	//s_tdata=8'h64;
				  t_addr_M = 8'b11111000  ;	//8'hf8
				  tx_data_S = 16'h3333;
			#100  start = 1'b1;
			#40  start = 1'b0;//一个系统时钟周期触发长度(40ns)
			#22020;
			
		//Third transmittal
				  t_data_M = ~t_data_M;		//25'h09abcde;
				  t_addr_M = 8'b01111100  ;	//8'h7c
				  tx_data_S = 16'h4444;
			#100  start = 1'b1;

			#100  start = 1'b0;
			#20000;
			
		//Fourth transmittal
				  t_addr_M = 8'b10011111  ;	//9f
				 tx_data_S = 16'h4344;
			#100  start = 1'b1;
			#100  start = 1'b0;
			#20000;

	   end

spi_master 
    #(
        .DATA_WIDTH    (16),
        .ADDR_WIDTH    (8 )
    )
    spi_master_inst
    (
        .sys_clk    (clk),    
        .rst_n        (rst_n),
    
        .spi_cs        (spi_cs),
        .spi_sck    (spi_sclk),
        .spi_mosi    (spi_mosi),
        .spi_miso    (spi_miso),
    
        .CPOL        (1'b0),        //极性
        .CPHA        (1'b0),        //相位
        .clk_div    (16'h0003),    //spi_sclk = clk/((clk_div+2)*2)
        .rw_start    (start),
        .rw_ack        (rw_ack),        //结束标志
        .miso_valid    (),
        .mosi_valid    (),
        .addr          (t_addr_M),
        .txdata        (t_data_M),
        .rxdata        (rx_data_M)
    );
	
	spi_slave 
	#(
	.DATA_WIDTH (16),
	.ADDR_WIDTH (8)
	)
	myspi_slave (

		.clk(clk),
		.rst_n			(rst_n),
		.spi_cs			(spi_cs),			//cs <<<-----
		.spi_sck		(spi_sclk),			//sclk <<<-----
		.spi_mosi		(spi_mosi),			//mosi <<<-----
		.spi_miso		(spi_miso), 		//miso ----->>>
			
		.txdata		(tx_data_S),		//data from EEPROM
		.txreq	(spi_rw_flag_S),	//0:data from master to slave?1:data from slave to master
		.addr		(r_addr_S),
		.rxdata		(r_data_S),			//data from master
		.spi_over(spi_over_S),
		.addr_valid()

		);

endmodule

