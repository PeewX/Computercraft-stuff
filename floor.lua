--FLS (FloorLightSystem)
------------
local modem = peripheral.find("modem", rednet.open)
local mon = peripheral.find("monitor")
local FLS = {positions = {}}

local x = {-594, -590}
local z = {-1235, -1239}
local h = 70
local monSize = 5

function FLS.updateMonitor()
	for k, v in pairs(FLS.positions) do
		if getTickCount() - v.tick > 5000 then
			local relX = x[2] - v.pos[1]
			local relY = z[2] - v.pos[3]
			print(relX .. " - " .. relY)
			local w, h = mon.getSize()
			mon.setCursorPos(w/monSize*relX, h/monSize*relY)
			mon.setTextColor(colors.red)
			mon.write(".")
		end
	end
end

function FLS.checkPosition(position)
	return (position[1] >= x[1] and position[1] <= x[2] and	position[3] >= z[1] and	position[3] <= z[2])
end

function FLS.receive()
	local sId, message = rednet.receive("FLS", 1)
	if message and type(message) == "table" then
		if FLS.checkPosition(message) then
			table.insert(FLS.positions, {pos = message, tick = getTickCount()})
		end
--	else
--		print("Received invalid message")
	end
	
	FLS.updateMonitor()
end

---

function getTickCount()
	return os.epoch("utc")
end

---

while true do FLS.receive() end