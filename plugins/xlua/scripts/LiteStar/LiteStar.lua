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
local gps_crs = 0
local guide = 0
local brt_control = 101
local spd = 0
local alt = 0
local numsats = 12 --const not simulated
local mode = 0 -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto, 5 scroll GPS menu, 6 starup, 7 export
local xtksense = 0
local swath_num = 1
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
menu[1]["value"] = {"NEW JOB", "OLD JOB", "EXPORT"}
menu[1]["set"] = 1

menu[2] = {}
menu[2]["name"] = ">SWIDTH"
menu[2]["value"] = {"50.0"}
menu[2]["set"] = 1

menu[3] = {}
menu[3]["name"] = ">PATRN"
menu[3]["value"] = {"BK_BK L", "Expand", "Squeeze", "RV_TRK", "QK_RTRK", "RC_TRK", "BK_BK R" }
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
menu[6]["value"] = {"SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Time", "Acres", "AcftHdg", "Speed"}
menu[6]["set"] = 8

menu[7] = {}
menu[7]["name"] = ">DISP3"
menu[7]["value"] = {"SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Time", "Acres", "AcftHdg", "Speed"}
menu[7]["set"] = 7

menu[8] = {}
menu[8]["name"] = ">DISP4"
menu[8]["value"] = {"SwthNum", "X-Track", "Blank", "GPS Alt", "NumSats", "HDOP", "A/B Hdg", "Time", "Dst2Mrk", "Acres", "AcftHdg", "Speed"}
menu[8]["set"] = 2

menu[9] = {}
menu[9]["name"] = ">LBAR"
menu[9]["value"] = {"SENS 3"}
menu[9]["set"] = 1

menu[10] = {}
menu[10]["name"] = ">GPS"
menu[10]["value"] = {"MENU"}
menu[10]["submenu"] = {">Status", ">Sats", ">Sats", ">Diff", ">HDOP", ">", ">", ">Alt ft", ">Mph", ">Hdg", ">Date", ">Time" }
menu[10]["submenu"]["index"] = 1
menu[10]["set"] = 1

menu[11] = {}
menu[11]["name"] = ">UTC"
menu[11]["value"] = {"-12:00", "-11:00", "-10:00", "-9:00", "-8:00", "-7:00", "-6:00", "-5:00", "-4:00", "-3:00", "-2:00", "-1:00", "0:00", "+1:00", "+2:00", "+3:00", "+4:00", "+5:00", "+6:00", "+7:00", "+8:00", "+9:00", "+10:00", "+11:00", "+12:00", "+13:00", "+14:00"}
menu[11]["set"] = 13

menu[12] = {}
menu[12]["name"] = ">UNITS"
menu[12]["value"] = {"FEET", "METERS"}
menu[12]["set"] = 1

menu[13] = {}
menu[13]["name"] = ">DifTyp"
menu[13]["value"] = {"WAAS", "eDif"}
menu[13]["set"] = 1

menu[14] = {}
menu[14]["name"] = ">SBASR"
menu[14]["value"] = {"ON", "OFF"}
menu[14]["set"] = 1

menu[15] = {}
menu[15]["name"] = ">LS4LB"
menu[15]["value"] = {"3.001c"}
menu[15]["set"] = 1

menu[16] = {}
menu[16]["name"] = ">SETFAC"
menu[16]["value"] = {"DEFAULTS"}
menu[16]["set"] = 1

menu[17] = {}
menu[17]["name"] = "DEFSNOT"
menu[17]["value"] = {"RESET"}
menu[17]["set"] = 1

local R = 6371008.7714


local ledtrkL = {}
local ledtrkR = {}
for i=0, 21 do
	ledtrkL[i] = " "
	ledtrkR[i] = " "
	for j=1, i do
		ledtrkL[i] = ledtrkL[i] .. "*"
		ledtrkR[i] = ledtrkR[i] .. ","
	end
end


local swath_tbl = {}
local swath_sequence_tbl = {}
local track = {}

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
old_job["set13"] = menu[13]["set"]
old_job["set14"] = menu[14]["set"]
old_job["set15"] = menu[15]["set"]
old_job["set16"] = menu[16]["set"]
old_job["set17"] = menu[17]["set"]
old_job["pointAlat"] = 0
old_job["pointAlon"] = 0
old_job["pointBlat"] = 0
old_job["pointBlon"] = 0
old_job["pointClat"] = 0
old_job["pointClon"] = 0
old_job["pointMrklat"] = 0
old_job["pointMrklon"] = 0
old_job["swath_width"] = 50
old_job["swath_num"] = 0
old_job["sens"] = 3
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

hours_z = find_dataref("sim/cockpit2/clock_timer/zulu_time_hours")
minutes_z = find_dataref("sim/cockpit2/clock_timer/zulu_time_minutes")
seconds_z = find_dataref("sim/cockpit2/clock_timer/zulu_time_seconds")
day = find_dataref("sim/cockpit2/clock_timer/current_day")
month = find_dataref("sim/cockpit2/clock_timer/current_month")

water_quantity = find_dataref("sim/flightmodel/weight/m_jettison")

startup_running = find_dataref("sim/operation/prefs/startup_running")

fuse = create_dataref("custom/dromader/litestar/fuse","number", dummy)
power_sw = create_dataref("custom/dromader/litestar/power_sw","number", dummy)
power = create_dataref("custom/dromader/litestar/power","number", dummy)
brt_knob = create_dataref("custom/dromader/litestar/brt_knob","number", brt_knob_handler)



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

local startup_count = 1

function startup()
	if startup_count < 16 then
		str_disL = " "
		str_disR = " "				
		for i = 1,7 do
			if math.random() > 0.5 then
				str_disL = str_disL..string.char(math.random(65,90))
				str_disR = str_disR..string.char(math.random(48,57))
			else
				str_disL = str_disL..string.char(math.random(48,57))
				str_disR = str_disR..string.char(math.random(65,90))
			end
			
		end
	elseif startup_count > 32 then
		mode = 1
		in_menu = 1
		stop_timer(startup)
	else
		str_disL = "   LITE"
		str_disR = "STAR 4 "
	end
	startup_count = startup_count + 1
end

local export_count = 0

function export()
		if export_count <= 100 then
		if export_count%7 == 0 then
			if str_disL:sub(-1) == "(" then
				str_disL = str_disL:sub(1, -2 )
				str_disL = str_disL .. ")"
			else
				str_disL = str_disL .. "("
			end
		end
		str_disR = string.format("%6d%%", export_count)
		else
		str_disL = "Success"
		str_disR = "    8/8"			
			if export_count > 124 then
				export_count = 0
				mode = 1
				in_menu = 1
				menu[1]["set"] = 2
				stop_timer(export)
			end
		end
		export_count = export_count + 1
