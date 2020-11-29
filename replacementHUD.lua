local localPlayer = entity.get_local_player();
local playerResource = entity.get_player_resource();
local scrW, scrH = client.screen_size();
local csgo_weapons = require "gamesense/csgo_weapons"
local images = require "gamesense/images"
local js = panorama.open()
local GameStateAPI = js.GameStateAPI
local chatMSG = {};
local avatars = {};
-- window's usage is {name, x position, y position, width, height, if the window width is changable}
local windows = { {"watermark", 1660, 10, 250, 20, false }, {"keybinds", 10, 500, 200, 20, true}, {"chatbox", 25, 750, 350, 20, true}};
local hold = { false, 0, 0, "", 0, 0, 0, 0, true };
ui.new_label("LUA", "B", "\n\n")
ui.new_label("LUA", "B", "---- Onion's LUA ----")
ui.new_label("LUA", "B", "Header Color: ")
local colors = { ui.new_color_picker("LUA", "B", "Header", 200, 103, 245, 255) };
local keyTable = { {0x20, " "}, {0x30, "0"}, {0x31, "1"}, {0x32, "2"}, {0x33, "3"}, {0x34, "4"}, {0x35, "5"}, {0x36, "6"}, {0x37, "7"}, {0x38, "8"}, {0x39, "9"}, {0x41, "A"}, {0x42, "B"}, {0x43, "C"}, {0x44, "D"}, {0x45, "E"}, {0x46, "F"}, {0x47, "G"}, {0x48, "H"}, {0x49, "I"}, {0x4A, "J"}, {0x4B, "K"}, {0x4C, "L"}, {0x4D, "M"}, {0x4E, "N"}, {0x4F, "O"}, {0x50, "P"}, {0x51, "Q"}, {0x52, "R"}, {0x53, "S"}, {0x54, "T"}, {0x55, "U"}, {0x56, "V"}, {0x57, "W"}, {0x58, "X"}, {0x59, "Y"}, {0x5A, "Z"} };
local controls = { ui.new_checkbox("LUA", "B", "Enabled", true), ui.new_checkbox("LUA", "B", "Override HUD", true), ui.new_hotkey("LUA", "B", "Global Chat Key", false, 0x59), ui.new_hotkey("LUA", "B", "Team Chat Key", false, 0x55), ui.new_hotkey("LUA", "B", "Stop Chatting Key", false, 0x12), ui.new_multiselect("LUA", "B", "HUD Features", "Watermark", "Keybinds", "Chatbox", "Weapons", "Health", "Spectator's List") }
local keybindReferences = { {"Fake-Duck", false, ui.reference("rage", "other", "duck peek assist")}, {"Thirdperson", true, ui.reference("visuals", "effects", "force third person (alive)")}, {"Double-Tap", true, ui.reference("rage", "other", "double tap")}, {"Hideshots", true, ui.reference("aa", "other", "on shot anti-aim")}, {"LBY Flick", true, ui.reference("aa", "other", "fake peek")}, {"Slowwalk", true, ui.reference("aa", "other", "slow motion")}, {"Force Safe-Point", false, ui.reference("rage", "aimbot", "force safe point")}, {"Force Body-Aim", false, ui.reference("rage", "other", "force body aim")}, {"Blockbot", true, ui.reference("misc", "movement", "blockbot")}, {"Edge-Jump", true, ui.reference("misc", "movement", "jump at edge")}, {"Freecam", false, ui.reference("misc", "miscellaneous", "free look")} }
local locationControls = {};
local locationControlsVisible = true;
for i = 1, #windows do
    if (not windows[i][6]) then
        table.insert(locationControls, {ui.new_label("LUA", "B", "---- " .. windows[i][1] .. " ----"), ui.new_slider("LUA", "B", windows[i][1] .. " X Axis", 0, scrW, windows[i][2]), ui.new_slider("LUA", "B", windows[i][1] .. " Y Axis", 0, scrH, windows[i][3])})
    else
        table.insert(locationControls, {ui.new_label("LUA", "B", "---- " .. windows[i][1] .. " ----"), ui.new_slider("LUA", "B", windows[i][1] .. " X Axis", 0, scrW, windows[i][2]), ui.new_slider("LUA", "B", windows[i][1] .. " Y Axis", 0, scrH, windows[i][3]), ui.new_slider("LUA", "B", windows[i][1] .. " Width", 0, scrW, windows[i][4])})
    end
end
local typeHandler = {false, {}, "", false};

function findKey(key, inverse)
    for i = 1, #keyTable do
        if (inverse) then
            if (keyTable[2] == key) then
                return keyTable[1];
            end
        else
            if (keyTable[1] == key) then
                return keyTable[2];
            end
        end
    end

    return 0;
