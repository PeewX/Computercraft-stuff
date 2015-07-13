--PewX FarmBot
local t = turtle
local p = {}

function p.init()
	os.setComputerLabel("FarmBot")
	p.nextTurn = t.turnLeft
	t.up()
	t.forward()
	p.validFarming = {"potato", "wheat", "carrot"}
	p.avg = {count = 10, min = 5, datas = {}}
	p.fuelSlots = {}
	
	p.run()
end

function p.run()
	while true do
		--Check at first some states
		p.checkInventory()
		p.checkForRefuel()
		
		if p.availableSlots == 0 then
			--If no slot available, wait for manual clearing
			print("No slot is available. Wait for clearing")
			while p.availableSlots == 0 do
				p.checkInventory()
				sleep(0.5)
			end
		end
	
	
	
		local fb, fd = t.inspectDown()
		if fb then
		--if fb and p.isValidToFarm(fd.name) then
			if p.isValidToFarm(fd.name) then
				print("metadata of farming object: " .. fd.metadata)
				if fd.metadata == 7 then
					t.digDown()
					t.placeDown()
					p.avg.datas = {}
				else
					p.checkAvarage(fd.metadata)
				end
			end
			
			p.turned = false
		else
			print("No block is under me..")
			t.down()
			local gbb, gb = t.inspectDown()
			if gbb and gb.name:find("dirt") then
				print("There is dirt!")
				t.up()
				t.digDown()
				t.placeDown()
				p.turned = false
			elseif gbb and gb.name:find("water") then
				print("there is water :>")
				
				while not t.detect() do
					t.forward()
				end
				
				t.up()
				p.turned = false
			else
				print("There is a fence ! turn :3")
				t.up()
				p.turn()
			end
		end
		
		--If we can't go forward, we think, here is torch or something else..
		if not t.forward() then
			sleep(0.5)
			local upCount = 0
			while not t.forward() do
				--sleep(1)
				upCount = upCount + 1
				t.up()
			end
			
			while t.detectDown() do
				t.forward()
			end
			
			for i = 1, upCount do
				t.down()
			end
		end
	end
end

--This is the most useful function.. the turtle will go in standby, when we not reach the avg minimum - just to save fuel
function p.checkAvarage(nMD)
	if #p.avg.datas < p.avg.count then
		table.insert(p.avg.datas, nMD)
	else
		local avg = 0
		for _, v in ipairs(p.avg.datas) do
			avg = avg + v
		end
		avg = avg/p.avg.count

		p.avg.datas = {}
		if avg < p.avg.min then
			os.setComputerLabel("FarmBot (Standby)")
			
			local sb, sbd = turtle.inspectDown()
			while sb and sbd.metadata < 6 do
				sb, sbd = turtle.inspectDown()
				sleep(0.5)
			end
			
			os.setComputerLabel("FarmBot")
		end
	end
end

function p.turn()
	if p.turned then
		print("Uh, iam already turned without do anything, go back!")
		t.back()
		p.nextTurn()
		t.back()
		p.nextTurn()
		return
	end
	
	p.nextTurn()
	t.forward()
	p.nextTurn()
	
	p.nextTurn = p.nextTurn == t.turnLeft and t.turnRight or t.turnLeft
	p.turned = true
end

function p.checkInventory()
	p.availableSlots = 0
	for i = 1, 16 do
		local item = t.getItemDetail(i)
				
		if item and item.name:lower():find("coal") and not p.isInTable(p.fuelSlots, i) then
			table.insert(p.fuelSlots, i)
		end
				
		if not item then
			p.availableSlots = p.availableSlots + 1
		end
	end
end

function p.checkForRefuel()
	if t.getFuelLevel() <= 3 then
		if #p.fuelSlots > 0 then
			t.select(p.fuelSlots[#p.fuelSlots])
			table.remove(p.fuelSlots, #p.fuelSlots)
			t.refuel(16)
		else
			print("Waiting for manual refuel..")
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

function p.isValidToFarm(theItem)
	for k, v in ipairs(p.validFarming) do
		if theItem:lower():find(v) then
			return true
		end
	end
	return false
end

p.init()
