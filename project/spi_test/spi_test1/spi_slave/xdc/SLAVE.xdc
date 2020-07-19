#FPGA2 - U7  SPI_SLAVE

# 时钟 XC7V2_2CPLD_CLK "W30"	
set_property PACKAGE_PIN W30 [get_ports SYS_CLK1]			
set_property IOSTANDARD LVCMOS18 [get_ports SYS_CLK1]

## 复位 XC7V2_RSTN "AK28"
set_property PACKAGE_PIN AK28 [get_ports RESET_N]		
set_property IOSTANDARD LVCMOS18 [get_ports RESET_N]


## SPI时钟 XC7V2_2XC7V3_IO1_C "L14"
set_property PACKAGE_PIN L14 [get_ports SPI_CLK]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_CLK]
## SPI片选 XC7V2_2XC7V3_IO2_C "K14"
set_property PACKAGE_PIN K14 [get_ports SPI_CS]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_CS]
## SPI从输出 XC7V2_2XC7V3_IO3_C "K17"
set_property PACKAGE_PIN K17 [get_ports SPI_MISO]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_MISO]
## SPI从输入 XC7V2_2XC7V3_IO4_C "J17"
set_property PACKAGE_PIN J17 [get_ports SPI_MOSI]		
set_property IOSTANDARD LVCMOS18 [get_ports SPI_MOSI]




#------------------------------------------------------
#ERROR: [Labtools 27-3165] End of startup status: LOW"尝试
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
