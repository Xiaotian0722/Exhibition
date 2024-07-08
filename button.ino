const int left1 = 2;
const int right1 = 3;
const int left2 = 4;
const int right2 = 5;
const int skip = 8;
const int back = 9;


void setup() {
  Serial.begin(9600);
  pinMode(left1, INPUT_PULLUP);
  pinMode(right1, INPUT_PULLUP);
  pinMode(left2, INPUT_PULLUP);
  pinMode(right2, INPUT_PULLUP);
  pinMode(skip, INPUT_PULLUP);
  pinMode(back, INPUT_PULLUP);
}

void loop() {
  if (digitalRead(left1) == LOW || digitalRead(left2) == LOW) {
    Serial.println("LEFT");
    delay(250);
  } else if (digitalRead(right1) == LOW || digitalRead(right2) == LOW) {
    Serial.println("RIGHT");
    delay(250);
  } else if (digitalRead(skip) == LOW) {
    Serial.println("SKIP");
    delay(200);
  } else if (digitalRead(back) == LOW) {
    Serial.println("BACK");
    delay(200);
  }
}
