----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
-- parts of this code is borrowed from EADT KLN90B. 10x Falcon!
----------------------------------------------------------------------------------------------------------
function dummy()

end

local in_menu = 0
local area = 0 --area in hectares
local area_disp = 0
local swath_width_dis = 0
local hdop = 0.6 --const not simulated
local xtk = 0
local dtk = 0
local gps_crs = 0
local guide = 0
local brt_control = 101
local spd = 0
local alt = 0
local numsats = 6 --const not simulated
local mode = 0 -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto
local xtksense = 0
local swath_num = 0
local swath_dir = 0
local swath_width_m = 0
local flash_timer = 0

local temp_mrk_lat = 0
local temp_mrk_lon = 0

local points = {}
points["A"] = {["lat"] = 0, ["lon"] = 0}
points["B"] = {["lat"] = 0, ["lon"] = 0}
points["C"] = {["lat"] = 0, ["lon"] = 0}
points["LastLoc"] = {["lat"] = 0, ["lon"] = 0}
points["Mrk"] = {["lat"] = 0, ["lon"] = 0}

local menu = {}
menu[1] = {}
menu[1]["name"] = ">JOB"
menu[1]["value"] = {"NEW JOB", "OLD JOB"}
menu[1]["set"] = 1

menu[2] = {}
menu[2]["name"] = ">SWIDTH"
menu[2]["value"] = {"50.0"}
menu[2]["set"] = 1

menu[3] = {}
menu[3]["name"] = ">PATRN"
menu[3]["value"] = {"BK_BK L", "BK_BK R"}
menu[3]["set"] = 1

menu[4] = {}
menu[4]["name"] = ">DIM"
menu[4]["value"] = {"USEKNOB"}
menu[4]["set"] = 1

menu[5] = {}
menu[5]["name"] = ">DISP1"
menu[5]["value"] = {"SwthNum", "X-Track", "Blank", "GPS Alt", "NumSats", "HDOP", "A/B Hdg", "Time", "Dst2Mrk", "Acres", "AcftHdg", "Speed"}
menu[5]["set"] = 1

menu[6] = {}
menu[6]["name"] = ">DISP2"
menu[6]["value"] = {"SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Acres", "AcftHdg", "Speed"}
menu[6]["set"] = 8

menu[7] = {}
menu[7]["name"] = ">DISP3"
menu[7]["value"] = {"SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Acres", "AcftHdg", "Speed"}
menu[7]["set"] = 7

menu[8] = {}
menu[8]["name"] = ">DISP4"
menu[8]["value"] = {"SwthNum", "X-Track", "Blank", "GPS Alt", "NumSats", "HDOP", "A/B Hdg", "Time", "Dst2Mrk", "Acres", "AcftHdg", "Speed"}
menu[8]["set"] = 2

menu[9] = {}
menu[9]["name"] = ">LBAR"
menu[9]["value"] = {"SENS 2"}
menu[9]["set"] = 1

menu[10] = {}
menu[10]["name"] = ">UNITS"
menu[10]["value"] = {"FEET", "METERS"}
menu[10]["set"] = 1

menu[11] = {}
menu[11]["name"] = ">SETFAC"
menu[11]["value"] = {"DEFAULTS"}
menu[11]["set"] = 1

menu[12] = {}
menu[12]["name"] = "DEFSNOT"
menu[12]["value"] = {"RESET"}
menu[12]["set"] = 1


local ledtrkL = {}
local ledtrkR = {}
for i=0, 21 do
	ledtrkL[i] = ""
	ledtrkR[i] = ""
	for j=1, i do
		ledtrkL[i] = ledtrkL[i] .. "*"
		ledtrkR[i] = ledtrkR[i] .. ","
	end
end
	
local senstable = {}
senstable[1] = {1,2,3,4,8,16,32,83,133,183,233,283,333,383,433,483,533,583,633,683,733}
senstable[2] = {2,4,6,8,16,32,64,166,266,366,466,566,666,766,866,966,1066,1166,1266,1366,1466}
senstable[3] = {3,6,9,12,24,48,96,250,400,550,700,850,1000,1150,1300,1450,1600,1750,1900,2050,2200}
senstable[4] = {4,8,12,16,32,64,128,333,533,733,933,1133,1333,1533,1733,1933,2133,2333,2533,2733,2933}
senstable[5] = {5,10,15,20,40,80,160,416,666,916,1166,1416,1666,1916,2166,2416,2666,2916,3166,3416,3666}
senstable[6] = {6,12,18,24,48,96,192,500,800,1100,1400,1700,2000,2300,2600,2900,3200,3500,3800,4100,4400}
senstable[7] = {7,14,21,28,56,112,224,583,933,1283,1633,1983,2333,2683,3033,3383,3733,4083,4483,4783,5133}
senstable[8] = {8,16,24,32,64,128,256,666,1066,1466,1866,2266,2666,3066,3466,3866,4266,4666,5066,5466,5866}
senstable[9] = {9,18,27,36,72,144,288,750,1200,1650,2100,2550,3000,3450,3900,4350,4800,5250,5700,6150,6600}
senstable[10] = {60,120,180,240,480,960,1920,5000,8000,11000,14000,17000,20000,23000,26000,29000,32000,35000,38000,41000,44000}