end

function calculate_point(lat1, lon1, dir, dist)

	local latA = math.rad(lat1)
	local lonA = math.rad(lon1)

	local latB = math.asin( math.sin(latA) * math.cos( dist / R ) + math.cos( latA ) * math.sin( dist / R ) * math.cos( math.rad(dir) ) )
	local lonB = lonA + math.atan2(math.sin( math.rad(dir) ) * math.sin( dist / R ) * math.cos( latA ), math.cos( dist / R ) - math.sin( latA ) * math.sin( latB ))

	return math.deg(latB), math.deg(lonB)
end

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

function ang_diff(angA, angB)
	return ((angA - angB) + 180) % 360 - 180
end

function reverse_course(course)
	return (course + 180) % 360
end

function clear_tbl(tbl)
	for k,v in pairs(tbl) do
		v = nil
	end
end

function pattern_BK_BK_R()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	points["C"]["lat"] = 0
	points["C"]["lon"] = 0
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	local dir = (course_ab + 90) % 360
	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = "R"}
	swath_sequence_tbl[1] = 1
	for i=2, 99 do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)
		swath_sequence_tbl[i] = i
	end
end

function pattern_BK_BK_L()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	points["C"]["lat"] = 0
	points["C"]["lon"] = 0
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	local dir = (course_ab - 90) % 360
	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = "L"}
	swath_sequence_tbl[1] = 1
	for i=2, 99 do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)
		swath_sequence_tbl[i] = i
	end
end

function pattern_RC_TRK()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	
	local course_ac = course ( points["A"]["lat"], points["A"]["lon"], points["C"]["lat"], points["C"]["lon"])
	local dir = 0
	local dcourse = ang_diff(course_ab, course_ac)
	local letter = "L"
	if dcourse > 0 then
		dir = (course_ab - 90) % 360
	else
		dir = (course_ab + 90) % 360
		letter = "R"
	end	
	

	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = letter}
	local abc_distance = math.abs(crosstrack( points["C"]["lat"], points["C"]["lon"], points["A"]["lat"], points["A"]["lon"], course_ab))
	
	local num_swaths = round2(math.abs(abc_distance/swath_width_m)) + 1
	if num_swaths > 999 then num_swaths = 999 end

	if abc_distance < swath_width_m*2 then points["C"]["lat"] = 0 points["C"]["lon"] = 0 guide = 0 return end
	for i=2, num_swaths do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)

	end
	
	local ind = 1
	swath_sequence_tbl[2] = num_swaths
	for k,v in pairs(swath_tbl) do
		if k%2 ~= 0 then
			swath_sequence_tbl[k] = ind
			ind = ind + 1
		end
	
	end
	for k,v in pairs(swath_tbl) do
		if k%2 == 0 and k ~= 2 then
			swath_sequence_tbl[k] = ind
			ind = ind + 1
		end
	
	end

end

function pattern_Squeeze()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	
	local course_ac = course ( points["A"]["lat"], points["A"]["lon"], points["C"]["lat"], points["C"]["lon"])
	local dir = 0
	local dcourse = ang_diff(course_ab, course_ac)
	local letter = "L"
	if dcourse > 0 then
		dir = (course_ab - 90) % 360
	else
		dir = (course_ab + 90) % 360
		letter = "R"
	end	
	

	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = letter}
	local abc_distance = math.abs(crosstrack( points["C"]["lat"], points["C"]["lon"], points["A"]["lat"], points["A"]["lon"], course_ab))
	if abc_distance < swath_width_m*2 then points["C"]["lat"] = 0 points["C"]["lon"] = 0 guide = 0 return end
	local num_swaths = round2(math.abs(abc_distance/swath_width_m)) + 1
	if num_swaths > 999 then num_swaths = 999 end
	
	for i=2, num_swaths do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)

	end
	
	local ind = 1

	for k,v in pairs(swath_tbl) do
		if k%2 == 0 then
			swath_sequence_tbl[k] = num_swaths
			num_swaths = num_swaths - 1
		else 
			swath_sequence_tbl[k] = ind
			ind = ind + 1
		end
	
	end
end

function pattern_Expand()

	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	
	local course_ac = course ( points["A"]["lat"], points["A"]["lon"], points["C"]["lat"], points["C"]["lon"])
	local dir = 0
	local dcourse = ang_diff(course_ab, course_ac)
	local letter = "L"
	if dcourse > 0 then
		dir = (course_ab - 90) % 360
	else
		dir = (course_ab + 90) % 360
		letter = "R"
	end	
	

	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = letter}
	swath_sequence_tbl[1] = 1
	for i=2, 999 do
		swath_tbl[i] = {}
		if i%2 == 0 then
			swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(points["A"]["lat"], points["A"]["lon"], dir, swath_width_m*(i/2))
			swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(points["B"]["lat"], points["B"]["lon"], dir, swath_width_m*(i/2))
		else
			swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(points["A"]["lat"], points["A"]["lon"], reverse_course(dir), swath_width_m*((i-1)/2))
			swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(points["B"]["lat"], points["B"]["lon"], reverse_course(dir), swath_width_m*((i-1)/2))		
		end
		swath_sequence_tbl[i] = i
	end
	
end

function pattern_QK_RTRK()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	
	local course_ac = course ( points["A"]["lat"], points["A"]["lon"], points["C"]["lat"], points["C"]["lon"])
	local dir = 0
	local dcourse = ang_diff(course_ab, course_ac)
	local letter = "L"
	if dcourse > 0 then
		dir = (course_ab - 90) % 360
	else
		dir = (course_ab + 90) % 360
		letter = "R"
	end	
	

	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = letter}
	local abc_distance = math.abs(crosstrack( points["C"]["lat"], points["C"]["lon"], points["A"]["lat"], points["A"]["lon"], course_ab))
	if abc_distance < swath_width_m*2 then points["C"]["lat"] = 0 points["C"]["lon"] = 0 guide = 0 return end
	local mid_swath = round2(math.abs(abc_distance/swath_width_m))+1
	if mid_swath > 500 then mid_swath = 500 end
	local num_swaths = (mid_swath - 1)*2


	for i=2, num_swaths do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)

	end
	
	local ind = 1
	for k,v in pairs(swath_tbl) do
		if k%2 == 0 then
			swath_sequence_tbl[k] = mid_swath
			mid_swath = mid_swath + 1
		else
			swath_sequence_tbl[k] = ind
			ind = ind + 1
		end
	
	end
end

