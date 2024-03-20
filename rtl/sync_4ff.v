module sync_4ff
    (  
        input clk_a,
        input clk_b,
        input resetn_a,
        input resetn_b,
        input signal_in,
        output sync_signal
    );
    /****************连线********************/
    wire D0,D1,D2,D3;
    wire Q0,Q1,Q2,Q3;
      
    /****************例化********************/
    dff #(.DW(1)) inst_dff0 (.clk_in  (clk_a),.resetn  (resetn_a),.en      (1),.clk_gen (1),.d       (D0),.q       (Q0));
	dff #(.DW(1)) inst_dff1 (.clk_in  (clk_b),.resetn  (resetn_b),.en      (1),.clk_gen (1),.d       (D1),.q       (Q1));
	dff #(.DW(1)) inst_dff2 (.clk_in  (clk_b),.resetn  (resetn_b),.en      (1),.clk_gen (1),.d       (D2),.q       (Q2));
	dff #(.DW(1)) inst_dff3 (.clk_in  (clk_b),.resetn  (resetn_b),.en      (1),.clk_gen (1),.d       (D3),.q       (Q3)); 
    
    /****************组合逻辑****************/
      	assign D0=signal_in^Q0;
        assign D1=Q0;
        assign D2=Q1;
        assign D3=Q2;
        assign sync_signal = Q2^Q3;       
                 

endmodule