local old_job = {}
old_job["set1"] = menu[1]["set"]
old_job["set2"] = menu[2]["set"]
old_job["set3"] = menu[3]["set"]
old_job["set4"] = menu[4]["set"]
old_job["set5"] = menu[5]["set"]
old_job["set6"] = menu[6]["set"]
old_job["set7"] = menu[7]["set"]
old_job["set8"] = menu[8]["set"]
old_job["set9"] = menu[9]["set"]
old_job["set10"] = menu[10]["set"]
old_job["set11"] = menu[11]["set"]
old_job["set12"] = menu[12]["set"]
old_job["pointAlat"] = 0
old_job["pointAlon"] = 0
old_job["pointBlat"] = 0
old_job["pointBlon"] = 0
old_job["pointMrklat"] = 0
old_job["pointMrklon"] = 0
old_job["swath_width"] = 50
old_job["swath_num"] = 0
old_job["sens"] = 2
old_job["acres"] = 0
old_job["brt_knob"] = 0.8
old_job["brt_control"] = 101
old_job["spayed_swath"] = {}

function brt_knob_handler()
	old_job["brt_knob"] = brt_knob
	if brt_control == 101 then
		brt = brt_knob
	end
end

lat = find_dataref("sim/flightmodel/position/latitude")
lon = find_dataref("sim/flightmodel/position/longitude")
spd_dr = find_dataref("sim/flightmodel/position/groundspeed")
crs = find_dataref("sim/flightmodel/position/true_psi")
brt = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[4]")
alt_dr = find_dataref("sim/flightmodel/position/elevation")
spray = find_dataref("custom/dromader/spray/spray","number")
hours = find_dataref("sim/cockpit2/clock_timer/local_time_hours")
minutes = find_dataref("sim/cockpit2/clock_timer/local_time_minutes")

fuse = create_dataref("custom/dromader/litestar/fuse","number", dummy)
power_sw = create_dataref("custom/dromader/litestar/power_sw","number", dummy)
power = create_dataref("custom/dromader/litestar/power","number", dummy)
brt_knob = create_dataref("custom/dromader/litestar/brt_knob","number", brt_knob_handler)
-- xtksense = create_dataref("custom/dromader/litestar/xtksense","number", dummy)
-- swath_num = create_dataref("custom/dromader/litestar/swath_num","number", dummy)
-- swath_dir = create_dataref("custom/dromader/litestar/swath_dir","number", dummy)
-- swath_width_m = create_dataref("custom/dromader/litestar/swath_width_m","number", dummy)
--area = create_dataref("custom/dromader/litestar/area","number", dummy)
--dtk = create_dataref("custom/dromader/litestar/gps_dtk","number", dummy)


local filename = "Output/preferences/LiteStarIV.cfg"

local file = io.open(filename, "a+")
	while true do
		local line = file:read("*line")
		if line == nil then break end
		
		k,v = line:match('^([^=]+)=(.+)$')
		if k:sub(1, 1) ~= "#" and k:sub(1, 12) ~= "spayed_swath" then 
			old_job[k] = tonumber(v)
		elseif k:sub(1, 12) == "spayed_swath" then
			old_job["spayed_swath"][tonumber(k:sub(13))] = tonumber(v)
		end
	end
file:close()




local R = 6371008.7714

function calculate_point(lat1, lon1, dir, dist)
	
	local latA = math.rad(lat1)
	local lonA = math.rad(lon1)

	local latB = math.asin( math.sin(latA) * math.cos( dist / R ) + math.cos( latA ) * math.sin( dist / R ) * math.cos( math.rad(dir) ) )
	local lonB = lonA + math.atan2(math.sin( math.rad(dir) ) * math.sin( dist / R ) * math.cos( latA ), math.cos( dist / R ) - math.sin( latA ) * math.sin( latB )) 

	return math.deg(latB), math.deg(lonB)
end

