require "config"

local keys = {"item", "tool", "ammo", "repair-tool", "item-with-entity-data"}
local pres = {"", "bob-"}

local function registerRecipe(recipe)
	data:extend({recipe})
end

local function itemExists(name)
	for _,key in pairs(keys) do
		--log("Checking data.raw." .. key .. "[" .. name .. "]")
		if data.raw[key][name] then
			return true
		end
	end
end

local function getMaxTierOf(base, suffix)
	if not suffix then suffix = "" end
	for i = 5,1,-1 do
		for _,pre in pairs(pres) do
			local suff = i == 1 and "" or ("-" .. i)
			local name = pre .. base .. suff .. suffix
			--log(name)
			if itemExists(name) then
				log("Found tier " .. i .. " of '" .. base .. "'")
				return name
			end
			
			suff = i == 1 and "" or ("-mk" .. i)
			name = pre .. base .. suff .. suffix
			--log(name)
			if itemExists(name) then
				log("Found tier " .. i .. " of '" .. base .. "'")
				return name
			end
		end
	end
	error("Could not find any tier for item '" .. base .. "'!")
end

local function getIngredientWithFallback(item, fallback, num, numfall)
	if num and numfall then
		if itemExists(item) then
			return {item, num}
		else
			log("Could not find ingredient " .. item .. "; defaulting to " .. fallback)
			return {fallback, numfall}
		end
	else
		if itemExists(item) then
			return item
		else
			log("Could not find ingredient " .. item .. "; defaulting to " .. fallback)
			return fallback
		end
	end
end

local function tabletostring(entry)
	local ret = "{"
	for k,v in pairs(entry) do ret = ret .. v .. ", " end
	return ret .. "}"
end

local function buildIngredients(ingredients)
	local ret = {}
	--[[
	for item,amt in pairs(ingredients) do
		table.insert(ret, {item, amt})
	end
	--]]
	local i = 1
	while i < #ingredients do
		--log(i)
		local entry = ingredients[i]
		if type(entry) == "table" then
			item = entry[1]
			amt = entry[2]
			i = i+1
		else
			item = entry
			amt = ingredients[i+1]
			i = i+2
		end
		
		--log("Parsing " .. item .. " & " .. amt .. " from " .. (type(entry) == "table" and tabletostring(entry) or (entry .. "x" .. amt)))
		if item == nil then
			error("Invalid recipe specification created null item")
		elseif type(item) ~= "string" then
			error("Invalid recipe specification created non-string item '" .. item .. "'")
		elseif itemExists(item) then
			table.insert(ret, {item, amt})
		else
			log("Could not find ingredient '" .. item .. "'! Skipping!")
		end
	end
	return ret
end

local function createRecipe(name, time, ingredients)
	local ret = {
		type = "recipe",
		name = name,
		result = name,
		energy_required = time,
		ingredients = buildIngredients(ingredients),
		enabled = false,
		--order = "[" .. name .. "]-1",
	}
	return ret
end

local function getStackSize(item)
	if item == "bridge" or item == "maintenance-bay" or item == "cargo-bay" or item == "habitation-module" then
		return 1
	elseif item == "drydock-component" or item == "body-segment" or item == "fusion-engine-cluster" or item == "forward-gun" then
		return 2
	elseif item == "solar-array" then-- or item == "habitation-section" then
		return 5
	elseif item == "habitation-section" then
		return 20
	end
	return 10
end

local function createItem(name)
	return {
		type = "item",
		name = name,
		icon = "__Starship__/graphics/icons/" .. name .. ".png",
		icon_size = 64,
		order = name,
		flags = {"goes-to-main-inventory"},
		stack_size = getStackSize(name),
		subgroup = "starship",
	}
end

local function createAndRegisterItemAndRecipe(name, time, ingredients)
	local item = createItem(name)
	data:extend({item})
	local recipe = createRecipe(name, time, ingredients)
	registerRecipe(recipe)
end

data:extend({
  {
    type = "item-group",
    name = "starship",
    order = "f",
    icon = "__Starship__/graphics/item-group.png",
    icon_size = 64,
  },
  {
    type = "item-subgroup",
    name = "starship",
    group = "starship",
    order = "a"
  },
})

