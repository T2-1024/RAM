`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:14 04/27/2020 
// Design Name: 
// Module Name:    spi_slave 
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
//前沿采样，后沿输出
module spi_slave
#(
		parameter DATA_WIDTH = 16,
		parameter ADDR_WIDTH = 8
)
(
    
input               clk,
input               rst_n,

input               spi_cs,
input               spi_sck,
output   reg        spi_miso,
input               spi_mosi,

output  reg [ADDR_WIDTH-1:0]  addr,
output  reg        txreq,
output              spi_over,
output  reg [DATA_WIDTH-1:0]  rxdata,
input    [DATA_WIDTH-1:0]     txdata,
output              addr_valid


);


//-----------------------------//
 reg        spi_cs_2,spi_cs_1;
 reg        spi_sck_2,spi_sck_1;
 reg        spi_mosi_2,spi_mosi_1;
 wire       spi_cs_pos;
 wire       spi_cs_flag;
 wire       spi_sck_neg;
 wire       spi_sck_pos;
 wire       spi_mosi_flag;
reg    [DATA_WIDTH-1:0]     txdata_reg;

reg    [3:0]     state;
reg    [4:0]     cnt;

//----------------------------------------//
localparam idle       = 4'd0;
localparam rxd_addr   = 4'd1;
localparam jude_wr_rd = 4'd2;
localparam rxd_data   = 4'd3;
localparam rxd_over   = 4'd4;
localparam txd_data   = 4'd5;
localparam end_sta    = 4'd6;
 
always @(posedge clk or negedge rst_n)
begin
if(!rst_n)
    begin
        {spi_cs_2,spi_cs_1} <= 2'b11;
        {spi_sck_2,spi_sck_1} <= 2'b00;
        {spi_mosi_2,spi_mosi_1} <= 2'b00;
    end
else 
    begin
        {spi_cs_2,spi_cs_1} <= {spi_cs_1,spi_cs};
        {spi_sck_2,spi_sck_1} <= {spi_sck_1,spi_sck};
        {spi_mosi_2,spi_mosi_1} <= {spi_mosi_1,spi_mosi}; 
    end
end
        
assign spi_cs_pos = ~spi_cs_2 & spi_cs_1;
assign spi_cs_flag = spi_cs_2;
assign spi_sck_neg = ~spi_sck_1&spi_sck_2;
assign spi_sck_pos = ~spi_sck_2&spi_sck_1; 
assign spi_mosi_flag = spi_mosi_2;

assign spi_over = (state == end_sta);
assign addr_valid = (state == jude_wr_rd);


always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			state       <= idle;
			cnt         <= 'd0;
			addr        <= 'd0;
			rxdata      <= 'd0;
			txreq       <= 1'b0;
			spi_miso    <= 1'b0;
		end
	else if(!spi_cs_flag)            //cs 信号低电平时
		begin
			case(state)
				idle:
					begin
						state       <= rxd_addr;
						cnt         <= 'd0;
						addr        <= 'd0;
						rxdata      <= 'd0;
						txreq       <= 1'b0;
						spi_miso    <= 1'b0;
					end
				rxd_addr:
					begin
						if(cnt == ADDR_WIDTH)
							begin
								state <= jude_wr_rd;
							end
						else 
							if(spi_sck_pos)
							begin
								cnt <= cnt + 1;
								addr <= {addr[ADDR_WIDTH-2:0],spi_mosi_flag};
							end
					end
				jude_wr_rd:
					begin
						cnt <= 0;
					//	if(spi_sck_neg)
					//	begin
							if(addr[ADDR_WIDTH-1] == 0)
								state <= rxd_data;
							else
								begin
									txdata_reg <= txdata;      
									state <= txd_data;                               
								end
						//end
					//	else
					//		state <= jude_wr_rd;  
					end
				rxd_data:
					begin
						if(cnt == DATA_WIDTH)
							begin
								state      <= end_sta;
							end
						else 
							if(spi_sck_pos)
							begin
								cnt <= cnt + 1;
								rxdata <= {rxdata[DATA_WIDTH-2:0],spi_mosi_flag};
							end                                
					end
				txd_data:
					begin
						txreq <= 1;   
						if(cnt == DATA_WIDTH)
							begin
								state <= end_sta;
							end
						else 
						if(spi_sck_neg)
							begin
								cnt <= cnt + 1;
								spi_miso <= txdata_reg[DATA_WIDTH-1];
								txdata_reg <= {txdata_reg[DATA_WIDTH-2:0],1'b0};
							end                        
					end
				end_sta:	state <= end_sta; 
				default:	state <= idle; 
			endcase      
		end
	else
		begin
			state       <= idle;
			cnt         <= 'd0;
			addr        <= 'd0;
			rxdata      <= 'd0;
			txreq       <= 1'b0;
			spi_miso    <= 1'b0;
		end
end
endmodule
