#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

// Flex Sensor Pins
const int FLEX1_PIN = A0; // Thumb
const int FLEX2_PIN = A1; // Index
const int FLEX3_PIN = A2; // Middle
const int FLEX4_PIN = A3; // Ring
const int FLEX5_PIN = A6; // Pinky

// Pulse Sensor Pin
const int PULSE_PIN = A7; // Heart rate

// Timing logic for 50Hz transmission rate
unsigned long lastTime = 0;
const int UPDATE_INTERVAL = 20; // 50Hz = 1000ms / 50

void setup() {
  Serial.begin(115200);

  // Initialize I2C and MPU6050
  Wire.begin();
  mpu.initialize();

  // Give sensors time to stabilize
  delay(100);
}

void loop() {
  unsigned long currentTime = millis();

  // Send data at 50Hz
  if (currentTime - lastTime >= UPDATE_INTERVAL) {
    lastTime = currentTime;

    // Read Flex Sensors
    int f1 = analogRead(FLEX1_PIN);
    int f2 = analogRead(FLEX2_PIN);
    int f3 = analogRead(FLEX3_PIN);
    int f4 = analogRead(FLEX4_PIN);
    int f5 = analogRead(FLEX5_PIN);

    // Read Pulse Sensor
    int hr = analogRead(PULSE_PIN);

    // Read MPU6050
    int16_t ax, ay, az, gx, gy, gz;
    mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    // Convert raw gyro values to deg/s (assuming default 250 deg/s range -> 131 LSB/deg/s)
    float gyroX = gx / 131.0;
    float gyroY = gy / 131.0;

    // Format output as CSV: <F1,F2,F3,F4,F5,GX,GY,HR>
    Serial.print("<");
    Serial.print(f1); Serial.print(",");
    Serial.print(f2); Serial.print(",");
    Serial.print(f3); Serial.print(",");
    Serial.print(f4); Serial.print(",");
    Serial.print(f5); Serial.print(",");
    Serial.print(gyroX, 2); Serial.print(","); // 2 decimal places for accuracy
    Serial.print(gyroY, 2); Serial.print(",");
    Serial.print(hr);
    Serial.println(">");
  }
}
