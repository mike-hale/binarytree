module redb (in_sig, out_sig, deb_clk);

input wire in_sig, deb_clk;
output reg out_sig;

reg prev;

initial begin
  prev <= 0;
  out_sig <= 0;
end

always @(posedge deb_clk) begin
  if (prev == 0 && in_sig == 1) begin
    out_sig <= 1;
    prev <= 1;
  end else if (in_sig == 0) begin
    prev <= 0;
    out_sig <= 0;
  end else
    out_sig <= 0;
end
    
endmodule