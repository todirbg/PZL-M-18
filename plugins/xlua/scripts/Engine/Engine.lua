----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

eng_cyl_temp = find_dataref("sim/flightmodel/engine/ENGN_CHT_c[0]")
eng_carb_temp = find_dataref("sim/cockpit2/engine/indicators/carburetor_temperature_C[0]")
eng_cyl_temp_lim_lo = find_dataref("sim/aircraft/limits/red_lo_CHT")
eng_cyl_temp_lim_hi = find_dataref("sim/aircraft/limits/red_hi_CHT")
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
oat = find_dataref("sim/weather/temperature_ambient_c")

bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")

starter_fuse = create_dataref("custom/dromader/electrical/starter_fuse","number", dummy)
starter_fail = find_dataref("sim/operation/failures/rel_startr0")
starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
starter_hit = find_dataref("sim/cockpit2/engine/actuators/starter_hit[0]")

flywheel_rpm = create_dataref("custom/dromader/engine/flywheel_rpm","number")

bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")
air_res = find_dataref("sim/operation/failures/rel_airres0")


primed_ratio = create_dataref("custom/dromader/engine/primed_ratio","number", dummy)
--magL_fail = find_dataref("sim/operation/failures/rel_magLFT0")
--magR_fail = find_dataref("sim/operation/failures/rel_magRGT0")
running_eng = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
eng_max_pwr_w = find_dataref("sim/aircraft2/engine/max_power_limited_watts")



MP_limit = find_dataref("sim/aircraft/limits/red_hi_MP")
MP_cur = find_dataref("sim/cockpit2/engine/indicators/MPR_in_hg[0]")


max_throt = find_dataref("sim/aircraft/engine/acf_throtmax_FWD")

local eng_power_wats = eng_max_pwr_w

local primer_handle_prev = 0
function primer_handle_handler()
	if running_eng == 0 and primer_handle_prev > primer_handle then
		primed_ratio = primed_ratio + (primer_handle_prev - primer_handle)*0.2
	end
	primer_handle_prev = primer_handle

end

primer_handle = create_dataref("custom/dromader/engine/primer_handle","number", primer_handle_handler)


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
		if primed_ratio > math.random() then
			primed_good = 1
		else
			primed_good = 0
			eng_fail = 6
		end
	elseif phase == 1 and starter_fuse == 1 then
		flywheel_rpm = math.max(0, flywheel_rpm - 20*SIM_PERIOD)
		primed_ratio_prev = primed_ratio
	elseif phase == 2 and starter_fuse == 1 then
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
--eng_hi_fail_counter = create_dataref("custom/dromader/engine/eng_hi_fail_counter","number")
--MP_fail_counter = create_dataref("custom/dromader/engine/MP_fail_counter","number")
function check_eng()

	oil_temp_max = (200/(1+oil_flap) ) - oat
	oil_pres = 90 - oil_temp/5
	
	if oil_pres < oil_press_lo_lim and eng_speed > 100 then
		eng_max_pwr_w = eng_power_wats - 1000*(oil_press_lo_lim - oil_pres)
	elseif oil_pres > oil_press_hi_lim then
		oil_fail = 6
		smoke_trail = 1
	else
		if eng_max_pwr_w ~= eng_power_wats then
			eng_max_pwr_w = eng_power_wats
		end
	end
	
	if oil_temp > 110 then
		air_res = 6
		smoke_trail = 1
	end

	if eng_cyl_temp < eng_cyl_temp_lim_lo and eng_speed > 126 then
		eng_lo_fail_counter = eng_lo_fail_counter + SIM_PERIOD
	elseif eng_cyl_temp > 215 then
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
	
	if eng_lo_fail_counter > 60 and eng_cyl_temp < eng_cyl_temp_lim_lo then
		if eng_speed > 126 then
			eng_max_pwr_w = eng_max_pwr_w - 100*SIM_PERIOD -- degrade performance 100 wats/sec
			eng_power_wats = eng_max_pwr_w
		end
		air_res = 6
		smoke_trail = 1
	elseif eng_lo_fail_counter > 120 and eng_cyl_temp < eng_cyl_temp_lim_lo then
		oil_fail = 6
	elseif eng_hi_fail_counter > 60 and eng_cyl_temp > 215 then
			air_res = 6
			smoke_trail = 1
			eng_max_pwr_w = eng_max_pwr_w - 100*SIM_PERIOD -- degrade performance 100 wats/sec
			eng_power_wats = eng_max_pwr_w
		if eng_hi_fail_counter > 180 then
			eng_seize = 6
			eng_fire = 6
		end
	end

	
	if eng_cyl_temp < (eng_cyl_temp_lim_lo - 20) and starter_running == 1 then
		eng_max_pwr_w = eng_power_wats * math.max(0.3,math.min(1, eng_cyl_temp/100))
	else 
		eng_max_pwr_w = eng_power_wats
	end
	
	if eng_cyl_temp < 15 then
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
	math.randomseed( oat )
end


function after_physics()
	flywheel_rpm = math.max(0, flywheel_rpm - 2*SIM_PERIOD)	
	check_eng()
end