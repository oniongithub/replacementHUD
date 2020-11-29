local localPlayer = entity.get_local_player();
local playerResource = entity.get_player_resource();
local scrW, scrH = client.screen_size();
-- window's usage is {name, x position, y position, width, height, if the window width is changable}
local windows = { {"watermark", 1660, 10, 250, 20, false }, {"keybinds", 10, 700, 200, 20, true}};
local hold = { false, 0, 0, "", 0, 0, 0, 0, true };
ui.new_label("LUA", "B", "\n\n")
ui.new_label("LUA", "B", "---- Onion's LUA ----")
ui.new_label("LUA", "B", "Header Color: ")
local colors = { ui.new_color_picker("LUA", "B", "Header", 200, 103, 245, 255) };
local controls = { ui.new_checkbox("LUA", "B", "Enabled", true), ui.new_checkbox("LUA", "B", "Override HUD", true), ui.new_multiselect("LUA", "B", "HUD Features", "Watermark", "Keybinds", "Chatbox", "Weapons", "Health", "Spectator's List") }
local keybindReferences = { {"Fake-Duck", false, ui.reference("rage", "other", "duck peek assist")}, {"Double-Tap", true, ui.reference("rage", "other", "double tap")}, {"Hideshots", true, ui.reference("aa", "other", "on shot anti-aim")}, {"LBY Flick", true, ui.reference("aa", "other", "fake peek")}, {"Slowwalk", true, ui.reference("aa", "other", "slow motion")}, {"Force Safe-Point", false, ui.reference("rage", "aimbot", "force safe point")}, {"Force Body-Aim", false, ui.reference("rage", "other", "force body aim")}, {"Blockbot", true, ui.reference("misc", "movement", "blockbot")}, {"Edge-Jump", true, ui.reference("misc", "movement", "jump at edge")}, {"Freecam", false, ui.reference("misc", "miscellaneous", "free look")} }
local locationControls = {};
local locationControlsVisible = true;
for i = 1, #windows do
    if (not windows[i][6]) then
        table.insert(locationControls, {ui.new_label("LUA", "B", "---- " .. windows[i][1] .. " ----"), ui.new_slider("LUA", "B", windows[i][1] .. " X Axis", 0, scrW, windows[i][2]), ui.new_slider("LUA", "B", windows[i][1] .. " Y Axis", 0, scrH, windows[i][3])})
    else
        table.insert(locationControls, {ui.new_label("LUA", "B", "---- " .. windows[i][1] .. " ----"), ui.new_slider("LUA", "B", windows[i][1] .. " X Axis", 0, scrW, windows[i][2]), ui.new_slider("LUA", "B", windows[i][1] .. " Y Axis", 0, scrH, windows[i][3]), ui.new_slider("LUA", "B", windows[i][1] .. " Width", 0, scrW, windows[i][4])})
    end
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

client.set_event_callback("paint", function()
    localPlayer = entity.get_local_player();
    if (localPlayer == nil) then return end

    -- Update Position Settings
    updateSettings(hold[9])
    
    if (ui.get(controls[1])) then
        local enabledTable = ui.get(controls[3]);

        -- HUD Movement
        runWindowMovement();

        -- HUD Functions
        if (tableContains(enabledTable, "Watermark")) then drawWatermark(); end
        if (tableContains(enabledTable, "Keybinds")) then drawKeybinds(); end
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

    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], windows[index][5], 20, 20, 20, 150)
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

    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 20, 20, 20, 20, 150)
    renderer.rectangle(windows[index][2], windows[index][3], windows[index][4], 2, ui.get(colors[1]))
    renderer.text(windows[index][2] + (windows[index][4] / 2), windows[index][3] + 11, 255, 255, 255, 255, "c", 0, "Keybinds")

    local usedHeight = 25;
    if (#heldKeybinds > 0) then
        for i = 1, #heldKeybinds do
            renderer.rectangle(windows[index][2], windows[index][3] + usedHeight, windows[index][4], 18, 20, 20, 20, 150)
            renderer.rectangle(windows[index][2], windows[index][3] + usedHeight, 2, 18, ui.get(colors[1]))
            local w, h = renderer.measure_text("", heldKeybinds[i][1])
            renderer.text(windows[index][2] + 7, windows[index][3] + usedHeight + 9 - (h / 2), 255, 255, 255, 255, "", 0, heldKeybinds[i][1])
            usedHeight = usedHeight + 18
        end
    end
end
