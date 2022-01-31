----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------

water_quantity = find_dataref("sim/flightmodel/weight/m_jettison")
water_quantity_max = find_dataref("sim/aircraft/weight/acf_m_jettison")
acf_weight = find_dataref("sim/flightmodel/weight/m_fixed")
hyd_press_1 = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
hyd_press_2 = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")
bus_volt = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
startup_running = find_dataref("sim/operation/prefs/startup_running")

function dummy()

end




dropping_water_hyd = create_dataref("custom/dromader/water/dropping_water_hyd","number", dummy)
dropping_water_em = create_dataref("custom/dromader/water/dropping_water_em","number", dummy)

hyd_drop = create_dataref("custom/dromader/water/hyd_drop","number", dummy)

em_drop = create_dataref("custom/dromader/water/emergency_drop","number", dummy)
em_drop_handle = create_dataref("custom/dromader/water/emergency_drop_handle","number", dummy)
water_drop_speed = create_dataref("custom/dromader/water/water_drop_speed","number", dummy)
foaming_quantity = create_dataref("custom/dromader/water/foaming_quantity","number", dummy)
foam_switch = create_dataref("custom/dromader/water/foaming_fuse","number", dummy)
foam_add = create_dataref("custom/dromader/water/foam_add","number", dummy)

foaming_qty_ind = create_dataref("custom/dromader/water/foaming_qty_ind","array[7]", dummy)

water_drop_anim = create_dataref("custom/dromader/water/water_drop_anim","number", dummy)
water_drop_em_anim = create_dataref("custom/dromader/water/water_drop_em_anim","number", dummy )

hyd_dump_fuse = create_dataref("custom/dromader/water/hyd_dump_fuse","number", dummy)

foam_quantity_handle = create_dataref("custom/dromader/water/foam_quantity_handle","number", dummy)
water_quantity_handle = create_dataref("custom/dromader/water/water_quantity_handle","number", dummy)

function hyd_drop_toggle_cmd(phase, duration)
	if phase == 1 then
		dropping_water_hyd = 1
	else 
		dropping_water_hyd = 0
	end
end

dropwatercmd = create_command("custom/dromader/water/hyd_drop_toggle","Drop water hydraulic", hyd_drop_toggle_cmd)

local foam_added = 0 --create_dataref("custom/dromader/water/foam_added","number", dummy)
function foam_switch_toggle_cmd(phase, duration)
	if phase <= 1 then
		foam_switch = 1
		
		if foaming_quantity > 0 then
			foam_added = foam_added + SIM_PERIOD
			foaming_quantity = math.max(0 ,foaming_quantity - SIM_PERIOD)
		end
	else
		foam_switch = 0
	end
end

foamingcmd = create_command("custom/dromader/water/foaming_fuse_cmd","Toggle foaming agent", foam_switch_toggle_cmd)

function water_drop_toggle_cmd(phase, duration)
	if phase == 0 then
		if dropping_water_em == 0 then
			dropping_water_em = 1
		elseif dropping_water_em == 1 and water_quantity == 0 and em_drop <= 0.1 then
			dropping_water_em = 0
		end
	end
end

customjetisoncmd = replace_command("sim/flight_controls/jettison_payload", water_drop_toggle_cmd)

function water_dump_dwn_cmd(phase, duration)
	if phase == 0 then
		if dropping_water_em == 0 then
			dropping_water_em = 1
		end
	end
end

function water_dump_up_cmd(phase, duration)
	if phase == 0 then
		if water_quantity == 0 and em_drop <= 0.1 then
			dropping_water_em = 0
		end
	end
end

customjetisonupcmd = create_command("custom/dromader/water/jettison_payload_up", "Close emergency water dump",water_dump_up_cmd)
customjetisondwncmd = create_command("custom/dromader/water/jettison_payload_dwn", "Open emergency water dump",water_dump_dwn_cmd)

function hyd_dump_fuse_toggle_cmd(phase, duration)
	if phase == 0 then
		if hyd_dump_fuse == 0 then
			hyd_dump_fuse = 1
		else
			hyd_dump_fuse = 0
		end
	end
end

hyddumpfusecmd = create_command("custom/dromader/water/hyd_dump_fuse_cmd","Toggle foaming agent", hyd_dump_fuse_toggle_cmd)

function func_animate_slowly(reference_value, animated_VALUE, anim_speed)
  if math.abs(reference_value - animated_VALUE) < 0.01 then return reference_value end
  animated_VALUE = animated_VALUE + ((reference_value - animated_VALUE) * (anim_speed * SIM_PERIOD))
  return animated_VALUE
