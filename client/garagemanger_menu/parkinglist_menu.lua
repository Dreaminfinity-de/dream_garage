function addParkinglist(mainMenu)
    
    menu = menuPool:AddSubMenu(mainMenu, _U('garage_parkinglist_titel'))



    ESX.TriggerServerCallback('dream_garage:getOwnedVehicles', function(vehicles)
        
        items = {}
        

        for i, v in ipairs(vehicles) do

            item = NativeUI.CreateItem(_U('garage_parkinglist_item', v.plate), _U('garage_parkinglist_item_desc'))
            if v.vehicle_name ~= nil then
                item:RightLabel(v.vehicle_name)
            end


            if v.garage_name ~= nil then
                if items[v.garage_name] == nil then
                    items[v.garage_name] = {}
                end
                table.insert( items[v.garage_name], { item = item, data = v } )
            else
                if items['none'] == nil then
                    items['none'] = {}
                end
                table.insert( items['none'], { item = item, data = v } )
            end
    
            item.Activated = onParkinglistItemClick
        end

        for _, sort in ipairs(Config.GarageParkinglistSort) do
            if sort == 'config_garages' then
                for i, v in ipairs(Config.Garages) do
                    if items[v.id] ~= nil then
                        submenu = menuPool:AddSubMenu(menu, v.name)
                        for k, v in pairs(items[v.id]) do
                            submenu:AddItem(v.item)
                        end
        
                        items[v.id] = nil
                    end
                end
            elseif sort == 'unknown_garages' then
                for k, v in pairs(items) do
                    if #v > 0 and v[1].data.garage_name ~= nil then
                        submenu = menuPool:AddSubMenu(menu, _U('garage_parkinglist_item_unknown-garage', v[1].data.garage_name))
                        for i2, v2 in ipairs(v) do
                            submenu:AddItem(v2.item)
                        end
                    end
                end
            elseif sort == 'out_of_garages' then
                if items['none'] ~= nil then
                    submenu = menuPool:AddSubMenu(menu, _U('garage_parkinglist_item_out-of-garage'))
                    for k, v in pairs(items['none']) do
                        submenu:AddItem(v.item)
                    end
                end
            end
        end

        

        
    end)

    return menu
end


function onParkinglistItemClick(sender, index)
    --result = 'Geändert - Bugmode'
    --index:RightLabel(result)
end