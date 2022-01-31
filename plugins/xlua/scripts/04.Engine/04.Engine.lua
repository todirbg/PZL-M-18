----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

eng_cyl_temp = find_dataref("sim/flightmodel/engine/ENGN_CHT_c[0]")
eng_cyl_temp_max = find_dataref("sim/aircraft/engine/acf_max_CHT")
eng_egt = find_dataref("sim/flightmodel/engine/ENGN_EGT_c[0]")
eng_carb_temp = find_dataref("sim/cockpit2/engine/indicators/carburetor_temperature_C[0]")
eng_pwr = find_dataref("sim/flightmodel/engine/ENGN_power[0]")
eng_cyl_temp_red_lo = find_dataref("sim/aircraft/limits/red_lo_CHT")
eng_cyl_temp_red_hi = find_dataref("sim/aircraft/limits/red_hi_CHT")
eng_cyl_temp_green_lo = find_dataref("sim/aircraft/limits/green_lo_CHT")
eng_cyl_temp_green_hi = find_dataref("sim/aircraft/limits/green_hi_CHT")
eng_speed = find_dataref("sim/flightmodel/engine/ENGN_tacrad[0]")
eng_throt = find_dataref("sim/flightmodel/engine/ENGN_thro[0]")
eng_fail = find_dataref("sim/operation/failures/rel_engfai0")
eng_seize = find_dataref("sim/operation/failures/rel_seize_0")
eng_fire = find_dataref("sim/operation/failures/rel_engfir0")
eng_cowl = find_dataref("sim/flightmodel/engine/ENGN_cowl[0]")
smoke_cpit = find_dataref("sim/operation/failures/rel_smoke_cpit")
smoke_trail = find_dataref("sim/flightmodel/failures/smoking")
oil_flap = find_dataref("sim/flightmodel/engine/ENGN_cowl[1]")
oil_temp_max = find_dataref("sim/aircraft/engine/acf_max_OILT")
oil_temp = find_dataref("sim/flightmodel/engine/ENGN_oil_temp_c[0]")
oil_pres = find_dataref("sim/aircraft/engine/acf_max_OILP")
oil_fail = find_dataref("sim/operation/failures/rel_oilpmp0")
oil_press_lo_lim = find_dataref("sim/aircraft/limits/red_lo_oilP")
oil_press_hi_lim = find_dataref("sim/aircraft/limits/red_hi_oilP")
oil_rad_fail = create_dataref("custom/dromader/engine/oil_rad_fail","number", dummy)
oat = find_dataref("sim/weather/temperature_ambient_c")

smoker = create_dataref("custom/dromader/engine/smoker","number", dummy)

bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")

starter_fuse = create_dataref("custom/dromader/electrical/starter_fuse","number", dummy)
starter_fail = find_dataref("sim/operation/failures/rel_startr0")
starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
starter_hit = find_dataref("sim/cockpit2/engine/actuators/starter_hit[0]")

flywheel_rpm = create_dataref("custom/dromader/engine/flywheel_rpm","number", dummy)

bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")
air_res = find_dataref("sim/operation/failures/rel_airres0")


primed_ratio = create_dataref("custom/dromader/engine/primed_ratio","number", dummy)
--magL_fail = find_dataref("sim/operation/failures/rel_magLFT0")
--magR_fail = find_dataref("sim/operation/failures/rel_magRGT0")
running_eng = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
eng_max_pwr_w = find_dataref("sim/aircraft2/engine/max_power_limited_watts")
flooded = create_dataref("custom/dromader/engine/flooded","number", dummy)


MP_limit = find_dataref("sim/aircraft/limits/red_hi_MP")
MP_cur = find_dataref("sim/cockpit2/engine/indicators/MPR_in_hg[0]")


max_throt = find_dataref("sim/aircraft/engine/acf_throtmax_FWD")
fuel_press_dromader = find_dataref("custom/dromader/fuel/fuel_press")

local eng_power_wats = eng_max_pwr_w


local primer_handle_prev = 0
function primer_handle_handler()
	if running_eng == 0 and primer_handle_prev > primer_handle then
		primed_ratio = primed_ratio + (primer_handle_prev - primer_handle)*(fuel_press_dromader/180)
		if primed_ratio > 2 then
			flooded = 1
		end
	end
	primer_handle_prev = primer_handle

end

primer_handle = create_dataref("custom/dromader/engine/primer_handle","number", primer_handle_handler)

function cmd_smoker_enable(phase, duration)
	if phase == 1 and running_eng == 1 then
		smoker = 1
	else
		smoker = 0
	end
end

cmdcustomsmokerenable = create_command("custom/dromader/engine/smoker_enable","Lay smoke",cmd_smoker_enable)

local bus_load_prev = 0

function cmd_start_fuse_tog(phase, duration)
	if phase == 0 then
		if starter_fuse == 0 then
			starter_fuse = 1
		else
			starter_fuse = 0
		end
	end
end

cmdcustomstarttog = create_command("custom/dromader/electrical/starter_fuse_tog","Toggle starter fuse",cmd_start_fuse_tog)

function cmd_starter_wrap_before_handler()
		if flywheel_rpm == 0 or starter_fuse == 0 then
			starter_fail = 6
		else
			starter_fail = 0
		end
