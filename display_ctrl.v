module display_ctrl (clk,
                     score_sw,
                     high_score,
                     curr_score,
                     an,
                     seg);

input wire clk, score_sw;
input wire [15:0] high_score;
input wire [15:0] curr_score;
output wire [3:0] an;
output wire [7:0] seg;

reg [8:0] mplex_cnt;
reg mplex_clk;
reg [2:0] pos;
reg [3:0] digit;

initial begin
  mplex_cnt <= 0;
  pos <= 0;
  digit <= 0;
end

always @(posedge clk) begin
  if (mplex_cnt == 500) begin
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
  if (score_sw == 0)
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