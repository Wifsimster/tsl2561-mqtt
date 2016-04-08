# Send TSL2561 data through an ESP8266 to a MQTT broker

This LUA script is for ESP8266 hardware.

## Description

MQTT client publising TSL2561 data to a MQTT broker each time data changes.

## Principle

1. Connect to a wifi AP
2. Start a MQTT client and try to connect to a MQTT broker
3. Publish data to  MQTT broker each time a data changes

## Scheme

