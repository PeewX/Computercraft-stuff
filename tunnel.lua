--os.pullEvent = os.pullEventRaw
local t = turtle
local p = {forward = 0}

function tobool(val)
	local t = type(val)
	if (t == 'nil') then
			return false
	elseif (t == 'boolean') then
			return val
	elseif (t == 'number') then
			return (val ~= 0)
	elseif (t == 'string') then
			return ((val ~= '0') and (val ~= 'false'))
	end
	return false
end

local input = {...}
if #input < 1 then
	--term.clear()
	--term.setCursorPos(1,1)
	print("Invalid usage!")
	print("pew {int:length} [{bool:redstoneSignal} {bool:returnHome}]")
	return
else
	p.length = math.abs(input[1])
	p.waitForRedstone = tobool(input[2])
	p.returnHome = tobool(input[3])
end

function p.init()
	term.clear()
	term.setCursorPos(1,1)
	
	--Variables
	--p.trash = {"cobblestone", "dirt", "gravel", "lead", "yellorite"}
	p.keepMe = {"iron", "thermalfoundation", "appliedenergistics2", "coal", "gold", "lapis", "uran", "flint", "torch", "emerald"}
	p.cLength = 0
	p.availableSlots = 0
	p.trashSlots = {}
	p.fuelSlots = {}
	
	p.checkInventory()
	p.checkForRefuel()
	
	p.availableSteps = math.floor(t.getFuelLevel()/3) --Think the turtle need 3 fuel for one step
	p.print("Length set to: " .. p.length)
	if p.availableSteps < p.length then
		p.print("Without refuel I can only do " .. p.availableSteps)
	end
	
	--Wait for redstone if we want
	if p.waitForRedstone then
		print("")
		p.print("I Just wait for a redstone signal :>")
		while not redstone.getInput("back") do
			sleep(0.5)
		end
	end
	
	--Let the turtle do his job.. :>
	p.display()
	p.run()
end

function p.run()
	while true do
		--Check at first some states
		p.checkInventory()
		p.checkForRefuel()
		
		if p.availableSlots == 0 then
			--If no slot available, sort inventory and check again
			p.sortInventory()
			p.checkInventory()
			
			if p.availableSlots == 0 then
				--If there is still no slot available, drop trash
				if not p.dropTrash() then
					--In case of no drop, wait for manual clearing
					p.print("No empty slot! Wait for manual clearing")
					while p.availableSlots == 0 do
						p.checkInventory()
						sleep(0.5)
					end
				end
			end
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
		
		p.cLength = p.cLength + 1
		if p.cLength%15 == 0 then
			p.placeTorch()
		end
		
		p.display()
		if p.cLength >= p.length then
				term.clear()
				term.setCursorPos(1,1)
				p.print("Done!")
				
				if p.returnHome then
					term.clear()
					term.setCursorPos(1,1)
					p.print("RETURN  TO HOME")
					
					t.turnLeft()
					t.turnLeft()
					for k = 1, p.length do
						p.checkForRefuel()
						p.forward()
					end
					t.turnLeft()
					t.turnLeft()
				end
			break
		end
	end
end

function p.placeTorch()
	if t.getItemDetail(16) and t.getItemDetail(16).name:lower():find("torch") then
		t.select(16)
		t.turnLeft()
		t.turnLeft()
		t.place()
		t.turnLeft()
		t.turnLeft()
	end
end

function p.sortInventory()
	for i = 16, 1, -1 do
		t.select(i)
		for d = 1, 16 do
			if i ~= k and t.transferTo(d) then break end
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
	if t.getFuelLevel() <= 3 then
		p.print("Fuel is empty!")
		if #p.fuelSlots > 0 then
			p.print("Auto refuel available..")
			t.select(p.fuelSlots[#p.fuelSlots])
			table.remove(p.fuelSlots, #p.fuelSlots)
			t.refuel(16)
		else
			p.print("Waiting for manual refuel..")
			while t.getFuelLevel() <= 3 do
				for i = 1, 16 do
					t.select(i)
					if t.refuel(16) then
						print("Success!")
						break
					end
				end
			end
		end
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
	if p.trash then
		for _, trashItem in ipairs(p.trash) do
			if itemName:lower():find(trashItem) then
				return true
			end
		end
		return false
	elseif p.keepMe then
		for _, trashItem in ipairs(p.keepMe) do
			if itemName:lower():find(trashItem) then
				return false
			end
		end
		return true
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

function p.display()
	term.clear()
	term.setCursorPos(1,1)
	print("")		
	print("---------------------------------------")
	print(("Progress: %s/%s (%s%%)"):format(p.cLength, p.length, p.cLength/p.length*100))
	print(("Fuel: %s (%s)"):format(t.getFuelLevel(), math.floor(t.getFuelLevel()/3)))
	print(("Trash count: %s"):format(#p.trashSlots))
	print("")
	print(("Place torch in: %s"):format(15-p.cLength%15))
	local x, y = term.getSize()
	term.setCursorPos(1, y)
	print(string.rep("=", p.cLength/p.length*x) .. ">")
	term.scroll(-1)
	term.setCursorPos(1,1)
	print("PewX Miner v1                   (Rev.5)")
end

function p.print(t)
  print(("[AI] %s"):format(t))
end

p.init()
