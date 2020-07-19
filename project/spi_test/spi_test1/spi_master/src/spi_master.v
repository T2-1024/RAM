`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/07 15:59:26
// Design Name: 
// Module Name: spi_master
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


module spi_master
#(
	parameter DATA_WIDTH= 16,
	parameter ADDR_WIDTH= 8
)
(
	input                       sys_clk,	
	input                       rst_n,
	
	output      reg                spi_cs,
	output                      spi_sck,
	output                      spi_mosi,
	input                       spi_miso,
	
	input                       CPOL,		//极性
	input                       CPHA,		//相位
	input	[15:0]				clk_div,	//spi_sclk = clk/((clk_div+2)*2)
	input						rw_start,
	output						rw_ack,		//结束标志
	output						miso_valid,
   	output		 	            mosi_valid,
	input	[ADDR_WIDTH-1:0]	addr,
	input	[DATA_WIDTH-1:0]	txdata,
	output	[DATA_WIDTH-1:0]	rxdata
);
	localparam				ADDR_CNT_EDGE = ADDR_WIDTH + ADDR_WIDTH;
    localparam                DATA_CNT_EDGE = DATA_WIDTH + DATA_WIDTH;
	localparam				CNT_EDGE	  = ADDR_CNT_EDGE + DATA_CNT_EDGE;
	localparam				SHIFT_WIDTH   = ADDR_WIDTH + DATA_WIDTH;
	//状态（格雷码）
	localparam				IDLE            = 3'b001;	// 'd1
	localparam				DCLK_EDGE       = 3'b011;	// 'd3
	localparam				DCLK_IDLE       = 3'b010;	// 'd2
	localparam				ACK             = 3'b110;	// 'd6
	localparam				LAST_HALF_CYCLE = 3'b100;	// 'd4
	localparam				ACK_WAIT        = 3'b101;	// 'd5
	
	reg						DCLK_reg;
	reg	[ADDR_WIDTH-1:0]	addr_shift;
	reg	[DATA_WIDTH-1:0]	txdata_shift;
	reg	[DATA_WIDTH-1:0]	rxdata_shift;
	reg	[2:0]				state;
	reg	[2:0]				next_state;
	reg	[15:0]				clk_cnt;
	reg	[5:0]				clk_edge_cnt;
	reg	       				rw_cmd_reg;
	
	//MOSI，空闲状态值无效（清零），写状态输出有效数据
	assign spi_mosi = (state != IDLE) ? 
				  ((clk_edge_cnt <= ADDR_CNT_EDGE-1) ? addr_shift[ADDR_WIDTH-1] : ((!rw_cmd_reg) ? txdata_shift[DATA_WIDTH-1]  : 1'b0)) : 1'b0;
	assign spi_sck = DCLK_reg;
	assign rxdata = rxdata_shift[DATA_WIDTH-1:0];
	assign rw_ack = (state == ACK);
	assign mosi_valid = (state != IDLE) ? ((rw_cmd_reg) ? ((clk_edge_cnt <= ADDR_CNT_EDGE) ? 1'b1: 1'b0): 1'b1) : 1'b0; 
	assign miso_valid = ((state != IDLE) &&(rw_cmd_reg) &&(clk_edge_cnt > ADDR_CNT_EDGE)) ? 1'b1 : 1'b0 ; 
	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				state <= IDLE;
			else 
			begin
				if((state == IDLE)&&(rw_start == 1'b1))
				    state <= DCLK_IDLE;
				else
				    state <= next_state;
			end
		end

	always@(*)
		begin
			case(state)
				IDLE:begin
							spi_cs <= 1;
				/*	if(rw_start == 1'b1)   //至少两个个系统时钟周期，保证
						begin
							next_state <= DCLK_IDLE;
							spi_cs <= 0;
						end
					else
						begin
							next_state <= IDLE;
						end*/
					end
				DCLK_IDLE:begin
						spi_cs <= 0;
					//half a SPI clock cycle produces a clock edge
					if(clk_cnt == clk_div)
						next_state <= DCLK_EDGE;
					else
						next_state <= DCLK_IDLE;
						end
				DCLK_EDGE:
					//a SPI byte with a total of 16 clock edges
					if(clk_edge_cnt == CNT_EDGE-1)
						next_state <= LAST_HALF_CYCLE;
					else
						next_state <= DCLK_IDLE;
				//this is the last data edge		
				LAST_HALF_CYCLE:
					if(clk_cnt == clk_div)
						next_state <= ACK;
					else
						next_state <= LAST_HALF_CYCLE; 
				//send one byte complete		
				ACK:
					begin
						next_state <= ACK_WAIT;
						spi_cs <= 1;
					end
				//wait for one clock cycle, to ensure that the cancel request signal
				ACK_WAIT:
					next_state <= IDLE;
				default:
					next_state <= IDLE;
			endcase
		end

	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				DCLK_reg <= 1'b0;
			else if(state == IDLE)
				DCLK_reg <= CPOL;
			else if(state == DCLK_EDGE)
				DCLK_reg <= ~DCLK_reg;//SPI clock edge
		end
	//SPI clock wait counter
	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				clk_cnt <= 16'd0;
			else if(state == DCLK_IDLE || state == LAST_HALF_CYCLE) 
				clk_cnt <= clk_cnt + 16'd1;
			else
				clk_cnt <= 16'd0;
		end
	//SPI clock edge counter
	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				clk_edge_cnt <= 5'd0;
			else if(state == DCLK_EDGE)
				clk_edge_cnt <= clk_edge_cnt + 5'd1;
			else if(state == IDLE)
				clk_edge_cnt <= 5'd0;
		end
	//SPI data output
	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					addr_shift <= 8'd0;
					txdata_shift <= 'd0;
					rw_cmd_reg <= 1'b0;				// 默认为写指令
				end
			else if(state == IDLE && rw_start)		// 锁存/加载指令及数据
				begin
					addr_shift <= addr;
					rw_cmd_reg <= addr[7];
					txdata_shift <= txdata;
				end
			else if(state == DCLK_EDGE)
				begin
				//rw_cmd + addr
					if(clk_edge_cnt <= ADDR_CNT_EDGE)
						begin
							if(CPHA == 1'b0 && clk_edge_cnt[0] == 1'b1)
								addr_shift <= {addr_shift[ADDR_WIDTH-2:0],addr_shift[ADDR_WIDTH-1]};
							else if(CPHA == 1'b1 && (clk_edge_cnt != 'd0 && clk_edge_cnt[0] == 1'b0))
								addr_shift <= {addr_shift[ADDR_WIDTH-2:0],addr_shift[ADDR_WIDTH-1]};
						end
				//txdata
					else
						begin
							if(CPHA == 1'b0 && clk_edge_cnt[0] == 1'b1)
								txdata_shift <= {txdata_shift[DATA_WIDTH-2:0],txdata_shift[DATA_WIDTH-1]};
							else if(CPHA == 1'b1 && (clk_edge_cnt != 'd0 && clk_edge_cnt[0] == 1'b0))
								txdata_shift <= {txdata_shift[DATA_WIDTH-2:0],txdata_shift[DATA_WIDTH-1]};
						end
				end
		end
	//SPI data input
	always@(posedge sys_clk or negedge rst_n)
		begin
			if(!rst_n)
				rxdata_shift <= 'd0;
			else if(state == IDLE && rw_start)
				rxdata_shift <= 'h00;
			else if(state == DCLK_EDGE)
				if(CPHA == 1'b0 && clk_edge_cnt[0] == 1'b0)
					rxdata_shift <= {rxdata_shift[DATA_WIDTH-2:0],spi_miso};
				else if(CPHA == 1'b1 && (clk_edge_cnt[0] == 1'b1))
					rxdata_shift <= {rxdata_shift[DATA_WIDTH-2:0],spi_miso};
		end
endmodule 
