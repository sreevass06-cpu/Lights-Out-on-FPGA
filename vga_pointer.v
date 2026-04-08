`timescale 1ns / 1ps
module vga_pointer(input clk_25,reset,output reg[9:0]hcount,vcount,output reg hsync,vsync,video_on);
  reg [9:0]nxthcount,nxtvcount;
  reg nxthsync,nxtvsync,nxtvideo_on;
  always@(posedge clk_25,posedge reset)begin
    if(reset)begin
      hcount<=0;
      vcount<=0;
      hsync<=1;
      vsync<=1;
      video_on<=0;
    end
    else begin
      hcount<=nxthcount;                      
      vcount<=nxtvcount; 
      hsync<=nxthsync;
      vsync<=nxtvsync;
      video_on<=nxtvideo_on;
    end               
  end
  always@(*)begin
    nxthcount=hcount;
    nxtvcount=vcount;
    nxtvideo_on=video_on;
    if(hcount<799)
        nxthcount=hcount+1;
    else 
        nxthcount=0;
    if(vcount<524 && hcount==799)
        nxtvcount=vcount+1;
    else if(vcount==524 && hcount==799)
        nxtvcount=0;
    nxthsync=~(nxthcount>=656 && nxthcount<752);
    nxtvsync=~(nxtvcount>=490 && nxtvcount<492);
    nxtvideo_on=(nxthcount<640 && nxtvcount<480);
  end
endmodule