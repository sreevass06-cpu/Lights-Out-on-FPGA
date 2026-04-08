`timescale 1ns / 1ps
module boxes_select(input clk,reset,input [2:0]level,output reg [63:0]boxes);
always@(posedge clk or posedge reset)begin
  if(reset)begin
    boxes<=0;
  end
  else begin
    case(level)
      3'h0:boxes<=64'b0100001011000011001111000010010000100100001111001100001101000010;
      3'h1:boxes<=64'h0;
      3'h2:boxes<=64'h0;
      3'h3:boxes<=64'h0;
      3'h4:boxes<=64'h0;
      3'h5:boxes<=64'h0;
      3'h6:boxes<=64'h0;
      3'h7:boxes<=64'h0;
    endcase
  end
  end
endmodule