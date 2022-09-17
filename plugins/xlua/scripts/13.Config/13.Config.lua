----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2021
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
boom_hide = find_dataref("custom/dromader/spray/boom_hide")
vru_set = find_dataref("custom/dromader/spray/vru_set")
pump_press = find_dataref("custom/dromader/spray/pump_press_set")
bat_con = find_dataref("sim/operation/failures/rel_batter0")
show_pilot = find_dataref("custom/dromader/misc/show_pilot","number")
--foaming_quantity = find_dataref("custom/dromader/water/foaming_quantity")
foaming_quantity = find_dataref("sim/flightmodel/weight/m_stations[1]")
boom_fuse = find_dataref("custom/dromader/spray/boom_fuse")
startup_running = find_dataref("sim/operation/prefs/startup_running")


local values = {}
values["boom_hide"] = 1
values["vru_set"] = 9
values["pump_press"] = 1
values["bat_con"] = 0
values["show_pilot"] = 1

local filename = "Output/preferences/Dromader.cfg"

local file = io.open(filename, "a+")

	while true do
	  local line = file:read("*line")
	  if line == nil then break end
	  k,v = line:match('^([^=]+)=(.+)$')
	  if k:sub(1, 1) ~= "#" then 
		values[k] = tonumber(v)
	  end
	end
file:close()

function flight_start()
	boom_hide = values["boom_hide"]
	vru_set = values["vru_set"]
	pump_press = values["pump_press"]
	bat_con = values["bat_con"]
	show_pilot = values["show_pilot"]
	if boom_hide == 0 then
		foaming_quantity = 0
		if startup_running == 1 then
			boom_fuse = 1
		end
	else
		foaming_quantity = 60
	end
end

function aircraft_unload()
local file = io.open(filename, "w")

  file:write("boom_hide=" .. boom_hide .. "\n" )
  file:write("vru_set=" .. vru_set .. "\n" )
  file:write("pump_press=" .. pump_press .. "\n" )
  file:write("bat_con=" .. bat_con .. "\n" )
  file:write("show_pilot=" .. show_pilot .. "\n" )
file:close()
end
