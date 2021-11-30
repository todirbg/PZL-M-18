----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()
--do nothing
end

bat_sel = create_dataref("custom/dromader/electrical/battery_sw","number", dummy)
volt_sel = create_dataref("custom/dromader/electrical/volt_src","number", dummy)
volt_needle = create_dataref("custom/dromader/electrical/volt_needle","number", dummy)

batt = find_dataref("sim/cockpit2/electrical/battery_on[0]")
gpu = find_dataref("sim/cockpit/electrical/gpu_on")
startup_running = find_dataref("sim/operation/prefs/startup_running")

running_eng = find_dataref("sim/flightmodel/engine/ENGN_running[0]")

bus_amp = find_dataref("sim/cockpit2/electrical/bus_load_amps[0]")
bus_amp2 = find_dataref("sim/cockpit2/electrical/bus_load_amps[1]")
bus_amp3 = find_dataref("sim/cockpit2/electrical/bus_load_amps[2]")
bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bat_volt =  find_dataref("sim/cockpit2/electrical/battery_voltage_indicated_volts[0]")
bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")
gen_off = find_dataref("sim/cockpit/warnings/annunciators/generator_off[0]")

ldg_lt = find_dataref("sim/cockpit2/switches/landing_lights_on")
taxi_lt = find_dataref("sim/cockpit2/switches/taxi_light_on")
nav_lt = find_dataref("sim/cockpit2/switches/navigation_lights_on")
strobe_lt = find_dataref("sim/cockpit2/switches/strobe_lights_on")
beacon_lt = find_dataref("sim/cockpit2/switches/beacon_on")

elec_hyd = find_dataref("sim/cockpit2/switches/electric_hydraulic_pump_on")
stat_heat = find_dataref("sim/cockpit/switches/static_heat_on")

door5_ratio = find_dataref("sim/flightmodel2/misc/door_open_ratio[4]")

fuel_fuse = create_dataref("custom/dromader/electrical/fuel_fuse","number", dummy)

kill_gpu = create_dataref("custom/dromader/electrical/kill_gpu","number", dummy) --0 connected/ 1 disconnected
spd_dr = find_dataref("sim/flightmodel/position/groundspeed")


stall_fuse = create_dataref("custom/dromader/electrical/stall_fuse","number", dummy)
stall_fail = find_dataref("sim/operation/failures/rel_stall_warn")

inst_brt = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")

heater_sw = create_dataref("custom/dromader/electrical/heater","number", dummy)

vent_fuse = create_dataref("custom/dromader/electrical/vent","number", dummy)
fan_ang_deg = create_dataref("custom/dromader/electrical/fan_ang_deg","number", dummy)

wiper_fuse = create_dataref("custom/dromader/electrical/wiper","number", dummy)
wiper_speed = find_dataref("sim/cockpit2/switches/wiper_speed")

inst_light_fuse = create_dataref("custom/dromader/electrical/instruments_light","number", dummy)
inst_light_fail = find_dataref("sim/operation/failures/rel_clights")

agk49_fuse = create_dataref("custom/dromader/electrical/agk49_power","number", dummy)
agk49_fail = find_dataref("sim/operation/failures/rel_invert0")

radio_fuse = create_dataref("custom/dromader/electrical/radio_power","number", dummy)
radio_fail = find_dataref("sim/operation/failures/rel_esys2")

transponder_fuse = create_dataref("custom/dromader/electrical/transponder_power","number", dummy)
transponder_fail = find_dataref("sim/operation/failures/rel_esys3")
inverter_on = find_dataref("sim/cockpit2/electrical/inverter_on[0]")

bat_cover_hide = create_dataref("custom/dromader/electrical/hide_bat_cover","number", dummy)

primed_ratio = find_dataref("custom/dromader/engine/primed_ratio")



local volt_but = 0

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

