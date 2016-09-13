--[[
%% properties
63 value
%% events
%% globals
--]]

-- My Variables 

local currentDate = os.date("*t")
local quietStart = 23 -- 11pm - When you don't want the fan running from
local quietEnd = 06 -- 6am - To
local bathroomLight = 56
local bathroomFan = 57
local bathroomMotion = 63
local bathroomHumiditySensor = 66
local bathroomHumidityLevel = tonumber(fibaro:getValue(bathroomHumiditySensor, "value") 
-- End my variables

-- Movement - LIGHT ON

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getValue(bathroomMotion, "value")) > 0 ) -- This is the motion sensor 
or
startSource["type"] == "other"
)
then -- Turns on Bathroom Light and Fan if outside of silent hours 
	fibaro:call(bathroomLight, "turnOn");
	if (currentDate.hour >= quietEnd) and (currentDate.hour <= quietStart) then 
  	fibaro:call(bathroomFan, "turnOn");
    end
end
-- End of LIGHTS ON

-- Start LIGHTS OFF
local startSource = fibaro:getSourceTrigger();
if(startSource["type"] == "other") then
	fibaro:call(56, "turnOff");
	fibaro:call(57, "turnOff");
else
if (( tonumber(fibaro:getValue(63, "value")) == 0 )) then
setTimeout(function()
local delayedCheck0 = false;
local tempDeviceState0, deviceLastModification0 = fibaro:get(63, "value");
if (( tonumber(fibaro:getValue(63, "value")) == 0 ) and (os.time() - deviceLastModification0) >= 120) then
	delayedCheck0 = true;
end

local startSource = fibaro:getSourceTrigger();
if (
 ( delayedCheck0 == true )
or
startSource["type"] == "other"
)
then
	fibaro:call(bathroomLight, "turnOff");
	-- Next line to check if Humidyty high is so leave fan on by ending loop
    fibaro:debug("Humidity in the bathroom is: " .. fibaro:getValue(66, "value"))
    while 
      (( tonumber(fibaro:getValue(66, "value")) >= (bathroomHumidityLevel * 1.05 )) do
      fibaro:sleep(60000) -- sleep for 1 miunute   
    end
    fibaro:call(bathroomFan, "turnOff");
end
end, 120000)
end
end
-- End of LIGHTS OFF
