#FPGA3 - U13  SPI_MASTER

# 时钟 XC7V3_2CPLD_CLK "AV18"	
set_property PACKAGE_PIN AV18 [get_ports SYS_CLK0]			
set_property IOSTANDARD LVCMOS18 [get_ports SYS_CLK0]

## 复位 XC7V3_RSTN "BC19"
set_property PACKAGE_PIN BC19 [get_ports RESET_N]		
set_property IOSTANDARD LVCMOS18 [get_ports RESET_N]


## SPI时钟 XC7V2_2XC7V3_IO1_C "U25"
set_property PACKAGE_PIN U25 [get_ports SPI_SCK]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_SCK]
## SPI片选 XC7V2_2XC7V3_IO2_C "T25"
set_property PACKAGE_PIN T25 [get_ports SPI_CS]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_CS]
## SPI从输出 XC7V2_2XC7V3_IO3_C "AL18"
set_property PACKAGE_PIN AL18 [get_ports SPI_MISO]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_MISO]
## SPI从输入 XC7V2_2XC7V3_IO4_C "AJ16"
set_property PACKAGE_PIN AJ16 [get_ports SPI_MOSI]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_MOSI]
