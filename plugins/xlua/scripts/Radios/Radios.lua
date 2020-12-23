----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------

transp_code = find_dataref("sim/cockpit/radios/transponder_code")
transp_mode = find_dataref("sim/cockpit/radios/transponder_mode")
transp_mode_dromader = create_dataref("custom/dromader/radios/transponder_mode","number")

transp_knob = create_dataref("custom/dromader/radios/transponder_rot","array[4]")
transp_str_FL = create_dataref("custom/dromader/radios/string_fl","string")
transp_str_ALT = create_dataref("custom/dromader/radios/string_alt","string")
transp_str_SBY = create_dataref("custom/dromader/radios/string_sby","string")
transp_str_GND = create_dataref("custom/dromader/radios/string_gnd","string")
transp_str_ON = create_dataref("custom/dromader/radios/string_on","string")
transp_str_R = create_dataref("custom/dromader/radios/string_r","string")
transp_str_FL = "FL"
transp_str_ALT = "ALT"
transp_str_SBY = "SBY"
transp_str_ON = "ON"
transp_str_R = "R"
transp_str_GND = "GND"

comm_coarse_knob = create_dataref("custom/dromader/radios/comm_coarse_knob","number")
comm_fine_knob = create_dataref("custom/dromader/radios/comm_fine_knob","number")
nav_coarse_knob = create_dataref("custom/dromader/radios/nav_coarse_knob","number")
nav_fine_knob = create_dataref("custom/dromader/radios/nav_fine_knob","number")
com_pwr_konb = create_dataref("custom/dromader/radios/com_pwr_konb","number")
nav_pwr_konb = create_dataref("custom/dromader/radios/nav_pwr_knob","number")
com_pwr = find_dataref("sim/cockpit2/radios/actuators/com1_power")
nav_pwr = find_dataref("sim/cockpit2/radios/actuators/nav1_power")
com_brt = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")
nav_brt = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[1]")

startup_running = find_dataref("sim/operation/prefs/startup_running")

function cmd_transponder_up(phase, duration)
	if phase == 0 then
		if transp_mode_dromader < 5 then
			transp_mode_dromader = transp_mode_dromader + 1	
			if transp_mode_dromader == 1 then
				transp_mode = 1
			elseif transp_mode_dromader == 2 then
				transp_mode = 4
			elseif transp_mode_dromader == 3 then
				transp_mode = 5
			elseif transp_mode_dromader == 4 then
				transp_mode = 2
			elseif transp_mode_dromader == 5 then
				transp_mode = 3
			end
		end
	end
end

function cmd_transponder_dn(phase, duration)
	if phase == 0 then
		if transp_mode_dromader > 0 then
			transp_mode_dromader = transp_mode_dromader - 1
			if transp_mode_dromader == 1 then
				transp_mode = 1
			elseif transp_mode_dromader == 2 then
				transp_mode = 4
			elseif transp_mode_dromader == 3 then
				transp_mode = 5
			elseif transp_mode_dromader == 4 then
				transp_mode = 2
			elseif transp_mode_dromader == 0 then
				transp_mode = 0
			end
		end
	end
end


cmdcsutomtransup = create_command("custom/dromader/radios/transponder_up","Transponder power knob up",cmd_transponder_up)
cmdcsutomtransdwn = create_command("custom/dromader/radios/transponder_dn","Transponder power knob up",cmd_transponder_dn)



function cmd_transponder_vfr(phase, duration)
	if phase == 0 then
		transp_code = 1200
	end
end


cmdcsutomtransvfr = create_command("custom/dromader/radios/vfr","Transponder VFR",cmd_transponder_vfr)

function dummy()

end

function thou_up_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[0] = transp_knob[0] + 1
	end
end

function thou_dn_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[0] = transp_knob[0] - 1
	end
end

cmdcsutomtransthouup = wrap_command("sim/transponder/transponder_thousands_up", dummy, thou_up_cmd_after)
cmdcsutomtransthoudn = wrap_command("sim/transponder/transponder_thousands_down", dummy, thou_dn_cmd_after)

function hun_up_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[1] = transp_knob[1] + 1
	end
end

function hun_dn_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[1] = transp_knob[1] - 1
	end
end

cmdcsutomtranshunup = wrap_command("sim/transponder/transponder_hundreds_up", dummy, hun_up_cmd_after)
cmdcsutomtranshundn = wrap_command("sim/transponder/transponder_hundreds_down", dummy, hun_dn_cmd_after)

function ten_up_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[2] = transp_knob[2] + 1
	end
end

function ten_dn_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[2] = transp_knob[2] - 1
	end
end

cmdcsutomtranstenup = wrap_command("sim/transponder/transponder_tens_up", dummy, ten_up_cmd_after)
cmdcsutomtranstendn = wrap_command("sim/transponder/transponder_tens_down", dummy, ten_dn_cmd_after)

function one_up_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[3] = transp_knob[3] + 1
	end
end

function one_dn_cmd_after(phase, duration)
	if phase == 0 then
		transp_knob[3] = transp_knob[3] - 1
	end
end

