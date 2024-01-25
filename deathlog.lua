os.loadAPI("vault")
vault.setDir("/.vault")
local db = vault.open("deaths.np")

function main()
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

        sleep(60)
    end
end

function handleNewDeath()
    local incidentFreeDays = getNumberOfIncidentFreeDays()

    local monitor = peripheral.find("monitor")
    local oldTerm = term.redirect(monitor)

    term.setBackgroundColor(colors.black)
    term.clear()

    local textScale = 0.5
    monitor.setTextScale(textScale)

    local margin = 1

    paintutils.drawFilledBox(margin, margin, 32*textScale, 24*textScale, colors.orange)

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

    drawDayBox(margin+4, 6, incidentFreeDays)

    -- Total Accidents
    term.setCursorPos(margin+1, 9)
    term.setBackgroundColor(colors.orange)
    term.setTextColor(colors.black)
    term.write("Total injuries")

    drawDayBox(margin+4, 10, getAllDeaths())

    term.redirect(oldTerm)
end

function drawDayBox(x, y, days)
    paintutils.drawFilledBox(x, y, x+3, y+1, colors.white)
    term.setCursorPos(x+1, y+1)
    term.setBackgroundColor(colors.white)
    term.write(days)
end

function getNumberOfIncidentFreeDays()
    local lastIncident = db["lastIncident"] or 0
    return os.day() - lastIncident
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
    local _, death = commands.exec("scoreboard ")
    local deathString = string.gfind(death[1], "%d")()
    return tonumber(deathString) or 1
end

main()