function tension_handle_handler()

end

draw_fires = find_dataref("sim/graphics/settings/draw_forestfires")
static_heat = find_dataref("sim/cockpit/switches/static_heat_on")

tension_handle = create_dataref("custom/dromader/misc/tension_handle","number", tension_handle_handler)

local fires_temp = draw_fires

function aircraft_load()
	draw_fires = 1

end

function flight_start()
	tension_handle = 0.5
	static_heat = 0
end

function aircraft_unload()
	draw_fires = fires_temp
end