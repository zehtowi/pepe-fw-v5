Framework = nil

TriggerEvent('Framework:GetObject', function(obj) Framework = obj end)

Framework.Functions.CreateCallback('pepe-storerobbery:server:get:config', function(source, cb)
    cb(Config)
end)

Framework.Commands.Add("resetsafes", "Reset store safes", {}, false, function(source, args)
    for k, v in pairs(Config.Safes) do
        Config.Safes[k]['Busy'] = false
        TriggerClientEvent('pepe-storerobbery:client:safe:busy', -1, k, false)
    end
end, "user")

Framework.Functions.CreateCallback('pepe-storerobbery:server:HasItem', function(source, cb, itemName)
    local Player = Framework.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName(itemName)
	if Player ~= nil then
        if Item ~= nil then
			cb(true)
        else
			cb(false)
        end
	end
end)

Citizen.CreateThread(function()
    while true do
        for k, v in pairs(Config.Registers) do
            if Config.Registers[k]['Time'] > 0 and (Config.Registers[k]['Time'] - Config.Inverval) >= 0 then
                Config.Registers[k]['Time'] = Config.Registers[k]['Time'] - Config.Inverval
            else
                Config.Registers[k]['Time'] = 0
                Config.Registers[k]['Robbed'] = false
                TriggerClientEvent('pepe-storerobbery:client:set:register:robbed', -1, k, false)
            end
        end
        Citizen.Wait(Config.Inverval)
    end
end)

RegisterServerEvent('pepe-storerobbery:server:set:register:robbed')
AddEventHandler('pepe-storerobbery:server:set:register:robbed', function(RegisterId, bool)
    Config.Registers[RegisterId]['Robbed'] = bool
    Config.Registers[RegisterId]['Time'] = Config.ResetTime
    TriggerClientEvent('pepe-storerobbery:client:set:register:robbed', -1, RegisterId, bool)
end)

RegisterServerEvent('pepe-storerobbery:server:set:register:busy')
AddEventHandler('pepe-storerobbery:server:set:register:busy', function(RegisterId, bool)
    Config.Registers[RegisterId]['Busy'] = bool
    TriggerClientEvent('pepe-storerobbery:client:set:register:busy', -1, RegisterId, bool)
end)

RegisterServerEvent('pepe-storerobbery:server:safe:busy')
AddEventHandler('pepe-storerobbery:server:safe:busy', function(SafeId, bool)
    Config.Safes[SafeId]['Busy'] = bool
    TriggerClientEvent('pepe-storerobbery:client:safe:busy', -1, SafeId, bool)
end)

RegisterServerEvent('pepe-storerobbery:server:safe:robbed')
AddEventHandler('pepe-storerobbery:server:safe:robbed', function(SafeId, bool)
    Config.Safes[SafeId]['Robbed'] = bool
    TriggerClientEvent('pepe-storerobbery:client:safe:robbed', -1, SafeId, bool)
    SetTimeout((1000 * 60) * 25, function()
        TriggerClientEvent('pepe-storerobbery:client:safe:robbed', -1, SafeId, false)
        Config.Safes[SafeId]['Robbed'] = false
    end)
end)

RegisterServerEvent('pepe-storerobbery:server:rob:register')
AddEventHandler('pepe-storerobbery:server:rob:register', function(RegisterId, IsDone)
    local Player = Framework.Functions.GetPlayer(source)
    Player.Functions.AddMoney('cash', math.random(900, 3120), "Store Robbery")
    if IsDone then
        local RandomItem = Config.SpecialItems[math.random(#Config.SpecialItems)]
        local RandomValue = math.random(1, 100)
        if RandomValue <= 16 then
            Player.Functions.AddItem(RandomItem, 1)
            TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items[RandomItem], "add")
        end
        Player.Functions.AddItem('money-roll', math.random(25, 150))
        TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items['money-roll'], "add")
    end
end)

RegisterServerEvent('pepe-storerobbery:server:safe:reward')
AddEventHandler('pepe-storerobbery:server:safe:reward', function()
    local Player = Framework.Functions.GetPlayer(source)
    local RandomItem = Config.SpecialItems[math.random(#Config.SpecialItems)]
    Player.Functions.AddMoney('cash', math.random(1000, 3000), "Safe Robbery")
    Player.Functions.AddItem('money-roll', math.random(40, 95))
    TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items['money-roll'], "add")
    local RandomValue = math.random(1,100)
    if RandomValue <= 25 then
        Player.Functions.AddItem("gold-rolex", math.random(2,4))
        TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items["gold-rolex"], "add") 
    elseif RandomValue >= 35 and RandomValue <= 55 then
        Player.Functions.AddItem(RandomItem, 1)
        TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items[RandomItem], "add")
    elseif RandomValue >= 65 and RandomValue <= 75 then
        Player.Functions.AddItem("gold-bar", math.random(1,2))
        TriggerClientEvent('pepe-inventory:client:ItemBox', source, Framework.Shared.Items["gold-bar"], "add") 
    end
end)