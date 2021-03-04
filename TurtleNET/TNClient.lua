--TurtleNET Client
rednet.open("right");
local TN = {}

function TN.register()
    local msg = {
        cmd = "register",
        data = {
            label = os.getComputerLabel()
        }
    }

    rednet.broadcast(msg, "TN")
end

function TN.sendInfo()
    local msg = {
        cmd = "status",
        data = {
            gps = { gps.locate() }
        }
    }
    rednet.broadcast(msg, "TN")
end

TN.register()
TN.sendInfo()