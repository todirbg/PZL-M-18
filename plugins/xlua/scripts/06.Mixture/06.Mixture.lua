----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------
function dummy()

end

local power_last = 0
local power_slope = 1
local egt_last = 0
local egt_slope = 0

mixture_eng = find_dataref("sim/flightmodel/engine/ENGN_mixt[0]")
power_eng = find_dataref("sim/flightmodel/engine/ENGN_power[0]")


joy_map = find_dataref("sim/joystick/joy_mapped_axis_avail") --starting from 0 - 9 mixture all eng, 28 mixture eng1, 29 mixture eng2.
joy_value = find_dataref("sim/joystick/joy_mapped_axis_value")

running_eng = find_dataref("sim/flightmodel/engine/ENGN_running[0]")
ovrd_mix = find_dataref("sim/operation/override/override_mixture")
startup_running = find_dataref("sim/operation/prefs/startup_running")
mixture_fail = create_dataref("custom/dromader/mixture/mixture_fail","number", dummy)


function mixture_handle_handler()
	if mixture_fail == 1 then
		ovrd_mix = 1
		return
	end
	if mixture_handle < 1 then
		ovrd_mix = 0
		mixture_eng = mixture_handle
	elseif mixture_handle == 1 then
		ovrd_mix = 1
	end
end

mixture_handle = create_dataref("custom/dromader/fuel/mixture_handle","number", mixture_handle_handler)

function joy_axis_handler()

  if joy_map[9] == 1 then
    if joy_value[9] > 0.95 then
		ovrd_mix = 1
		mixture_handle = 1
	else
		ovrd_mix = 0
		mixture_handle = mixture_eng
	end
    
  end

end

function cmd_mixture_selector_up(phase, duration)
		if mixture_eng == 1 then
			ovrd_mix = 1
		end
		mixture_handle = mixture_eng
end

function cmd_mixture_selector_dwn(phase, duration)
		if ovrd_mix == 1 then
			mixture_eng = 0.99
			ovrd_mix = 0
		end
		mixture_handle = mixture_eng
end

function cmd_mixture_selector_max(phase, duration)
	if phase == 0 then
		mixture_handle = 1
	end
end

function cmd_mixture_selector_min(phase, duration)
	if phase == 0 then
		mixture_handle = 0
	end
end

cmdcustommixup = wrap_command("sim/engines/mixture_up", dummy, cmd_mixture_selector_up)
cmdcustommixdwn = wrap_command("sim/engines/mixture_down", dummy, cmd_mixture_selector_dwn)
cmdcustommixmax = wrap_command("sim/engines/mixture_max", dummy, cmd_mixture_selector_max)
cmdcustommixmin = wrap_command("sim/engines/mixture_min", dummy, cmd_mixture_selector_min)

function auto_rich()
 local mix = mixture_eng
 local step = 0.01
 local delta = math.abs(power_eng - power_last)
 
   if running_eng == 1 then

    if delta <= 100 and delta >= 10 then step = 0.001
    elseif delta < 10 then step = 0.0001 
    end
    
    if power_eng > power_last and power_slope == 1 then 
      mix = mixture_eng - step
      power_last = power_eng
      power_slope = 1
      return mix
    elseif power_eng < power_last  and power_slope == 1 then 
      mix = mixture_eng + step
      power_last = power_eng
      power_slope = 0
      return mix
    elseif power_eng < power_last  and power_slope == 0 then 
      mix = mixture_eng - step
      power_last = power_eng
      power_slope = 1
      return mix
    elseif power_eng > power_last and power_slope == 0 then 
      mix = mixture_eng + step
      power_last = power_eng
      power_slope = 0
      return mix
    else
      return mix
    end    
          
   else
      power_last = power_eng
      power_slope = 1
    return 1
   end

end

function mix_limits(value)
  if value > 1 then return 1
  elseif value < 0.2 then return 0.2
  end
  return value
end

function set_mixture()
	if ovrd_mix == 1 then
		if mixture_fail == 1 then
			mixture_eng = 0
			return
		end
		mixture_eng = mix_limits(auto_rich())
	end
end

function aircraft_load()
	mixture_handle = 1
	ovrd_mix = 1
end



function aircraft_unload()
  ovrd_mix = 0
end

function after_physics()
   joy_axis_handler()
end

run_at_interval(set_mixture,(1/10))
