--[[
%% properties
63 value
%% events
%% globals
--]]

-- Scene written by Brent Brown - https://github.com/Buster1959/Home-Automation
-- Last modified 14/09/2016 - V1 Production ready following testing.

-- My Variables 
local debug = 1
local currentDate = os.date("*t")
local quietStart = 23 -- 11pm - When you don't want the fan running from
local quietEnd = 06 -- 6am - To
local bathroomLight = 56
local bathroomFan = 57
local bathroomMotion = 63
local bathroomHumiditySensor = 66
local bathroomHumidityLevel = tonumber(fibaro:getValue(bathroomHumiditySensor, "value")) 
local startSource = fibaro:getSourceTrigger();
-- End my variables

-- Movement - LIGHT ON
if ( ( tonumber(fibaro:getValue(bathroomMotion, "value")) > 0 ) or startSource["type"] == "other") then 
  -- Turns on Bathroom Light and Fan if outside of silent hours 
	fibaro:call(bathroomLight, "turnOn");
  if debug == 1 then fibaro:debug("Bathroom Lights turned ON") end
    if (currentDate.hour >= quietEnd) and (currentDate.hour <= quietStart) then 
      fibaro:call(bathroomFan, "turnOn");
      if debug == 1 then fibaro:debug("Bathroom Fan turned ON") end
    end
end
-- End of LIGHTS ON

local startSource = fibaro:getSourceTrigger();
if(startSource["type"] == "other") then	
  fibaro:call(bathroomLight, "turnOff")
  if debug == 1 then fibaro:debug("Bathroom Lights turned OFF") end
  fibaro:call(bathroomFan, "turnOff")
  if debug == 1 then fibaro:debug("Bathroom Fan turned OFF") end
else
  if (( tonumber(fibaro:getValue(bathroomMotion, "value")) == 0 )) then
    setTimeout(function()
      local delayedCheck0 = false;
      local tempDeviceState0, deviceLastModification0 = fibaro:get(bathroomMotion, "value");
      if (( tonumber(fibaro:getValue(bathroomMotion, "value")) == 0 ) and (os.time() - deviceLastModification0) >= 120) then delayedCheck0 = true end
      local startSource = fibaro:getSourceTrigger();
      if ( ( delayedCheck0 == true ) or startSource["type"] == "other") then	
        fibaro:call(bathroomLight, "turnOff") 
        if debug == 1 then fibaro:debug("Bathroom Lights turned OFF") end
      end
      -- Turn Bathroom Fan off is Humidity is <5% of starting humiduty
      if debug == 1 then fibaro:debug("Humidity in the bathroom currently is " .. tonumber((fibaro:getValue(bathroomHumiditySensor, "value"))) .. " which is ".. (bathroomHumidityLevel - tonumber(fibaro:getValue(bathroomHumiditySensor, "value"))) .. " above, starting humidity of " .. bathroomHumidityLevel ) end
      local count = 0
      local maxRunTime = 60
      while  
        (( tonumber(fibaro:getValue(bathroomHumiditySensor, "value")) >= (bathroomHumidityLevel * 1.05 ))) and count < maxRunTime do
          count = count+1
          fibaro:sleep(60000) -- sleep for 1 miunute
          if debug == 1 then fibaroDebug("Waiting 1 minute for Humidity to fall. Humidity is: " .. (bathroomHumidityLevel - tonumber(fibaro:getValue(bathroomHumiditySensor, "value"))) .. " above start level") end
      end
      fibaro:call(bathroomFan, "turnOff");
      if debug == 1 then fibaro:debug("Bathroom Fan truned OFF") end
      -- END of Bathroom Fan Check
    end, 120000)
  end
end