function pattern_RV_TRK()
	clear_tbl(swath_tbl)
	clear_tbl(swath_sequence_tbl)
	local course_ab = course ( points["A"]["lat"], points["A"]["lon"], points["B"]["lat"], points["B"]["lon"])
	local course_ba = reverse_course(course_ab)
	
	local course_ac = course ( points["A"]["lat"], points["A"]["lon"], points["C"]["lat"], points["C"]["lon"])
	local dir = 0
	local dcourse = ang_diff(course_ab, course_ac)
	local letter = "L"
	if dcourse > 0 then
		dir = (course_ab + 90) % 360
	else
		dir = (course_ab - 90) % 360
		letter = "R"
	end	
	

	swath_tbl[1] = {["latA"] = points["A"]["lat"], ["lonA"] = points["A"]["lon"], ["latB"] = points["B"]["lat"], ["lonB"] = points["B"]["lon"], ["dtk1"] = course_ab, ["dtk2"] = course_ba, ["letter"] = letter}
	local abc_distance = math.abs(crosstrack( points["C"]["lat"], points["C"]["lon"], points["A"]["lat"], points["A"]["lon"], course_ab))
	if abc_distance < swath_width_m*2 then points["C"]["lat"] = 0 points["C"]["lon"] = 0 guide = 0 return end
	local half_swaths = round2(math.abs(abc_distance/swath_width_m)) + 1
	if half_swaths > 500 then half_swaths = 500 end

	for i=2, half_swaths do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i-1]["latA"], swath_tbl[i-1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i-1]["latB"], swath_tbl[i-1]["lonB"], dir, swath_width_m)
	
	end

	dir = reverse_course(dir)
	num_swaths = (half_swaths * 2) - 1
		swath_tbl[num_swaths] = {}
		swath_tbl[num_swaths]["latA"], swath_tbl[num_swaths]["lonA"] = calculate_point(swath_tbl[1]["latA"], swath_tbl[1]["lonA"], dir, swath_width_m)
		swath_tbl[num_swaths]["latB"], swath_tbl[num_swaths]["lonB"] = calculate_point(swath_tbl[1]["latB"], swath_tbl[1]["lonB"], dir, swath_width_m)
	
	for i = (num_swaths - 1), half_swaths + 1 , -1 do
		swath_tbl[i] = {}
		swath_tbl[i]["latA"], swath_tbl[i]["lonA"] = calculate_point(swath_tbl[i+1]["latA"], swath_tbl[i+1]["lonA"], dir, swath_width_m)
		swath_tbl[i]["latB"], swath_tbl[i]["lonB"] = calculate_point(swath_tbl[i+1]["latB"], swath_tbl[i+1]["lonB"], dir, swath_width_m)

	end
	
	local ind = 1
	local ind2 = half_swaths + 1
	for k,v in pairs(swath_tbl) do
		if k%2 == 0 then
			swath_sequence_tbl[k] = ind2
			ind2 = ind2 + 1
		else
			swath_sequence_tbl[k] = ind
			ind = ind + 1
		end
	
	end
end

function power_reset()
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

	menu[1]["set"] = 1
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
	menu[13]["set"] = old_job["set13"]
	menu[14]["set"] = old_job["set14"]
	menu[15]["set"] = old_job["set15"]
	menu[16]["set"] = old_job["set16"]
	menu[17]["set"] = old_job["set17"]
	points["A"]["lat"] = old_job["pointAlat"]
	points["A"]["lon"] = old_job["pointAlon"]
	points["B"]["lat"] = old_job["pointBlat"]
	points["B"]["lon"] = old_job["pointBlon"]
	points["Mrk"]["lat"] = old_job["pointMrklat"]
	points["Mrk"]["lon"] = old_job["pointMrklon"]
	
	if points["B"]["lat"] ~= 0 then
		menu[1]["set"] = 2
	end

	swath_num = old_job["swath_num"]
	xtksense = old_job["sens"]
	area = old_job["acres"]
	in_menu = 0
	mode = 6
	guide = 0
	startup_count = 1
	run_at_interval(startup,(1/4))
end

