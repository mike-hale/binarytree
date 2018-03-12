module syria (RxD,  //Incoming serial data
              TxD,  //Outgoing serial data
		      clk,  //100 MHz clock signal
              btns, //center button
              btnu, //upper button
              btnl, //left button
              btnd, //bottom button
              btnr, //right button
              sw,
				  led); //switch
				  
input RxD, clk, btns, btnu, btnl, btnd, btnr, sw;
output TxD;
output [4:0] led;

/* Parameters */
parameter deb_div = 25000000;
parameter board_height = 20;
parameter board_width = 40;

/* Gameboard variables */
reg [7:0]  player_x;
reg [7:0]  player_y;
reg [7:0]  wave_y[2:0];
reg [39:0] wave_bitfield[2:0];

/* Game variables */
reg [15:0] high_score;
reg [15:0] current_score;
reg [25:0] speed_ctrl;
reg [25:0] speed_cnt;
reg speed_clk, death1, death2, death3;
wire death;
wire [175:0] packet;

/* Button variables */
wire top, bottom, left, right, center;
reg deb_clk, score_sw;
reg [31:0] deb_cnt;

/* Initial */
initial begin
  /* clk vars */
  deb_clk <= 0;
  deb_cnt <= 0;
  speed_ctrl <= 50000;
  speed_cnt <= 0;
  speed_clk <= 0;
  /* positions */
  player_x <= 10;
  player_y <= 1;
  wave_y[0] <= board_height - 2;
  wave_y[1] <= board_height - 2;
  wave_y[2] <= board_height - 2;
  wave_bitfield[0] <= 40'hffffffffff;
  wave_bitfield[1] <= 40'hffffffffff;
  wave_bitfield[2] <= 40'hffffffffff;
  score_sw <= 0;
  death1 <= 0;
  death2 <= 0;
  death3 <= 0;
end

assemble_pack pack_assembler (.clk(clk),
                              .player_x(player_x),
                              .player_y(player_y),
                              .wave1_y(wave_y[0]),
                              .wave2_y(wave_y[1]),
                              .wave3_y(wave_y[2]),
                              .wave1_bitfield(wave_bitfield[0]),
                              .wave2_bitfield(wave_bitfield[1]),
                              .wave3_bitfield(wave_bitfield[2]),
                              .packet(packet));

print_screen screen_printer (.RxD(RxD),
                             .TxD(TxD),
                             .clk(clk),
                             .packet(packet));

/* Debouncing clk / Wave clk */
always @(posedge clk) begin
  if (deb_cnt == deb_div) begin
    deb_cnt <= 0;
    deb_clk <= ~deb_clk;
  end else
    deb_cnt <= deb_cnt + 1;

  if (speed_cnt == speed_ctrl) begin
    speed_cnt <= 0;
    speed_clk <= ~speed_clk;
  end else
    speed_cnt <= speed_cnt + 1;
end

assign led[0] = deb_clk;
assign led[1] = btnu;
assign led[2] = btnd;
assign led[3] = btnl;
assign led[4] = btnr;

/* Switch sampling */
always @(posedge deb_clk)
  score_sw <= sw;

redb top_db    (.in_sig(btnu), .out_sig(top),    .deb_clk(deb_clk));
redb bottom_db (.in_sig(btnd), .out_sig(bottom), .deb_clk(deb_clk));
redb left_db   (.in_sig(btnl), .out_sig(left),   .deb_clk(deb_clk));
redb right_db  (.in_sig(btnr), .out_sig(right),  .deb_clk(deb_clk));
redb center_db (.in_sig(btns), .out_sig(center), .deb_clk(deb_clk));

assign death = death1 | death2 | death3;

always @(top or bottom) begin
  if (top == 1 /*&& player_y > 1*/) begin
    death1 <= is_dead(player_x, player_y + 1, wave_y[0], wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    player_y <= player_y + 1;
  end else if (bottom == 1 /*&& player_y < board_height - 2*/) begin
    death1 <= is_dead(player_x, player_y - 1, wave_y[0], wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    player_y <= player_y - 1;
  end
end 

always @(posedge left, posedge right) begin
  if (left == 1 /*&& player_x > 0*/) begin
    death2 <= is_dead(player_x - 1, player_y, wave_y[0], wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    player_x <= player_x - 1;
  end else if (right == 1 /*&& player_x < board_width - 1*/) begin
    death2 <= is_dead(player_x + 1, player_y, wave_y[0], wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    player_x <= player_x + 1;
  end
end

always @(posedge speed_clk) begin
  if (wave_y[0] == 1) begin
    death3 <= is_dead(player_x, player_y, board_height - 2, wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    wave_y[0] <= board_height - 2;
  end else begin
    death3 <= is_dead(player_x, player_y, wave_y[0] - 1, wave_y[1], wave_y[2],
                     wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
    wave_y[0] <= wave_y[0] - 1;
  end
end

/* Function to determine if space is occupied by drones */
function is_dead;
input player_x, player_y, wave1_y, wave2_y, wave3_y;
input [39:0] wave1_bfield, wave2_bfield, wave3_bfield;
begin
  if ((player_y == wave1_y && wave1_bfield[player_x] == 1) ||
      (player_y == wave2_y && wave2_bfield[player_x] == 1) ||
      (player_y == wave3_y && wave3_bfield[player_x] == 1))
    is_dead = 1;
  else
    is_dead = 0;
end
endfunction

endmodule