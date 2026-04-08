`timescale 1ns / 1ps

module top(
    input clk,                           // Pin W5 (100MHz)
    input btnU, btnD, btnL, btnR, btnC,  // Buttons
    input [3:0] sw,                      // sw[0] for Reset
    output [6:0] led,                    // Matches led[0:6] in XDC
    output hsync, vsync,                 // Lowercase to match XDC
    output [3:0] vgaRed, vgaGreen, vgaBlue // 12-bit VGA output
);

    // Internal Wires
    wire clk_25;            
    wire video_on;
    wire [9:0] hcount, vcount;
    wire [2:0] rgb_3bit;
    wire [63:0] boxes;
    wire [2:0] c1, c2,level;
    wire done;
    wire db_U, db_D, db_L, db_R, db_C;

    // 1. Clock Wizard Instance (Must be named vga_clk_gen in IP Catalog)
    vga_clk_gen clk_wiz (
        .clk_in1(clk),      
        .clk_out1(clk_25)   
    );
    
    de_bounce db_u_inst (.clk_25(clk), .btn_in(btnU), .pulse(db_U));
    de_bounce db_d_inst (.clk_25(clk), .btn_in(btnD), .pulse(db_D));
    de_bounce db_l_inst (.clk_25(clk), .btn_in(btnL), .pulse(db_L));
    de_bounce db_r_inst (.clk_25(clk), .btn_in(btnR), .pulse(db_R));
    de_bounce db_c_inst (.clk_25(clk), .btn_in(btnC), .pulse(db_C));

    // 2. Game Logic Instance (Direct Connection)
    lights_on game_inst (
        .clk(clk),
        .reset(sw[0]),.inboxes(boxes)
        .u(db_U), .d(db_D), .l(db_L), .r(db_R), .toggle(db_C),
        .count1(c1), .count2(c2),
        .boxes(boxes),
        .done(done)
    );
  boxes_select (
    .clk(clk),
    .reset(sw[0]),
    .level({sw[3],sw[2],sw[1]});
    .boxes(boxes)
  );
  

    // 3. VGA Sync Generator
    vga_pointer vga_sync (
        .clk_25(clk),
        .reset(sw[0]),
        .hcount(hcount),
        .vcount(vcount),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on)
    );

    // 4. Pixel Generator
    pixel_generator pixel_gen (
        .video_on(video_on),
        .hcount(hcount),
        .vcount(vcount),
        .boxes(boxes),
        .rgb(rgb_3bit),
        .count1(c1),
        .count2(c2)
    );

    // 5. VGA Pin Mapping
    assign vgaRed   = {4{rgb_3bit[2]}};
    assign vgaGreen = {4{rgb_3bit[1]}};
    assign vgaBlue  = {4{rgb_3bit[0]}};

    // 6. LED Debugging
    assign led[2:0] = c1;
    assign led[5:3] = c2;
    assign led[6]   = done;

endmodule