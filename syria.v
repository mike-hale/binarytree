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

/* Gameboard variables */
reg [7:0]  player_x;
reg [7:0]  player_y;
reg [7:0]  wave_y[2:0];
reg [39:0] wave_bitfield[2:0];

/* Game variables */
reg [15:0] high_score;
reg [23:0] speed_ctrl;
wire [175:0] packet;

assemble_pack pack_assembler (.clk(clk),
                              .player_x(player_x),
                              .player_y(player_y),
                              .wave_y(wave_y),
                              .wave_bitfield(wave_bitfield),
                              .packet(packet));

