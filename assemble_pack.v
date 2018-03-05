module assemble_pack( clk,
                      player_x,
                      player_y,
                      wave1_y,
                      wave2_y,
                      wave3_y,
                      wave1_bitfield,
                      wave2_bitfield,
                      wave3_bitfield,
                      packet);

input wire clk;
input wire [7:0]  player_x;
input wire [7:0]  player_y;
input wire [7:0]  wave1_y;
input wire [7:0]  wave2_y;
input wire [7:0]  wave3_y;
input wire [39:0] wave1_bitfield;
input wire [39:0] wave2_bitfield;
input wire [39:0] wave3_bitfield;
output reg [175:0] packet;

initial
  packet <= 0;

always @(posedge clk) begin
  packet[15:0] <= 16'h55AA;
  packet[23:16] <= player_x;
  packet[31:24] <= player_y;
  packet[39:32] <= wave1_y;
  packet[79:40] <= wave1_bitfield;
  packet[87:80] <= wave2_y;
  packet[127:88] <= wave2_bitfield;
  packet[135:128] <= wave3_y;
  packet[175:136] <= wave3_bitfield;
end

endmodule