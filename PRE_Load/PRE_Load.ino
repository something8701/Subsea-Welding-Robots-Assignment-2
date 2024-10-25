const int buttonPin = 2;    // Pin connected to the button (E-stop)
const int ledPin1 = 13;     // Green LED on D13 (matches MATLAB code)
const int ledPin2 = 12;     // Red LED on D12 (matches MATLAB code)
bool eStopTriggered = false;

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);  
  pinMode(ledPin1, OUTPUT);         
  pinMode(ledPin2, OUTPUT);          
  
  // Initial state
  digitalWrite(ledPin1, LOW);       // Green LED starts off
  digitalWrite(ledPin2, HIGH);      // Red LED starts on
  
  Serial.begin(9600);              
}

void loop() {
  int buttonState = digitalRead(buttonPin);
  
  // If button is pressed (LOW due to INPUT_PULLUP) and not already triggered
  if (buttonState == LOW && !eStopTriggered) {
    eStopTriggered = true;
    Serial.println("eStop");        // Send command to MATLAB
    delay(250);                     // Debounce delay
  }
  
  // Check for MATLAB commands
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim();
    
    if (command == "clearled") {
      eStopTriggered = false;
    }
  }
  
  // Let MATLAB control the LEDs directly
  delay(50);
}