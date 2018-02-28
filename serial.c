#include<windows.h>
#include<stdio.h>
int main()
{
  HANDLE hComm;

  hComm = CreateFile(“COM1”,                //port name
                      GENERIC_READ | GENERIC_WRITE, //Read/Write
                      0,                            // No Sharing
                      NULL,                         // No Security
                      OPEN_EXISTING,// Open existing port only
                      0,            // Non Overlapped I/O
                      NULL);        // Null for Comm Devices

  if (hComm == INVALID_HANDLE_VALUE)
      printf(“Error in opening serial port”);
  else
      printf(“opening serial port successful”);

  DCB dcbSerialParams = { 0 };
  dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
  GetCommState(hComm, &dcbSerialParams);
  dcbSerialParams.BaudRate = CBR_9600;
  dcbSerialParams.ByteSize = 8;
  dcbSerialParams.StopBits = ONESTOPBIT;
  dcbSerialParams.Parity = NOPARITY;

  char char_buf;
  DWORD nbytes;
  while (1) {
    ReadFile (hComm, &char_buf, sizeof(char), &nbytes, NULL);
    printf("%c", char_buf);
  }

  CloseHandle(hComm);//Closing the Serial Port

  return 0;
}