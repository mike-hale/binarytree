module assemble_pack( clk,
                      player_x,
                      player_y,
                      wave_y,
                      wave_bitfield,
                      packet);

input wire [7:0]  player_x;
input wire [7:0]  player_y;
input wire [7:0]  wave_y[3];
input wire [39:0] wave_bitfield[3];
output reg [175:0] packet;

initial
  packet <= 0;

always @(posedge clk) begin
  packet[15:0] <= 16'h55AA;
  packet[23:16] <= player_x;
  packet[31:24] <= player_y;
  packet[39:32] <= wave_y[0];
  packet[79:40] <= wave_bitfield[0];
  packet[87:80] <= wave_y[1];
  packet[127:88] <= wave_bitfield[1];
  packet[135:128] <= wave_y[2];
  packet[175:136] <= wave_bitfield[2];
end

endmodule