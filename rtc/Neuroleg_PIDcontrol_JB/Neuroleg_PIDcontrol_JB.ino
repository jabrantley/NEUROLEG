/*------------------------------------------------------------
  Author: Justin A Brantley, Dana Seibert
  Email: justin.a.brantley@gmail.com
  Laboratory for Non-Invasive Brain Machine Interface Systems
  University of Houston
  Date: 6/27/2019
  Version: V1
  ----------------------------------------------------------
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.*/

// --------------------------START---------------------------
// Include related libraries
#include "SPIencoder.h"

// PIN Definition.
int LED = 13;
#define  AS5045_CLK_PIN 14  // Clock PIN
#define  AS5045_CS_PIN 15   // Chip Select
#define  AS5045_DATA_PIN 16 // Data In
#define  pwmPin 9
#define  enablePin 10
#define  directionPin 11
#define  brakePin 12
uint8_t AS5045_nbits = 12;
uint8_t nbits = 16;
uint8_t PWM_nbits = 8;

// Instantiate Objects.
SPIencoder myAS5045(AS5045_CS_PIN, AS5045_CLK_PIN, AS5045_DATA_PIN, AS5045_nbits);

// Start position of leg
//double startAngle = 0; // this will work for enc raw or degrees

// Setup Timer
IntervalTimer myTimer;
int timerMicros = 50000;
int dt = timerMicros / 1000;

// Angles and start position
double minAngle = 1.0;
double maxAngle = 60.0;
double desiredAngle = minAngle;
//float inValue;

// PID Gains
double Kp = 4;
double Ki = 1 / 9;
double Kd = 0.01;
double error, cumError, rateError;
double lastAngle = desiredAngle;
double lastError = 0;
double setPoint, pidAngle;
double ITerm;

//float minphase = 10.0; //starting value
//float fase = minphase;
//float maxphase = 50.0;
int flag;

String inString = "";

// Global Variables
double rawEnc;
double degEnc;
double calibEnc;
uint8_t samplingRate = 200;
double samplingTimeus = 1000000 / samplingRate;
double Vcrange[2] = { -3.3, 3.3};
double pwmRange[2] = {10, 90};

// CHANGE THESE VARIABLES FOR STARTING IN FLEXION/EXTENSION
// EXTENSION- CHANGE IN MATLAB variable_making.m: measured_angle_offset.signals.values = 181, angle_range_min.signals.values = -180, angle_range_max.signals.values = 180
// FLEXION - CHANGE IN MATLAB variable_making.m: measured_angle_offset.signals.values = 240, angle_range_min.signals.values = 180, angle_range_max.signals.values = -180
// NOTE: range[2] = {max,min} NOT {min,max} - THIS IS REVERSED FROM MATLAB
// DEFINE MOVEMENT DIRECTION - i.e., flexion or extension
bool flex_or_ext = 0; // 0 = flexion, 1 = extension
int range[2] = {-180, 180}; // EXTENSION: range[2] = {180,-180}; FLEXION: range[2] = {-180,180};
float encOffset = 240;//181; // Encoder offset - EXTENSION: 181; FLEXION: 240;

// -----------------------------------------------------------
void setup() {
  // put your setup code here, to run once:
  // PIN mode setup, e.g., input/output
  // Serial setup
  pinMode(LED, INPUT);
  pinMode(pwmPin, OUTPUT);
  pinMode(enablePin, OUTPUT);
  pinMode(directionPin, OUTPUT);
  pinMode(brakePin, OUTPUT);
  Serial.begin(115200); // uncomment to use Serial

  // Moving to start postion
  //Serial.println("Moving leg to start position...");
  degEnc = myAS5045.EncDeg();

  // Begin timer
  myTimer.begin(execute_on_timer, timerMicros);
  //desiredAngle = 5;
}

