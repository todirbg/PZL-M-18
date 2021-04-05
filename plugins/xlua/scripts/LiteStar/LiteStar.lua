function dummy()

end

lat = find_dataref("sim/flightmodel/position/latitude")
lon = find_dataref("sim/flightmodel/position/longitude")
spd = find_dataref("sim/flightmodel/position/groundspeed")
crs = find_dataref("sim/flightmodel/position/true_psi")

fuse = create_dataref("custom/dromader/litestar/fuse","number", dummy)
power_sw = create_dataref("custom/dromader/litestar/power_sw","number", dummy)
brt_knob = create_dataref("custom/dromader/litestar/brt_knob","number", dummy)

function cmd_swath_adv(phase, duration)
	if phase == 0 then
	
	end
end

cmdswathadv = create_command("custom/dromader/litestar/but_swath_adv","Swath Advance",cmd_swath_adv)

function cmd_swath_dec(phase, duration)
	if phase == 0 then
	
	end
end

cmdswathdec = create_command("custom/dromader/litestar/but_swath_dec","Swath Decrement",cmd_swath_dec)

function cmd_set_mark(phase, duration)
	if phase == 0 then
	
	end
end

cmdsetmark = create_command("custom/dromader/litestar/but_set_mark","Set Mark",cmd_set_mark)

function cmd_toggle_fuse(phase, duration)
	if phase == 0 then
		if fuse == 1 then
			fuse = 0
		else
			fuse = 1
		end
	end
end

cmdtogglefuse = create_command("custom/dromader/litestar/toggle_fuse","Toggle fuse",cmd_toggle_fuse)

function cmd_toggle_power(phase, duration)
	if phase == 0 then
		if power_sw == 1 then
			power_sw = 0
		else
			power_sw = 1
		end
	end
end

cmdtogglepower = create_command("custom/dromader/litestar/toggle_power","Toggle power",cmd_toggle_power)

function cmd_but_menu(phase, duration)
	if phase == 0 then
	
	end
end

cmdbutmenu = create_command("custom/dromader/litestar/but_menu","Menu",cmd_but_menu)

function cmd_but_ent(phase, duration)
	if phase == 0 then
	
	end
end

cmdbutent = create_command("custom/dromader/litestar/but_ent","Enter",cmd_but_ent)

function cmd_but_up(phase, duration)
	if phase == 0 then
	
	end
end

cmdbutup = create_command("custom/dromader/litestar/but_up","Up",cmd_but_up)

function cmd_but_dn(phase, duration)
	if phase == 0 then
	
	end
end

cmdbutdn = create_command("custom/dromader/litestar/but_dn","Down",cmd_but_dn)



str_disL = create_dataref("custom/dromader/litestar/disp_L","string")
str_disR = create_dataref("custom/dromader/litestar/disp_R","string")
str_trkL = create_dataref("custom/dromader/litestar/trk_L","string")
str_trkR = create_dataref("custom/dromader/litestar/trk_R","string")
str_hdgL = create_dataref("custom/dromader/litestar/hdg_L","string")
str_hdgR = create_dataref("custom/dromader/litestar/hdg_R","string")
str_ontrk = create_dataref("custom/dromader/litestar/on_trk","string")
str_stat = create_dataref("custom/dromader/litestar/stat","string")
str_disL = "---A123"
str_disR = "123----"
str_trkL = ",,,,,,,,,,,,,,,,,,,,,,"
str_trkR = "**********************"
str_hdgL = ",,,,,,,,,,,,,,,,,,"
str_hdgR = "******************"
local ontrk = "` ` `"
str_ontrk = ontrk
str_stat = "<`,"

local points = {}
points["A"] = 0
points["B"] = 0
points["C"] = 0

--local track = math.asin(math.sin(distance(values["activeWPT"][1]["lat"], values["activeWPT"][1]["lon"], values["GPSlat"], values["GPSlon"])*pi/10800)*math.sin((course(values["activeWPT"][1]["lat"], values["activeWPT"][1]["lon"], values["GPSlat"], values["GPSlon"])-course(values["activeWPT"][1]["lat"], values["activeWPT"][1]["lon"], values["activeWPT"][2]["lat"], values["activeWPT"][2]["lon"]))*pi/180))/pi*-10800

function distance(lat1, lon1, lat2, lon2)

  lat1 =  lat1 * pi / 180
  lon1 =  lon1 * pi / -180
  lat2 =  lat2 * pi / 180
  lon2 =  lon2 * pi / -180
  local dist = (2 * math.asin(math.sqrt((math.sin((lat1 - lat2) / 2)) ^ 2 + math.cos(lat1) * math.cos(lat2) * (math.sin((lon1 - lon2) / 2)) ^ 2)))
  dist = dist * 10800 / pi
  return dist
end

function course(lat1, lon1, lat2, lon2)

  lat1 =  lat1 * math.pi / 180
  lon1 =  lon1 * math.pi / -180
  lat2 =  lat2 * math.pi / 180
  lon2 =  lon2 * math.pi / -180
  local course = math.fmod(math.atan2(math.sin(lon1 - lon2) * math.cos(lat2), math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(lon1 - lon2)), 2 * math.pi)
  course = (course * 180 / math.pi)
  if course < 0 then
    course = course + 360
  elseif course > 360 then
    course = course - 360
  end
  return course
 
end
