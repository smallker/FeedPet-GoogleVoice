#include <Arduino.h>
#include <FirebaseESP8266.h>
#include <ESP8266WiFi.h>
#include <Servo.h>
#define WIFI_SSID "y"
#define WIFI_PASSWORD "11111111"
#define FIREBASE_HOST "assistant-iot-c5302.firebaseio.com"
#define FIREBASE_AUTH "9h9ybDSkYaP5N5tknza18lbmd2LMJfzO27UNhNT1"
#define FIREBASE_FCM_SERVER_KEY "AAAAaCOvYz0:APA91bF10--iPw-oDuieubxi13yi8gUQN40aL1skzGhVvI84S5dvDI0DtFGUAe1EPv26TixcXhgKUQhvTXbN896ojPk2F88tJi4sjNcsnMpXhy6Yig-otwfWBUO-A7bIbhkV4Fh59vRm"
#define sensorPin A0
#define servoPin D5
bool voice;
float berat;
FirebaseData firebaseData;
Servo servo;
void fungsiSuara(void);
void setup()
{
  pinMode(sensorPin, INPUT);
  servo.attach(servoPin);
  Serial.begin(9600);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  firebaseData.setBSSLBufferSize(1024, 1024);
  firebaseData.setResponseSize(1024);

  firebaseData.fcm.begin(FIREBASE_FCM_SERVER_KEY);
  firebaseData.fcm.setPriority("high");
  firebaseData.fcm.setTimeToLive(1000);
  firebaseData.fcm.setTopic("status");
}
void loop()
{
  /*  Ganti variabel berat dengan pembacaan
      real dari sensor load cell 
  */
  berat = analogRead(sensorPin);
  Serial.print("beratnya adalah :");
  Serial.println(berat);
  if (berat > 500)
  {
    Firebase.set(firebaseData, "/status", true);
  }
  else
  {
    Firebase.set(firebaseData, "/status", false);
  }

  if (Firebase.getBool(firebaseData, "/voice"))
  {
    voice = firebaseData.boolData();
    fungsiSuara();
  }
}

void fungsiSuara()
{
  if (voice == true)
  {
    Serial.println("Mengecek kondisi load cell");
    if (berat > 500)
    {
      Serial.println("tempat makan sudah penuh");
    }
    else
    {
      Serial.println("mengisi tempat makan");
      servo.write(180);
      delay(5000);
      servo.write(0);
    }
    Firebase.set(firebaseData,"/voice",false);
  }
}
