/*
start_flag 高电平有效
在start_flag 上升沿（包括）之前给定r_w,address,data维持
*/

module mdio (
    input   wire        sys_clk,    
    input   wire        sys_rst_n, 
    input	wire		start_flag,
    input	wire		r_w,
    input	wire[4:0]	phy_add,
    input	wire[4:0]	reg_add,
    input	wire[15:0]	write_reg_data,
    

    output	reg[15:0]	read_reg_data,
    output	reg			mdc,
    output  reg         end_flag,

    inout   wire        mdio
);
reg         mdio_en;
reg         mdio_o;
reg[3:0]    cnt_mdc;
reg[9:0]    num_mdc;     

parameter IDLE = 'd0;
parameter WRITE = 'd1;
parameter TURN_WR = 'd2;
parameter TURN_RD = 'd3;

parameter CNT_MAX = 'd15;
parameter CNT_HALF = 'd7;

parameter CNT_WRITE = 'd45;
parameter CNT_TURN = 'd63;
reg[1:0]	state;

wire[31:0]  preamble;
wire[1:0]   st;
reg[1:0]    op;
wire[4:0]   phyad;
wire[4:0]   regad;
reg[1:0]    wr_ta;
reg[15:0]   wr_data;

wire[63:0]  write_data;
//预处理数据
assign preamble = {'d32{1'b1}};
assign st = 2'b01;
assign phyad = phy_add;
assign regad = reg_add;

always @(*)
    if (start_flag == 1'b1)
        if (r_w == 1'b0)
        begin
            op = 2'b01;
            wr_ta = 2'b10;
            wr_data = write_reg_data;
        end
        else
        begin
            op = 2'b10;
            wr_ta = 0;
            wr_data = 0;
        end
assign write_data = {preamble, st, op, phyad, regad, wr_ta, wr_data};

assign mdio = (mdio_en == 1) ? mdio_o : 1'bz;
//第一段状态
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 'b0) 
        state <= IDLE;
    else 
        case(state)
        IDLE:
            if (start_flag == 1'b1)
                state <= WRITE;
        WRITE:
            if (cnt_mdc == CNT_MAX && num_mdc == CNT_WRITE && r_w == 0)
                state <= TURN_WR;
            else if (cnt_mdc == CNT_MAX && num_mdc == CNT_WRITE && r_w == 1)
                state <= TURN_RD;
        TURN_WR:
            if (cnt_mdc == CNT_MAX && num_mdc == CNT_TURN)
                state <= IDLE;
        TURN_RD:
            if (cnt_mdc == CNT_MAX && num_mdc == CNT_TURN)
                state <= IDLE;
        default:
            state <= IDLE;
        endcase


//第二段输出
//输出mdc
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 'b0) 
        mdc <= 1'b1;
    else 
        case(state)
        IDLE:
            if (start_flag == 1'b1)
                mdc <= 0;
            else
                mdc <= 1;
        default:
            if (cnt_mdc == CNT_HALF)
                mdc <= 1;
            else if (cnt_mdc == CNT_MAX)
                mdc <= 0;
        endcase

//输出mdio_o
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 'b0) 
        mdio_o <= 1;
    else 
        case(state)
        IDLE:
            mdio_o <= 1;
        WRITE:
            if (cnt_mdc == CNT_MAX && num_mdc < CNT_WRITE)
                mdio_o <= write_data[CNT_TURN - 1 - num_mdc];
            else if(num_mdc == CNT_WRITE && cnt_mdc == CNT_MAX)
                mdio_o <= 1;
        TURN_WR:
            if (cnt_mdc == CNT_MAX && num_mdc < CNT_TURN) 
                mdio_o <= write_data[CNT_TURN - 1 - num_mdc];
            else if (cnt_mdc == CNT_MAX && num_mdc == CNT_TURN)
                mdio_o <= 1;
        TURN_RD:
            mdio_o <= 1;
        endcase

//读入mdio，组合成为read_reg_data
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 0) 
        read_reg_data <= 0;   
    else 
        case(state)
        TURN_RD:
            if (cnt_mdc == CNT_HALF && num_mdc > 47 && num_mdc <= CNT_TURN)
                read_reg_data[CNT_TURN - num_mdc] <= mdio;
        endcase

//输入mdio_en
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 'b0) 
        mdio_en <= 0;
    else 
        case(state)
        IDLE:
            if (start_flag == 1)
                mdio_en <= 1;
            else
                mdio_en <= 0;
        WRITE:
            if (num_mdc == CNT_WRITE && cnt_mdc == CNT_MAX && r_w == 1)
                mdio_en <= 0;
            else
                mdio_en <= 1;
        TURN_WR:
            if (num_mdc == CNT_TURN && cnt_mdc == CNT_MAX)
                mdio_en <= 0;
            else
                mdio_en <= 1;
        TURN_RD:
            mdio_en <= 0;
        endcase

always @(posedge sys_clk)
    if (sys_rst_n == 1'b0)
        end_flag <= 0;
    else
        case(state)
        TURN_WR:
            if (cnt_mdc == CNT_MAX && num_mdc == CNT_TURN)
                end_flag <= 1;
        TURN_RD:
            if (cnt_mdc == CNT_MAX && num_mdc == CNT_TURN)
                end_flag <= 1;
        default:
            end_flag <= 0;
        endcase
                                               

//辅助寄存器
//时钟分配计数器cnt_mdc
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 0) 
        cnt_mdc <= 0;
    else 
        case(state)
        IDLE:
            cnt_mdc <= 0;
        default:
            cnt_mdc <= cnt_mdc + 1;
        endcase
//mdc时钟计数器num_mdc
always @(posedge sys_clk)
    //reset
    if (sys_rst_n == 0) 
        num_mdc <= 0;       
    else 
        case(state)
        IDLE:
            num_mdc <= 0;
        default:
            if (cnt_mdc == CNT_MAX)
                num_mdc <= num_mdc + 1;
        endcase        
    
endmodule