createAndRegisterItemAndRecipe("hull-panel", 1, {"low-density-structure", 20, getIngredientWithFallback("titanium-plate", "steel-plate"), 10, "small-lamp", 5})
createAndRegisterItemAndRecipe("scaffolding", 1, {"low-density-structure", 10, getIngredientWithFallback("titanium-plate", "steel-plate"), 4})
createAndRegisterItemAndRecipe("window", 0.5, {getIngredientWithFallback("glass", "plastic-bar"), 10, getIngredientWithFallback("titanium-plate", "steel-plate"), 2})
createAndRegisterItemAndRecipe("scanner", 5, {"radar", 1, "advanced-circuit", 20, "processing-unit", 10})
createAndRegisterItemAndRecipe("control-computer", 10, {"advanced-circuit", 1, "rocket-control-unit", 5, "arithmetic-combinator", 10, "decider-combinator", 10})
createAndRegisterItemAndRecipe("thermal-control-unit", 2.5, {"control-computer", 1, "electric-engine-unit", 10, "copper-cable", 15, "processing-unit", 1})
createAndRegisterItemAndRecipe("shield-emitter", 0.5, {"pipe", 1, getMaxTierOf("energy-shield", "-equipment"), 3, "copper-cable", 18, getIngredientWithFallback("advanced-processing-unit", "processing-unit"), 6})
createAndRegisterItemAndRecipe("power-conduit", 1, {getIngredientWithFallback("rubber", "plastic-bar", 25, 10), "pipe", 10, "steel-plate", 10, "copper-cable", 100})
createAndRegisterItemAndRecipe("fuel-tank", 4, {"pipe", 40, "thermal-control-unit", 2, getMaxTierOf("storage-tank"), 10, "pump", 1})
createAndRegisterItemAndRecipe("power-storage-unit", 2, {"power-conduit", 5, getIngredientWithFallback("large-accumulator-3", "accumulator"), 20, "advanced-circuit", 10, "hull-panel", 1})
createAndRegisterItemAndRecipe("ram-scoop-section", 0.5, {"scaffolding", 2, "hull-panel", 1})
createAndRegisterItemAndRecipe("body-segment", 2, {"scaffolding", 12, "hull-panel", 6})
createAndRegisterItemAndRecipe("habitation-section", 2, {"thermal-control-unit", 1, "hull-panel", 9, "small-lamp", 12, "window", 9})
createAndRegisterItemAndRecipe("solar-wing", 30, {getMaxTierOf("solar-panel"), 9, "power-conduit", 1, "steel-plate", 3})
createAndRegisterItemAndRecipe("solar-array", 60, {"solar-wing", 3, "scaffolding", 2})
createAndRegisterItemAndRecipe("bridge", 360, {"hull-panel", 6, "window", 40, "control-computer", 10, "scanner", 5})
createAndRegisterItemAndRecipe("targeting-computer", 10, {"scanner", 1, "control-computer", 2, getIngredientWithFallback("advanced-processing-unit", "processing-unit"), 5})
createAndRegisterItemAndRecipe("fusion-engine", 20, {"power-conduit", 8, getIngredientWithFallback("tungsten-plate", "steel-plate", 16, 24), "thermal-control-unit", 1, getIngredientWithFallback("tungsten-pipe", "pipe"), 32, getMaxTierOf("fusion-reactor-equipment"), 4})
createAndRegisterItemAndRecipe("maintenance-bay", 1200, {"repair-pack", 10000, "hull-panel", 8, getMaxTierOf("assembling-machine"), 4, getMaxTierOf("roboport"), 4, "body-segment", 1, getMaxTierOf("construction-robot"), 200})
createAndRegisterItemAndRecipe("cargo-bay", 900, {"electric-engine-unit", 8, "body-segment", 4, getIngredientWithFallback("angels-warehouse", "steel-chest", 1, 24), getMaxTierOf("logistic-robot"), 100})
createAndRegisterItemAndRecipe("habitation-rotator", 90, {"body-segment", 5, "electric-engine-unit", 80, "scaffolding", 20})
createAndRegisterItemAndRecipe("defence-turret", 15, {getIngredientWithFallback("plasma-turret", "laser-turret"), 9, "control-computer", 3, "power-storage-unit", 1, "targeting-computer", 1})
createAndRegisterItemAndRecipe("power-coupler", 8, {"power-storage-unit", 4, "power-conduit", 32, "processing-unit", 16})
createAndRegisterItemAndRecipe("fusion-engine-cluster", 60, {"fusion-engine", 6, "scaffolding", 16, "pipe", 6, "control-computer", 2, "pump", 4})
createAndRegisterItemAndRecipe("forward-gun", 45, {"targeting-computer", 2, getIngredientWithFallback("purple-loader", "express-loader"), 2, "artillery-wagon", 4, "artillery-shell", 1000})
--createAndRegisterItemAndRecipe("habitation-module", 1200, {"habitation-section", 15, "habitation-rotator", 1, "scaffolding", 4, "power-conduit", 1})

createAndRegisterItemAndRecipe("logistics-unit", 60, {getMaxTierOf("construction-robot"), 100, getIngredientWithFallback("angels-warehouse", "steel-chest", 2, 25)})
createAndRegisterItemAndRecipe("welder-unit", 90, {getIngredientWithFallback("magnesium-rod", "steel-chest", 2, 50), "magnesium-rod", 750, "solder-alloy", 400})
createAndRegisterItemAndRecipe("drydock-component", 240, {"logistics-unit", 2, "welder-unit", 5, "hull-panel", 5, "repair-pack", 50, "solar-wing", 2})