function dummy()

end

water_quantity = find_dataref("sim/flightmodel/weight/m_jettison")
air_speed = find_dataref("sim/flightmodel/forces/vz_air_on_acf")
prop_wash = find_dataref("sim/flightmodel2/engines/jetwash_mtr_sec[0]")
atom_prop_deg = create_dataref("custom/dromader/spray/atom_prop_ang","number", dummy)
pump_prop_deg = create_dataref("custom/dromader/spray/pump_prop_ang","number", dummy)
pump_prop_deg_sec = create_dataref("custom/dromader/spray/pump_prop_deg_sec","number", dummy)
boom_press = create_dataref("custom/dromader/spray/boom_press","number", dummy)
boom_hide = create_dataref("custom/dromader/spray/boom_hide","number", dummy)
boom_fuse = create_dataref("custom/dromader/spray/boom_fuse","number", dummy)
spray = create_dataref("custom/dromader/spray/spray","number", dummy)

function spray_toggle_cmd(phase, duration)
	if phase == 0 then
		if spray == 0 then
			spray = 1
		else
			spray = 0
		end
	end
end

spraycmd = create_command("custom/dromader/spray/spray_cmd","Toggle spray", spray_toggle_cmd)

function boom_fuse_toggle_cmd(phase, duration)
	if phase == 0 then
		if boom_fuse == 0 then
			boom_fuse = 1
		else
			boom_fuse = 0
		end
	end
end

boomfusecmd = create_command("custom/dromader/spray/boom_fuse_cmd","Toggle boom fuse", boom_fuse_toggle_cmd)

function after_physics()
	if boom_hide == 0 then
		local temp_deg = atom_prop_deg
		temp_deg = temp_deg + math.max(0,air_speed*36*SIM_PERIOD)

		if temp_deg > 360 then
			temp_deg = temp_deg - 360
		end

		atom_prop_deg = temp_deg
		
		if boom_fuse == 1 then
			local temp_pump_deg = pump_prop_deg
			temp_pump_deg = temp_pump_deg + math.max(0,(air_speed +  prop_wash/2) )*36*SIM_PERIOD
			pump_prop_deg_sec = (temp_pump_deg - pump_prop_deg)/(SIM_PERIOD*60)
			boom_press = math.min(1.5, math.max(0, pump_prop_deg_sec/30) )
			if spray == 1 then
				if boom_press > 0.5 then
					boom_press = boom_press - 0.5
				end
			end
			if temp_pump_deg > 360 then
				temp_pump_deg = temp_pump_deg - 360
			end	
			pump_prop_deg = temp_pump_deg
		end	
		
		if water_quantity > 0 and boom_fuse == 1 then
			if spray == 1 then
				water_quantity = water_quantity - 10*boom_press*SIM_PERIOD
			end
		else
			spray = 0
		end
	end
end

