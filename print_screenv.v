module print_screen(
RxD,
TxD,
clk
    );

input RxD, clk;
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
   reg [seq_dp_width-1:0]  tx_data;
   reg [3:0]               state;

assign o_tx_busy = (state!=stIdle);
assign tfifo_rd = ~tfifo_empty & ~tx_active & ~tfifo_rd_z;

   assign tfifo_wr = ~tfifo_full & (state!=stIdle);
   
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
                     .rst               (rst));

   always @ (posedge clk)
     if (rst)
       tfifo_rd_z <= 1'b0;
     else
       tfifo_rd_z <= tfifo_rd;

   uart uart_ (// Outputs
               .received                (o_rx_valid),
               .rx_byte                 (o_rx_data[7:0]),
               .is_receiving            (),
               .is_transmitting         (tx_active),
               .recv_error              (),
               .tx                      (o_tx),
               // Inputs
               .rx                      (i_rx),
               .transmit                (tfifo_rd_z),
               .tx_byte                 (tfifo_out[7:0]),
               /*AUTOINST*/
               // Inputs
               .clk                     (clk),
               .rst                     (rst));

endmodule
