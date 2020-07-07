`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:17:50 07/07/2020 
// Design Name: 
// Module Name:    uart_test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module uart_test(
	input                        sys_clk_i,
	input                        uart_rx,
	input                        sys_rst_n,
	output                       uart_tx
	);
	

wire clk_25m;	//clk_wiz0输出25MHz时钟
	
//clock
  clk_wiz0 clk_inst
   (// Clock in ports
    .clk_in1(sys_clk_i),      // IN ,50Mhz
    // Clock out ports
    .clk_out1(clk_25m));    // OUT ,25Mhz


wire bps_start1,bps_start2;	//接收到数据后，波特率时钟启动信号置位
wire clk_bps1,clk_bps2;		// clk_bps_r高电平为接收数据位的中间采样点,同时也作为发送数据的数据改变点 
wire[7:0] rx_data;	//接收数据寄存器，保存直至下一个数据来到
wire rx_int;		//接收数据中断信号,接收到数据期间始终为高电平

	//UART接收信号波特率设置
speed_setting		u2_speed_rx(	
							.clk(clk_25m),	//波特率选择模块
							.rst_n(sys_rst_n),
							.bps_start(bps_start1),
							.clk_bps(clk_bps1)
						);

	//UART接收数据处理
uart_rx			u3_my_uart_rx(		
							.clk(clk_25m),	//接收数据模块
							.rst_n(sys_rst_n),
							.uart_rx(uart_rx),
							.rx_data(rx_data),
							.rx_int(rx_int),
							.clk_bps(clk_bps1),
							.bps_start(bps_start1)
						);
		
//-------------------------------------

	//UART发送信号波特率设置													
speed_setting		u4_speed_tx(	
							.clk(clk_25m),	//波特率选择模块
							.rst_n(sys_rst_n),
							.bps_start(bps_start2),
							.clk_bps(clk_bps2)
						);
						
	//UART发送数据处理
uart_tx			u5_my_uart_tx(		
							.clk(clk_25m),	//发送数据模块
							.rst_n(sys_rst_n),
							.rx_data(rx_data),
							.rx_int(rx_int),
							.uart_tx(uart_tx),
							.clk_bps(clk_bps2),
							.bps_start(bps_start2)
						);

endmodule		

