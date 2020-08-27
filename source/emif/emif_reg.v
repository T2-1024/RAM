`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/22 14:58:36
// Design Name: 
// Module Name: emif_reg
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


module emif_reg(
	input         clk_in1_p,
	input         clk_in1_n,
	input         reset_n,
	input         DSP_EMIFA_NWE,
	input         DSP_EMIFA_NOE,
	input         DSP_EMIFA_NCS5,
	input         DSP_EMIFA_NCS2,
	input [23:0]  DSP_EMIFA_A,
	inout [15:0]  DSP_EMIFA_D,
	
	input 		SRIO_init,      
	input 		SPI_comm,       
	input 		DSP0_SRIO_init, 
	input 		sd_125M,        
	input 		lock_125M,      
	input 		lock_25M,
	
	input 		FIBRA1_BITS,     
	input 		FIBRA_RX_BITS,   
	input 		FIBRA_TX_BITS,   
	input 		FIBRA_PWRON, 
	input		 DSP1_BITS,       
	input 		DSP1_PWRON,  
	input		 FPGA2_BITS,      
	input		 FPGA2_PWRON, 
	input		 FPGA1_BITS,      
	input		 FPGA1_PWRON, 
	input		 CPLD2,           
	input		 CPLD1,           
	 
	input		 ADC2BD,  
	input		 ADC1BD,  
	input		 MWBD  ,  
	   
	output		 dma0_start,                     
	output		 dma0_state,                     
	output [31:0]dma0_trans_size,            
	output [31:0]dma0_all_trans_size,        
	output [31:0]dma0_addr,                  
	output [31:0]Dma0_package_num,           
	output [31:0]Dma0_total_package_num,     
	                                             
	output		 dma1_start,                     
	output		 dma1_state,                     
	output [31:0]dma1_trans_size,            
	output [31:0]dma1_all_trans_size,        
	output [31:0]dma1_addr,                  
	output [31:0]Dma1_package_num,           
	output [31:0]Dma1_total_package_num     

    );
    
	wire clk_156m;
	wire clk_125m;
	wire clk_25m;
	wire [15:0] NSTATUS_0;
	wire [15:0] Board_Status;
	wire [15:0] SubSYS_Status;
	wire [15:0] cnt_125M;

	assign  NSTATUS_0[11] = SRIO_init;
	assign  NSTATUS_0[10] = SPI_comm;
	assign  NSTATUS_0[6]  = DSP0_SRIO_init;
	assign  NSTATUS_0[2]  = sd_125M;
	assign  NSTATUS_0[1]  = lock_125M;
	assign  NSTATUS_0[0]  = lock_25M;
	
	assign  Board_Status[13]  = FIBRA1_BITS;
	assign  Board_Status[12]  = FIBRA_RX_BITS;
	assign  Board_Status[11]  = FIBRA_TX_BITS;
	assign  Board_Status[10]  = FIBRA_PWRON;
	assign  Board_Status[7]  = DSP1_BITS;
	assign  Board_Status[6]  = DSP1_PWRON;
	assign  Board_Status[5]  = FPGA2_BITS;
	assign  Board_Status[4]  = FPGA2_PWRON;
	assign  Board_Status[3]  = FPGA1_BITS;
	assign  Board_Status[2]  = FPGA1_PWRON;
	assign  Board_Status[1]  = CPLD2;
	assign  Board_Status[0]  = CPLD1;
	
	assign  SubSYS_Status[3] = ADC2BD;
	assign  SubSYS_Status[2] = ADC1BD;
	assign  SubSYS_Status[1] = MWBD;

	clk_wiz clk_wiz_i
	(
	// Clock out ports
	    // Clock out ports
	    .clk_out1(clk_156m),	// output clk_out1
	    .clk_out2(clk_25m),		// output clk_out1
	    .clk_out3(clk_125m),	// output clk_out1
	   // Clock in ports
	    .clk_in1_p(clk_in1_p),	// input clk_in1_p
	    .clk_in1_n(clk_in1_n)
	);    // input clk_in1_n
    
	clk_dection
	#(
	    .CLK_NUM('d125)
	)
	clk_dection_i
	(
		.clk_25M_dect(clk_25m),
		.clk_125M_dect(clk_125m),
		.rst(!reset_n),
		.clk_run(clk_156m),
		.clk_flag(),
		.clk_cnt(cnt_125M)
	);
	
	wire		clk_1ms;
	reg [15:0]	cnt_40ns = 16'd0;
	reg 		clk_1ms_reg = 1'b0;
	
	always @ (posedge clk_25m )		//25MHZ
	begin
		if (cnt_40ns == 16'd12499)
			begin
				cnt_40ns <= 'd0;
				clk_1ms_reg <= ~clk_1ms_reg;	//1ms clock cycle
			end
		else
			cnt_40ns <= cnt_40ns + 1'b1;
	end
	
	assign clk_1ms = clk_1ms_reg;
	
	reg [15:0] count_1ms; 
	
	always @ (posedge clk_1ms )		//1ms clock
		begin
			count_1ms <= count_1ms + 1'b1;
		end
    
	emif_if emif_if_i
	(
		.sys_clk(clk_156m),                      
		.sys_rstn(reset_n),                     
		//***** DSP EMIF PINS *****//    
		.DSP_EMIFA_NWE(DSP_EMIFA_NWE),                
		.DSP_EMIFA_NOE(DSP_EMIFA_NOE),                
		.DSP_EMIFA_NCS5(DSP_EMIFA_NCS5),               
		.DSP_EMIFA_NCS2(DSP_EMIFA_NCS2),               
		.DSP_EMIFA_A(DSP_EMIFA_A),                  
		.DSP_EMIFA_D(DSP_EMIFA_D),                  
		
		//***** REG *****//              
		.Node_ID(16'hf0f1),                      
		.CNTSTATE(count_1ms),                     
		.NSTATUS_0(NSTATUS_0),                    
		.NSTATUS_1(),                    
		.NSTATUS_2(),                    
		.NSTATUS_3(),                    
		.cnt_125M(cnt_125M),
		
		.Board_Status(Board_Status),                 
		.SubSYS_Status(SubSYS_Status),                
		.dma0_start(dma0_start),                   
		.dma0_state(dma0_state),                   
		.dma0_trans_size_low(dma0_trans_size[15:0]),          
		.dma0_trans_size_high(dma0_trans_size[31:16]),         
		.dma0_all_trans_size_low(dma0_all_trans_size[15:0]),      
		.dma0_all_trans_size_high(dma0_all_trans_size[31:16]),     
		.dma0_addr_low(dma0_addr[15:0]),                
		.dma0_addr_high(dma0_addr[31:16]),               
		
		.dma1_start(dma1_start),                   
		.dma1_state(dma1_state),                   
		.dma1_trans_size_low(dma1_trans_size[15:0]),          
		.dma1_trans_size_high(dma1_trans_size[31:16]),         
		.dma1_all_trans_size_low(dma1_all_trans_size[15:0]),      
		.dma1_all_trans_size_high(dma1_all_trans_size[31:16]),     
		.dma1_addr_low(dma1_addr[15:0]),                
		.dma1_addr_high(dma1_addr[31:16]),               
		
		.Dma0_package_num_low(Dma0_package_num[15:0]),         
		.Dma0_package_num_high(Dma0_package_num[31:16]),        
		.Dma0_total_package_num_low(Dma0_total_package_num[15:0]),   
		.Dma0_total_package_num_high(Dma0_total_package_num[31:16]),  
		.Dma1_package_num_low(Dma1_package_num[15:0]),         
		.Dma1_package_num_high(Dma1_package_num[31:16]),        
		.Dma1_total_package_num_low(Dma1_total_package_num[15:0]),   
		.Dma1_total_package_num_high(Dma1_total_package_num[31:16])   
	);                           

endmodule
