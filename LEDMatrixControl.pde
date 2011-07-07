#include <TimerOne.h>

#define DATA_PIN 12
#define CLOCK_PIN 11
#define LATCH_PIN 10

#define TOTAL_ROWS 8
#define TOTAL_COLS 8     
#define LEDS_PER_GROUP 3

#define RED 0
#define GREEN 1
#define BLUE 2

#define BUFFER_SIZE (TOTAL_ROWS * TOTAL_COLS * LEDS_PER_GROUP)

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
        
        colROn |= *pixel++ ? _BV(c) : 0;
        colGOn |= *pixel++ ? _BV(c) : 0;
        colBOn |= *pixel++ ? _BV(c) : 0;    
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

void setLED(int row, int col, int color, int on) {

  int group = (col * TOTAL_COLS) + row;
  int index = (group * LEDS_PER_GROUP) + color;

  displayBuffer[index] = on;
}

boolean isOn(int row, int col, int color) {

  int group = (col * TOTAL_COLS) + row;
  int index = (group * LEDS_PER_GROUP) + color;

  return displayBuffer[index];
}

void setCol(int col, int color, int on) {

  for (int i = 0; i < TOTAL_COLS; i++) {
   
    setLED(i, col, color, on); 
  }
}

void setRow(int row, int color, int on) {
 
  for (int i = 0; i < TOTAL_COLS; i++) {
   
    setLED(row, i, color, on);
  }
}

void clearDisplay() {
 
  for (int i = 0; i < BUFFER_SIZE; i ++) {
    
    displayBuffer[i] = 0; 
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


void sayHi(int color) {
    
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


void spiral(int spd, int color) {

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


void loop() {

  clearDisplay();  
  spiral(20, RED);
  delay(100);
  
  clearDisplay();
  spiral(20, BLUE);
  delay(100);

  clearDisplay();  
  spiral(20, GREEN);
  delay(100);
  
  clearDisplay();
  int colors[] = {RED, BLUE, GREEN, RED, BLUE, GREEN, RED, BLUE};
  colorFill(10, colors);
  
  blinkDisplay(5, 100);
} 
