module syria (RxD,  //Incoming serial data
              TxD,  //Outgoing serial data
		      clk,  //100 MHz clock signal
              btns, //center button
              btnu, //upper button
              btnl, //left button
              btnd, //bottom button
              btnr, //right button
              sw,
              an,
              seg,
              led); //switch
				  
input RxD, clk, btns, btnu, btnl, btnd, btnr;
input [1:0] sw;
output TxD;
output [4:0] led;
output [7:0] seg;
output [3:0] an;

/* Parameters */
parameter deb_div = 25000000; //Implementation 25000000 Testing: 25000
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
wire [25:0] speed_ctrl;
reg [25:0] speed_cnt;
wire [3:0] difficulty;
reg speed_clk;
reg death1, death2;
wire death;
wire death3;
wire [175:0] packet;
reg clk_50Hz;
reg [19:0] cnt_50Hz;
reg [3:0] wave2_cntdown, wave3_cntdown;
assign difficulty = current_score >> 4;
assign speed_ctrl = 50000 - (difficulty << 10);

/* Button variables */
wire top, bottom, left, right, center;
reg pause, score_toggle;
reg deb_clk, score_sw;
reg [31:0] deb_cnt;

/* Random bus */
wire [7:0] random;
wire [5:0] random_x;
assign random_x = (random % (board_width - 8)) + 4;

/* Initial */
initial begin
  /* clk vars */
  deb_clk <= 0;
  deb_cnt <= 0;
  speed_cnt <= 0;
  speed_clk <= 0;
  current_score <= 0;
  high_score <= 0;
  /* positions */
  player_x <= 10;
  player_y <= 1;
  wave_y[0] <= board_height - 2;
  wave_y[1] <= board_height - 2;
  wave_y[2] <= board_height - 2;
  wave_bitfield[0] <= 40'hfffffff007;
  wave_bitfield[1] <= 40'hf007ffffff;
  wave_bitfield[2] <= 40'hfffe00ffff;
  score_sw <= 0;
  death1 <= 0;
  death2 <= 0;
  //death3 <= 0;
  clk_50Hz <= 0;
  cnt_50Hz <= 0;
  wave2_cntdown <= 6;
  wave3_cntdown <= 12;
end

assemble_pack pack_assembler (.clk(clk_50Hz),
                              .player_x(player_x),
                              .player_y(player_y),
                              .wave1_y(wave_y[0]),
                              .wave2_y(wave_y[1]),
                              .wave3_y(wave_y[2]),
                              .wave1_bitfield(wave_bitfield[0]),
                              .wave2_bitfield(wave_bitfield[1]),
                              .wave3_bitfield(wave_bitfield[2]),
                              .death(death),
                              .current_score(current_score),
                              .high_score(high_score),
                              .packet(packet));

print_screen screen_printer (.RxD(RxD),
                             .TxD(TxD),
                             .clk(clk),
                             .print_e(clk_50Hz),
                             .packet(packet));

display_ctrl four_dig_display (.clk(clk), 
                               .death(death),
                               .score_sw(score_toggle),
                               .high_score(high_score),
                               .curr_score(current_score),
                               .an(an),
                               .seg(seg));

pr_gen rand_num_gen (.clk(clk),
                     .random(random));

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

  if (cnt_50Hz == 100000) begin //1000000 for implementation 
    cnt_50Hz <= 0;
    clk_50Hz <= ~clk_50Hz;
  end else
    cnt_50Hz <= cnt_50Hz + 1;
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
always @(posedge deb_clk) begin
  pause <= sw[1];
  score_toggle <= sw[0];
end

assign death = death1 | death2 | death3;

