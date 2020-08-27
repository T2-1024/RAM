`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/10 13:51:42
// Design Name: 
// Module Name: emif_top
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

module emif_if(
	input         sys_clk,
	input         sys_rstn,
	
	//***** DSP EMIF PINS *****//
	input         DSP_EMIFA_NWE,
	input         DSP_EMIFA_NOE,
	input         DSP_EMIFA_NCS5,
	input         DSP_EMIFA_NCS2,
	input [23:0]  DSP_EMIFA_A,
	inout [15:0]  DSP_EMIFA_D,
	
	//***** REG *****//
	input [15:0] Node_ID,
	input [15:0] CNTSTATE,
	input [15:0] NSTATUS_0,
	output reg [15:0] NSTATUS_1,
	output reg [15:0] NSTATUS_2,
	output reg [15:0] NSTATUS_3,
	input  [15:0] cnt_125M,
	input  [15:0] Board_Status,
	input  [15:0] SubSYS_Status,
	output reg [15:0]dma0_start,
	output reg [15:0]dma0_state,
	output reg [15:0]dma0_trans_size_low,
	output reg [15:0]dma0_trans_size_high,
	output reg [15:0]dma0_all_trans_size_low,
	output reg [15:0]dma0_all_trans_size_high,
	output reg [15:0]dma0_addr_low,
	output reg [15:0]dma0_addr_high,
	
	output reg [15:0]dma1_start,
	output reg [15:0]dma1_state,
	output reg [15:0]dma1_trans_size_low,
	output reg [15:0]dma1_trans_size_high,
	output reg [15:0]dma1_all_trans_size_low,
	output reg [15:0]dma1_all_trans_size_high,
	output reg [15:0]dma1_addr_low,
	output reg [15:0]dma1_addr_high,
	
	output reg [15:0]Dma0_package_num_low,
	output reg [15:0]Dma0_package_num_high,
	output reg [15:0]Dma0_total_package_num_low,
	output reg [15:0]Dma0_total_package_num_high,
	output reg [15:0]Dma1_package_num_low,
	output reg [15:0]Dma1_package_num_high,
	output reg [15:0]Dma1_total_package_num_low,
	output reg [15:0]Dma1_total_package_num_high
    );
	
     reg 			   rden_sig;
     
	//user reg if
     wire   [23:0]      reg_addr;
     wire   [15:0]      reg_val_in;
     reg    [15:0]      reg_val_out;
     reg                reg_wr_en;
     reg                reg_rd_en;  
     
     reg [15:0]      DSP_EMIFA_D_r;
     reg [23:0]      DSP_EMIFA_A_r;
     reg             DSP_EMIFA_NWE_r; 
     
     reg             DSP_EMIFA_NOE_r; 
     reg             DSP_EMIFA_NCS5_r; 
     reg             DSP_EMIFA_NCS2_r;
     reg             DSP_EMIFA_NWE_r1; 
     reg             DSP_EMIFA_NOE_r1; 
     reg             DSP_EMIFA_NWE_r2; 
     reg             DSP_EMIFA_NOE_r2;
     reg             DSP_EMIFA_NWE_r3; 
     reg             DSP_EMIFA_NOE_r3;  
     
     wire            NWE_n, NOE_n, NOE_q;   
     
     assign  reg_addr = {DSP_EMIFA_A_r[22:0],DSP_EMIFA_A_r[23]};
     assign  reg_val_in = DSP_EMIFA_D_r;
     assign  DSP_EMIFA_D = rden_sig ? (reg_val_out) : 16'hz;
     
     always @ (posedge sys_clk or negedge sys_rstn) 
	 begin
		 if (!sys_rstn) 
			 begin
				 DSP_EMIFA_D_r <= 23'b0;
				 DSP_EMIFA_A_r <= 16'b0;
				 DSP_EMIFA_NWE_r <= 1'b1;
				 DSP_EMIFA_NOE_r <= 1'b1;
				 DSP_EMIFA_NCS2_r <= 1'b1;
				 DSP_EMIFA_NCS5_r <= 1'b1;
			 end 
		 else 
			 begin
				 DSP_EMIFA_D_r <= DSP_EMIFA_D;
				 DSP_EMIFA_A_r <= DSP_EMIFA_A;
				 DSP_EMIFA_NWE_r <= DSP_EMIFA_NWE;
				 DSP_EMIFA_NOE_r <= DSP_EMIFA_NOE;
				 DSP_EMIFA_NCS5_r <= DSP_EMIFA_NCS5;
				 DSP_EMIFA_NCS2_r <= DSP_EMIFA_NCS2;
			 end
     end
     
     always @ (posedge sys_clk or negedge sys_rstn) 
	 begin
		 if(!sys_rstn) 
			 begin
				 DSP_EMIFA_NWE_r1 <= 1'b0;
				 DSP_EMIFA_NWE_r2 <= 1'b0;
				 DSP_EMIFA_NWE_r3 <= 1'b0;
				 DSP_EMIFA_NOE_r1 <= 1'b0;
				 DSP_EMIFA_NOE_r2 <= 1'b0;
				 DSP_EMIFA_NOE_r3 <= 1'b0;
			 end 
		 else 
			 begin    
				 DSP_EMIFA_NWE_r1 <= DSP_EMIFA_NWE_r;
				 DSP_EMIFA_NWE_r2 <= DSP_EMIFA_NWE_r1;
				 DSP_EMIFA_NWE_r3 <= DSP_EMIFA_NWE_r2;
				 DSP_EMIFA_NOE_r1 <= DSP_EMIFA_NOE_r;
				 DSP_EMIFA_NOE_r2 <= DSP_EMIFA_NOE_r1;
				 DSP_EMIFA_NOE_r3 <= DSP_EMIFA_NOE_r2;
			 end
     end
     
     assign  NWE_n = DSP_EMIFA_NWE_r3 & ~DSP_EMIFA_NWE_r2 & ~DSP_EMIFA_NWE_r1;	//negedge , start of low NWE
     assign  NOE_n = DSP_EMIFA_NOE_r3 & ~DSP_EMIFA_NOE_r2 & ~DSP_EMIFA_NOE_r1;	//negedge , start of low NWE
     assign  NOE_q = ~DSP_EMIFA_NOE_r3 & DSP_EMIFA_NOE_r2 & DSP_EMIFA_NOE_r1;	//posedge , end of low NOE
     
     //
     always @ (posedge sys_clk or negedge sys_rstn)
     begin
         if (!sys_rstn)
         	begin
         		reg_wr_en <= 1'b0;
         		reg_rd_en <= 1'b0;
         	end
         else if (!DSP_EMIFA_NCS5_r && NWE_n)
         	reg_wr_en <= 1'b1;
         else if (!DSP_EMIFA_NCS5_r && NOE_n)
         	reg_rd_en <= 1'b1;
         else
         	begin
         		reg_wr_en <= 1'b0;
         		reg_rd_en <= 1'b0;
         	end
     end 
     
	//change inout
     always @ (posedge sys_clk or negedge sys_rstn) 
	 begin
		 if (!sys_rstn)
			 rden_sig <= 1'b0;
		 else if ((!DSP_EMIFA_NCS5_r && NOE_n)  || (!DSP_EMIFA_NCS2_r && NOE_n))
			 rden_sig <= 1'b1;
		 else if (NOE_q)
			 rden_sig <= 1'b0;    
     end
     
	 always @ (posedge sys_clk or negedge sys_rstn)
	 begin
		 if(!sys_rstn) 
			 begin
				NSTATUS_1                     <= 16'd0;
				NSTATUS_2                     <= 16'd0;
				NSTATUS_3                     <= 16'd0;
				dma0_start                    <= 16'd0;
				dma0_state                    <= 16'd0;
				dma0_trans_size_low           <= 16'd0;
				dma0_trans_size_high          <= 16'd0;
				dma0_all_trans_size_low       <= 16'd0;
				dma0_all_trans_size_high      <= 16'd0;
				dma0_addr_low                 <= 16'd0;
				dma0_addr_high                <= 16'd0;
				dma1_start                    <= 16'd0;
				dma1_state                    <= 16'd0;
				dma1_trans_size_low           <= 16'd0;
				dma1_trans_size_high          <= 16'd0;
				dma1_all_trans_size_low       <= 16'd0;
				dma1_all_trans_size_high      <= 16'd0;
				dma1_addr_low                 <= 16'd0;
				dma1_addr_high                <= 16'd0;
				Dma0_package_num_low          <= 16'd0;
				Dma0_package_num_high         <= 16'd0;
				Dma0_total_package_num_low    <= 16'd0;
				Dma0_total_package_num_high   <= 16'd0;
				Dma1_package_num_low          <= 16'd0;
				Dma1_package_num_high         <= 16'd0;
				Dma1_total_package_num_low    <= 16'd0;
			 end
		  else 
			  begin
				  if(reg_wr_en)
					  begin
						  case(reg_addr)
							24'h3: begin NSTATUS_1 <=  reg_val_in; end
							24'h4: begin NSTATUS_2 <=  reg_val_in; end  
							24'h5: begin NSTATUS_3 <=  reg_val_in; end
							24'h10: begin dma0_start <=  reg_val_in; end
							24'h11: begin dma0_state <=  reg_val_in; end
							24'h12: begin dma0_trans_size_low <=  reg_val_in; end
							24'h13: begin dma0_trans_size_high <=  reg_val_in; end
							24'h14: begin dma0_all_trans_size_low <=  reg_val_in; end
							24'h15: begin dma0_all_trans_size_high <=  reg_val_in; end 
							24'h16: begin dma0_addr_low <=  reg_val_in; end
							24'h17: begin dma0_addr_high <=  reg_val_in; end
							24'h18: begin dma1_start <=  reg_val_in; end
							24'h19: begin dma1_state <=  reg_val_in; end
							24'h1a: begin dma1_trans_size_low <=  reg_val_in; end
							24'h1b: begin dma1_trans_size_high <=  reg_val_in; end
							24'h1c: begin dma1_all_trans_size_low <=  reg_val_in; end
							24'h1d: begin dma1_all_trans_size_high <=  reg_val_in; end 
							24'h1e: begin dma1_addr_low <=  reg_val_in; end
							24'h1f: begin dma1_addr_high <=  reg_val_in; end
							24'h20: begin Dma0_package_num_low <=  reg_val_in; end
							24'h21: begin Dma0_package_num_high <=  reg_val_in; end
							24'h22: begin Dma0_total_package_num_low <=  reg_val_in; end
							24'h23: begin Dma0_total_package_num_high <=  reg_val_in; end
							24'h24: begin Dma1_package_num_low <=  reg_val_in; end
							24'h25: begin Dma1_package_num_high <=  reg_val_in; end
							24'h26: begin Dma1_total_package_num_low <=  reg_val_in; end
							24'h27: begin Dma1_total_package_num_high <=  reg_val_in; end                  
						  endcase
					  end                              
			  end
	 end

	always @ (posedge sys_clk or negedge sys_rstn)
    begin
      if(!sys_rstn) 
          begin
              reg_val_out <=  16'd0;   
          end
      else 
          begin
              if(reg_rd_en)
                  begin
                      case(reg_addr)
                            24'h0:  reg_val_out       <= Node_ID;                     
                            24'h1:  reg_val_out       <= CNTSTATE;                    
                            24'h2:  reg_val_out       <= NSTATUS_0;                   
                            24'h3:  reg_val_out       <= NSTATUS_1;                   
                            24'h4:  reg_val_out       <= NSTATUS_2;                   
                            24'h5:  reg_val_out       <= NSTATUS_3;                   
                            24'h6:  reg_val_out       <= cnt_125M;                    
                            24'he:  reg_val_out       <= Board_Status;                
                            24'hf:  reg_val_out       <= SubSYS_Status;               
                            24'h10: reg_val_out       <= dma0_start;                  
                            24'h11: reg_val_out       <= dma0_state;                  
                            24'h12: reg_val_out       <= dma0_trans_size_low;         
                            24'h13: reg_val_out       <= dma0_trans_size_high;        
                            24'h14: reg_val_out       <= dma0_all_trans_size_low;     
                            24'h15: reg_val_out       <= dma0_all_trans_size_high;    
                            24'h16: reg_val_out       <= dma0_addr_low;               
                            24'h17: reg_val_out       <= dma0_addr_high;              
                            24'h18: reg_val_out       <= dma1_start;                  
                            24'h19: reg_val_out       <= dma1_state;                  
                            24'h1a: reg_val_out       <= dma1_trans_size_low;         
                            24'h1b: reg_val_out       <= dma1_trans_size_high;        
                            24'h1c: reg_val_out       <= dma1_all_trans_size_low;     
                            24'h1d: reg_val_out       <= dma1_all_trans_size_high;    
                            24'h1e: reg_val_out       <= dma1_addr_low;               
                            24'h1f: reg_val_out       <= dma1_addr_high;              
                            24'h20: reg_val_out       <= Dma0_package_num_low;        
                            24'h21: reg_val_out       <= Dma0_package_num_high;       
                            24'h22: reg_val_out       <= Dma0_total_package_num_low;  
                            24'h23: reg_val_out       <= Dma0_total_package_num_high; 
                            24'h24: reg_val_out       <= Dma1_package_num_low;        
                            24'h25: reg_val_out       <= Dma1_package_num_high;       
                            24'h26: reg_val_out       <= Dma1_total_package_num_low;  
                            24'h27: reg_val_out       <= Dma1_total_package_num_high; 
                          default:  reg_val_out       <= 16'd0;
                      endcase
                  end                               
          end
    end
 
	ila_0  
	(
		.clk(sys_clk), // input wire clk
		.probe0(DSP_EMIFA_NWE), // input wire [0:0]  probe0  
		.probe1(DSP_EMIFA_NOE), // input wire [0:0]  probe1 
		.probe2(DSP_EMIFA_NCS5), // input wire [0:0]  probe2 
		.probe3(DSP_EMIFA_NCS2), // input wire [0:0]  probe3 
		.probe4(DSP_EMIFA_A), // input wire [23:0]  probe4 
		.probe5(DSP_EMIFA_D), // input wire [15:0]  probe5
		.probe6(reg_addr), // input wire [23:0]  probe6 
		.probe7(reg_val_in) // input wire [15:0]  probe7
	);

	ila_1  
	(
		.clk(sys_clk), // input wire clk
		.probe0(dma0_start), // input wire [15:0]  probe0  
		.probe1(dma0_state), // input wire [15:0]  probe1 
		.probe2(dma0_trans_size_low), // input wire [15:0]  probe2 
		.probe3(dma0_trans_size_high), // input wire [15:0]  probe3 
		.probe4(dma0_all_trans_size_low), // input wire [15:0]  probe4 
		.probe5(dma0_all_trans_size_high), // input wire [15:0]  probe5 
		.probe6(dma0_addr_low), // input wire [15:0]  probe6 
		.probe7(dma0_addr_high), // input wire [15:0]  probe7 
		.probe8(dma1_start), // input wire [15:0]  probe8 
		.probe9(dma1_state), // input wire [15:0]  probe9 
		.probe10(dma1_trans_size_low), // input wire [15:0]  probe10 
		.probe11(dma1_trans_size_high), // input wire [15:0]  probe11 
		.probe12(dma1_all_trans_size_low), // input wire [15:0]  probe12 
		.probe13(dma1_all_trans_size_high), // input wire [15:0]  probe13 
		.probe14(dma1_addr_low), // input wire [15:0]  probe14 
		.probe15(dma1_addr_high), // input wire [15:0]  probe15 
		.probe16(Dma0_package_num_low), // input wire [15:0]  probe16 
		.probe17(Dma0_package_num_high), // input wire [15:0]  probe17 
		.probe18(Dma0_total_package_num_low), // input wire [15:0]  probe18 
		.probe19(Dma0_total_package_num_high), // input wire [15:0]  probe19 
		.probe20(Dma1_package_num_low), // input wire [15:0]  probe20 
		.probe21(Dma1_package_num_high), // input wire [15:0]  probe21 
		.probe22(Dma1_total_package_num_low), // input wire [15:0]  probe22 
		.probe23(Dma1_total_package_num_high) // input wire [15:0]  probe23
	);
	
endmodule
