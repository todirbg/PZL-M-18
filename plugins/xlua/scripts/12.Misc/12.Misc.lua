----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

function tension_handle_handler()

end

audio_vol_com1 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1")
audio_vol_nav1 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")

function audio_vol_handler()
	audio_vol_com1 = audio_vol
	audio_vol_nav1 = audio_vol
end

draw_fires = find_dataref("sim/graphics/settings/draw_forestfires")
static_heat = find_dataref("sim/cockpit/switches/static_heat_on")

park_brake = find_dataref("sim/cockpit2/controls/parking_brake_ratio")
left_brake = find_dataref("sim/cockpit2/controls/left_brake_ratio")
right_brake = find_dataref("sim/cockpit2/controls/right_brake_ratio")


audio_com1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
audio_nav1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")

tension_handle = create_dataref("custom/dromader/misc/tension_handle","number", tension_handle_handler)

audio_sw = create_dataref("custom/dromader/misc/audio_sw","number", dummy)
audio_vol = create_dataref("custom/dromader/misc/audio_vol","number", audio_vol_handler)

compass_lock_knob = create_dataref("custom/dromader/compass/compass_lock_knob","number", dummy)
compass_heading_dromader = create_dataref("custom/dromader/compass/compass_heading","number", dummy)
compass_g_side_dromader = create_dataref("custom/dromader/compass/compass_g_side","number", dummy)
compass_g_nrml_dromader= create_dataref("custom/dromader/compass/compass_g_nrml","number", dummy)

compass_heading = find_dataref("sim/cockpit2/gauges/indicators/compass_heading_deg_mag")
compass_g_side = find_dataref("sim/flightmodel/forces/g_side")
compass_g_nrml = find_dataref("sim/flightmodel/forces/g_nrml")

pilot_show_int = create_dataref("custom/dromader/misc/show_pilot","number", dummy)
pilot_show_head = create_dataref("custom/dromader/misc/show_head","number", dummy)
pilot_head_x = find_dataref("sim/graphics/view/pilots_head_x")
pilot_head_y = find_dataref("sim/graphics/view/pilots_head_y")
pilot_head_z = find_dataref("sim/graphics/view/pilots_head_z")
ext_view = find_dataref("sim/graphics/view/view_is_external")


door_detach_L = find_dataref("sim/operation/failures/rel_aftbur0")
door_detach_R = find_dataref("sim/operation/failures/rel_aftbur1")

chocks = create_dataref("custom/dromader/misc/chocks","number", dummy)
pitot_cover = create_dataref("custom/dromader/misc/pitot_cover","number", dummy)
pitot_fail = find_dataref("sim/operation/failures/rel_pitot")

air_int_cover = create_dataref("custom/dromader/misc/air_intake_cover","number", dummy)
air_int_fail = find_dataref("custom/dromader/mixture/mixture_fail")

oil_rad_cover = create_dataref("custom/dromader/misc/oil_radiator_cover","number", dummy)
oil_rad_fail = find_dataref("custom/dromader/engine/oil_rad_fail")

ail_right_lock = create_dataref("custom/dromader/misc/right_aeleron_lock","number", dummy)
ail_right_fail = find_dataref("sim/operation/failures/rel_fc_ail_R")

ail_left_lock = create_dataref("custom/dromader/misc/left_aeleron_lock","number", dummy)
ail_left_fail = find_dataref("sim/operation/failures/rel_fc_ail_L")

elev_right_lock = create_dataref("custom/dromader/misc/right_elevator_lock","number", dummy)
elev_up_fail = find_dataref("sim/operation/failures/rel_fc_elv_U")

elev_left_lock = create_dataref("custom/dromader/misc/left_elevator_lock","number", dummy)
elev_down_fail = find_dataref("sim/operation/failures/rel_fc_elv_D")

rudder_lock = create_dataref("custom/dromader/misc/rudder_lock","number", dummy)
rudder_L_fail = find_dataref("sim/operation/failures/rel_fc_rud_L")
rudder_R_fail = find_dataref("sim/operation/failures/rel_fc_rud_R")

elev_trim_fail = find_dataref("sim/operation/failures/rel_trim_elv")
ail_trim_fail = find_dataref("sim/operation/failures/rel_trim_ail")
rud_trim_fail = find_dataref("sim/operation/failures/rel_trim_rud")

