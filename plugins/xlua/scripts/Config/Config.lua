----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2021
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
boom_hide = find_dataref("custom/dromader/spray/boom_hide")
vru_set = find_dataref("custom/dromader/spray/vru_set")
pump_press_set = find_dataref("custom/dromader/spray/pump_press_set")
battery_conect = find_dataref("sim/operation/failures/rel_batter0")


local values = {}
values["boom_hide"] = 1
values["vru_set"] = 9
values["pump_press"] = 1
values["bat_con"] = 0

local filename = "Output/preferences/Dromader.txt"

local file = io.open(filename, "a+")

	while true do
	  ::continue::
	  local line = file:read("*line")
	  if line == nil then break end
	  k,v = line:match('^([^=]+)=(.+)$')
	  if k:sub(1, 1) == "#" then 
		goto continue --skip comments
	  elseif k == "boom_hide" then
		values["boom_hide"] = tonumber(v)
	  elseif k == "vru_set" then
		values["vru_set"] = tonumber(v)
	  elseif k == "pump_press" then
		values["pump_press"] = tonumber(v)
	  elseif k == "bat_con" then
		values["bat_con"] = tonumber(v)
	  end
	end
file:close()

function flight_start()
	boom_hide = values["boom_hide"]
	vru_set = values["vru_set"]
	pump_press_set = values["pump_press"]
	battery_conect = values["bat_con"]
end

function aircraft_unload()
local file = io.open(filename, "w")
  file:write("boom_hide=" .. boom_hide .. "\n" )
  file:write("vru_set=" .. vru_set .. "\n" )
  file:write("pump_press=" .. pump_press_set .. "\n" )
  file:write("bat_con=" .. battery_conect .. "\n" )
file:close()
end
