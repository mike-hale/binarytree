module seven_seg_ctrl (digit,    //Input
                       position, //Input
                       seg,      //Output
                       an        //Output
                      );

input [3:0] digit; //Value between 0 and 9
input [1:0] position; 
output reg [7:0] seg;
output reg [3:0] an;

always @* begin
  /* Enable only 'position' position
     Note: on = 0, off = 1 */
  an[0] = ~(position == 0);
  an[1] = ~(position == 1);
  an[2] = ~(position == 2);
  an[3] = ~(position == 3);

  /* Correctly set segments */
  case (digit)
    0: seg = 'b00111111;
    1: seg = 'b00000110;
    2: seg = 'b01011011;
    3: seg = 'b01001111;
    4: seg = 'b01100110;
    5: seg = 'b01101101;
    6: seg = 'b01111101;
    7: seg = 'b00000111;
    8: seg = 'b01111111;
    9: seg = 'b01101111;
    default: seg = 8'b0;
  endcase
end

endmodule