cmdcsutomtransoneup = wrap_command("sim/transponder/transponder_ones_up", dummy, one_up_cmd_after)
cmdcsutomtransonedn = wrap_command("sim/transponder/transponder_ones_down", dummy, one_dn_cmd_after)

function comcoarse_up_cmd_after(phase, duration)
	if phase == 0 then
		comm_coarse_knob = comm_coarse_knob + 1
	end
end

function comcoarse_dn_cmd_after(phase, duration)
	if phase == 0 then
		comm_coarse_knob = comm_coarse_knob - 1
	end
end

cmdcsutomcomcoarseup = wrap_command("sim/radios/stby_com1_coarse_up", dummy, comcoarse_up_cmd_after)
cmdcsutomcomcoarsedn = wrap_command("sim/radios/stby_com1_coarse_down", dummy, comcoarse_dn_cmd_after)

function comfine_up_cmd_after(phase, duration)
	if phase == 0 then
		comm_fine_knob = comm_fine_knob + 1
	end
end

function comfine_dn_cmd_after(phase, duration)
	if phase == 0 then
		comm_fine_knob = comm_fine_knob - 1
	end
end

cmdcsutomcomfineup = wrap_command("sim/radios/stby_com1_fine_up", dummy, comfine_up_cmd_after)
cmdcsutomcomfinedn = wrap_command("sim/radios/stby_com1_fine_down", dummy, comfine_dn_cmd_after)

function navcoarse_up_cmd_after(phase, duration)
	if phase == 0 then
		nav_coarse_knob = nav_coarse_knob + 1
	end
end

function navcoarse_dn_cmd_after(phase, duration)
	if phase == 0 then
		nav_coarse_knob = nav_coarse_knob - 1
	end
end

cmdcsutomnavcoarseup = wrap_command("sim/radios/stby_nav1_coarse_up", dummy, navcoarse_up_cmd_after)
cmdcsutomnavcoarsedn = wrap_command("sim/radios/stby_nav1_coarse_down", dummy, navcoarse_dn_cmd_after)

function navfine_up_cmd_after(phase, duration)
	if phase == 0 then
		nav_fine_knob = nav_fine_knob + 1
	end
end

function navfine_dn_cmd_after(phase, duration)
	if phase == 0 then
		nav_fine_knob = nav_fine_knob - 1
	end
end

cmdcsutomnavfineup = wrap_command("sim/radios/stby_nav1_fine_up", dummy, navfine_up_cmd_after)
cmdcsutomnavfinedn = wrap_command("sim/radios/stby_nav1_fine_down", dummy, navfine_dn_cmd_after)

function cmd_compwr_up(phase, duration)
	if phase == 0 or phase == 1 then
		if com_pwr_konb < 0.8 then
			com_pwr_konb = com_pwr_konb + 0.05
			if com_pwr_konb >= 0.05 then
				com_pwr = 1
			end
			com_brt = com_pwr_konb + 0.15
		end
	end
end

function cmd_compwr_dn(phase, duration)
	if phase == 0 or phase == 1 then
		if com_pwr_konb >= 0.05 then
			com_pwr_konb = com_pwr_konb - 0.05
			if com_pwr_konb == 0 then
				com_pwr = 0
			end
			com_brt = com_pwr_konb + 0.15
		end
	end
end


cmdcsutomcompwrup = create_command("custom/dromader/radios/comm_pwr_up","Comm power knob up",cmd_compwr_up)
cmdcsutomcompwrdwn = create_command("custom/dromader/radios/comm_pwr_dwn","Comm power knob up",cmd_compwr_dn)

function cmd_navpwr_up(phase, duration)
	if phase == 0 or phase == 1 then
		if nav_pwr_konb < 0.8 then
			nav_pwr_konb = nav_pwr_konb + 0.05
			if nav_pwr_konb >= 0.05 then
				nav_pwr = 1
			end
			nav_brt = nav_pwr_konb + 0.15
		end
	end
end

function cmd_navpwr_dn(phase, duration)
	if phase == 0 or phase == 1 then
		if nav_pwr_konb >= 0.05 then
			nav_pwr_konb = nav_pwr_konb - 0.05
			if nav_pwr_konb == 0 then
				nav_pwr = 0
			end
			nav_brt = nav_pwr_konb + 0.15
		end
	end
end


cmdcsutomnavpwrup = create_command("custom/dromader/radios/nav_pwr_up","Nav power knob up",cmd_navpwr_up)
cmdcsutomnavpwrdwn = create_command("custom/dromader/radios/nav_pwr_down","Nav power knob down",cmd_navpwr_dn)

function flight_start()

	if startup_running == 1 then
		nav_brt = 0.7
		nav_pwr = 1
		nav_pwr_knob = 0.7
		com_brt = 0.7
		com_pwr = 1
		com_pwr_knob = 0.7
		transp_mode = 1
		transp_mode_dromader = 1
	else
		nav_brt = 0.0
		nav_pwr = 0
		nav_pwr_knob = 0.0
		com_brt = 0.0
		com_pwr = 0
		com_pwr_knob = 0.0	
		transp_mode = 0
		transp_mode_dromader = 0
	end
end
