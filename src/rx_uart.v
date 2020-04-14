`timescale 1ns / 1ps

/*////////////  Instance template //////////////////
 	rx_uart #(
		.CLK_FREQUENCY()	//Input Clock Frequency
		.BAUD_RATE()		//Serial Baud Rate
	) 
	instance_name(
		.clk(),				//Input clock
		.reset(),			//Input reset signal, active high
		.rx(),				//Input data signal
		.rx_data(),			//Output data byte
		.rx_ready()			//Output data ready signal
	);
*///////////////////////////////////////////////////

module rx_uart
#(
	parameter CLK_FREQUENCY = 100000000,
	parameter BAUD_RATE = 115200
)(
	input clk,
	input reset,
	input rx,
	output [7:0] rx_data,
	output reg rx_ready
);

	wire baud8_tick;

	reg rx_ready_sync;
	wire rx_ready_pre;

	uart_baud_tick_gen #(
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE),
		.OVERSAMPLING(8)
	) baud8_tick_blk (
		.clk(clk),
		.enable(1'b1),
		.tick(baud8_tick)
	);

	uart_rx uart_rx_blk (
		.clk(clk),
		.reset(reset),
		.baud8_tick(baud8_tick),
		.rx(rx),
		.rx_data(rx_data),
		.rx_ready(rx_ready_pre)
	);

	always @(posedge clk) begin
		rx_ready_sync <= rx_ready_pre;
		rx_ready <= ~rx_ready_sync & rx_ready_pre;
	end

endmodule