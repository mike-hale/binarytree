module print_screen(
RxD,
TxD,
clk,
packet);

input RxD, clk;
input wire [175:0] packet;
output TxD;

/*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 tfifo_empty;            // From tfifo_ of uart_fifo.v
   wire                 tfifo_full;             // From tfifo_ of uart_fifo.v
   wire [7:0]           tfifo_out;              // From tfifo_ of uart_fifo.v
   // End of automatics

   reg [7:0]            tfifo_in;
   wire                 tx_active;
   wire                 tfifo_rd;
   reg                  tfifo_rd_z;
   reg [7:0]            tx_data;
   reg [4:0]               state;
	wire [7:0] o_rx_data;
	
	initial begin
	  state <= 0;
	end

assign o_tx_busy = (state!=0);
assign tfifo_rd = ~tfifo_empty & ~tx_active & ~tfifo_rd_z;

   assign tfifo_wr = ~tfifo_full & (state!=0);
   
   uart_fifo tfifo_ (// Outputs
                     .fifo_cnt          (),
                     .fifo_out          (tfifo_out[7:0]),
                     .fifo_full         (tfifo_full),
                     .fifo_empty        (tfifo_empty),
                     // Inputs
                     .fifo_in           (tfifo_in[7:0]),
                     .fifo_rd           (tfifo_rd),
                     .fifo_wr           (tfifo_wr),
                     /*AUTOINST*/
                     // Inputs
                     .clk               (clk),
                     .rst               (1'b0));
						

   always @ (posedge clk) begin
     tfifo_rd_z <= tfifo_rd;
	  if (~tfifo_full)
	    if (state == 22)
		   state <= 0;
		 else
		   state <= state + 1;
	end
		 
   always @* begin
	  tfifo_in = packet >> (8*(state - 1));
	end

   uart uart_ (// Outputs
               .received                (o_rx_valid),
               .rx_byte                 (o_rx_data[7:0]),
               .is_receiving            (),
               .is_transmitting         (tx_active),
               .recv_error              (),
               .tx                      (TxD),
               // Inputs
               .rx                      (RxD),
               .transmit                (tfifo_rd_z),
               .tx_byte                 (tfifo_out[7:0]),
               /*AUTOINST*/
               // Inputs
               .clk                     (clk),
               .rst                     (rst));

endmodule
