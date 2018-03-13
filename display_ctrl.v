module display_ctrl (clk, // 100 MHz
                     death,
                     score_sw,
                     high_score,
                     curr_score,
                     an,
                     seg);

input wire clk, score_sw, death;
input wire [15:0] high_score;
input wire [15:0] curr_score;
output wire [3:0] an;
output wire [7:0] seg;

reg [8:0] mplex_cnt;
reg mplex_clk; //100 kHz
reg [1:0] pos;
reg [3:0] digit;
reg [16:0] lose_cnt;

initial begin
  mplex_cnt <= 0;
  mplex_clk <= 0;
  pos <= 0;
  digit <= 0;
end

always @(posedge clk) begin
  if (mplex_cnt == 5) begin //Implementation: 500
    mplex_cnt <= 0;
    mplex_clk <= ~mplex_clk;
  end else
    mplex_cnt <= mplex_cnt + 1;
end

seven_seg_ctrl my_numbers (.digit(digit),
                           .position(pos),
                           .seg(seg),
                           .an(an));

always @(posedge mplex_clk) begin
  pos <= pos + 1;
  lose_cnt <= (death == 1) ? (lose_cnt + 1) : 0;
  if (death == 1 && lose_cnt[16] == 1)
    case ('h3 & (pos + 1))
      0: digit <= 11; //E
      1: digit <= 5; //S
      2: digit <= 0; //O
      3: digit <= 10; //L
    endcase
  else if (score_sw == 0)
    case ('h3 & (pos + 1))
      0: digit <= curr_score % 10;
      1: digit <= (curr_score / 10) % 10;
      2: digit <= (curr_score / 100) % 10;
      3: digit <= (curr_score / 1000) % 10;
    endcase
  else
    case ('h3 & (pos + 1))
      0: digit <= high_score % 10;
      1: digit <= (high_score / 10) % 10;
      2: digit <= (high_score / 100) % 10;
      3: digit <= (high_score / 1000) % 10;
    endcase
end

endmodule