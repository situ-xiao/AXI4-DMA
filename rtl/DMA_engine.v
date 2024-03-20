module DMA_engine
    #(  parameter                  M_AXI_DATA_WIDTH              = 64,
       	parameter                  M_AXI_ADDR_WIDTH              = 32,
       //parameter                M_TARGET_SURBODINATE_BASE_ADDR = 32'h40000000,
       //	parameter                  M_AXI_BURST_LEN               = 1, //1,2,4,8,16,32,64,128,256
     	parameter                  M_AXI_ID_WIDTH                = 7
        //parameter                  M_AXI_WUSER_WIDTH             = 1,
        //parameter                  M_AXI_AWUSER_WIDTH            = 1,
        //parameter                  M_AXI_ARUSER_WIDTH            = 1,
        //parameter                  M_AXI_RUSER_WIDTH             = 1,
        //parameter                  M_AXI_BUSER_WIDTH             = 1
        )
    (  
        input								ACLK_i,
        input								ARESETN_i,
        ////////////////from to AXI_M////////////////////
        output	[M_AXI_ADDR_WIDTH-1:0]		dma_axi_awaddr_o,
        output	[M_AXI_ADDR_WIDTH-1:0]		dma_axi_araddr_o,
        output	[2:0]						dma_axi_awburst_o,
        output	[2:0]						dma_axi_awsize_o,
        output	[7:0]						dma_axi_awlen_o,
        output	[2:0]						dma_axi_arburst_o,
        output	[2:0]						dma_axi_arsize_o,
        output	[7:0]						dma_axi_arlen_o, 	
        input								dma_axi_awready_i,
        output								dma_axi_awvalid_o,
        output								dma_axi_arvalid_o,
        input								dma_axi_arready_i,
        input								dma_axi_aerror_i,
        //output	[M_AXI_ID_WIDTH-1:0]		dma_axi_awid_o,
        //output	[M_AXI_ID_WIDTH-1:0]		dma_axi_arid_o,
        //output	[M_AXI_ID_WIDTH-1:0]		dma_axi_rid_o,
        input	[M_AXI_DATA_WIDTH-1:0]		dma_axi_rdata_i,
        output	[M_AXI_DATA_WIDTH-1:0]		dma_axi_wdata_o,
        input								dma_axi_wlast_i,
        input 								dma_axi_rlast_i,
        //output	[M_AXI_DATA_WIDTH/8-1:0]	dma_axi_wstrb_o,
        //output	[M_AXI_DATA_WIDTH/8-1:0]	dma_axi_rstrb_o,
        output 								dma_axi_wvalid_o,
        input 								dma_axi_wready_i,
        input 								dma_axi_rvalid_i,
        output 								dma_axi_rready_o,
        ////////////////from to FIFO////////////////////
        output								dma_fifo_wr_o,
        output								dma_fifo_rd_o,
        input								dma_fifo_full_i,
        input								dma_fifo_empty_i,
        input	[M_AXI_DATA_WIDTH-1:0]		dma_fifo_rdata_i,
        output	[M_AXI_DATA_WIDTH-1:0]		dma_fifo_wdata_o,
        ////////////////from to Arbiter////////////////////
        input								dma_arbiter_src_req_i,
		input								dma_arbiter_dst_req_i,
		output	[31:0]						dma_arbiter_transfer_data_o,
		output 								dma_arbiter_src_work_o,
		output  							dma_arbiter_dst_work_o,
		output								dma_arbiter_src_ack_o,
		output								dma_arbiter_dst_ack_o,
		output [31:0]						dma_arbiter_peri_pri_o,
		output [31:0]						dma_arbiter_mem_pri_o,
		////////////////from to reg_cfg////////////////////
		input	[M_AXI_ADDR_WIDTH-1:0]		dma_reg_src_addr_i,
		input	[M_AXI_ADDR_WIDTH-1:0]		dma_reg_dst_addr_i,
		input	[32-1:0]					dma_reg_transfer_data_i,
		//input	[M_AXI_DATA_WIDTH-1:0]		dma_reg_dst_data_i,
		input	[31:0]						dma_reg_time_out_i,
		input   [31:0]						dma_reg_peri_pri_i,
		input   [31:0]						dma_reg_mem_pri_i,
		output  [31:0]						dma_reg_src_cur_addr_o,
		output  [31:0]						dma_reg_dst_cur_addr_o,
		output  [31:0]						dma_reg_cur_transfer_data_o,
		////////////////from to sync////////////////////
		output								dma_sync_int_done_o,
		output								dma_sync_int_error_o,
		output								dma_sync_int_timeout_o,
		input								dma_sync_start_i,
		input								dma_sync_soft_rst_i,
		input								dma_clk_gating_i,
		////////////////from to P/M////////////////////
		//output [M_AXI_DATA_WIDTH-1:0]dma_dst_data_num,
		//output [M_AXI_DATA_WIDTH-1:0]dma_dst_src_num,
		output dma_soft_rst
		//output dma_done





    );
		/****************参数********************/
		localparam IDLE=0;
		localparam WAIT_R_SRC=1;
		localparam R_SRC_START = 2;
		localparam R_SRC=3;
		localparam WAIT_W_DST=4;
		localparam W_DST_START=5;
		localparam W_DST=6;


		localparam FIXED=2'b00;
		localparam INCR=2'b01;
		localparam WRAP=2'b10;
		localparam INCR4=3'h3;
		localparam INCR8=3'h5;
		localparam INCR16=3'h7;
		localparam Byte=2'b00;
		localparam Halfword=2'b01;
		localparam Word=2'b10;
		localparam Double_word=2'b11;

		/****************寄存器******************/
		reg [2:0]state;
		reg [2:0]next_state;      
		reg [31:0]time_out_count;
		reg [31:0]r_cur_transfer_data;
		reg r_src_ack;
		reg r_dst_ack;
		reg [63:0]rdata_buffer1;
		reg [63:0]rdata_buffer2;
		//reg [5:0]buffer_cnt;
		reg [3:0]burst_cnt;
		reg r_dma_fifo_wr_en;
		//reg r_dma_fifo_rd_en;
		reg r_wvalid;
		reg r_rready;
		reg r_awvalid;
		reg r_arvalid;
		reg buffer1_to_buffer2;
		reg [63:0]wdata_buffer;
		/****************连线********************/
		wire [1:0]burst_type;
		wire [1:0]src_burst_asize;
		wire [2:0]src_burst_length;
		wire [1:0]dst_burst_asize;
		wire [2:0]dst_burst_length;
		//wire [31:0]data_transfer_size;
		wire [4:0]cur_burst_length;
		wire waddr_handshake;
		wire raddr_handshake;
		wire wdata_handshake;
		wire rdata_handshake;
		

		/****************例化********************/
		
		
		/****************组合逻辑****************/
		assign dma_arbiter_src_work_o = state == WAIT_R_SRC;
		assign dma_arbiter_dst_work_o = state == WAIT_W_DST;
		assign dma_arbiter_transfer_data_o = dma_reg_transfer_data_i;
		assign dma_sync_int_timeout_o= time_out_count>dma_reg_time_out_i;       
		assign burst_type = dma_reg_transfer_data_i[15:14];
		assign src_burst_asize = dma_reg_transfer_data_i[9:8];
		assign dst_burst_asize = dma_reg_transfer_data_i[11:10];
		assign src_burst_length = dma_reg_transfer_data_i [2:0];
		assign dst_burst_length = dma_reg_transfer_data_i [6:4];
		assign dma_reg_cur_transfer_data_o = r_cur_transfer_data;


		assign cur_burst_length = (r_cur_transfer_data > 'd16 )? 'd16:r_cur_transfer_data;
		assign dma_axi_arlen_o = {8{(state == R_SRC)}} & cur_burst_length;
		assign dma_axi_awlen_o = {8{(state == W_DST)}} & cur_burst_length;
		assign dma_axi_awsize_o = {3{(state == W_DST)}} & dst_burst_asize;
		assign dma_axi_arsize_o = {3{(state == R_SRC)}} & src_burst_asize;
		assign dma_axi_araddr_o = {32{(state == R_SRC)}} & dma_reg_src_addr_i;
		assign dma_axi_awaddr_o = {32{(state == W_DST)}} & dma_reg_dst_addr_i;
		assign dma_axi_awburst_o = {3{(state == W_DST)}} & dst_burst_length;
		assign dma_axi_arburst_o = {3{(state == R_SRC)}} & src_burst_length;
		assign dma_reg_src_cur_addr_o = ({32{(src_burst_asize == Byte)}} 	 	& (dma_reg_src_addr_i + burst_cnt)) |
										({32{(src_burst_asize == Halfword)}} 	& (dma_reg_src_addr_i + burst_cnt<<1)) |
										({32{(src_burst_asize == Word)}} 	 	& (dma_reg_src_addr_i + burst_cnt<<2)) | 
										({32{(src_burst_asize == Double_word)}} & (dma_reg_src_addr_i + burst_cnt<<3));

		assign dma_reg_dst_cur_addr_o = ({32{(dst_burst_asize == Byte)}} 	 	& (dma_reg_dst_addr_i + burst_cnt)) |
										({32{(dst_burst_asize == Halfword)}} 	& (dma_reg_dst_addr_i + burst_cnt<<1)) |
										({32{(dst_burst_asize == Word)}} 	 	& (dma_reg_dst_addr_i + burst_cnt<<2)) | 
										({32{(dst_burst_asize == Double_word)}} & (dma_reg_dst_addr_i + burst_cnt<<3));

		assign dma_arbiter_src_ack_o = r_src_ack;
		assign dma_arbiter_dst_ack_o = r_dst_ack;
		assign dma_sync_int_done_o = (dma_fifo_empty_i | dma_axi_wlast_i) &(~dma_arbiter_dst_req_i)&dma_arbiter_dst_ack_o &(cur_burst_length==0);
		assign dma_arbiter_peri_pri_o = dma_reg_peri_pri_i;
		assign dma_arbiter_mem_pri_o = dma_reg_mem_pri_i;
		assign dma_soft_rst = dma_sync_soft_rst_i;

		//assign dma_fifo_wr_o = state == R_SRC;
		assign dma_fifo_wr_o = rdata_handshake;
		assign dma_fifo_rd_o = r_wvalid;

		assign waddr_handshake = dma_axi_awvalid_o & dma_axi_awready_i;
		assign raddr_handshake = dma_axi_arvalid_o & dma_axi_arready_i;
		assign wdata_handshake = dma_axi_wvalid_o & dma_axi_wready_i;
		assign rdata_handshake = dma_axi_rvalid_i & dma_axi_rready_o;
		assign dma_fifo_wdata_i = rdata_buffer2;
		assign dma_axi_wdata_o =  {32{(state == W_DST)}} & dma_fifo_rdata_i;
		assign dma_axi_rready_o = r_rready ;
		assign dma_axi_arvalid_o = r_arvalid;
		assign dma_axi_awvalid_o = r_awvalid;
		assign dma_axi_wvalid_o = r_wvalid;
		

		/****************时序逻辑****************/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            state<=IDLE;   	    		
		        else 
		        	state<=next_state;
		end
		/*
			 timeout interrupt counter
		*/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            time_out_count<=0;   	    		
		        else 
		        	if(state==WAIT_R_SRC || state == WAIT_W_DST)begin
		        		if (dma_sync_int_timeout_o)
		        			time_out_count<=0;
		        		else
		        			time_out_count<=time_out_count+1'b1;
		        	end
		        	else
		        		time_out_count<=0;

		end
		/*
				request acknowlege
		*/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_cur_transfer_data<=0;   	    		
		        else begin
		        	if (state==IDLE)
		        		r_cur_transfer_data<=dma_reg_transfer_data_i;
		        	else if (state==W_DST && dma_axi_wlast_i)
		        		r_cur_transfer_data<=r_cur_transfer_data - cur_burst_length;
		        	else
		        		r_cur_transfer_data<=r_cur_transfer_data;
		        end
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_src_ack<=0;   	    		
		        else 
		        	if(state==R_SRC)
		        		if((~dma_arbiter_src_req_i)&&dma_arbiter_src_ack_o)
		        			r_src_ack<=0;
		        		else
		        			r_src_ack<=dma_arbiter_src_req_i;
		        	else
		        		r_src_ack<=r_src_ack;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_dst_ack<=0;   	    		
		        else 
		        	if(state==W_DST)
		        		if((~dma_arbiter_dst_req_i)&&dma_arbiter_dst_ack_o)
		        			r_dst_ack<=0;
		        		else
		        			r_dst_ack<=dma_arbiter_dst_req_i;
		        	else
		        		r_dst_ack<=r_dst_ack;
		end
		/*
				burst transfer
		*/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            burst_cnt<=0;   	    		
		        else 
		        	if(state == R_SRC && rdata_handshake)begin
		        		if (~dma_axi_rlast_i) 
		        			burst_cnt<=burst_cnt + 1'b1;
		        		else 
		        			burst_cnt<=0;
		        	end
		        	else if(state == W_DST && wdata_handshake) begin
		        		if (~dma_axi_wlast_i) 
		        			burst_cnt<=burst_cnt + 1'b1;
		        		else 
		        			burst_cnt<=0;
		        	end
		        	else
		        		burst_cnt<=burst_cnt;	
		end
		/*
				read data align
		*/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_arvalid<=0;   	    		
		        else if(raddr_handshake)
		        	r_arvalid<=0;
		        else if(state == R_SRC_START)
		        	r_arvalid<=1'b1;
		        else
		        	r_arvalid<=r_arvalid;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		        	rdata_buffer1<=0;	
		        else if(state == R_SRC) begin
					case(src_burst_asize)
						Byte:begin
							case(burst_cnt[2:0])
								3'b000:rdata_buffer1[7:0]  <=dma_axi_rdata_i[7:0];
								3'b001:rdata_buffer1[15:8] <=dma_axi_rdata_i[15:8];
								3'b010:rdata_buffer1[23:16]<=dma_axi_rdata_i[23:16];
								3'b011:rdata_buffer1[31:24]<=dma_axi_rdata_i[31:24];
								3'b100:rdata_buffer1[39:32]<=dma_axi_rdata_i[39:32];
								3'b101:rdata_buffer1[47:40]<=dma_axi_rdata_i[47:40];
								3'b110:rdata_buffer1[55:48]<=dma_axi_rdata_i[55:48];
								3'b111:rdata_buffer1[63:56]<=dma_axi_rdata_i[63:56];
							endcase	
						end
						Halfword:begin
							case(burst_cnt[1:0])
								2'b00:rdata_buffer1[15:0]<=dma_axi_rdata_i[15:0];
								2'b01:rdata_buffer1[31:16]<=dma_axi_rdata_i[31:16];
								2'b10:rdata_buffer1[47:32]<=dma_axi_rdata_i[47:32];
								2'b11:rdata_buffer1[63:48]<=dma_axi_rdata_i[63:48];
							endcase	
						end
						Word:begin
							case(burst_cnt[0])
								1'b0:rdata_buffer1[31:0]<=dma_axi_rdata_i[31:0];
								1'b1:rdata_buffer1[63:32]<=dma_axi_rdata_i[63:32];
							endcase	
						end
						Double_word:rdata_buffer1<=dma_axi_rdata_i;
					endcase		
				end
				else
					rdata_buffer1<=rdata_buffer1;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		        	buffer1_to_buffer2<=0;	
		        else if(state == R_SRC) begin
					case(src_burst_asize)
						Byte:buffer1_to_buffer2 <= (burst_cnt[2:0]==3'b111) | dma_axi_rlast_i;
						Halfword:buffer1_to_buffer2 <= (burst_cnt[1:0]==2'b11) | dma_axi_rlast_i;
						Word:buffer1_to_buffer2 <= burst_cnt[0] | dma_axi_rlast_i;
						Double_word:buffer1_to_buffer2 <= dma_axi_rlast_i;
					endcase		
				end
				else
					buffer1_to_buffer2<=0;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		        	rdata_buffer2<=0;	
		        else if(buffer1_to_buffer2) begin
					case(burst_cnt[2:0])
						3'b000:rdata_buffer2<={56'h0,rdata_buffer1[7:0]};
						3'b001:rdata_buffer2<={48'h0,rdata_buffer1[15:0]};
						3'b010:rdata_buffer2<={40'h0,rdata_buffer1[23:0]};
						3'b011:rdata_buffer2<={32'h0,rdata_buffer1[31:0]};
						3'b100:rdata_buffer2<={24'h0,rdata_buffer1[39:0]};
						3'b101:rdata_buffer2<={16'h0,rdata_buffer1[47:0]};
						3'b110:rdata_buffer2<={8'h0,rdata_buffer1[55:0]};
						3'b111:rdata_buffer2<=rdata_buffer1[63:0];
					endcase	
				end
				else
					rdata_buffer2<=rdata_buffer2;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_dma_fifo_wr_en<=0;   	    		
		        else 
		        	r_dma_fifo_wr_en<=buffer1_to_buffer2;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_rready<=0;   	    		
		        else 
		        	if(dma_axi_rlast_i)
		        		r_rready<=0;
		        	else if(~dma_axi_rlast_i & state==R_SRC)
		        		r_rready<=1'b1;
		        	else
		        		r_rready<=r_rready;
		end
		/*
				write data align
		*/
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_awvalid<=0;   	    		
		        else if(waddr_handshake)
		        	r_awvalid<=0;
		        else if(state == W_DST_START)
		        	r_awvalid<=1'b1;
		        else
		        	r_awvalid<=r_awvalid;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		        	wdata_buffer<=0;	
		        else if(state == W_DST) begin
					case(dst_burst_asize)
						Byte:begin
							case(burst_cnt[2:0])
								3'b000:wdata_buffer<={56'h0,dma_fifo_rdata_i[7:0]};
								3'b001:wdata_buffer<={56'h0,dma_fifo_rdata_i[15:8]};
								3'b010:wdata_buffer<={56'h0,dma_fifo_rdata_i[23:16]};
								3'b011:wdata_buffer<={56'h0,dma_fifo_rdata_i[31:24]};
								3'b100:wdata_buffer<={56'h0,dma_fifo_rdata_i[39:32]};
								3'b101:wdata_buffer<={56'h0,dma_fifo_rdata_i[47:40]};
								3'b110:wdata_buffer<={56'h0,dma_fifo_rdata_i[55:48]};
								3'b111:wdata_buffer<={56'h0,dma_fifo_rdata_i[63:56]};
							endcase	
						end
						Halfword:begin
							case(burst_cnt[1:0])
								2'b00:wdata_buffer[15:0]<={48'h0,dma_fifo_rdata_i[15:0]};
								2'b01:wdata_buffer[15:0]<={48'h0,dma_fifo_rdata_i[31:16]};
								2'b10:wdata_buffer[15:0]<={48'h0,dma_fifo_rdata_i[47:32]};
								2'b11:wdata_buffer[15:0]<={48'h0,dma_fifo_rdata_i[63:48]};
							endcase	
						end
						Word:begin
							case(burst_cnt[0])
								1'b0:wdata_buffer[31:0]<={32'h0,dma_fifo_rdata_i[31:0]};
								1'b1:wdata_buffer[31:0]<={32'h0,dma_fifo_rdata_i[63:32]};
							endcase	
						end
						Double_word:wdata_buffer<=dma_fifo_rdata_i;
					endcase		
				end
				else
					wdata_buffer<=0;
		end
		always @(posedge ACLK_i or negedge ARESETN_i) begin
		        if (~ARESETN_i) 
		            r_wvalid<=0;   	    		
		        else 
		        	if(dma_axi_wlast_i)
		        		r_wvalid<=0;
		        	else if(state == W_DST & ~dma_axi_wlast_i)
		        		r_wvalid<=1'b1;
		        	else
		        		r_wvalid<=r_wvalid;
		end





		/****************状态机******************/
		always @(posedge ACLK_i or negedge ARESETN_i) begin 
		        if(~ARESETN_i) begin
		            next_state<= 0;
		        end else begin
		            case(state)
		            IDLE:begin
		            	if (dma_sync_start_i) 
		            		next_state<=WAIT_R_SRC;
		            	else
		            		next_state<=IDLE;
		            end
		            WAIT_R_SRC:begin
		            	if (dma_sync_int_timeout_o ) 
		            		next_state<=IDLE;
		            	else begin
		            		if(dma_arbiter_src_req_i)
		            			next_state<=R_SRC_START;
		            		else
		            			next_state<=WAIT_R_SRC;
		            	end
		            end
		            R_SRC_START:begin
		            	if(raddr_handshake)
		            		next_state<=R_SRC;
		            	else
		            		next_state<=R_SRC_START;
		            end
		            R_SRC:begin
		            	if ((~dma_arbiter_src_req_i)&&dma_arbiter_src_ack_o && ~dma_fifo_full_i && ~dma_axi_rlast_i)
		            		next_state <= WAIT_R_SRC;
		            	else if(dma_fifo_full_i || dma_axi_rlast_i)
		            		next_state <= WAIT_W_DST;
		            	else
		            		next_state <= R_SRC;
		            end
		            WAIT_W_DST:begin
		            	if (dma_sync_int_timeout_o ) 
		            		next_state<=IDLE;
		            	else begin
		            		if(dma_arbiter_dst_req_i)
		            			next_state<=W_DST_START;
		            		else
		            			next_state<=WAIT_W_DST;
		            	end
		            end
		            W_DST_START:begin
		            	if(waddr_handshake)
		            		next_state<=W_DST;
		            	else
		            		next_state<=W_DST_START;
		            end
		            W_DST:begin
		            	if ((~dma_arbiter_dst_req_i)&&dma_arbiter_dst_ack_o && ~dma_fifo_empty_i && ~dma_axi_wlast_i)
		            		next_state <= WAIT_W_DST;
		            	else if((dma_fifo_empty_i || dma_axi_wlast_i) && (~dma_arbiter_dst_req_i)&&dma_arbiter_dst_ack_o) 
		            		if(r_cur_transfer_data>0)
		            			next_state <= WAIT_R_SRC;
		            		else
		            			next_state <= IDLE;
		            	else
		            		next_state <= W_DST;
		            end
		            default:next_state<=IDLE;
		            endcase
		        end
		end
		
		
		
		
		
		
		endmodule