// Execute on timer
void execute_on_timer() {

  digitalWrite(LED, !digitalRead(LED));
  // Read Encoder value
  rawEnc = myAS5045.EncRaw();
  degEnc = myAS5045.EncDeg();
  calibEnc = myAS5045.EncCalib(range, encOffset);


  while (Serial.available() > 0) {
    int inChar = Serial.read();
    if (inChar != '\n') { 

      // As long as the incoming byte
      // is not a newline,
      // convert the incoming byte to a char
      // and add it to the string
      inString += (char)inChar;
    }
    // if you get a newline, print the string,
    // then the string's value as a float:
    else {
      Serial.print("Input string: ");
      Serial.print(inString);
      Serial.print("\tAfter conversion to float:");
      Serial.println(inString.toFloat());
      desiredAngle = inString.toFloat();
      // clear the string for new input:
      inString = "";
    }
 
    //float inValue = Serial.parseFloat();
//    char inValue = Serial.read();
//    //Serial.flush();
//    //Serial.print("Value: ");
//    Serial.print(inValue);
//    Serial.print(" ");
//    //desiredAngle = inValue;
//    //Serial.println(inValue,DEC);
//    delay(1000);
  }


  // PID controller
  //pidAngle = PID(setPoint, calibEnc);

  Serial.print(desiredAngle);
  Serial.print(" ");
  Serial.print(calibEnc);
  Serial.print(" ");
  // Error computation
  error =  desiredAngle - calibEnc; // compute error
  //cumError += (error * dt);            // compute integral
  ITerm += (Ki * error) * dt; // <--- THIS IS WRONG BUT SOMEHOW WORKS...
  rateError = (calibEnc - lastAngle) / dt; // Using inputs to minimize derivative kick. Otherwise: (error - lastError) / dt; // compute derivative
  lastError = error;
  lastAngle = calibEnc;

  // Compute PID output
  //double pid_angle = Kp*error + Ki*cumError + Kd*rateError;
  double pid_angle = Kp * error + ITerm + Kd * rateError;
  Serial.print(pid_angle);
  Serial.println(" ");
  // Voltage
  float Vc = ((Vcrange[1] - Vcrange[0]) / 360) * pid_angle;
  if (Vc < Vcrange[0]) {
    Vc = Vcrange[0];
  }
  if (Vc > Vcrange[1]) {
    Vc = Vcrange[1];
  }

  // PWM
  float absVin = abs(Vc);
  int pwmRes = (1 << PWM_nbits) - 1;
  float pwmVal = (absVin / Vcrange[1]) * pwmRes;

  float finalPWMVal = ((pwmVal / pwmRes) * (0.8 * pwmRes)) + (0.1 * pwmRes);

  // Write PWM
  analogWrite(pwmPin, finalPWMVal);
  digitalWriteFast(brakePin, LOW);

  // Control motor based on direction of movement
  // EXTENSION
  if (flex_or_ext) {
    if (Vc < 0 ) {
      digitalWriteFast(enablePin, HIGH);
      digitalWriteFast(directionPin, HIGH);
    }
    if (Vc > 0 ) {
      digitalWriteFast(enablePin, HIGH);
      digitalWriteFast(directionPin, LOW);
    }
  }
  // FLEXION
  else {
    if (Vc < 0 ) {
      digitalWriteFast(enablePin, HIGH);
      digitalWriteFast(directionPin, LOW);
    }
    if (Vc > 0 ) {
      digitalWriteFast(enablePin, HIGH);
      digitalWriteFast(directionPin, HIGH);
    }
  } // end else


  if (desiredAngle > maxAngle) {
    Serial.println("SOMETHING");
    desiredAngle = maxAngle;
  }
  if (desiredAngle < minAngle) {
    Serial.println("HAPPENING");
    desiredAngle = minAngle;
  }
  
  //  if (desiredAngle > maxAngle) {
  //    flag = 1;
  //  }
  //  if (desiredAngle < minAngle) {
  //    flag = 0;
  //  }
  //  if (flag == 0) {
  //    //desiredAngle += 1;
  //    Serial.println("SOMETHING");
  //    desiredAngle = minAngle;
  //  }
  //  else if (flag == 1) {
  //    //desiredAngle -= 1;
  //    Serial.println("HAPPENING");
  //    desiredAngle = maxAngle;
  //  }

} // end execute_on_timer()

// -----------------------------------------------------------
void loop() {

}
