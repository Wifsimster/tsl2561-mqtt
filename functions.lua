require('config')

-- Say hello to MQTT broker
function mqtt_online()
    DATA = '{"mac":"'..mac..'","ip":"'..ip..'","name":"'..CLIENT_ID..'","type":"'..DEVICE_TYPE..'"}'
    m:publish(ONLINE_TOPIC, DATA, 0, 0, function(conn)
        print(ONLINE_TOPIC.." : "..CLIENT_ID)
    end)
end

-- Ping MQTT broker
function mqtt_ping()
    tmr.create():alarm(10000, tmr.ALARM_AUTO, function(cb_timer)
        DATA = '{"mac":"'..mac..'"}'
        m:publish(PING_TOPIC, DATA, 0, 0, function(conn)
            print(PING_TOPIC.." : "..CLIENT_ID)
        end)
    end)
end

function mqtt_publish()
    data = readLux()
    TMP_LUX_1 = tonumber(data._1)
    DATA = '{"mac":"'..wifi.sta.getmac()..'","ip":"'..ip..'",'
    DATA = DATA..'"luminosity":"'..TMP_LUX_1..'","refresh":"'..REFRESH_RATE..'"}'
    m:publish(DATA_TOPIC, DATA, 0, 0, function(conn)
        print(DATA_TOPIC.." : "..CLIENT_ID.." - "..DATA)
    end)
end