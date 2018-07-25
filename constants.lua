local function buildComponentList(tab)
	local ret = {}
	for i = 1,#tab,2 do
		ret[tab[i]] = tab[i+1]
		log("Registering starship component '" .. tab[i] .. "' x" .. tab[i+1])
	end
	return ret
end

drydockComponents = buildComponentList({"drydock-component", 10})

shipComponents = buildComponentList({"maintenance-bay", 1, "body-segment", 20, "cargo-bay", 1, "ram-scoop-section", 30, "solar-array", 2, "forward-gun", 2, "fusion-engine-cluster", 8, "power-coupler", 1, "fuel-tank", 6, "bridge", 1, "defence-turret", 15, "shield-emitter", 18})