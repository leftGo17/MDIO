module tb_mdio();

reg			sys_clk;
reg			sys_rst_n;
reg			start_flag;
reg			r_w;
reg[4:0]	phy_add;
reg[4:0]	reg_add;
reg[15:0]	write_reg_data;
reg			mdio_in;

wire[15:0]	read_reg_data;
wire		mdio_en;
wire		mdio_o;
wire		mdc;

initial begin
	sys_clk = 1;
	sys_rst_n = 1;
	start_flag = 0;
	r_w = 0;
	phy_add = 0;
	reg_add = 0;
	write_reg_data = 0;
	mdio_in = 0;
	#20;
	start_flag = 1;
	r_w = 0;
	phy_add = 0;
	reg_add = 0;
	write_reg_data = 16'b0010_0001_0000_0000;
	#20;
	start_flag = 0;
end

always #10 sys_clk = ~ sys_clk;

mdio mdio_inst
(
	.sys_clk		(sys_clk),    
	.sys_rst_n		(sys_rst_n),
	.start_flag		(start_flag),
	.r_w			(r_w),
	.phy_add		(phy_add),
	.reg_add		(reg_add),
	.write_reg_data (write_reg_data),
	.mdio_in		(mdio_in),

	.read_reg_data	(read_reg_data),
	.mdio_en		(mdio_en),
	.mdio_o			(mdio_o),
	.mdc			(mdc)
);

endmodule