function cmd_swath_adv(phase, duration)
	if phase == 0 and power == 1 then
		if mode == 3 then
			points["Mrk"]["lat"] = temp_mrk_lat
			points["Mrk"]["lon"] = temp_mrk_lon
			old_job["pointMrklat"] = points["Mrk"]["lat"]
			old_job["pointMrklon"] = points["Mrk"]["lon"]
			mode = 0
		elseif mode == 2 then
			mode = 0
		elseif mode == 4 then
			mode = 2
		elseif mode == 0 and guide == 1 then
			if swath_num == 99 then return end
			local dir = 0
			
			
			if menu[3]["set"] == 1 then
				if swath_num%2 == 0 then
				dir = dtk - 90
				else
				dir = dtk + 90
				end
			else
				if swath_num%2 == 0 then
				dir = dtk + 90
				else
				dir = dtk - 90
				end			
			end
			
			if dir > 360 then dir = dir - 360 end
			if dir < 0 then dir = dir + 360 end
			
			swath_num = math.min(99,swath_num + 1)
			old_job["swath_num"] = swath_num
			local lat1, lon1 = calculate_point(points["A"]["lat"], points["A"]["lon"], dir, swath_width_m)
			
			points["A"]["lat"], points["A"]["lon"] = calculate_point(points["B"]["lat"], points["B"]["lon"], dir, swath_width_m)
			
			points["B"]["lat"] = lat1
			points["B"]["lon"] = lon1
			
			old_job["pointAlat"] = points["A"]["lat"]
			old_job["pointAlon"] = points["A"]["lon"]
			old_job["pointBlat"] = points["B"]["lat"]
			old_job["pointBlon"] = points["B"]["lon"]	
			
			dtk = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
		elseif mode == 0 and guide == 0 then
			if points["A"]["lat"] == 0 and points["A"]["lon"] == 0 then 
				points["A"]["lat"] = lat
				points["A"]["lon"] = lon
				old_job["pointAlat"] = points["A"]["lat"]
				old_job["pointAlon"] = points["A"]["lon"]
			elseif  points["B"]["lat"] == 0 and points["B"]["lon"] == 0 then 
				points["B"]["lat"] = lat
				points["B"]["lon"] = lon
				old_job["pointBlat"] = points["B"]["lat"]
				old_job["pointBlon"] = points["B"]["lon"]
				dtk = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
				guide = 1
			end		
		end
	end
end

cmdswathadv = create_command("custom/dromader/litestar/but_swath_adv","Swath Advance",cmd_swath_adv)

function cmd_swath_dec(phase, duration)
	if phase == 0 and power == 1 then
		if mode == 3 then
			temp_mrk_lat = 0
			temp_mrk_lon = 0
			mode = 0
		elseif mode == 4 then
			mode = 0
		elseif mode == 0 and  guide == 1 then
			if swath_num == 0 then return end
			local dir = 0
			
			if menu[3]["set"] == 1 then
				if swath_num%2 == 0 then
				dir = dtk + 90
				else
				dir = dtk - 90
				end
			else
				if swath_num%2 == 0 then
				dir = dtk - 90
				else
				dir = dtk + 90
				end			
			end
			
			if dir > 360 then dir = dir - 360 end
			if dir < 0 then dir = dir + 360 end
			
			swath_num = math.max(0,swath_num - 1)
			old_job["swath_num"] = swath_num
			
			local lat1, lon1 = calculate_point(points["A"]["lat"], points["A"]["lon"], dir, swath_width_m)
			
			points["A"]["lat"], points["A"]["lon"] = calculate_point(points["B"]["lat"], points["B"]["lon"], dir, swath_width_m)
			
			points["B"]["lat"] = lat1
			points["B"]["lon"] = lon1
			
			old_job["pointAlat"] = points["A"]["lat"]
			old_job["pointAlon"] = points["A"]["lon"]
			old_job["pointBlat"] = points["B"]["lat"]
			old_job["pointBlon"] = points["B"]["lon"]	
			
			dtk = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
		end
	end
end

cmdswathdec = create_command("custom/dromader/litestar/but_swath_dec","Swath Decrement",cmd_swath_dec)

function cmd_set_mark(phase, duration)
	if phase == 0 and power == 1 then
		if in_menu == 0 then
			temp_mrk_lat = lat
			temp_mrk_lon = lon
			mode = 3
		end
	end
end

cmdsetmark = create_command("custom/dromader/litestar/but_set_mark","Set Mark",cmd_set_mark)

function cmd_toggle_fuse(phase, duration)
	if phase == 0 then
		if fuse == 1 then
			fuse = 0
			power = 0
		else
			fuse = 1
			if power_sw == 1 then
				power = 1
			end
		end
	end
end

cmdtogglefuse = create_command("custom/dromader/litestar/toggle_fuse","Toggle fuse",cmd_toggle_fuse)

function cmd_toggle_power(phase, duration)
	if phase == 0 then
		if power_sw == 1 then
			power_sw = 0
			power = 0
		else
			power_sw = 1
			if fuse == 1 then
				power = 1
			end
		end
	end
end

cmdtogglepower = create_command("custom/dromader/litestar/toggle_power","Toggle power",cmd_toggle_power)

function cmd_but_menu(phase, duration)
	if phase == 0 and power == 1 then
			if mode == 2 then
				mode = 0
				return
			end
			
			if points["Mrk"]["lat"] ~= 0 and mode == 0 then -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto
				mode = 4
			else 
				mode = 1
			end
			
			if mode == 1 then
				in_menu = in_menu + 1
				if in_menu > #menu then 
					in_menu = 1 
				end
				if menu[1]["set"] == 2 then
					if menu[in_menu]["name"] == ">SWIDTH" then
						in_menu = in_menu + 2
					end
				end
			end

	end
end

cmdbutmenu = create_command("custom/dromader/litestar/but_menu","Menu",cmd_but_menu)

