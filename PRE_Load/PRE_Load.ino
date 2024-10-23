const int buttonPin = 2;   // Pin connected to the button (E-stop)
const int ledPin1 = 13;    // Pin connected to the first LED (green, ready state)
const int ledPin2 = 12;    // Pin connected to the second LED (red, E-stop active)

bool eStopTriggered = false;  // Variable to track if the E-stop has been triggered

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);  // Enable internal pull-up resistor for the button
  pinMode(ledPin1, OUTPUT);          // Set first LED pin (green) as an output
  pinMode(ledPin2, OUTPUT);          // Set second LED pin (red) as an output
  digitalWrite(ledPin1, LOW);        // Ensure green LED is off at startup
  digitalWrite(ledPin2, HIGH);       // Turn on the red LED at startup (E-stop active)
  Serial.begin(9600);
}

void loop() {
  int buttonState = digitalRead(buttonPin);  // Read the button state

  // If the button is pressed (E-stop), trigger the stop state
  if (buttonState == LOW && !eStopTriggered) {
    eStopTriggered = true;         // Mark E-stop as triggered
    digitalWrite(ledPin1, HIGH);   // Turn on the green LED (ready state)
    digitalWrite(ledPin2, LOW);    // Turn off the red LED (E-stop deactivated)
    Serial.println("eStop");       // Send E-stop command to MATLAB
  }

  // Check for serial input to reset the E-stop state
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();  // Remove any trailing newline or spaces
    if (command == "clearled") {
      eStopTriggered = false;      // Reset the E-stop triggered state
      digitalWrite(ledPin1, LOW);  // Turn off the green LED (not ready)
      digitalWrite(ledPin2, HIGH); // Turn on the red LED (E-stop active)
    }
  }

  delay(100);
}
