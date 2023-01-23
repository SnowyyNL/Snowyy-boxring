ESX                  = nil

local Gloves         = {}
local fightStatus    = STATUS_INITIAL
local betAmount      = 0
local STATUS_INITIAL = 0
local STATUS_JOINED  = 1
local STATUS_STARTED = 2
local players        = 0
local blueJoined     = false
local redJoined      = false
local showCountDown  = false
local participando   = false
local rival          = nil
local showWinner     = false
local winner         = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(
            'esx:getSharedObject',
            function(obj)
                ESX = obj
            end
        )
        Citizen.Wait(0)
    end
    --CreateBlip(Config.BLIP.coords, Config.BLIP.text, Config.BLIP.sprite, Config.BLIP.color, Config.BLIP.scale) -- [ik Heb blip uitstaan ook in config] --
    RunThread()
end)

RegisterNetEvent('Snowyy-Boxring:playerJoined')
AddEventHandler('Snowyy-Boxring:playerJoined', function(side, id)

        if side == 1 then
            blueJoined = true
        else
            redJoined = true
        end

        if id == GetPlayerServerId(PlayerId()) then
            participando = true
            putGloves()
        end
        players = players + 1
        fightStatus = STATUS_JOINED

end)

RegisterNetEvent('Snowyy-Boxring:startFight')
AddEventHandler('Snowyy-Boxring:startFight', function(fightData)

    for index,value in ipairs(fightData) do
        if(value.id ~= GetPlayerServerId(PlayerId())) then
            rival = value.id      
        elseif value.id == GetPlayerServerId(PlayerId()) then
            participando = true
        end
    end

    fightStatus = STATUS_STARTED
    showCountDown = true
    countdown()

end)

RegisterNetEvent('Snowyy-Boxring:playerLeaveFight')
AddEventHandler('Snowyy-Boxring:playerLeaveFight', function(id)

    if id == GetPlayerServerId(PlayerId()) then
        ESX.ShowNotification('Je bent te ver afgedwaald, je hebt de strijd opgegeven.')
        SetPedMaxHealth(PlayerPedId(), 200)
        SetEntityHealth(PlayerPedId(), 200)
        removeGloves()
    elseif participando == true then
        TriggerServerEvent('Snowyy-Boxring:pay', betAmount)
        ESX.ShowNotification('Je hebt Gewonnen. ~r~' .. (betAmount * 2) .. '$')
        SetPedMaxHealth(PlayerPedId(), 200)
        SetEntityHealth(PlayerPedId(), 200)
        removeGloves()
    end
    reset()

end)

RegisterNetEvent('Snowyy-Boxring:fightFinished')
AddEventHandler('Snowyy-Boxring:fightFinished', function(looser)

    if participando == true then
        if(looser ~= GetPlayerServerId(PlayerId()) and looser ~= -2) then
            TriggerServerEvent('Snowyy-Boxring:pay', betAmount)
            ESX.ShowNotification('Je hebt Gewonnen. ~r~' .. (betAmount * 2) .. '$')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
    
            TriggerServerEvent('Snowyy-Boxring:showWinner', GetPlayerServerId(PlayerId()))
        end
    
        if(looser == GetPlayerServerId(PlayerId()) and looser ~= -2) then
            ESX.ShowNotification('Je hebt de strijd verloren ~r~-' .. betAmount .. '$')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
        end
    
        if looser == -2 then
            ESX.ShowNotification('Het Gevecht is voorbij vanwege de tijdslimiet')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
        end

        removeGloves()
    end
    
    reset()

end)

RegisterNetEvent('Snowyy-Boxring:raiseActualBet')
AddEventHandler('Snowyy-Boxring:raiseActualBet', function()
    betAmount = betAmount * 2
    if betAmount == 0 then
        betAmount = 200
    elseif betAmount > 10000 then
        betAmount = 0
    end
end)

RegisterNetEvent('Snowyy-Boxring:winnerText')
AddEventHandler('Snowyy-Boxring:winnerText', function(id)
    showWinner = true
    winner = id
    Citizen.Wait(5000)
    showWinner = false
    winner = nil
end)

local actualCount = 0
function countdown()
    for i = 5, 0, -1 do
        actualCount = i
        Citizen.Wait(1000)
    end
    showCountDown = false
    actualCount = 0

    if participando == true then
        SetPedMaxHealth(PlayerPedId(), 500)
        SetEntityHealth(PlayerPedId(), 500)
    end
end

function putGloves()
    local ped = GetPlayerPed(-1)
    local hash = GetHashKey('prop_boxing_glove_01')
    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end
    local pos = GetEntityCoords(ped)
    local gloveA = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    local gloveB = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    table.insert(Gloves,gloveA)
    table.insert(Gloves,gloveB)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(gloveA,false)
    SetEntityCollision(gloveA,false,true)
    ActivatePhysics(gloveA)
    FreezeEntityPosition(gloveB,false)
    SetEntityCollision(gloveB,false,true)
    ActivatePhysics(gloveB)
    if not ped then ped = GetPlayerPed(-1); end 
    AttachEntityToEntity(gloveA, ped, GetPedBoneIndex(ped, 0xEE4F), 0.05, 0.00,  0.04,     00.0, 90.0, -90.0, true, true, false, true, 1, true) 
    AttachEntityToEntity(gloveB, ped, GetPedBoneIndex(ped, 0xAB22), 0.05, 0.00, -0.04,     00.0, 90.0,  90.0, true, true, false, true, 1, true) 
