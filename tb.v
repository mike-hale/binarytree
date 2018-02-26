`timescale 1ns / 1ps

module tb;

reg clk, RxD;
wire TxD;

initial begin
  clk = 0;
  RxD = 1;
end

print_screen UUT (.RxD(RxD), .TxD(TxD), .clk(clk));

always
  #1 clk <= ~clk;

endmodule