stick_roll = find_dataref("sim/joystick/yoke_roll_ratio")
stick_pitch = find_dataref("sim/joystick/yoke_pitch_ratio")
pedals_yaw = find_dataref("sim/joystick/yoke_heading_ratio")

startup_running = find_dataref("sim/operation/prefs/startup_running")

spd_dr = find_dataref("sim/flightmodel/position/groundspeed")

function emer_handle_R_handler()
	if emer_handle_R == 1 then
		door_detach_R = 6
	end

end

function emer_handle_L_handler()
	if emer_handle_L == 1 then
		door_detach_L = 6
	end
end

emer_handle_R = create_dataref("custom/dromader/misc/emer_handle_R","number", emer_handle_R_handler)
emer_handle_L = create_dataref("custom/dromader/misc/emer_handle_L","number", emer_handle_L_handler)


function brake_cmd_after(phase, duration)
	left_brake = park_brake
	right_brake = park_brake
end

cmdcsutombrakeregtog = wrap_command("sim/flight_controls/brakes_toggle_regular", dummy, brake_cmd_after)
cmdcsutombrakemaxtog = wrap_command("sim/flight_controls/brakes_toggle_max", dummy, brake_cmd_after)
cmdcsutombrakereghold = wrap_command("sim/flight_controls/brakes_regular", dummy, brake_cmd_after)
cmdcsutombrakemaxhold = wrap_command("sim/flight_controls/brakes_max", dummy, brake_cmd_after)

function cmd_audiosw_up(phase, duration)
	if phase == 0 then
		audio_sw = math.min(2, audio_sw + 1)
		if audio_sw == 1 then
			audio_com1 = 0
			audio_nav1 = 0
		elseif audio_sw == 2 then
			audio_com1 = 0
			audio_nav1 = 1
		end
	end
end

function cmd_audiosw_dn(phase, duration)
	if phase == 0 then
		audio_sw = math.max(0, audio_sw - 1)
		if audio_sw == 0 then
			audio_com1 = 1
			audio_nav1 = 0
		elseif audio_sw == 1 then
			audio_com1 = 0
			audio_nav1 = 0
		end
	end
end


cmdcsutomaudioswup = create_command("custom/dromader/misc/audio_sw_up","Audio switch up",cmd_audiosw_up)
cmdcsutomaudioswdwn = create_command("custom/dromader/misc/audio_sw_dwn","Audio switch down",cmd_audiosw_dn)

function cmd_compasslock(phase, duration)
	if phase == 0 then
		compass_lock_knob = 1
	end
end

function cmd_compassunlock(phase, duration)
	if phase == 0 then
		compass_lock_knob = 0
	end
end

function cmd_compasslock_tog(phase, duration)
	if phase == 0 then
		if compass_lock_knob == 0 then
			compass_lock_knob = 1
		else
			compass_lock_knob = 0
		end
	end
end

cmdcsutomcompasslock = create_command("custom/dromader/compass/compass_lock","Compass lock",cmd_compasslock)
cmdcsutomcompassunlock = create_command("custom/dromader/compass/compass_unlock","Compass unlock",cmd_compassunlock)
cmdcsutomcompasslocktog = create_command("custom/dromader/compass/compass_lock_tog","Compass lock toggle",cmd_compasslock_tog)


function cmd_chocks_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if chocks == 0 then
			chocks = 1
			park_brake = 1
		else
			chocks = 0
			if left_brake == 0 and right_brake == 0 then
				park_brake = 0
			end
		end
	end
end

cmdcsutomchockstog = create_command("custom/dromader/misc/chocks_tog","Toggle chocks",cmd_chocks_tog)

function cmd_pitot_cover_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if pitot_cover == 0 then
			pitot_cover = 1
			pitot_fail = 6
		else
			pitot_cover = 0
			pitot_fail = 0
		end
	end
end

cmdcsutompitotcovertog = create_command("custom/dromader/misc/pitot_cover_tog","Toggle pitot cover",cmd_pitot_cover_tog)

function cmd_air_int_cover_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if air_int_cover == 0 then
			air_int_cover = 1
			air_int_fail = 1
		else
			air_int_cover = 0
			air_int_fail = 0
		end
	end
end

cmdcsutomairintcovertog = create_command("custom/dromader/misc/air_int_cover_tog","Toggle air intake cover",cmd_air_int_cover_tog)