end

function swapPostionEdits()
    for i = 1, #locationControls do
        ui.set_visible(locationControls[i][1], not locationControlsVisible);
        ui.set_visible(locationControls[i][2], not locationControlsVisible);
        ui.set_visible(locationControls[i][3], not locationControlsVisible);

        if (#locationControls[i] > 3) then
            ui.set_visible(locationControls[i][4], not locationControlsVisible);
        end
    end

    locationControlsVisible = not locationControlsVisible;
end

function updateSettings(saving)
    for i = 1, #windows do
        if (not saving) then
            windows[i][2], windows[i][3] = ui.get(locationControls[i][2]), ui.get(locationControls[i][3]);

            if (windows[i][6]) then
                windows[i][4] = ui.get(locationControls[i][4])
            end
        else
            if (windows[i][2] ~= nil and windows[i][3] ~= nil) then
                ui.set(locationControls[i][2], windows[i][2])
                ui.set(locationControls[i][3], windows[i][3])
            end
        end
    end
end

ui.new_button("LUA", "B", "Toggle Position Settings", swapPostionEdits);
swapPostionEdits();

function handleText()
    if (ui.get(controls[2]) and ui.get(controls[1])) then
        if (ui.get(controls[4]) and not typeHandler[1]) then
            table.insert(typeHandler[2], 0x55);
            typeHandler[1], typeHandler[4] = true, false;
        end

        if (ui.get(controls[3]) and not typeHandler[1]) then
            table.insert(typeHandler[2], 0x59);
            typeHandler[1], typeHandler[4] = true, true;
        end

        if (not tableContains(typeHandler[2], 0x08)) then
            if (client.key_state(0x08)) then
                table.insert(typeHandler[2], 0x08);
                if (typeHandler[3] ~= nil and typeHandler[3] ~= "") then
                    typeHandler[3] = typeHandler[3]:sub(1, -2)
                end
            end
        end

        if (not ui.get(controls[5])) then
            if (typeHandler[1]) then
                for i = 1, #typeHandler[2] do
                    if (typeHandler[2][i] ~= nil) then
                        if (not client.key_state(typeHandler[2][i])) then
                            table.remove(typeHandler[2], i);
                        end
                    end
                end

                for i = 1, #keyTable do
                    if (client.key_state(keyTable[i][1])) then
                        if (not tableContains(typeHandler[2], keyTable[i][1])) then
                            if (client.key_state(0xA0)) then
                                typeHandler[3] = typeHandler[3] .. keyTable[i][2]
                            else
                                typeHandler[3] = typeHandler[3] .. string.lower(keyTable[i][2]);
                            end

                            table.insert(typeHandler[2], keyTable[i][1])
                        end
                    end
                end
            end
        else
            typeHandler[1], typeHandler[2], typeHandler[3], typeHandler[4] = false, {}, "", false;
        end
    else
        typeHandler[1], typeHandler[2], typeHandler[3], typeHandler[4] = false, {}, "", false;
    end
end

client.set_event_callback("paint", function()
    localPlayer = entity.get_local_player();
    if (localPlayer == nil) then return end

    -- Handle some shit idk
    updateSettings(hold[9])
    handleUI();

    if (ui.get(controls[1])) then
        local enabledTable = ui.get(controls[6]);

        -- HUD Movement
        runWindowMovement();

        -- HUD Functions
        if (tableContains(enabledTable, "Watermark")) then drawWatermark(); end
        if (tableContains(enabledTable, "Keybinds")) then drawKeybinds(); end
        if (tableContains(enabledTable, "Chatbox")) then drawChatbox(); handleText(); end
    end
end)

function findWindow(name)
    if (name == nil) then return end

    for i = 1, #windows do
        if (windows[i][1] == name) then
            return i;
        end
    end

    return 0;
end

function tableContains(table, string)
    if (string == nil) then return end

    for i = 1, #table do
        if (table[i] == string) then
            return true;
        end
    end

    return false;
end

function runWindowMovement()
    if (client.key_state(0x01)) then
        hold[2], hold[3] = ui.mouse_position();

        if (not hold[1]) then
            hold[1] = true;
            for i = 1, #windows do
                local name, x, y, w, h = windows[i][1], windows[i][2], windows[i][3], windows[i][4], windows[i][5];
                if (not hold[9]) then
                    if (hold[2] >= x and hold[2] <= x + w and hold[3] >= y and hold[3] <= y + h) then
                        hold[4], hold[9], hold[5], hold[6], hold[7], hold[8] = name, true, hold[2], hold[3], hold[2] - x, hold[3] - y;
                    end
                end
            end
        else
            if (hold[4] == "") then return end            
            local index = findWindow(hold[4])

            if (hold[2] - hold[7] >= 0 and hold[2] - hold[7] <= scrW) then
                windows[index][2] = hold[2] - hold[7];
            end

            if (hold[3] - hold[8] >= 0 and hold[3] - hold[8] <= scrH) then
                windows[index][3] = hold[3] - hold[8];
            end
        end
    else
        hold[1], hold[4], hold[5], hold[6], hold[7], hold[8], hold[9] = false, "", 0, 0, 0, 0, false;
    end
end

function handleUI()
    if (ui.get(controls[2]) and ui.get(controls[1])) then
        cvar.cl_draw_only_deathnotices:set_int(1)
        cvar.cl_drawhud_force_radar:set_int(1)
        client.exec("unbind y")
        client.exec("unbind u")
    else
        cvar.cl_draw_only_deathnotices:set_int(0)
        cvar.cl_drawhud_force_radar:set_int(0)
        client.exec("bind y messagemode")
        client.exec("bind u messagemode2")
    end
end

function handleBinds()
    if (ui.get(controls[2]) and ui.get(controls[1])) then

    else

    end
end

function drawChatbox()
    local index = findWindow("chatbox");
    if (index == nil) then return end

    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 2, ui.get(colors[1]));
    renderer.rectangle(windows[index][2], 2 + windows[index][3], windows[index][4], 16, 20, 20, 20, 100);
    renderer.text((windows[index][4] / 2) + windows[index][2], 10 + windows[index][3], 255, 255, 255, 255, "c", 0, "Chatbox")
    local height = 25;

    if (#chatMSG ~= nil) then
        height = height + (#chatMSG * 22);

        if (#chatMSG > 0) then
            for i = 1, #chatMSG do
                renderer.rectangle(windows[index][2], 22 + (20 * (i - 1)) + windows[index][3], 2, 16, ui.get(colors[1]))
                renderer.rectangle(2 + windows[index][2], 22 + (20 * (i - 1)) + windows[index][3], windows[index][4] / 4, 16, 20, 20, 20, 100)
                renderer.rectangle(windows[index][4] / 4 + 5 + windows[index][2], 22 + (20 * (i - 1)) + windows[index][3], (windows[index][4] / 4) * 3 - 5, 16, 20, 20, 20, 100)
                renderer.text(((windows[index][4] / 4 + 5 + windows[index][2]) + (((windows[index][4] / 4) * 3 - 5) / 2)), (22 + (20 * (i - 1))) + 8 + windows[index][3], 255, 255, 255, 255, "c", (windows[index][4] / 4) * 3 - 15, chatMSG[i][2])
                local avatarIndex;

                for f = 1, #avatars do
                    if (avatars[f][1] == chatMSG[i][3]) then
                        avatarIndex = f;
                    end
                end

                if (avatarIndex == nil) then
                    if (chatMSG[i][3] ~= "" and chatMSG[i][3] ~= nil) then
                        table.insert(avatars, {chatMSG[i][3], images.get_steam_avatar(chatMSG[i][3])});
                        avatarIndex = #chatMSG;
                    end
                end

                if (chatMSG[i][4] == 2) then -- T Side
                    renderer.text(windows[index][2] + ((windows[index][4] / 4) / 2), (22 + (20 * (i - 1))) + 8 + windows[index][3], 255, 114, 43, 255, "c", 71, chatMSG[i][1])
                elseif (chatMSG[i][4] == 3) then -- CT Side
                    renderer.text(windows[index][2] + ((windows[index][4] / 4) / 2), (22 + (20 * (i - 1))) + 8 + windows[index][3], 43, 223, 255, 255, "c", 71, chatMSG[i][1])
                else -- Spectators
                    renderer.text(windows[index][2] + ((windows[index][4] / 4) / 2), (22 + (20 * (i - 1))) + 8 + windows[index][3], 200, 200, 200, 255, "c", 71, chatMSG[i][1])
                end

                if (avatars[avatarIndex][2] ~= nil) then
                    avatars[avatarIndex][2]:draw(windows[index][2] - 20, 22 + (20 * (i - 1)) + windows[index][3], 16, 16, 255, 255, 255, 255, false, 'f')
                end
            end
        end
    end

    if (typeHandler[1]) then
        renderer.rectangle(windows[index][2], windows[index][3] + height + 5, 2, 16, ui.get(colors[1]))
        renderer.rectangle(2 + windows[index][2], windows[index][3] + height + 5, windows[index][4] / 4, 16, 20, 20, 20, 100)
        renderer.rectangle(windows[index][4] / 4 + 5 + windows[index][2], windows[index][3] + height + 5, (windows[index][4] / 4) * 3 - 5, 16, 20, 20, 20, 100)

        if (typeHandler[4]) then
            renderer.text(2 + windows[index][2] + ((windows[index][4] / 4) / 2), windows[index][3] + height + 14, 255, 255, 255, 255, "c", 0, "Global")
        else
            renderer.text(2 + windows[index][2] + ((windows[index][4] / 4) / 2), windows[index][3] + height + 14, 255, 255, 255, 255, "c", 0, "Team")
        end

        if (client.key_state(0x0D)) then
            if (typeHandler[3] ~= "" and typeHandler[3] ~= nil) then
                if (typeHandler[4]) then
                    client.exec("say " .. typeHandler[3]);
                else
                    client.exec("say_team " .. typeHandler[3]);
                end
            end

            typeHandler[1], typeHandler[2], typeHandler[3], typeHandler[4] = false, {}, "", false;
        end

        if (typeHandler[3] ~= "" and typeHandler[3] ~= nil) then
            local textW, textH = renderer.measure_text("", typeHandler[3]);
            renderer.text(7 + windows[index][2] + (windows[index][4] / 4) + (((windows[index][4] / 4) * 3) / 2), windows[index][3] + height + 14, 255, 255, 255, 255, "c", ((windows[index][4] / 4) * 3) - 10, typeHandler[3])
        end
    end

    windows[index][5] = height;
end

function drawWatermark()
    local index = findWindow("watermark");
    if (index == nil) then return end

    local watermarkFlags = { {"", entity.get_player_name(localPlayer)}, {"hp", 0}, {"armor", 0}, {"ms", client.latency()} };

    local healthProp = entity.get_prop(localPlayer, "m_iHealth");
    if (healthProp ~= nil) then
        watermarkFlags[2][2] = healthProp;
    end

    local armorProp = entity.get_prop(localPlayer, "m_iArmor");
    if (armorProp ~= nil) then
        watermarkFlags[3][2] = armorProp;
    end

    local text = "gamesense";

    for i = 1, #watermarkFlags do
        if (watermarkFlags[i][2]) then
            text = text .. " | " .. watermarkFlags[i][1] .. " " .. watermarkFlags[i][2]
        end
    end

    local w, h = renderer.measure_text(nil, text)
    windows[index][4] = w + 12;

    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], windows[index][5], 20, 20, 20, 100)
    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 2, ui.get(colors[1]))
    renderer.text(windows[index][2] + (windows[index][4] / 2), windows[index][3] + 1 + ((windows[index][5] - 2) / 2), 255, 255, 255, 255, "c", 0, text)
