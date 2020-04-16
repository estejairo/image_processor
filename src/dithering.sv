`timescale 1ns / 1ps

module dithering(
    input logic [23:0] pixel_in,
    input logic [10:0] hc_visible,
    input logic [10:0] vc_visible,
    output logic [11:0] dithering
    );
    logic [10:0] x = (hc_visible[10:0])%4;
    logic [10:0] y = (vc_visible[10:0])%4; 
    logic [3:0] r;
    logic [3:0] g;
    logic [3:0] b;
    logic [31:0] matrix_value;
    always_comb begin
        // case({x,y})
        //     {11'd0,11'd0}: matrix_value = -'d2;
        //     {11'd0,11'd1}: matrix_value = 'd0;
        //     {11'd0,11'd2}: matrix_value = -'d2;
        //     {11'd0,11'd3}: matrix_value = 'd0;
        //     {11'd1,11'd0}: matrix_value = 'd0;
        //     {11'd1,11'd1}: matrix_value = -'d1;
        //     {11'd1,11'd2}: matrix_value = 'd1;
        //     {11'd1,11'd3}: matrix_value = -'d1;
        //     {11'd2,11'd0}: matrix_value = -'d2;
        //     {11'd2,11'd1}: matrix_value = 'd0;
        //     {11'd2,11'd2}: matrix_value = -'d2;
        //     {11'd2,11'd3}: matrix_value = 'd0;
        //     {11'd3,11'd0}: matrix_value = 'd1;
        //     {11'd3,11'd1}: matrix_value = -'d1;
        //     {11'd3,11'd2}: matrix_value = 'd1;
        //     {11'd3,11'd3}: matrix_value = -'d1;
        //     default: matrix_value = 'd0;
        // endcase

        // r[3:0] = pixel_in[23:16]/'d17 + matrix_value;
        // g[3:0] = pixel_in[15:8]/'d17 + matrix_value;
        // b[3:0] = pixel_in[7:0]/'d17 + matrix_value;
        case({x,y})
            {11'd0,11'd0}: matrix_value = 'd0;
            {11'd0,11'd1}: matrix_value = 'd32;
            {11'd0,11'd2}: matrix_value = 'd8;
            {11'd0,11'd3}: matrix_value = 'd40;
            {11'd1,11'd0}: matrix_value = 'd48;
            {11'd1,11'd1}: matrix_value = 'd16;
            {11'd1,11'd2}: matrix_value = 'd56;
            {11'd1,11'd3}: matrix_value = 'd24;
            {11'd2,11'd0}: matrix_value = 'd12;
            {11'd2,11'd1}: matrix_value = 'd44;
            {11'd2,11'd2}: matrix_value = 'd4;
            {11'd2,11'd3}: matrix_value = 'd36;
            {11'd3,11'd0}: matrix_value = 'd60;
            {11'd3,11'd1}: matrix_value = 'd28;
            {11'd3,11'd2}: matrix_value = 'd52;
            {11'd3,11'd3}: matrix_value = 'd20;
            default: matrix_value = 'd0;
        endcase

        r[3:0] = (pixel_in[23:16]>'d195)?'d15:(pixel_in[23:16] + matrix_value)/17;
        g[3:0] = (pixel_in[15:8]>'d195)?'d15:(pixel_in[15:8] + matrix_value)/17;
        b[3:0] = (pixel_in[7:0]>'d195)?'d15:(pixel_in[7:0] + matrix_value)/17;
    end
    assign dithering[11:0] = {r[3:0],g[3:0],b[3:0]};

endmodule