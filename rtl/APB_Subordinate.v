module APB_Subordinate
    #(parameter APB_S_DATA_DW = 32 ,
    					  APB_S_ADDR_DW = 32
    					  )
    (  
        input							S_APB_PCLK,
        input							S_APB_RESETn,
        input	[APB_S_ADDR_DW-1:0]		S_APB_PADDR,
        input							S_APB_PSEL,
        input							S_APB_PENABLE,
        input							S_APB_PWRITE,
        input	[APB_S_DATA_DW-1:0]		S_APB_WDATA,
        input	[2:0]					S_APB_PPROT,
        input	[APB_S_DATA_DW/8-1:0]	S_APB_STRB,
        output	[APB_S_DATA_DW-1:0]		S_APB_PRDATA,
        output							S_APB_PREADY,
        output							S_APB_PSLAVERR,
        input	[APB_S_DATA_DW-1:0]		reg_cfg_rdata,
        output	[APB_S_DATA_DW-1:0]		reg_cfg_wdata,
        output	[APB_S_ADDR_DW-1:0]		reg_cfg_addr,
        output	[APB_S_DATA_DW/8-1:0]	reg_cfg_strobe,
        output 							reg_cfg_wr


    );
/****************寄存器******************/
       reg [APB_S_DATA_DW-1:0] 		r_wdata;
       reg [APB_S_ADDR_DW-1:0]		r_addr;
       reg [APB_S_DATA_DW/8-1:0] 	r_strb;
       reg 							r_pwrite;
/****************组合逻辑****************/
       assign S_APB_PREADY		=		1'b1;
       assign reg_cfg_wdata	=		r_wdata;
       assign reg_cfg_addr		=		r_addr;
       assign reg_cfg_strobe	=		r_strb;
       assign S_APB_PSLAVERR	=		0;
       assign reg_wr					=		r_pwrite;
       assign S_APB_PRDATA    = reg_cfg_rdata;  
/****************时序逻辑****************/
		always @(posedge S_APB_PCLK or negedge S_APB_RESETn) begin
		    	if (~S_APB_RESETn) 
		    			r_wdata<=0;
		    	else if(S_APB_PSEL&&S_APB_PREADY)
		    			r_wdata<=S_APB_WDATA;
		    	else
		    			r_wdata<=r_wdata;
		end
		always @(posedge S_APB_PCLK or negedge S_APB_RESETn) begin
		    	if (~S_APB_RESETn) 
		    			r_addr<=0;
		    	else if(S_APB_PSEL)
		    			r_addr<=S_APB_PADDR;
		    	else
		    			r_addr<=r_addr;
		end
		always @(posedge S_APB_PCLK or negedge S_APB_RESETn) begin
		    	if (~S_APB_RESETn) 
		    			r_strb<=0;
		    	else if(S_APB_PSEL)
		    			r_strb<=S_APB_STRB;
		    	else
		    			r_strb<=r_strb;
		end
		always @(posedge S_APB_PCLK or negedge S_APB_RESETn) begin
		    	if (~S_APB_RESETn) 
		    			r_pwrite<=0;
		    	else if(S_APB_PSEL)
		    			r_pwrite<=S_APB_PWRITE;
		    	else
		    			r_pwrite<=r_pwrite;
		end





/****************状态机******************/




endmodule