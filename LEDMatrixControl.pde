#include <TimerOne.h>

#define DATA_PIN 12
#define CLOCK_PIN 11
#define LATCH_PIN 10

#define TOTAL_ROWS 8
#define TOTAL_COLS 8     

#define ON true
#define OFF false

#define RED   0x01
#define GREEN 0x02
#define BLUE  0x04

#define BUFFER_SIZE (TOTAL_ROWS * TOTAL_COLS)

unsigned int TIMER_PERIOD = 10000;

uint8_t displayBuffer[BUFFER_SIZE];

void drawBufferContents() {
  
  uint8_t* pixel = displayBuffer;

  uint8_t rowOn = 1;
  uint8_t colROn = 0;
  uint8_t colGOn = 0;
  uint8_t colBOn = 0;
  
  for(byte r = 0; r < TOTAL_ROWS; r++) {
    
    colROn = 0; colGOn = 0; colBOn = 0;
    
    for (byte c = 0; c < TOTAL_COLS; c++) {
        
        colROn |= *pixel & RED   ? _BV(c) : 0;
        colGOn |= *pixel & GREEN ? _BV(c) : 0;
        colBOn |= *pixel & BLUE  ? _BV(c) : 0;
        
        *pixel++;
    }
   
    digitalWrite(LATCH_PIN, LOW); 
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST,   rowOn); // Row (ground)
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~colGOn); // Green
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~colROn); // Red
    shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~colBOn); // Blue
    digitalWrite(LATCH_PIN, HIGH);
    
    rowOn <<= 1;
  }

  digitalWrite(LATCH_PIN, LOW); 
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST,  0x00); // Row (ground)
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~0x00); // Green
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~0x00); // Red
  shiftOut(DATA_PIN, CLOCK_PIN, MSBFIRST, ~0x00); // Blue
  digitalWrite(LATCH_PIN, HIGH);
}

void setLED(int row, int col, byte color, boolean on) {

  int i = (col * TOTAL_COLS) + row;
    
  displayBuffer[i] = on ? (displayBuffer[i] | color) : (displayBuffer[i] & ~color);
}

uint8_t* getLED(int row, int col) {
  
  return &displayBuffer[(col * TOTAL_COLS) + row];
}

void setCol(int col, byte color, boolean on) {

  for (int i = 0; i < TOTAL_COLS; i++) {
   
    setLED(i, col, color, on); 
  }
}

void setRow(int row, byte color, boolean on) {
 
  for (int i = 0; i < TOTAL_COLS; i++) {
   
    setLED(row, i, color, on);
  }
}

void clearDisplay() {
 
  for (int i = 0; i < BUFFER_SIZE; i++) {

    displayBuffer[i] &= ~(RED|GREEN|BLUE);    
  }
}

void setup() {
  
  Serial.begin(9600);
  
  pinMode(DATA_PIN, OUTPUT);
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);
  
  Timer1.initialize(TIMER_PERIOD);
  Timer1.attachInterrupt(drawBufferContents);
}


void sayHi(byte color) {
    
    clearDisplay();
    setCol(0, color, 1);
    setCol(1, color, 1);
    setCol(3, color, 1);
    setCol(4, color, 1);
    setCol(6, color, 1);
    setCol(7, color, 1);    
    setLED(3, 2, color, 1);  
    setLED(4, 2, color, 1);
}


void colorFill(int spd, int *colors) {
    
  int lastCol = TOTAL_COLS;
  
  for (int ci = 0; ci < 8; ci++) {
    
    int currentColor = colors[ci];
    
    for (int row = 0; row < TOTAL_ROWS; row++) {
      
      for (int col = 0; col < lastCol; col++) {
     
        if (col != 0) {

          setLED(row, col - 1, currentColor, 0);
        }
        
        setLED(row, col, currentColor, 1);
        
        delay(spd);
      }      
    }

    if (lastCol != 0) {
      
      lastCol -= 1;
    }
    else {
     
      break; 
    }
  }  
}


