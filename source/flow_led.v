//板块化书写，明了易移植
//流水灯范例
module flow_led
  (
    input clk_25mhz,  //Source clock
    output [3:0]led   //four LED
  );
  
  reg [15:0]  cnt_40ns;
  reg [15:0]  cnt_1ms;
  reg [3:0]   led_reg = 4'b0001;  //初始化赋值
  reg     clk_1ms_reg;
  wire    clk_1ms;
  
  assign led = led_reg;
  
  //ns级转换位ms级
  //gen 1ms clock
  assign clk_1ms = clk_1ms_reg;
  always@(posedge clk_25mhz)
    begin
      if(cnt_40ns <= 'd12499)
        begin
          cnt_40ns <= cnt_40ns + 1'b1;
          clk_1ms_reg = clk_1ms_reg;
        end
      else
        begin
          cnt_40ns <= 'd0;
          clk_1ms_reg = ~clk_1ms_reg;
        end
    end
    
  //延时计数
  always@(posedge clk_1ms)
    begin
      if(cnt_1ms <= 'd199)
        cnt_1ms <= cnt_1ms + 1'b1;
      else
        cnt_1ms <= 'd0;
    end
    
  //移位实现流动
  always @(posedge clk_25mhz) 
    begin
      if(cnt_1ms == 16'd199) 
        led_reg[3:0] <= {led_reg[2:0],led_reg[3]};
      else
        led_reg <= led_reg;
    end

endmodule
