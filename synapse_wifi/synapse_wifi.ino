#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>

// Networking Configuration
const char* WIFI_SSID = "Synapse_Network";
const char* WIFI_PASSWORD = "password123";

// WebSocket Server on Port 81
WebSocketsServer webSocket(81);

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED: {
      IPAddress ip = webSocket.remoteIP(num);
      Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
      webSocket.sendTXT(num, "Synapse ESP8266 Connected!");
      break;
    }
  }
}

void setup() {
  // Start Serial (Connected to Arduino Nano TX)
  // Ensure the baud rate matches exactly!
  Serial.begin(115200);

  // Connect to WiFi network
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("Connected! IP address: ");
  Serial.println(WiFi.localIP());

  // Start WebSocket Server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  Serial.println("WebSocket server started on port 81");
}

void loop() {
  webSocket.loop();

  // Read incoming Serial lines from Arduino Nano
  if (Serial.available()) {
    String dataStr = Serial.readStringUntil('\n');

    // Strip trailing \r if present
    dataStr.trim();

    // Check if the data looks like a valid CSV packet: <F1,F2,F3,F4,F5,GX,GY,HR>
    if (dataStr.startsWith("<") && dataStr.endsWith(">")) {
      // Broadcast the string to all connected WebSocket clients
      webSocket.broadcastTXT(dataStr);
    }
  }
}
