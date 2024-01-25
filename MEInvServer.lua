-- Applied Energistics 2, ME Interface
local meBridge

local protocol = "meInv"

function main()
    init()
    while true do
        recieveRednet()
    end
end

function init()
    rednet.open("back")
    meBridge = peripheral.find("meBridge")
end

function recieveRednet()
    local idFrom, msg, _ = rednet.receive(protocol)

    local msgTable = splitString(msg)
    local funcName = msgTable[1]
    table.remove(msgTable, 1)

    if (funcName == "sendItem") then
        local amount = tonumber(msgTable[1])
        table.remove(msgTable, 1)
        local name = table.concat(msgTable, " ")
        sendItem(amount, name)
    elseif (funcName == "toggleOffHand") then
        toggleOffHand()
    end
end

--- Sends the given amount of the given item to the player
---@param amount number
---@vararg string
function sendItem(amount, ...)
    if (amount == nil) then
        amount = 1
    end

    local itemName = table.concat({...}, " ")
    itemName = string.lower(itemName)

    for k, v in pairs(meBridge.listItems()) do
        local meItemName = string.lower(v["displayName"])
        if (meItemName == itemName) then
            local itemToSend = v
            itemToSend.count = amount
            meBridge.exportItem(itemToSend, "right")
            print("Sending " .. itemToSend["count"] .. "x " .. itemToSend["displayName"])
        end
    end
end

--- Enables a redstone signal on the bottom side to deactivate/activate the item transfer of the offhand
function toggleOffHand()
    if (redstone.getAnalogOutput("bottom") > 0) then
        print("Enabled Off-Hand transfer")
        redstone.setAnalogOutput("bottom", 0)
    else
        print("Disabled Off-Hand transfer")
        redstone.setAnalogOutput("bottom", 15)
    end
end

--- Splits the given string on each space
---@param text string
---@return table
function splitString(text)
    local resultTable = {}

    for token in string.gmatch(text, "[^%s]+") do
        table.insert(resultTable, token)
    end

    return resultTable
end

main()