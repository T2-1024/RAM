`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/07 15:36:51
// Design Name: 
// Module Name: SLAVE_TOP
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


module SLAVE_TOP(

    input 		SYS_CLK1,
    input 		RESET_N,
	
//------------------ SPI -------------------
	input			SPI_CLK,
	input			SPI_CS,
	output			SPI_MISO,
	input			SPI_MOSI

    );

        wire     [15:0]  RX_DATA;
        wire     [7:0]  RX_ADDR;
        wire     [15:0]  TX_DATA = 16'haa33;
        wire         SPI_OVER;

	wire	i_clk;
	wire	i_rst_n;
	wire	i_sck;
	wire	i_cs;
	wire	i_mosi;
	wire		[7:0]	o_rx_addr;
	wire	[15:0]	o_rx_data;
	wire	[15:0]	i_tx_data;
	reg		[15:0]	inst_txd_data;
	reg		[15:0]	reg_2;
	
	wire		inst_txreq;
	wire		o_spi_over;
	wire		o_miso;
	wire		clk_out1;

//----------- ports ---------
	assign i_clk	= SYS_CLK1;
	assign i_rst_n	= RESET_N;
	assign i_sck	= SPI_CLK;
	assign i_cs		= SPI_CS;
	assign SPI_MISO	= o_miso;
	assign i_mosi	= SPI_MOSI;
	assign i_tx_data= TX_DATA;
	assign RX_DATA	= o_rx_data;
	assign RX_ADDR	= o_rx_addr;
	assign SPI_OVER	= o_spi_over;


//------- clk --------
  clk_wiz_0 clk_wiz_inst
   (
    // Clock out ports
    .clk_out1(clk_out1),     // output clk_out1
   // Clock in ports
    .clk_in1(i_clk));      // input clk_in1

//----------------- SPI wr process --------------------

always @ (posedge clk_out1 or negedge i_rst_n)
	begin
		if (!i_rst_n)
			begin
				reg_2 <= 'd0;
			end
		else
			begin
				if(o_spi_over&&(inst_txreq==0))
					begin
						case(o_rx_addr[6:0])
							7'd2:
								begin
									reg_2 <= o_rx_data[15:0];//Ð´¼Ä´æÆ÷Öµ
								end
							default:;							
						endcase
					end
				else
					begin
						case(o_rx_addr[6:0])
							7'd0:
								begin
									inst_txd_data <= 16'h0ad0;//Ö»¶Á
								end
							7'd1:
								begin
									inst_txd_data <= i_tx_data;//¶Á¼Ä´æÆ÷Öµ
								end
								
							default:;							
						endcase
					end
			end
	end

    ila_0 ila_slave (
        .clk(clk_out1), // input wire clk
    
    
        .probe0(i_cs), // input wire [0:0]  probe0  
        .probe1(i_sck), // input wire [0:0]  probe1 
        .probe2(o_miso), // input wire [0:0]  probe2 
        .probe3(i_mosi), // input wire [0:0]  probe3 
        .probe4(inst_txd_data), // input wire [0:0]  probe4 
        .probe5(o_rx_data), // input wire [15:0]  probe5 
        .probe6(o_rx_addr) // input wire [15:0]  probe6 
    );

//--------------------------------------------------
//--------------------- inst -----------------------
	spi_slave 
	#(
		.DATA_WIDTH	(16),
		.ADDR_WIDTH	(8)
	)
	spi_slave_inst
	(
			.clk		(clk_out1),	// <--
			.rst_n		(i_rst_n),		// <--
			
			//MCU_CPLD_io
			.spi_cs		(i_cs),		// <--
			.spi_sck	(i_sck),	// <--
			.spi_miso	(o_miso),	// -->
			.spi_mosi	(i_mosi),	// <--
			
			//config in CPLD
			.addr		(o_rx_addr),			// --> , 1Byte, {rw_flag,addr[6:0]}
//			.rover_flag	(rover_flag),	// -->
			.txreq		(inst_txreq),		// --> , R/W status
//			.tover_flag	(),				// -->
			.spi_over	(o_spi_over),				// -->
			.rxdata		(o_rx_data), 		// --> , 2Byte,
			.txdata		(inst_txd_data),  		// <-- , 2Byte, 
			.addr_valid	()
		);



endmodule
