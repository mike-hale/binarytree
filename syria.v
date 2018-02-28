module syria (RxD,  //Incoming serial data
              TxD,  //Outgoing serial data
				  clk,  //100 MHz clock signal
				  btns, //center button
				  btnu, //upper button
				  btnl, //left button
				  btnd, //bottom button
				  btnr, //right button
				  sw);  //switch
				  
input RxD, clk, btns, btnu, btnl, btnd, btnr, sw;
output TxD;

reg [15:0] player_pos;
reg [