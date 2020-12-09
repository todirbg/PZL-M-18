bat_sel = create_dataref("custom/dromader/electrical/battery_sw","number")
volt_sel = create_dataref("custom/dromader/electrical/volt_src","number")
volt_needle = create_dataref("custom/dromader/electrical/volt_needle","number")

batt = find_dataref("sim/cockpit2/electrical/battery_on[0]")
gpu = find_dataref("sim/cockpit/electrical/gpu_on")
startup_running = find_dataref("sim/operation/prefs/startup_running")


bus_amp = find_dataref("sim/cockpit2/electrical/bus_load_amps[0]")
bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bat_volt =  find_dataref("sim/cockpit2/electrical/battery_voltage_indicated_volts[0]")

local volt_but = 0

function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
  if math.abs(reference_value - animated_VALUE) < 0.1 then return reference_value end
  animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * (anim_speed * SIM_PERIOD))
  return animated_VALUE
end

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


	if startup_running == 1 then
		bat_sel = 0
		batt = 1
		gpu = 0
		--avionics = 1
	else
		bat_sel = 1
		batt = 0
		gpu = 0
		--avionics = 0
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
	volt_needle = func_animate_slowly(tmpval, volt_needle, 5)
end

function after_physics()
	update_volt_needle()
	
end