open_door5_cmd = find_command("sim/flight_controls/door_open_5")
function cmd_bat_cover_tog(phase, duration)
	if phase == 0 then
		if bat_cover_hide == 0 then
			bat_cover_hide = 1
		else
			bat_cover_hide = 0
			if door5_ratio == 0 and kill_gpu == 0 then
				open_door5_cmd:once()
			end
		end
	end
end

cmdcustombatcvrtog = create_command("custom/dromader/electrical/bat_cover_tog","Toggle battery cover",cmd_bat_cover_tog)

function cmd_agk49_fuse_tog(phase, duration)
	if phase == 0 then
		if agk49_fuse == 0 then
			agk49_fuse = 1
			agk49_fail = 0
			inverter_on = 1
		else
			agk49_fuse = 0
			agk49_fail = 6
			inverter_on = 0
		end
	end
end

cmdcustomagk49tog = create_command("custom/dromader/electrical/agk49_pwr_cmd","Toggle AGK-49 fuse",cmd_agk49_fuse_tog)

function cmd_radio_fuse_tog(phase, duration)
	if phase == 0 then
		if radio_fuse == 0 then
			radio_fuse = 1
			radio_fail = 0
			bus_load_add = bus_load_add + 5
		else
			radio_fuse = 0
			radio_fail = 6
			bus_load_add = bus_load_add - 5
		end
	end
end

cmdcustomradiotog = create_command("custom/dromader/electrical/radio_pwr_cmd","Toggle radio fuse",cmd_radio_fuse_tog)

function cmd_transponder_fuse_tog(phase, duration)
	if phase == 0 then
		if transponder_fuse == 0 then
			transponder_fuse = 1
			transponder_fail = 0
			bus_load_add = bus_load_add + 5
		else
			transponder_fuse = 0
			transponder_fail = 6
			bus_load_add = bus_load_add - 5
		end
	end
end

cmdcustomtranspondertog = create_command("custom/dromader/electrical/transponder_pwr_cmd","Toggle transponder fuse",cmd_transponder_fuse_tog)

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

function cmd_door5_close_wrap_handler(phase, duration)
	if phase == 0 then
		kill_gpu = 1
		gpu = 0
	end
end

cmddooor5closewrap = wrap_command("sim/flight_controls/door_close_5", dummy, cmd_door5_close_wrap_handler)

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
			batt = 0		
			if kill_gpu == 0 then
				gpu = 1
			end
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
			batt = 0
			if kill_gpu == 0 then
				gpu = 1
			end
		end
	end
end


cmdcustombatswup = create_command("custom/dromader/electrical/bat_selector_up","Move the power selector up one",cmd_bat_selector_up)
cmdcustombatswdwn = create_command("custom/dromader/electrical/bat_selector_dwn","Move the power selector down one",cmd_bat_selector_dwn)

function cmd_gpu_connect_tog(phase, duration)
	if phase == 0 then
		if kill_gpu == 0 then
			kill_gpu = 1
			gpu = 0
		else
			kill_gpu = 0
			if bat_sel == 2 then
				gpu = 1
			end
		end
	end
end

cmdcustomgpuconnecttog = create_command("custom/dromader/electrical/gpu_connect_tog","Toggle GPU",cmd_gpu_connect_tog)

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

fuel_press_dromader = find_dataref("custom/dromader/fuel/fuel_press")
function auto_start_after()
		inst_light_fuse = 0
		inst_light_fail = 6
		bat_sel = 0
		batt = 1
		gpu = 0
		kill_gpu = 1
--		stall_fuse = 1
--		stall_fail = 0
--		agk49_fuse = 1
--		agk49_fail = 0
--		radio_fuse = 1
--		radio_fail = 0
--		transponder_fuse = 1
--		transponder_fail = 0
		fuel_fuse = 1
		heater_sw = 0
		vent_fuse = 0
		ldg_lt = 0
		taxi_lt = 0
		nav_lt = 0
		strobe_lt = 0
		beacon_lt = 1
--		elec_hyd = 1
		stat_heat = 0
		bus_load_add = 10
        fuel_press_dromader = 35
		primed_ratio = 1
