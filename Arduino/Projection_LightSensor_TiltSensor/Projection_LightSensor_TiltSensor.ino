//Sketch that detects 
// 1. The user interaction depending on the tilt sensor value
// 2. The lighting conditions of the room

const int tiltSensorPin = 2;     
const int lightSensorPin = 0;

const int tiltSensorLedPin = 9;
const int lightSensorLedPin =  13;     

// variables will change
int tiltSensorState = 0;        
int prevTiltSensorState = -1; 

// Variables for light Level
int lightLevel= 0;
int prevLightLevel = 0; 

// We'll also set up some global variables for the light level:
int maxDark = 0, maxLight = 1023;

void setup() 
{
  // initialize the LED pin as an output:
  pinMode(lightSensorLedPin, OUTPUT);      
  
  // initialize the pushbutton pin as an input:
  //pinMode(tiltSensorPin, INPUT);

  //Initialise the LED pin as an output
  pinMode(tiltSensorLedPin, OUTPUT);

  Serial.begin(9600);  
}

void loop()
{  
  String sensorValues = "";
  
  // read the state of the pushbutton value:
  tiltSensorState = digitalRead(tiltSensorPin);
  
//  //Check if the tilt sensor orientation has been changed, if it has send signal to processing  
//  if(tiltSensorState!= prevTiltSensorState)
//  {
    // check if the pushbutton is pressed.
    // if it is, the tiltSensorState is HIGH:
    
      if (tiltSensorState == HIGH) 
      {     
        // turn LED on:    
        digitalWrite(tiltSensorLedPin, HIGH);
        //Serial.println("T1"); 
        sensorValues = sensorValues+ "1,";  
      }
      
      else 
      {
        // turn LED off:
        digitalWrite(tiltSensorLedPin, LOW);
        //Serial.println("T0"); 
        sensorValues = sensorValues+ "0,";  
  
      } 
      
//     prevTiltSensorState =  tiltSensorState; 
//  }
  
  //Check if the light level value has changed, if it is send the signal to processing
   
  //lightlevel is low for dark and high if it is bright
  
  lightLevel = analogRead(lightSensorPin);
  
  //Serial.println(lightLevel);

  autoTune();
  //Serial.println(lightLevel);

  
  sensorValues = sensorValues+ (String) lightLevel;  
    
  Serial.println(sensorValues);
  
  digitalWrite(lightSensorLedPin, lightLevel);
  
  delay(100);
  
}

void autoTune()
{ 
  if (lightLevel < maxLight)
  {
    maxLight = lightLevel;
  }
  
  if (lightLevel > maxDark)
  {
    maxDark = lightLevel;
  }
  
  lightLevel = map(lightLevel, maxLight+30, maxDark-30, 0, 255);
  lightLevel = constrain(lightLevel, 0, 255);
}
