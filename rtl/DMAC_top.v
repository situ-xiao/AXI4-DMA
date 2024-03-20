module DMAC_top
	#( parameter				   DMA_BASE_ADDR 									= 0,
		parameter				   APB_S_DATA_DW 									= 32,
		parameter				   APB_S_ADDR_DW 									= 32,
		parameter 				   M_AXI_DATA_WIDTH 			 					= 64,
    	parameter				   M_AXI_ADDR_WIDTH 							   	= 32,
    	//parameter				   M_TARGET_SURBODINATE_BASE_ADDR 	= 32'h40000000,
    	//parameter				   M_AXI_BURST_LEN   								= 1, //1,2,4,8,16,32,64,128,256
    	parameter				   M_AXI_ID_WIDTH 	   								= 7,
    	parameter				   M_AXI_WUSER_WIDTH   							= 1,
    	parameter				   M_AXI_AWUSER_WIDTH 							= 1,
    	parameter				   M_AXI_ARUSER_WIDTH 							= 1,
    	parameter				   M_AXI_RUSER_WIDTH 							= 1,
    	parameter				   M_AXI_BUSER_WIDTH 							= 1
)
    (  
    	/**********APB S*****************/
    	input								S_APB_PCLK,
        input								S_APB_RESETn,
        input	[APB_S_ADDR_DW-1:0]			S_APB_PADDR,
        input								S_APB_PSEL,
        input								S_APB_PENABLE,
        input								S_APB_PWRITE,
        input	[APB_S_DATA_DW-1:0]			S_APB_WDATA,
        input	[2:0]						S_APB_PPROT,
        input	[APB_S_DATA_DW/8-1:0]		S_APB_STRB,
        output								S_APB_PREADY,
        
        /**********AXI M*****************/


        input								M_AXI_ACLK			,
        input								M_AXI_ARESETN	,
        ////////////WRITE PORT/////////////
		output								M_AXI_AWVALID	,
		input								M_AXI_AWREADY	,
		output	[M_AXI_ID_WIDTH-1:0]		M_AXI_AWID    		,
		output								M_AXI_WVALID  	,
		output								M_AXI_WLAST  		,	
		output								M_AXI_WREADY		,
		output	[M_AXI_DATA_WIDTH-1:0]		M_AXI_WDATA		,
		output	[M_AXI_WUSER_WIDTH-1:0]		M_AXI_WUSER   	,
		output	[M_AXI_AWUSER_WIDTH-1:0]	M_AXI_AWUSER  	,
		output	[M_AXI_ADDR_WIDTH-1:0]		M_AXI_AWADDR  	,
		output	[M_AXI_DATA_WIDTH/8-1:0]	M_AXI_WSTRB   	,
		output	[7:0]						M_AXI_AWLEN   	,
		output	[2:0]						M_AXI_AWSIZE		,
		output	[1:0]						M_AXI_AWBUSRT	,
		output								M_AXI_AWLOCK 	,
		output	[3:0]						M_AXI_AWCACHE	,
		output	[3:0]						M_AXI_AWQOS  		,
		output	[2:0]						M_AXI_AWPROT  	,
		////////////READ PORT/////////////
		output								M_AXI_ARVALID	,
		output								M_AXI_ARREADY	,
		output	[M_AXI_ID_WIDTH-1:0]		M_AXI_ARID    		,
		input	[M_AXI_ID_WIDTH-1:0]		M_AXI_RID    		,
		input								M_AXI_RVALID  	,
		output								M_AXI_RLAST  		,	
		output								M_AXI_RREADY		,
		input	[M_AXI_DATA_WIDTH-1:0]		M_AXI_RDATA		,
		output	[M_AXI_WUSER_WIDTH-1:0]		M_AXI_RUSER   	,
		output	[M_AXI_AWUSER_WIDTH-1:0]	M_AXI_ARUSER  	,
		output	[M_AXI_ADDR_WIDTH-1:0]		M_AXI_ARADDR  	,
		output	[7:0]						M_AXI_ARLEN   	,
		output	[2:0]						M_AXI_ARSIZE		,
		output	[1:0]						M_AXI_ARBUSRT	,
		output								M_AXI_ARLOCK 	,
		output	[3:0]						M_AXI_ARCACHE	,
		output	[3:0]						M_AXI_ARQOS  		,
		output	[2:0]						M_AXI_ARPROT  	,
		input	[1:0]						M_AXI_RRESP		,
		////////////RESPONSE PORT///////	//////
		input	[M_AXI_ID_WIDTH-1:0]		M_AXI_BID      		,
		input	[1:0]						M_AXI_BRESP      	, 
		input	[M_AXI_BUSER_WIDTH-1:0]		M_AXI_BUSER   	,
		input								M_AXI_BVALID		,
		output								M_AXI_BREADY		,
		/**********other port*****************/
		input 								PERI_CLK_i,
		input 								PERI_RESETN_i,
		input								DMA_P0_REQ,
		input								DMA_P1_REQ,
		input								DMA_P2_REQ,
		input								DMA_P3_REQ,
		output								DMA_P0_ACK,
		output								DMA_P1_ACK,
		output								DMA_P2_ACK,
		output								DMA_P3_ACK,
		output								DMA_IRQ,
		//output	[10:0]						EP_DST_NUM,
		//output	[10:0]						EP_SRC_NUM,
		output								EP_SOFT_RST,
		output								EP_DONE

    );

    	/****************寄存器******************/
    	       
    	
    	/****************连线********************/
    	wire	[APB_S_DATA_DW-1:0]			S_APB_PRDATA;
        wire								S_APB_PSLAVERR;
        wire	[APB_S_DATA_DW-1:0]			reg_cfg_wdata;
        wire	[APB_S_ADDR_DW-1:0]			reg_cfg_addr;
        wire	[APB_S_DATA_DW/8-1:0]		reg_cfg_strobe;
        wire    [31:0]						src_addr;
        wire    [31:0]						dst_addr;
        wire    [31:0]						transfer_data;
        wire    [31:0]						time_out;
        wire    [31:0]						peri_pri;
        wire    [31:0]						mem_pri;
        wire    [31:0]						src_cur_addr;
        wire    [31:0]						dst_cur_addr;
        wire    [31:0]						cur_transfer_data;

        wire	[M_AXI_ADDR_WIDTH-1:0]		dma_axi_awaddr;
		wire	[M_AXI_ADDR_WIDTH-1:0]		dma_axi_araddr;
		wire	[2:0]						dma_axi_awburst;
		wire	[2:0]						dma_axi_awsize;
		wire	[6:0]						dma_axi_awlen;
		wire	[2:0]						dma_axi_arburst;
		wire	[2:0]						dma_axi_arsize;
		wire	[6:0]						dma_axi_arlen;
		wire								dma_axi_awready;
		wire 								dma_axi_awvalid;
		wire 								dma_axi_arvalid;
		wire								dma_axi_arready;
		wire								dma_axi_ack_req;
		wire								dma_axi_aerror;
		//wire	[M_AXI_ID_WIDTH-1:0]		dma_axi_awid;
		//wire	[M_AXI_ID_WIDTH-1:0]		dma_axi_arid;
		//wire	[M_AXI_ID_WIDTH-1:0]		dma_axi_rid;
		wire	[M_AXI_DATA_WIDTH-1:0]		dma_axi_rdata;
		wire	[M_AXI_DATA_WIDTH-1:0]		dma_axi_wdata;
		wire								dma_axi_wlast;
		wire 								dma_axi_rlast;
		//wire	[M_AXI_DATA_WIDTH/8-1:0]	dma_axi_wstrb;
		//wire	[M_AXI_DATA_WIDTH/8-1:0]	dma_axi_rstrb;
		wire 								dma_axi_wvalid;
		wire 								dma_axi_wready;
		wire 								dma_axi_rvalid;
		wire 								dma_axi_rready;
		wire [M_AXI_DATA_WIDTH-1:0]			dma_fifo_din;
		wire 								dma_fifo_wren;
		wire 								dma_fifo_rden;
		wire [M_AXI_DATA_WIDTH-1:0]			dma_fifo_dout;
		wire 								dma_fifo_empty;
		wire 								dma_fifo_full;
		wire 								dma_fifo_overflow;
		wire 								dma_fifo_underflow;
		wire                                dma_done_int;
		wire                                dma_error_int;
		wire                                dma_timeout_int;
		wire   								dma_start;
		wire   								dma_soft_rst;
		wire                                dma_clk_gating;

		wire 								dma_arbiter_src_req;
		wire 								dma_arbiter_dst_req;
		wire [31:0]							dma_arbiter_transfer_data;
		wire 								dma_arbiter_src_work;
		wire 								dma_arbiter_dst_work;
		wire 								dma_arbiter_src_ack;
		wire 								dma_arbiter_dst_ack;
		wire [31:0]							dma_arbiter_peri_pri;
		wire [31:0]							dma_arbiter_mem_pri;


		wire								reg_cfg_wr;
		wire	[M_AXI_DATA_WIDTH-1:0]		reg_cfg_rdata;
       	wire								sync_int_done;
       	wire								sync_int_error;
       	wire								sync_int_timeout;
       	wire								reg_clk_gating;
       	wire								DMA_START;
    	wire								reg_soft_rst;
    	wire 								SYNC_P0_REQ;
		wire 								SYNC_P1_REQ;
		wire 								SYNC_P2_REQ;
		wire 								SYNC_P3_REQ;
    	/****************存储器******************/
    	    
    	         
    	/****************例化********************/
    			APB_Subordinate #(
			.APB_S_DATA_DW(APB_S_DATA_DW),
			.APB_S_ADDR_DW(APB_S_ADDR_DW)
		) inst_APB_Subordinate (
			.S_APB_PCLK     (S_APB_PCLK),
			.S_APB_RESETn   (S_APB_RESETn),
			.S_APB_PADDR    (S_APB_PADDR),
			.S_APB_PSEL     (S_APB_PSEL),
			.S_APB_PENABLE  (S_APB_PENABLE),
			.S_APB_PWRITE   (S_APB_PWRITE),
			.S_APB_WDATA    (S_APB_WDATA),
			.S_APB_PPROT    (S_APB_PPROT),
			.S_APB_STRB     (S_APB_STRB),
			.S_APB_PRDATA   (S_APB_PRDATA),
			.S_APB_PREADY   (S_APB_PREADY),
			.S_APB_PSLAVERR (S_APB_PSLAVERR),
			.reg_cfg_rdata  (reg_cfg_rdata),
			.reg_cfg_wdata  (reg_cfg_wdata),
			.reg_cfg_addr   (reg_cfg_addr),
			.reg_cfg_strobe (reg_cfg_strobe),
			.reg_cfg_wr     (reg_cfg_wr)
		);

			reg_cfg #(
			.DMAC_BASE_ADDR(DMAC_BASE_ADDR)
		) inst_reg_cfg (
		////////////////apb///////////////////
			.wdata_i               (reg_cfg_wdata),
			.addr_i                (reg_cfg_addr),
			.presetn_i             (S_APB_RESETn),
			.pclk_i                (S_APB_PCLK),
			.pwrite_i               (reg_cfg_wr),
			.rdata_o               (reg_cfg_rdata),
		///////////////sync//////////////////	
			.sync_int_done_i       (sync_int_done),
			.sync_int_error_i      (sync_int_error),
			.sync_int_timeout_i    (sync_int_timeout),
			.reg_soft_rst_o        (reg_soft_rst),
			.DMA_START_o           (DMA_START),
			.reg_clk_gating_o      (reg_clk_gating),
		//////////////DMA engine/////////////
			.DMA_burst_cur_srcaddr_i (src_cur_addr),
			.DMA_burst_cur_dstaddr_i (dst_cur_addr),
			.DMA_cur_transfer_data_i(transfer_data),
			.reg_src_addr_o        (src_addr),
			.reg_dst_addr_o        (dst_addr),
			.reg_tranfer_data_o    (transfer_data),
			.reg_time_out_o        (time_out),
			.reg_peri_pri_o        (peri_pri),
			.reg_mem_pri_o         (mem_pri),
		//////////////irq///////////////////
			.reg_int_o             (DMA_IRQ)
		);
			sync inst_sync(
			.PCLK_i                (S_APB_PCLK),
			.ACLK_i                (M_AXI_ACLK),
			.CLK_peri_i            (PERI_CLK_i),
			.apb_s_rstn_i          (S_APB_RESETn),
			.axi_m_rstn_i          (M_AXI_ARESETN),
			.rstn_peri_i           (PERI_RESETN_i),
			///////////////////reg_cfg///////////////////
			.reg_soft_rst_i        (reg_soft_rst),
			.reg_start_i           (DMA_START),
			.reg_clk_gating_i      (reg_clk_gating),
			.sync_int_done_o       (sync_int_done),
			.sync_int_error_o      (sync_int_error),
			.sync_int_timeout_o    (sync_int_timeout),
			///////////////////DMA engine///////////////////
			.sync_dma_int_done_i   (dma_done_int),
			.sync_dma_int_error_i (dma_error_int),
			.sync_dma_int_timeout_i  (dma_timeout_int),
			.sync_start_o          (dma_start),
			.sync_dma_soft_rst_o   (dma_soft_rst),
			.sync_dma_clk_gating_o (dma_clk_gating),
			///////////////////Peripheral///////////////////
			.DMA_P0_REQ_i          (DMA_P0_REQ),
			.DMA_P1_REQ_i          (DMA_P1_REQ),
			.DMA_P2_REQ_i          (DMA_P2_REQ),
			.DMA_P3_REQ_i          (DMA_P3_REQ),
			///////////////////Arbiter///////////////////
			.SYNC_P0_REQ_o         (SYNC_P0_REQ),
			.SYNC_P1_REQ_o         (SYNC_P1_REQ),
			.SYNC_P2_REQ_o         (SYNC_P2_REQ),
			.SYNC_P3_REQ_o         (SYNC_P3_REQ)
		);

	DMA_engine #(
			.M_AXI_DATA_WIDTH(M_AXI_DATA_WIDTH),
			.M_AXI_ADDR_WIDTH(M_AXI_ADDR_WIDTH),
			.M_AXI_ID_WIDTH(M_AXI_ID_WIDTH)
			//.M_AXI_WUSER_WIDTH(M_AXI_WUSER_WIDTH),
			//.M_AXI_AWUSER_WIDTH(M_AXI_AWUSER_WIDTH),
			//.M_AXI_ARUSER_WIDTH(M_AXI_ARUSER_WIDTH),
			//.M_AXI_RUSER_WIDTH(M_AXI_RUSER_WIDTH),
			//.M_AXI_BUSER_WIDTH(M_AXI_BUSER_WIDTH)
		) inst_DMA_engine (
			.ACLK_i                      (M_AXI_ACLK),
			.ARESETN_i                   (M_AXI_ARESETN),
			///////////////////AXI///////////////////
			.dma_axi_awaddr_o            (dma_axi_awaddr),
			.dma_axi_araddr_o            (dma_axi_araddr),
			.dma_axi_awburst_o           (dma_axi_awburst),
			.dma_axi_awsize_o            (dma_axi_awsize),
			.dma_axi_awlen_o             (dma_axi_awlen),
			.dma_axi_arburst_o           (dma_axi_arburst),
			.dma_axi_arsize_o            (dma_axi_arsize),
			.dma_axi_arlen_o             (dma_axi_arlen),
			.dma_axi_awready_i           (dma_axi_awready),
			.dma_axi_arready_i           (dma_axi_arready),
			.dma_axi_awvalid_o			 (dma_axi_awvalid),
			.dma_axi_arvalid_o			 (dma_axi_arvalid),
			.dma_axi_aerror_i            (dma_axi_aerror),
			//.dma_axi_awid_o              (dma_axi_awid),
			//.dma_axi_arid_o              (dma_axi_arid),
			//.dma_axi_rid_o               (dma_axi_rid),
			.dma_axi_rdata_i             (dma_axi_rdata),
			.dma_axi_wdata_o             (dma_axi_wdata),
			.dma_axi_wlast_i             (dma_axi_wlast),
			.dma_axi_rlast_i             (dma_axi_rlast),
			.dma_axi_wvalid_o            (dma_axi_wvalid),
			.dma_axi_wready_i            (dma_axi_wready),
			.dma_axi_rvalid_i            (dma_axi_rvalid),
			.dma_axi_rready_o            (dma_axi_rready),
			///////////////////FIFO///////////////////
			.dma_fifo_wr_o               (dma_fifo_wren),
			.dma_fifo_rd_o               (dma_fifo_rden),
			.dma_fifo_full_i             (dma_fifo_full),
			.dma_fifo_empty_i            (dma_fifo_empty),
			.dma_fifo_rdata_i            (dma_fifo_dout),
			.dma_fifo_wdata_o            (dma_fifo_din),
			///////////////////Arbiter///////////////////
			.dma_arbiter_src_req_i       (dma_arbiter_src_req),
			.dma_arbiter_dst_req_i       (dma_arbiter_dst_req),
			.dma_arbiter_transfer_data_o (dma_arbiter_transfer_data),
			.dma_arbiter_src_work_o      (dma_arbiter_src_work),
			.dma_arbiter_dst_work_o      (dma_arbiter_dst_work),
			.dma_arbiter_src_ack_o       (dma_arbiter_src_ack),
			.dma_arbiter_dst_ack_o       (dma_arbiter_dst_ack),
			.dma_arbiter_peri_pri_o      (dma_arbiter_peri_pri),
			.dma_arbiter_mem_pri_o       (dma_arbiter_mem_pri),
			///////////////////reg cfg///////////////////
			.dma_reg_src_addr_i          (src_addr),
			.dma_reg_dst_addr_i          (dst_addr),
			.dma_reg_transfer_data_i     (transfer_data),
			.dma_reg_time_out_i          (time_out),
			.dma_reg_peri_pri_i          (peri_pri),
			.dma_reg_mem_pri_i           (mem_pri),
			.dma_reg_src_cur_addr_o      (src_cur_addr),
			.dma_reg_dst_cur_addr_o      (dst_cur_addr),
			.dma_reg_cur_transfer_data_o (cur_transfer_data),
			///////////////////sync///////////////////
			.dma_sync_int_done_o          (dma_done_int),
			.dma_sync_int_error_o        (dma_error_int),
			.dma_sync_int_timeout_o      (dma_timeout_int),
			.dma_sync_start_i            (dma_start),
			.dma_sync_soft_rst_i         (dma_soft_rst),
			.dma_clk_gating_i			 (dma_clk_gating),
			//.dma_dst_data_num            (dma_dst_data_num),
			//.dma_dst_src_num             (dma_dst_src_num),
			.dma_soft_rst                (EP_SOFT_RST)
		);
			Arbiter inst_Arbiter
		(
			.clk_i                   (M_AXI_ACLK),
			.resetn_i                (M_AXI_ARESETN),
			.P0_ACK_o                (DMA_P0_ACK),
			.P1_ACK_o                (DMA_P1_ACK),
			.P2_ACK_o                (DMA_P2_ACK),
			.P3_ACK_o                (DMA_P3_ACK),
			.SYNC_P0_REQ_i           (SYNC_P0_REQ),
			.SYNC_P1_REQ_i           (SYNC_P1_REQ),
			.SYNC_P2_REQ_i           (SYNC_P2_REQ),
			.SYNC_P3_REQ_i           (SYNC_P3_REQ),
			.arbiter_src_ack_i       (dma_arbiter_src_ack),
			.arbiter_dst_ack_i       (dma_arbiter_dst_ack),
			.arbiter_src_req_o       (dma_arbiter_src_req),
			.arbiter_dst_req_o       (dma_arbiter_dst_req),
			.arbiter_transfer_data_i (dma_arbiter_transfer_data),
			.arbiter_src_work_i      (dma_arbiter_src_work),
			.arbiter_dst_work_i      (dma_arbiter_dst_work),
			.arbiter_peri_pri_i      (dma_arbiter_peri_pri),
			.arbiter_mem_pri_i       (dma_arbiter_mem_pri)
		);

    		sync_fifo #(
			.DW(M_AXI_DATA_WIDTH),
			.depth(16)
		) inst_sync_fifo (
			.clk       (M_AXI_ACLK),
			.rstn      (M_AXI_ARESETN),
			.din       (dma_fifo_din),
			.wr_en     (dma_fifo_wren),
			.rd_en     (dma_fifo_rden),
			.dout      (dma_fifo_dout),
			.empty     (dma_fifo_empty),
			.full      (dma_fifo_full),
			.overflow  (dma_fifo_overflow),
			.underflow (dma_fifo_underflow)
		);
			AXI_FULL_MANAGER #(
			.M_AXI_DATA_WIDTH(M_AXI_DATA_WIDTH),
			.M_AXI_ADDR_WIDTH(M_AXI_ADDR_WIDTH),
			//.M_TARGET_SURBODINATE_BASE_ADDR(M_TARGET_SURBODINATE_BASE_ADDR),
			//.M_AXI_BURST_LEN(M_AXI_BURST_LEN),
			.M_AXI_ID_WIDTH(M_AXI_ID_WIDTH),
			.M_AXI_WUSER_WIDTH(M_AXI_WUSER_WIDTH),
			.M_AXI_AWUSER_WIDTH(M_AXI_AWUSER_WIDTH),
			.M_AXI_ARUSER_WIDTH(M_AXI_ARUSER_WIDTH),
			.M_AXI_RUSER_WIDTH(M_AXI_RUSER_WIDTH),
			.M_AXI_BUSER_WIDTH(M_AXI_BUSER_WIDTH)
		) inst_AXI_FULL_MANAGER (
			.M_AXI_ACLK        (M_AXI_ACLK),
			.M_AXI_ARESETN     (M_AXI_ARESETN),
			.axi_dma_awvalid_i (dma_axi_awvalid),
			.axi_dma_wvalid_i  (dma_axi_wvalid),
			.axi_dma_wready_o  (dma_axi_wready),
			.axi_dma_awlen_i   (dma_axi_awlen),
			.axi_dma_awsize_i  (dma_axi_awsize),
			.axi_dma_awburst_i (dma_axi_awburst),
			.axi_dma_awaddr_i  (dma_axi_awaddr),
			.axi_dma_wlast_o   (dma_axi_wlast),
			.axi_dma_rlast_o   (dma_axi_rlast),
			.axi_dma_arvalid_i (dma_axi_arvalid),
			.axi_dma_rready_i  (dma_axi_rready),
			.axi_dma_rvalid_o  (dma_axi_rvalid),
			.axi_dma_arlen_i   (dma_axi_arlen),
			.axi_dma_arsize_i  (dma_axi_arsize),
			.axi_dma_arburst_i (dma_axi_arburst),
			.axi_dma_araddr_i  (dma_axi_araddr),
			.axi_dma_wdata_i   (dma_axi_wdata),
			.axi_dma_rdata_o   (dma_axi_rdata),
			.M_AXI_AWVALID     (M_AXI_AWVALID),
			.M_AXI_AWREADY     (M_AXI_AWREADY),
			.M_AXI_AWID        (M_AXI_AWID),
			.M_AXI_WVALID      (M_AXI_WVALID),
			.M_AXI_WLAST       (M_AXI_WLAST),
			.M_AXI_WREADY      (M_AXI_WREADY),
			.M_AXI_WDATA       (M_AXI_WDATA),
			.M_AXI_WUSER       (M_AXI_WUSER),
			.M_AXI_AWUSER      (M_AXI_AWUSER),
			.M_AXI_AWADDR      (M_AXI_AWADDR),
			.M_AXI_WSTRB       (M_AXI_WSTRB),
			.M_AXI_AWLEN       (M_AXI_AWLEN),
			.M_AXI_AWSIZE      (M_AXI_AWSIZE),
			.M_AXI_AWBUSRT     (M_AXI_AWBUSRT),
			.M_AXI_AWLOCK      (M_AXI_AWLOCK),
			.M_AXI_AWCACHE     (M_AXI_AWCACHE),
			.M_AXI_AWQOS       (M_AXI_AWQOS),
			.M_AXI_AWPROT      (M_AXI_AWPROT),
			.M_AXI_ARVALID     (M_AXI_ARVALID),
			.M_AXI_ARREADY     (M_AXI_ARREADY),
			.M_AXI_ARID        (M_AXI_ARID),
			.M_AXI_RID         (M_AXI_RID),
			.M_AXI_RVALID      (M_AXI_RVALID),
			.M_AXI_RLAST       (M_AXI_RLAST),
			.M_AXI_RREADY      (M_AXI_RREADY),
			.M_AXI_RDATA       (M_AXI_RDATA),
			.M_AXI_RUSER       (M_AXI_RUSER),
			.M_AXI_ARUSER      (M_AXI_ARUSER),
			.M_AXI_ARADDR      (M_AXI_ARADDR),
			.M_AXI_ARLEN       (M_AXI_ARLEN),
			.M_AXI_ARSIZE      (M_AXI_ARSIZE),
			.M_AXI_ARBUSRT     (M_AXI_ARBUSRT),
			.M_AXI_ARLOCK      (M_AXI_ARLOCK),
			.M_AXI_ARCACHE     (M_AXI_ARCACHE),
			.M_AXI_ARQOS       (M_AXI_ARQOS),
			.M_AXI_ARPROT      (M_AXI_ARPROT),
			.M_AXI_RRESP       (M_AXI_RRESP),
			.M_AXI_BID         (M_AXI_BID),
			.M_AXI_BRESP       (M_AXI_BRESP),
			.M_AXI_BUSER       (M_AXI_BUSER),
			.M_AXI_BVALID      (M_AXI_BVALID),
			.M_AXI_BREADY      (M_AXI_BREADY)
		);


    	
    	
    	
endmodule