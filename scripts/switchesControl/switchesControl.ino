#include "fastIO.h"

const int buttonPin = 2;
const int firstFirePin = 3;
const int secondFirePin = 4;

bool shouldFire = false;
int lastButtonState = LOW;  // the previous reading from the input pin
int buttonState;            // the current reading from the input pin
bool arleadyFired = false;


// the following variables are unsigned longs because the time, measured in
// milliseconds, will quickly become a bigger number than can be stored in an int.
unsigned long lastDebounceTime = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 50;

void setup() {
  // put your setup code here, to run once:
  pinMode(firstFirePin, OUTPUT);
  pinMode(secondFirePin, OUTPUT);
  digitalWrite(firstFirePin, 0);
  digitalWrite(secondFirePin, 0);

  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
  int reading = digitalRead(buttonPin);

  if (reading == LOW && !arleadyFired) {
    shouldFire = true;
  }
  if (reading == HIGH && arleadyFired) {
    arleadyFired = false;
  }

  if (shouldFire) {
    fastDigitalWrite(firstFirePin, 1);
    delayMicroseconds(2600);  // 3000
    fastDigitalWrite(secondFirePin, 1);
    delayMicroseconds(390);  // 3000
    fastDigitalWrite(firstFirePin, 0);
    delayMicroseconds(750);
    fastDigitalWrite(secondFirePin, 0);


    shouldFire = false;
    arleadyFired = true;
  }
}
