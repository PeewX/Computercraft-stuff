os.loadAPI("vault")
vault.setDir("/.vault")
local db = vault.open("deaths.np")

function main()
    drawIncidentScreen()

    while true do
        -- Update Day box
        drawDayBox(5, 6, getNumberOfIncidentFreeDays())

        for k, v in pairs(getOnlinePlayers()) do
            local currentDeaths = getPlayerDeaths(v)
            local savedDeaths = db[v]
            if not savedDeaths then
                savedDeaths = 0
                saveToVault(v, 0)
            end

            if (currentDeaths > savedDeaths) then
                handleNewDeath()
                db[v] = currentDeaths
            end
        end

        sleep(5)
    end
end

function drawIncidentScreen()
    local monitor = peripheral.find("monitor")
    term.redirect(monitor)
    term.setCursorBlink(false)

    term.setBackgroundColor(colors.black)
    
    local textScale = 0.5
    monitor.setTextScale(textScale)

    local margin = 1

    paintutils.drawFilledBox(margin, margin, 16, 12, colors.orange)

    -- Header
    term.setCursorPos(margin+1, margin+1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.orange)
    term.write("SAFETY FIRST")

    -- Last Incident
    term.setCursorPos(margin+1, 4)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.black)
    term.write("Days since")
    term.setCursorPos(margin+1, 5)
    term.write("last injury")

    drawDayBox(margin+4, 6, getNumberOfIncidentFreeDays())

    -- Total Accidents
    term.setCursorPos(margin+1, 9)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.black)
    term.write("Total injuries")

    drawDayBox(margin+4, 10, getAllDeaths())
end

function handleNewDeath()
    saveToVault("lastIncident", getUnixtime())

    drawIncidentScreen()
end

function drawDayBox(x, y, days)
    paintutils.drawFilledBox(x, y, x+3, y+1, colors.white)
    term.setCursorPos(x+1, y+1)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.write(days)
end

function getUnixtime()
  local response = http.get("https://worldtimeapi.org/api/timezone/Europe/Berlin.json")
  local result = textutils.unserialiseJSON(response.readAll())
  return result.unixtime
end

function getNumberOfIncidentFreeDays()    
    local lastIncident = db["lastIncident"] or 0
    local unixtime = getUnixtime()
    local diff = unixtime - lastIncident
    
    return math.floor(diff / 60 / 60 / 24)
end

function getOnlinePlayers()
    pd = peripheral.find("playerDetector")

    if not pd then
        return {}
    end

    return pd.getOnlinePlayers()
end

function getAllPlayers()
    local _, playerString = commands.exec("scoreboard players list")

    local offset = string.find(playerString[1], ":") + 2
    local subString = string.sub(playerString[1], offset)

    local playerTable = {}
    for token in string.gmatch(subString, "[^,%s]+") do
        table.insert(playerTable, token)
    end
    return playerTable
end

function getAllDeaths()
    local players = getAllPlayers()
    local deathSum = 0
    for k, v in pairs(players) do
        deathSum = deathSum + getPlayerDeaths(v)
    end
    return deathSum
end

function getPlayerDeaths(playerName)
    local _, _, deaths = commands.exec("scoreboard players get " .. playerName .. " Deaths")
    --local deathString = string.gfind(death[1], " %d+")()
    --return tonumber(string.sub(deathString, 2)) or 0
    return deaths
end

function saveToVault(name, amount)
  db[name] = amount
  vault.flush(db)
end

main()
