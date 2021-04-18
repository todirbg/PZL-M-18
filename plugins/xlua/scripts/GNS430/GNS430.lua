----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

knob_b_l_ang = create_dataref("custom/dromader/gns430/knob_big_l_ang","number", dummy)
knob_b_r_ang = create_dataref("custom/dromader/gns430/knob_big_r_ang","number", dummy)
knob_s_l_ang = create_dataref("custom/dromader/gns430/knob_small_l_ang","number", dummy)
knob_s_r_ang = create_dataref("custom/dromader/gns430/knob_small_r_ang","number"), dummy

com_vol = find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1")
gps_pwr = find_dataref("sim/cockpit2/radios/actuators/gps_power")



function cmd_coarse_down_after_handler(phase, duration)
	if phase == 0 then
		knob_b_l_ang = knob_b_l_ang - 1
	end
end


cmd_coarse_down = wrap_command("sim/GPS/g430n1_coarse_down", dummy, cmd_coarse_down_after_handler)

function cmd_coarse_up_after_handler(phase, duration)
	if phase == 0 then
		knob_b_l_ang = knob_b_l_ang + 1
	end
end


cmd_coarse_up = wrap_command("sim/GPS/g430n1_coarse_up", dummy, cmd_coarse_up_after_handler)

function cmd_fine_down_after_handler(phase, duration)
	if phase == 0 then
		knob_s_l_ang = knob_s_l_ang - 1
	end
end


cmd_fine_down = wrap_command("sim/GPS/g430n1_fine_down", dummy, cmd_fine_down_after_handler)

function cmd_fine_up_after_handler(phase, duration)
	if phase == 0 then
		knob_s_l_ang = knob_s_l_ang + 1
	end
end


cmd_fine_up = wrap_command("sim/GPS/g430n1_fine_up", dummy, cmd_fine_up_after_handler)

function cmd_chapter_up_after_handler(phase, duration)
	if phase == 0 then
		knob_b_r_ang = knob_b_r_ang + 1
	end
end


cmd_chapter_up = wrap_command("sim/GPS/g430n1_chapter_up", dummy, cmd_chapter_up_after_handler)

function cmd_chapter_down_after_handler(phase, duration)
	if phase == 0 then
		knob_b_r_ang = knob_b_r_ang - 1
	end
end


cmd_chapter_down = wrap_command("sim/GPS/g430n1_chapter_dn", dummy, cmd_chapter_down_after_handler)

function cmd_page_up_after_handler(phase, duration)
	if phase == 0 then
		knob_s_r_ang = knob_s_r_ang + 1
	end
end


cmd_page_up = wrap_command("sim/GPS/g430n1_page_up", dummy, cmd_page_up_after_handler)

function cmd_page_down_after_handler(phase, duration)
	if phase == 0 then
		knob_s_r_ang = knob_s_r_ang - 1
	end
end


cmd_page_down = wrap_command("sim/GPS/g430n1_page_dn", dummy, cmd_page_down_after_handler)

function after_physics()
	if com_vol < 0.05 and  gps_pwr == 1 then gps_pwr = 0
	elseif com_vol >= 0.1 and  gps_pwr == 0 then gps_pwr = 1
	end
end
