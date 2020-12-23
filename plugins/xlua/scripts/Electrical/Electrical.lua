----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------

bat_sel = create_dataref("custom/dromader/electrical/battery_sw","number")
volt_sel = create_dataref("custom/dromader/electrical/volt_src","number")
volt_needle = create_dataref("custom/dromader/electrical/volt_needle","number")

batt = find_dataref("sim/cockpit2/electrical/battery_on[0]")
gpu = find_dataref("sim/cockpit/electrical/gpu_on")
startup_running = find_dataref("sim/operation/prefs/startup_running")


bus_amp = find_dataref("sim/cockpit2/electrical/bus_load_amps[0]")
bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bat_volt =  find_dataref("sim/cockpit2/electrical/battery_voltage_indicated_volts[0]")
bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")


fuel_fuse = create_dataref("custom/dromader/electrical/fuel_fuse","number")

starter_fuse = create_dataref("custom/dromader/electrical/starter_fuse","number")
starter_fail = find_dataref("sim/operation/failures/rel_startr0")

stall_fuse = create_dataref("custom/dromader/electrical/stall_fuse","number")
stall_fail = find_dataref("sim/operation/failures/rel_stall_warn")

inst_brt = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")

heater_sw = create_dataref("custom/dromader/electrical/heater","number")

vent_fuse = create_dataref("custom/dromader/electrical/vent","number")

wiper_fuse = create_dataref("custom/dromader/electrical/wiper","number")
wiper_speed = find_dataref("sim/cockpit2/switches/wiper_speed")

inst_light_fuse = create_dataref("custom/dromader/electrical/instruments_light","number")
inst_light_fail = find_dataref("sim/operation/failures/rel_clights")

agk49_fuse = create_dataref("custom/dromader/electrical/agk49_power","number")
agk49_fail = find_dataref("sim/operation/failures/rel_elec_gyr")

radio_fuse = find_dataref("sim/cockpit2/electrical/cross_tie")


local volt_but = 0

function dummy()
--do nothing
end

function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
  if math.abs(reference_value - animated_VALUE) < 0.1 then return reference_value end
  animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * (anim_speed * SIM_PERIOD))
  return animated_VALUE
end

function cmd_heater_sw_up(phase, duration)
	if phase == 0 then
		heater_sw = heater_sw + 1
		if heater_sw < 3 then bus_load_add = bus_load_add + 10 end
		if heater_sw > 2 then heater_sw = 2 end
	end
end

function cmd_heater_sw_dwn(phase, duration)
	if phase == 0 then
		heater_sw = heater_sw - 1
		if heater_sw > -1 then bus_load_add = bus_load_add - 10 end
		if heater_sw < 0 then heater_sw = 0 end		
	end
end

cmdcustomheaterswup = create_command("custom/dromader/electrical/heater_sw_up","Toggle heater up",cmd_heater_sw_up)
cmdcustomheaterswdwn = create_command("custom/dromader/electrical/heater_sw_dwn","Toggle heater dwn",cmd_heater_sw_dwn)

function cmd_stall_fuse_tog(phase, duration)
	if phase == 0 then
		if stall_fuse == 0 then
			stall_fuse = 1
			stall_fail = 0
		else
			stall_fuse = 0
			stall_fail = 6
		end
	end
end

cmdcustomstalltog = create_command("custom/dromader/electrical/stall_fuse_tog","Toggle stall warning fuse",cmd_stall_fuse_tog)

function cmd_agk49_fuse_tog(phase, duration)
	if phase == 0 then
		if agk49_fuse == 0 then
			agk49_fuse = 1
			agk49_fail = 0
			bus_load_add = bus_load_add + 2
		else
			agk49_fuse = 0
			agk49_fail = 6
			bus_load_add = bus_load_add - 2
		end
	end
end

cmdcustomagk49tog = create_command("custom/dromader/electrical/agk49_pwr_cmd","Toggle AGK-49 fuse",cmd_agk49_fuse_tog)

function cmd_inst_light_fuse_tog(phase, duration)
	if phase == 0 then
		if inst_light_fuse == 0 then
			inst_light_fuse = 1
			inst_light_fail = 0
		else
			inst_light_fuse = 0
			inst_light_fail = 6
		end
	end
end

cmdcustominstlighttog = create_command("custom/dromader/electrical/inst_light_cmd","Toggle instruments light fuse",cmd_inst_light_fuse_tog)



function cmd_wiper_fuse_tog(phase, duration)
	if phase == 0 then
		if wiper_fuse == 0 then
			wiper_fuse = 1
		else
			wiper_fuse = 0
			wiper_speed = 0
		end
	end
end

function cmd_wiper_wrap_handler(phase, duration)
	if phase == 0 then
		if wiper_fuse == 0 then
			wiper_speed = 0
		end
	end
end


cmdcustomwiperdn = wrap_command("sim/systems/wipers_dn", dummy, cmd_wiper_wrap_handler)
cmdcustomwiperup = wrap_command("sim/systems/wipers_up", dummy, cmd_wiper_wrap_handler)
cmdcustomwipertog = create_command("custom/dromader/electrical/wiper_fuse_tog","Toggle stall warning fuse",cmd_wiper_fuse_tog)

