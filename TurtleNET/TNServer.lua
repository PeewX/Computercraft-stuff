--TurtleNET Server
------------------
local modem = rednet.open("right")
local mon = peripheral.find("monitor")
local TN = {}
------------------

TN.registered = {}

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
        for k, v in pairs(TN.registered) do
            mon.setCursorPos(1, 2+k)
            mon.write(v.label)
            mon.write(" ")
            mon.write(math.ceil((os.epoch("utc") - v.lastContact)/1000))
        end
    else
        mon.setCursorPos(1, 3)
        mon.write("None")
    end
end

function TN.receive()
    local sId, message, dis = rednet.receive("TN", 1)

    if message and message.cmd, message.data then
        if message.cmd == "register" then
            TN.register(sId, message.data)
        elseif message.cmd == "status" then
            TN.recvInfo(sId, message.data)
        end

        TN.updateMonitor()
    end
end

function TN.register(TId, data)
    local registerTable = {
        Id = TId,
        label = data.label,
        lastContact = os.epoch("utc")
    }

    table.insert(TN.registered, registerTable)
    print("Registered Turtle: " .. TId)
end

function TN.recvInfo(TId, data)
    print("Turtle " .. TId .. ":\n")
    print("X: " .. data.gps[1] .. " | Y: " .. data.gps[2] .. " | Z: " .. data.gps[3])
end