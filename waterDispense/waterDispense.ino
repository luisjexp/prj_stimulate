#include <CapacitiveSensor.h>
CapacitiveSensor   cs = CapacitiveSensor(3, 2);       // 10 megohm resistor between pins 4 & 2, pin 2 is sensor pin, add wire, foil

int valve_numPins       = 3; //numberof pins used to drive valve
int valve_pinIDs[3]     = {22, 24, 26}; // id of pins that drive valve
int valve_pulseWidth  = 75; //45 ms pulse width
int ttlStim_pinID       = 13;
int ttlReward_pinID     = 12;
byte lick = 0;        // 
int threshold = 200; // threshold of sensor , 150 is good
int cmd;

void setup() {
  int i;
  for (i = 0; i < valve_numPins; i++)
  { pinMode(valve_pinIDs[i], OUTPUT);
    digitalWrite(valve_pinIDs[i], LOW);
  }

  pinMode(ttlStim_pinID, OUTPUT);
  digitalWrite(ttlStim_pinID, LOW);

  pinMode(ttlReward_pinID, OUTPUT);
  digitalWrite(ttlReward_pinID, LOW);

  Serial.begin(9600);
}


void loop() {
  long val = cs.capacitiveSensor(30); // sensitivity
  lick = (val > threshold); //  

  if (Serial.available() > 0) {
    cmd = Serial.read();

    switch (cmd) {

      case 'w':       
        Serial.write(lick); // write back state of sensor
        break;

      case 'v':
        digitalWrite(ttlReward_pinID, HIGH); // ttl on
        for (int i = 0; i < valve_numPins; i++) {
          digitalWrite(valve_pinIDs[i], HIGH); // pins on
        }
        break;

      case 'c':
        for (int i = 0; i < valve_numPins; i++) {
          digitalWrite(valve_pinIDs[i], LOW); // turn off
        }
        break;

      case 'p':
        for (int i = 0; i < valve_numPins; i++) {
          digitalWrite(valve_pinIDs[i], HIGH); // turn on
        }
        delay(valve_pulseWidth); // hold
        for (int i = 0; i < valve_numPins; i++) {
          digitalWrite(valve_pinIDs[i], LOW); // turn on
        }
        break;

        case 'r':
          Serial.println(valve_pulseWidth); // write back state of sensor
          break;

        case '+':
          valve_pulseWidth = valve_pulseWidth + 1;
          valve_pulseWidth = constrain(valve_pulseWidth, 30, 500); 
          break;
          
        case '-':
          valve_pulseWidth = valve_pulseWidth - 1;
          valve_pulseWidth = constrain(valve_pulseWidth, 30, 500); 
          break;        


//          break;
//      case '1': //stim on
//        digitalWrite(ttlStim_pinID, HIGH);
//        break;
//
//      case '0': //stimoff
//        digitalWrite(ttlStim_pinID, LOW);
//        break;

    }
  }
}

