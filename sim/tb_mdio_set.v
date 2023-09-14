module tb_mdio_set();

reg			sys_clk;
reg			sys_rst_n;
reg			mdio_set_start_flag;

wire		mdc;
wire		mdio;

initial begin
	sys_clk = 1;
	sys_rst_n <= 0;
	mdio_set_start_flag <= 0;
	#20;
	sys_rst_n <= 1;
	#20;
	mdio_set_start_flag <= 1;
	#20;
	mdio_set_start_flag <= 0;
end

always #10 sys_clk = ~sys_clk;

mdio_set mdio_set_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.mdio_set_start_flag(mdio_set_start_flag),
	.mdc(mdc),
	.mdio(mdio)
);

endmodule