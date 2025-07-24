local FastPull, FastKick, FastBan, FastTrash, FastDrop = false, false, false,false, false -- /fp /fk /fb /fw /fd /ft.

-- ░ DIALOG : menu utama ░ --------------------------------------------
local dialog = [[
set_bg_color|10,10,10,225
set_border_color|255,255,255,180
set_default_color|`0
add_label_with_icon|big|`4Welcome To R.A.P.S Proxy|left|1784|
add_smalltext|`4Author By: `3MojoWasTaken.
add_spacer|big|
add_button|proxy_menu|`2Proxy Menu||
add_spacer|small|
add_button|feature|`2FEATURE||
add_spacer|small|
add_url_button||Join Discord|NOFLAGS|https://discord.gg/krQdRWEP9G|Wanna Join My Discord Server?|0|0|
end_dialog|lusi|Close Proxy|
]]
sendVariant({
    [0]= "OnDialogRequest", 
    [1]= dialog
    
}, -1)

-- ░ DIALOG : feature ░ -------------------------------------------------
local function openFeature()
    local menu = [[
set_bg_color|10,10,10, 255
set_border_color|255, 255, 255, 180
set_default_color|`0
add_label_with_icon|big|`4Feature Setting|left|32|
add_spacer|big|
add_label_with_icon|small|`4Magic Feature|left|10540|
add_textbox|`6/fp [`1This Command For Fast Pull.]|
add_spacer|small|
add_textbox|`6/fk [`1This Command For Fast Kick.]|
add_spacer|small|
add_textbox|`6/fb [`1This Command For Fast Ban.]|
add_spacer|small|
add_textbox|`6/cn [`1This Command For Visual Name.]|
add_textbox|Note: `1 Feature fast kick, fast pull, fast ban Not Working If You Enable All Command So, Just which one Command! And If You Want To Disable feature Just Write again Command. example: `2/fp To Enabled Feature, `4/fp To Disable Feature.|
add_button|back_main|`4Back||
end_dialog|feature_dialog|Close||
]]
    sendVariant({
        [0]= "OnDialogRequest", 
        [1]= menu
        
    }, -1)
end

-- ░ UTIL ░ ------------------------------------------------------------
local function overlay(txt)
    sendVariant({
        [0]="OnTextOverlay",
        [1]=txt
    }, -1)
end

-- ░ HOOK 1 : command input & dialog navigasi ░ ------------------------
AddHook("OnTextPacket","raps_cmd",function(_,pkt)
    if pkt:find("buttonClicked|feature") then openFeature(); return true end
    if pkt:find("buttonClicked|back_main") then 
        sendVariant({
            [0] ="OnDialogRequest", 
            [1] = menu
            
        }, -1)
        return true
    end

    local cmd = pkt:match("action|input\n|text|/(f[pkb])")
    if cmd then
        if cmd == "fp" then
            FastPull = not FastPull
            overlay(FastPull and "`2Fast Pull Enabled" or "`4Fast Pull Disabled")
        elseif cmd == "fk" then
            FastKick = not FastKick
            overlay(FastKick and "`2Fast Kick Enabled" or "`4Fast Kick Disabled")
        elseif cmd == "fb" then
            FastBan = not FastBan
            overlay(FastBan and "`2Fast Ban Enabled" or "`4Fast Ban Disabled")
        end
        return true
    end
    
end)

-- ░ HOOK 2 : intercept pop-up wrench ░ --------------------------------
AddHook("OnVarlist","raps_fastaction",function(var)
    if var[0] ~= "OnDialogRequest" then return false end
    if not var[1]:find("add_popup_name|WrenchMenu") then return false end
    if not (FastPull or FastKick or FastBan) then return false end

    local id = tonumber(var[1]:match("embed_data|netID|(%d+)"))
    if not id or id == 0 then return false end

    local button = FastPull and "pull" or FastKick and "kick" or FastBan and "worldban"
    if button then
        sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..id.."|\nnetID|"..id.."|\nbuttonClicked|"..button)
        return true
    end
end)

-- ░ HOOK 3 : buka menu lewat /proxy ░ --------------------------------
AddHook("OnTextPacket", "lusiii", function(_, pkt)
    if pkt:find("action|input\n|text|/proxy") then
        sendVariant({
            [0] = "OnDialogRequest", 
            [1] = dialog
            
        }, -1)
        return true
    end
end)

-- ░ HOOK 4 : feedback text ░ -----------------------------------------
AddHook("OnTextPacket","raps_feedback",function(_,pkt)
    if pkt:find("pulls``") then
        overlay("`5Pulled `0"..(pkt:match("pull`` (.+)!") or "player"))
    elseif pkt:find("kicks``") then
        overlay("`4Kicked `0"..(pkt:match("kick`` (.+)!") or "player"))
    elseif pkt:find("banishes``") or pkt:find("world%-bans") or pkt:find("bans``") then
        overlay("`cBanned `0"..(pkt:match("ban.*`` (.+)!") or "player"))
    end
end)

local ischanged = false
local nem = ''

function change(n)
    sendVariant({ 
        [0] = "OnNameChanged", 
        [1] = n 
        
    }, getLocal().netId)
end

AddHook('OnTextPacket', 'jawa', function(_, str)
    if str:find('/cn (.+)') then
        local name = str:match('/cn (.+)')
        change(name)
        nem = name
        ischanged = true
        overlay("`4changed visual name to:``` " .. name)
        return true
    end
    return false
end)

AddHook('OnVarlist', 'mojo_restore_name', function(v)
    if v[0] == 'OnCountryState' then
        if ischanged then 
            change(nem)
        end
    end
    return false
end)