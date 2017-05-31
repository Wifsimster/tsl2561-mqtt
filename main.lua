require('config')
require('functions')

mac = wifi.sta.getmac()
ip = wifi.sta.getip()
m = mqtt.Client(CLIENT_ID, 120, "", "")

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

m:lwt("/lwt", '{"message":"'..CLIENT_ID..'","topic":"'..DATA_TOPIC..'","ip":"'..ip..'"}', 0, 0)

-- Try to reconnect to broker when communication is down
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to " .. BROKER_IP .. " from " .. ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart();
    end)
end)

print("Connecting to "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    mqtt_online()
    mqtt_ping()
    tmr.alarm(1, REFRESH_RATE, 1, function()
        data = readLux()
        LUX_1 = tonumber(data._1)
        if(TMP_LUX_1 ~= LUX_1) then
            TMP_LUX_1 = LUX_1
            mqtt_publish()
        end
    end)
end)
