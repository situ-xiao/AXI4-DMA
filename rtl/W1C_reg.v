module W1C_reg
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
                    dff_r[DW-1:DW/2]<=0;              
            else if(en) 
                    dff_r[DW-1:DW/2]<=d[DW-1:DW/2];
            else 
                    dff_r[DW-1:DW/2]<=dff_r[DW-1:DW/2];
    end    
    generate
        genvar i;
                for (i = 0; i < DW/2; i = i + 1)begin
                       always @(posedge clk or negedge resetn) begin
                                if (~resetn) 
                                        dff_r[i]<=0;              
                                else if(dff_r[i])
                                        dff_r[i]<=0;
                                else if(en&d[i+DW/2]) 
                                        dff_r[i]<=d[i];
                                else
                                        dff_r[i]<=dff_r[i];
                end  
                        end
    endgenerate



endmodule