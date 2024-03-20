module int_ori_reg
 
    (  
        input clk_in,
        input resetn,
        input en,
        input [5:0]int_clear,
        input clk_gen,
        input   [32-1:0]d,
        output [32-1:0]q
    );
    wire clk;
    assign clk=clk_in&clk_gen;
    reg [32-1:0]dff_r;
    assign q=dff_r;
    wire enable;
    assign enable=(|int_clear)|en;
    always @(posedge clk or negedge resetn) begin
        	if (~resetn) 
        	       	dff_r<='h0;	
        	else  if (enable)
                    if(~(|int_clear))
        			     dff_r<=d;
                    else begin
                         dff_r[21:16]<={~int_clear[5:0]};
                         dff_r[13:8]<={~int_clear[5:0]};
                         dff_r[5:0]<={~int_clear[5:0]};
                    end
        	else
        			dff_r<=dff_r;
    end



endmodule