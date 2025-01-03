#include <Wire.h>
#include <ESP8266WiFi.h>
#include "APDS9930.h"


#define LEDPIN D4
#define TRIGGERPIN D5
#define THRESHHOLD 200
#define STARTUPDELAY 5
#define VACUUMRUNTIME 8
#define AVERAGEDREADS 10

// Global Variables
APDS9930 apds = APDS9930();
uint16_t proximityData = 0;
uint8_t reads = 0;
uint16_t avgData = 0;
uint16_t rats = 0;

void triggerVaccuum(){
  WiFi.begin("RatTrap: 0", "pass-to-network");
  Serial.println("TRIGGERED");
  digitalWrite(LEDPIN, LOW);
  digitalWrite(TRIGGERPIN, HIGH);
  delay(VACUUMRUNTIME * 1000);
  digitalWrite(LEDPIN, HIGH);
  digitalWrite(TRIGGERPIN, LOW);
  WiFi.softAPdisconnect (true);
  rats++;
  WiFi.softAP("RatTrap: " + String(rats));
}

void setup() {
  WiFi.softAP("RatTrap: 0");
  pinMode(LEDPIN, OUTPUT);
  digitalWrite(LEDPIN, HIGH);
  pinMode(TRIGGERPIN, OUTPUT);
  digitalWrite(TRIGGERPIN, LOW);
  Serial.begin(9600);
  
  // Initialize APDS-9930 (configure I2C and initial values)
  if ( apds.init() ) {
    Serial.println(F("APDS-9930 initialization complete"));
  } else {
    Serial.println(F("Something went wrong during APDS-9930 init!"));
  }
  
  // Start running the APDS-9930 proximity sensor (no interrupts)
  if ( apds.enableProximitySensor(false) ) {
    Serial.println(F("Proximity sensor is now running"));
  } else {
    Serial.println(F("Something went wrong during sensor init!"));
  }

  delay(STARTUPDELAY * 1000);
}


void loop() {
  /*
  if ( !apds.readProximity(proximityData) ) {
    Serial.println("Error reading proximity value");
  } else {
    Serial.print("Proximity: ");
    Serial.println(proximityData);
  }
  */
  
  // Read the proximity value
  if ( !apds.readProximity(proximityData) ) {
    Serial.println("Error reading proximity value");
  } else {
    if(reads < (AVERAGEDREADS - 1)) {
      avgData = avgData + proximityData;
      reads++;
    }
    else {
      Serial.print("Proximity: ");
      avgData = avgData / AVERAGEDREADS;
      Serial.print(avgData);
      Serial.println("");

      if(avgData >= THRESHHOLD) {
        triggerVaccuum();
      }
      avgData = 0;
      reads = 0; 
    }
  }
  
  delay(50);
}