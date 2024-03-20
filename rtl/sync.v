module sync
    (  
        input PCLK_i,
        input ACLK_i,
        input CLK_peri_i,
        input apb_s_rstn_i,
        input axi_m_rstn_i,
        input rstn_peri_i,
        ////////////from/to reg_cfg/////////
        input reg_soft_rst_i,
        input reg_start_i,
        input reg_clk_gating_i,
        output sync_int_done_o,
        output sync_int_error_o,
        output sync_int_timeout_o,
        ////////////from/to DMA engine////////
        input sync_dma_int_done_i,
        input sync_dma_int_error_i,
        input sync_dma_int_timeout_i,
        output sync_start_o,
        output sync_dma_soft_rst_o,
        output sync_dma_clk_gating_o,
        ////////////from/to Peripheral////////
        input DMA_P0_REQ_i,
        input DMA_P1_REQ_i,
        input DMA_P2_REQ_i,
        input DMA_P3_REQ_i,
        ////////////from/to Arbiter////////
        output SYNC_P0_REQ_o,
        output SYNC_P1_REQ_o,
        output SYNC_P2_REQ_o,
        output SYNC_P3_REQ_o
    );
      /****************连线********************/

    
    /****************寄存器******************/
     
    
    /****************组合逻辑****************/

                 
    /****************时序逻辑****************/
    
    
    /****************inst******************/
    	sync_4ff reg_sync_4ff1(
			.clk_a       (PCLK_i),
			.clk_b       (ACLK_i),
			.resetn_a    (apb_s_rstn_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (reg_soft_rst_i),
			.sync_signal (sync_dma_soft_rst_o)
		);
    	sync_4ff reg_sync_4ff2(
			.clk_a       (PCLK_i),
			.clk_b       (ACLK_i),
			.resetn_a    (apb_s_rstn_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (reg_start_i),
			.sync_signal (sync_start_o)
		);
		sync_4ff reg_sync_4ff3(
			.clk_a       (PCLK_i),
			.clk_b       (ACLK_i),
			.resetn_a    (apb_s_rstn_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (reg_clk_gating_i),
			.sync_signal (sync_dma_clk_gating_o)
		);
		sync_4ff dma_sync_4ff1(
			.clk_a       (ACLK_i),
			.clk_b       (PCLK_i),
			.resetn_a    (axi_m_rstn_i),
			.resetn_b    (apb_s_rstn_i),
			.signal_in   (sync_dma_int_done_i),
			.sync_signal (sync_int_done_o)
		);
		sync_4ff dma_sync_4ff2(
			.clk_a       (ACLK_i),
			.clk_b       (PCLK_i),
			.resetn_a    (axi_m_rstn_i),
			.resetn_b    (apb_s_rstn_i),
			.signal_in   (sync_dma_int_error_i),
			.sync_signal (sync_int_error_o)
		);
		sync_4ff dma_sync_4ff3(
			.clk_a       (ACLK_i),
			.clk_b       (PCLK_i),
			.resetn_a    (axi_m_rstn_i),
			.resetn_b    (apb_s_rstn_i),
			.signal_in   (sync_dma_int_timeout_i),
			.sync_signal (sync_int_timeout_o)
		);
		sync_4ff peri_sync_4ff1(
			.clk_a       (CLK_peri_i),
			.clk_b       (ACLK_i),
			.resetn_a    (rstn_peri_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (DMA_P0_REQ_i),
			.sync_signal (SYNC_P0_REQ_o)
		);
		sync_4ff peri_sync_4ff2(
			.clk_a       (CLK_peri_i),
			.clk_b       (ACLK_i),
			.resetn_a    (rstn_peri_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (DMA_P1_REQ_i),
			.sync_signal (SYNC_P1_REQ_o)
		);
		sync_4ff peri_sync_4ff3(
			.clk_a       (CLK_peri_i),
			.clk_b       (ACLK_i),
			.resetn_a    (rstn_peri_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (DMA_P2_REQ_i),
			.sync_signal (SYNC_P2_REQ_o)
		);
		sync_4ff peri_sync_4ff4(
			.clk_a       (CLK_peri_i),
			.clk_b       (ACLK_i),
			.resetn_a    (rstn_peri_i),
			.resetn_b    (axi_m_rstn_i),
			.signal_in   (DMA_P3_REQ_i),
			.sync_signal (SYNC_P3_REQ_o)
		);

    


endmodule