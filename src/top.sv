`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Universidad Tecnica Federico Santa Maria
// Author: Jairo Gonzalez
// 
// Create Date: 12.04.2020 12:00:00
// Design Name: top
// Module Name: top
// Project Name: image_processor
// Target Devices: Nexys 4 DDR - Artix 7 FPGA
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input logic UART_TXD_IN,                    //UART data input
    input logic CLK100MHZ,                      //System clock
    input logic CPU_RESETN,                     //Hardware reset   
    input logic [15:0] SW,                      //Switches
    output logic [3:0] VGA_R,VGA_G,VGA_B,       //VGA Colors
    output logic VGA_HS,VGA_VS                  //VGA sync signals
    
);

    logic rst_press;                        //debounced reset signal
    
    /// Clock Wizard IP
    logic CLK100M;
    logic CLK65M;
    clk_wiz_0 clk_vga(
        .clk_out1(CLK65M),  // output clk_out1
        .clk_out2(CLK100M), // output clk_out2
        .reset(rst_press),  // input reset
        .clk_in1(CLK100MHZ) // input clk_in1
    );    
    
    /// Reset pushbutton debouncer
    PB_Debouncer #(.DELAY(5_000_000))       //Delay in terms of clock cycles
    rst_debouncer_uart_bram(
        .clk(CLK100M),                    //Input clock
        .rst(1'b0),                         //Input reset signal, active high
        .PB(~CPU_RESETN),                   //Input pushbutton to be debounced
        .PB_pressed_status(),               //Output pushbutton status (while pressed)
        .PB_pressed_pulse(rst_press),       //Output pushbutton pressed pulse (when just pressed)
        .PB_released_pulse()                //Output pushbutton status (when just released)
    );

    PB_Debouncer #(.DELAY(3_250_000))       //Delay in terms of clock cycles
    rst_debouncer_vga(
        .clk(CLK65M),                    //Input clock
        .rst(1'b0),                         //Input reset signal, active high
        .PB(~CPU_RESETN),                   //Input pushbutton to be debounced
        .PB_pressed_status(),               //Output pushbutton status (while pressed)
        .PB_pressed_pulse(rst_vga_press),       //Output pushbutton pressed pulse (when just pressed)
        .PB_released_pulse()                //Output pushbutton status (when just released)
    );

    //UART logic
    logic [7:0] byte_received;
    logic rx_data_ready;
    rx_uart #(
		.CLK_FREQUENCY(100_208_000),   //Input Clock Frequency
		.BAUD_RATE(115200)		        //Serial Baud Rate
	) 
	instance_name(
		.clk(CLK100M),				    //Input clock
		.reset(rst_press),			    //Input reset signal, active high
		.rx(UART_TXD_IN),				//Input data signal
		.rx_data(byte_received[7:0]),	//Output data byte
		.rx_ready(rx_data_ready)	    //Output data ready signal
	);

    //Blok RAM logic
    logic ena;
    logic wea;
    logic [17:0] addra;
    logic [23:0] dina;
    logic enb;
    logic [17:0] addrb;
    logic [23:0] doutb;
    blk_mem_gen_0 BRAM(
        .clka(CLK100M),         // input wire clka
        .ena(ena),              // input wire ena
        .wea(wea),              // input wire [0 : 0] wea
        .addra(addra[17:0]),    // input wire [17 : 0] addra
        .dina(dina[23:0]),      // input wire [23 : 0] dina
        .clkb(CLK65M),          // input wire clkb
        .enb(enb),              // input wire enb
        .addrb(addrb[17:0]),    // input wire [17 : 0] addrb
        .doutb(doutb[23:0])     // output wire [23 : 0] doutb
    );

    write_controller write_bram(
        .clk(CLK100M),
        .rst(rst_press),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .en(ena),
        .we(wea),
        .addr(addra[17:0]),
        .din(dina[23:0]),
        .status(),
        .status_next(),
        .array(),
        .byte_counter()
    );

    /// VGA logic
    logic [10:0] hc_visible_1,vc_visible_1;
    logic VGA_HS_1;
    logic VGA_VS_1;
    driver_vga_1024x768 driver(
                .clk_vga(CLK65M),.hs(VGA_HS_1),.vs(VGA_VS_1),.hc_visible(hc_visible_1),
                .vc_visible(vc_visible_1)); 


    //BRAM Read logic
    always_comb begin
        if ((vc_visible_1 == 'd0)|| (hc_visible_1 == 'd0))
            enb = 0;
        else
            enb = 1;
            addrb[17:0] = (((hc_visible_1-1)/2) + 'd512*((vc_visible_1-1)/2));
    end

    //Synchronization between colors and sync signals
    logic VGA_HS_4,VGA_HS_3,VGA_HS_2 = 'd0;
    logic VGA_VS_4,VGA_VS_3,VGA_VS_2 = 'd0;
    logic [10:0] hc_visible_4, hc_visible_3,hc_visible_2 = 'd0;
    logic [10:0] vc_visible_4, vc_visible_3,vc_visible_2 = 'd0;
    logic [23:0] color4 = 'd0;
    
    always_ff @(posedge CLK65M) begin
        if (rst_vga_press) begin 
            {hc_visible_4,hc_visible_3,hc_visible_2}<= 'd0;
            {vc_visible_4,vc_visible_3,vc_visible_2}<= 'd0;
            {VGA_HS_4,VGA_HS_3,VGA_HS_2}            <= 'd0;
            {VGA_VS_4,VGA_VS_3,VGA_VS_2}            <= 'd0;
            color4[23:0]                            <= 'd0;
        end
        else begin
            {hc_visible_4,hc_visible_3,hc_visible_2}<= {hc_visible_3,hc_visible_2,hc_visible_1};
            {vc_visible_4,vc_visible_3,vc_visible_2}<= {vc_visible_3,vc_visible_2,vc_visible_1};
            {VGA_HS_4,VGA_HS_3,VGA_HS_2}            <= {VGA_HS_3,VGA_HS_2,VGA_HS_1};
            {VGA_VS_4,VGA_VS_3,VGA_VS_2}            <= {VGA_VS_3,VGA_VS_2,VGA_VS_1};
            color4[23:0]                            <= doutb[23:0];
        end
    end

    // Gray Scale
    logic [7:0] gray;
    logic [23:0] gray_scale;
    always_comb begin
        gray[7:0] = (color4[23:16]+color4[15:8]+color4[7:0])/'d3;
        if (SW[1])
            gray_scale[23:0] = {gray[7:0],gray[7:0] ,gray[7:0]};
        else
            gray_scale[23:0] = color4[23:0];
    end
    
    logic VGA_HS_5 = 'd0;
    logic VGA_VS_5 = 'd0;
    logic [10:0] hc_visible_5 = 'd0;
    logic [10:0] vc_visible_5 = 'd0;
    logic [23:0] color5 = 'd0;

    always_ff @(posedge CLK65M) begin
        if (rst_vga_press) begin 
            hc_visible_5 <= 'd0;
            vc_visible_5 <= 'd0;
            VGA_HS_5     <= 'd0;
            VGA_VS_5     <= 'd0;
            color5[23:0] <= 'd0;
        end
        else begin
            hc_visible_5 <= hc_visible_4;
            vc_visible_5 <= vc_visible_4;
            VGA_HS_5     <= VGA_HS_4;
            VGA_VS_5     <= VGA_VS_4;
            color5[23:0] <= gray_scale[23:0];
        end
    end

    //Color Scrambler
    logic [23:0] scramble;
    color_scramble scramble_inst(
        .pixel_in(color5[23:0]),
        .sw(SW[15:10]),
        .scramble(scramble[23:0])
    );

    logic VGA_HS_6 = 'd0;
    logic VGA_VS_6 = 'd0;
    logic [10:0] hc_visible_6 = 'd0;
    logic [10:0] vc_visible_6 = 'd0;
    logic [23:0] color6 = 'd0;

    always_ff @(posedge CLK65M) begin
        if (rst_vga_press) begin 
            hc_visible_6 <= 'd0;
            vc_visible_6 <= 'd0;
            VGA_HS_6     <= 'd0;
            VGA_VS_6     <= 'd0;
            color6[23:0] <= 'd0;
        end
        else begin
            hc_visible_6 <= hc_visible_5;
            vc_visible_6 <= vc_visible_5;
            VGA_HS_6     <= VGA_HS_5;
            VGA_VS_6     <= VGA_VS_5;
            color6[23:0] <= scramble[23:0];
        end
    end
    
    //Screen drawing
    logic [11:0] VGA_COLOR = 12'd0;
    always_comb begin
        if ((vc_visible_6 == 'd0)|| (hc_visible_6 == 'd0))
            VGA_COLOR[11:0] = 12'h000;
        else
            VGA_COLOR[11:0] = {color6[23:20],color6[15:12],color6[7:4]};
            
    end

    always_ff @(posedge CLK65M) begin
        if (rst_vga_press) begin
            {VGA_R[3:0],VGA_G[3:0],VGA_B[3:0]} <= 'd0;
            VGA_HS <= 'd0;
            VGA_VS <= 'd0;
        end
        else begin
            {VGA_R[3:0],VGA_G[3:0],VGA_B[3:0]} <= VGA_COLOR[11:0];
            VGA_HS <= VGA_HS_6;
            VGA_VS <= VGA_VS_6;
        end
    end
    
endmodule