local index = 1
function track_flight()
	if spd_dr > 1 and power == 1 then
		track[index] = {}
		track[index]["spd"] = msec2kph(spd_dr)
		track[index]["alt"] = alt_dr
		track[index]["spray"] = spray
		track[index]["payload"] = water_quantity
		track[index]["area"] = area
		track[index]["hr"]	= hours_z
		track[index]["min"] = minutes_z
		track[index]["sec"] = seconds_z
		track[index]["lat"] = lat
		track[index]["lon"] = lon
		index = index + 1
	end
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
		elseif mode == 1 then
			cmd_but_ent(phase, duration)
		elseif mode == 4 then
			mode = 2
		elseif mode == 0 and guide == 1 then
			if swath_num == #swath_sequence_tbl then return end

			swath_num = math.min(#swath_sequence_tbl,swath_num + 1)
			old_job["swath_num"] = swath_num

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

				if menu[3]["set"] == 1 then
					pattern_BK_BK_L()
					guide = 1
				elseif menu[3]["set"] == 7 then
					pattern_BK_BK_R()
					guide = 1
				end
					
			elseif  points["C"]["lat"] == 0 and points["C"]["lon"] == 0 and points["B"]["lat"] ~= 0 and points["B"]["lon"] ~= 0 then
				points["C"]["lat"] = lat
				points["C"]["lon"] = lon
				old_job["pointClat"] = points["C"]["lat"]
				old_job["pointClon"] = points["C"]["lon"]
				--"BK_BK L", "Expand", "Squeeze", "RV_TRK", "QK_RTRK", "RC_TRK", "BK_BK R"
					if menu[3]["set"] == 2 then
						pattern_Expand()
					elseif menu[3]["set"] == 3 then
						pattern_Squeeze()
					elseif menu[3]["set"] == 4 then
						pattern_RV_TRK()
					elseif menu[3]["set"] == 5 then
						pattern_QK_RTRK()
					elseif menu[3]["set"] == 6 then
						pattern_RC_TRK()						
					end
				if old_job["spayed_swath"][1] == 1 then
					swath_num = 2
				end
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
			if swath_num == 1 then return end
			swath_num = math.max(1,swath_num - 1)
			old_job["swath_num"] = swath_num
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
			stop_timer(startup)
			power_reset()
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
			stop_timer(startup)
			power_reset()
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
			elseif mode == 5 then
				mode = 1
			elseif mode == 6 or mode == 7 then
				return
			end

			if points["Mrk"]["lat"] ~= 0 and mode == 0 then -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto
				mode = 4
			else
				mode = 1
			end

			if mode == 1 then
				if #swath_tbl > 0 then 
					menu[1]["set"] = 2
				end
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
		if mode == 3 then
			points["Mrk"]["lat"] = temp_mrk_lat
			points["Mrk"]["lon"] = temp_mrk_lon
			old_job["pointMrklat"] = points["Mrk"]["lat"]
			old_job["pointMrklon"] = points["Mrk"]["lon"]
			mode = 0
			return
		elseif mode == 4 then
			mode = 2
			return
		elseif mode == 5 or mode == 6 or mode == 7 then
			return
		end

		if in_menu > 0 then
			if menu[in_menu]["name"] == "DEFSNOT" then
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0
				points["C"]["lat"] = 0
				points["C"]["lon"] = 0
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				clear_tbl(swath_tbl)
				clear_tbl(swath_sequence_tbl)
				in_menu = 1
				mode = 1
				area = 0
				guide = 0
				swath_num = 1
				return
			elseif menu[in_menu]["name"] == ">SETFAC" then
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0
				points["C"]["lat"] = 0
				points["C"]["lon"] = 0
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0
				clear_tbl(swath_tbl)
				clear_tbl(swath_sequence_tbl)
				in_menu = 1
				mode = 1
				area = 0
				swath_num = 1
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
				menu[13]["set"] = 13
				menu[14]["set"] = 1
				menu[15]["set"] = 1				
				menu[16]["set"] = 1
				menu[17]["set"] = 1
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				xtksense = 3
				menu[9]["value"] = {"SENS 3"}
				menu[2]["value"] = {"50.0"}
				swath_width_dis = 50
				guide = 0
				return
			end
			if menu[1]["set"] == 1 then
				points["A"]["lat"] = 0
				points["A"]["lon"] = 0
				points["B"]["lat"] = 0
				points["B"]["lon"] = 0
				points["C"]["lat"] = 0
				points["C"]["lon"] = 0
				points["Mrk"]["lat"] = 0
				points["Mrk"]["lon"] = 0
				clear_tbl(swath_tbl)
				clear_tbl(swath_sequence_tbl)
				--old_job["set1"] = menu[1]["set"]
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
				old_job["set13"] = menu[13]["set"]
				old_job["set14"] = menu[14]["set"]
				old_job["set15"] = menu[15]["set"]
				old_job["set16"] = menu[16]["set"]
				old_job["set17"] = menu[17]["set"]
				old_job["swath_width"] = swath_width_dis
				old_job["sens"] = xtksense
				for k in pairs(old_job["spayed_swath"]) do
					old_job["spayed_swath"][k] = nil
				end
				area = 0
				guide = 0
				swath_num = 1
			elseif menu[1]["set"] == 2 then
				if points["A"]["lat"] == 0 or points["B"]["lat"] == 0 then
					menu[1]["set"] = 1
					return
				elseif points["C"]["lat"] == 0 and (menu[3]["set"] ~= 1 or menu[3]["set"] ~= 7) then
					menu[1]["set"] = 1
					return				
				end
				--old_job["set1"] = menu[1]["set"]
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
				old_job["set13"] = menu[13]["set"]
				old_job["set14"] = menu[14]["set"]
				old_job["set15"] = menu[15]["set"]
				old_job["set16"] = menu[16]["set"]
				old_job["set17"] = menu[17]["set"]
				old_job["sens"] = xtksense
				old_job["brt_control"] = brt_control
				if 	#swath_tbl == 0 then
					if menu[3]["set"] == 1 then
						pattern_BK_BK_L()
					elseif menu[3]["set"] == 2 then
						pattern_Expand()
					elseif menu[3]["set"] == 3 then
						pattern_Squeeze()
					elseif menu[3]["set"] == 4 then
						pattern_RV_TRK()
					elseif menu[3]["set"] == 5 then
						pattern_QK_RTRK()
					elseif menu[3]["set"] == 6 then
						pattern_RC_TRK()
					elseif menu[3]["set"] == 7 then
						pattern_BK_BK_R()						
					end				
					area = 0
					guide = 1
				else
					guide = 1
				end
			elseif menu[1]["set"] == 3 and #track > 0 then
				generate_kml()
				run_at_interval(export,(1/8))
				mode = 7
				in_menu = 0
				str_disL = ""
				return
			end
			in_menu = 0
			mode = 0
			if menu[12]["set"] == 1 then
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
			if menu[in_menu]["name"] == ">GPS" then
				
				if mode == 5 then
					menu[10]["submenu"]["index"] = menu[10]["submenu"]["index"] + 1
					if menu[10]["submenu"]["index"] > #menu[10]["submenu"] then
						menu[10]["submenu"]["index"] = 1
					end
				else
					mode = 5
					menu[10]["submenu"]["index"] = 1
				end
			elseif menu[in_menu]["name"] == ">SWIDTH" then
				local t = function () if menu[12]["set"] == 1 then return 300 end return 100 end
				swath_width_dis = math.min(t(), swath_width_dis+0.1)
				menu[in_menu]["value"][1] = string.format("%.1f", swath_width_dis)

			elseif menu[in_menu]["name"] == ">DIM" then

				brt_control = brt_control+1
				if brt_control > 101 then brt_control = 1 end
				old_job["brt_control"] = brt_control
				if brt_control == 101 then
					brt = brt_knob
					menu[in_menu]["value"][1] = "USEKNOB"
				else
					brt = brt_control/100
					menu[in_menu]["value"][1] = string.format("%d%%", brt_control)
				end
			elseif menu[in_menu]["name"] == ">LBAR" then
				xtksense = xtksense+1
				if xtksense > 10 then xtksense = 1 end
				menu[in_menu]["value"][1] = string.format("SENS %d", xtksense)
			else
				local prev = menu[in_menu]["set"]
				menu[in_menu]["set"] = menu[in_menu]["set"]+1
				if menu[in_menu]["set"] > #menu[in_menu]["value"] then menu[in_menu]["set"] = 1 end
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
			if menu[in_menu]["name"] == ">GPS" then
				if mode == 5 then
					menu[10]["submenu"]["index"] = menu[10]["submenu"]["index"] - 1
					if menu[10]["submenu"]["index"] < 1 then
						menu[10]["submenu"]["index"] = #menu[10]["submenu"]
					end
				else
					mode = 5
					menu[10]["submenu"]["index"] = #menu[10]["submenu"]
				end
			elseif menu[in_menu]["name"] == ">SWIDTH" then
				local t = function () if menu[12]["set"] == 1 then return 6 end return 2 end
				swath_width_dis = math.max(t(), swath_width_dis-0.1)
				menu[in_menu]["value"][1] = string.format("%.1f", swath_width_dis)
			elseif menu[in_menu]["name"] == ">DIM" then
				brt_control = brt_control-1
				if brt_control < 1 then brt_control = 101 end
				old_job["brt_control"] = brt_control
				if brt_control == 101 then
					brt = brt_knob
					menu[in_menu]["value"][1] = "USEKNOB"
				else
					brt = brt_control/100
					menu[in_menu]["value"][1] = string.format("%d%%", brt_control)
				end
			elseif menu[in_menu]["name"] == ">LBAR" then
				xtksense = xtksense-1
				if xtksense < 1 then xtksense = 10 end
				menu[in_menu]["value"][1] = string.format("SENS %d", xtksense)
			else
				local prev = menu[in_menu]["set"]
				menu[in_menu]["set"] = menu[in_menu]["set"]-1
				if menu[in_menu]["set"] < 1 then menu[in_menu]["set"] = #menu[in_menu]["value"] end
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
	if phase == 0 and power == 1 and mode == 0 then
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
			if menu[3]["set"] == 1 or menu[3]["set"] == 7 then
				if menu[3]["set"] == 1 then
					pattern_BK_BK_L()
				elseif menu[3]["set"] == 7 then
					pattern_BK_BK_R()
				end
				swath_num = 2
				guide = 1
			end
		elseif  points["C"]["lat"] == 0 and points["C"]["lon"] == 0 and points["B"]["lat"] ~= 0 and points["B"]["lon"] ~= 0 then
			points["C"]["lat"] = lat
			points["C"]["lon"] = lon
			old_job["pointClat"] = points["C"]["lat"]
			old_job["pointClon"] = points["C"]["lon"]
				if menu[3]["set"] == 2 then
					pattern_Expand()
				elseif menu[3]["set"] == 3 then
					pattern_Squeeze()
				elseif menu[3]["set"] == 4 then
					pattern_RV_TRK()
				elseif menu[3]["set"] == 5 then
					pattern_QK_RTRK()
				elseif menu[3]["set"] == 6 then
					pattern_RC_TRK()						
				end
			swath_num = 2
			guide = 1
		end
		track_flight()
	end
end

spraytogwrapcmd = wrap_command("custom/dromader/spray/spray_tog_cmd",dummy, spray_toggle_after_cmd)

function spray_after_cmd(phase, duration)
	if phase == 0 and power == 1 and mode == 0 then
		if points["A"]["lat"] == 0 and points["A"]["lon"] == 0 then
			points["A"]["lat"] = lat
			points["A"]["lon"] = lon
			old_job["pointAlat"] = points["A"]["lat"]
			old_job["pointAlon"] = points["A"]["lon"]
		elseif  points["C"]["lat"] == 0 and points["C"]["lon"] == 0 and points["B"]["lat"] ~= 0 and points["B"]["lon"] ~= 0 then
			points["C"]["lat"] = lat
			points["C"]["lon"] = lon
			old_job["pointClat"] = points["C"]["lat"]
			old_job["pointClon"] = points["C"]["lon"]
				if menu[3]["set"] == 2 then
					pattern_Expand()
				elseif menu[3]["set"] == 3 then
					pattern_Squeeze()
				elseif menu[3]["set"] == 4 then
					pattern_RV_TRK()
				elseif menu[3]["set"] == 5 then
					pattern_QK_RTRK()
				elseif menu[3]["set"] == 6 then
					pattern_RC_TRK()						
				end
			swath_num = 2
			guide = 1
		end
		track_flight()
	elseif phase == 2 and power == 1 then
		if  points["B"]["lat"] == 0 and points["B"]["lon"] == 0 then
			points["B"]["lat"] = lat
			points["B"]["lon"] = lon
			old_job["pointBlat"] = points["B"]["lat"]
			old_job["pointBlon"] = points["B"]["lon"]
			if menu[3]["set"] == 1 or menu[3]["set"] == 7 then
				if menu[3]["set"] == 1 then
					pattern_BK_BK_L()
				elseif menu[3]["set"] == 7 then
					pattern_BK_BK_R()
				end
				guide = 1
			end
			swath_num = 2
		end
		track_flight()
	end
end

spraywrapcmd = wrap_command("custom/dromader/spray/spray_cmd",dummy, spray_after_cmd)

str_disL = create_dataref("custom/dromader/litestar/disp_L","string", dummy)
str_disR = create_dataref("custom/dromader/litestar/disp_R","string", dummy)
str_trkL = create_dataref("custom/dromader/litestar/trk_L","string", dummy)
str_trkR = create_dataref("custom/dromader/litestar/trk_R","string", dummy)
str_hdgL = create_dataref("custom/dromader/litestar/hdg_L","string", dummy)
str_hdgR = create_dataref("custom/dromader/litestar/hdg_R","string", dummy)
str_ontrk = create_dataref("custom/dromader/litestar/on_trk","string", dummy)
str_stat = create_dataref("custom/dromader/litestar/stat","string", dummy)
str_disL = " "--"---A123"
str_disR = " "--"123----"
str_trkL = " "--"*********************"
str_trkR = " "--",,,,,,,,,,,,,,,,,,,,,"
str_hdgL = " "--"******************"
str_hdgR = " "--",,,,,,,,,,,,,,,,,,"
local ontrk = "` ` `"
str_ontrk = " "--ontrk
str_stat = " "--"<`*"

str_dis1 = "    "
str_dis2 = "   "
str_dis3 = "   "
str_dis4 = "    "


function flight_start()
	if startup_running == 1 then
		power_sw = 1
		power = 1
	else
		power_sw = 0
		power = 0	
	end
	fuse = 1
	mode = 6
	power_reset()
end



function timer()
	if flash_timer == 1 then
		flash_timer = 0
	else
		flash_timer = 1
	end
end

run_at_interval(timer,(1/4))
run_at_interval(track_flight,1)

function after_physics()
	if power == 1 then
		if spray == 1 then
			str_stat = "<"
			area = area + (msec2kph(spd_dr, 2)*swath_width_m/600)*SIM_PERIOD/60
			old_job["acres"] = area
		else
			str_stat = " "
		end

		if menu[12]["set"] == 1 then
			spd = math.min(999,msec2mph(spd_dr))
			area_disp = math.min(999,hect2acre(area,2))
			alt = math.min(9999,met2feet(alt_dr))
		else
			area_disp = math.min(999,area)
			spd = math.min(999,msec2kph(spd_dr))
			alt = math.min(9999, round2(alt_dr))
		end


		gps_crs = round2(course ( points["LastLoc"]["lat"], points["LastLoc"]["lon"], lat, lon))

		points["LastLoc"]["lat"] = lat
		points["LastLoc"]["lon"] = lon


			str_hdgL = " "
			str_hdgR = " "
			str_trkL = " "
			str_trkR = " "
			str_ontrk =" "
			if mode == 0 then -- 0 guide, 1 menu, 2 dirto, 3 set mark, 4 confirm dirto, 5 submenu, 6 startup
				if guide == 1 then

					if menu[12]["set"] == 1 then
						xtk = met2feet(crosstrack( points["LastLoc"]["lat"], points["LastLoc"]["lon"], swath_tbl[swath_sequence_tbl[swath_num]]["latA"], swath_tbl[swath_sequence_tbl[swath_num]]["lonA"], swath_tbl[1]["dtk1"]) )
					else
						xtk = round2(crosstrack( points["LastLoc"]["lat"], points["LastLoc"]["lon"], swath_tbl[swath_sequence_tbl[swath_num]]["latA"], swath_tbl[swath_sequence_tbl[swath_num]]["lonA"], swath_tbl[1]["dtk1"]) )
					end
					
					local d1 = ang_diff(gps_crs, swath_tbl[1]["dtk1"])
					local d2 = ang_diff(gps_crs, swath_tbl[1]["dtk2"])
					
					local diff = 0
					if math.abs(d1) > math.abs(d2) then
						diff = d2
						xtk = -1*xtk
					else
						diff = d1
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
									str_ontrk = " "
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
									str_ontrk = " "
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
								str_trkL = " "
								str_trkR = " "
							end
					end
				-- "SwthNum", "X-Track", "Blank", "GPS Alt", "NumSats", "HDOP", "A/B Hdg", "Time"(HHMM), "Dst2Mrk", "Acres", "AcftHdg", "Speed"
				-- "SwthNum", "Blank", "NumSats", "HDOP", "A/B Hdg", "Time"(HH on the left and MM on the right), "Acres", "AcftHdg", "Speed"

				if menu[5]["set"] == 1 then

					str_dis1 = string.format("%s%d", swath_tbl[1]["letter"], swath_sequence_tbl[swath_num])
				elseif menu[5]["set"] == 2 then
					str_dis1 = string.format("%s%d", letter, xtk)
				elseif menu[5]["set"] == 3 then
					str_dis1 = string.format("    ")
				elseif menu[5]["set"] == 4 then
					str_dis1 = string.format("%4d", alt)
				elseif menu[5]["set"] == 5 then
					str_dis1 = string.format("%2d", numsats)
				elseif menu[5]["set"] == 6 then
					str_dis1 = string.format("%1.2f", hdop)
				elseif menu[5]["set"] == 7 then
					str_dis1 = string.format("%3d", swath_tbl[1]["dtk1"])
				elseif menu[5]["set"] == 8 then
					str_dis1 = string.format("%2.2d%2.2d", hours, minutes)
				elseif menu[5]["set"] == 9 then
					local dist = 0
					if points["Mrk"]["lat"] ~= 0 then
						dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
						if menu[12]["set"] == 1 then
							dist = km2mile(dist)
						end
					end
					str_dis1 = string.format("%4d", math.min(9999, dist))
				elseif menu[5]["set"] == 10 then
					str_dis1 = string.format("%3d", area_disp)
				elseif menu[5]["set"] == 11 then
					str_dis1 = string.format("%3d", gps_crs)
				elseif menu[5]["set"] == 12 then
					str_dis1 = string.format("%3d", spd)
				end

				if menu[6]["set"] == 1 then

					str_dis2 = string.format("%s%d", swath_tbl[1]["letter"], swath_sequence_tbl[swath_num])
				elseif menu[6]["set"] == 2 then
					str_dis2 = string.format("    ")
				elseif menu[6]["set"] == 3 then
					str_dis2 = string.format("%2d", numsats)
				elseif menu[6]["set"] == 4 then
					str_dis2 = string.format("%1.2f", hdop)
				elseif menu[6]["set"] == 5 then
					str_dis2 = string.format("%3d", swath_tbl[1]["dtk1"])
				elseif menu[6]["set"] == 6 then
					str_dis2 = string.format("%2.2d", hours)
				elseif menu[6]["set"] == 7 then
					str_dis2 = string.format("%3d", area_disp)
				elseif menu[6]["set"] == 8 then
					str_dis2 = string.format("%3d", gps_crs)
				elseif menu[6]["set"] == 9 then
					str_dis2 = string.format("%3d", spd)
				end

				if menu[7]["set"] == 1 then

					str_dis3 = string.format("%s%d", swath_tbl[1]["letter"], swath_sequence_tbl[swath_num])
				elseif menu[7]["set"] == 2 then
					str_dis3 = string.format("    ")
				elseif menu[7]["set"] == 3 then
					str_dis3 = string.format("%2d", numsats)
				elseif menu[7]["set"] == 4 then
					str_dis3 = string.format("%1.2f", hdop)
				elseif menu[7]["set"] == 5 then
					str_dis3 = string.format("%3d", swath_tbl[1]["dtk1"])
				elseif menu[7]["set"] == 6 then
					str_dis3 = string.format("%2.2d", minutes)
				elseif menu[7]["set"] == 7 then
					str_dis3 = string.format("%3d", area_disp)
				elseif menu[7]["set"] == 8 then
					str_dis3 = string.format("%3d", gps_crs)
				elseif menu[7]["set"] == 9 then
					str_dis3 = string.format("%3d", spd)
					end

					if menu[8]["set"] == 1 then

						str_dis4 = string.format("%s%d", swath_tbl[1]["letter"], swath_sequence_tbl[swath_num])
					elseif menu[8]["set"] == 2 then
						str_dis4 = string.format("%s%d", letter, xtk)
					elseif menu[8]["set"] == 3 then
						str_dis4 = string.format("    ")
					elseif menu[8]["set"] == 4 then
						str_dis4 = string.format("%4d", alt)
					elseif menu[8]["set"] == 5 then
						str_dis4 = string.format("%2d", numsats)
					elseif menu[8]["set"] == 6 then
						str_dis4 = string.format("%1.2f", hdop)
					elseif menu[8]["set"] == 7 then
						str_dis4 = string.format("%3d", swath_tbl[1]["dtk1"])
					elseif menu[8]["set"] == 8 then
						str_dis4 = string.format("%2.2d%2.2d", hours, minutes)
					elseif menu[8]["set"] == 9 then
						local dist = 0
						if points["Mrk"]["lat"] ~= 0 then
							dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
							if menu[12]["set"] == 1 then
								dist = km2mile(dist)
							end
						end
						str_dis4 = string.format("%4d", math.min(9999, dist))
					elseif menu[8]["set"] == 10 then
						str_dis4 = string.format("%3d", area_disp)
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
							if points["B"]["lat"] ~= 0 and points["B"]["lon"] ~= 0 then 
								point = "C"
							else
								point = "B"
							end
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
				str_disR = string.format("%7.7s", menu[in_menu]["value"][menu[in_menu]["set"] or 1])
			elseif mode == 2 then
				local dist = round2(distance(lat, lon, points["Mrk"]["lat"], points["Mrk"]["lon"] )/1000 )
				if menu[12]["set"] == 1 then
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
			elseif mode == 5 then
				if menu[10]["submenu"]["index"] == 1 then
					local word = " Diff"
					if menu[14]["set"] == 2 then word = "" end
					str_disL = string.format("%-7.7s", menu[10]["submenu"][1])
					str_disR = string.format("%7.7s", string.format("3D%s", word))
				elseif menu[10]["submenu"]["index"] == 2 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][2])
					str_disR = string.format("%7.7s", string.format("Trak %2d", numsats + 3))
				elseif menu[10]["submenu"]["index"] == 3 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][3])
					str_disR = string.format("%7.7s", string.format("Used %2d", numsats))
				elseif menu[10]["submenu"]["index"] == 4 then
					local age = 0
					if menu[14]["set"] ~= 2 then age = os.date("%S") + 1 end 
					str_disL = string.format("%-7.7s", menu[10]["submenu"][4])
					str_disR = string.format("%7.7s", string.format("Age %03d", age))
				elseif menu[10]["submenu"]["index"] == 5 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][5])
					str_disR = string.format("%7.7s", string.format("%1.2f", hdop))
				elseif menu[10]["submenu"]["index"] == 6 then
					local word = "N"
					if points["LastLoc"]["lat"] < 0 then word = "S" end
					local num, frac = tostring(math.abs(points["LastLoc"]["lat"])):match("(%d+).(%d+)")
					str_disL = string.format("%-7.7s", string.format(">%s %03s.", word, num))
					str_disR = string.format("%7.7s", frac)
				elseif menu[10]["submenu"]["index"] == 7 then
					local word = "E"
					if points["LastLoc"]["lon"] < 0 then word = "W" end
					local num, frac = tostring(math.abs(points["LastLoc"]["lon"])):match("(%d+).(%d+)")
					str_disL = string.format("%-7.7s", string.format(">%s %03s.", word, num))
					str_disR = string.format("%7.7s", frac)
				elseif menu[10]["submenu"]["index"] == 8 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][8])
					str_disR = string.format("%7.7s", string.format("%.2f", met2feet(alt_dr,2)))
				elseif menu[10]["submenu"]["index"] == 9 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][9])
					str_disR = string.format("%7.7s", string.format("%.2f", msec2mph(spd_dr, 2)))
				elseif menu[10]["submenu"]["index"] == 10 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][10])
					str_disR = string.format("%7.7s", string.format("%03d", gps_crs))
				elseif menu[10]["submenu"]["index"] == 11 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][11])
					str_disR = string.format("%7.7s", string.format("%02d%02d%02d", string.sub(os.date(), -2), month, day))
				elseif menu[10]["submenu"]["index"] == 12 then
					str_disL = string.format("%-7.7s", menu[10]["submenu"][12])
					str_disR = string.format("%7.7s", string.format("%02d%02d%02d", hours, minutes, seconds_z))
				end
			end
	end
