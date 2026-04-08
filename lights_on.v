`timescale 1ns / 1ps
module lights_on(input r,l,d,u,toggle,clk,reset,
                 output reg[2:0]count1,count2,
                 input [63:0]inboxes,
                 output reg [63:0]boxes,
                 output done);
  reg [2:0]nxtcount1,nxtcount2;
  parameter [1:0]S0=2'h0,S1=2'h1,S2=2'h2;
  reg [1:0]curr,nxt;
  reg [63:0]boxesnxt;
  integer i;
  reg zero;
  always@(posedge clk or posedge reset)begin
    if(reset)begin
      count1<=0;
      count2<=0;
      curr<=S0;
      boxes<=inboxes;
    end
    else begin
      count1<=nxtcount1;
      count2<=nxtcount2;
      curr<=nxt;
      boxes<=boxesnxt;
    end
  end
  always@(*)begin
    nxtcount1=count1;           
    nxtcount2=count2;           
    nxt=curr;
    zero=1;
    boxesnxt=boxes;
  case(curr)
    2'h1,
    2'h0:begin
    if(!toggle)begin
      if(r&!l)begin
        if(count1!=3'h7)
          nxtcount1=count1+1;
        else 
          nxtcount1=0;
      end
      else if(l&!r)begin
        if(count1!=0)
          nxtcount1=count1-1;
        else
          nxtcount1=3'h7;
      end
      if(d&!u)begin
        if(count2!=3'h7)
          nxtcount2=count2+1;
        else 
          nxtcount2=0;
      end
      else if(u&!d)begin
        if(count2!=0)
          nxtcount2=count2-1;
        else
          nxtcount2=3'h7; 
      end
    end
    else begin
      boxesnxt[count2*8+count1]=~boxes[count2*8+count1];
      if(count1!=0)
        boxesnxt[count2*8+count1-1]=~boxes[count2*8+count1-1];
      else
        boxesnxt[7+count2*8]=~boxes[7+count2*8];
      if(count1!=7)
        boxesnxt[count2*8+count1+1]=~boxes[count2*8+count1+1];
      else
        boxesnxt[8*count2]=~boxes[8*count2];
      if(count2!=0)
        boxesnxt[count1+(count2-1)*8]=~boxes[count1+(count2-1)*8];
      else
        boxesnxt[count1+8*7]=~boxes[count1+8*7];
      if(count2!=7)
        boxesnxt[count1+(count2+1)*8]=~boxes[count1+(count2+1)*8];
      else
        boxesnxt[count1]=~boxes[count1];
    end
      for(i=0;i<64;i=i+1)begin
        if(boxesnxt[i])
          zero=0;
      end
      if(zero)
        nxt=S2;
      else
        nxt=S1;
      end
      2'h2:nxt=S2;
      default:nxt=S0;
  endcase
  end
      assign done=(curr==S2);
endmodule