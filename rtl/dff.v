module dff
    #(parameter DW=1)
    (  
        input clk_in,
        input resetn,
        input en,
        input clk_gen,
        input   [DW-1:0]d,
        output [DW-1:0]q
    );
    wire clk;
    assign clk=clk_in&clk_gen;
    reg [DW-1:0]dff_r;
    assign q=dff_r;
    always @(posedge clk or negedge resetn) begin
        	if (~resetn) 
        	       	dff_r<='h0;	
        	else  if (en)
        			dff_r<=d;
        	else
        			dff_r<=dff_r;
    end



endmodule