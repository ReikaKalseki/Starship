require "config"
require "constants"

local function checkIfShipBuilt(force)
	for item,num in pairs(shipComponents) do
		if force.get_item_launched(item) < num then
			return false
		end
	end
	return true
end

local function checkIfDrydockBuilt(force)
	for item,num in pairs(drydockComponents) do
		if force.get_item_launched(item) < num then
			return false
		end
	end
	return true
end

local function onShipComplete(force)
	force.print("Your spacecraft is complete! [Placeholder event]")
end

local function getDrydockCompletion(force)
	local req = 0
	local has = 0
	for item,num in pairs(drydockComponents) do
		has = has+force.get_item_launched(item)
		req = req+num
	end
	return (has/req)*100
end

local function initGlobal(markDirty)
	--[[
	if remote.interfaces["silo_script"] then
		remote.call("silo_script", "set_show_launched_without_satellite", false)
		for item,num in pairs(drydockComponents) do
			remote.call("silo_script", "add_tracked_item", item)
		end
		for item,num in pairs(shipComponents) do
			remote.call("silo_script", "add_tracked_item", item)
		end
	end
	--]]
end

script.on_init(function()
	initGlobal(true)
end)

script.on_configuration_changed(function()
	initGlobal(true)
end)

script.on_event(defines.events.on_rocket_launched, function(event)
	local inv = event.rocket.get_inventory(defines.inventory.chest)
	local item = inv[1]
	local force = event.rocket.force
	if item and item.valid_for_read then
		if shipComponents[item.name] then
			if not checkIfDrydockBuilt(force) then
				force.print("You have not built a drydock yet (" .. getDrydockCompletion(force) .. "% complete); You cannot assemble your spacecraft!")
				force.set_item_launched(item.name, 0) --item is wasted
			elseif checkIfShipBuilt(force) then
				onShipComplete(force)
			end
		elseif drydockComponents[item.name] then
			if checkIfDrydockBuilt(force) then
				force.print("Drydock is complete! Ready to begin spacecraft construction!")
			else
				force.print("Drydock is now " .. getDrydockCompletion(force) .. "% complete.")
			end
		else
			force.print("Rocket was launched with non-ship-related part '" .. item.name .. "'.")
		end
	else
		force.print("Rocket was launched empty.")
	end
end)

--[[
script.on_event(defines.events.on_tick, function(event)
	
end)--]]