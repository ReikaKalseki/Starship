require "config"

local pres = {"", "bob-"}

local myTechs = {}

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
	table.insert(myTechs, tech)
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

local function techExists(name)
	--log("Checking data.raw." .. key .. "[" .. name .. "]")
	if data.raw.technology[name] then
		return true
	end
end

local function getMaxTierOf(base, suffix)
	if not suffix then suffix = "" end
	for i = 5,1,-1 do
		for _,pre in pairs(pres) do
			local suff = i == 1 and "" or ("-" .. i)
			local name = pre .. base .. suff .. suffix
			--log(name)
			if techExists(name) then
				log("Found tier " .. i .. " of '" .. base .. "'")
				return name
			end
			
			suff = i == 1 and "" or ("-mk" .. i)
			name = pre .. base .. suff .. suffix
			--log(name)
			if techExists(name) then
				log("Found tier " .. i .. " of '" .. base .. "'")
				return name
			end
			
			if i == 1 then
				suff = "-1"
				name = pre .. base .. suff .. suffix
				if techExists(name) then
					log("Found tier " .. i .. " of '" .. base .. "'")
					return name
				end
			end
		end
	end
	error("Could not find any tier for tech '" .. base .. "'!")
end

local function getTechWithFallback(tech, fallback)
	if techExists(tech) then
		return tech
	else
		log("Could not find tech " .. tech .. "; defaulting to " .. fallback)
		return fallback
	end
end

local function buildPrereqs(prereqs)
	local ret = {}
	for _,req in pairs(prereqs) do
		if type(req) == "string" then
			local add = nil
			for _,pre in pairs(pres) do
				if techExists(pre .. req) then
						add = pre .. req
					break
				end
			end
			if add then
				table.insert(ret, add)
			else
				log("Could not find technology '" .. req .. "'! Skipping!")
			end
		else
			error("Invalid prerequisite!")
		end
	end
	return ret
end

local function createAndRegisterTech(name, prereqs, recipes, packs)
	local tech = createTech(name, buildPrereqs(prereqs), recipes, packs)
	registerTech(tech)
end

--total cost 25000 packs
createAndRegisterTech("space-travel", {"rocket-silo", "titanium-processing"}, {"hull-panel", "scaffolding", "window"}, 250)
createAndRegisterTech("orbital-assembly", {"space-travel", "asteroid-mining", getMaxTierOf("automation"), getTechWithFallback("bob-robots-4", "construction-robotics")}, {"drydock-component"}, 2500)
createAndRegisterTech("deep-space-travel", {"orbital-assembly"}, {"body-segment"}, 2000)
createAndRegisterTech("starship-construction", {"deep-space-travel"}, {}, 1000)
createAndRegisterTech("interstellar-travel", {"starship-construction"}, {}, 5000)
createAndRegisterTech("space-sensors", {"advanced-electronics-2", "rocket-silo"}, {"scanner"}, 250)
createAndRegisterTech("starship-control-systems", {"space-sensors", "space-travel", getMaxTierOf("advanced-electronics")}, {"control-computer", "thermal-control-unit"}, 750)
createAndRegisterTech("space-combat", {"space-travel", "military-4"}, {}, 750)
createAndRegisterTech("ship-shielding", {"space-combat", "interstellar-travel", getMaxTierOf("energy-shield", "-equipment")}, {"shield-emitter"}, 500)
createAndRegisterTech("space-weaponry", {"space-combat", "artillery-shell-range-7", "starship-control-systems", getTechWithFallback("plasma-turrets", "laser-turrets")}, {"targeting-computer", "forward-gun", "defence-turret"}, 1500)
createAndRegisterTech("maintenance-bay", {"deep-space-travel", getMaxTierOf("automation")}, {"maintenance-bay"}, 500)
createAndRegisterTech("cargo-bay", {"deep-space-travel", "electric-engine", getTechWithFallback("bob-robots-4", "logistic-robotics"), "angels-warehouses"}, {"cargo-bay"}, 500)
createAndRegisterTech("artificial-gravity", {"deep-space-travel", "electric-engine"}, {"habitation-rotator"}, 1500)
createAndRegisterTech("ship-fuel-system", {"starship-construction", getMaxTierOf("fluid-handling")}, {"fuel-tank"}, 500)
createAndRegisterTech("ram-scoop", {"interstellar-travel", "ship-fuel-system"}, {"ram-scoop-section"}, 1000)
createAndRegisterTech("power-system", {"deep-space-travel", getMaxTierOf("electric-energy-distribution"), getMaxTierOf("electric-energy-accumulators")}, {"power-storage-unit", "power-conduit", "power-coupler"}, 1500)
createAndRegisterTech("habitat-simulation", {"artificial-gravity", "interstellar-travel", "bob-greenhouse"}, {"habitation-section"}, 1000)
createAndRegisterTech("fusion-engines", {"interstellar-travel", getMaxTierOf("fusion-reactor-equipment"), "electric-engine", "nuclear-power", "tungsten-processing"}, {"fusion-engine", "fusion-engine-cluster"}, 2500)
createAndRegisterTech("space-solar-power", {"power-system", getMaxTierOf("solar-energy")}, {"solar-wing", "solar-array"}, 500)
createAndRegisterTech("bridge", {"starship-control-systems", "starship-construction"}, {"bridge"}, 1000)

--[[
for _,tech in pairs(myTechs) do
	for _,unlock in pairs(tech.effects) do
		if unlock.type == "unlock-recipe" then
			local recipe = unlock.recipe
			for _,ingredient in pairs(recipe.ingredients) do
				--add any tech prereqs
			end
		end
	end
end
--]]

--[[
createAndRegisterTech("orbital-assembly", {"rocket-silo"}, {"hull-panel", "scaffolding"}, 7500)
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
--]]