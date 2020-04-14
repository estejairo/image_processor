`timescale 1ns / 1ps
module read_controller
#(
    parameter M_STATE = 1
)(
    input   logic clk,
    input   logic rst,
    input   logic [1:0] master_state,

    input   logic [7:0] doutb,
    output  logic enb,
    output  logic [9:0] addrb,

    input   logic tx_ongoing,
    output  logic tx_start,
    output  logic [7:0] byte_to_send,

    output  logic [9:0] status,
    output  logic [9:0] status_next,
    output  logic read_done
);

    //Not sure why, but registering those signals helps in FSM
    logic tx_ongoing_r       = 1'd0;
    logic [1:0] master_state_r    = 1'd0;
    always_ff @(posedge clk) begin
        if (rst) begin
            tx_ongoing_r     <= 1'd0;
            master_state_r[1:0]  <= 2'd0;
        end
        else begin
            tx_ongoing_r     <= tx_ongoing;
            master_state_r[1:0]  <= master_state[1:0];
        end
    end


    //FSM
    enum logic [9:0] {IDLE, WAIT_1, READ, WAIT_2, SEND, WAIT_3, WAIT_4, WAIT_5, END_1, END_2, END_3, END_4} state, state_next;
    logic   addrb_reset;
    assign  status[9:0] = state[9:0];
    assign  status_next[9:0] = state_next[9:0];

    logic [7:0] byte_to_send_next = 8'd0;
    logic tx_start_next = 1'b0;

    always_comb begin
        state_next[9:0] = IDLE;
        enb = 1'b0;
        addrb_reset = 1'd1;
        read_done = 1'b0;
        tx_start_next = 1'd0;
        byte_to_send_next[7:0] = 8'd0;
        case(state)
            IDLE:   begin
                        if (master_state_r[1:0]==M_STATE) begin
                            state_next[9:0] = WAIT_1;
                            addrb_reset = 1'd0;
                        end
                    end
            WAIT_1: begin
                        state_next[9:0] = WAIT_1;
                        addrb_reset = 1'd0;
                        if (!tx_ongoing_r) begin
                            state_next[9:0] = READ;
                            addrb_reset = 1'd0;
                        end

                    end
            READ:   begin
                        enb = 1'b1;
                        addrb_reset = 1'd0;
                        state_next[9:0] = WAIT_2;
                        if (addrb[9:0]==10'd1023) begin
                            state_next[9:0]= END_1;
                            addrb_reset = 1'd1;
                        end
                    end
            WAIT_2: begin
                        enb = 1'b1;
                        addrb_reset = 1'd0;
                        state_next[9:0] = SEND;
                    end
            SEND:   begin
                        addrb_reset = 1'd0;
                        tx_start_next = 1'b1;
                        state_next[9:0] = WAIT_3;
                        byte_to_send_next[7:0] = doutb[7:0];
                    end
            WAIT_3: begin
                        addrb_reset = 1'd0;
                        state_next[9:0] = WAIT_4;
                    end
            WAIT_4: begin
                        addrb_reset = 1'd0;
                        state_next[9:0] = WAIT_5;
                    end
            WAIT_5: begin
                        addrb_reset = 1'd0;
                        state_next[9:0] = WAIT_1;
                    end
            END_1:   begin
                        enb = 1'b1;
                        state_next[9:0] = END_2;
                    end
            END_2:  begin
                        tx_start_next = 1'b1;
                        byte_to_send_next[7:0] = doutb[7:0];
                        state_next[9:0] = END_3;
                    end
            END_3:  begin
                        read_done = 1'b1;
                        state_next[9:0] = END_4;
                    end
            END_4:  begin
                        state_next[9:0] = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_start <= 1'd0;
            byte_to_send[7:0] <= 8'd0;
        end
        else begin
            tx_start <= tx_start_next;
            byte_to_send[7:0] <= byte_to_send_next[7:0];
        end
    end

    always_ff @(posedge clk) begin
        if (rst||addrb_reset) begin
            addrb[9:0] <= 10'd0;
        end
        else 
            if (state[9:0]==READ) begin
                addrb[9:0] <= addrb[9:0]+1'd1;
            end
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state[9:0] <= IDLE;
        end
        else begin
            state[9:0] <= state_next[9:0];
        end
    end
endmodule