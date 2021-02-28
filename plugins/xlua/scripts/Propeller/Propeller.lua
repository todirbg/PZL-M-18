----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2021
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------

prop_disc_ovrd = find_dataref("sim/flightmodel2/engines/prop_disc/override[0]")
prop_is_disc = find_dataref("sim/flightmodel2/engines/prop_is_disc[0]")

prop_rotation_angle_deg = find_dataref("sim/flightmodel2/engines/prop_rotation_angle_deg[0]")
prop_rotation_speed_rad_sec = find_dataref("sim/flightmodel2/engines/prop_rotation_speed_rad_sec[0]")
prop_pitch_deg = find_dataref("sim/flightmodel2/engines/prop_pitch_deg[0]")

disc_s_dim = find_dataref("sim/flightmodel2/engines/prop_disc/disc_s_dim[0]")
disc_t_dim = find_dataref("sim/flightmodel2/engines/prop_disc/disc_t_dim[0]")
disc_alpha_front = find_dataref("sim/flightmodel2/engines/prop_disc/disc_alpha_front[0]")
disc_alpha_side = find_dataref("sim/flightmodel2/engines/prop_disc/disc_alpha_side[0]")
disc_alpha_inside = find_dataref("sim/flightmodel2/engines/prop_disc/disc_alpha_inside[0]")
disc_width = find_dataref("sim/flightmodel2/engines/prop_disc/disc_width[0]")

side_width = find_dataref("sim/flightmodel2/engines/prop_disc/side_width[0]")
side_number_of_blades = find_dataref("sim/flightmodel2/engines/prop_disc/side_number_of_blades[0]")
side_s_dim = find_dataref("sim/flightmodel2/engines/prop_disc/side_s_dim[0]")
side_t_dim = find_dataref("sim/flightmodel2/engines/prop_disc/side_t_dim[0]")
side_alpha_front = find_dataref("sim/flightmodel2/engines/prop_disc/side_alpha_front[0]")
side_alpha_side = find_dataref("sim/flightmodel2/engines/prop_disc/side_alpha_side[0]")
side_alpha_inside = find_dataref("sim/flightmodel2/engines/prop_disc/side_alpha_inside[0]")
side_angle = find_dataref("sim/flightmodel2/engines/prop_disc/side_angle[0]")

side_is_billboard = find_dataref("sim/flightmodel2/engines/prop_disc/side_is_billboard[0]")

disc_s = find_dataref("sim/flightmodel2/engines/prop_disc/disc_s[0]")
disc_t = find_dataref("sim/flightmodel2/engines/prop_disc/disc_t[0]")
side_s = find_dataref("sim/flightmodel2/engines/prop_disc/side_s[0]")
side_t = find_dataref("sim/flightmodel2/engines/prop_disc/side_t[0]")

fuel_press_dromader = find_dataref("custom/dromader/fuel/fuel_press")
throttle_ratio = find_dataref("sim/flightmodel2/engines/throttle_used_ratio[0]")
eng_running = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
primed_ratio = find_dataref("custom/dromader/engine/primed_ratio")

function prop_angle_handler()
	if prop_angle_dromader > prop_rotation_angle_deg then
		fuel_press_dromader = math.max(0, fuel_press_dromader - (prop_angle_dromader - prop_rotation_angle_deg)*throttle_ratio/90)
		primed_ratio = math.max(0, primed_ratio - (prop_angle_dromader - prop_rotation_angle_deg)*0.001)
	else
		prop_angle_dromader = prop_rotation_angle_deg
		return
	end
	if prop_angle_dromader > 360 then 
		prop_angle_dromader = 0
	elseif prop_angle_dromader < 0 then
		prop_angle_dromader = 360
	end
		prop_rotation_angle_deg = prop_angle_dromader
end

prop_angle_dromader = create_dataref("custom/dromader/engine/prop_angle_deg","number", prop_angle_handler)

function interp(in1, out1, in2, out2, x)

	if(x < in1) then return out1
	elseif(x > in2) then return out2
	end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function aircraft_load()
	prop_disc_ovrd = 1
end

function flight_start()
    disc_s_dim = 4
    disc_t_dim = 1
    disc_alpha_front = 1
    disc_alpha_side = 0.1
    disc_alpha_inside = 1
    disc_width = 0.05

    side_width = 0.5
    side_number_of_blades = 4
    side_s_dim = 16
    side_t_dim = 1
    side_alpha_front = 0
    side_alpha_side = 1
    side_alpha_inside = 0.5
    side_is_billboard = 0
end

function aircraft_unload()
	prop_disc_ovrd = 0
end


local prop_angle_prev = 0
function after_physics()
local prop_speed_now = prop_rotation_speed_rad_sec

    if prop_rotation_angle_deg > 360 then

        prop_rotation_angle_deg = prop_rotation_angle_deg - 360

    end
    if side_angle > 360 then

        side_angle = side_angle - 360

    end

local prop_angle_now = prop_rotation_angle_deg
local side_angle_now = side_angle

prop_rotation_angle_deg = prop_angle_now + prop_speed_now * SIM_PERIOD * 60
side_angle = side_angle_now + prop_speed_now * SIM_PERIOD * 60
    if prop_speed_now > 20 then
        prop_is_disc = 1
    else
        prop_is_disc = 0
    end

disc_s = interp(20,0,120,2, prop_speed_now)
side_s = interp(0,12,90,14, prop_pitch_deg)
prop_angle_dromader = prop_rotation_angle_deg
	
end
