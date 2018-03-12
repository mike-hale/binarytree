`timescale 1ns / 1ps

module tb;

reg clk, btnu, btnl, btnr, btns, btnd, sw;
wire TxD, RxD, tfull;
wire [4:0] state;
wire [7:0] tfout;

initial begin
  clk = 0;
  btnu = 0;
  btnl = 0;
  btnr = 0;
  btns = 0;
  btnd = 0;
  sw = 0;
end

syria UUT (.RxD(RxD), .TxD(TxD), .clk(clk), .btnu(btnu), .btnl(btnl), .btnr(btnr), .btns(btns), .btnd(btnd), .sw(sw));
//print_screen UUT (.RxD(RxD), .TxD(TxD), .clk(clk), .state(state), .tfifo_full(tfull), .tfifo_out(tfout));

model_uart model_uart0_ (// Outputs
                            .TX                  (RxD),
                            // Inputs
                            .RX                  (TxD)
                            /*AUTOINST*/);

defparam model_uart0_.name = "UART0";
defparam model_uart0_.baud = 5000000;

always
  #1 clk <= ~clk;

endmodule
