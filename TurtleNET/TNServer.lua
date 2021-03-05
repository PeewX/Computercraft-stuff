--TurtleNET Server
--Pastebin: https://pastebin.com/q9Ngw9Fg
------------------
local modem = rednet.open("right")
local mon = peripheral.find("monitor")
local TN = {}
TN.registered = {}

------------------

function TN.updateMonitor()
    local title = "-- TurtleNET Server --"

    local w, h = mon.getSize()
    local posX, posY = w/2 - #title/2, 1

    mon.clear()
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
                mon.write(("  GPS: %d, %d, %d"):format(unpack(v.gps)))
            end
            if v.lastContact then
                yOffset = yOffset + 1
                mon.setCursorPos(1, 2 + yOffset)
				mon.write(("  Last contact: %ds ago"):format((os.epoch("utc") - v.lastContact)/1000))
            end

            yOffset = yOffset + 1
        end
    else
        mon.setCursorPos(1, 3)
        mon.write("None")
    end
end

function TN.receive()
    local sId, message, dis = rednet.receive("TN", 1)

    if message and message.cmd and message.data then
        if message.cmd == "register" then
            TN.register(sId, message.data)
        elseif message.cmd == "status" then
            TN.receiveInfo(sId, message.data)
        end
    end
	
	TN.updateMonitor()
end

------------------

function TN.register(TId, data)
	if TN.isTurtleRegistered(TId) then
		print(("Turtle %s is already registered"):format(TId))
		return
	end

    local registerTable = {
        Id = TId,
        label = data.label,
        infoMsg = nil,
        gps = nil,
        lastContact = os.epoch("utc")
    }

    table.insert(TN.registered, registerTable)
    print("Registered Turtle: " .. TId)
end

function TN.unregister(TId)
	local turtle, key = TN.getTurtleFromId(TId)
	if turtle then
		print(("Unregister turtle: %s"):format(turtle.label))
		table.remove(TN.registered, key)
	end
end

function TN.receiveInfo(TId, data)
    for k, v in pairs(TN.registered) do
        if v.Id == TId then
            if data.infoMsg then
                TN.registered[k].infoMsg = data.infoMsg
            end

            if data.gps then
                TN.registered[k].gps = data.gps
            end
            v.lastContact = os.epoch("utc")
        end
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

------------------

TN.updateMonitor()

while true do TN.receive() end