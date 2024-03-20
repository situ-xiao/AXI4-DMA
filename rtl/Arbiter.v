module Arbiter
    (  
      input			clk_i,
      input			resetn_i,
      ///////////from/to Peripheral//////////
      output		P0_ACK_o,
      output		P1_ACK_o,
      output		P2_ACK_o,
      output		P3_ACK_o,
      ///////////from/to SYNC//////////
      input			SYNC_P0_REQ_i,
      input			SYNC_P1_REQ_i,
      input			SYNC_P2_REQ_i,
      input			SYNC_P3_REQ_i,
      ///////////from/to DMA engine//////////
      input			arbiter_src_ack_i,
      input			arbiter_dst_ack_i,
      output		arbiter_src_req_o,
      output		arbiter_dst_req_o,
      input	[31:0]	arbiter_transfer_data_i,
      input 		arbiter_src_work_i,
      input         arbiter_dst_work_i,
      input [31:0]  arbiter_peri_pri_i,
      input [31:0]  arbiter_mem_pri_i

    );
    /*
		default:P0>P1>P2>P3>M0>M1
		
    */
    
    /****************寄存器******************/
           
    
    /****************连线********************/
    wire [2:0]p0_pri;
    wire [2:0]p1_pri;
    wire [2:0]p2_pri;
    wire [2:0]p3_pri;
    wire [2:0]m0_pri;
    wire [2:0]m1_pri;
    //wire [2:0]count;
    wire [1:0]peri_max_bit;
    wire [1:0]final_max_bit;
    wire [2:0]peri_max;
    wire [2:0]final_max;
    wire [5:0]channel_enable;
    wire p0_gnt;
    wire p1_gnt;
    wire p2_gnt;
    wire p3_gnt;
    wire m0_gnt;
    wire m1_gnt;
    wire m2m;
    wire p2m;
    wire m2p;
    wire p2p;
    wire p0_active;

    /****************例化********************/
    max #(.DW(3)) inst_max0 (.A(p0_pri), .B(p1_pri), .C(p2_pri), .D(p3_pri), .max(peri_max), .pri_bit(peri_max_bit));
    max #(.DW(3)) inst_max1 (.A(peri_max), .B(m0_pri), .C(m1_pri), .D(0), .max(final_max), .pri_bit(final_max_bit));

    
    /****************组合逻辑****************/
    //assign count=SYNC_P0_REQ_i+SYNC_P1_REQ_i+SYNC_P2_REQ_i+SYNC_P3_REQ_i;
    assign m2m = (arbiter_transfer_data_i[13:12]==2'b11);
    assign p2m = (arbiter_transfer_data_i[13:12]==2'b00);
    assign m2p = (arbiter_transfer_data_i[13:12]==2'b01);
    assign p2p = (arbiter_transfer_data_i[13:12]==2'b10);
    assign p0_pri = arbiter_peri_pri_i[2:0] ;
    assign p1_pri = arbiter_peri_pri_i[6:4] ;
    assign p2_pri = arbiter_peri_pri_i[10:8] ;
    assign p3_pri = arbiter_peri_pri_i[14:12] ;       
    assign m0_pri = arbiter_mem_pri_i[2:0] ;
    assign m1_pri = arbiter_mem_pri_i[6:4] ;
    assign p0_gnt = (peri_max_bit==2'b00) & (final_max_bit==2'b00) ;  
    assign p1_gnt = (peri_max_bit==2'b01) & (final_max_bit==2'b00) ;
    assign p2_gnt = (peri_max_bit==2'b10) & (final_max_bit==2'b00) ;
    assign p3_gnt = (peri_max_bit==2'b11) & (final_max_bit==2'b00) ;
    assign m0_gnt = final_max_bit==2'b01;
    assign m1_gnt = final_max_bit==2'b10;
    assign p0_active=arbiter_transfer_data_i[16];
    assign p1_active=arbiter_transfer_data_i[17];
    assign p2_active=arbiter_transfer_data_i[18];
    assign p3_active=arbiter_transfer_data_i[19];
    assign m0_active=arbiter_transfer_data_i[20];
    assign m1_active=arbiter_transfer_data_i[21];
    assign arbiter_src_req_o = arbiter_src_work_i & ((p0_active & p0_gnt& SYNC_P0_REQ_i) |
    												 (p1_active & p1_gnt& SYNC_P1_REQ_i) |
    												 (p2_active & p2_gnt& SYNC_P2_REQ_i) |
    												 (p3_active & p3_gnt& SYNC_P3_REQ_i)& (p2m| p2p) ) |
    												 ((m0_active & m0_gnt & 1'b1) |
    												  (m1_active & m1_gnt & 1'b1) & (m2m)) ;
    assign arbiter_dst_req_o = arbiter_dst_work_i & ((p0_active & p0_gnt & SYNC_P0_REQ_i) |
    												 (p1_active & p1_gnt & SYNC_P1_REQ_i) |
    												 (p2_active & p2_gnt & SYNC_P2_REQ_i) |
    												 (p3_active & p3_gnt & SYNC_P3_REQ_i)& (m2p| p2p) ) |
    												 ((m0_active & m0_gnt & 1'b1) |
    												  (m1_active & m1_gnt & 1'b1) & (m2m)) ;
    assign P0_ACK_o = p0_gnt & p0_active & (arbiter_src_ack_i | arbiter_dst_ack_i);
    assign P1_ACK_o = p1_gnt & p1_active & (arbiter_src_ack_i | arbiter_dst_ack_i);
    assign P2_ACK_o = p2_gnt & p2_active & (arbiter_src_ack_i | arbiter_dst_ack_i);
    assign P3_ACK_o = p3_gnt & p3_active & (arbiter_src_ack_i | arbiter_dst_ack_i);
    assign M0_ACK_o = m0_gnt & m0_active & (arbiter_src_ack_i | arbiter_dst_ack_i);
    assign M1_ACK_o = m1_gnt & m1_active & (arbiter_src_ack_i | arbiter_dst_ack_i);


    /****************时序逻辑****************/
    
    
    /****************状态机******************/
    
    




endmodule