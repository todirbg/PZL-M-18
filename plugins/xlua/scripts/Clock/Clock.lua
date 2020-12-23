----------------------------------------------------------------------------------------------------------
-- Copyright Todor Radonov 2020
-- Licnsed under Creative Commons CC BY-NC 4.0
-- https://creativecommons.org/licenses/by-nc/4.0/
----------------------------------------------------------------------------------------------------------

time_sec = create_dataref("custom/dromader/clock/elapsed_time_seconds","number")
time_min = create_dataref("custom/dromader/clock/elapsed_time_minutes","number")
time_hr = create_dataref("custom/dromader/clock/elapsed_time_hours","number")
sim_time = find_dataref("sim/time/total_flight_time_sec")
local timer_state = 2
local timer_running = 0
local tmp_time = 0
local seconds = 0

function cmd_flight_time_cyc(phase, duration)
	if phase == 0 then
		timer_state = timer_state + 1
		if timer_state > 2 then timer_state = 0 end
		
		if timer_state == 0 then
			timer_running = 1
			tmp_time = sim_time
		elseif timer_state == 1 then
			timer_running = 0
		elseif timer_state == 2 then
			seconds = 0
			time_min = 0
			time_hr = 0
		end
	end
end

cmdcustomftimecyc = create_command("custom/dromader/clock/elapsed_timer_cycle","Cycle flight time timer",cmd_flight_time_cyc)

function after_physics()
	

		if timer_running == 1 then
			seconds = sim_time - tmp_time
			time_sec = seconds
			time_min = seconds/60
			time_hr = seconds/3600
		end

end

