module mdio_set (
    input   wire        sys_clk, 
    input	wire		sys_rst_n,   
    input   wire       	mdio_set_start_flag,
    
    output	wire		mdc,
    inout	wire		mdio,
    output	reg		    mdio_set_end_flag,
    output	reg		    mdio_link_flag
);

reg				mdio_start_flag;
wire			mdio_end_flag;

reg				r_w;
reg[4:0]		phy_add;
reg[4:0]		reg_add;
reg[15:0]		write_reg_data;
wire[15:0]		read_reg_data;


parameter 	IDLE 	= 0;
parameter	WRITE	= 1;
parameter	READ	= 2;
parameter	CHECK	= 3;
reg[1:0]		state;
//
always @(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		state <= IDLE;
	else 
		case(state)
		IDLE:
			if (mdio_set_start_flag == 1)
				state <= WRITE;
		WRITE:
			if (mdio_end_flag == 1)
				state <= READ;
		READ:
			if (mdio_end_flag == 1)
				state <= CHECK;
		CHECK:
			if (mdio_set_end_flag == 1)
				state <= IDLE;
		default:
			state <= IDLE;
		endcase	

//
always @(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		begin
			mdio_start_flag <= 0;
			phy_add <= 0;
			reg_add <= 0;
			r_w <= 1;
			write_reg_data <= 0;
		end
	else 
		case(state)
		IDLE:
			if (mdio_set_start_flag == 1)
				begin
					mdio_start_flag <= 1;
					phy_add <= 0;
					reg_add <= 0;
					r_w <= 0;
					write_reg_data <= 16'b0000_0001_0000_0000;
				end
			else
				mdio_start_flag <= 0;
		WRITE:
			if (mdio_end_flag == 1)
				begin
					mdio_start_flag <= 1;
					r_w <= 1;
					phy_add <= 0;
					reg_add <= 1;
				end
			else
				mdio_start_flag <= 0;
		default:
			mdio_start_flag <= 0;
		endcase

//
always @(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		mdio_set_end_flag <= 0;
	else 
		case(state)
		READ:
			if (mdio_end_flag == 1)
				mdio_set_end_flag <= 1;
			else
				mdio_set_end_flag <= 0;
		default:
			mdio_set_end_flag <= 0;
		endcase

//
always @(posedge sys_clk)
	//reset
	if (sys_rst_n == 'b0) 
		mdio_link_flag <= 0;
	else 
		case(state)
		READ:
			if (mdio_end_flag == 1)
				if (read_reg_data[2] == 1)
					mdio_link_flag <= 1;
				else
					mdio_link_flag <= 0;
			else	
				mdio_link_flag <= 0;
		default:
			mdio_link_flag <= 0;
		endcase
mdio mdio_inst
(
	.sys_clk		(sys_clk),    
	.sys_rst_n		(sys_rst_n),
	.start_flag		(mdio_start_flag),
	.r_w			(r_w),
	.phy_add		(phy_add),
	.reg_add		(reg_add),
	.write_reg_data (write_reg_data),

	.read_reg_data	(read_reg_data),
	.mdc			(mdc),

	.mdio			(mdio),

	.end_flag		(mdio_end_flag)
);
endmodule


