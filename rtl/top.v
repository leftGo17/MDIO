module top
(
	input		wire			sys_clk,
	input		wire			sys_rst_n,
	input		wire			key,

	output		wire			mdc,
	inout		wire			mdio,

	output		reg				led
);


reg			start_flag;
wire		key_flag;
wire		mdio_set_end_flag;
wire		mdio_link_flag;
 		
always 	@(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		start_flag <= 0;
	else 
		if (key_flag == 1)
			start_flag <= 1;
		else
			start_flag <= 0;

//
always @(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		led <= 0;
	else 
		if (mdio_set_end_flag == 1 && mdio_link_flag == 1)
			led <= 1;
		else if (mdio_set_end_flag == 1 && mdio_link_flag == 0)
			led <= 0;
		else
			led <= led;
			
	
mdio_set mdio_set_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.mdio_set_start_flag(start_flag),

	.mdc(mdc),
	.mdio(mdio),
	.mdio_set_end_flag(mdio_set_end_flag),
	.mdio_link_flag(mdio_link_flag)
);

key_filter key_filter_inst
(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.key_in(key),
	.key_flag(key_flag)
);

endmodule