function cmd_oil_rad_cover_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if oil_rad_cover == 0 then
			oil_rad_cover = 1
			oil_rad_fail = 1
		else
			oil_rad_cover = 0
			oil_rad_fail = 0
		end
	end
end

cmdcsutomoilradcovertog = create_command("custom/dromader/misc/oil_rad_cover_tog","Toggle oil radiator cover",cmd_oil_rad_cover_tog)

function cmd_ailr_lock_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if ail_right_lock == 0 then
			ail_right_lock = 1
			ail_right_fail = 6
			ail_left_fail = 6
			ail_trim_fail = 6
		else
			ail_right_lock = 0
			if ail_left_lock == 0 then
				ail_right_fail = 0
				ail_left_fail = 0	
				ail_trim_fail = 0
			end
		end
	end
end

cmdcsutomailrlocktog = create_command("custom/dromader/misc/right_ail_lock_tog","Toggle right aileron lock",cmd_ailr_lock_tog)

function cmd_aill_lock_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if ail_left_lock == 0 then
			ail_left_lock = 1
			ail_right_fail = 6
			ail_left_fail = 6
			ail_trim_fail = 6
		else
			ail_left_lock = 0
			if ail_right_lock == 0 then
				ail_right_fail = 0
				ail_left_fail = 0	
				ail_trim_fail = 0
			end
		end
	end
end

cmdcsutomailllocktog = create_command("custom/dromader/misc/left_ail_lock_tog","Toggle left aileron lock",cmd_aill_lock_tog)

function cmd_elevr_lock_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if elev_right_lock == 0 then
			elev_right_lock = 1
			elev_up_fail = 6
			elev_down_fail = 6
			elev_trim_fail = 6
		else
			elev_right_lock = 0
			if elev_left_lock == 0 then
				elev_up_fail = 0
				elev_down_fail = 0	
				elev_trim_fail = 0
			end
		end
	end
end

cmdcsutomelevrlocktog = create_command("custom/dromader/misc/right_elev_lock_tog","Toggle elevator aileron lock",cmd_elevr_lock_tog)

function cmd_elevl_lock_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if elev_left_lock == 0 then
			elev_left_lock = 1
				elev_up_fail = 6
				elev_down_fail = 6
				elev_trim_fail = 6
		else
			elev_left_lock = 0
			if elev_right_lock == 0 then
				elev_up_fail = 0
				elev_down_fail = 0		
				elev_trim_fail = 0
			end
		end
	end
end

cmdcsutomelevllocktog = create_command("custom/dromader/misc/left_elev_lock_tog","Toggle left elevator lock",cmd_elevl_lock_tog)

function cmd_rud_lock_tog(phase, duration)
	if phase == 0 and spd_dr< 0.1 then
		if rudder_lock == 0 then
			rudder_lock = 1
			rudder_L_fail = 6
			rudder_R_fail = 6
			rud_trim_fail = 6
		else
			rudder_lock = 0
			rudder_L_fail = 0
			rudder_R_fail = 0
			rud_trim_fail = 0
		end
	end
end

cmdcsutomrudlocktog = create_command("custom/dromader/misc/rudder_lock_tog","Toggle rudder lock",cmd_rud_lock_tog)

local fires_temp = draw_fires

function aircraft_load()
	draw_fires = 1
end

function flight_start()
	tension_handle = 0.5
	static_heat = 0
	audio_com1 = 1
	audio_nav1 = 0
	audio_sw = 0
	audio_vol = 0.8
	audio_vol_com1 = audio_vol
	audio_vol_nav1 = audio_vol
	compass_lock_knob = 0
	left_brake = park_brake
	right_brake = park_brake
	park_brake = 0
	if startup_running == 0 then
		chocks = 1
		pitot_cover = 1
		pitot_fail = 6
		air_int_cover = 1
		air_int_fail = 1
		oil_rad_cover = 1
		oil_rad_fail = 1
		ail_left_lock = 1
		ail_right_lock = 1
		ail_left_fail = 6
		ail_right_fail = 6
		elev_left_lock = 1
		elev_right_lock = 1
		elev_down_fail = 6
		elev_up_fail = 6
		rudder_lock = 1
		rudder_L_fail = 6
		rudder_R_fail = 6
		elev_trim_fail = 6
		ail_trim_fail = 6
		rud_trim_fail = 6
	end
