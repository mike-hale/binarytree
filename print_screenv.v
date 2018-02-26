module print_screen(
RxD,
TxD,
clk
    );

input RxD, clk;
output TxD;

reg reset, trans;
reg [7:0] tx_byte;
reg [4:0] index;
wire recvd, is_recv, is_trans, recv_err;
wire [7:0] rx_byte;

uart this_uart(.clk(clk),
               .rst(reset),
					.rx(RxD),
					.tx(TxD),
					.transmit(trans),
					.tx_byte(tx_byte),
					.received(recvd),
					.is_receiving(is_recv),
					.is_transmitting(is_trans),
					.recv_error(recv_err));



initial begin
  reset = 0;
  index = 0;
  tx_byte[0] = string[index];
  tx_byte[1] = string[index + 1];
  tx_byte[2] = string[index + 2];
  tx_byte[3] = string[index + 3];
  tx_byte[4] = string[index + 4];
  tx_byte[5] = string[index + 5];
  tx_byte[6] = string[index + 6];
  tx_byte[7] = string[index + 7];
  trans = 1;
end

parameter [79:0] string = "ESKEDDDDIITTTTT\n\n\n\n\n";

always @(negedge is_trans) begin
  if (index == 20)
    index <= 0;
  else
    index <= index + 1;
  tx_byte[0] <= string[index];
  tx_byte[1] <= string[index + 1];
  tx_byte[2] <= string[index + 2];
  tx_byte[3] <= string[index + 3];
  tx_byte[4] <= string[index + 4];
  tx_byte[5] <= string[index + 5];
  tx_byte[6] <= string[index + 6];
  tx_byte[7] <= string[index + 7];
end

endmodule
