dofile("scripts/forts.lua")

local MOD_SCRIPT = "mods/forts_admin/script.lua"
local MAX_CLIENT_INDEX = 16
local menuOpen = false
local menuControls = {}
local menuTargets = {}
local localBlackout = false

local function isLobbyCreator()
	return GetLocalClientIndex() == 0
end

local function removeMenu()
	for _, name in ipairs(menuControls) do
		if ControlExists("", name) then
			DeleteControl("", name)
		end
	end
	menuControls = {}
	menuTargets = {}
	menuOpen = false
end

local function addMenuText(name, text, y, style)
	AddTextControl("", name, text, ANCHOR_TOP_LEFT, Vec3(32, y), false, style)
	table.insert(menuControls, name)
end

local function addMenuButton(name, text, y)
	AddTextButtonControl("", name, text, ANCHOR_TOP_LEFT, Vec3(32, y), false, "Button")
	table.insert(menuControls, name)
end

local function openMenu()
	if not isLobbyCreator() or menuOpen then
		return
	end

	menuOpen = true
	addMenuText("forts_admin_title", "TROLL MENU", 36, "Heading")
	addMenuText("forts_admin_hint", "Choose a player to toggle the black screen", 70, "Default")

	local row = 0
	for clientIndex = 1, MAX_CLIENT_INDEX - 1 do
		local teamId = GetClientTeamId(clientIndex)
		if teamId ~= TEAM_NEUTRAL then
			local active = data.blackoutTargets[clientIndex] == true
			local buttonName = "forts_admin_player_" .. tostring(clientIndex)
			local status = active and "ON" or "OFF"
			addMenuButton(buttonName, "Player #" .. tostring(clientIndex) .. " (team " .. tostring(teamId) .. ") - BLACK SCREEN: " .. status, 112 + row * 42)
			menuTargets[buttonName] = clientIndex
			row = row + 1
		end
	end

	if row == 0 then
		addMenuText("forts_admin_empty", "No other players found", 112, "Default")
	end

	addMenuButton("forts_admin_close", "Close menu (U)", 142 + row * 42)
end

function Load(gameStart)
	if type(data.blackoutTargets) ~= "table" then
		data.blackoutTargets = {}
	end
end

function OnKey(key, down)
	if not down or not isLobbyCreator() or (key ~= "U" and key ~= "u") then
		return false
	end

	if menuOpen then
		removeMenu()
	else
		openMenu()
	end
	return true
end

function OnControlActivated(name, code, doubleClick)
	if not isLobbyCreator() or not menuOpen then
		return
	end

	if name == "forts_admin_close" then
		removeMenu()
		return
	end

	local clientIndex = menuTargets[name]
	if clientIndex then
		local enable = data.blackoutTargets[clientIndex] ~= true
		SendScriptEvent("SetBlackout", tostring(clientIndex) .. ", " .. tostring(enable), MOD_SCRIPT, true)
		removeMenu()
	end
end

function SetBlackout(clientIndex, enable)
	if type(clientIndex) ~= "number" or clientIndex < 1 or clientIndex >= MAX_CLIENT_INDEX or type(enable) ~= "boolean" then
		return
	end

	if enable then
		data.blackoutTargets[clientIndex] = true
	else
		data.blackoutTargets[clientIndex] = nil
	end
end

function OnUpdate(timeDelta)
	local shouldBeBlack = data.blackoutTargets[GetLocalClientIndex()] == true
	if shouldBeBlack ~= localBlackout then
		ShowWorld(not shouldBeBlack)
		ShowHUD(not shouldBeBlack, true)
		localBlackout = shouldBeBlack
	end
end

function OnRestart()
	data.blackoutTargets = {}
	localBlackout = false
	if menuOpen then
		removeMenu()
	end
end

function OnExit()
	if localBlackout then
		ShowWorld(true)
		ShowHUD(true, true)
		localBlackout = false
	end
	if menuOpen then
		removeMenu()
	end
end