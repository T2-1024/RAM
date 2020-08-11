`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/29 09:53:28
// Design Name: 
// Module Name: xadc_test
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

module xadc_test(
input   sys_clk
/*
//register io
input           rst_n ,
output	reg	[15:0]    temperature_dout , //Data
output	reg	[15:0]    vccint_dout ,
output	reg	[15:0]    vccaux_dout ,
output	reg	[15:0]    vccbram_dout ,
	
output	reg	temperature_dout_en ,    //Valid
output	reg	vccint_dout_en ,
output	reg	vccaux_dout_en ,
output	reg	vccbram__dout_en 
*/
    );
    wire    rst_n;
    wire    clk;
    wire    clk_25mhz;
    wire    clk_50mhz;
    wire    clk_100mhz;
    wire    clk_125mhz;
    wire    clk_156mhz;

   //-------------------------------------
   //------------ CLOCK------------- 
      clk_wiz_0 clk_inst
       (
        // Clock out ports
        .clk_out1(clk_25mhz),     // output clk_out1
        .clk_out2(clk_50mhz),     // output clk_out2
        .clk_out3(clk_100mhz),     // output clk_out3
        .clk_out4(clk_125mhz),     // output clk_out4
        // Status and control signals
        .locked(rst_n),       // output locked
       // Clock in ports
        .clk_in1(sys_clk));      // input clk_in1
        
        assign clk = clk_100mhz;
   //-------------------------------------
   //---- XADC IP INST ------------- 
   wire [15:0]	di_in;
   wire [6:0]	daddr_in;
   wire			den_in;
   wire			dwe_in;
   wire			drdy_out;
   wire [15:0]	do_out;
   
   wire [4:0]	channel_out;
   wire			eoc_out;
   wire			eos_out;
   wire			busy_out;
   
   //XADC IP (Mode:Channel Sequencer)
   xadc_wiz_0 xadc_ip_inst (
     .di_in(di_in),                              // input wire [15 : 0] di_in
     .daddr_in(daddr_in),                        // input wire [6 : 0] daddr_in
     .den_in(den_in),                            // input wire den_in
     .dwe_in(dwe_in),                            // input wire dwe_in
     .drdy_out(drdy_out),                        // output wire drdy_out
     .do_out(do_out),                            // output wire [15 : 0] do_out
     .dclk_in(clk),                          // input wire dclk_in
     .reset_in(!rst_n),                        // input wire reset_in
     .vp_in(1'b0),                              // input wire vp_in
     .vn_in(1'b0),                              // input wire vn_in
     .user_temp_alarm_out(),  // output wire user_temp_alarm_out
     .vccint_alarm_out(),        // output wire vccint_alarm_out
     .vccaux_alarm_out(),        // output wire vccaux_alarm_out
     .ot_out(),                            // output wire ot_out
     .channel_out(channel_out),                  // output wire [4 : 0] channel_out
     .eoc_out(eoc_out),                          // output wire eoc_out
     .alarm_out(),                      // output wire alarm_out
     .eos_out(eos_out),                          // output wire eos_out
     .busy_out(busy_out)                        // output wire busy_out
   );
   //only Read
    assign di_in = 16'd0;   //not used
    assign dwe_in = 1'b0;   //not used
    assign den_in = eoc_out;
    assign daddr_in = {2'd0,channel_out};
    
    //-------------------------------------
    //Read Temperature Data
	reg	[15:0]    temperature_dout ;
    reg    [15:0]    vccint_dout ;
    reg    [15:0]    vccaux_dout ;
    reg    [15:0]    vccbram_dout ;
    
    reg    temperature_dout_en ;
    reg    vccint_dout_en ;
    reg    vccaux_dout_en ;
    reg    vccbram__dout_en ;
	always @(posedge clk or negedge rst_n)
        begin
            if(!rst_n) 
                begin
                    temperature_dout <= 16'd0;
                    vccint_dout <= 16'd0;
                    vccaux_dout <= 16'd0;
                    vccbram_dout <= 16'd0;
                    
                    temperature_dout_en <= 1'b0;
                    vccint_dout_en <= 1'b0;
                    vccaux_dout_en <= 1'b0;
                    vccbram__dout_en <= 1'b0;
                end
            else 
                begin
                    if((drdy_out) &&(channel_out == 5'd0))     // Latch ADCcode of On-chip-temperature
                        begin
                            temperature_dout <= do_out;
                            temperature_dout_en <= drdy_out;
                        end
                    else if((drdy_out) &&(channel_out == 5'd1))     // Latch ADCcode of VCCINT
                        begin
                            vccint_dout <= do_out;
                            vccint_dout_en <= drdy_out;
                        end
                    else if((drdy_out) &&(channel_out == 5'd2))     // Latch ADCcode of VCCAUX
                        begin
                            vccaux_dout <= do_out;
                            vccaux_dout_en <= drdy_out;
                        end
                    else if((drdy_out) &&(channel_out == 5'd6))        // Latch ADCcode of VCCBRAM
                        begin
                            vccbram_dout <= do_out;
                            vccbram__dout_en <= drdy_out;
                        end
                    else
                        begin
                            temperature_dout_en <= 1'b0;
                            vccint_dout_en <= 1'b0;
                            vccaux_dout_en <= 1'b0;
                            vccbram__dout_en <= 1'b0;
                        end
                end
        end
        

	//-------------------------------------
	//watch value
	ila_0 watch_value_inst (
        .clk(clk), // input wire clk
    
    
        .probe0(di_in), // input wire [15:0]  probe0  
        .probe1(daddr_in), // input wire [6:0]  probe1 
        .probe2(den_in), // input wire [0:0]  probe2 
        .probe3(dwe_in), // input wire [0:0]  probe3 
        .probe4(drdy_out), // input wire [0:0]  probe4 
        .probe5(do_out), // input wire [15:0]  probe5 
        .probe6(rst_n), // input wire [0:0]  probe6 
        .probe7(channel_out), // input wire [4:0]  probe7 
        .probe8(eoc_out), // input wire [0:0]  probe8 
        .probe9(eos_out), // input wire [0:0]  probe9 
        .probe10(busy_out), // input wire [0:0]  probe10 
        .probe11(temperature_dout_en), // input wire [0:0]  probe11 
        .probe12(temperature_dout) // input wire [15:0]  probe12 
    );

endmodule
