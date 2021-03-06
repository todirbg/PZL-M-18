----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2021
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

water_quantity = find_dataref("sim/flightmodel/weight/m_jettison")
acf_cd = find_dataref("sim/aircraft/bodies/acf_fuse_cd")
air_speed = find_dataref("sim/flightmodel/forces/vz_air_on_acf")
prop_wash = find_dataref("sim/flightmodel2/engines/jetwash_mtr_sec[0]")
atom_prop_deg = create_dataref("custom/dromader/spray/atom_prop_ang","number", dummy)
pump_prop_deg = create_dataref("custom/dromader/spray/pump_prop_ang","number", dummy)
pump_prop_deg_sec = create_dataref("custom/dromader/spray/pump_prop_deg_sec","number", dummy)
boom_press = create_dataref("custom/dromader/spray/boom_press","number", dummy)
boom_hide = create_dataref("custom/dromader/spray/boom_hide","number", dummy)
boom_fuse = create_dataref("custom/dromader/spray/boom_fuse","number", dummy)
spray = create_dataref("custom/dromader/spray/spray","number", dummy)
spray_sw = create_dataref("custom/dromader/spray/spray_sw","number", dummy)

local acf_cg_save = acf_cd

function ag_equip_toggle_cmd(phase, duration)
	if phase == 0 then
		if boom_hide == 0 then
			boom_hide = 1
			acf_cd = acf_cg_save
			boom_press = 0
		else
			boom_hide = 0
			acf_cd = acf_cg_save*3
		end
	end
end

agequiptogcmd = create_command("custom/dromader/spray/ag_equip_tog_cmd","Toggle AG equipment", ag_equip_toggle_cmd)

function spray_toggle_cmd(phase, duration)
	if phase == 0 then
		if spray_sw == 0 then 
			spray_sw = 1
			if water_quantity > 0 and boom_fuse == 1 and boom_hide == 0 then
				spray = 1
			end		
		else
			spray_sw = 0
			spray = 0
		end
	end
end

spraytogcmd = create_command("custom/dromader/spray/spray_tog_cmd","Toggle spray", spray_toggle_cmd)

function spray_cmd(phase, duration)
	if phase == 0 then
		if spray == 0 and water_quantity > 0 and boom_fuse == 1 and boom_hide == 0 then
			spray = 1
		end
	elseif phase == 1 then	
			if water_quantity < 0 or boom_fuse == 0 then
				spray = 0
				boom_press = 0
			end
	elseif phase == 2 then
			spray = 0
	end
end

spraycmd = create_command("custom/dromader/spray/spray_cmd","Engage spray", spray_cmd)

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

function flight_start()
	boom_hide = 1
end

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
			if  water_quantity > 0 then
				boom_press = math.min(1.5, math.max(0, pump_prop_deg_sec/30) )
			else
				boom_press = 0
			end
			if spray == 1 then
				boom_press = math.max(0, boom_press - boom_press*0.25)
			end
			if temp_pump_deg > 360 then
				temp_pump_deg = temp_pump_deg - 360
			end	
			pump_prop_deg = temp_pump_deg
		end	
		
		if water_quantity > 0 and boom_fuse == 1 then
			if spray == 1 then
				water_quantity = water_quantity - 30*boom_press*SIM_PERIOD/60 --30 lit/min at 1bar - 10*3 l/min
			end
		else
			spray = 0
		end
	end
end