end
local primed_good = 0
function cmd_starter_wrap_after_handler(phase, duration)
	if phase == 0 then 
		if (primed_ratio > math.random()*0.8 or eng_cyl_temp >= 30) and flooded == 0  then
			primed_good = 1
		else
			primed_good = 0
			eng_fail = 6
		end
	elseif phase == 1 and starter_fuse == 1 then
		flywheel_rpm = math.max(0, flywheel_rpm - 20*SIM_PERIOD)
		primed_ratio_prev = primed_ratio
	elseif phase == 2 and starter_fuse == 1 and flooded == 0 then
		primed_ratio = 0
	end
end


cmdcustomstarter = wrap_command("sim/starters/engage_starter_1", cmd_starter_wrap_before_handler, cmd_starter_wrap_after_handler)


function cmd_spin_flywheel(phase, duration)
	if phase == 1 and starter_fuse == 1 and bus_volt > 18 then
		flywheel_rpm = math.min(100, flywheel_rpm + (bus_volt - 18)*3*SIM_PERIOD)
		bus_load_add = bus_load_prev + 60 - flywheel_rpm/2
	elseif phase == 0 then
		bus_load_prev = bus_load_add
	else
		bus_load_add = bus_load_prev
	end
end


cmdcsutomspinflywheel = create_command("custom/dromader/engine/spin_flywheel","Starter spin flywheel",cmd_spin_flywheel)


local eng_hi_fail_counter = 0
local eng_lo_fail_counter = 0
local MP_fail_counter = 0
local RPM_fail_counter = 0
--eng_hi_fail_counter = create_dataref("custom/dromader/engine/eng_hi_fail_counter","number")
--MP_fail_counter = create_dataref("custom/dromader/engine/MP_fail_counter","number")
--eng_pwr_ratio = create_dataref("custom/dromader/engine/eng_pwr_ratio","number", dummy)
function check_eng()

	--local eng_pwr_ratio = math.max(0,(eng_pwr/eng_max_pwr_w))
	--eng_cyl_temp_max = eng_egt*(0.25+eng_pwr_ratio/2
	if oil_rad_fail == 1 then 
		oil_temp_max = 300
	else
		oil_temp_max = (200/(1+oil_flap) )
	end
	
	if oil_temp > 100 then
		air_res = 6
		smoke_trail = 1
	end
	
	if eng_speed > 246.1 then
		RPM_fail_counter = RPM_fail_counter + SIM_PERIOD
		if RPM_fail_counter > 30 then
			eng_seize = 6
		end
	else
		if RPM_fail_counter > 0 then
			RPM_fail_counter = RPM_fail_counter - 2*SIM_PERIOD
		end
	end

	if eng_cyl_temp < eng_cyl_temp_red_lo and eng_speed > 150 then
		eng_lo_fail_counter = eng_lo_fail_counter + SIM_PERIOD
	elseif eng_cyl_temp > eng_cyl_temp_green_hi+35 then
		eng_hi_fail_counter = eng_hi_fail_counter + SIM_PERIOD
	else
		if eng_hi_fail_counter > 0 then
			eng_hi_fail_counter = eng_hi_fail_counter - 2*SIM_PERIOD
		end
		if eng_lo_fail_counter > 0 then
			eng_lo_fail_counter = eng_lo_fail_counter - 2*SIM_PERIOD
		end
	end
	
	if MP_cur > MP_limit*1.05 then
		MP_fail_counter = MP_fail_counter + (MP_cur - MP_limit)*SIM_PERIOD
	else
		if MP_fail_counter > 0 then
			MP_fail_counter = MP_fail_counter - 5*SIM_PERIOD
		end
	end
	
	if MP_fail_counter > 300 then
		air_res = 6
		smoke_trail = 1
		max_throt = 0.75
	end
	
	if eng_lo_fail_counter > 60 and eng_cyl_temp < eng_cyl_temp_red_lo then
		if eng_speed > 126 then
			eng_max_pwr_w = eng_max_pwr_w - 100*SIM_PERIOD -- degrade performance 100 wats/sec
			eng_power_wats = eng_max_pwr_w
		end
		air_res = 6
		smoke_trail = 1
	elseif eng_lo_fail_counter > 120 and eng_cyl_temp < eng_cyl_temp_red_lo then
		oil_fail = 6
	elseif eng_hi_fail_counter > 300 and eng_cyl_temp > eng_cyl_temp_green_hi then
			air_res = 6
			smoke_trail = 1
	elseif eng_hi_fail_counter > 180 and eng_cyl_temp > eng_cyl_temp_red_hi then
			eng_seize = 6
			eng_fire = 6
	end

	
	if eng_cyl_temp < 30 then
		if primed_good == 1 then
			if math.max(0,eng_cyl_temp/100) < math.random(-1, 1) and eng_fail == 0 then 
					
				if eng_speed < 33 then
					eng_fail = 0
				else
					eng_fail = 6
				end
			else
				eng_fail = 0
			end
		end
	else		
		eng_fail = 0
	end
	
end

function flight_start()
	eng_max_pwr_w = eng_power_wats
	if oat < 15 then 
		eng_cowl = 0.5
	else 
		eng_cowl = 1
	end
	math.randomseed( os.clock( ) )
end

function after_physics()
	flywheel_rpm = math.max(0, flywheel_rpm - 2*SIM_PERIOD)	
	check_eng()
end