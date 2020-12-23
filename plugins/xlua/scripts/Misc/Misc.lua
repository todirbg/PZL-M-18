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

audio_com1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
audio_nav1 = find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")

tension_handle = create_dataref("custom/dromader/misc/tension_handle","number", tension_handle_handler)

audio_sw = create_dataref("custom/dromader/misc/audio_sw","number")
audio_vol = create_dataref("custom/dromader/misc/audio_vol","number", audio_vol_handler)

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
end

function aircraft_unload()
	draw_fires = fires_temp
end