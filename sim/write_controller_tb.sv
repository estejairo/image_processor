`timescale 1ns / 1ps

module write_controller_tb();
    logic clk,rst,rx_data_ready,en,we;
    logic   [31:0] i;
    logic   [7:0] byte_received;
    logic   [17:0] addr;
    logic   [23:0] din;
    logic   [2:0] status;
    logic [2:0] status_next;
    logic [23:0] array;
    logic [1:0] byte_counter;

    initial begin
        status[2:0] = 3'd0;
        status_next[2:0] = 3'd0;
        i[31:0] = 32'd0;
        clk = 1'b0;
        rst = 1'b0;
        rx_data_ready = 1'd0;
        byte_received[7:0] = 8'd0;
        addr[17:0] = 10'd0;
        din[23:0] = 8'd0;
        array[23:0] = 24'd0;
        byte_counter[1:0] = 2'd0;
    end

    always 
        #1 clk = ~ clk;

    always begin
        #1
        #20
        for (i=0; i<(199692*3); i=i+1) begin
            #10     byte_received[7:0] = byte_received[7:0] + 1'd1;
                    rx_data_ready = 1'd1;
            #2      rx_data_ready = 1'd0;
        end

        #20
        #201;
    end

    write_controller write_inst(
        .clk(clk),
        .rst(rst),
        .byte_received(byte_received[7:0]),
        .rx_data_ready(rx_data_ready),
        .en(en),
        .we(we),
        .addr(addr[17:0]),
        .din(din[23:0]),
        .status(status[2:0]),
        .status_next(status_next[2:0]),
        .array(array[23:0]),
        .byte_counter(byte_counter[1:0])
    );
endmodule