module pr_gen( clk,
               random);

input clk;
output reg [7:0] random;
wire feedback;
reg [7:0] rand_tmp;
reg [3:0] cnt;

assign feedback = rand_tmp[7] ^ rand_tmp[5] ^ rand_tmp[4] ^ rand_tmp[3];

initial begin
  rand_tmp <= 8'hF;
  cnt <= 0;
end

always @(posedge clk) begin
  if (cnt < 13) begin
    cnt <= cnt + 1;
    rand_tmp <= {rand_tmp[6:0], feedback};
  end else begin
    cnt <= 0;
    random <= rand_tmp;
  end
end

endmodule