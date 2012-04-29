//Arduino sketch for the Tag Player project, links RFID reader, Bluetooth module via UART, displays "ambient" 
//content using a HD44780 derivative character LCD
#include <LiquidCrystal.h>
#include <SoftwareSerial.h>
#include <string.h>

//arrays to store incoming data from the computer, RFID reader ID values
char rfidID[13];
char inData[100];
char inChar;
int index= 0;
int counter1,counter2= 0;
//boolean values to mark when a message from the computer has been receiverd
boolean started = false;
boolean ended = false;
boolean hasRfid = false;
//arrays to store the ID value,as well as the name
char name[16];
char ID[16];
//strings displayed on the LCD
char string1[] = "Welcome to Wattpad!  ";
char string2[] = "Tap your tag here... ";
//Software serial port for interfacing with the RFID reader
SoftwareSerial RFID(7,6);
// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

void setup() {
  // set up the LCD's number of columns and rows: 
  lcd.begin(16,2);
  lcd.home();
  //initalize the Bluetooth and RFID serial ports
  Serial.begin(115200);
  RFID.begin(9600);
}

void loop() {
 
  static int s_nPosition = 0;
  //Get incoming bytes from the computer
  while(Serial.available() > 0)
   {
		char inputChar = Serial.read();
		//if the beginning of message character is read, set flags to begin storing input data
		if(inputChar =='<'){
			started = true;
			index = 0;
			inData[index] = '\0';
			}
		//if EOM character is read, set ended flag
		else if(inpuChar == '>'){
			ended = true;
			}
		//otherwise, store the input data,and place a null character in the next value in the array,
		//to make the input data a C string
		else if(started){
			inData[index] = inputChar;
			index++;
			inData[index] = '\0';
			}
	}
   //if there is incoming data from the RFID reader, then read,place them in the RFID ID array
   while(RFID.available()>0){
     readRfidValue(rfidID,13);
     hasRfid = true;
   }
   
   //check if RFID ID exists, if so, then send it to computer via bluetooth, and reset array and flag for 
   //RFID ID
    if(hasRfid){
       hasRfid = false;
       Serial.println(rfidID);
       memset(rfidID,0,13);
     }

	//check if message from computer has arrived,
   if(started && ended)
   {
		//if message exists, reset LCD
        lcd.noAutoscroll();
        lcd.clear();
        lcd.setCursor(0,0);
		//get the name and ID values from the message, and replace space subsituite with actual spaces
		//(due to delimiter issues when using strtok)
        name = strtok (inData," ");
        ID = strtok (NULL, " ");
        strrep(ID,'/',' ');
		//print out the name and ID messages
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.print(name);
        lcd.setCursor(0,1);
        lcd.print(ID);

		//reset message received flags,arrays, and delay for 2.5 seconds to show message
		started = false;
		ended = false;
		index = 0;
		inData[index] = '\0';
        memset(inData,0,100);
		delay(2500);
   }
   //otherwise, display scrolling text, using example from
   //http://www.codeproject.com/Articles/38204/Interfacing-an-Arduino-with-LCDs
	else{
	int i;
	
    if(s_nPosition < (strlen(string1)- 16))
    {
        for(i=0; i<16; i++)
        {
            lcd.setCursor(i, 0);
            lcd.print(string1[s_nPosition + i]);
            lcd.setCursor(i,1);
            lcd.print(string2[s_nPosition + i]);
        }
    }
    else
    {
        int nChars = strlen(string1) - s_nPosition;
        for(i=0; i<nChars; i++)
        {
            lcd.setCursor(i, 0);
            lcd.print(string1[s_nPosition + i]);
            lcd.setCursor(i,1);
            lcd.print(string2[s_nPosition + i]);
        }

        for(i=0; i<(16 - nChars); i++)
        {
            lcd.setCursor(nChars + i, 0);
            lcd.print(string1[i]);
            lcd.setCursor(nChars+i,1);
            lcd.print(string2[i]);
        }
    }

    s_nPosition++;
    if(s_nPosition >= strlen(string1))
    {
        s_nPosition = 0;
    }

    delay(500);

    
   }
  }

//function for reading into a buffer, used to store the RFID reader value into the ID array
int readRfidValue(char *buffer, size_t length)
{
  size_t count = 0;
  while (count < length) {
    int c = RFID.read();
    if (c < 0) break;
    *buffer++ = (char)c;
    count++;
  }
  return count;
}

//string replacement function, used to replace space subsituite character with proper spaces
void strrep(char *str, char old, char newChar)  {
    char *pos;
    while (1)  {
        pos = strchr(str, old);
        if (pos == NULL)  {
            break;
        }
        *pos = newChar;
    }
}