end

function auto_board_after()
		inst_light_fuse = 0
		inst_light_fail = 6
		bat_sel = 0
		batt = 1
		gpu = 0
--		stall_fuse = 1
--		stall_fail = 0
--		agk49_fuse = 1
--		agk49_fail = 0
--		radio_fuse = 1
--		radio_fail = 0
--		transponder_fuse = 1
--		transponder_fail = 0
		fuel_fuse = 1
		heater_sw = 0
		vent_fuse = 0
		ldg_lt = 0
		taxi_lt = 0
		nav_lt = 0
		strobe_lt = 0
		beacon_lt = 1
--		elec_hyd = 1
		stat_heat = 0
end


quickstart = wrap_command("sim/operation/quick_start", dummy, auto_start_after)
autostart = wrap_command("sim/operation/auto_start", dummy, auto_start_after)
autoboard = wrap_command("sim/operation/auto_board", dummy, auto_board_after)


function flight_start()

	inst_light_fuse = 0
	inst_light_fail = 6
	kill_gpu = 1
	if startup_running == 1 then
		bat_sel = 0
		batt = 1
		gpu = 0
		stall_fuse = 1
		stall_fail = 0
		agk49_fuse = 1
		agk49_fail = 0
		radio_fuse = 1
		radio_fail = 0
		transponder_fuse = 1
		transponder_fail = 0
		fuel_fuse = 1
		elec_hyd = 1
		bus_load_add = 10
	else
		bat_sel = 1
		batt = 0
		gpu = 0
		stall_fuse = 0
		stall_fail = 6
		agk49_fuse = 0
		agk49_fail = 6
		radio_fuse = 0
		radio_fail = 6
		transponder_fuse = 0
		transponder_fail = 6
		elec_hyd = 0
	end
end

function update_volt_needle()
local tmpval
	if batt == 1 or gpu == 1 then
		if volt_but == 0 then
			if volt_sel == 0 then
				if gen_off == 1 and gpu == 0 then
					tmpval = (bus_amp + bus_amp2 + bus_amp3)/4
				else
					tmpval = (bus_amp + bus_amp2 + bus_amp3)/4 - 20
				end
			elseif volt_sel == 1 then
				tmpval = bus_volt
			elseif volt_sel == 2 then
				if running_eng == 1 and gen_off == 0 then
					tmpval = bus_volt
				else
					tmpval = 0
				end
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
	else
		tmpval = 0
	end
	volt_needle = func_animate_slowly(tmpval, volt_needle, 2)
end

function monitor_failures()

	if bus_amp > 100 then
		bat_sel = 1
		batt = 0
		gpu = 0
	end

	if inst_light_fail == 6 then
		inst_light_fuse = 0
	end

	if stall_fail == 6 then
		stall_fuse = 0
	end

	if agk49_fail == 6 then
		if agk49_fuse == 1 then
			agk49_fuse = 0
			inverter_on = 0
		end
	end

	if radio_fail == 6 then
		if radio_fuse == 1 then
			radio_fuse = 0
		end
	end

	if transponder_fail == 6 then
		if transponder_fuse == 1 then
			transponder_fuse = 0
		end
	end

end

function after_physics()
	update_volt_needle()
	monitor_failures()
	
	if vent_fuse == 1 and bus_volt > 18 then 
		
		fan_ang_deg = fan_ang_deg + (100*bus_volt)*SIM_PERIOD
		
		if fan_ang_deg > 360 then 
				fan_ang_deg = fan_ang_deg - 360 
		end
		
	end

	if kill_gpu == 0 and spd_dr > 0.1 then
			kill_gpu = 1
	end
end

function after_replay()
	if vent_fuse == 1 and bus_volt > 18 then 
		
		fan_ang_deg = fan_ang_deg + (100*bus_volt)*SIM_PERIOD
		
		if fan_ang_deg > 360 then 
				fan_ang_deg = fan_ang_deg - 360 
		end
		
	end		
end
