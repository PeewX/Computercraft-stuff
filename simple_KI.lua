--os.pullEvent = os.pullEventRaw
local t = turtle
local p = {forward = 0}

function p.run()
	while true do
	  if t.detect() and p.isStairs() then
		p.upFails = 0
		while p.isStairs() and p.upFails < 3 do
			local u = t.up()
			local f = t.forward()
				if u and f then
					p.print("detected up stairs")
				else
					print("Fail up")
					p.upFails = p.upFails + 1
				end
		end
	  end
	  
	if p.isStairsDown() then
		p.downFails = 0
		while p.isStairsDown() and p.downFails < 3 do
			local f = t.forward()
			local d = t.down()
			if f and d then 
				p.print("detected down stairs")
			else
				print("Fail down")
				p.downFails = p.downFails + 1
			end
		end
	end
	  
		if not t.forward() then
			p.forward = 0
			p.turnMe()
		else
			p.forward = p.forward + 1
			p.print("Forward " .. p.forward)
			if p.forward >= math.random(3, 20) then
				p.forward = 0
				p.turnMe()
			end
		end
	end
end

function p.turnMe()
	local turns = p.getAvailablePositions()
	if turns == 3 then
		t.turnRight()
	elseif turns == 2 then
		if math.random(1,2) == 1 then t.turnLeft() else t.turnRight() end
	else
		t.turnLeft()
	end
	t.forward()
end

function p.getAvailablePositions()
	local tp = {}
	for i = 1, 3 do
		t.turnLeft()
		if not t.detect() then
			table.insert(tp, i)
		end
	end
	t.turnLeft()
	p.print(#tp .. " available positions")
	return tp[math.random(1, #tp)]
end

function p.isStairs()
  for i = 13, 15 do
    t.select(i)
    if t.compare() then
      return true
    end
  end
end

function p.isStairsDown()
  for i = 13, 15 do
    t.select(i)
    if t.compareDown() then
      return true
    end
  end
end

function p.print(t)
  print(("GPS: %s"):format(t))
end

term.clear()
term.setCursorPos(1,1)
p.run()
