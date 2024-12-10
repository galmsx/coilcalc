
const int buttonPin = 2;
const int firePin = 3;

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
  pinMode(firePin, OUTPUT);
  digitalWrite(firePin, LOW);

  pinMode(buttonPin, INPUT_PULLUP);
}

void loop() {
  int reading = digitalRead(buttonPin);

  if (reading == LOW && !arleadyFired) {
    shouldFire = true;
  }
  if(reading == HIGH && arleadyFired){
    arleadyFired = false;
  }

  if (shouldFire) {
    digitalWrite(firePin, HIGH);
    delayMicroseconds(3000);
    digitalWrite(firePin, LOW);
    shouldFire = false;
    arleadyFired = true;
  }
}
