--[[
%% properties
114 value
%% events
%% globals
HomeMode
--]]


-- Scene written by Brent Brown (Buster1959)
-- To use the scene you need to create a Predefined Variable within the Variable Panal with:
-- Variable values of "Home", "Away","Night" & "Vacation"
-- This will allow you to set Armed /Disarmed for alarm scene but also you can use these variables for scenes that 
-- do things like turn the heating to eco when on Vacation, or turn lights on/off at random times

local debug = 1 -- Set to 1 to debug the scene
local indoorAlarm = 108
local keypadID = 114 -- ID of Keypad or door lock
local armMode = tonumber(fibaro:getValue(keypadID, "value"))
local home_Mode = fibaro:getGlobalValue("HomeMode") -- Set variable for to that of HomeMode Predefined variable
local startSource = fibaro:getSourceTrigger();

local phoneArray = {} -- IDs of the phones to Push messages to
phoneArray["Brent"] = 109 -- OnePlus
-- phoneArray["Zac"] = 

local sensorArray = {} -- Array to hold all of the Devices 
sensorArray["Landing"] = 99
sensorArray["FrontDoor"] = 33
sensorArray["KitchenMotion"] = 22 -- Comment out for testing
sensorArray["BackDoor"] = 31
sensorArray["MasterBedroom"] = 49
sensorArray["Bathroom"] = 63
local backDoorArmDelay=tonumber((fibaro:getValue(sensorArray["BackDoor"], "armDelay"))) -- Get the Arm Delay from main entry point

function setArmedStatus(deviceId,state) -- Function to Arm / Disarm device
local dev = api.get('/devices/' .. deviceId)
-- false= disarm; true= armded
dev.properties.armed = state
api.put('/devices/' .. deviceId, dev)
end
 
--State what the current Back Door Arm Delay
if debug == 1 then fibaro:debug("Back Door Delay = " .. backDoorArmDelay .. "\n") end

if debug == 1 then 
  for key, value in pairs(sensorArray) do fibaro:debug(key .. " : " .. value) end
end


-- Check if keypad /door lock changes state & set HomeMode appropriatly
if ((tonumber(fibaro:getValue(keypadID, "value")) == 0 )) then 
  if debug == 1 then fibaro:debug("Setting Sensors to DISARM because HomeMode is set to: " .. home_Mode) end
  	for key, value in pairs(sensorArray) do setArmedStatus(value, false) end
    --for key, value in pairs(sensorArray) do fibaro:call(value, "setArmed", "0") end
    if debug == 1 then for key, value in pairs(sensorArray) do fibaro:debug(key .. " = " .. fibaro:getValue(value, "armed")) end end
    fibaro:call(sensorArray["BackDoor"], "setValue", "30") -- Make the alarm flash
  	fibaro:sleep(2000)
  	fibaro:call(indoorAlarm, "turnOff")
    fibaro:setGlobal("HomeMode", "Home")
    for key, value in pairs(sensorArray) do 
      if fibaro:getValue(value, "armed") == 1 then fibaro:call(phoneArray["Brent"], 'sendPush', "The following device is still ARMED: " .. key) end
    end
else
  if debug == 1 then fibaro:debug("Setting Sensors to ARM because HomeMode is se to : " .. home_Mode) end
  	--for key, value in pairs(sensorArray) do fibaro:call(value, "setArmed", "1") end
    for key, value in pairs(sensorArray) do setArmedStatus(value, true) end
	if debug == 1 then for key, value in pairs(sensorArray) do fibaro:debug(key .. " = " .. fibaro:getValue(value, "armed")) end end
  	fibaro:call(sensorArray["BackDoor"], "setValue", "30") -- Make the alarm flash
  	fibaro:sleep(backDoorArmDelay)
  	fibaro:call(indoorAlarm, "turnOff")
    fibaro:setGlobal("HomeMode", "Away") -- Set the HomeMode to away
end
