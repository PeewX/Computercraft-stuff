local CRITICAL_TEMP = 431.97 -- Kelvin (0 K = -273,15 °C)
local CRITICAL_DAMAGE = 0.1 -- Percent
local CRITICAL_COOLANT = 0.75 -- Percent
local CRITICAL_WASTE = 0.2 -- Percent
local CRITICAL_FUEL = 0.05 -- Percent

local reactor = peripheral.find("fissionReactorLogicAdapter")

if not reactor then
	print("reactor not found")
	return
end

local checkFunctions = {
	temp = function(d) return d < CRITICAL_TEMP, string.format("Temperature: %.2f K", d) end,
	damage = function(d) return d < CRITICAL_DAMAGE, string.format("Damage: %.1f%%", d*100)  end,
	coolant = function(d) return d > CRITICAL_COOLANT, string.format("Coolant: %.1f%%", d*100) end,
	waste = function(d) return d < CRITICAL_WASTE, string.format("Waste: %.1f%%", d*100) end,
	fuel = function(d) return d > CRITICAL_FUEL, string.format("Fuel: %.1f%%", d*100)  end,
}

function check(data)
	for key, value in pairs(data) do
		if (checkFunctions[key]) then
			if not checkFunctions[key](value) then
				return false, key
			end
		end
	end
	
	return true
end

function updateData()
	local data = {
		running = reactor.getStatus(),
		temp = reactor.getTemperature(),
		damage = reactor.getDamagePercent(),
		coolant = reactor.getCoolantFilledPercentage(),
		waste = reactor.getWasteFilledPercentage(),
		fuel = reactor.getFuelFilledPercentage(),
	}
	
	return data
end

while true do
    local status, data = pcall(updateData)
	if status then
		local result, err = check(data)
		if not result then
			pcall(reactor.scram)
			shell.run("clear")
			print("SCRAM REACTOR DUE TO: " .. err)
			break
		end
	
		shell.run("clear")
		for key, value in pairs(data) do
			print(key .. ": " .. tostring(value))
		end
		
	else
		print("Update data failed!")
		print("Error: " .. data)
		print("Try to shutdown the reactor!")
		pcall(reactor.scram)
	end
    
	sleep(0.1)
end