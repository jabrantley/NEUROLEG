// This is the main file for the XBee trigger system.

// Manual trigger buttons for system synch
const int input_trigger = 2; // Main input trigger button - external
const int onboard_trigger = 3; // Main input trigger button - onboard

// MATLAB Serial Altered Pin
const int matlab_serial = 4; // Just used for detecting interrupt

// Output BNC
const int synch_out1 = 10; // BNC 1
const int synch_out2 = 11; // BNC 2
const int synch_out3 = 12;  // BNC 3
const int led_trigger = 13; // Input trigger indicator LED

// EEG 25-pin connector
const int eeg_outS1 = 17; // S1 trigger input to EEG
const int eeg_outS2 = 18; // S2 trigger input to EEG
const int eeg_outS4 = 19; // S4 trigger input to EEG

// BNC in from IR sensors - write to EEG out
const int eeg_in1 = 20; // Input 1 from IR sensor to EEG
const int eeg_in1LED = 21; // LED indicator for input 1 from IR sensor to EEG
const int eeg_in2 = 22; // Input 2 from IR sensor to EEG
const int eeg_in2LED = 23; // LED indicator for input 2 from IR sensor to EEG

// Create flag variable
volatile boolean flag1 = 0;
volatile boolean flag2 = 0;
volatile boolean flag3 = 0;
volatile boolean flag4 = 0;
volatile boolean flag5 = 0;

char matlabSignal;

// Debouncing variables
// For input trigger
unsigned long lastDebounceTime1 = 0; // last time input toggled
unsigned long debounceDelay1 = 30; // debounce time, increase if input flickers
// For onboard trigger
unsigned long lastDebounceTime2 = 0; // last time input toggled
unsigned long debounceDelay2 = 30; // debounce time, increase if input flickers
// For eeg_in1
unsigned long lastDebounceTime3 = 0; // last time input toggled
unsigned long debounceDelay3 = 30; // debounce time, increase if input flickers
// For eeg_in2
unsigned long lastDebounceTime4 = 0; // last time input toggled
unsigned long debounceDelay4 = 30; // debounce time, increase if input flickers

// Serial1 for writing to XBee
// rx1 = 0;
// tx1 = 1;

// ***********************************************************************************************************
// *                                                                                                         *
// *                                  ******* MAIN SETUP *******                                             *
// *                                                                                                         *
// ***********************************************************************************************************
void setup() {

  // Serial communication
  Serial1.begin(9600);
  Serial.begin(9600);


  // Define all pin modes
  pinMode(input_trigger, INPUT_PULLUP);     // INPUT_PULLUP used because using button
  pinMode(onboard_trigger, INPUT_PULLUP);   // INPUT_PULLUP used because using button
  pinMode(matlab_serial, INPUT_PULLUP);     // not sure about this ///////////////////////////////////////////////////////////////////////////////////////////////////////
  pinMode(synch_out1, OUTPUT);
  pinMode(synch_out2, OUTPUT);
  pinMode(synch_out3, OUTPUT);
  pinMode(led_trigger, OUTPUT);
  pinMode(eeg_outS1, OUTPUT);
  pinMode(eeg_outS2, OUTPUT);
  pinMode(eeg_outS4, OUTPUT);
  pinMode(eeg_in1, INPUT_PULLUP);
  pinMode(eeg_in1LED, OUTPUT);
  pinMode(eeg_in2, INPUT_PULLUP);
  pinMode(eeg_in2LED, OUTPUT);

  // Turn LEDs on and off 5x to indicate start up
  for (int ii = 0; ii <= 5; ii++) {
    digitalWriteFast(led_trigger, HIGH);
    digitalWriteFast(eeg_in1LED, HIGH);
    digitalWriteFast(eeg_in2LED, HIGH);
//    setXBeeState(0x5);
    delay(100);
    digitalWriteFast(led_trigger, LOW);
    digitalWriteFast(eeg_in1LED, LOW);
    digitalWriteFast(eeg_in2LED, LOW);
//    setXBeeState(0x4);
    delay(100);
  }

  // Setup interrupts
  // CHANGE used because need to interrupt when button pressed and when button released
  attachInterrupt (digitalPinToInterrupt(input_trigger), checkExternalButton, CHANGE);  // attach input_trigger (external) to pin 2
  attachInterrupt (digitalPinToInterrupt(onboard_trigger), checkOnboardButton, CHANGE);  // attach onboard_trigger (internal) to pin 3
  attachInterrupt (digitalPinToInterrupt(eeg_in1), checkInput1, CHANGE);  // attach eeg_in1 to pin 20
  attachInterrupt (digitalPinToInterrupt(eeg_in2), checkInput2, CHANGE);  // attach eeg_in2 to pin 22
  //attachInterrupt (digitalPinToInterrupt(matlab_serial), checkMATLAB, CHANGE); //serial from MATLAB


} // end of void setup()

