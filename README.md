# MQTTPerformanceMon
Send Windows CPU &amp; Memory stats to MQTT for displaying on a Nodemcu connected LCD

This project comprises of 3 parts:
 -a Powershell script running on a Windows machine to send the performance data
 -a NodeMCU with a HD4780 16x2 LCD and the I2C backpack, used for displaying the data
 -a MQTT broker running on the network accessible by both the Windows host and the NodeMCU

The Powershell script reads the Windows CPU &amp; Memory usage via the WMI provider, 
this information is then formatted into a JSON message and published to a specific MQTT topic.
As the screen that is used for this purpose can display more information, the current data and
time is also encoded in the MQTT payload.
Information is sent to the MQTT topic every 1 second, this uses 
This script can be run as a scheduled task to run on log-on 

The Lua script used on the NodeMCU:
-Connects to WiFi
-Initializes the screen
-Subscribes to the MQTT broker
-Decodes the invocoming message, if it's the JSON formatted message it displays it in 2 lines,
 or checks the payload is just "CLS" clears the screen
 A 1 second delay is included in the init.lua file that breaks script execution if the flash button is pressed.

Pre-Requisites:
-You need to have a functioning MQTT broker running in the network, Mosquitto is used and tested
-Mosquitto needs to be installed on the machine running the Powershell script, the Mosquitto_pub cli 
 command must be available in the path the powershell script runs 