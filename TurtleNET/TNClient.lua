--TurtleNET Client
rednet.open("right");
TN = {}

function TN.register()
    local msg = {
        cmd = "register",
        data = {
            label = os.getComputerLabel()
        }
    }

    rednet.broadcast(msg, "TN")
end

function TN.sendInfo(info)
    local msg = {
        cmd = "status",
        data = {
            infoMsg = info,
            gps = { gps.locate() }
        }
    }
    rednet.broadcast(msg, "TN")
end

TN.register()
TN.sendInfo()