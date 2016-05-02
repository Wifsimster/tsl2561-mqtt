require('config')

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

-- MQTT client
TOPIC = "/sensors/bureau/tsl2561/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

tmr.alarm(2, 1000, 1, function()
    tmr.stop(2)
    print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
    m:connect(BROKER_IP, BROKER_PORT, 0, function(conn)
        print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
        LUX_0 = tonumber(readLux()._0)
        LUX_1 = tonumber(readLux()._1)
        
        -- First send data
        DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..wifi.sta.getip()..'",'
        DATA = DATA..'"lux_0":"'..LUX_0..'","lux_1":"'..LUX_1..'"}'
        m:publish(TOPIC, DATA, 0, 0, function(conn)
            print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
        end)
        
        -- Check every 5s for values change
        tmr.alarm(1, REFRESH_RATE, 1, function()
            TMP_LUX_0 = tonumber(readLux()._0)
            TMP_LUX_1 = tonumber(readLux()._1)
            if(LUX_0 ~= TMP_LUX_0 or LUX_1 ~= TMP_LUX_1) then
                DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..wifi.sta.getip()..'",'
                DATA = DATA..'"lux_0":"'..TMP_LUX_0..'","lux_1":"'..TMP_LUX_1..'"}'
                -- Publish a message (QoS = 0, retain = 0)       
                m:publish(TOPIC, DATA, 0, 0, function(conn)
                    print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
                end)
            else
                print("No change in value, no data send to broker.")
            end
        end)
    end)
end)

m:close();
