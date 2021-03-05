-- ©2021 Namo

local t = turtle
local stats = {} -- Containing Turtle Infos (redNet)
local redNet = {}
local p = {
	goLeft = true,
	loadingChunks = 8,
	tunnelsToDig = 5,
	minFuel = 3,

	burnable = {
		"wood",
		"plank",
		"fence",
		"coal",
		"charcoal"
	}
}

-- TODO:
-- redNet Service
-- Program arguments

function main()
	-- start redNet Service (send Infos to Server / retrive commands: start/stop)
    os.loadAPI("TNClient")
    TNClient.TN.register()

    -- start turtle thread (Coroutine?)
    p.run()
end

function p.run()
	for i = 0, p.tunnelsToDig do
		if not p.move(p.loadingChunks * 16) then
			break;
		end
		p.turn()
	end
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
		-- send gps if successfully moved
		if t.forward() then
		   TNClient.TN.sendInfo()
		end
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
	p.goLeft = not p.goLeft
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
	    TNClient.TN.sendInfo("Help Me. I am out of fuel")
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
			else
				table.insert(itemsToDrop, i)
			end
		end
	end

	if not chestPlaced then
		-- print error (rednet)?
		TNClient.TN.sendInfo("My Inventory is full. Its to heavy to go ahead")
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