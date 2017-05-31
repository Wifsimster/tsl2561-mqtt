-- Wifi Settings
AP = "WIFWIFI"
PWD = "192Wifsimster!!"

-- MQTT Broker
BROKER_IP = "192.168.0.35"
BROKER_PORT = 1883

-- MQTT Settings
CLIENT_ID = "ESP8266-"..node.chipid()
ONLINE_TOPIC = "/online/"
PING_TOPIC = "/ping/"
DATA_TOPIC = "/sensors/tsl2561/"
DEVICE_TYPE = "luminosity"

-- Device Settings
REFRESH_RATE = 1000
SDA_PIN = 3 -- GPIO_0
SCL_PIN = 4 -- GPIO_2