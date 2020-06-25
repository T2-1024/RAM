`timescale 1ns / 1ps
//clock about baud-rate 
module gen_clk1
	#(
		parameter CLK_FRE = 50000000,	//source clock (HZ),(example:50MHZ)
		parameter BAUD_RATE = 115200	//baud rate
	)
	(
		input			clk,		//clock input
		input			rst_n,		//reset input, low active 
		output reg		clk_pulse	//pluse output

	);
	
	//calculate the clock cycle for baud rate 
	localparam	CYCLE = CLK_FRE / BAUD_RATE;

	reg	[15:0]	cycle_cnt;        //baud counter
	
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				cycle_cnt <= 16'd0;
			else if(cycle_cnt == CYCLE - 1)
				cycle_cnt <= 16'd0;				//clear count register
			else
				cycle_cnt <= cycle_cnt + 16'd1;	
		end
		
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				clk_pulse <= 1'b0;
			else if(cycle_cnt == CYCLE - 1)
				clk_pulse <= 1'b1;
			else
				clk_pulse <= 1'b0;	
		end
endmodule 
