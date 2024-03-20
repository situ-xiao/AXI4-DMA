`timescale 1ns / 1ps
//同步fifo，例化dp_ram实现

module sync_fifo
#(parameter DW=32,depth=16)
(
    clk,
    rstn,
    din,
    wr_en,
    rd_en,
    dout,
    empty,
    full,
    overflow,
    underflow
);
  input clk;
  input [DW-1:0]din;
  input rstn;
  input wr_en;
  input rd_en;
  output [DW-1:0]dout;
  output reg empty;//读完标志
  output reg full;//写完标志
  output  overflow;//上溢出，写超过1024个继续写
  output  underflow;//下溢出，读超过1024个继续读
  reg   [clogb2(depth)-1:0]rd_addr;
  reg   [clogb2(depth)-1:0]wr_addr;
  wire   [1:0]flag;
  reg   [clogb2(depth)-1:0]fifo_cnt;

    dp_ram #(
            .DW(DW),
            .depth(depth)
        ) inst_dp_ram (
            .wclk   (clk),
            .rclk   (clk),
            .dina   (din),
            .addra  (wr_addr),
            .wr_ena (wr_en),
            .addrb  (rd_addr),
            .rd_enb (rd_en),
            .doutb  (dout)
        );


    assign flag={rd_en,wr_en};
    always@(posedge clk)begin
        if(!rstn)begin
            empty<=1;
            full<=0;
        
        end
        else begin
            if(fifo_cnt==0)begin
                empty<=1;
            
            end
            else if(fifo_cnt==depth-1)
                    full<=1;
            else begin
                empty<=0;
                full<=0;
            end
            
            
        end
    end
    always@(posedge clk)begin
         if(!rstn)
            wr_addr<=0;
         else if(wr_en)
         //begin
//            if(wr_addr<(addr-1))begin
                      wr_addr<=wr_addr+1;
//                      //fifo_cnt<=fifo_cnt+1;
//                    end
//            else if(wr_addr==addr-1)begin
//                       wr_addr<=0;
//            end
//            else 
//                wr_addr<=wr_addr;
//        end
        else 
             wr_addr<=wr_addr;
    end
 always@(posedge clk)begin
         if(!rstn)
            rd_addr<=0;
         else if(rd_en)
//         begin
//                if(rd_addr<(addr-1))begin
                      rd_addr<=rd_addr+1;
                      //fifo_cnt<=fifo_cnt+1;
//                    end
//                else if(rd_addr==addr-1)begin
//                       rd_addr<=0;
//                end
//                else 
//                    rd_addr<=rd_addr;
//        end
        else
            rd_addr<=rd_addr;
    end
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            //rd_addr<=0;
            //wr_addr<=0;
            fifo_cnt<=0;
        
        end
        else begin
            case(flag)
                2'b00:  begin
                        //rd_addr<=rd_addr;
                        //wr_addr<=wr_addr;
                        fifo_cnt<=fifo_cnt;
                
                    end
                
                2'b01:begin //此时，写有效
                    if(fifo_cnt!=depth-1)
                     fifo_cnt<=fifo_cnt+1;
                end
                
                
                2'b10:begin
                   if(fifo_cnt!=0)
                    fifo_cnt<=fifo_cnt-1;
                  end
                
                
                2'b11:
                    fifo_cnt<=fifo_cnt;
                
                default:fifo_cnt<=fifo_cnt;
            endcase
        end
    end
 assign  overflow=(wr_en&&full&&flag!=2'b11)? 1'b1 :1'b0;
 assign  underflow=(rd_en&&empty&&flag!==2'b11)? 1'b1 :1'b0;


function integer clogb2(integer number);
       begin
           for(clogb2=0;number >0;clogb2=clogb2+1)
                number=number>>1;
           end
       endfunction
endmodule
