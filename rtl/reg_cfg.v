module reg_cfg
	#(parameter DMAC_BASE_ADDR=0)
    (  
        /**********APB_S**********/
        input	[31:0]		wdata_i,
        input	[31:0]		addr_i,
        input				presetn_i,
        input				pclk_i,
        input				pwrite_i,
        output reg	[31:0]	rdata_o,
        /**********SYNC**********/
        input				sync_int_done_i,
        input				sync_int_error_i,
        input				sync_int_timeout_i,
        output 				reg_soft_rst_o,
        output				DMA_START_o,
        output 				reg_clk_gating_o,
        /**********DMA engine**********/
        input	[31:0]		DMA_burst_cur_srcaddr_i,
        input	[31:0]		DMA_burst_cur_dstaddr_i,
        input   [31:0]		DMA_cur_transfer_data_i,
        output	[31:0]		reg_src_addr_o,
        output	[31:0]		reg_dst_addr_o,
        output	[31:0]		reg_transfer_data_o,
        //output	[31:0]		reg_dst_data_o,
        output	[31:0]		reg_time_out_o,
        output  [31:0]		reg_peri_pri_o,
        output  [31:0]		reg_mem_pri_o,
        /**********CPU**********/
        output 				reg_int_o
    );
    	/****************连线********************/
    			wire	[127:0]	reg_en;
    			wire	[31:0]	cfg_addr;
    			wire			clk_gen;
    			wire	[31:0]	DMAC_CON ;
				wire	[31:0]	DMAC_CKGEN; 
				wire	[31:0]	DMAC_PERI_REQ_PRI;
				wire	[31:0]	DMAC_SOFT_REQ_PRI;
				wire	[31:0]	DMAC_CHAN_ST;
				wire	[31:0]	DMAC_INT_EN ;
				wire	[31:0]	DMAC_INT_MASK; 
				wire	[31:0]	DMAC_INT_CLEAR; 
				wire	[31:0]	DMAC_INT_ORIST;
				wire	[31:0]	DMAC_INT_ST ;
				wire	[31:0]	DMAC_SRCADDR_P0;
				wire	[31:0]	DMAC_DSTADDR_P0; 
				wire	[31:0]	DMAC_LEN_P0 ;
				wire	[31:0]	DMAC_CON_P0 ;
				wire	[31:0]	DMAC_CUR_SRCADDR_P0;
				wire	[31:0]	DMAC_CUR_DSTADDR_P0; 
				wire	[31:0]	DMAC_CUR_LEN_P0; 
				wire	[31:0]	DMAC_LLI_P0;
				wire	[31:0]	DMAC_SRCADDR_P1;
				wire	[31:0]	DMAC_DSTADDR_P1 ;
				wire	[31:0]	DMAC_LEN_P1; 
				wire	[31:0]	DMAC_CON_P1 ;
				wire	[31:0]	DMAC_CUR_SRCADDR_P1;
				wire	[31:0]	DMAC_CUR_DSTADDR_P1; 
				wire	[31:0]	DMAC_CUR_LEN_P1; 
				wire	[31:0]	DMAC_LLI_P1;
				wire	[31:0]	DMAC_SRCADDR_P2;
				wire	[31:0]	DMAC_DSTADDR_P2; 
				wire	[31:0]	DMAC_LEN_P2; 
				wire	[31:0]	DMAC_CON_P2; 
				wire	[31:0]	DMAC_CUR_SRCADDR_P2;
				wire	[31:0]	DMAC_CUR_DSTADDR_P2; 
				wire	[31:0]	DMAC_CUR_LEN_P2;
				wire	[31:0]	DMAC_LLI_P2 ;
				wire	[31:0]	DMAC_SRCADDR_P3;
				wire	[31:0]	DMAC_DSTADDR_P3; 
				wire	[31:0]	DMAC_LEN_P3 ;
				wire	[31:0]	DMAC_CON_P3 ;
				wire	[31:0]	DMAC_CUR_SRCADDR_P3;
				wire	[31:0]	DMAC_CUR_DSTADDR_P3; 
				wire	[31:0]	DMAC_CUR_LEN_P3;
				wire	[31:0]	DMAC_LLI_P3 ;
				wire	[31:0]	DMAC_SRCADDR_M0;
				wire	[31:0]	DMAC_DSTADDR_M0; 
				wire	[31:0]	DMAC_LEN_M0 ;
				wire	[31:0]	DMAC_CON_M0 ;
				wire	[31:0]	DMAC_CUR_SRCADDR_M0;
				wire	[31:0]	DMAC_CUR_DSTADDR_M0; 
				wire	[31:0]	DMAC_CUR_LEN_M0;
				wire	[31:0]	DMAC_LLI_M0; 
				wire	[31:0]	DMAC_SRCADDR_M1;
				wire	[31:0]	DMAC_DSTADDR_M1; 
				wire	[31:0]	DMAC_LEN_M1 ;
				wire	[31:0]	DMAC_CON_M1 ;
				wire	[31:0]	DMAC_CUR_SRCADDR_M1;
				wire	[31:0]	DMAC_CUR_DSTADDR_M1; 
				wire	[31:0]	DMAC_CUR_LEN_M1;
				wire	[31:0]	DMAC_LLI_M1 ;
				//wire	[31:0]	DMAC_BURST_TYPE_P0;
				//wire	[31:0]	DMAC_BURST_TYPE_P1;
				//wire	[31:0]	DMAC_BURST_TYPE_P2;
				//wire	[31:0]	DMAC_BURST_TYPE_P3;
				//wire	[31:0]	DMAC_BURST_TYPE_M0;
				//wire	[31:0]	DMAC_BURST_TYPE_M1;
				//wire [2:0]						channel_status;
				wire			P0_start;
				wire			P1_start;
				wire			P2_start;
				wire			P3_start;
				wire			M0_start;
				wire			M1_start;
				//wire	[15:0]	src_burst_data;
				//wire	[15:0]	dst_burst_data;
				wire    [15:0]  burst_data;
				wire			READ_ONLY_SIGN;
				wire			wr_error;
				wire	[31:0]	channel_status;
				wire	[31:0]	irq_status;
				wire	[31:0]	irq_ori_status;
				wire	[31:0]	P0_cur_srcaddr;
				wire	[31:0]	P0_cur_dstaddr;
				wire	[31:0]	P0_cur_length;
				wire	[31:0]	P1_cur_srcaddr;
				wire	[31:0]	P1_cur_dstaddr;
				wire	[31:0]	P1_cur_length;
				wire	[31:0]	P2_cur_srcaddr;
				wire	[31:0]	P2_cur_dstaddr;
				wire	[31:0]	P2_cur_length;
				wire	[31:0]	P3_cur_srcaddr;
				wire	[31:0]	P3_cur_dstaddr;
				wire	[31:0]	P3_cur_length;
				wire	[31:0]	M0_cur_srcaddr;
				wire	[31:0]	M0_cur_dstaddr;
				wire	[31:0]	M0_cur_length;
				wire	[31:0]	M1_cur_srcaddr;
				wire	[31:0]	M1_cur_dstaddr;
				wire	[31:0]	M1_cur_length;
    	/****************寄存器******************/
    			//reg [127:0]					reg_en;
    			config_reg #(.DW(32)) inst_dff0 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[0]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON));
    			config_reg #(.DW(32)) inst_dff1 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[1]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CKGEN));
    			config_reg #(.DW(32)) inst_dff2 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[2]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_PERI_REQ_PRI));
    			config_reg #(.DW(32)) inst_dff3 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[3]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SOFT_REQ_PRI));
    			dff #(.DW(32)) inst_dff4 (.clk_in(pclk_i), .resetn(presetn_i), .en(1),.clk_gen(clk_gen), .d(channel_status), .q(DMAC_CHAN_ST));//read only
    			config_reg #(.DW(32)) inst_dff5 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[5]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_INT_EN));
    			config_reg #(.DW(32)) inst_dff6 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[6]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_INT_MASK));
    			dff #(.DW(32)) inst_dff (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[7]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_INT_CLEAR));
    			W1C_reg #(.DW(32)) inst_clr_reg7 (.clk_in(pclk_i),.resetn (presetn_i),.en(reg_en[7]),.clk_gen (clk_gen),.d(wdata_i),.q(DMAC_INT_CLEAR));
    			dff #(.DW(32)) inst_dff8 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[8]),.clk_gen(clk_gen), .d(irq_ori_status), .q(DMAC_INT_ORIST));//read only
    			dff #(.DW(32)) inst_dff9 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[9]),.clk_gen(clk_gen), .d(irq_status), .q(DMAC_INT_ST));//read only
    			dff #(.DW(32)) inst_dff10 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[10]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_P0));
    			dff #(.DW(32)) inst_dff11 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[11]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_P0));
    			dff #(.DW(32)) inst_dff12 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[12]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_P0));
    			config_reg #(.DW(32)) inst_dff13 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[13]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_P0));
    			dff #(.DW(32)) inst_dff14 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[14]),.clk_gen(clk_gen), .d(P0_cur_srcaddr), .q(DMAC_CUR_SRCADDR_P0));//read only
    			dff #(.DW(32)) inst_dff15 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[15]),.clk_gen(clk_gen), .d(P0_cur_dstaddr), .q(DMAC_CUR_DSTADDR_P0));//read only
    			dff #(.DW(32)) inst_dff16 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[16]),.clk_gen(clk_gen), .d(P0_cur_length), .q(DMAC_CUR_LEN_P0));//read only
    			dff #(.DW(32)) inst_dff17 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[17]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_P0));
    			dff #(.DW(32)) inst_dff18 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[18]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_P1));
    			dff #(.DW(32)) inst_dff19 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[19]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_P1));
    			dff #(.DW(32)) inst_dff20 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[20]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_P1));
    			dff #(.DW(32)) inst_dff21 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[21]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_P1));
    			dff #(.DW(32)) inst_dff22 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[22]),.clk_gen(clk_gen), .d(P1_cur_srcaddr), .q(DMAC_CUR_SRCADDR_P1));
    			dff #(.DW(32)) inst_dff23 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[23]),.clk_gen(clk_gen), .d(P1_cur_dstaddr), .q(DMAC_CUR_DSTADDR_P1));
    			dff #(.DW(32)) inst_dff24 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[24]),.clk_gen(clk_gen), .d(P1_cur_length), .q(DMAC_CUR_LEN_P1));
    			dff #(.DW(32)) inst_dff25 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[25]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_P1));
    			dff #(.DW(32)) inst_dff26 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[26]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_P2));
    			dff #(.DW(32)) inst_dff27 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[27]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_P2));
    			dff #(.DW(32)) inst_dff28 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[28]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_P2));
    			config_reg #(.DW(32)) inst_dff29 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[29]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_P2));
    			dff #(.DW(32)) inst_dff30 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[30]),.clk_gen(clk_gen), .d(P2_cur_srcaddr), .q(DMAC_CUR_SRCADDR_P2));
    			dff #(.DW(32)) inst_dff31 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[31]),.clk_gen(clk_gen), .d(P2_cur_dstaddr), .q(DMAC_CUR_DSTADDR_P2));
    			dff #(.DW(32)) inst_dff32 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[32]),.clk_gen(clk_gen), .d(P2_cur_length), .q(DMAC_CUR_LEN_P2));
    			dff #(.DW(32)) inst_dff33 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[33]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_P2));
    			dff #(.DW(32)) inst_dff34 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[34]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_P3));
    			dff #(.DW(32)) inst_dff35 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[35]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_P3));
    			dff #(.DW(32)) inst_dff36 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[36]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_P3));
    			config_reg #(.DW(32)) inst_dff37 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[37]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_P3));
    			dff #(.DW(32)) inst_dff38 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[38]),.clk_gen(clk_gen), .d(P3_cur_srcaddr), .q(DMAC_CUR_SRCADDR_P3));
    			dff #(.DW(32)) inst_dff39 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[39]),.clk_gen(clk_gen), .d(P3_cur_dstaddr), .q(DMAC_CUR_DSTADDR_P3));
    			dff #(.DW(32)) inst_dff40 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[40]),.clk_gen(clk_gen), .d(P3_cur_length), .q(DMAC_CUR_LEN_P3));
    			dff #(.DW(32)) inst_dff41 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[41]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_P3));
    			dff #(.DW(32)) inst_dff42 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[42]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_M0));
    			dff #(.DW(32)) inst_dff43 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[43]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_M0));
    			dff #(.DW(32)) inst_dff44 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[44]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_M0));
    			config_reg #(.DW(32)) inst_dff45 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[45]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_M0));
    			dff #(.DW(32)) inst_dff46 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[46]),.clk_gen(clk_gen), .d(M0_cur_srcaddr), .q(DMAC_CUR_SRCADDR_M0));
    			dff #(.DW(32)) inst_dff47 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[47]),.clk_gen(clk_gen), .d(M0_cur_dstaddr), .q(DMAC_CUR_DSTADDR_M0));
    			dff #(.DW(32)) inst_dff48 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[48]),.clk_gen(clk_gen), .d(M0_cur_length), .q(DMAC_CUR_LEN_M0));
    			dff #(.DW(32)) inst_dff49 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[49]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_M0));
    			dff #(.DW(32)) inst_dff50 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[50]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_SRCADDR_M1));
    			dff #(.DW(32)) inst_dff51 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[51]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_DSTADDR_M1));
    			dff #(.DW(32)) inst_dff52 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[52]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LEN_M1));
    			config_reg #(.DW(32)) inst_dff53 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[53]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_CON_M1));
    			dff #(.DW(32)) inst_dff54 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[54]),.clk_gen(clk_gen), .d(M1_cur_srcaddr), .q(DMAC_CUR_SRCADDR_M1));
    			dff #(.DW(32)) inst_dff55 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[55]),.clk_gen(clk_gen), .d(M1_cur_dstaddr), .q(DMAC_CUR_DSTADDR_M1));
    			dff #(.DW(32)) inst_dff56 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[56]),.clk_gen(clk_gen), .d(M1_cur_length), .q(DMAC_CUR_LEN_M1));
    			dff #(.DW(32)) inst_dff57 (.clk_in(pclk_i), .resetn(presetn_i), .en(reg_en[57]),.clk_gen(clk_gen), .d(wdata_i), .q(DMAC_LLI_M1));

    	/****************组合逻辑****************/
    		   assign clk_gen = 1;
    	       assign reg_int_o=sync_int_done_i|sync_int_timeout_i|sync_int_error_i;
    	       assign cfg_addr=addr_i;   
               assign READ_ONLY_SIGN =  (cfg_addr==(DMAC_BASE_ADDR)+'h38)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h3C)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h58)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h5C)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h78)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h7C)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h98)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h9C)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hB8)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hBC)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hD8)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hDC)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h10)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h20)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h24)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h40)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h60)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'h80)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hA0)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hC0)|
    	       							(cfg_addr==(DMAC_BASE_ADDR)+'hE0);

    	       assign reg_soft_rst_o=DMAC_CON[15];
    	       generate
    	       	genvar i;
    	       	for (i = 0; i < 128; i = i + 1)begin
    	       		assign reg_en[i]=pwrite_i & ((cfg_addr>>2)==i) & ~READ_ONLY_SIGN;
    	       	end
    	       endgenerate
    	       //assign channel_status = DMAC_CON[10:8];
    	       assign {M1_start,M0_start,P3_start,P2_start,P1_start,P0_start}=DMAC_CON[5:0];
    	       assign reg_src_addr_o =  ({32{P0_start}} &DMAC_SRCADDR_P0)|
    	       							({32{P1_start}} &DMAC_SRCADDR_P1)|
    	       							({32{P2_start}} &DMAC_SRCADDR_P2)|
    	       							({32{P3_start}} &DMAC_SRCADDR_P3)|
    	       							({32{M0_start}} &DMAC_SRCADDR_M0)|
    	       							({32{M1_start}} &DMAC_SRCADDR_M1);
    	        assign reg_dst_addr_o = ({32{P0_start}} &DMAC_DSTADDR_P0)|
    	       							({32{P1_start}} &DMAC_DSTADDR_P1)|
    	       							({32{P2_start}} &DMAC_DSTADDR_P2)|
    	       							({32{P3_start}} &DMAC_DSTADDR_P3)|
    	       							({32{M0_start}} &DMAC_DSTADDR_M0)|
    	       							({32{M1_start}} &DMAC_DSTADDR_M1);
    	       							
    	       	assign burst_data = 	({16{P0_start}} & DMAC_CON_P0[15:0])|
    	       							({16{P1_start}} & DMAC_CON_P1[15:0])|
    	       							({16{P2_start}} & DMAC_CON_P2[15:0])|
    	       							({16{P3_start}} & DMAC_CON_P3[15:0])|
    	       							({16{M0_start}} & DMAC_CON_M0[15:0])|
    	       							({16{M1_start}} & DMAC_CON_M1[15:0]);

    	       	//assign dst_burst_data = ({16{P0_start}} &{DMAC_CON_P0[15:14],DMAC_CON_P0[13:12],DMAC_CON_P0[11:10],DMAC_CON_P0[6:4]})|
    	       	//						({16{P1_start}} &{DMAC_CON_P1[15:14],DMAC_CON_P1[13:12],DMAC_CON_P1[11:10],DMAC_CON_P1[6:4]})|
    	       	//						({16{P2_start}} &{DMAC_CON_P2[15:14],DMAC_CON_P2[13:12],DMAC_CON_P2[11:10],DMAC_CON_P2[6:4]})|
    	       	//						({16{P3_start}} &{DMAC_CON_P3[15:14],DMAC_CON_P3[13:12],DMAC_CON_P3[11:10],DMAC_CON_P3[6:4]})|
    	       	//						({16{M0_start}} &{DMAC_CON_M0[15:14],DMAC_CON_M0[13:12],DMAC_CON_M0[11:10],DMAC_CON_M0[6:4]})|
    	       	//						({16{M1_start}} &{DMAC_CON_M1[15:14],DMAC_CON_M1[13:12],DMAC_CON_M1[11:10],DMAC_CON_M1[6:4]});	

                //assign reg_src_data_o = {10'b0,DMAC_CON[5:0],src_burst_data[15:0]};
                //assign reg_dst_data_o = {10'b0,DMAC_CON[5:0],dst_burst_data[15:0]};
                assign reg_transfer_data_o = {10'b0,DMAC_CON[5:0],burst_data};
                assign reg_peri_pri_o = DMAC_PERI_REQ_PRI;
                assign reg_mem_pri_o  = DMAC_SOFT_REQ_PRI;
                assign DMA_START_o = (P0_start &DMAC_CHAN_ST[0])|
    	       						 (P1_start &DMAC_CHAN_ST[1])|
    	       						 (P2_start &DMAC_CHAN_ST[2])|
    	       						 (P3_start &DMAC_CHAN_ST[3])|
    	       						 (M0_start &DMAC_CHAN_ST[4])|
    	       						 (M1_start &DMAC_CHAN_ST[5]); 
    	       	assign wr_error = (cfg_addr>(DMAC_BASE_ADDR+'hE4))|(pwrite_i&READ_ONLY_SIGN);

    	       	assign channel_status[5:0] = DMAC_CON[5:0];

    	       	assign channel_status[10:8]=P0_start?3'b001:
    	       								P1_start?3'b010:
    	       								P2_start?3'b011:
    	       								P3_start?3'b100:
    	       								M0_start?3'b101:
    	       								M1_start?3'b110:3'b0;
    	       	assign irq_ori_status[21:16] = (|DMAC_INT_CLEAR[5:0])?(~DMAC_INT_CLEAR[5:0]):({6{sync_int_timeout_i}}	&{DMAC_CON[5:0]} 	& {6{DMAC_INT_EN[7]}} & {DMAC_INT_EN[1:0],DMAC_INT_EN[5:2]});
    	       	assign irq_ori_status[13:8]   = (|DMAC_INT_CLEAR[5:0])?(~DMAC_INT_CLEAR[5:0]):({6{sync_int_error_i}}	&{DMAC_CON[5:0]}		& {6{DMAC_INT_EN[8]}} & {DMAC_INT_EN[1:0],DMAC_INT_EN[5:2]});
    	       	assign irq_ori_status[5:0]     = (|DMAC_INT_CLEAR[5:0])?(~DMAC_INT_CLEAR[5:0]):({6{sync_int_done_i}}		&{DMAC_CON[5:0]}		& {6{DMAC_INT_EN[6]}} & {DMAC_INT_EN[1:0],DMAC_INT_EN[5:2]});
    	       	assign irq_status[21:16]	 = irq_ori_status[21:16] &	{6{DMAC_INT_MASK[7]}} & {DMAC_INT_MASK[1:0],DMAC_INT_MASK[5:2]};
    	       	assign irq_status[13:8]	 = irq_ori_status[13:8] 	&	{6{DMAC_INT_MASK[8]}} & {DMAC_INT_MASK[1:0],DMAC_INT_MASK[5:2]};
    	       	assign irq_status[5:0]	 	 = irq_ori_status[5:0] 		&	{6{DMAC_INT_MASK[6]}} & {DMAC_INT_MASK[1:0],DMAC_INT_MASK[5:2]};
    	       	assign reg_transfer_size	= 	({32{P0_start}} & DMAC_LEN_P0) | 
												({32{P1_start}} & DMAC_LEN_P1) |
												({32{P2_start}} & DMAC_LEN_P2) |
												({32{P3_start}} & DMAC_LEN_P3) |
												({32{M0_start}} & DMAC_LEN_M0) |
												({32{M1_start}} & DMAC_LEN_M1) ;									
    	/****************时序逻辑****************/
    	
    	
    	always @(posedge pclk_i or negedge presetn_i) begin 
    	            if(~presetn_i) begin
    	                	rdata_o<=128'h0;
    	            end else if(~pwrite_i) begin
    	                	case(cfg_addr)
    	                			DMAC_BASE_ADDR+'h00:rdata_o<=DMAC_CON;
    	                			DMAC_BASE_ADDR+'h04:rdata_o<=DMAC_CKGEN;
    	                			DMAC_BASE_ADDR+'h08:rdata_o<=DMAC_PERI_REQ_PRI;
    	                			DMAC_BASE_ADDR+'h0C:rdata_o<=DMAC_SOFT_REQ_PRI;

    	                			DMAC_BASE_ADDR+'h10:rdata_o<=DMAC_CHAN_ST;
    	                			DMAC_BASE_ADDR+'h14:rdata_o<=DMAC_INT_EN;
    	                			DMAC_BASE_ADDR+'h18:rdata_o<=DMAC_INT_MASK;
    	                			DMAC_BASE_ADDR+'h1C:rdata_o<=DMAC_INT_CLEAR;

    	                			DMAC_BASE_ADDR+'h20:rdata_o<=DMAC_INT_ORIST;
    	                			DMAC_BASE_ADDR+'h24:rdata_o<=DMAC_INT_ST;
    	                			DMAC_BASE_ADDR+'h28:rdata_o<=DMAC_SRCADDR_P0;
    	                			DMAC_BASE_ADDR+'h2C:rdata_o<=DMAC_DSTADDR_P0;
    	                			DMAC_BASE_ADDR+'h30:rdata_o<=DMAC_LEN_P0;
    	                			DMAC_BASE_ADDR+'h34:rdata_o<=DMAC_CON_P0;
    	                			DMAC_BASE_ADDR+'h38:rdata_o<=DMAC_CUR_SRCADDR_P0;
    	                			DMAC_BASE_ADDR+'h3C:rdata_o<=DMAC_CUR_DSTADDR_P0;
    	                			DMAC_BASE_ADDR+'h40:rdata_o<=DMAC_CUR_LEN_P0;
    	                			DMAC_BASE_ADDR+'h44:rdata_o<=DMAC_LLI_P0;
    	                			DMAC_BASE_ADDR+'h48:rdata_o<=DMAC_SRCADDR_P1;
    	                			DMAC_BASE_ADDR+'h4C:rdata_o<=DMAC_DSTADDR_P1;
    	                			DMAC_BASE_ADDR+'h50:rdata_o<=DMAC_LEN_P1;
    	                			DMAC_BASE_ADDR+'h54:rdata_o<=DMAC_CON_P1;
    	                			DMAC_BASE_ADDR+'h58:rdata_o<=DMAC_CUR_SRCADDR_P1;
    	                			DMAC_BASE_ADDR+'h5C:rdata_o<=DMAC_CUR_DSTADDR_P1;
    	                			DMAC_BASE_ADDR+'h60:rdata_o<=DMAC_CUR_LEN_P1;
    	                			DMAC_BASE_ADDR+'h64:rdata_o<=DMAC_LLI_P1;
    	                			DMAC_BASE_ADDR+'h68:rdata_o<=DMAC_SRCADDR_P2;
    	                			DMAC_BASE_ADDR+'h6C:rdata_o<=DMAC_DSTADDR_P2;
    	                			DMAC_BASE_ADDR+'h70:rdata_o<=DMAC_LEN_P2;
    	                			DMAC_BASE_ADDR+'h74:rdata_o<=DMAC_CON_P2;
    	                			DMAC_BASE_ADDR+'h78:rdata_o<=DMAC_CUR_SRCADDR_P2;
    	                			DMAC_BASE_ADDR+'h7C:rdata_o<=DMAC_CUR_DSTADDR_P2;
    	                			DMAC_BASE_ADDR+'h80:rdata_o<=DMAC_CUR_LEN_P2;
    	                			DMAC_BASE_ADDR+'h84:rdata_o<=DMAC_LLI_P2;
    	                			DMAC_BASE_ADDR+'h88:rdata_o<=DMAC_SRCADDR_P3;
    	                			DMAC_BASE_ADDR+'h8C:rdata_o<=DMAC_DSTADDR_P3;
    	                			DMAC_BASE_ADDR+'h90:rdata_o<=DMAC_LEN_P3;
    	                			DMAC_BASE_ADDR+'h94:rdata_o<=DMAC_CON_P3;
    	                			DMAC_BASE_ADDR+'h98:rdata_o<=DMAC_CUR_SRCADDR_P3;
    	                			DMAC_BASE_ADDR+'h9C:rdata_o<=DMAC_CUR_DSTADDR_P3;
    	                			DMAC_BASE_ADDR+'hA0:rdata_o<=DMAC_CUR_LEN_P3;
    	                			DMAC_BASE_ADDR+'hA4:rdata_o<=DMAC_LLI_P3;
    	                			DMAC_BASE_ADDR+'hA8:rdata_o<=DMAC_SRCADDR_M0;
    	                			DMAC_BASE_ADDR+'hAC:rdata_o<=DMAC_DSTADDR_M0;
    	                			DMAC_BASE_ADDR+'hB0:rdata_o<=DMAC_LEN_M0;
    	                			DMAC_BASE_ADDR+'hB4:rdata_o<=DMAC_CON_M0;
    	                			DMAC_BASE_ADDR+'hB8:rdata_o<=DMAC_CUR_SRCADDR_M0;
    	                			DMAC_BASE_ADDR+'hBC:rdata_o<=DMAC_CUR_DSTADDR_M0;
    	                			DMAC_BASE_ADDR+'hC0:rdata_o<=DMAC_CUR_LEN_M0;
    	                			DMAC_BASE_ADDR+'hC4:rdata_o<=DMAC_LLI_M0;
    	                			DMAC_BASE_ADDR+'hC8:rdata_o<=DMAC_SRCADDR_M1;
    	                			DMAC_BASE_ADDR+'hCC:rdata_o<=DMAC_DSTADDR_M1;
    	                			DMAC_BASE_ADDR+'hD0:rdata_o<=DMAC_LEN_M1;
    	                			DMAC_BASE_ADDR+'hD4:rdata_o<=DMAC_CON_M1;
    	                			DMAC_BASE_ADDR+'hD8:rdata_o<=DMAC_CUR_SRCADDR_M1;
    	                			DMAC_BASE_ADDR+'hDC:rdata_o<=DMAC_CUR_DSTADDR_M1;
    	                			DMAC_BASE_ADDR+'hE0:rdata_o<=DMAC_CUR_LEN_M1;
    	                			DMAC_BASE_ADDR+'hE4:rdata_o<=DMAC_LLI_M1;
    	                			
    	                			default:rdata_o<=0;
    	                endcase
    	            end
    	            else
    	            	rdata_o<=0;
    	end

    	
    	/****************状态机******************/
    	
    	


endmodule