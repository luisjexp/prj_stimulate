// Explicitly declare Analog pins
const int JoyStick_X = A0; // x-axis
const int JoyStick_Y = A1; // y-axis
const int JoyStick_Z = 3;  // button/key (Digital Pin 3)

void setup() {
  // Use internal pull-up resistor to prevent floating readings on the button
  pinMode(JoyStick_Z, INPUT_PULLUP); 
  Serial.begin(9600); // 9600 bps baud rate
}

void loop() {
  int x = analogRead(JoyStick_X);
  int y = analogRead(JoyStick_Y);
  
  // With INPUT_PULLUP: 1 = Not Pressed, 0 = Pressed
  int z = digitalRead(JoyStick_Z); 

  // Print as a clean CSV line: "x,y,z\n"
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(z);

  delay(100); // 10 Hz update rate
}

