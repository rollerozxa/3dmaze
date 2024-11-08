-- Node Registrations

core.register_node("3dmaze:brick_wall", {
	description = "brick wall",
	tiles = {"3dmaze_brick_wall.png"},
	light_source = 12,
})
core.register_node("3dmaze:wood_floor", {
	description = "wood floor",
	tiles = {"3dmaze_wood_floor.png"},
	light_source = 12,
})
core.register_node("3dmaze:brick_ceiling", {
	description = "brick ceiling",
	drawtype = "allfaces",
	tiles = {"3dmaze_brick_ceiling.png"},
	light_source = 12,
})

local function map_function(maze, player)
	local loc_maze = maze
	width = loc_maze.width
	height = loc_maze.height

	--Copy to the map
	local vm         = core.get_voxel_manip()
	local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height+1,y=4,z=width+1})
	local data = vm:get_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	local ground   = core.get_content_id("3dmaze:wood_floor")
	local wall     = core.get_content_id("3dmaze:brick_wall")
	local ceil     = core.get_content_id("3dmaze:brick_ceiling")
	local invisble = core.get_content_id("game:inv")
	local air      = core.get_content_id("air")

	--Set up the level itself
	for z=1, width do --z
		for x=1, height do --x
			if loc_maze[x][z] == 1 then
				data[a:index(x, 0, z)] = ground
				data[a:index(x, 2, z)] = ceil

			else
				data[a:index(x, 1, z)] = wall
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map(true)

	--player target coords
	player_x = math.floor(height/2)+(math.floor(height/2)+1)%2
	player_z = math.floor(width/2)+(math.floor(width/2)+1)%2

	--Lets now overwrite the channel for the player to fall into:
	local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
	local data = vm:get_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	for y=5,32 do
		for x=player_x-1, player_x+1 do
			for z=player_z-1, player_z+1 do
				data[a:index(x, y, z)] = air
			end
		end
		--Add the invisible channel
		data[a:index(player_x-1, y, player_z)] = invisble
		data[a:index(player_x+1, y, player_z)] = invisble
		data[a:index(player_x, y, player_z-1)] = invisble
		data[a:index(player_x, y, player_z+1)] = invisble
	end
	vm:set_data(data)
	vm:write_to_map(true)

	-- Make player smol
	player:set_properties({visual_size = {x=0.5, y=0.5, z=0.5}, collisionbox = {-0.4, 0.0, -0.4, 0.4, 0.8, 0.4}})
	player:set_eye_offset({x=0,y=-12,z=0}, {x=0,y=-12,z=0})
	player:set_physics_override({ speed = 0.4, jump = 0 })

	--Finally, move  the player

	player:set_velocity({x=0,y=0,z=0})
	player:set_pos({x=player_x,y=2,z=player_z})
end

local function cleanup(width, height)
	--Copy to the map
	local vm         = core.get_voxel_manip()
	local emin, emax = vm:read_from_map({x=0,y=0,z=0}, {x=height*2+1,y=4,z=width*2+1})
	local data = vm:get_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	local air = core.get_content_id("air")

	--zero it out
	for z=0, width*2+1 do --z
		for y=0,4 do --
			for x=0, height*2+1 do --x
				data[a:index(x, y, z)] = air
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map(true)

	--player target coords
	player_x = (math.floor(height/2)+(math.floor(height/2)+1)%2)*2
	player_z = (math.floor(width/2)+(math.floor(width/2)+1)%2)*2

	--Lets now overwrite the channel for the player to fall into:
	local emin, emax = vm:read_from_map({x=player_x-1,y=4,z=player_z-1}, {x=player_x+1,y=32,z=player_z+1})
	local data = vm:get_data()
	local a = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}
	for y=5,32 do
		for x=player_x-1, player_x+1 do
			for z=player_z-1, player_z+1 do
				data[a:index(x, y, z)] = air
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map(true)
end

laby_register_style("3dmaze","cave", map_function, cleanup)
