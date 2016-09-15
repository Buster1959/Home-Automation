-- Code snippet to calculate time duration between sunrise and sunset
-- Can be used within HC2 scene or virtual device
-- By Sankotronic 2016. Version 0.1
--
-- Correction for tommorow sunrise in minutes set by user
-- for northern hemisphere put positive number from 1 to 60 max
-- for southern hemisphere put negative number from -1 to -60 max
-- if 0 then no correction
local timeCorrection = 0;
-- take time of sunrise and sunset for today
local sunset       = fibaro:getValue(1, "sunsetHour");
local sunrise      = fibaro:getValue(1, "sunriseHour");
-- prepair hour and minute values for calculation
sunrisehour  = tonumber(string.sub(sunrise, 1, 2));
sunrisemin   = tonumber(string.sub(sunrise, 4, 5));
sunsethour   = tonumber(string.sub(sunset, 1, 2));
sunsetmin    = tonumber(string.sub(sunset, 4, 5));

-- function to calculate time duration between two different times in a day
function calculateDuration (H, M, DH, DM)
  if (H < DH) or ((H == DH) and (M < DM)) then
    Hp = H; H = DH; DH = Hp;
    Mp = M; M = DM; DM = Mp;
  end
  if M < DM then
    M = M + 60 - DM
    H = H - 1
  else
    M = M - DM
  end
  H = H - DH
  if string.len(H) < 2  then H = string.format("%s%s", '0', H) end 
  if string.len(M) < 2  then M = string.format("%s%s", '0', M) end 
  return string.format("%s:%s", H, M)
end

-- function to add time correction in minutes
function calculateCorrection(H, M, TC)
  -- get actual time and set up some important variables
  local currenttime  = os.date('*t');
  local currentmonth = currenttime['month']
  local currentday   = currenttime['day']
  -- Make sure that TC is positive number
  if TC < 0 then TC = math.abs(TC); south = true else south = false end;
  -- subfunction to add correction from summer to winter
  function addTC()
    M = M + TC; if M >= 60 then M = M - 60; H = H + 1; end;
  end
  -- subfunction to substract correction from winter to summer
  function subTC()
    if M < TC then M = M + 60 - TC; H = H - 1; else M = M - TC; end;
  end
  -- check time of year and add or substract correction
  if currentmonth >= 1 and currentmonth < 6 then
    if south then addTC() else subTC() end;
  elseif currentmonth == 6 then
    if currentday < 22 then
      if south then addTC() else subTC() end;
    elseif currentday > 22 then
      if south then subTC() else addTC() end;
    end
  elseif currentmonth > 6 and currentmonth < 12 then
    if south then subTC() else addTC() end;
  else
    if currentday < 22 then
      if south then subTC() else addTC() end;
    elseif currentday > 22 then
      if south then addTC() else subTC() end;
    end
  end
  if string.len(H) < 2  then H = string.format("%s%s", '0', H) end 
  if string.len(M) < 2  then M = string.format("%s%s", '0', M) end 
  return string.format("%s:%s", H, M)
end

-- Main code
-- if correction value is <> 0 then do time correction for sunrise
if timeCorrection ~= 0 then
  if timeCorrection >= -60 and timeCorrection <= 60 then
    sunrise = calculateCorrection(sunrisehour, sunrisemin, timeCorrection);
    sunrisehour  = tonumber(string.sub(sunrise, 1, 2));
    sunrisemin   = tonumber(string.sub(sunrise, 4, 5));
  end
end
-- Calculate day duration between sunrise & sunset
dayDuration   = calculateDuration (sunsethour, sunsetmin, sunrisehour, sunrisemin)
dayDurationH         = tonumber(string.sub(dayDuration, 1, 2));
dayDurationM         = tonumber(string.sub(dayDuration, 4, 5));
dayDurationMinutes   = dayDurationH * 60 + dayDurationM
-- Calculate night duration
nightDuration        = calculateDuration (24, 0, dayDurationH, dayDurationM)
nightDurationH       = tonumber(string.sub(nightDuration, 1, 2));
nightDurationM       = tonumber(string.sub(nightDuration, 4, 5));
nightDurationMinutes = nightDurationH * 60 + nightDurationM

-- display calculation
fibaro:debug("Sunrise: "..sunrise.."; Sunset: "..sunset.."; Day is long: "..dayDuration.."h - tot min: "..dayDurationMinutes.."; Night is long: "..nightDuration.."h - tot min: "..nightDurationMinutes)
