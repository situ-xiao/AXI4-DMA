module max
    #(parameter DW=8)
    (  
        input [DW-1:0] A,
        input [DW-1:0] B,
        input [DW-1:0] C,
        input [DW-1:0] D,
        output [DW-1:0]max,
        output [1:0]pri_bit

    );
    wire [DW:0]E,F;
    wire [DW+1:0]max_pri;
    assign E=(A>=B)?{1'b0,A}:{1'b1,B};
    assign F=(C>=D)?{1'b0,C}:{1'b1,D};
    //assign max_pri=(E[DW-1:0]>F[DW-1:0])?{1'b0,E}:{1'b1,F};
    assign {pri_bit,max}=(E[DW-1:0]>=F[DW-1:0])?{1'b0,E}:{1'b1,F};//00 A /01 B /10 C /11 D
endmodule