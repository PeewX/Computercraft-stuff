--TurtleNET Client
--Pastebin: https://pastebin.com/JN8iU1V6
------------------
rednet.open("left");
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

function TN.unregister()
	local msg = {
		cmd = "unregister"
	}
	
	rednet.broadcast(msg, "TN")
end

function TN.sendInfo(info)
    local mstg = {
        cmd = "status",
        data = {
            infoMsg = info,
            gps = { gps.locate() }
        }
    }
    rednet.broadcast(msg, "TN")
end