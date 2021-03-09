-- StripMining
-- ©2021 Namo
-- Pastebin: https://pastebin.com/7Jt83cY2
------------------------------------------
os.loadAPI("TurtleNET/TNClient.lua")
local TN = TNClient.TN

local t = turtle
local p = {
	goLeft = true,
	loadingChunks = 8,
	tunnelsToDig = 20,
	minFuel = 3,

	stepsToGo = 0,
	stepsMoved = 0,

	burnable = {
		"wood",
		"plank",
		"fence",
		"coal",
		"charcoal"
	}
}
------------------------------------------

local input = {...}
if #input > 0 then
	if #input == 3 and tonumber(input[2]) and tonumber(input[3]) then
		p.goLeft = input[1] == "left"
		p.loadingChunks = math.abs(math.floor(input[2] or 8))
		p.tunnelsToDig = math.abs(math.floor(input[3] or 20))
	else
		print("Invalid args!\nstripmine left/right chunksMv tunnelCt\nExample: stripmine left 8 20")
		return
	end
end

function main()
    TN.register()
	p.run()
end

function p.run()
    p.stepsToGo = p.tunnelsToDig * p.loadingChunks * 16

	for i = 0, p.tunnelsToDig do
		if not p.move(p.loadingChunks * 16) then
			break;
		end
		p.turn()
	end

	TN.sendInfo("I am done. Come and pick me up")
end

function p.move(steps)
	if steps == nil or steps < 1 then
		steps = 1
	end

	for i = 1, steps do
		if not p.checkFuel() then
			if not p.refuel() then
			    return false
			end
		end

		if t.detect() then t.dig() end
		
		while not t.forward() do
			t.dig()
			sleep(0.5)
		end
		
		-- send gps if successfully moved
		p.stepsMoved = p.stepsMoved + 1
        TN.sendInfo(("Progress %.2f%%"):format((100 / p.stepsToGo) * p.stepsMoved))

		if t.detectUp() then t.digUp() end

		if not p.checkInventorySpace() then
			if not p.freeInventory() then
				return false
			end
		end
	end

	return true
end

function p.turn()
	if p.goLeft then
		-- turn left
		t.turnLeft()
		p.move(3)
		t.turnLeft()
	else
		-- turn right
		t.turnRight()
		p.move(3)
		t.turnRight()
	end
	p.goLeft = not p.goLeft
end

function p.checkFuel()
	local fuel = t.getFuelLevel()
	if fuel < p.minFuel then
		return false
	end

	return true
end

function p.refuel()
	local item = nil
	for i = 1, 16 do
		item = t.getItemDetail(i)
		if item and p.isInTable(p.burnable, item.name) then
			t.select(i)
			t.refuel()
		end
	end

	if not p.checkFuel() then
	    TN.sendInfo("Help Me. I am out of fuel")
	    return false
	end

	return true
end

function p.checkInventorySpace()
	for i = 1, 16 do
		if t.getItemCount(i) == 0 then
			return true
		end
	end

	return false
end

function p.freeInventory()
	local item = nil
	local chestPlaced = false;
	local itemsToDrop = {}

	p.refuel()

	-- search for a chest in the inventory
	for i = 1, 16 do
		if t.getItemCount(i) > 0 then
			item = t.getItemDetail(i)
			if item and item.name:find("chest") then
				-- place down the chest
				t.select(i)
				t.digDown()
				t.placeDown()
				chestPlaced = true
				
				TN.sendInfo(("Placed Chest: %d, %d, %d"):format({gps.locate()}))
			else
				table.insert(itemsToDrop, i)
			end
		end
	end

	if not chestPlaced then
		TN.sendInfo("My Inventory is full. Its to heavy to go ahead")
		return false
	end

	-- drop items into the chest
	for _, v in ipairs(itemsToDrop) do
		t.select(v)
		t.dropDown()
	end

	return true
end

function p.isInTable(ttable, item)
	for k, v in ipairs(ttable) do
		if item:find(v) then
			return true
		end
	end
	return false
end

main()