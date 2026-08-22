const int JoyStick_X = A0;
const int JoyStick_Y = A1;
const int JoyStick_Z = 3;

void setup() {
  pinMode(JoyStick_Z, INPUT_PULLUP);
  Serial.begin(9600);
}

void loop() {
  int x = analogRead(JoyStick_X);
  int y = analogRead(JoyStick_Y);

  // INPUT_PULLUP means LOW = pressed, HIGH = not pressed.
  int b = digitalRead(JoyStick_Z);

//  Serial.print(x);
//  Serial.print(",");
//  Serial.print(y);
//  Serial.print(",");
//  Serial.println(b*2000);
  
  Serial.print("{\"protocol\":\"device-api\"");
  Serial.print(",\"version\":\"0.1\"");
  Serial.print(",\"message_type\":\"arduino_joystick_1.sample\"");
  Serial.print(",\"payload\":{");
  Serial.print("\"time\":"); 
  Serial.print(millis());
  Serial.print(",\"x\":");
  Serial.print(x);
  Serial.print(",\"y\":");
  Serial.print(y);
  Serial.print(",\"b\":");
  Serial.print(b);
  Serial.println("}}");

  delay(100);
}