end

function flight_start()
	--foaming_quantity = 60
	--acf_weight = foaming_quantity
	if startup_running == 1 then
		--foam_switch = 1
		hyd_dump_fuse = 1
	else
		--foam_switch = 0
		hyd_dump_fuse = 0
	end
end

function hydraulic_drop()
		if hyd_drop ~= dropping_water_hyd and (hyd_press_1 > 80 or hyd_press_2 > 80) and em_drop == 0 and hyd_dump_fuse == 1 then
			hyd_drop = func_animate_slowly(dropping_water_hyd, hyd_drop, 5)
		end
		if hyd_drop > 0 and em_drop == 0 then 
			water_drop_speed = math.min(1, hyd_drop*SIM_PERIOD)
			water_quantity = math.max(0 ,water_quantity - water_drop_speed*200)
			foam_added = (foam_add/200)*water_quantity
			if water_quantity > 0 then
				water_drop_anim = hyd_drop
			else
				water_drop_anim = 0
			end			
		end
		if hyd_drop == 0 and water_drop_speed ~= 0 then water_drop_speed = 0 end
end

function emergency_drop()
		if dropping_water_em == 1 then
			
			if em_drop_handle < 0.1 then
				em_drop_handle = func_animate_slowly(dropping_water_em, em_drop_handle, 10)
				em_drop = em_drop_handle * 0.1
			elseif em_drop_handle > 0.1 then
				
				em_drop_handle = func_animate_slowly(dropping_water_em, em_drop_handle, 10)
				if water_quantity < 200 and em_drop_handle > 0 then
					em_drop = func_animate_slowly(0.1, em_drop, 4)
				else 
					em_drop = func_animate_slowly(dropping_water_em, em_drop, 10)
				end
			end
		elseif dropping_water_em == 0 and em_drop_handle > 0 then
				em_drop_handle = func_animate_slowly(dropping_water_em, em_drop_handle, 10)
				if water_quantity == 0 and em_drop <= 0.1 then
					if em_drop_handle < 1 then 
						em_drop = em_drop_handle*0.1
					end
				end			
		end
		if em_drop > 0 then 
			water_drop_speed = math.min(1, em_drop*SIM_PERIOD)
			water_quantity = math.max(0 ,water_quantity - water_drop_speed*2000)
			foam_added = (foam_add/200)*water_quantity 

			if water_quantity > 0 then
				water_drop_em_anim = em_drop
			else
				water_drop_em_anim = 0
				water_drop_speed = 0
			end			
		end
end

function after_physics()
	hydraulic_drop()
	emergency_drop()
	if water_quantity_handle > 0.1 and em_drop == 0 and hyd_drop == 0 then
		water_quantity =  math.min(water_quantity_max, water_quantity + 50*water_quantity_handle*SIM_PERIOD)
	end
	if foam_quantity_handle > 0.1 and em_drop == 0 and hyd_drop == 0 then
		foaming_quantity =  math.min(60, foaming_quantity + 3*foam_quantity_handle*SIM_PERIOD)
	end
	if water_quantity > 0 then
		foam_add = ((foam_added/water_quantity)*100)*2	
	end
	if bus_volt > 18 then
		for i = 0, 6 do
			local fq = math.floor(foaming_quantity/10 + 0.5)
			if fq == i then 
				foaming_qty_ind[i] = 1
			else
				foaming_qty_ind[i] = 0
			end
		end
	else 
		for i = 0, 6 do
			foaming_qty_ind[i] = 0
		end
	end
		
end

function after_replay()
	if bus_volt > 18 then
		for i = 0, 6 do
			local fq = math.floor(foaming_quantity/10 + 0.5)
			if fq == i then 
				foaming_qty_ind[i] = 1
			else
				foaming_qty_ind[i] = 0
			end
		end
	else 
		for i = 0, 6 do
			foaming_qty_ind[i] = 0
		end
	end

	if hyd_drop > 0 and em_drop == 0 then 
		water_drop_speed = math.min(1, hyd_drop*SIM_PERIOD)
		if water_quantity > 0 and hyd_drop > 0 then
			water_drop_anim = hyd_drop
		else
			water_drop_anim = 0
		end			
	end		

	if em_drop > 0 then 
		water_drop_speed = math.min(1, em_drop*SIM_PERIOD)
		if water_quantity > 0 and em_drop > 0 then
			water_drop_em_anim = em_drop
		else
			water_drop_em_anim = 0
		end			
	end

end