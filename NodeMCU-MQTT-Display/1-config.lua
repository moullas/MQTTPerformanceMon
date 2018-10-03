-- file : config.lua
local module = {}

--USER VARS
module.SSID = {["AP1"] = "AP1Pass",["AP2"] = "AP2Pass"}  -- SSID {["AP1Name"] = "AP1Password",["AP2Name"] = "AP2Password"}
module.mqttHost = "192.168.1.1"  -- MQTT Server host IP
module.mqttPort = 1883              -- MQTT Server Port
module.mqttUsername = "mqUser"     -- MQTT Username, delete value unauthenticated-> module.mqttUsername = ""
module.mqttPassword = "mqPass"   -- MQTT Password, delete value blank if unauthenticated
module.mqttEndpoint = "nodemcu/"    -- MQTT Root Topic for this class of devices

-- STATIC VARS
module.NodeID = node.chipid()
module.mqttUpdateStatusTimerId=3
module.mqttUpdateStatusInterval=1000
module.mqttSubscribeTopic=module.mqttEndpoint .. module.NodeID
module.mqttPublishTopicStatus=module.mqttEndpoint .. module.NodeID.."/status/"
module.mqttLwtTopic=module.mqttEndpoint .. "lwt/" .. module.NodeID
return module 
