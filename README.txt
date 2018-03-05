Each packet:

Header: 0x55AA (2bytes)
Player: (x, y) sizeof(x) = sizeof(y) = 1
Wave1Y: 1 byte
Wave1bitfield: 5 bytes
Wave2Y: 1 byte
Wave2bitfield: 5 bytes
Wave3Y: 1 byte
Wave3bitfield: 5 bytes

Total packet length: 22 bytes

Serial.c converts packet to a gameboard:

########################################





^^^^^^^^^^     ^^^^^^^^^^^^^^   ^^^^^^^^


      @



^^^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^





****************************************
