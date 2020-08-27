`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/26 09:19:27
// Design Name: 
// Module Name: clk_dection
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


module clk_dection
	#(
		parameter CLK_NUM = 'd156
	)
	(
		input   clk_25M_dect,
		input   clk_125M_dect,
		input   rst,

		input   clk_run,

		output  reg  clk_flag,
		output  reg [9:0] clk_cnt
    );
    
	reg  [5:0] cnt_1us;  //1us jishu
	reg  [31:0] cnt_1s;   //1s jishu
	reg        flag_1us;
	reg        flag_1s;
	reg        flag_1us_2,flag_1us_1;
	reg        flag_1s_2,flag_1s_1;
	wire       flag_1us_neg;
	wire       flag_1us_pos;
	wire       flag_1s_neg;


	assign flag_1us_neg = flag_1us_2 & ( ~flag_1us_1);
	assign flag_1us_pos = (~flag_1us_2) & flag_1us_1;
	assign flag_1s_neg  = flag_1s_2  & ~flag_1s_1;


	always @ ( posedge clk_25M_dect )
	begin
		if(rst)
			begin
				cnt_1us <= 6'd0;
				cnt_1s  <= 32'd0;
				flag_1us <= 1'b0;
				flag_1s  <= 1'b0;
			end
		else
			begin
			   cnt_1us <=  cnt_1us + 1'd1;
			   cnt_1s  <=  cnt_1s + 1'd1;
			   flag_1s <=  cnt_1s[26];
			   if(cnt_1us >= 'd50)
					cnt_1us <= 6'd0;
			   if(cnt_1s >= 32'hfffffffa)
					cnt_1s <= 32'd0;
			   if(cnt_1us >= 'd0 && cnt_1us <= 'd24)
					flag_1us <= 'b1;
			   else
					flag_1us <= 'b0;          
			end
	end


	always @ ( posedge clk_125M_dect)
	begin
		if(rst)
			begin
				{flag_1s_2,flag_1s_1} <= 2'b11;
				{flag_1us_2,flag_1us_1} <= 2'b11;
			end
		else 
			begin
				{flag_1us_2,flag_1us_1}  <= {flag_1us_1,flag_1us};
				{flag_1s_2,flag_1s_1}  <= {flag_1s_1,flag_1s};

			end
	end

	reg [9:0] clk_cnt_1;
	always @ ( posedge clk_run )
	begin
		if(rst)
			begin
				clk_flag        <= 1'b1;
				clk_cnt_1       <= 10'd0;
				clk_cnt         <= 10'd0;          
			end
		else 
			begin
				if(flag_1us)
					clk_cnt_1  <=  clk_cnt_1 + 1'd1;
				if(flag_1us_neg)
					begin
					   clk_cnt_1    <= 10'd0; 
					   clk_cnt      <= clk_cnt_1;
					   if((clk_cnt_1 >= (CLK_NUM - 'd5)) && (clk_cnt_1 <= (CLK_NUM + 'd5)))
							clk_flag <= 1'b1;
					   else
							clk_flag <= 1'b0;
					end 
			end
	end


endmodule