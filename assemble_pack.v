module assemble_pack( clk, //50 Hz clk
                      player_x,
                      player_y,
                      wave1_y,
                      wave2_y,
                      wave3_y,
                      wave1_bitfield,
                      wave2_bitfield,
                      wave3_bitfield,
                      death,
                      current_score,
                      high_score,
                      packet);

input wire clk, death;
input wire [7:0]  player_x;
input wire [7:0]  player_y;
input wire [7:0]  wave1_y;
input wire [7:0]  wave2_y;
input wire [7:0]  wave3_y;
input wire [39:0] wave1_bitfield;
input wire [39:0] wave2_bitfield;
input wire [39:0] wave3_bitfield;
input wire [15:0] current_score, high_score;
output reg [175:0] packet;

reg [5:0] death_cnt;

initial begin
  packet <= 0;
  death_cnt <= 0;
end

always @(posedge clk) begin
  packet[15:0] <= 16'h55AA;
  if (death == 1 && death_cnt == 5) begin //50 for implementation
    packet[31:16] <= 16'hFFFF;
    packet[55:40] <= high_score;
    packet[71:56] <= current_score;
  end else begin
    death_cnt <= (death == 1) ? (death_cnt + 1) : 0;
    packet[23:16] <= player_x;
    packet[31:24] <= player_y;
    packet[79:40] <= wave1_bitfield;
  end
  packet[39:32] <= wave1_y;
  packet[87:80] <= wave2_y;
  packet[127:88] <= wave2_bitfield;
  packet[135:128] <= wave3_y;
  packet[175:136] <= wave3_bitfield;
end

endmodule