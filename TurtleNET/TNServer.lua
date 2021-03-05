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
        local posX = 1
        for k, v in pairs(TN.registered) do
            mon.setCursorPos(1, 2+posX)
            mon.write(v.label)

            if v.infoMsg then
                posX = posX + 1
                mon.setCursorPos(1, 2+posX)
                mon.write("\t")
                mon.write("Msg: \"" .. v.infoMsg .. "\"")
            end
            if v.gps then
                posX = posX + 1
                mon.setCursorPos(1, 2+posX)
                mon.write(" ")
                mon.write("Location: " .. v.gps[1] .. ", " .. v.gps[2] .. ", " .. v.gps[3])
            end
            if v.lastContact then
                posX = posX + 1
                mon.setCursorPos(1, 2+posX)
                mon.write(" ")
                mon.write("Last contact: " .. math.ceil((os.epoch("utc") - v.lastContact)/1000) .. "s ago")
            end

            posX = posX + 1
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
            TN.recvInfo(sId, message.data)
        end

        TN.updateMonitor()
    end
end

function TN.register(TId, data)
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

function TN.recvInfo(TId, data)
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
TN.updateMonitor()
while true do TN.receive() end