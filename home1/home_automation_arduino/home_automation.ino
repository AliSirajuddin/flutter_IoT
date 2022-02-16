
#include <ESP8266WiFi.h>

const char* ssid = "Rumah";
const char* password = "rumahalbasor";

#include "DHT.h"
#define DHTPIN 14
#define DHTTYPE DHT11   // DHT 11
DHT dht(DHTPIN, DHTTYPE);

#include<FirebaseArduino.h>

#define fb_Host "Your Firebase Host"
#define fb_Auth "Your Firebase Auth"

int relay_1 = 12;
int lamp = 13;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) 
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  pinMode(relay_1,OUTPUT);
  pinMode(lamp,OUTPUT);
  
  dht.begin();

  Firebase.begin(fb_Host, fb_Auth);
  
}
void loop() {
  // put your main code here, to run repeatedly:
  float h = dht.readHumidity();  
  float t = dht.readTemperature();  
  float f = dht.readTemperature(true);

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }

  String StatLamp = Firebase.getString("device/lampu1");
  Firebase.setFloat("device/temperature",t);

  if(StatLamp == "true"){
    digitalWrite(Lamp,HIGH);
  }else{
    digitalWrite(Lamp,LOW);
  }

  String StatCharge = Firebase.getString("device/chargeStat");
  if(StatCharge == "true"){
    digitalWrite(relay_1,LOW);
  }else{
    digitalWrite(relay_1,HIGH);
  }
  delay(1000);
}
