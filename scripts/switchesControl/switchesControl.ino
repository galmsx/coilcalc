#include "fastIO.h"

const int buttonPin = 3;
const int firstFirePin = 2;
const int secondFirePin = 4;
const int thirdFirePin = 5;
const int fourFirePin = 6;

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
  pinMode(thirdFirePin, OUTPUT);
  pinMode(fourFirePin, OUTPUT);
  digitalWrite(firstFirePin, 0);
  digitalWrite(secondFirePin, 0);
  digitalWrite(thirdFirePin, 0);
  digitalWrite(fourFirePin, 0);

  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
  int reading = digitalRead(buttonPin);

  // if (!reading) {
  //   digitalWrite(firstFirePin, 1);
  //   digitalWrite(secondFirePin, 1);
  //   digitalWrite(thirdFirePin, 1);
  //   digitalWrite(fourFirePin, 1);
  // } else {
  //   digitalWrite(firstFirePin, 0);
  //   digitalWrite(secondFirePin, 0);
  //   digitalWrite(thirdFirePin, 0);
  //   digitalWrite(fourFirePin, 0);
  // }

  if (reading == LOW && !arleadyFired) {
    shouldFire = true;
  }
  if (reading == HIGH && arleadyFired) {
    arleadyFired = false;
  }

  if (shouldFire) {
    //2800 for first stage, enter in sec stage coil at 3100(adjusted to -50)
    //  1320 total sec stage
    //

    // optimcal sec stage
    fastDigitalWrite(firstFirePin, 1);
    delayMicroseconds(2644);
    fastDigitalWrite(secondFirePin, 1);
    delayMicroseconds(156);
    fastDigitalWrite(firstFirePin, 0);
    delayMicroseconds(1164);
    fastDigitalWrite(secondFirePin, 0);

    // 3 total dur 1240 580before enter
    // enter in 3 after 1540 of start sec
    // so run 3 1540 - 580 = 960 after start sec

    // fastDigitalWrite(firstFirePin, 1);
    // delayMicroseconds(2644);
    // fastDigitalWrite(secondFirePin, 1);
    // delayMicroseconds(156);
    // fastDigitalWrite(firstFirePin, 0);

    // delayMicroseconds(804);
    // fastDigitalWrite(thirdFirePin, 1);
    // delayMicroseconds(360);
    // fastDigitalWrite(secondFirePin, 0);
    // delayMicroseconds(880);
    // fastDigitalWrite(thirdFirePin, 0);

    shouldFire = false;
    arleadyFired = true;
  }
}
