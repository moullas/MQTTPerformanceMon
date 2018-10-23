-- file : application.lua
local module = {}
m = nil
 

isMqttAlive=false
-- Clear Screen Function
local function clear_screen()
    dofile("lcd.lc").cls()
end

local function backlight_off()
    dofile("lcd.lc").cls()
    dofile("lcd.lc").backlightOff()
end

-- Subscribe Function
local function subsribe()
    print("Attempting to subscribe to " ..configApp.mqttSubscribeTopic)
    m:subscribe(configApp.mqttSubscribeTopic, 0,
    function(conn) 
            m:publish(configApp.mqttLwtTopic,"Active",0,1)
    end) 
end

local function updateStatus()
 --publicIp()
    local table_status = {
        ["nodeid"] =  node.chipid(),
        ["sta_macaddr"] = wifi.sta.getmac(),
        ["ap_macaddr"] = wifi.ap.getmac(),
        ["ipaddr"] = wifi.sta.getip(),
        ["rssi"] = wifi.sta.getrssi(),
        --["epoch"] = rtctime.get(),
        ["reboot"] = tmr.time(),
        --["uptime"] =  rtctime.get() - tmr.time(),
        ["publicip"] = pulicIpAddress,
        ["heap"] = node.heap()
    }
    for st,va in pairs(table_status) do
        m:publish(configApp.mqttPublishTopicStatus..st,va,0,1)                
    end 
end

-- onMessage main Function callback
local function onMessage()
    m:on("message", function(conn, topic, data)
        if data ~= nil then
                print(topic .. ": " .. data)
                -- do something, we have received a message
                  if data == "CLS" then
                   print("Received CLEAR SCREEN")
                   clear_screen()
                   --dofile("lcd.lc").cls()
                  elseif data == "OFF" then
                   print("Received ON")
                   -- gpio.write(2, gpio.HIGH)
                  else
                   -- local t = sjson.decode('{"line1":"13-02-2018 23:32","line2":"CPU:52% MEM:100%"}')
                   -- example MQ message: {"line1":"13/02/2018 23:32","line2":"CPU:100% MEM:90%"}
                   -- print("Message : " .. topic ..": " .. data)
                   local succ, lcdData = pcall(function()
                        return sjson.decode(data)
                   end)
                   if succ then
                        --print(datas.line1)
                        --print(datas.line2)
                        dofile("lcd.lc").lcdprint(lcdData.line1,1,0)
                        dofile("lcd.lc").lcdprint(lcdData.line2,2,0)
                   else
                        print("Error parsing JSON")
                   end
                   end
                end
              --
    end)
end

-- Connect Function
function connectToMqtt()  
    m:connect(configApp.mqttHost, configApp.mqttPort, 0, 0, function(client) 
        isMqttAlive = true 
        print("Successfully Connected to MQTT broker: "..configApp.mqttHost.." on port: "..configApp.mqttPort)
        subsribe()
        onMessage()
        m:publish(configApp.mqttLwtTopic,"Active",0,1)
        m:on("offline", function(con) 
           isMqttAlive = false 
           print("Disconnected from MQTT")
        end)
    end,
    function(con,reason)
        print("Failed to connect to MQTT broker: "..configApp.mqttHost.." on port: "..configApp.mqttPort..", Reason: "..reason)
    end)
end

function module.start()
    m=mqtt.Client(configApp.NodeID, 10, configApp.mqttUserName, configApp.mqttpassword)  
    m:lwt(configApp.mqttLwtTopic, "Inactive", 0,1)

    -- Clear Screen
    clear_screen()
    -- Connect To Broker
    connectToMqtt()
    
    -- Start Timer
    tmr.alarm(configApp.mqttUpdateStatusTimerId,configApp.mqttUpdateStatusInterval, tmr.ALARM_AUTO, function()  
    if isMqttAlive == false  
        then
            print("Reconnect To MQTT:"..configApp.mqttHost.." on port: "..configApp.mqttPort)
            connectToMqtt()
        else
            print("MQTT is OK: "..configApp.mqttHost.." on port: "..configApp.mqttPort)
            updateStatus()
        end
    end) 
end

return module
