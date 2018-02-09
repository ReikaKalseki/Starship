require "config"

local function createUnit(amt)
return {
	  count = amt,
	  ingredients = {
		{"science-pack-1", 1},
		{"science-pack-2", 1},
		{"science-pack-3", 1},
		{"high-tech-science-pack", 1},
		{"space-science-pack", 1},
	  },
	  time = 40
	}
end

local function registerTech(tech)
	data:extend({tech})
	table.insert(data.raw.technology["orbital-assembly"].prerequisites, tech.name)
end

local function createUnlocks(recipes)
	local ret = {}
	for _,recipe in pairs(recipes) do
		table.insert(ret, {type = "unlock-recipe", recipe = recipe})
	end
	return ret
end

local function createTech(name, prereqs, recipes, packs)
	local tech = {
		type = "technology",
		name = name,
		prerequisites = prereqs,
		icon = "__Starship__/graphics/technology/" .. name .. ".png",
		effects = createUnlocks(recipes),
		unit = createUnit(packs),
		order = "[" .. name .. "]-1",
		icon_size = 128,
	}
	return tech
end

local function createAndRegisterTech(name, prereqs, recipes, packs)
	if name ~= "ship-construction" then
		table.insert(prereqs, "ship-construction")
	end
	local tech = createTech(name, prereqs, recipes, packs)
	registerTech(tech)
end

data:extend({
createTech("orbital-assembly", {}, {}, 7500)
})

createAndRegisterTech("ship-construction", {"rocket-silo"}, {"hull-panel", "scaffolding"}, 500)
createAndRegisterTech("interstellar-travel", {}, {}, 5000)
createAndRegisterTech("starship-fuel-system", {"fluid-handling"}, {"fuel-tank"}, 1000)
createAndRegisterTech("fusion-engines", {"starship-control", "interstellar-travel", "fusion-reactor-equipment", "nuclear-power", "electric-engine"}, {"fusion-engine", "fusion-engine-cluster"}, 3000)
createAndRegisterTech("starship-shielding", {"energy-shield-equipment-2"}, {"shield-emitter"}, 1000)
createAndRegisterTech("starship-power", {"electric-energy-accumulators"}, {"power-conduit", "power-storage-unit", "power-coupler"}, 2000)
createAndRegisterTech("starship-solar", {"solar-panel"}, {"solar-wing", "solar-array"}, 2500)
createAndRegisterTech("starship-habitation", {}, {"habitation-section", "habitation-module"}, 2000)
createAndRegisterTech("starship-cargo", {}, {"cargo-bay"}, 500)
createAndRegisterTech("ramjet-scoop", {"starship-fuel-system"}, {"ram-scoop-section"}, 1500)
createAndRegisterTech("starship-control", {"advanced-electronics-2"}, {"control-computer", "thermal-control-unit"}, 1000)
createAndRegisterTech("starship-bridge", {"starship-control"}, {"bridge"}, 2500)

--[[
data:extend({
{
	type = "technology",
	name = "fusion-engines",
	prerequisites = {
		"fusion-reactor-equipment",
		"electric-engine",
		"flammables",
		"uranium-processing",
	},
	icon = "__Starship__/graphics/technology/engines.png",
	effects = {
	  {
		type = "unlock-recipe",
		recipe = "fusion-engine-cell"
	  },
	},
	unit = createUnit(1000),
	order = "[fusion-engines]-1",
	icon_size = 128,
},
{
	type = "technology",
	name = "micrometeorite-shielding",
	prerequisites = {
		"energy-shield-equipment",
	},
	icon = "__Starship__/graphics/technology/shielding.png",
	effects = {
	  {
		type = "unlock-recipe",
		recipe = "meteor-shield-unit"
	  },
	},
	unit = createUnit(1000),
	order = "[shielding]-1",
	icon_size = 128,
},
})
--]]