end

function auto_board()
		chocks = 0
		pitot_cover = 0
		pitot_fail = 0
		air_int_cover = 0
		air_int_fail = 0
		oil_rad_cover = 0
		oil_rad_fail = 0
		ail_left_lock = 0
		ail_right_lock = 0
		ail_left_fail = 0
		ail_right_fail = 0
		elev_left_lock = 0
		elev_right_lock = 0
		elev_down_fail = 0
		elev_up_fail = 0
		rudder_lock = 0
		rudder_L_fail = 0
		rudder_R_fail = 0
		elev_trim_fail = 0
		ail_trim_fail = 0
		rud_trim_fail = 0
end
autoboard = replace_command("sim/operation/auto_board", auto_board)


inst_light_fuse = find_dataref("custom/dromader/electrical/instruments_light")
inst_light_fail = find_dataref("sim/operation/failures/rel_clights")
bat_sel = find_dataref("custom/dromader/electrical/battery_sw")
batt = find_dataref("sim/cockpit2/electrical/battery_on[0]")
gpu = find_dataref("sim/cockpit/electrical/gpu_on")
kill_gpu = find_dataref("custom/dromader/electrical/kill_gpu") --0 connected/ 1 disconnected
fuel_fuse = find_dataref("custom/dromader/electrical/fuel_fuse")
heater_sw = find_dataref("custom/dromader/electrical/heater")
vent_fuse = find_dataref("custom/dromader/electrical/vent")
ldg_lt = find_dataref("sim/cockpit2/switches/landing_lights_on")
taxi_lt = find_dataref("sim/cockpit2/switches/taxi_light_on")
nav_lt = find_dataref("sim/cockpit2/switches/navigation_lights_on")
strobe_lt = find_dataref("sim/cockpit2/switches/strobe_lights_on")
beacon_lt = find_dataref("sim/cockpit2/switches/beacon_on")
stat_heat = find_dataref("sim/cockpit/switches/static_heat_on")
bus_load_add = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")
fuel_press_dromader = find_dataref("custom/dromader/fuel/fuel_press")
primed_ratio = find_dataref("custom/dromader/engine/primed_ratio")
fuel_cutoff_selector = find_dataref("custom/dromader/fuel/fuel_valve_handle") -- (0=none,1=fuel cutoff)

function auto_start_after()
		auto_board()
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
		stat_heat = 0
		bus_load_add = 10
        fuel_press_dromader = 35
		primed_ratio = 1
		fuel_cutoff_selector = 0
end

quickstart = wrap_command("sim/operation/quick_start", dummy, auto_start_after)
autostart = wrap_command("sim/operation/auto_start", dummy, auto_start_after)


function fire_app()
	boom_hide = find_dataref("custom/dromader/spray/boom_hide")
	agequiptogcmd = find_command("custom/dromader/spray/ag_equip_tog_cmd")
	if boom_hide == 0 then
		agequiptogcmd:once()
	end
end

fireapp = wrap_command("sim/operation/Forest_Fire_Approach", fire_app, dummy)

function aircraft_unload()
	draw_fires = fires_temp
end

function show_head()
	if ext_view == 1 then return end
	if pilot_show_int == 1 then
		if ( 0-pilot_head_x )^2 + (1.92024-pilot_head_y)^2 + (1.892808-pilot_head_z)^2 > 0.0169 then 
			pilot_show_head = 1
		else
			pilot_show_head = 0
		end
	else 
		pilot_show_head = 0
	end
end

function after_physics()
	if ail_left_fail == 6 or ail_right_fail == 6 then
		stick_roll  = 0
	end
	if elev_down_fail == 6 or elev_up_fail == 6 then
		stick_pitch = 0
	end
	if rudder_L_fail == 6 or rudder_R_fail == 6 then
		pedals_yaw = 0
	end
	show_head()
	if compass_lock_knob == 1 then
		compass_g_side_dromader = 0
		compass_g_nrml_dromader = 0
	else
		compass_g_side_dromader = compass_g_side
		compass_g_nrml_dromader = compass_g_nrml
		compass_heading_dromader = compass_heading
	end
	
	if chocks == 1 then
		park_brake = 1	
	end
end

function after_replay()
	show_head()
end
