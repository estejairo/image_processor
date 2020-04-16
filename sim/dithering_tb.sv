`timescale 1ns / 1ps

module dithering_tb();

    logic [23:0] pixel_in;
    logic [10:0] hc_visible;
    logic [10:0] vc_visible;
    logic [11:0] dithering;
    logic [11:0] i;
    logic [11:0] j;

    logic clk;

    initial begin
        clk = 1'b0;
        dithering[11:0] = 'd0;
        pixel_in[23:0] = 'd0;
        hc_visible[10:0] = 'd0;
        vc_visible[10:0] = 'd0;
        i[11:0] = 'd0;
        j[11:0] = 'd0;
    end

    always 
        #1 clk = ~ clk;

    always begin
        #1
        #20
        for (i=0; i<769; i=i+1) begin
            for (j=0; j<1025; j=j+1) begin
                
            #4      pixel_in[23:16] = i%256;
                    pixel_in[15:8] = j%256;
                    pixel_in[7:0] = (768-i)%256;
                    hc_visible[10:0] = j;
                    vc_visible[10:0] = i;
            end
        end

        #20
        #201;
    end
    dithering dithering_inst(
        .pixel_in(pixel_in[23:0]),
        .hc_visible(hc_visible[10:0]),
        .vc_visible(vc_visible[10:0]),
        .dithering(dithering[11:0])
    );

endmodule