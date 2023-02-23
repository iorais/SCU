#include <Servo.h>
#define MOVE 4000
#define CLOSED 0
#define OPEN 90
#define LIGHT 900

Servo myservo;

int wheel = 9;
int led = 7;
int button = 8;
int servo = 5;
int sensor = A5;
int pos;


void setup() {//sets up pins and motors
  Serial.begin(9600);
  pinMode(led,OUTPUT);
  pinMode(button,INPUT);
  pinMode(wheel,OUTPUT);
  pinMode(sensor,INPUT);
  myservo.attach(servo);
}

void loop() {
  int buttonState = digitalRead(button);
  int value = analogRead(sensor);
  
  if(buttonState == HIGH) {//opens door
    digitalWrite(led, HIGH);
    pos += OPEN;
    myservo.write(pos);

    Serial.println(value);
    if(value > LIGHT) {//moves dog based on light input
      digitalWrite(wheel, HIGH);
      delay(MOVE);
      digitalWrite(wheel, LOW);
    }
    
    delay(4000);
  }
}
