--[[ 
%% autostart 
%% properties 
%% globals 
--]] 

--while true do 

local currentDate = os.date("*t"); 
local wakeuptime = "07:00"; -- time to wake up 
local wakeupDuration = "15" -- time in minutes between start of Wakeup
local startlevel = 2; -- start dim level 
local dimlevel; 
local maxlevel = 80; -- max dim level 
local levelsteps = ((maxlevel - startlevel) / tonumber((wakeupDuration)) * 2)
local diminterval = 30;  -- interval time in seconds to wait to next dimlevel 
local light = 60; -- light to control 
local debug = true; 
local daysOfTheWeek = {} -- 1 = Mon, 2 = Tue etc.
    daysOfTheWeek[1] = true 
    daysOfTheWeek[2] = true
    daysOfTheWeek[3] = true 
    daysOfTheWeek[4] = true 
    daysOfTheWeek[5] = true 
    daysOfTheWeek[6] = false 
    daysOfTheWeek[7] = false
    -- Add true or false to each day you want the light to wake you.  

-- Thats the variables now the code

if (maxlevel > 100) then maxlevel = 100; end 
if (startlevel > maxlevel) then startlevel = maxlevel; end 
  

if   (daysOfTheWeek[currentDate.wday] == true and string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == wakeuptime)
 
  then 
    fibaro:debug("Wake up started at: " .. os.date()); 
    for level = startlevel, maxlevel, levelsteps do 
      dimlevel = level; 
      if (dimlevel > 100) then dimlevel = 100; end 
      fibaro:call(light, "setValue", dimlevel); 
      if (debug) then fibaro:debug("Set dim level at: " .. os.date()); end 
      if (debug) then fibaro:debug("Dimlevel: " .. dimlevel); end 
      fibaro:sleep(diminterval*1000); 
    end 
  end 

fibaro:sleep(60*1000); 
end;
