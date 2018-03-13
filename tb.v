`timescale 1ns / 1ps

module tb;

reg clk, btnu, btnl, btnr, btns, btnd, sw;
wire TxD, RxD, tfull, clk_50Hz, mplex_clk;
wire [7:0] seg;
wire [3:0] an;
wire [4:0] state;
wire [7:0] tfout;
wire [25:0] speed_ctrl;
wire [2:0] death;
wire [7:0] wave1_y, wave2_y, wave3_y, player_x, player_y;
wire [39:0] wave1_bf, wave2_bf, wave3_bf;
wire [15:0] high_score, current_score;

reg [31:0] timer;

initial begin
  clk = 0;
  btnu = 0;
  btnl = 0;
  btnr = 0;
  btns = 0;
  btnd = 0;
  sw = 0;
  timer = 0;
end

syria UUT (.RxD(RxD), .TxD(TxD), .clk(clk), .btnu(btnu), .btnl(btnl), .btnr(btnr), 
.btns(btns), .btnd(btnd), .sw(sw), .clk_50Hz(clk_50Hz), .seg(seg), .an(an), .speed_ctrl(speed_ctrl),
.death1(death[0]), .death2(death[1]), .death3(death[2]), .player_x(player_x), .player_y(player_y),
.wave1_y(wave1_y), .wave2_y(wave2_y), .wave3_y(wave3_y),
.wave1_bf(wave1_bf), .wave2_bf(wave2_bf), .wave3_bf(wave3_bf), .high_score(high_score), .current_score(current_score), .mplex_clk(mplex_clk));
//print_screen UUT (.RxD(RxD), .TxD(TxD), .clk(clk), .state(state), .tfifo_full(tfull), .tfifo_out(tfout));

model_uart model_uart0_ (// Outputs
                            .TX                  (RxD),
                            // Inputs
                            .RX                  (TxD)
                            /*AUTOINST*/);

defparam model_uart0_.name = "UART0";
defparam model_uart0_.baud = 5000000;

always begin
  #1 clk <= ~clk;
  if (death || (timer >= 5000000))
    timer <= timer + 1;
  if (timer == 5000000)
    btns <= 1;
  else if (timer == 6000000)
    btns <= 0;
end

endmodule
