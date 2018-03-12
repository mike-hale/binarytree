#include <windows.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

#define BOARD_WIDTH  40
#define BOARD_HEIGHT 20

struct pack_str {
  uint16_t header;
  uint8_t player_x;
  uint8_t player_y;
  uint8_t wave1_y;
  uint8_t wave1_bf[5];
  uint8_t wave2_y;
  uint8_t wave2_bf[5];
  uint8_t wave3_y;
  uint8_t wave3_bf[5];
};

int main()
{
  HANDLE hComm;

  hComm = CreateFile("COM_stream.txt",                //port name
                      GENERIC_READ,// | GENERIC_WRITE, //Read/Write
                      FILE_SHARE_READ | FILE_SHARE_WRITE,                            // No Sharing
                      NULL,                         // No Security
                      OPEN_EXISTING,// Open existing port only
                      0,            // Non Overlapped I/O
                      NULL);        // Null for Comm Devices

  if (hComm == INVALID_HANDLE_VALUE)
      printf("Error in opening serial port\n");
  else
      printf("opening serial port successful\n");
/*
  DCB dcbSerialParams = { 0 };
  dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
  GetCommState(hComm, &dcbSerialParams);
  dcbSerialParams.BaudRate = 9600;
  dcbSerialParams.ByteSize = 8;
  dcbSerialParams.StopBits = ONESTOPBIT;
  dcbSerialParams.Parity = NOPARITY;
*/
  char game_board[BOARD_HEIGHT][BOARD_WIDTH];
  /* Fill in top and bottom */
  for (int i = 0; i < BOARD_WIDTH; i++) {
    game_board[0][i] = '#';
    game_board[BOARD_HEIGHT - 1][i] = '*';
  }
 
  char pack_buf[22];
  DWORD nbytes;
  int bytes_read;

  /* Align to next header */
  char header;
  while(1) {
    ReadFile(hComm, &header, 1, &nbytes, NULL);
    if (nbytes == 0) {
      printf("Sleeping\n");
      Sleep(50000);
    }
    printf("Byte: 0x%02x\n", header & 0xFF);
    if ((header & 0xFF) == 0xAA) {
      ReadFile(hComm, &header, 1, &nbytes, NULL);
      if ((header & 0xFF) == 0x55) {
        bytes_read = 2;
        break;
      }
    }
  }
  /* Start reading packets */
  while (1) {
    ReadFile (hComm, pack_buf + bytes_read, sizeof(pack_buf) - bytes_read, &nbytes, NULL);
    bytes_read += nbytes;
    if (bytes_read == sizeof(pack_buf)) {
      bytes_read = 0;
      struct pack_str* packet = (struct pack_str*)pack_buf;
      /* Print packet info */
      printf("Character: (%d, %d)\n", packet->player_x, packet->player_y);
      printf("Wave 1: y=%d, bf=%x%x%x%x%x\n", packet->wave1_y, packet->wave1_bf[4] & 0xFF, packet->wave1_bf[3] & 0xFF, packet->wave1_bf[2] & 0xFF, packet->wave1_bf[1] & 0xFF, packet->wave1_bf[0] & 0xFF);
      printf("Wave 2: y=%d, bf=%x%x%x%x%x\n", packet->wave2_y, packet->wave2_bf[4] & 0xFF, packet->wave2_bf[3] & 0xFF, packet->wave2_bf[2] & 0xFF, packet->wave2_bf[1] & 0xFF, packet->wave2_bf[0] & 0xFF);
      printf("Wave 3: y=%d, bf=%x%x%x%x%x\n", packet->wave3_y, packet->wave3_bf[4] & 0xFF, packet->wave3_bf[3] & 0xFF, packet->wave3_bf[2] & 0xFF, packet->wave3_bf[1] & 0xFF, packet->wave3_bf[0] & 0xFF);
      for (int i = 0; i < BOARD_WIDTH; i++) {
        int bf_index = i / 8;
        int mask = (1 << (i % 8));
        if (packet->wave1_y >= BOARD_HEIGHT || packet->wave2_y >= BOARD_HEIGHT || packet->wave3_y >= BOARD_HEIGHT) {
          printf("Invalid heigh fields\n");
          Sleep(50000);
        }
        game_board[packet->wave1_y][i] = (packet->wave1_bf[bf_index] & mask) ? '^' : ' ';
        game_board[packet->wave2_y][i] = (packet->wave2_bf[bf_index] & mask) ? '^' : ' ';
        game_board[packet->wave3_y][i] = (packet->wave3_bf[bf_index] & mask) ? '^' : ' ';
        /* Place spaces in all other spaces */
        for (int j = 1; j < BOARD_HEIGHT - 1; j++)
          if (j != packet->wave1_y && j != packet->wave2_y && j != packet->wave3_y)
            game_board[j][i] = ' ';
      }
      /* Place player */
      if (game_board[packet->player_y][packet->player_x] == '^' ||
          packet->player_y == 0 || packet->player_y == BOARD_HEIGHT - 1)
        game_board[packet->player_y][packet->player_x] = 'X';
      else
        game_board[packet->player_y][packet->player_x] = '@';
      /* Print out gameboard */
      system("cls");
      for (int i = 0; i < BOARD_HEIGHT; i++) {
        if (fwrite(game_board[i], sizeof(char),  BOARD_WIDTH, stdout) < 0)
          printf("Error printing line\n");
        printf("\n");
      }
      fflush(stdout);
    }
    else
      continue;
  }

  CloseHandle(hComm);//Closing the Serial Port

  return 0;
}