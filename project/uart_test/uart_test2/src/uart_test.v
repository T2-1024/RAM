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
	

wire clk_25m;	//clk_wiz0���25MHzʱ��
	
//clock
  clk_wiz0 clk_inst
   (// Clock in ports
    .clk_in1(sys_clk_i),      // IN ,50Mhz
    // Clock out ports
    .clk_out1(clk_25m));    // OUT ,25Mhz


wire bps_start1,bps_start2;	//���յ����ݺ󣬲�����ʱ�������ź���λ
wire clk_bps1,clk_bps2;		// clk_bps_r�ߵ�ƽΪ��������λ���м������,ͬʱҲ��Ϊ�������ݵ����ݸı�� 
wire[7:0] rx_data;	//�������ݼĴ���������ֱ����һ����������
wire rx_int;		//���������ж��ź�,���յ������ڼ�ʼ��Ϊ�ߵ�ƽ

	//UART�����źŲ���������
speed_setting		u2_speed_rx(	
							.clk(clk_25m),	//������ѡ��ģ��
							.rst_n(sys_rst_n),
							.bps_start(bps_start1),
							.clk_bps(clk_bps1)
						);

	//UART�������ݴ���
uart_rx			u3_my_uart_rx(		
							.clk(clk_25m),	//��������ģ��
							.rst_n(sys_rst_n),
							.uart_rx(uart_rx),
							.rx_data(rx_data),
							.rx_int(rx_int),
							.clk_bps(clk_bps1),
							.bps_start(bps_start1)
						);
		
//-------------------------------------

	//UART�����źŲ���������													
speed_setting		u4_speed_tx(	
							.clk(clk_25m),	//������ѡ��ģ��
							.rst_n(sys_rst_n),
							.bps_start(bps_start2),
							.clk_bps(clk_bps2)
						);
						
	//UART�������ݴ���
uart_tx			u5_my_uart_tx(		
							.clk(clk_25m),	//��������ģ��
							.rst_n(sys_rst_n),
							.rx_data(rx_data),
							.rx_int(rx_int),
							.uart_tx(uart_tx),
							.clk_bps(clk_bps2),
							.bps_start(bps_start2)
						);

endmodule		