always @(top, bottom, center) begin
  if (pause == 1);
  else if (death == 0) begin
    if (top == 1 && player_y > 1) begin
      death1 <= is_dead(player_x, player_y - 1, wave_y[0], wave_y[1], wave_y[2],
                       wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
      player_y <= player_y - 1;
    end else if (bottom == 1 && player_y < board_height - 2) begin
      death1 <= is_dead(player_x, player_y + 1, wave_y[0], wave_y[1], wave_y[2],
                       wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
      player_y <= player_y + 1;
    end
  end else if (center == 1)
    player_y <= 1;
end 

always @(left, right, center) begin
  if (pause == 1);
  else if (death == 0 && pause == 0) begin
    if (left == 1 && player_x > 0) begin
      death2 <= is_dead(player_x - 1, player_y, wave_y[0], wave_y[1], wave_y[2],
                       wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
      player_x <= player_x - 1;
    end else if (right == 1 && player_x < board_width - 1) begin
      death2 <= is_dead(player_x + 1, player_y, wave_y[0], wave_y[1], wave_y[2],
                       wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);
      player_x <= player_x + 1;
    end
  end else if (center == 1)
    player_x <= 10;
end

wire [7:0] next_wave_y [2:0];
wire [39:0] next_wave_bf [2:0];
assign next_wave_y[0] = (wave_y[0] == 1) ? (board_height - 2) : (wave_y[0] - 1);
assign next_wave_y[1] = (wave_y[1] == 1) ? (board_height - 2) : (wave_y[1] - 1);
assign next_wave_y[2] = (wave_y[2] == 1) ? (board_height - 2) : (wave_y[2] - 1);
assign next_wave_bf[0] = (wave_y[0] == 1) ? (rand_bf(difficulty, random_x)) : wave_bitfield[0];
assign next_wave_bf[1] = (wave_y[1] == 1) ? (rand_bf(difficulty, random_x)) : wave_bitfield[1];
assign next_wave_bf[2] = (wave_y[2] == 1) ? (rand_bf(difficulty, random_x)) : wave_bitfield[2];
assign death3 = is_dead(player_x, player_y, wave_y[0], wave_y[1], wave_y[2],
                        wave_bitfield[0], wave_bitfield[1], wave_bitfield[2]);

always @(posedge speed_clk, posedge center) begin
  if (pause == 1);
  else if (death == 0) begin
    /* Adjust score */
    if (next_wave_y[0] == 1 || next_wave_y[1] == 1 || next_wave_y[2] == 1) begin
      current_score <= current_score + 1;
      if (current_score == high_score)
        high_score <= high_score + 1;
    end
    /* Adjust waves */
    wave_y[0] <= next_wave_y[0];
    wave_bitfield[0] <= next_wave_bf[0];
    if (wave2_cntdown > 0)
      wave2_cntdown <= wave2_cntdown - 1;
    else begin
      wave_y[1] <= next_wave_y[1];
      wave_bitfield[1] <= next_wave_bf[1];
    end
    if (wave3_cntdown > 0)
      wave3_cntdown <= wave3_cntdown - 1;
    else begin
      wave_y[2] <= next_wave_y[2];
      wave_bitfield[2] <= next_wave_bf[2];
    end
  end else if (center == 1) begin
    current_score <= 0;
    wave_y[0] <= board_height - 2;
    wave_y[1] <= board_height - 2;
    wave_y[2] <= board_height - 2;
    wave_bitfield[0] <= 40'hfffffff007;
    wave_bitfield[1] <= 40'hf007ffffff;
    wave_bitfield[2] <= 40'hfffe00ffff;
    wave2_cntdown <= 6;
    wave3_cntdown <= 12;
  end
end

/* Function to determine if space is occupied by drones */
function is_dead;
input [7:0] player_x, player_y, wave1_y, wave2_y, wave3_y;
input [39:0] wave1_bfield, wave2_bfield, wave3_bfield;
begin
  if ((player_y == wave1_y) && (wave1_bfield[player_x] == 1) ||
      (player_y == wave2_y) && (wave2_bfield[player_x] == 1) ||
      (player_y == wave3_y) && (wave3_bfield[player_x] == 1))
    is_dead = 1;
  else
    is_dead = 0;
end
endfunction

/* Function to generate a random bitfield */
function [39:0] rand_bf;
input [3:0] diff;
input [5:0] rand_x;
reg [5:0] i;
reg [3:0] width;
begin
  case(diff)
    0: width = 4;
    1: width = 3;
    2: width = 2;
    default: width = 1;
  endcase;
  for (i = 0; i < 40; i = i + 1)
    rand_bf[i] = (i < rand_x - width || i > rand_x + width) ? 1 : 0;
end
endfunction

endmodule