`timescale 1ns / 1ps

module fifo_test
	(
		input			clk,		//50MHz ,sys_clk
		input			rst_n,		//reset ,low active
		input	[15:0]	data_in,
		output	[15:0]	data_out,
		output	[8:0]	rd_data_count, 	
		output	[8:0]	wr_data_count,
		output	full,
		output	empty		
	);
//		wire	[8:0]	rd_data_count ;
//		wire	[8:0]	wr_data_count ;
//		wire	full ;
//		wire	empty	;
	localparam W_IDLE = 1;
	localparam W_FIFO = 2; 
	localparam R_IDLE = 1;
	localparam R_FIFO = 2; 

	reg [2:0]  write_state;
	reg [2:0]  next_write_state;
	reg [2:0]  read_state;
	reg [2:0]  next_read_state;

	reg [15:0] w_data;
	wire [15:0] r_data;
	wire	wr_en;
	wire	rd_en;



//==================================
//gen process of writing FIFO 
	always@(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
			write_state <= W_IDLE;
		else
			write_state <= next_write_state;
	end

	always@(*)
	begin
		case(write_state)
			W_IDLE:
				if(empty == 1'b1)              	//if FIFO empty, goto write FIFO
					next_write_state <= W_FIFO;
				else
					next_write_state <= W_IDLE;
			W_FIFO:
				if(full == 1'b1)
					next_write_state <= W_IDLE;
				else
					next_write_state <= W_FIFO;
			default:
				next_write_state <= W_IDLE;
		endcase
	end

	assign wr_en = (next_write_state == W_FIFO) ? 1'b1 : 1'b0; 

	always@(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
			w_data <= 16'd0;
		else
			begin
			   if (wr_en == 1'b1)
					w_data <= data_in;
				else
					w_data <= 16'd0;		
			end
	end


//==================================
//gen process of Reading FIFO 
	always@(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
			read_state <= R_IDLE;
		else
			read_state <= next_read_state;
	end

	always@(*)
	begin
		case(read_state)
			R_IDLE:
			begin
				if(full == 1'b1)               //if FIFO full, goto read FIFO
					next_read_state <= R_FIFO;
				else
					next_read_state <= R_IDLE;
			end
			R_FIFO:
			begin
				if(empty == 1'b1)
					next_read_state <= R_IDLE;
				else
					next_read_state <= R_FIFO;
			end
			default:
				next_read_state <= R_IDLE;
		endcase
	end

	assign rd_en = (next_read_state == R_FIFO) ? 1'b1 : 1'b0; 
	assign data_out = r_data; 
	
//==================================
//FIFO IP inst
	fifo_ip fifo_ip_inst 
	(
		.rst            (~rst_n       ),   // input rst
		.wr_clk         (clk          ),   // input wr_clk
		.rd_clk         (clk          ),   // input rd_clk
		.din            (w_data       ),   // input [15 : 0] din
		.wr_en          (wr_en        ),   // input wr_en
		.rd_en          (rd_en        ),   // input rd_en
		.dout           (r_data       ),   // output [15 : 0] dout
		.full           (full         ),   // output full
		.empty          (empty        ),   // output empty
		.rd_data_count  (rd_data_count),   // output [8 : 0] rd_data_count
		.wr_data_count  (wr_data_count)    // output [8 : 0] wr_data_count
	);

//==================================
//monitor ip
	wire [255:0]  TRIG0;

	ila ila_inst 
	(
		.clk(clk),          // input [0:0] clk;
		.probe0(TRIG0)      // input [255:0] probe0;
	);                                                     

	assign  TRIG0[15:0]=w_data;  
	assign  TRIG0[16]=wr_en;  	
	assign  TRIG0[32:17]=r_data;  
	assign  TRIG0[33]=rd_en; 
	assign  TRIG0[34]=full;
	assign  TRIG0[35]=empty;
	assign  TRIG0[44:36]=rd_data_count;  	
	assign  TRIG0[53:45]=wr_data_count; 

 	
endmodule


