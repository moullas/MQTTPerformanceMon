print("\n\nHold Pin00 (Flash button) low to stop boot, you got one second.")
tmr.delay(1000000)
if gpio.read(3) == 0 then print("...boot stopped") return end
print("...booting")

configApp = require("1-config")
setup = require("2-setup")
app = require("3-application")

setup.start()