end

function generate_kml()
	local year = os.date("%Y")
	local filename = "Output/LiteStarIV".. "_" .. os.date("%Y-%m-%d-%H-%M") .. ".kml"
	local file = io.open(filename, "w")
	
	file:write([[
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
	<Document>
		<name>LiteStar IV GPS</name>
		]])
	file:write("		<Snippet>Created " .. os.date("%Y-%m-%d %H:%M:%S") .. "</Snippet>\n")	
	file:write([[
		<Style id="swathline">
			 <LineStyle>
				 <color>ff0000ff</color>
				 <width>5</width>
				 <gx:labelVisibility>1</gx:labelVisibility>
			 </LineStyle>
		 </Style>
		<Style id="sprayline">
			 <LineStyle>
				 <color>64B4E614</color>
				 ]])
	file:write("				 <gx:physicalWidth>" .. swath_width_m ..  "</gx:physicalWidth>\n")
	file:write([[
				 <gx:labelVisibility>1</gx:labelVisibility>
			 </LineStyle>
		 </Style>
	   <!-- Normal track style -->
		<LookAt>
		]])
    file:write("		<longitude>" .. track[1]["lon"] .. "</longitude>\n")
    file:write("		<latitude>" .. track[1]["lat"] .. "</latitude>\n")
    file:write("		<range>" .. (2000.000000 + track[1]["alt"]) .. "</range>\n")
    file:write([[
		</LookAt>
		<Style id="track_n">
		  <IconStyle>
			<scale>.5</scale>
			<Icon>
			  <href>http://earth.google.com/images/kml-icons/track-directional/track-none.png</href>
			</Icon>
		  </IconStyle>
		  <LabelStyle>
			<scale>0</scale>
		  </LabelStyle>

		</Style>
		<!-- Highlighted track style -->
		<Style id="track_h">
		  <IconStyle>
			<scale>1.2</scale>
			<Icon>
			  <href>http://earth.google.com/images/kml-icons/track-directional/track-none.png</href>
			</Icon>
		  </IconStyle>
		</Style>
		<StyleMap id="track">
		  <Pair>
			<key>normal</key>
			<styleUrl>#track_n</styleUrl>
		  </Pair>
		  <Pair>
			<key>highlight</key>
			<styleUrl>#track_h</styleUrl>
		  </Pair>
		</StyleMap>
		<!-- Normal multiTrack style -->
		<Style id="multiTrack_n">
		  <IconStyle>
			<Icon>
			  <href>http://earth.google.com/images/kml-icons/track-directional/track-0.png</href>
			</Icon>
		  </IconStyle>
		  <LineStyle>
			<color>99ffac59</color>
			<width>4</width>
		  </LineStyle>

		</Style>
		<!-- Highlighted multiTrack style -->
		<Style id="multiTrack_h">
		  <IconStyle>
			<scale>1.2</scale>
			<Icon>
			  <href>http://earth.google.com/images/kml-icons/track-directional/track-0.png</href>
			</Icon>
		  </IconStyle>
		  <LineStyle>
			<color>99ffac59</color>
			<width>6</width>
		  </LineStyle>
		</Style>
		<StyleMap id="multiTrack">
		  <Pair>
			<key>normal</key>
			<styleUrl>#multiTrack_n</styleUrl>
		  </Pair>
		  <Pair>
			<key>highlight</key>
			<styleUrl>#multiTrack_h</styleUrl>
		  </Pair>
		</StyleMap>
		<!-- Normal waypoint style -->
		<Style id="waypoint_n">
		  <IconStyle>
			<Icon>
			  <href>http://maps.google.com/mapfiles/kml/pal4/icon61.png</href>
			</Icon>
		  </IconStyle>
		</Style>
		<!-- Highlighted waypoint style -->
		<Style id="waypoint_h">
		  <IconStyle>
			<scale>1.2</scale>
			<Icon>
			  <href>http://maps.google.com/mapfiles/kml/pal4/icon61.png</href>
			</Icon>
		  </IconStyle>
		</Style>
		<StyleMap id="waypoint">
		  <Pair>
			<key>normal</key>
			<styleUrl>#waypoint_n</styleUrl>
		  </Pair>
		  <Pair>
			<key>highlight</key>
			<styleUrl>#waypoint_h</styleUrl>
		  </Pair>
		</StyleMap>
		<Style id="lineStyle">
		  <LineStyle>
			<color>99ffac59</color>
			<width>4</width>
		  </LineStyle>
		</Style>
		 <Schema id="schema">
			<gx:SimpleArrayField name="speed" type="string">
				 <displayName>Speed</displayName>
			</gx:SimpleArrayField>
			<gx:SimpleArrayField name="payload" type="string">
				<displayName>Payload</displayName>
			</gx:SimpleArrayField>
			<gx:SimpleArrayField name="area" type="string">
				<displayName>Area</displayName>
			</gx:SimpleArrayField>
		 </Schema>
		 ]])
	if points["A"]["lon"] ~= 0 and points["A"]["lat"] ~=0 then
	file:write("		<Placemark>\n")
	file:write("			<name>Point A</name>\n")
	file:write("				<Point>\n")
	file:write("					<coordinates>" .. points["A"]["lon"] .. "," .. points["A"]["lat"] .. "," .. "0" .. "</coordinates>\n")
	file:write("				</Point>\n")	
	file:write("		</Placemark>\n")
	file:write("		<Placemark>\n")
	file:write("			<name>Point B</name>\n")
	file:write("				<Point>\n")
	file:write("					<coordinates>" .. points["B"]["lon"] .. "," .. points["B"]["lat"] .. "," .. "0" .. "</coordinates>\n")
	file:write("				</Point>\n")	
	file:write("		</Placemark>\n")
		if points["C"]["lon"] ~= 0 and points["C"]["lat"] ~=0 then
		file:write("		<Placemark>\n")
		file:write("			<name>Point C</name>\n")
		file:write("				<Point>\n")
		file:write("					<coordinates>" .. points["C"]["lon"] .. "," .. points["C"]["lat"] .. "," .. "0" .. "</coordinates>\n")
		file:write("				</Point>\n")	
		file:write("			</Placemark>\n")
		end
	end
		if points["Mrk"]["lon"] ~= 0 and points["Mrk"]["lat"] ~=0 then
		file:write("		<Placemark>\n")
		file:write("			<name>Marker</name>\n")
		file:write("				<Point>\n")
		file:write("					<coordinates>" .. points["Mrk"]["lon"] .. "," .. points["Mrk"]["lat"] .. "," .. "0" .. "</coordinates>\n")
		file:write("				</Point>\n")	
		file:write("			</Placemark>\n")
		end
	for k,v in pairs(swath_tbl) do
		file:write("		<Placemark>\n")

		file:write("			<name>Swatht " .. k .. "|Num in sequence " .. swath_sequence_tbl[k] .. "</name>\n")
		file:write("			<styleUrl>#swathline</styleUrl>\n")	
		file:write("				<LineString>\n")
		file:write("					<coordinates>\n")
		
		file:write("						" .. v["lonA"] .. "," .. v["latA"] .. "\n" .. "						" .. v["lonB"] .. "," .. v["latB"] .. "\n")
		
		file:write("					</coordinates>\n")
		file:write("				</LineString>\n")	
		file:write("		</Placemark>\n")
	end
	local count = 1
	local i = 1
	while i <= #track do
		if track[i]["spray"] == 1 then
			file:write("		<Placemark>\n")

			file:write("			<name>Spray run " .. count .. "</name>\n")
			file:write("			<styleUrl>#sprayline</styleUrl>\n")	
			file:write("				<LineString>\n")
			file:write("					<coordinates>\n")

				while track[i]["spray"] == 1 do
					file:write("						" .. track[i]["lon"] .. "," .. track[i]["lat"] .. "\n")
					i = i + 1
					if i > #track then break end
				end
			
			file:write("					</coordinates>\n")
			file:write("				</LineString>\n")	
			file:write("		</Placemark>\n")
			count = count + 1
		end
		i = i + 1
	end
	file:write("		<Folder>\n")
	file:write("		<name>AcfTrack</name>\n")
	file:write("			<Placemark>\n")	
	file:write("				<name>Aircraft</name>\n")
	file:write("				<styleUrl>#multiTrack</styleUrl>\n")
	file:write("				<gx:Track>\n")
	file:write("				<altitudeMode>absolute</altitudeMode>\n")
	
	for k,v in pairs(track) do
		local line  = string.format("				<when>%d-%02d-%02dT%02d:%02d:%02dZ</when>\n", year, month, day, v["hr"], v["min"], v["sec"])
		file:write(line)
	end
	for k,v in pairs(track) do
		file:write("				<gx:coord>" .. v["lon"] .. " " .. v["lat"] .. " " .. v["alt"] .. "</gx:coord>\n")
	end
	file:write("					<ExtendedData>\n")
	file:write("						<SchemaData schemaUrl=\"#schema\">\n")
	file:write("							<gx:SimpleArrayData name=\"speed\">\n")
	for k,v in pairs(track) do
		file:write("								<gx:value>" .. v["spd"] .. " km/h" .. "</gx:value>\n")
	end	
	file:write("							</gx:SimpleArrayData>\n")
	file:write("							<gx:SimpleArrayData name=\"payload\">\n")
	for k,v in pairs(track) do
		file:write("								<gx:value>" .. round2(v["payload"], 1) .. " kg" .. "</gx:value>\n")
	end	
	file:write("							</gx:SimpleArrayData>\n")
	file:write("							<gx:SimpleArrayData name=\"area\">\n")
	for k,v in pairs(track) do
		file:write("								<gx:value>" .. round2(v["area"], 2) .. " ha" .. "</gx:value>\n")
	end	
	file:write("							</gx:SimpleArrayData>\n")
	file:write("						</SchemaData>\n")
	file:write("					</ExtendedData>\n")
	file:write("				</gx:Track>\n")
	file:write("			</Placemark>\n")
	file:write("		</Folder>\n")
	file:write("	</Document>\n")	
	file:write("</kml>\n")
	file:close()

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


