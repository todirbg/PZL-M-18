
draw_fires = find_dataref("sim/graphics/settings/draw_forestfires")

local fires_temp = draw_fires

function aircraft_load()
	draw_fires = 1
end

function aircraft_unload()
	draw_fires = fires_temp
end