// ***********************************************************************************************************
// *                                                                                                         *
// *                                  ******* MAIN LOOP *******                                              *
// *                                                                                                         *
// ***********************************************************************************************************

void loop() {
  //
  //  // ************ //
  //  // Check flag 1 //      // For input trigger
  //  // ************ //
  //
  //  if (flag1 == true)  // trigger by interrupt
  //  {
  //    int state1 = digitalRead(input_trigger);  // read and store current value (HIGH or LOW)
  //
  //    if ((long)(millis() - lastDebounceTime1) > debounceDelay1) // check if elapsed time since signal is greater than interval
  //    { // must be set to long
  //      flag1 = false; // reset flag
  //      //Serial.println((millis() - lastDebounceTime1)); // prints elapsed time
  //
  //      if (state1 == LOW)  // button pressed
  //      {
  //        triggerON();  // turns lights on and sends signals to certain outputs
  //      }
  //      else if (state1 == HIGH)  // button not pressed
  //      {
  //        triggerOFF(); // turns lights off and stops signals to certain outputs
  //      }
  //
  //      lastDebounceTime1 = millis(); //reset time
  //
  //    } // end of if ((long)(millis() - lastDebounceTime1) > debounceDelay1)
  //  }  // end of if (flag1 == true)
  //
  //
  //  // ************ //
  //  // Check flag 2 //    // For onboard trigger
  //  // ************ //
  //
  //  if (flag2 == true)  // trigger by interrupt
  //  {
  //    int state2 = digitalRead(onboard_trigger);  // read and store current value (HIGH or LOW)
  //
  //    if ((long)(millis() - lastDebounceTime2) > debounceDelay2) // check if elapsed time since signal is greater than interval
  //    { // must be set to long
  //      flag2 = false; // reset flag
  //      //Serial.println((millis() - lastDebounceTime2)); // prints elapsed time
  //
  //      if (state2 == LOW)  // button pressed
  //      {
  //        triggerON();  // turns lights on and sends signals to certain outputs
  //      }
  //      else if (state2 == HIGH)  // button not pressed
  //      {
  //        triggerOFF(); // turns lights off and stops signals to certain outputs
  //      }
  //
  //      lastDebounceTime2 = millis(); //reset time
  //
  //    } // end of if ((long)(millis() - lastDebounceTime2) > debounceDelay2)
  //  }  // end of if (flag2 == true)
  //
  //
  //  // ************ //
  //  // Check flag 3 //    // For eeg_in1 trigger
  //  // ************ //
  //
  //  // NOTE: A change in flag 3 (from eeg_in1 interrupt) ONLY creates marker in EEG data (S2)
  //
  //  if (flag3 == true)  // trigger by interrupt
  //  {
  //    int state3 = digitalRead(eeg_in1); // read and store current value (HIGH or LOW)
  //
  //    if ((long)(millis() - lastDebounceTime3) > debounceDelay3) // check if elapsed time since signal is greater than interval
  //    { // must be set to long
  //      flag3 = false; // reset flag
  //      //Serial.println((millis() - lastDebounceTime3)); // prints elapsed time
  //
  //      if (state3 == HIGH)  // blocked
  //      {
  //        // Set pins to high
  //        digitalWriteFast(eeg_outS2, HIGH);
  //        digitalWriteFast(eeg_in1LED, HIGH);
  //        // Turn on LED indicator
  //        digitalWriteFast(led_trigger, HIGH);
  //        digitalWriteFast(synch_out1, HIGH);
  //      }
  //      else if (state3 == LOW)  // not blocked
  //      {
  //        // Set pins to low
  //        digitalWriteFast(eeg_outS2, LOW);
  //        digitalWriteFast(eeg_in1LED, LOW);
  //        // Turn off LED indicator
  //        digitalWriteFast(led_trigger, LOW);
  //        digitalWriteFast(synch_out1, LOW);
  //      }
  //
  //      lastDebounceTime3 = millis(); //reset time
  //
  //    } // end of if ((long)(millis() - lastDebounceTime3) > debounceDelay3)
  //  }  // end of if (flag3 == true)
  //
  //
  //  // ************ //
  //  // Check flag 4 //    // For eeg_in2 trigger
  //  // ************ //
  //
  //  // NOTE: A change in flag 4 (from eeg_in2 interrupt) ONLY creates marker in EEG data (S4)
  //
  //  if (flag4 == true)  // trigger by interrupt
  //  {
  //    int state4 = digitalRead(eeg_in2);  // read and store current value (HIGH or LOW)
  //
  //    if ((long)(millis() - lastDebounceTime4) > debounceDelay4) // check if elapsed time since signal is greater than interval
  //    { // must be set to long
  //      flag4 = false; // reset flag
  //      //Serial.println((millis() - lastDebounceTime4)); // prints elapsed time
  //
  //      if (state4 == HIGH)  // blocked
  //      {
  //        // Set pins to high
  //        digitalWriteFast(eeg_outS4, HIGH);
  //        digitalWriteFast(eeg_in2LED, HIGH);
  //        // Turn on LED indicator
  //        digitalWriteFast(led_trigger, HIGH);
  //        digitalWriteFast(synch_out1, HIGH);
  //      }
  //      else if (state4 == LOW)  // not blocked
  //      {
  //        // Set pins to low
  //        digitalWriteFast(eeg_outS4, LOW);
  //        digitalWriteFast(eeg_in2LED, LOW);
  //        // Turn off LED indicator
  //        digitalWriteFast(led_trigger, LOW);
  //        digitalWriteFast(synch_out1, LOW);
  //      }
  //
  //      lastDebounceTime4 = millis(); //reset time
  //
  //    } // end of if ((long)(millis() - lastDebounceTime3) > debounceDelay3)
  //  }  // end of if (flag4 == true)
  //
} // end of void loop()