end

function removeGloves()
    for k,v in pairs(Gloves) do DeleteObject(v); end
end

function spawnMarker(coords)
    local centerRing = GetDistanceBetweenCoords(coords, vector3(259.79, -263.12, 46.26), true)
    if centerRing < Config.Loser and fightStatus ~= STATUS_STARTED then
        
        DrawMarker(27, Config.Inzet.x, Config.Inzet.y, Config.Inzet.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 80, 0, 255, false, true, 2, true, false, false, false)
        DrawText3D(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z +1.5, 'Spelers: ~o~' .. players .. '/2 \n ~w~Weddenschap: ~o~'.. betAmount ..'$ ', 0.8)

        local blueZone = GetDistanceBetweenCoords(coords, vector3(Config.BlouwRing.x, Config.BlouwRing.y, Config.BlouwRing.z), true)
        local redZone = GetDistanceBetweenCoords(coords, vector3(Config.RodeRing.x, Config.RodeRing.y, Config.RodeRing.z), true)
        local betZone = GetDistanceBetweenCoords(coords, vector3(Config.Inzet.x, Config.Inzet.y, Config.Inzet.z), true)

        if blueJoined == false then
            DrawText3D(Config.BlouwRing.x, Config.BlouwRing.y, Config.BlouwRing.z +1.5, 'Deelnemen aan de strijd ~o~[E]~w~', 0.4)
            if blueZone < Config.Afstand then
                ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om naar de ~b~Blauwe~w~ kant te Gaan...")
                if IsControlJustReleased(0, Config.Key) and participando == false then
                    TriggerServerEvent('Snowyy-Boxring:join', betAmount, 0 )
                end
            end
        end

        if redJoined == false then
            DrawText3D(Config.RodeRing.x, Config.RodeRing.y, Config.RodeRing.z +1.5, 'Deelnemen aan de strijd ~o~[E]~w~', 0.4)
            if redZone < Config.Afstand then
                ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om naar de ~r~Rode~w~ kant te Gaan...")
                if IsControlJustReleased(0, Config.Key) and participando == false then
                    TriggerServerEvent('Snowyy-Boxring:join', betAmount, 1)
                end
            end
        end

        if betZone < Config.Afstand and fightStatus ~= STATUS_JOINED and fightStatus ~= STATUS_STARTED then
            ESX.ShowHelpNotification("Druk op ~INPUT_CONTEXT~ om de ~o~inzet~w~ te veranderen.")
            if IsControlJustReleased(0, Config.Key) then
                TriggerServerEvent('Snowyy-Boxring:raiseBet', betAmount)
            end
        end

    end
end

function get3DDistance(x1, y1, z1, x2, y2, z2)
    local a = (x1 - x2) * (x1 - x2)
    local b = (y1 - y2) * (y1 - y2)
    local c = (z1 - z2) * (z1 - z2)
    return math.sqrt(a + b + c)
end

function DrawText3D(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function CreateBlip(coords, text, sprite, color, scale)
	local blip = AddBlipForCoord(coords.x, coords.y)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
end

function reset() 
    redJoined = false
    blueJoined = false
    participando = false
    players = 0
    fightStatus = STATUS_INITIAL
end

function RunThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local coords = GetEntityCoords(PlayerPedId())
            spawnMarker(coords)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        if fightStatus == STATUS_STARTED and participando == false and GetEntityCoords(PlayerPedId()) ~= rival then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z,coords.x,coords.y,coords.z) < Config.TeleAfstand then
                ESX.ShowNotification('Ga weg van de ring!')
                for height = 1, 1000 do
                    SetPedCoordsKeepVehicle(GetPlayerPed(-1), 259.79, -263.12, 46.26)
                    local foundGround, zPos = GetGroundZFor_3dCoord(259.79, -263.12, 46.26)
                    if foundGround then
                        SetPedCoordsKeepVehicle(GetPlayerPed(id), 259.79, -263.12, 46.26)
                        break
                    end
                    Citizen.Wait(5)
                end
            end
        end
        Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showCountDown == true then
            DrawText3D(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z + 1.5, 'Het gevecht begint in: ' .. actualCount, 2.0)
        elseif showCountDown == false and fightStatus == STATUS_STARTED then
            if GetEntityHealth(PlayerPedId()) < 150 then
                TriggerServerEvent('Snowyy-Boxring:finishFight', GetPlayerServerId(PlayerId()))
                -- TriggerServerEvent('Snowyy-Boxring:finishFight', 20)
                fightStatus = STATUS_INITIAL
            end
        end
       
        if participando == true then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z,coords.x,coords.y,coords.z) > Config.VechtenAfstand then
                TriggerServerEvent('Snowyy-Boxring:leaveFight', GetPlayerServerId(PlayerId()))
            end
        end

        if showWinner == true and winner ~= nil then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z,coords.x,coords.y,coords.z) < 15 then
                DrawText3D(Config.MiddenRing.x, Config.MiddenRing.y, Config.MiddenRing.z + 2.5, '~r~ID: ' .. winner .. ' winnen!', 2.0)
            end
        end
    end
end)