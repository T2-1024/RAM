`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:01:24 07/08/2020 
// Design Name: 
// Module Name:    speed_setting 
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
module speed_setting(
				clk,rst_n,
				bps_start,clk_bps
			);

input clk;	// 25MHz��ʱ��
input rst_n;	//�͵�ƽ��λ�ź�
input bps_start;	//���յ����ݺ󣬲�����ʱ�������ź���λ
output clk_bps;	// clk_bps�ĸߵ�ƽΪ���ջ��߷�������λ���м������ 

`define CLK_PERIORD	40	//����ʱ������Ϊ40ns(25MHz)
`define BPS_SET		192	//����ͨ�Ų�����Ϊ19200bps

`define BPS_PARA	(10_000_000/`CLK_PERIORD/`BPS_SET)//10_000_000/`CLK_PERIORD/192;		//������Ϊ19200ʱ�ķ�Ƶ����ֵ
`define BPS_PARA_2	(`BPS_PARA/2)//BPS_PARA/2;	//������Ϊ19200ʱ�ķ�Ƶ����ֵ��һ�룬�������ݲ���

reg[15:0] cnt;			//��Ƶ����
reg clk_bps_r;			//������ʱ�ӼĴ���

//----------------------------------------------------------

always @ (posedge clk or negedge rst_n)
	if(!rst_n) cnt <= 16'd0;
	else if((cnt == `BPS_PARA) || !bps_start) cnt <= 16'd0;	//�����ʼ�������
	else cnt <= cnt+1'b1;			//������ʱ�Ӽ�������

always @ (posedge clk or negedge rst_n)
	if(!rst_n) clk_bps_r <= 1'b0;
	else if(cnt == `BPS_PARA_2) clk_bps_r <= 1'b1;	// clk_bps_r�ߵ�ƽΪ��������λ���м������,ͬʱҲ��Ϊ�������ݵ����ݸı��
	else clk_bps_r <= 1'b0;

assign clk_bps = clk_bps_r;

endmodule