function cmd_but_ent(phase, duration)
	if phase == 0 and power == 1 then

		if in_menu > 0 then
			if menu[1]["set"] == 1 then	
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0
				old_job["set1"] = menu[1]["set"]
				old_job["set2"] = menu[2]["set"]
				old_job["set3"] = menu[3]["set"]
				old_job["set4"] = menu[4]["set"]
				old_job["set5"] = menu[5]["set"]
				old_job["set6"] = menu[6]["set"]
				old_job["set7"] = menu[7]["set"]
				old_job["set8"] = menu[8]["set"]
				old_job["set9"] = menu[9]["set"]
				old_job["set10"] = menu[10]["set"]
				old_job["set11"] = menu[11]["set"]
				old_job["set12"] = menu[12]["set"]
				old_job["swath_width"] = swath_width_dis
				old_job["sens"] = xtksense	
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				area = 0
				guide = 0
				swath_num = 0
			elseif menu[1]["set"] == 2 then
				old_job["set1"] = menu[1]["set"]
				old_job["set2"] = menu[2]["set"]
				old_job["set3"] = menu[3]["set"]
				old_job["set4"] = menu[4]["set"]
				old_job["set5"] = menu[5]["set"]
				old_job["set6"] = menu[6]["set"]
				old_job["set7"] = menu[7]["set"]
				old_job["set8"] = menu[8]["set"]
				old_job["set9"] = menu[9]["set"]
				old_job["set10"] = menu[10]["set"]
				old_job["set11"] = menu[11]["set"]
				old_job["set12"] = menu[12]["set"]
				old_job["sens"] = xtksense
				old_job["brt_control"] = brt_control
				if 	points["A"]["lat"] ~= 0 and points["B"]["lat"] ~= 0 then
					dtk = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
					guide = 1
				else
					area = 0
					guide = 0				
				end
			end
			if menu[in_menu]["name"] == "DEFSNOT" then	
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0	
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0	
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				in_menu = 1
				mode = 1
				area = 0
				guide = 0
				swath_num = 0
				return
			elseif menu[in_menu]["name"] == ">SETFAC" then	
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0	
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0	
				in_menu = 1
				mode = 1
				area = 0
				swath_num = 0
				menu[1]["set"] = 1
				menu[2]["set"] = 1
				menu[3]["set"] = 1
				menu[4]["set"] = 1
				menu[5]["set"] = 1
				menu[6]["set"] = 9
				menu[7]["set"] = 8
				menu[8]["set"] = 2
				menu[9]["set"] = 1
				menu[10]["set"] = 1
				menu[11]["set"] = 1
				menu[12]["set"] = 1
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				xtksense = 2
				menu[9]["value"] = {"SENS 2"}
				menu[2]["value"] = {"50.0"}
				swath_width_dis = 50
				guide = 0
				return
			end
			in_menu = 0
			mode = 0
			if menu[10]["set"] == 1 then
				swath_width_m = feet2met(swath_width_dis, 5)
			else
				swath_width_m = swath_width_dis
			end
		end
	end
end

cmdbutent = create_command("custom/dromader/litestar/but_ent","Enter",cmd_but_ent)

