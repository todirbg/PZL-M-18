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
values["boom"] = 1
values["vru"] = 5
values["pump"] = 1
values["bat_con"] = 0

local filename = "Output/preferences/Dromader.txt"

local file = io.open(filename, "a+")

	while true do
	  local line = file:read("*line")
	  if line == nil then break end
	  if string.find(line, "#spray") then
		values["boom"] = tonumber(string.sub(line, 7))
	  elseif string.find(line, "#vru") then
		values["vru"] = tonumber(string.sub(line, 5))
	  elseif string.find(line, "#pump") then
		values["pump"] = tonumber(string.sub(line, 6))
	  elseif string.find(line, "#bat_con") then
		values["bat_con"] = tonumber(string.sub(line, 9))
	  end
	end
file:close()

function flight_start()
	boom_hide = values["boom"]
	vru_set = values["vru"]
	pump_press_set = values["pump"]
	battery_conect = values["bat_con"]
end

function aircraft_unload()
local file = io.open(filename, "w")
  file:write("#spray" .. boom_hide .. "\n" )
  file:write("#vru" .. vru_set .. "\n" )
  file:write("#pump" .. pump_press_set .. "\n" )
  file:write("#bat_con" .. battery_conect .. "\n" )
file:close()
end
