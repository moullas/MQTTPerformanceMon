-- Ref: http://giantmetalrobot.blogspot.in/2015/07/esp8266-i2c-lcd.html
local M
do
local id = 0
local sda = 4      -- GPIO0
local scl = 3      -- GPIO2
local dev = 0x27   -- I2C Address
local reg = 0x00   -- write
i2c.setup(id, sda, scl, i2c.SLOW)

local bl = 0x08      -- 0x08 = backlight on
local bloff = 0x00   -- 0x00 = backlight off

local function send(data)
   local value = {}
   for i = 1, #data do
      table.insert(value, data[i] + bl + 0x04 + rs)
      table.insert(value, data[i] + bl +  rs)      -- fall edge to write
   end
  
   i2c.start(id)
   i2c.address(id, dev ,i2c.TRANSMITTER)
   i2c.write(id, reg, value)
   i2c.stop(id)
end
 
local function backlightOff()
   --local value = {}
   data = {0x00, 0x10}
   local value = {}
   for i = 1, #data do
      table.insert(value, data[i] + bloff + 0x04 + rs)
      table.insert(value, data[i] + bloff +  rs)      -- fall edge to write
   end
  
   i2c.start(id)
   i2c.address(id, dev ,i2c.TRANSMITTER)
   i2c.write(id, reg, value)
   i2c.stop(id)          -- display on
 end

if (rs == nil) then
-- init
 rs = 0
 send({0x30})
 tmr.delay(4100)
 send({0x30})
 tmr.delay(100)
 send({0x30})
 send({0x20, 0x20, 0x80})      -- 4 bit, 2 line
 send({0x00, 0x10})            -- display clear
 send({0x00, 0xc0})            -- display on
end

local function cursor(op)
 local oldrs=rs
 rs=0
 if (op == 1) then 
   send({0x00, 0xe0})            -- cursor on
  else 
   send({0x00, 0xc0})            -- cursor off
 end
 rs=oldrs
end

local function cls()
 local oldrs=rs
 rs=0
 send({0x00, 0x10})
 rs=oldrs
end

local function home()
 local oldrs=rs
 rs =0
 send({0x00, 0x20})
 rs=oldrs
end


local function lcdprint (str,line,col)
if (type(str) =="number") then
 str = tostring(str)
end
rs = 0
--move cursor
if (line == 2) then
 send({0xc0,bit.lshift(col,4)})
elseif (line==1) then 
 send({0x80,bit.lshift(col,4)})
end

rs = 1
for i = 1, #str do
 local char = string.byte(string.sub(str, i, i))
 send ({ bit.clear(char,0,1,2,3),bit.lshift(bit.clear(char,4,5,6,7),4)})
end

end

M={
lcdprint=lcdprint,
cls = cls,
home=home,
cursor=cursor,
backlightOff=backlightOff,
}
end
return M