function cmd_but_up(phase, duration)
	if phase == 0 and power == 1 then
		if in_menu > 0 then
			if menu[in_menu]["name"] == ">SWIDTH" then
				local t = function () if menu[10]["set"] == 1 then return 300 end return 100 end
				swath_width_dis = math.min(t(), swath_width_dis+0.1)
				menu[in_menu]["value"][1] = string.format("%.1f", swath_width_dis)

			elseif menu[in_menu]["name"] == ">DIM" then
				
				brt_control = math.min(101, brt_control+1)
				old_job["brt_control"] = brt_control
				if brt_control == 101 then
					brt = brt_knob
					menu[in_menu]["value"][1] = "USEKNOB"
				else
					brt = brt_control/100
					menu[in_menu]["value"][1] = string.format("%d%%", brt_control)
				end
			elseif menu[in_menu]["name"] == ">LBAR" then
				xtksense = math.min(10, xtksense+1)
				menu[in_menu]["value"][1] = string.format("SENS %d", xtksense)
			else
				local prev = menu[in_menu]["set"]
				menu[in_menu]["set"] = math.min(#menu[in_menu]["value"], menu[in_menu]["set"]+1)
				if menu[in_menu]["name"] == ">UNITS" and prev ~= menu[in_menu]["set"] then
					if menu[in_menu]["set"] == 1 then
						swath_width_dis = math.max(6,math.min(300, met2feet(swath_width_dis, 1)))
						menu[2]["value"][1] = string.format("%.1f", swath_width_dis)
					else
						swath_width_dis = math.max(2,math.min(100, feet2met(swath_width_dis, 1)))
						menu[2]["value"][1] = string.format("%.1f", swath_width_dis)						
					end
				end
			end
		end
		
	end
end



function cmd_but_dn(phase, duration)
	if phase == 0 and power == 1 then
		if in_menu > 0 then
			if menu[in_menu]["name"] == ">SWIDTH" then
				local t = function () if menu[10]["set"] == 1 then return 6 end return 2 end
				swath_width_dis = math.max(t(), swath_width_dis-0.1)
				menu[in_menu]["value"][1] = string.format("%.1f", swath_width_dis)
			elseif menu[in_menu]["name"] == ">DIM" then
				brt_control = math.max(1, brt_control-1)
				old_job["brt_control"] = brt_control
					brt = brt_control/100
					menu[in_menu]["value"][1] = string.format("%d%%", brt_control)
			elseif menu[in_menu]["name"] == ">LBAR" then
				xtksense = math.max(1, xtksense-1)
				menu[in_menu]["value"][1] = string.format("SENS %d", xtksense)
			else
				local prev = menu[in_menu]["set"]
				menu[in_menu]["set"] = math.max(1, menu[in_menu]["set"]-1)
				if menu[in_menu]["name"] == ">UNITS" and prev ~= menu[in_menu]["set"] then
					if menu[in_menu]["set"] == 1 then
						swath_width_dis = math.max(6,math.min(300, met2feet(swath_width_dis, 1)))
						menu[2]["value"][1] = string.format("%.1f", swath_width_dis)
					else
						swath_width_dis = math.max(2,math.min(100, feet2met(swath_width_dis, 1)))
						menu[2]["value"][1] = string.format("%.1f", swath_width_dis)						
					end
				end
			end
		end
	end
end

cmdbutdn = create_command("custom/dromader/litestar/but_dn","Down",cmd_but_dn)
cmdbutup = create_command("custom/dromader/litestar/but_up","Up",cmd_but_up)

function spray_toggle_after_cmd(phase, duration)
	if phase == 0 and power == 1 then
		if points["A"]["lat"] == 0 and points["A"]["lon"] == 0 then 
			points["A"]["lat"] = lat
			points["A"]["lon"] = lon
			old_job["pointAlat"] = points["A"]["lat"]
			old_job["pointAlon"] = points["A"]["lon"]

		elseif  points["B"]["lat"] == 0 and points["B"]["lon"] == 0 then 
			points["B"]["lat"] = lat
			points["B"]["lon"] = lon
			old_job["pointBlat"] = points["B"]["lat"]
			old_job["pointBlon"] = points["B"]["lon"]	
			
		dtk = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
		guide = 1
		end
	end
end

spraytogwrapcmd = wrap_command("custom/dromader/spray/spray_tog_cmd",dummy, spray_toggle_after_cmd)

-- function spray_after_cmd(phase, duration)
	-- if phase == 0 then
		-- if points["A"]["lat"] == 0 and points["A"]["lon"] == 0 then 
			-- points["A"]["lat"] = lat
			-- points["A"]["lon"] = lon
		-- end
	-- elseif phase == 2 then
		-- if  points["B"]["lat"] == 0 and points["B"]["lon"] == 0 then 
			-- points["B"]["lat"] = lat
			-- points["B"]["lon"] = lon
		-- end
	-- end
-- end

-- spraywrapcmd = wrap_command("custom/dromader/spray/spray_cmd",dummy, spray_after_cmd)

str_disL = create_dataref("custom/dromader/litestar/disp_L","string")
str_disR = create_dataref("custom/dromader/litestar/disp_R","string")
str_trkL = create_dataref("custom/dromader/litestar/trk_L","string")
str_trkR = create_dataref("custom/dromader/litestar/trk_R","string")
str_hdgL = create_dataref("custom/dromader/litestar/hdg_L","string")
str_hdgR = create_dataref("custom/dromader/litestar/hdg_R","string")
str_ontrk = create_dataref("custom/dromader/litestar/on_trk","string")
str_stat = create_dataref("custom/dromader/litestar/stat","string")
str_disL = ""--"---A123"
str_disR = ""--"123----"
str_trkL = ""--"*********************"
str_trkR = ""--",,,,,,,,,,,,,,,,,,,,,"
str_hdgL = ""--"******************"
str_hdgR = ""--",,,,,,,,,,,,,,,,,,"
local ontrk = "` ` `"
str_ontrk = ""--ontrk
str_stat = ""--"<`*"

str_dis1 = "    "
str_dis2 = "   "
str_dis3 = "   "
str_dis4 = "    "


function distance(lat1, lon1, lat2, lon2)

	local latA = math.rad(lat1)
	local latB = math.rad(lat2)
	local dlat = math.rad(lat2 - lat1)
	local dlon = math.rad(lon2 - lon1)
	
	local a = math.sin(dlat/2)*math.sin(dlat/2) + math.cos(latA)*math.cos(latB)*math.sin(dlon/2)*math.sin(dlon/2)
	local c = 2*math.atan2(math.sqrt(a), math.sqrt(1-a))
	
	return R*c
	
end

function course(lat1, lon1, lat2, lon2)

	local latA = math.rad(lat1)
	local lonA = math.rad(lon1)
	local latB = math.rad(lat2)
	local lonB = math.rad(lon2)

	local y = math.sin(lonB-lonA) * math.cos(latB)
	local x = math.cos(latA)*math.sin(latB) - math.sin(latA)*math.cos(latB)*math.cos(lonB-lonA) 
	local a = math.atan2(y, x) 
	
	return (math.deg(a) + 360) % 360 --in degrees
end

function crosstrack(lat_cur, lon_cur, latA, lonA, dcourse)

	local dis = distance( latA, lonA, lat_cur, lon_cur)/R
	local bearA = math.rad( course( latA, lonA, lat_cur, lon_cur) )
	local bearB = math.rad( dcourse )
	
	return math.asin( math.sin( dis) * math.sin( bearA - bearB ) )*R
end

function round2(num, numDecimalPlaces)
    return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function round(num)
	if num > 0 then
	    return math.floor(num + 0.5)
	elseif num < 0 then
		return math.ceil(num + (-0.5))
	end
		return num
end

function met2feet(met, prec)
	return round2(met*3.2808399, prec or 0)
end

function feet2met(feet, prec)
	return round2(feet/3.2808399, prec or 0)
end

function msec2kph(msec, prec)
	return round2(msec*3.6, prec or 0)
end

function msec2mph(msec, prec)
	return round2(msec*2.23693629, prec or 0)
end

function hect2acre(hect, prec)
	return round2(hect*2.47105381, prec or 0)
end

function km2mile(km, prec)
	return round2(km*0.621371192, prec or 0)
end

function flight_start()
	brt_knob = old_job["brt_knob"]
	brt_control = old_job["brt_control"]
	if brt_control == 101 then
		brt = brt_knob
	else
		brt = brt_control/100
	end
	xtksense = old_job["sens"]
	menu[9]["value"][1] = string.format("SENS %d", xtksense)
	swath_width_dis = old_job["swath_width"] 
	menu[2]["value"][1] = string.format("%.1f", swath_width_dis)
	
	menu[1]["set"] = old_job["set1"] 
	menu[2]["set"] = old_job["set2"]
	menu[3]["set"] = old_job["set3"]
	menu[4]["set"] = old_job["set4"]
	menu[5]["set"] = old_job["set5"]
	menu[6]["set"] = old_job["set6"]
	menu[7]["set"] = old_job["set7"]
	menu[8]["set"] = old_job["set8"]
	menu[9]["set"] = old_job["set9"]
	menu[10]["set"] = old_job["set10"]
	menu[11]["set"] = old_job["set11"]
	menu[12]["set"] = old_job["set12"]
	points["A"]["lat"] = old_job["pointAlat"]
	points["A"]["lon"] = old_job["pointAlon"]
	points["B"]["lat"] = old_job["pointBlat"]
	points["B"]["lon"] = old_job["pointBlon"]
	points["Mrk"]["lat"] = old_job["pointMrklat"]
	points["Mrk"]["lon"] = old_job["pointMrklon"]

	swath_num = old_job["swath_num"]
	xtksense = old_job["sens"]
	area = old_job["acres"]
	
	fuse = 1
	power_sw = 1
	power = 1
	mode = 1
	in_menu = 1
	
end



function timer()
	if flash_timer == 1 then
		flash_timer = 0
	else 
		flash_timer = 1
	end
end

run_at_interval(timer,(1/4))

function after_physics()
	if power == 1 then
		if spray == 1 then 
			str_stat = "<"
			area = area + (msec2kph(spd_dr, 2)*swath_width_m/600)*SIM_PERIOD/60
			old_job["acres"] = area
		else
			str_stat = ""
		end
		
		if menu[10]["set"] == 1 then
			spd = math.min(999,msec2mph(spd_dr))
			area_disp = math.min(99.9,hect2acre(area, 2))
			alt = math.min(9999,met2feet(alt_dr))
		else
			area_disp = math.min(99.9,area)
			spd = math.min(999,msec2kph(spd_dr))
			alt = math.min(9999, round2(alt_dr))
		end
		
		
		gps_crs = round2(course ( points["LastLoc"]["lat"], points["LastLoc"]["lon"], lat, lon))
		
		points["LastLoc"]["lat"] = lat
		points["LastLoc"]["lon"] = lon
		

			str_hdgL = ""
			str_hdgR = ""
			str_trkL = ""
			str_trkR = ""
			str_ontrk =""
			if mode == 0 then -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto
				if guide == 1 then 
					
					if menu[10]["set"] == 1 then
						xtk = met2feet(crosstrack( points["LastLoc"]["lat"], points["LastLoc"]["lon"], points["A"]["lat"], points["A"]["lon"], dtk) )
					else
						xtk = round2(crosstrack( points["LastLoc"]["lat"], points["LastLoc"]["lon"], points["A"]["lat"], points["A"]["lon"], dtk) )
					end
					
					
					local diff = gps_crs - dtk
					
					if diff < -180 then 
						diff = diff + 360
					elseif diff > 180 then 
						diff = diff - 360 
					end
					
					if diff > 0 then 
						diff = math.floor(math.min(diff/5, 18) )
						str_hdgR = ledtrkR[diff]	
					elseif diff < 0 then
						diff = math.floor(math.min(math.abs(diff/5), 18) )
						str_hdgL = ledtrkL[diff]	
					end
					
					local letter = " "
					if xtk > 0 then
						letter = "L"
					elseif xtk < 0 then
						letter = "R"
					end

					if xtk > 0 then
						for k,v in ipairs(senstable[xtksense]) do
							if xtk < v then
								str_trkL = 	ledtrkL[k-1]
								if diff < 2 and diff> -2 and k < 3 then
									str_ontrk = ontrk
								else
									str_ontrk = ""
								end
								break
							else
								str_trkL = 	ledtrkL[k-1]
							end
						end
						xtk = math.min(xtk, 999)
					else
						xtk = math.abs(xtk)
						for k,v in ipairs(senstable[xtksense]) do
							if xtk < v then
								str_trkR = 	ledtrkR[k-1]
								if diff < 2 and diff> -2 and k < 3 then
									str_ontrk = ontrk
								else
									str_ontrk = ""
								end
								break
							else
								str_trkR = 	ledtrkR[k-1]
							end
						end
						xtk = math.min(xtk, 999)
					end
					
					if str_ontrk == ontrk and spray == 1 and old_job["spayed_swath"][swath_num] == nil then
						old_job["spayed_swath"][swath_num] = 0
					elseif str_ontrk == ontrk and spray == 0 and old_job["spayed_swath"][swath_num] == 0 then
						old_job["spayed_swath"][swath_num] = 1
					elseif str_ontrk == ontrk and spray == 1 and old_job["spayed_swath"][swath_num] == 1 then
							if flash_timer == 1 then
								str_trkL = "*********************"
								str_trkR = ",,,,,,,,,,,,,,,,,,,,,"
							else
								str_trkL = ""
								str_trkR = ""							
							end							
					end
				-- "SwthNum", "X-Track", "Blank", "GPS Alt", "NumSats", "HDOP", "A/B Hdg", "Time", "Dst2Mrk", "Acres", "AcftHdg", "Speed"
				-- "SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Acres", "AcftHdg", "Speed"	
				
				if menu[5]["set"] == 1 then
					local dir = "L"
					if menu[3]["set"] == 2 then
						dir = "R"
					end			
					str_dis1 = string.format("%s%d", dir, swath_num)
				elseif menu[5]["set"] == 2 then
					str_dis1 = string.format("%s%d", letter, xtk)
				elseif menu[5]["set"] == 3 then
					str_dis1 = string.format("    ")
				elseif menu[5]["set"] == 4 then
					str_dis1 = string.format("%4d", alt)
				elseif menu[5]["set"] == 5 then
					str_dis1 = string.format("%2d", numsats)
				elseif menu[5]["set"] == 6 then
					str_dis1 = string.format("%2.1f", hdop)
				elseif menu[5]["set"] == 7 then
					str_dis1 = string.format("%3d", dtk)
				elseif menu[5]["set"] == 8 then
					str_dis1 = string.format("%2.2d%2.2d", hours, minutes)
				elseif menu[5]["set"] == 9 then
					local dist = 0
					if points["Mrk"]["lat"] ~= 0 then
						dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
						if menu[10]["set"] == 1 then
							dist = km2mile(dist)
						end
					end
					str_dis1 = string.format("%4d", math.min(9999, dist))
				elseif menu[5]["set"] == 10 then
					str_dis1 = string.format("%2.1f", area_disp)
				elseif menu[5]["set"] == 11 then
					str_dis1 = string.format("%3d", gps_crs)
				elseif menu[5]["set"] == 12 then
					str_dis1 = string.format("%3d", spd)
				end
				
				if menu[6]["set"] == 1 then
					local dir = "L"
					if menu[3]["set"] == 2 then
						dir = "R"
					end
					str_dis2 = string.format("%s%d", dir, swath_num)
				elseif menu[6]["set"] == 2 then
					str_dis2 = string.format("    ")
				elseif menu[6]["set"] == 3 then
					str_dis2 = string.format("%2d", numsats)
				elseif menu[6]["set"] == 4 then
					str_dis2 = string.format("%2.1f", hdop)
				elseif menu[6]["set"] == 5 then
					str_dis2 = string.format("%3d", dtk)
				elseif menu[6]["set"] == 6 then
					str_dis2 = string.format("%2.1f", area_disp)
				elseif menu[6]["set"] == 7 then
					str_dis2 = string.format("%3d", gps_crs)
				elseif menu[6]["set"] == 8 then
					str_dis2 = string.format("%3d", spd)
				end
					
				if menu[7]["set"] == 1 then
					local dir = "L"
					if menu[3]["set"] == 2 then
						dir = "R"
					end
					str_dis3 = string.format("%s%d", dir, swath_num)
				elseif menu[7]["set"] == 2 then
					str_dis3 = string.format("    ")
				elseif menu[7]["set"] == 3 then
					str_dis3 = string.format("%2d", numsats)
				elseif menu[7]["set"] == 4 then
					str_dis3 = string.format("%2.1f", hdop)
				elseif menu[7]["set"] == 5 then
					str_dis3 = string.format("%3d", dtk)
				elseif menu[7]["set"] == 6 then
					str_dis3 = string.format("%2.1f", area_disp)
				elseif menu[7]["set"] == 7 then
					str_dis3 = string.format("%3d", gps_crs)
				elseif menu[7]["set"] == 8 then
					str_dis3 = string.format("%3d", spd)
					end
										
					if menu[8]["set"] == 1 then
						local dir = "L"
						if menu[3]["set"] == 2 then
							dir = "R"
						end
						str_dis4 = string.format("%s%d", dir, swath_num)
					elseif menu[8]["set"] == 2 then
						str_dis4 = string.format("%s%d", letter, xtk)
					elseif menu[8]["set"] == 3 then
						str_dis4 = string.format("    ")
					elseif menu[8]["set"] == 4 then
						str_dis4 = string.format("%4d", alt)
					elseif menu[8]["set"] == 5 then
						str_dis4 = string.format("%2d", numsats)
					elseif menu[8]["set"] == 6 then
						str_dis4 = string.format("%2.1f", hdop)
					elseif menu[8]["set"] == 7 then
						str_dis4 = string.format("%3d", dtk)
					elseif menu[8]["set"] == 8 then
						str_dis4 = string.format("%2.2d%2.2d", hours, minutes)
					elseif menu[8]["set"] == 9 then
						local dist = 0
						if points["Mrk"]["lat"] ~= 0 then
							dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
							if menu[10]["set"] == 1 then
								dist = km2mile(dist)
							end
						end
						str_dis4 = string.format("%4d", math.min(9999, dist))
					elseif menu[8]["set"] == 10 then
						str_dis4 = string.format("%2.1f", area_disp)
					elseif menu[8]["set"] == 11 then
						str_dis4 = string.format("%3d", gps_crs)
					elseif menu[8]["set"] == 12 then
						str_dis4 = string.format("%3d", spd)
					end			
					
					str_disL = string.format("%-4.4s%3.3s", str_dis1, str_dis2)	
					str_disR = string.format("%-3.3s%4.4s", str_dis3, str_dis4)	
					
				else
						local point = "A"
						if points["A"]["lat"] ~= 0 and points["A"]["lon"] ~= 0 then
							point = "B"
							str_ontrk = ontrk
							if flash_timer == 1 then
								str_trkL = "*********************"
								str_trkR = ",,,,,,,,,,,,,,,,,,,,,"
								if old_job["spayed_swath"][swath_num] == nil and spray == 1 then
									old_job["spayed_swath"][swath_num] = 0
								end
							end
						end
						str_dis1 = string.format("---%s", point)
						str_dis2 = string.format("%3d", spd)
						str_dis3 = string.format("%3d", gps_crs)
						str_dis4 = "----"
						
					str_disL = string.format("%-4.4s%3.3s", str_dis1, str_dis2)	
					str_disR = string.format("%-3.3s%4.4s", str_dis3, str_dis4)	
				end
			elseif mode == 1 then
				str_disL = string.format("%-7.7s", menu[in_menu]["name"])	
				str_disR = string.format("%-7.7s", menu[in_menu]["value"][ menu[in_menu]["set"] or 1])	
			elseif mode == 2 then
				local dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
				if menu[10]["set"] == 1 then
					dist = km2mile(dist)
				end

				local bearing = course ( points["LastLoc"]["lat"], points["LastLoc"]["lon"], points["Mrk"]["lat"], points["Mrk"]["lon"])
				local diff = gps_crs - bearing

				
				if diff < -180 then 
					diff = diff + 360
				elseif diff > 180 then 
					diff = diff - 360 
				end
				
				if diff > 0 then 
					diff = round2(math.min(diff/5, 18) )
					str_hdgL = ledtrkL[diff]	
				elseif diff < 0 then
					diff = round2(math.min(math.abs(diff/5), 18) )
					str_hdgR = ledtrkR[diff]	
				end

				str_dis1 = string.format("%3d", bearing)
				str_dis2 = string.format("%3d", spd)
				str_dis3 = string.format("%3d", gps_crs)
				str_dis4 = string.format("%3d", math.min(9999, dist))
				
				str_disL = string.format("%-4.4s%3.3s", str_dis1, str_dis2)	
				str_disR = string.format("%-3.3s%4.4s", str_dis3, str_dis4)				
			elseif mode == 3 then
				str_disL = string.format("%-7.7s", ">SET")	
				str_disR = string.format("%-7.7s", "MARK")	
			elseif mode == 4 then 
				str_disL = string.format("%-7.7s", ">  =|")	
				str_disR = string.format("%-7.7s", "TO MARK")	
			end
	end
end

function aircraft_unload()
	local file = io.open(filename, "w")
	local table_index = 0
	for k,v in pairs(old_job) do
		if type(v) ~= "table" then
			file:write(k .. "=" .. v .. "\n" )
		else
			table_index = k
		end
	end
	for k,v in pairs(old_job[table_index]) do
			file:write(table_index .. k .. "=" .. v .. "\n" )
	end
	
	file:close()
end