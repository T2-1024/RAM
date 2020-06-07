//================================================================================
//
//  Date 		  : 	2019.12.26
//	By   		  :	  T2_1024
//  Revision	:	  1.0
//	Language	:	  verilog
//	File	  	:	  ram_20191226.v
//  Type      :   source
//
//================================================================================
//									Description
//
// 	Module Name : ram
//
//		Width				:	32
//		Depth				:	256
//		Type of data port 	: 	inout
//================================================================================
//  Change Description:
//
//			None
//
//--------------------------------------------------------------------------------//
//
//
//////////

module ram(
	input			clk,
	input			rst_n,
	input			en_write,
	input			en_read,
	input	[7:0]	addr_ram_in,
	inout	[31:0]	data_ram_io
	);

    reg		[31:0]	ram_data[255:0];  //width=32,depth=356 
    integer			i;   
    reg		[31:0]	data_ram_out;
	
/////////////////
//
	always @(posedge clk or posedge rst_n)
	begin
		if (rst_n)									//reset, clearing by word
			begin
				for(i=0;i<=255;i=i+1)
				ram_data[i] <= 32'b0;
			end
		else if (en_write)
			begin
				ram_data[addr_ram_in] <= data_ram_io;
			end
		else if (en_read) 
			begin
				data_ram_out <= ram_data[addr_ram_in];
			end
		else											//no-read and no-write
			begin
				data_ram_out <= 32'bz;
			end
	end
	
////////////////
//output,assign
	assign data_ram_io = en_read? data_ram_out : 32'bz;
	
endmodule
