`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2019 23:00:19
// Design Name: 
// Module Name: color_scramble
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

// color_scramble(.pixel_in(24 bits),.sw(6 últimos switches)),.scramble_out(24 bits));

module color_scramble(
    input logic [23:0]pixel_in,
    input logic [5:0]sw,
    output logic [23:0]scramble
    );
    logic [7:0]r_scramble;
    logic [7:0]g_scramble;
    logic [7:0]b_scramble;
    logic [1:0]s_r;
    logic [1:0]s_g;
    logic [1:0]s_b;
    
    assign s_r=sw[5:4];
    assign s_g=sw[3:2];
    assign s_b=sw[1:0];
    
    always_comb begin
        case (sw[5:4])
            2'b00: r_scramble=pixel_in[23:16];
            2'b01: r_scramble=pixel_in[15:8];
            2'b10: r_scramble=pixel_in[7:0];
            2'b11: r_scramble='b0;
        endcase
        
        case (sw[3:2])
            2'b00: g_scramble=pixel_in[23:16];
            2'b01: g_scramble=pixel_in[15:8];
            2'b10: g_scramble=pixel_in[7:0];
            2'b11: g_scramble='b0;
        endcase
        
        case (sw[1:0])
            2'b0:  b_scramble=pixel_in[23:16];
            2'b01: b_scramble=pixel_in[15:8];
            2'b10: b_scramble=pixel_in[7:0];
            2'b11: b_scramble='b0;
        endcase        
    end
    
    assign scramble[23:16]=r_scramble;
    assign scramble[15:8]=g_scramble;
    assign scramble[7:0]=b_scramble;
    
endmodule