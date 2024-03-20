`timescale 1ns / 1ps
//双端口ram，可同时读写。

module dp_ram
#(parameter DW=32,depth=16)
(
        wclk,
        rclk,
        dina,
        addra,
        wr_ena,
        addrb,
        rd_enb,
        doutb
        
    );
    input rclk;
    input wclk;
    input [DW-1:0]dina;
    input [clogb2(depth)-1:0]addra;
    input wr_ena;
    input [clogb2(depth)-1:0]addrb;
    input rd_enb;
    output reg [DW-1:0]doutb;
    
    reg [DW-1:0]mem[depth-1:0];
    
    always@(posedge wclk)begin
        if(wr_ena==1)begin
            mem[addra]<=dina;
        
        end
    
    
    end
        
    always@(posedge rclk)begin
        if(rd_enb==1)begin
            doutb<=mem[addrb];
        
        end
    
    
    end
    function integer clogb2(integer number);
           begin
               for(clogb2=0;number >0;clogb2=clogb2+1)
                    number=number>>1;
               end
           endfunction
endmodule
