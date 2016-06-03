require('config')
local ntp = require('ntp')

TOPIC = "/sensors/"..LOCATION.."/tsl2561/data"

function readLux()
    tsl2561 = require("tsl2561")
    tsl2561.init(SDA_PIN, SCL_PIN)    
    ch0, ch1 = tsl2561.getrawchannels()
    rst = {}
    rst["_0"] = ch0
    rst["_1"] = ch1    
    tsl2561 = nil
    package.loaded["tsl2561"] = nil    
    return rst
end

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

ip = wifi.sta.getip()

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

-- Sync to NTP server
ntp.sync()

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    tmr.alarm(1, REFRESH_RATE, 1, function()
        data = readLux()
        LUX_0 = tonumber(data._0)
        LUX_1 = tonumber(data._1)
        DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
        DATA = DATA..'"date":"'..ntp.date()..'","time":"'..ntp.time()..'",'
        DATA = DATA..'"lux_0":"'..LUX_0..'","lux_1":"'..LUX_1..'"}'
        -- Publish a message (QoS = 0, retain = 0)       
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
    end)
end)