function cmd_vent_fuse_tog(phase, duration)
	if phase == 0 then
		if vent_fuse == 0 then
			vent_fuse = 1
			bus_load_add = bus_load_add + 3
		else
			vent_fuse = 0
			bus_load_add = bus_load_add - 3
		end
	end
end

ventfusetogcmd = create_command("custom/dromader/electrical/vent_fuse_tog","Toggle vent fuse",cmd_vent_fuse_tog)

function cmd_start_fuse_tog(phase, duration)
	if phase == 0 then
		if starter_fuse == 0 then
			starter_fuse = 1
			starter_fail = 0
		else
			starter_fuse = 0
			starter_fail = 6
		end
	end
end

cmdcustomstarttog = create_command("custom/dromader/electrical/starter_fuse_tog","Toggle starter fuse",cmd_start_fuse_tog)

function cmd_fuel_fuse_tog(phase, duration)
	if phase == 0 then
		if fuel_fuse == 0 then
			fuel_fuse = 1
			bus_load_add = bus_load_add + 2
		else
			fuel_fuse = 0
			bus_load_add = bus_load_add - 2
		end
	end
end

cmdcustomfueltog = create_command("custom/dromader/electrical/fuel_fuse_tog","Toggle fuel needles fuse",cmd_fuel_fuse_tog)

function cmd_bat_selector_up(phase, duration)
	if phase == 0 then
		if bat_sel < 2 then 
			bat_sel = bat_sel + 1 
		end
		if bat_sel == 0 then
			batt = 1
			gpu = 0
		elseif bat_sel == 1 then
			batt = 0
			gpu = 0
		elseif bat_sel == 2 then
			batt = 1
			gpu = 1
		end
	end
end

function cmd_bat_selector_dwn(phase, duration)
	if phase == 0 then
		if bat_sel > 0 then 
			bat_sel = bat_sel - 1 
		end
		if bat_sel == 0 then
			batt = 1
			gpu = 0
		elseif bat_sel == 1 then
			batt = 0
			gpu = 0
		elseif bat_sel == 2 then
			batt = 1
			gpu = 1
		end		
	end
end


cmdcustombatswup = create_command("custom/dromader/electrical/bat_selector_up","Move the power selector up one",cmd_bat_selector_up)
cmdcustombatswdwn = create_command("custom/dromader/electrical/bat_selector_dwn","Move the power selector down one",cmd_bat_selector_dwn)


function cmd_volt_selector_up(phase, duration)
	if phase == 0 then
		if volt_sel < 4 then 
			volt_sel = volt_sel + 1 
		end
	end
end

function cmd_volt_selector_dwn(phase, duration)
	if phase == 0 then
		if volt_sel > 0 then 
			volt_sel = volt_sel - 1 
		end	
	end
end

cmdcustomvoltswup = create_command("custom/dromader/electrical/volt_selector_up","Move the volmeter source selector up one",cmd_volt_selector_up)
cmdcustomvoltswdwn = create_command("custom/dromader/electrical/volt_selector_dwn","Move the volmeter source selector down one",cmd_volt_selector_dwn)

function cmd_volt_but_press(phase, duration)
	if phase == 1 then
		volt_but = 1
	else 
		volt_but = 0
	end
end


cmdcustomvoltbutpress = create_command("custom/dromader/electrical/volt_but","Press voltmeter button",cmd_volt_but_press)


function flight_start()

	starter_fuse = 0
	starter_fail = 6
	inst_light_fuse = 0
	inst_light_fail = 6
	if startup_running == 1 then
		bat_sel = 0
		batt = 1
		gpu = 0
		bus_load_add = bus_load_add + 2
		stall_fuse = 1
		stall_fail = 0
		agk49_fuse = 1
		agk49_fail = 0
		radio_fuse = 1
	else
		bat_sel = 1
		batt = 0
		gpu = 0
		stall_fuse = 0
		stall_fail = 6
		agk49_fuse = 0
		agk49_fail = 6	
		radio_fuse = 0
	end
end

function update_volt_needle()
local tmpval
	if volt_but == 0 then
		if volt_sel == 0 then
			tmpval = bus_amp/4
		elseif volt_sel == 1 then
			tmpval = bus_volt
		elseif volt_sel == 2 then
			tmpval = bus_volt
		elseif volt_sel == 3 then
			tmpval = bat_volt
		elseif volt_sel == 4 then
			if gpu == 1 then
				tmpval = bus_volt
			else 
				tmpval = 0
			end
		end
	else 
		tmpval = bus_volt
	end
	volt_needle = func_animate_slowly(tmpval, volt_needle, 3)
end

function monitor_failures()
	
	if starter_fail == 6 then
		starter_fuse = 0
	end
	
	if inst_light_fail == 6 then
		inst_light_fuse = 0
	end
	
	if stall_fail == 6 then
		stall_fuse = 0
	end
	
	if agk49_fail == 6 then
		if agk_49_fuse == 1 then
			bus_load_add = bus_load_add - 2
		end
		agk49_fuse = 0
	end
	
end

function after_physics()
	update_volt_needle()
	monitor_failures()
end