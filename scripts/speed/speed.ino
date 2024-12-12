
#include <Arduino.h>
#include <GyverSegment.h>
#include <TimerOne.h>


#define DIO_PIN 2
#define SCLK 3
#define RCLK 4
// дефайны настроек (объявлять перед подключением библиотеки)
#define DISP595_CLK_DELAY 0  // задержка интерфейса в мкс
#define GS_EXP_TIME 100      // время экспонирования знакоместа


Disp595_4 disp(DIO_PIN, SCLK, RCLK);

int val;

void setup() {
  pinMode(5, INPUT_PULLUP);
  disp.setCursor(0);
  disp.print(0);
  disp.update();
  Serial.begin(9600);
  Timer1.initialize(10000);           // установка таймера на каждые 1500 микросекунд
  Timer1.attachInterrupt(timerIsr);  // запуск таймера
}

void timerIsr() {   // прерывание таймера
  disp.tickManual();  // пнуть дисплей
}

void loop() {
  unsigned long pulse = pulseInLong(5, HIGH);
  Serial.println(pulse);
  Serial.println(pulse > 0);


  if (pulse > 0) {
    float Speed = (1000000 / (float)pulse) * 0.0426;

    Serial.println(Speed);

    disp.setCursor(0);
    disp.print(Speed, 2);
    disp.update();
  }
}
