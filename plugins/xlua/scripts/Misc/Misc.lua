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
	end
end

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
