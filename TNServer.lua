--TurtleNET Server
--Pastebin: https://pastebin.com/q9Ngw9Fg
------------------
local modem = rednet.open("right")
local mon = peripheral.find("monitor")
local TN = {}
TN.registered = {}
TN.contactTimout = 60000

------------------

function TN.updateMonitor()
    local title = "-- TurtleNET Server --"

    local w, h = mon.getSize()
    local posX, posY = w/2 - #title/2, 1

    mon.clear()
	mon.setTextColor(colors.white)
    mon.setCursorPos(posX, posY)
    mon.write(title)

    mon.setCursorPos(1, 2)
    mon.write("Registered Turtles:")
	
    if #TN.registered > 0 then
        local yOffset = 1
		
        for k, v in pairs(TN.registered) do
            mon.setCursorPos(1, 2 + yOffset)
            mon.write(v.label)

            if v.infoMsg then
                yOffset = yOffset + 1
                mon.setCursorPos(1, 2 + yOffset)
                mon.write(("  Msg: '%s'"):format(v.infoMsg))
            end
			
            if v.gps then
                yOffset = yOffset + 1
                mon.setCursorPos(1, 2 + yOffset)
				
				local diff = getTickCount() - v.lastContact
				if diff <= 1000 then
					mon.setTextColor(colors.yellow)
				end
				
                mon.write(("  GPS: %d, %d, %d"):format(unpack(v.gps[1])))
				mon.setTextColor(colors.white)
            end
			
            if v.lastContact then
                yOffset = yOffset + 1
                mon.setCursorPos(1, 2 + yOffset)
				
				local diff = getTickCount() - v.lastContact
				if diff > TN.contactTimout then
					mon.setTextColor(colors.red)
				end
				
				mon.write(("  Last contact: %ds ago"):format(diff/1000))
				mon.setTextColor(colors.white)
            end

            yOffset = yOffset + 1
        end
    else
        mon.setCursorPos(1, 3)
        mon.write(" - ")
    end
end

function TN.receive()
    local sId, message = rednet.receive("TN", 1)

    if message and message.cmd then
        if message.cmd == "register" then
            TN.register(sId)
			TN.handleData(sId, message.data)
		elseif message.cmd == "unregister" then
			TN.unregister(sId)
        elseif message.cmd == "status" then
            TN.handleData(sId, message.data)
        end
    end
	
	TN.updateMonitor()
	TN.check()
end

function TN.check()
	for k, v in pairs(TN.registered) do
		if v.lastContact then
			local diff = getTickCount() - v.lastContact
			if diff > TN.contactTimout then
				print(("Missing contact from turtle %s since %d seconds!"):format(v.label, TN.contactTimout/1000))
				print("Last known positions:")
				print("   X    Y    Z")
				for _, pos in pairs(v.gps) do
					print(("  %d    %d    %d"):format(unpack(pos)))
				end
				
				-- Todo: Use a printer peripheral
			end
		end
	end
end

------------------

function TN.register(TId)
	if TN.isTurtleRegistered(TId) then
		print(("Turtle %d is already registered"):format(TId))
		return
	end

    local registerTable = {
        Id = TId,
        label = nil,
        infoMsg = nil,
        gps = {},
        lastContact = getTickCount
    }

    table.insert(TN.registered, registerTable)
    print(("Turtle %d registered"):format(TId))
end

function TN.unregister(TId)
	local turtle, key = TN.getTurtleFromId(TId)
	if turtle then
		print(("Unregister turtle: %s"):format(turtle.label))
		table.remove(TN.registered, key)
	end
end

function TN.handleData(TId, data)
	if not data then return end
	local turtle, key = TN.getTurtleFromId(TId)
	
	if turtle then
		if data.label then
			turtle.label = data.label
		end
	
		if data.infoMsg then
			turtle.infoMsg = data.infoMsg
		end
		
		if data.gps then
			table.insert(turtle.gps, 1, data.gps)
			
			if #turtle.gps > 10 then
				table.remove(turtle.gps, #turtle.gps)
			end
		end
		
		turtle.lastContact = getTickCount()
	end
end

------------------

function TN.isTurtleRegistered(TId)
	return TN.getTurtleFromId(TId) ~= false
end

function TN.getTurtleFromId(TId)
	for k, v in pairs(TN.registered) do
		if v.Id == TId then
			return v, k
		end
	end
	
	return false
end

function getTickCount()
	return os.epoch("utc")
end

------------------

TN.updateMonitor()

while true do TN.receive() end