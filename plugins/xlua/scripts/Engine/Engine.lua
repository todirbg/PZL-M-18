----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

eng_cyl_temp = find_dataref("sim/flightmodel/engine/ENGN_CHT_c[0]")
eng_carb_temp = find_dataref("sim/cockpit2/engine/indicators/carburetor_temperature_C[0]")
eng_cyl_temp_lim = find_dataref("sim/aircraft/limits/red_lo_CHT")
eng_speed = find_dataref("sim/flightmodel/engine/ENGN_tacrad[0]")
eng_throt = find_dataref("sim/flightmodel/engine/ENGN_thro[0]")
eng_fail = find_dataref("sim/operation/failures/rel_engfai0")
oat = find_dataref("sim/weather/temperature_ambient_c")

bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")

starter_fuse = create_dataref("custom/dromader/electrical/starter_fuse","number", dummy)
starter_fail = find_dataref("sim/operation/failures/rel_startr0")

flywheel_rpm = create_dataref("custom/dromader/engine/flywheel_rpm","number")

bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")

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

function cmd_starter_wrap_after_handler(phase, duration)
	if phase == 1 and starter_fuse == 1 then
		flywheel_rpm = math.max(0, flywheel_rpm - 20*SIM_PERIOD)
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

local rough = 0
function check_eng()
	if eng_cyl_temp < eng_cyl_temp_lim and oat < 5 then
		rough = 1
	else
		rough = 0
	end
	if rough == 1 then
		toggle_eng_fail()
	end
end

function toggle_eng_fail()
	if eng_fail == 6 then
		eng_fail = 0
	else 
		eng_fail = 6
	end
end

local timer = 0
function after_physics()
	flywheel_rpm = math.max(0, flywheel_rpm - 2*SIM_PERIOD)	
	--check_eng()
end