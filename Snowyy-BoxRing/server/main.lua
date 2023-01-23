ESX                   = nil

local fight           = {}
local bluePlayerReady = false
local redPlayerReady  = false

TriggerEvent('esx:getSharedObject',
    function(obj)
        ESX = obj
    end
)

RegisterServerEvent('Snowyy-Boxring:join')
AddEventHandler('Snowyy-Boxring:join', function(betAmount, side)

        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)

		if side == 0 then
			bluePlayerReady = true
		else
			redPlayerReady = true
		end

        local fighter = {
            id = source,
            amount = betAmount
        }
        table.insert(fight, fighter)

        balance = xPlayer.getMoney()
        if (balance > betAmount) or betAmount == 0 then
            xPlayer.removeMoney(betAmount)
            TriggerClientEvent('esx:showNotification', source, 'je neem deel aan de ~o~stijd~w~ even wachten op je ~r~Tegenstander')

            if side == 0 then
                TriggerClientEvent('Snowyy-Boxring:playerJoined', -1, 1, source)
            else
                TriggerClientEvent('Snowyy-Boxring:playerJoined', -1, 2, source)
            end

            if redPlayerReady and bluePlayerReady then 
                TriggerClientEvent('Snowyy-Boxring:startFight', -1, fight)
            end

        else
            TriggerClientEvent('esx:showNotification', source, 'Je hebt Geen ~r~Geld')
        end
end)

local count = 240
local actualCount = 0
function countdown(copyFight)
    for i = count, 0, -1 do
        actualCount = i
        Citizen.Wait(1000)
    end

    if copyFight == fight then
        TriggerClientEvent('Snowyy-Boxring:fightFinished', -1, -2)
        fight = {}
        bluePlayerReady = false
        redPlayerReady = false
    end
end

RegisterServerEvent('Snowyy-Boxring:finishFight')
AddEventHandler('Snowyy-Boxring:finishFight', function(looser)
       -- print("de verliezer is" .. loser)
       TriggerClientEvent('Snowyy-Boxring:fightFinished', -1, looser)
       fight = {}
       bluePlayerReady = false
       redPlayerReady = false
end)

RegisterServerEvent('Snowyy-Boxring:leaveFight')
AddEventHandler('Snowyy-Boxring:leaveFight', function(id)
       if bluePlayerReady or redPlayerReady then
            bluePlayerReady = false
            redPlayerReady = false
            fight = {}
            TriggerClientEvent('Snowyy-Boxring:playerLeaveFight', -1, id)
       end
end)

RegisterServerEvent('Snowyy-Boxring:pay')
AddEventHandler('Snowyy-Boxring:pay', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addMoney(amount * 2)
end)

RegisterServerEvent('Snowyy-Boxring:raiseBet')
AddEventHandler('Snowyy-Boxring:raiseBet', function(looser)
       TriggerClientEvent('Snowyy-Boxring:raiseActualBet', -1)
end)

RegisterServerEvent('Snowyy-Boxring:showWinner')
AddEventHandler('Snowyy-Boxring:showWinner', function(id)
       TriggerClientEvent('Snowyy-Boxring:winnerText', -1, id)
end)