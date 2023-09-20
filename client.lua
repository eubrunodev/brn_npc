local cfg = module(GetCurrentResourceName(), "config")

local isNearPed = false
local isAtPed = false
local isPedLoaded = false
local npc
local spawnedNPCs = {}  -- Armazena os NPCs que foram criados


Citizen.CreateThread(function()
    while true do

        for _,v in pairs(cfg.locais) do
            local x,y,z = table.unpack(v)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            local distance = Vdist(playerCoords, v.x,v.y,v.z)
            
            isNearPed = false
            isAtPed = false

            if distance < 20.0 and not spawnedNPCs[v] then 
                isNearPed = true
                if not isPedLoaded then 
                    RequestModel(v.pedModel)
                    while not HasModelLoaded(v.pedModel) do
                        Citizen.Wait(1)
                    end
                    npcType = v.type
                    npc = CreatePed(4, v.pedModel, v.x,v.y,v.z - 1.0, v.rot, false, false)
                    FreezeEntityPosition(npc, true)
                    SetEntityHeading(npc, v.rot)
                    SetEntityInvincible(npc, true)
                    SetBlockingOfNonTemporaryEvents(npc, true)
                    spawnedNPCs[v] = npc
                end
            end

            if isPedLoaded and not isNearPed then 
            
                DeleteEntity(npc)
                SetModelAsNoLongerNeeded(v.pedModel)
                isPedLoaded = false
                
            end
            if distance < 2.0 then 
                isAtPed = true
            end
            
            Citizen.Wait(500)
        end
        
        Citizen.Wait(500)
    end

end)


Citizen.CreateThread(function() 
    while true do
        if isAtPed then 
            showNotification(cfg.infoBarMessage)
        end
        Citizen.Wait(500)
    end
end)

function showNotification (text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, true)
    
end

function notify(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 5, -1)
end