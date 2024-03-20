module AXI_FULL_MANAGER
    #( 	parameter                   M_AXI_DATA_WIDTH               	= 64,
       	parameter                  M_AXI_ADDR_WIDTH                	= 32,
       	//parameter                  M_TARGET_SURBODINATE_BASE_ADDR  	= 32'h40000000,
     	//parameter                  M_AXI_BURST_LEN                  = 1, //1,2,4,8,16,32,64,128,256
     	parameter                  M_AXI_ID_WIDTH                   = 1,
        parameter                  M_AXI_WUSER_WIDTH              	= 1,
        parameter                  M_AXI_AWUSER_WIDTH             	= 1,
        parameter                  M_AXI_ARUSER_WIDTH             	= 1,
        parameter                  M_AXI_RUSER_WIDTH              	= 1,
        parameter                  M_AXI_BUSER_WIDTH              	= 1
)(  	
        input								M_AXI_ACLK		,
        input								M_AXI_ARESETN	,
        ////////////DMA engine PORT///////////
        input 								axi_dma_awvalid_i,
        input 								axi_dma_wvalid_i,
        output								axi_dma_wready_o,
        input	[7:0]						axi_dma_awlen_i,
        input	[2:0]						axi_dma_awsize_i,
        input	[1:0]						axi_dma_awburst_i,
        input 	[M_AXI_ADDR_WIDTH-1:0]		axi_dma_awaddr_i,
        output								axi_dma_wlast_o,
        output								axi_dma_rlast_o,
        input								axi_dma_arvalid_i,
        input								axi_dma_rready_i,
        output								axi_dma_rvalid_o,
        input	[7:0]						axi_dma_arlen_i,
        input	[2:0]						axi_dma_arsize_i,
        input	[1:0]						axi_dma_arburst_i,
        input 	[M_AXI_ADDR_WIDTH-1:0]		axi_dma_araddr_i,
        input	[M_AXI_DATA_WIDTH-1:0]		axi_dma_wdata_i,
        output 	[M_AXI_DATA_WIDTH-1:0]		axi_dma_rdata_o,
        ////////////WRITE PORT/////////////
		output								M_AXI_AWVALID	,
		input								M_AXI_AWREADY	,
		output	[M_AXI_ID_WIDTH-1:0]		M_AXI_AWID    	,
		output								M_AXI_WVALID  	,
		output								M_AXI_WLAST  	,	
		input								M_AXI_WREADY	,
		output	[M_AXI_DATA_WIDTH-1:0]		M_AXI_WDATA		,
		output	[M_AXI_WUSER_WIDTH-1:0]		M_AXI_WUSER   	,
		output	[M_AXI_AWUSER_WIDTH-1:0]	M_AXI_AWUSER  	,
		output	[M_AXI_ADDR_WIDTH-1:0]		M_AXI_AWADDR  	,
		output	[M_AXI_DATA_WIDTH/8-1:0]	M_AXI_WSTRB   	,
		output	[7:0]						M_AXI_AWLEN   	,
		output	[2:0]						M_AXI_AWSIZE	,
		output	[1:0]						M_AXI_AWBUSRT	,
		output								M_AXI_AWLOCK 	,
		output	[3:0]						M_AXI_AWCACHE	,
		output	[3:0]						M_AXI_AWQOS  	,
		output	[2:0]						M_AXI_AWPROT  	,
		////////////READ PORT/////////////
		output								M_AXI_ARVALID	,
		input								M_AXI_ARREADY	,
		output	[M_AXI_ID_WIDTH-1:0]		M_AXI_ARID    	,
		input	[M_AXI_ID_WIDTH-1:0]		M_AXI_RID    	,
		input								M_AXI_RVALID  	,
		input								M_AXI_RLAST  	,	
		output								M_AXI_RREADY	,
		input	[M_AXI_DATA_WIDTH-1:0]		M_AXI_RDATA		,
		output	[M_AXI_WUSER_WIDTH-1:0]		M_AXI_RUSER   	,
		output	[M_AXI_AWUSER_WIDTH-1:0]	M_AXI_ARUSER  	,
		output	[M_AXI_ADDR_WIDTH-1:0]		M_AXI_ARADDR  	,
		output	[7:0]						M_AXI_ARLEN   	,
		output	[2:0]						M_AXI_ARSIZE	,
		output	[1:0]						M_AXI_ARBUSRT	,
		output								M_AXI_ARLOCK 	,
		output	[3:0]						M_AXI_ARCACHE	,
		output	[3:0]						M_AXI_ARQOS  	,
		output	[2:0]						M_AXI_ARPROT  	,
		input	[1:0]						M_AXI_RRESP		,
		////////////RESPONSE PORT///////	//////
		input	[M_AXI_ID_WIDTH-1:0]		M_AXI_BID      	,
		input	[1:0]						M_AXI_BRESP     , 
		input	[M_AXI_BUSER_WIDTH-1:0]		M_AXI_BUSER   	,
		input								M_AXI_BVALID	,
		output								M_AXI_BREADY		

    );
		/****************参数********************/
		localparam           ST_IDLE        =   0   ,
							 ST_WRITE_START =   1   ,
							 ST_WRITE_TRANS =   2   ,
							 ST_WRITE_END   =   3   ,
							 ST_READ_START  =   4   ,
							 ST_READ_TRANS  =   5   ,
							 ST_READ_END    =   6   ;

		/****************寄存器******************/
		//reg							r_m_axi_awvalid	;
		reg	[M_AXI_ADDR_WIDTH-1:0]	r_m_axi_awaddr	;
		//reg	[M_AXI_DATA_WIDTH-1:0]	r_m_axi_wdata	;
		//reg							r_m_axi_wvalid	;
		
		reg							r_m_axi_write_start	;

		//reg							r_m_axi_arvalid	;       
		reg	[M_AXI_ADDR_WIDTH-1:0]	r_m_axi_araddr	;
		//reg	[M_AXI_DATA_WIDTH-1:0]	r_m_axi_rdata;
		//reg							r_m_axi_rready;
		reg							r_m_axi_read_start	;
		reg	[3:0]					r_m_burst_cnt;

		reg	[2:0]					r_current_st;
		reg	[2:0]					r_next_st;
		
		/****************连线********************/
		wire       	w_m_axi_whandshake ;
		wire       	w_m_axi_awhandshake ;
		wire       	w_m_axi_rhandshake ;
		wire       	w_m_axi_arhandshake ;
		wire  	   	w_m_axi_bhandshake	; 
		wire 		w_m_axi_wlast;   
		/****************组合逻辑****************/
		//////////////////////WRITE//////////////////////
		assign    M_AXI_AWVALID       = axi_dma_awvalid_i ;
		assign    M_AXI_WVALID        = axi_dma_wvalid_i ;
		assign    M_AXI_AWID          = 0 ;
		assign    M_AXI_WUSER         = 0 ;
		assign    M_AXI_AWUSER        = 0 ;
		assign    M_AXI_AWADDR        = axi_dma_awaddr_i; 
		assign    M_AXI_WSTRB         = {(M_AXI_DATA_WIDTH/8){1'b1}};
		assign    M_AXI_AWLEN         = axi_dma_awlen_i;
		assign    M_AXI_AWSIZE        = axi_dma_awsize_i;
		assign    M_AXI_WLAST         = w_m_axi_wlast;
		assign    w_m_axi_wlast       = (M_AXI_AWLEN==1'b1)? w_m_axi_whandshake:(r_m_burst_cnt==M_AXI_AWLEN-1'b1);
		assign    M_AXI_AWBUSRT       = 2'b01;
		assign    M_AXI_AWLOCK        = 0 ;
		assign    M_AXI_AWCACHE       = 4'b0010;
		assign    M_AXI_AWQOS         = 0;
		assign    M_AXI_AWPROT        = 0;
		assign    M_AXI_WDATA         = axi_dma_wdata_i;
		assign    w_m_axi_awhandshake = M_AXI_AWVALID    &   M_AXI_AWREADY;
		assign    w_m_axi_whandshake  = M_AXI_WVALID     &   M_AXI_WREADY;
		//////////////////////READ//////////////////////
		assign    M_AXI_ARVALID  	  = axi_dma_arvalid_i ;
		assign    M_AXI_RREADY  	  = axi_dma_rready_i ;
		assign 	  M_AXI_ARID 		  = 0 ;
		assign 	  M_AXI_RUSER 		  = 0 ;
		assign 	  M_AXI_ARUSER 	      = 0 ;
		assign 	  M_AXI_ARADDR   	  = axi_dma_araddr_i ; 
		assign 	  M_AXI_ARLEN      	  = axi_dma_arlen_i;
		assign    M_AXI_ARSIZE    	  = axi_dma_arsize_i;
		assign    M_AXI_ARBUSRT  	  = 2'b01;
		assign    M_AXI_ARLOCK		  = 0 ;
		assign    M_AXI_ARCACHE  	  = 4'b0010;
		assign    M_AXI_ARQOS     	  =	0;
		assign    M_AXI_ARPROT		  =	0;
		assign    w_m_axi_arhandshake = M_AXI_ARVALID   & M_AXI_ARREADY;
		assign    w_m_axi_rhandshake  = M_AXI_RVALID 	& M_AXI_RREADY;
		//////////////////////RESPONSE//////////////////////
		assign 	  M_AXI_BREADY		  = 1;
		assign    w_m_axi_bhandshake  = M_AXI_BVALID & M_AXI_BREADY;	



       
		             
		/****************时序逻辑****************/
		always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
		    	if (~M_AXI_ARESETN) 
		    			r_current_st<=ST_IDLE;
		    	else 
		    			r_current_st<=r_next_st;
		end
		
		/****************状态机******************/
		always @(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin 
		        if(~M_AXI_ARESETN) begin
		            r_next_st						<= ST_IDLE;
		        end else begin
		            case(r_current_st)
		            		ST_IDLE: begin
		            				r_next_st<=ST_WRITE_START;
		            		end
		            		ST_WRITE_START : begin
		            				if(M_AXI_AWVALID)
		            						r_next_st<=ST_WRITE_TRANS;
		            				else
		            						r_next_st<=r_next_st;
		            		end
		            		ST_WRITE_TRANS :begin
		            				if (w_m_axi_bhandshake) 
		            						r_next_st<=ST_WRITE_END;
		            				else 
		            						r_next_st<=r_next_st;
		            		end
		            		ST_WRITE_END :begin
		            				r_next_st<=ST_READ_START;
		            		end
		            		ST_READ_START :	begin
		            				if(M_AXI_ARVALID)
		            						r_next_st<=ST_READ_TRANS;
		            				else
		            						r_next_st<=r_next_st;
		            		end
							ST_READ_TRANS : begin
									if (M_AXI_RLAST) 
		            						r_next_st<=ST_READ_END;
		            				else 
		            						r_next_st<=r_next_st;
							end
							ST_READ_END : begin
		            				r_next_st<=ST_IDLE;
							end	
		            		default : r_next_st<=ST_IDLE;
		            endcase
		        end
		end
		
		/****************function****************/




		function integer clogb2(integer number);
		       begin
		           for(clogb2=0;number >0;clogb2=clogb2+1)
		                number=number>>1;
		           end
		       endfunction
endmodule	 