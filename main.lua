require('config')

TOPIC = "/sensors/tsl2561/data"
m = mqtt.Client(CLIENT_ID, 120, "", "")
ip = wifi.sta.getip()

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

m:lwt("/lwt", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

-- Try to reconnect to broker when communication is down
m:on("offline", function(con)
    ip = wifi.sta.getip()
    print ("MQTT reconnecting to " .. BROKER_IP .. " from " .. ip)
    tmr.alarm(1, 10000, 0, function()
        node.restart();
    end)
end)

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")

m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)

        DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..ip..'", "online":"true"}'

        m:publish(TOPIC, DATA, 0, 0, function(conn)
                print(CLIENT_ID.." sending online: "..DATA.." to "..TOPIC)
            end)

        data = readLux()
        TMP_LUX_1 = tonumber(data._1)
        DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
        DATA = DATA..'"luminosity":"'..TMP_LUX_1..'","refresh":"'..REFRESH_RATE..'"}'

        m:publish(TOPIC, DATA, 0, 0, function(conn)
                print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
            end)

        tmr.alarm(1, REFRESH_RATE, 1, function()
                data = readLux()
                LUX_1 = tonumber(data._1)
                if(TMP_LUX_1 ~= LUX_1) then
                    TMP_LUX_1 = LUX_1
                    DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
                    DATA = DATA..'"luminosity":"'..LUX_1..'","refresh":"'..REFRESH_RATE..'"}'   
                    m:publish(TOPIC, DATA, 0, 0, function(conn)
                            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
                        end)
                end
            end)
    end)