end

function drawKeybinds()
    local heldKeybinds = {};
    for i = 1, #keybindReferences do
        if (not keybindReferences[i][2]) then
            if (ui.get(keybindReferences[i][3])) then
                table.insert(heldKeybinds, keybindReferences[i]);
            end
        else
            if (ui.get(keybindReferences[i][4]) and ui.get(keybindReferences[i][3])) then
                table.insert(heldKeybinds, keybindReferences[i]);
            end
        end
    end

    local index = findWindow("keybinds");
    windows[index][5] = 25 + (#heldKeybinds * 18);

    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 20, 20, 20, 20, 100)
    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 2, ui.get(colors[1]))
    renderer.text(windows[index][2] + (windows[index][4] / 2), windows[index][3] + 11, 255, 255, 255, 255, "c", 0, "Keybinds")

    local usedHeight = 25;
    if (#heldKeybinds > 0) then
        for i = 1, #heldKeybinds do
            renderer.rectangle(windows[index][2], windows[index][3] + usedHeight, windows[index][4], 18, 20, 20, 20, 100)
            renderer.rectangle(windows[index][2], windows[index][3] + usedHeight, 2, 18, ui.get(colors[1]))
            local w, h = renderer.measure_text("", heldKeybinds[i][1])
            renderer.text(windows[index][2] + 7, windows[index][3] + usedHeight + 9 - (h / 2), 255, 255, 255, 255, "", 0, heldKeybinds[i][1])
            usedHeight = usedHeight + 18
        end
    end
end

client.set_event_callback("player_chat", function(e)
    if e.entity == nil then return end
    local steamid = entity.get_steam64(e.entity);
    local teamNum = entity.get_prop(playerResource, "m_iTeam", e.entity);
    if (e.name == nil or e.text == nil or e.name == "" or e.text == "" or teamNum == nil) then return end
    if (steamid == "" or steamid == nil) then
        steamid = ""
    end

    if (#chatMSG < 6) then
        table.insert(chatMSG, {e.name, e.text, steamid, teamNum})
    else
        table.remove(chatMSG, 1);
        table.insert(chatMSG, {e.name, e.text, steamid, teamNum})
    end
end)