// ***********************************************************************************************************
// *                                                                                                         *
// *                          ******* Change status of digital pins *******                                  *
// *                                                                                                         *
// ***********************************************************************************************************

void serialEvent() {
  char rxChar = Serial.read();            // Save character received.
  Serial.flush();                    // Clear receive buffer.
  // Indicate start of experiment
  switch (rxChar) {
    case 's':
    case 'S':                          // If received 's' or 'S':
    for (int ii = 0; ii <= 2; ii++){
    digitalWriteFast(led_trigger, HIGH);
      // Set pins to high
      digitalWriteFast(eeg_outS1, HIGH);
      digitalWriteFast(synch_out1, HIGH);
      // blink twice to indicate start
      //for (int ii = 0; ii <= 2; ii++) {
      digitalWriteFast(led_trigger, HIGH);
      delay(100);
      
      //}
      //delay(10);
      // Set pin to low
      digitalWriteFast(eeg_outS1, LOW);
      digitalWriteFast(synch_out1, LOW);
      digitalWriteFast(led_trigger, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(100);
    }
      break;
    // Indicate end of experiment
    case 'e':
    case 'E':                          // If received 'e' or 'E':
      // Set pins to high
      digitalWriteFast(eeg_outS2, HIGH);
      // blink twice to indicate start{
      digitalWriteFast(led_trigger, HIGH);
      delay(500);
      // Set pin to low
      digitalWriteFast(eeg_outS2, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(500);
      break;
    // Indicate end of experiment
    // Indicate second thing
    case 't':
    case 'T':                          // If received 'e' or 'E':
      digitalWriteFast(led_trigger, HIGH);
      // Set pins to high
      digitalWriteFast(eeg_outS4, HIGH);
      delay(500);
      // Set pin to low
      digitalWriteFast(eeg_outS4, LOW);
      digitalWriteFast(led_trigger, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(500);
      break;
       // Indicate second thing
    case 'r':
    case 'R':                          // If received 'e' or 'E':
      digitalWriteFast(led_trigger, HIGH);
      // Set pins to high
      digitalWriteFast(eeg_outS1, HIGH);
      digitalWriteFast(eeg_outS2, HIGH);
      delay(500);
      // Set pin to low
      digitalWriteFast(eeg_outS1, LOW);
      digitalWriteFast(eeg_outS2, LOW);
      digitalWriteFast(led_trigger, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(500);
      break;
    case 'x':
    case 'X':                          // If received 'e' or 'E':
      digitalWriteFast(led_trigger, HIGH);
      // Set pins to high
      digitalWriteFast(eeg_outS1, HIGH);
      digitalWriteFast(eeg_outS4, HIGH);
      delay(500);
      // Set pin to low
      digitalWriteFast(eeg_outS1, LOW);
      digitalWriteFast(eeg_outS4, LOW);
      digitalWriteFast(led_trigger, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(500);
      break;
    case 'y':
    case 'Y':                          // If received 'e' or 'E':
      digitalWriteFast(led_trigger, HIGH);
      // Set pins to high
      digitalWriteFast(eeg_outS2, HIGH);
      digitalWriteFast(eeg_outS4, HIGH);
      delay(500);
      // Set pin to low
      digitalWriteFast(eeg_outS2, LOW);
      digitalWriteFast(eeg_outS4, LOW);
      digitalWriteFast(led_trigger, LOW);
      // Return "ok" for matlab to confirm rx
      //Serial.write("ok");
      delay(500);
      break;
  }
}

void triggerON ()
{
  // Set pins to high
  digitalWriteFast(synch_out1, HIGH);
  digitalWriteFast(synch_out2, HIGH);
  digitalWriteFast(synch_out3, HIGH);
  digitalWriteFast(eeg_outS1, HIGH);
  // Turn on LED indicator
  digitalWriteFast(led_trigger, HIGH);
  // Signal MATLAB
  Serial.write('M');
}

void triggerOFF ()
{
  // Set pins to low
  digitalWriteFast(synch_out1, LOW);
  digitalWriteFast(synch_out2, LOW);
  digitalWriteFast(synch_out3, LOW);
  digitalWriteFast(eeg_outS1, LOW);
  // Turn off LED indicator
  digitalWriteFast(led_trigger, LOW);
}

// ***********************************************************************************************************
// *                                                                                                         *
// *                        ******* Interrupt Service Routines (ISR) *******                                 *
// *                                                                                                         *
// ***********************************************************************************************************

void checkExternalButton()  // For input trigger
{
  flag1 = true; // triggers section in void loop()
}

void checkOnboardButton() // For onboard trigger
{
  flag2 = true; // triggers section in void loop()
}

void checkInput1()  // For eeg_in1
{
  flag3 = true; // triggers section in void loop()
}

void checkInput2()  // For eeg_in2
{
  flag4 = true; // triggers section in void loop()
}
//void checkMATLAB() //For matlab_serial
//{
//  flag5 = true; // triggers section in void loop()
//}


