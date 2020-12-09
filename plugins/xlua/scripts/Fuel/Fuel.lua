
fuel_tank_selector = find_dataref("sim/cockpit2/fuel/fuel_tank_selector") -- (0=none,1=left,2=center,3=right,4=all)
startup_running = find_dataref("sim/operation/prefs/startup_running")

fuel_press = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[0]")
ovveride_fuel = find_dataref("sim/operation/override/override_fuel_system")
bus_volts = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")

fuel_flow_before_engine = find_dataref("sim/flightmodel2/engines/has_fuel_flow_before_mixture[0]")
fuel_flow = find_dataref("sim/flightmodel/engine/ENGN_FF_[0]")
engn_running = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
fuel_quantity_left = find_dataref("sim/flightmodel/weight/m_fuel[0]")
fuel_quantity_right = find_dataref("sim/flightmodel/weight/m_fuel[1]")
engn_tacrad = find_dataref("sim/flightmodel/engine/ENGN_tacrad[0]")

fuel_pump_spinning = find_dataref("sim/flightmodel2/engines/fuel_pump_spinning[0]")



local cutoff = 1
local press = 0
local man_press = 0
local flooded = 0
function fuel_cutoff_handler()
	if fuel_cutoff_selector > 0.7 then
		cutoff = 1
	elseif fuel_cutoff_selector < 0.3 then
		cutoff = 0
	end
end

fuel_cutoff_selector = create_dataref("custom/dromader/fuel/fuel_valve_handle","number", fuel_cutoff_handler) -- (0=none,1=fuel cutoff)

fuel_quantity_dromader_L = create_dataref("custom/dromader/fuel/fuel_quantity_L","number")
fuel_quantity_dromader_R = create_dataref("custom/dromader/fuel/fuel_quantity_R","number")

fuel_fuse = create_dataref("custom/dromader/electrical/fuel_fuse","number")
fuel_press_dromader = create_dataref("custom/dromader/electrical/fuel_press","number")
fuel_tank_selector_handle = create_dataref("custom/dromader/fuel/fuel_selector","number") -- (1=left,2=all,3=right)


local prev = 0 --manual_fuel_pump
function man_fuel_pump_handler()
	if manual_fuel_pump < prev then
		press = press + 20*SIM_PERIOD
	end
	prev = manual_fuel_pump
	if man_press > 50 then flooded = 1 end
end

manual_fuel_pump = create_dataref("custom/dromader/electrical/fuel_pump","number", man_fuel_pump_handler)

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

cmdcustomfueltog = create_command("custom/dromader/fuel/fuel_fuse_tog","Toggle fuel needles fuse",cmd_fuel_fuse_tog)

function update_fuel_needles()
	if fuel_fuse == 1 and bus_volts > 18 then
		fuel_quantity_dromader_L = func_animate_slowly(fuel_quantity_left, fuel_quantity_dromader_L, 5)
		fuel_quantity_dromader_R = func_animate_slowly(fuel_quantity_right, fuel_quantity_dromader_R, 5)
	else
		fuel_quantity_dromader_L = func_animate_slowly(0, fuel_quantity_dromader_L, 5)
		fuel_quantity_dromader_R = func_animate_slowly(0, fuel_quantity_dromader_R, 5)	
	end
end

function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
  if math.abs(reference_value - animated_VALUE) < 0.1 then return reference_value end
  animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * (anim_speed * SIM_PERIOD))
  return animated_VALUE
end

function cmd_fuel_selector_up(phase, duration)
	if phase == 0 then
		if fuel_tank_selector_handle < 3 then
			fuel_tank_selector_handle = fuel_tank_selector_handle + 1	
		end
	end
end

function cmd_fuel_selector_dwn(phase, duration)
	if phase == 0 then
		if fuel_tank_selector_handle > 1 then
			fuel_tank_selector_handle = fuel_tank_selector_handle - 1
		end
	end
end



function cmd_fuel_cutoff(phase, duration)
	if phase == 0 then
		if fuel_cutoff_selector == 0 then
			fuel_cutoff_selector = 1
			cutoff = 1
		else
			fuel_cutoff_selector = 0
			cutoff = 0
		end
	end
end

cmdcustomfuelup = create_command("custom/dromader/fuel/fuel_selector_up","Move the fuel selector up one",cmd_fuel_selector_up)
cmdcustomfueldwn = create_command("custom/dromader/fuel/fuel_selector_dwn","Move the fuel selector down one",cmd_fuel_selector_dwn)
cmdcustomfuelshutoff = create_command("custom/dromader/fuel/shut_down","Toggle fuel valve",cmd_fuel_cutoff)


function flight_start()
	ovveride_fuel = 1

	if startup_running == 1 then
		--fuel_cutoff_selector = 0
		fuel_tank_selector_handle = 2
		fuel_fuse = 1
		bus_load_add = bus_load_add + 2
		press = 20
	else
		--fuel_cutoff_selector = 1
		fuel_tank_selector_handle = 2
		fuel_fuse = 0
		press = 0
	end
end

function aircraft_unload()
	ovveride_fuel = 0
end
local nofuel = 0
function tank_check_empty(tank_quantity)
	if tank_quantity < 0 then 
		nofuel = 1
	else
		nofuel = 0
	end
end

function update_fuel_press()

	
	if cutoff == 0 and nofuel == 0 then 
		press = math.max(press, math.sqrt(6*math.abs(engn_tacrad)))
		press = math.max(0, press - fuel_flow)
	else
		press = math.max(0, press - fuel_flow)
		
	end
	fuel_press_dromader = press
end

function after_physics()
	update_fuel_needles()
	update_fuel_press()
	if engn_running == 1 and fuel_flow_before_engine == 1 then --uses fuel only when running
		if fuel_tank_selector_handle == 1 then
			fuel_quantity_left = fuel_quantity_left - fuel_flow * SIM_PERIOD --normalized per frame fuel flow
			tank_check_empty(fuel_quantity_left)
		elseif fuel_tank_selector_handle == 2 then
			local ff = fuel_flow/2 * SIM_PERIOD
			fuel_quantity_left = fuel_quantity_left - ff
			fuel_quantity_right = fuel_quantity_right - ff
			tank_check_empty(fuel_quantity_left + fuel_quantity_right)
		elseif fuel_tank_selector_handle == 3 then
			fuel_quantity_right = fuel_quantity_right - fuel_flow * SIM_PERIOD
			tank_check_empty(fuel_quantity_right)
		end
	end
	if cutoff==1 or nofuel==1 or press < 15 then
		fuel_flow_before_engine = 0
	else
		fuel_flow_before_engine = 1
	end
	
end