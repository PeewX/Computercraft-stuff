--os.pullEvent = os.pullEventRaw
local t = turtle
local p = {forward = 0}


function p.init()
	term.clear()
	term.setCursorPos(1,1)
	
	--Variabels
	p.trash = {"cobblestone", "dirt", "gravel", "lead", "yellorite"}
	p.length = 0
	p.availableSlots = 0
	p.trashSlots = {}
	p.fuelSlots = {}
	
	p.checkInventory()
	p.checkForRefuel()
	
	p.run()
end

function p.run()
	while true do
		p.checkInventory()
		p.checkForRefuel()
		if not p.dropTrash() then
			p.print("out of space")
			break
		end

		p.digUp()
		t.turnLeft()
		p.dig()
		p.up()
		p.dig()
		t.turnRight()
		t.turnRight()
		p.dig()
		p.down()
		p.dig()
		t.turnLeft()
		
		p.dig()
		if not p.forward() then
			print("Aborted")
			break
		end
		
		p.length = p.length + 1
		if p.length == 15 then
			t.turnLeft()
			t.turnLeft()
			t.select(16)
			t.place()
			t.turnLeft()
			t.turnLeft()
			p.length = 0
		end
	end
end

function p.checkInventory()
	p.availableSlots = 0
	for i = 1, 16 do
		local item = t.getItemDetail(i)
		
		if item and item.name:lower():find("coal") and not p.isInTable(p.fuelSlots, i) then
			table.insert(p.fuelSlots, i)
		end
		
		if item and p.isTrash(item.name) and not p.isInTable(p.trashSlots, i) then
			table.insert(p.trashSlots, i)
		end
		
		if not item then
			p.availableSlots = p.availableSlots + 1
		end
	end
end

function p.checkForRefuel()
	if t.getFuelLevel() == 0 then
		p.print("Refuel!")
		t.select(p.fuelSlots[#p.fuelSlots])
		table.remove(p.fuelSlots, #p.fuelSlots)
		t.refuel(32)
	end
end

function p.dig()
	while t.detect() do
		if t.dig() then
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function p.digUp()
	while t.detectUp() do
		if t.digUp() then
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function p.digDown()
	while t.detectDown() do
		if t.digDown() then
			sleep(0.5)
		else
			return false
		end
	end
	return true
end

function p.up()
	while not t.up() do
		if t.detectUp() then
			if not p.digUp() then
				return false
			end
		else
			sleep( 0.5 )
		end
	end
	return true
end

function p.down()
	while not t.down() do
		if t.detectDown() then
			if not p.digDown() then
				return false
			end
		else
			sleep( 0.5 )
		end
	end
	return true
end

function p.forward()
	while not t.forward() do
		if t.detect() then
			if not p.dig() then
				return false
			end
		else
			sleep( 0.5 )
		end
	end
	return true
end

function p.dropTrash()
	if p.availableSlots == 0 then
		if #p.trashSlots > 0 then
			for _, slot in ipairs(p.trashSlots) do
				t.select(slot)
				t.drop()
			end
			p.trashSlots = {}
		else
			return false
		end
	end
	return true
end

function p.isTrash(itemName)
	for _, trashItem in ipairs(p.trash) do
		if itemName:lower():find(trashItem) then
			return true
		end
	end
end

function p.isInTable(tTheTable, x)
	for k, v in ipairs(tTheTable) do
		if v == x then
			return true
		end
	end
	return false
end

function p.print(t)
  print(("[AI] %s"):format(t))
end

p.init()
