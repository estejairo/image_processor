`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.09.2019 10:58:50
// Design Name: 
// Module Name: dithering
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// dithering nombre_(.pixel_in(24 bits),.dithering(24 bits));

module dithering(
    input logic [23:0]pixel_in,
    output logic [23:0]dithering
    );
    logic [7:0]r_channel;
    logic [7:0]g_channel;
    logic [7:0]b_channel;
    
    logic [7:0]r_dither;
    logic [7:0]g_dither;
    logic [7:0]b_dither;
    
    assign r_channel = pixel_in[23:16];
    assign g_channel = pixel_in[15:8];
    assign b_channel = pixel_in[7:0];
    
    always_comb begin
        if (r_channel[3])begin
            if(r_channel[7:4]=='hF)
                r_dither = r_channel[7:0];
            else 
                r_dither = {r_channel[7:4]+1'b1, 4'b0};
            end
        else r_dither = {r_channel[7:4], 4'b0};
        
        if (g_channel[3])begin
            if(g_channel[7:4]=='hF)
                g_dither = g_channel[7:0];
            else 
                g_dither = {g_channel[7:4]+1'b1, 4'b0};
            end
        else g_dither = {g_channel[7:4], 4'b0};
        
        if (b_channel[3])begin
            if(b_channel[7:4]=='hF)
                b_dither = b_channel[7:0];
            else 
                b_dither = {b_channel[7:4]+1'b1, 4'b0};
            end
        else b_dither = {b_channel[7:4], 4'b0};
    end
    
    assign dithering = {r_dither,g_dither,b_dither};
endmodule