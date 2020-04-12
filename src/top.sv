`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.08.2019 15:15:02
// Design Name: 
// Module Name: top_module
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


module top_module(
//  input logic UART_TXD_IN,                    //datos seriales de python
    input logic CLK100MHZ, CPU_RESETN,
    input logic [11:0] SW,
    output logic [3:0] VGA_R,VGA_G,VGA_B,         //salidas al display
    output logic VGA_HS,VGA_VS
    
    );

    logic rst_press;

    logic CLK65MHZ;
    clk_wiz_0 clk_vga(
        .clk_out1(CLK65MHZ),     // output clk_out1
        .reset(rst_press), // input reset
        .clk_in1(CLK100MHZ)// input clk_in1
    );      
 

    PB_Debouncer #(.DELAY(3_940_000))   //Delay in terms of clock cycles
    instance_name(
        .clk(CLK65MHZ),                     //Input clock
        .rst(1'b0),                     //Input reset signal, active high
        .PB(~CPU_RESETN),                      //Input pushbutton to be debounced
        .PB_pressed_status(),       //Output pushbutton status (while pressed)
        .PB_pressed_pulse(rst_press),        //Output pushbutton pressed pulse (when just pressed)
        .PB_released_pulse()        //Output pushbutton status (when just released)
    );

    // logic clk;
    logic [10:0] hc_visible,vc_visible;
    // logic [17:0]address;
    // logic [23:0]data;
    // logic load_bram;
    // logic [17:0]linea;
    // logic [7:0]serial_data;
    // logic serial_ready;
    // logic [23:0]bram_out;                      //salida desde BRAM
    // logic [11:0] VGA_COLOR;
    // logic rst;
    // logic rst_db;
    // assign rst=~CPU_RESETN;
    // logic [23:0]vga_aux;
    
    //----------------------------------------------------------------------------------------------------------
    
    // debouncer DB(.clk(CLK100MHZ),.rst(0),.PB(rst),.PB_pressed_pulse(rst_db));
    
    // blk_mem_gen_0 memory(
    // .clka(CLK100MHZ),
    // .clkb(clk),
    // .dina(data),
    // .ena(1),
    // .wea(load_bram),
    // .addra(linea),
    // .doutb(bram_out),
    // .addrb(address),
    // .enb(1));
    
    // clk_wiz_0 clk_display(.clk_in1(CLK100MHZ),.clk_out1(clk),.reset(0));
    
    // uart_basic uart_basic(.clk(CLK100MHZ),
    //       //              .reset(rst_db),
    //                     .rx(UART_TXD_IN),.rx_data(serial_data),
    //                     .rx_ready(serial_ready));
    // uart_reciver uart(.clk(CLK100MHZ),
    //     //              .rst(rst_db),
    //                   .rx_ready(serial_ready),
    //                   .rx_data(serial_data),.dato(data),
    //                   .load(load_bram),.line(linea));
    
    driver_vga_1024x768 driver(
                .clk_vga(CLK65MHZ),.hs(VGA_HS),.vs(VGA_VS),.hc_visible(hc_visible),
                .vc_visible(vc_visible)); 
//     coor_to_address coor_to_address1(.a(hc_visible), .b(vc_visible), .out(address));
    
//     //---------------------------------------------------------------------------------------------------------
    
//     logic [23:0]dith_out;
//     logic [23:0]gray_out;
//     logic [23:0]scramble_out;           //salidas de los filtros a MUXs
//     logic [23:0]sobel_out;
    
//     logic [23:0]mux_0;
//     logic [23:0]mux_1;
//     logic [23:0]mux_2;
//     logic [23:0]mux_3;
    
//     /*********************************ARREGLO DE LOS FILTROS EN LOS MUX************************************/
    
//     always_comb begin
    
//         case (SW[0])
//             0:  mux_0=bram_out;
//             1:  mux_0=dith_out;
//             default:    mux_0=bram_out;
//         endcase
    
//         case (SW[1])
//             0:  mux_1=mux_0;
//             1:  mux_1=gray_out;
//             default:    mux_1=mux_0;
//         endcase
    
//         case (SW[2])
//             0:  mux_2=mux_1;
//             1:  mux_2=scramble_out;
//             default:    mux_2=mux_1;
//         endcase
    
//         case (SW[3])
//             0:  mux_3=mux_2;
//             1:  mux_3=sobel_out;            //MUX 3 ES LA SALIDA QUE DEBE PASAR A CL -> VGA_COLOR
//             default:    mux_3=mux_2;
//         endcase    
//         end
        
//     /************************************AQUÍ VAN LOS FILTROS************************************/
    
//     dithering ditherino(.pixel_in(bram_out),.dithering(dith_out));
//     grayscale bnw(.pixel_in(mux_0),.gray(gray_out));
//     color_scramble scramble(.pixel_in(mux_1),.sw(SW[15:10]),.scramble(scramble_out));
//    sobel_full (.pixel_in(mux_2),.clock(clk), .reset(0),.pixel_out(sobel_out), .hc_visible(hc_visible), .vc_visible(vc_visible));
//     /********************************************************************************************/
    logic [11:0] VGA_COLOR;
    always_comb begin                                   //pasa los bits a VGA_COLOR     (CL en diagrama)
        if ((hc_visible!='d0)&&(vc_visible!='d0))
             VGA_COLOR[11:0] = SW[11:0];
        else
             VGA_COLOR[11:0] = 12'h000; //pink
    end
    
    always_ff @(posedge CLK65MHZ)
        if (rst_press)
            {VGA_R,VGA_G,VGA_B} <= 12'd0;
        else
            {VGA_R,VGA_G,VGA_B} <= VGA_COLOR[11:0];
        


    // assign {VGA_R,VGA_G,VGA_B} = VGA_COLOR;
    
endmodule