void spiral(int spd, byte color) {

  const int UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3;
  
  int row = 4, col = 3, currentDir = UP;
  
  int startLength = 4, maxLength = TOTAL_ROWS * TOTAL_COLS;
  
  for (int i = 1; i <= 7; i += 2) {

    int totalLength = i * startLength;
    
    int sideLength = (totalLength / 4);
    
    for (int j = 1; j <= totalLength; j++) {
          
      switch (currentDir) {
       
        case RIGHT:
          col++;
          break;
        
        case DOWN:
          row++;
          break;
          
        case LEFT:
          col--;
          break;
          
        case UP:
          row--;
          break;
          
        default:
          break;       
      }
      
      setLED(row, col, color, 1);    
      
      delay(spd);
      
      if (j % sideLength == 0) {

        if (currentDir != LEFT) {
          
          currentDir++;
        }
        else {
          
          col--; row++;
          currentDir = UP; 
        }
      }
    }
  }  
}


void blinkDisplay(int times, int spd) {
  
  uint8_t displayCopy[BUFFER_SIZE];
  
  for (int i = 0; i < BUFFER_SIZE; i++) {
   
    displayCopy[i] = displayBuffer[i]; 
  }
  
  int timesBlinked = 0;
  
  while (timesBlinked < times) {
   
    for (int i = 0; i < BUFFER_SIZE; i++) {
      
      displayBuffer[i] = 0;
    }
    
    delay(spd);
    
    for (int i = 0; i < BUFFER_SIZE; i++) {
      
      displayBuffer[i] = displayCopy[i]; 
    }
    
    delay(spd);
    
    timesBlinked++;
  }
}


void setRowPattern(int row, byte pattern, byte color) {
  
  byte colOn = B00000001;
  
  for (int c = (TOTAL_COLS - 1); c >= 0; c--) {
    
    uint8_t* rgb = getLED(row, c);
  
    if ((colOn & pattern) == colOn) {
      
      *rgb |= color;
    }
    
    colOn <<= 1; 
  }
}


void blinkSmile(int times, byte color, int spd) {
  
  int timesBlinked = 0;
  
  while (timesBlinked < times) {
    
    clearDisplay();
    smileOn(color);
    delay(spd);
    
    clearDisplay();
    smileOff(color);
    delay(spd);
    
    timesBlinked++;
  }
}

void smileOn(byte color) {
  
  setRowPattern(0, B00000000, color);
  setRowPattern(1, B01100110, color);
  setRowPattern(2, B01100110, color);
  setRowPattern(3, B00000000, color);
  setRowPattern(4, B00011000, color);
  setRowPattern(5, B10011001, color);
  setRowPattern(6, B01000010, color);
  setRowPattern(7, B00111100, color);
}


void smileOff(byte color) {
  
  setRowPattern(0, B00000000, color);
  setRowPattern(1, B00000000, color);
  setRowPattern(2, B01100110, color);
  setRowPattern(3, B00000000, color);
  setRowPattern(4, B00011000, color);
  setRowPattern(5, B10011001, color);
  setRowPattern(6, B01000010, color);
  setRowPattern(7, B00111100, color);
}


void checkerboard(byte color1, byte color2, int times, int spd) {
 
  int timesBlinked = 0;

  while (timesBlinked < times) {
  
    setRowPattern(0, B11001100, color1);
    setRowPattern(1, B11001100, color1);
    setRowPattern(0, B00110011, color2);
    setRowPattern(1, B00110011, color2);
    
    setRowPattern(2, B00110011, color1);
    setRowPattern(3, B00110011, color1);
    setRowPattern(2, B11001100, color2);
    setRowPattern(3, B11001100, color2);
  
    setRowPattern(4, B11001100, color1);
    setRowPattern(5, B11001100, color1);
    setRowPattern(4, B00110011, color2);
    setRowPattern(5, B00110011, color2);
  
    setRowPattern(6, B00110011, color1);
    setRowPattern(7, B00110011, color1);  
    setRowPattern(6, B11001100, color2);
    setRowPattern(7, B11001100, color2);
    
    delay(spd);

    byte tmp = color1;
    color1 = color2;
    color2 = tmp;
    
    clearDisplay();
    
    timesBlinked++;
  }
}


void loop() {

  clearDisplay();
  int colors[TOTAL_COLS] = {RED, RED|GREEN, GREEN, GREEN|BLUE, BLUE|RED, BLUE, RED|GREEN, RED};
  colorFill(10, colors);
  blinkDisplay(3, 100);
  
  clearDisplay();
  spiral(20, RED|GREEN);
  delay(50);
  
  clearDisplay();
  spiral(20, RED|BLUE);
  delay(50);

  clearDisplay();
  checkerboard(RED, RED|GREEN|BLUE, 25, 100);
  delay(50);

  clearDisplay();
  blinkSmile(10, BLUE|GREEN, 70);
  delay(50);
} 
