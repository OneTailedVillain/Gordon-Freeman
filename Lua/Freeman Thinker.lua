local messagemodetxt = "say: "
local messagemode2txt = "say_team: "

	/*
	player.hl.inventory = {
		weapon_crowbar = true,
		weapon_9mmhandgun = true,
		ammo_9mm = 68,
	}
	*/

local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end
	end
end

local function warn(player, str)
	CONS_Printf(player, "\130WARNING: \128" .. tostring(str));
end

local skin = "kombifreeman"
local FLASH_DRAIN_TIME = FRACUNIT*6/5
local FLASH_CHARGE_TIME = FRACUNIT/5

SafeFreeSlot("SPR2_CRCH", "SPR2_CRWL", "S_PLAY_FREEMCROUCH", "S_PLAY_FREEMCROUCHMOVE",
"MT_HLRAY","MT_HLUSERAYCAST",
"sfx_hlflas","sfx_hlspra",
"sfx_pwepst","sfx_pwepsl","sfx_pwepcl","sfx_pwepen",
"sfx_hlfal1","sfx_hlfal2","sfx_hlfal3",
"sfx_frpai1","sfx_frpai2","sfx_frpai3","sfx_frpai4","sfx_frpai5",
"sfx_hlla1","sfx_hlla2","sfx_hlla3","sfx_hlla4",
"sfx_hlmed1","sfx_hlmed2")
sfxinfo[sfx_hldeny].caption = "\135Can't Use\x80" -- for SOME reason using the usual hex for this caption turns it cyan and eats the first two proper letters
sfxinfo[sfx_hlmed1].caption = "MEDIC!!"
sfxinfo[sfx_hlmed2].caption = "MEDIC!!"
/*
states[S_PLAY_FREEMCROUCHMOVE] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRWL|FF_ANIMATE,
	tics = -1,
	var1 = 24,
	var2 = 2,
	nextstate = S_PLAY_FREEMCROUCH
}
*/

mobjinfo[MT_HLUSERAYCAST] = {
spawnstate = S_INVISIBLE,
spawnhealth = 100,
deathstate = S_NULL,
speed = 64*FRACUNIT,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY | MF_PAPERCOLLISION,
}

states[S_PLAY_FREEMCROUCHMOVE] = {
	sprite = SPR_PLAY,
	frame = SPR2_CRWL|FF_ANIMATE,
	tics = -1,
	var1 = I,
	var2 = 6,
	nextstate = S_PLAY_FREEMCROUCHMOVE
}

states[S_PLAY_FREEMCROUCH] = {
	sprite = SPR_PLAY,
	frame = FF_ANIMATE|SPR2_CRCH,
	tics = -1,
	var1 = 14,
	var2 = 6,
	nextstate = S_PLAY_FREEMCROUCH
}

spr2defaults[SPR2_CRWL] = SPR2_WALK
spr2defaults[SPR2_CRCH] = SPR2_STND

local function SpawnSpray(mo)
	local spr  = P_SpawnPlayerMissile(mo, MT_SPRAY)
	spr.pangle = mo.angle
	spr.tracer = mo
	spr.z      = $+(mo.player.viewheight/2)
	return spr
end

-- Constants
local CATEGORY_COUNT = 10

-- Returns an empty weapon selection structure
local function emptySelection()
	local ws = {}
	for i = 0, 9 do ws[i] = 0 end
	return {
		weapons = {},
		weaponcount = 0,
		wepslotamounts = ws
	}
end

-- Returns the index of the first usable weapon, or nil if none
local function getFirstUsableIndex(sel)
	if not sel or not sel.weapons then return nil end
	for i, w in ipairs(sel.weapons) do
		if w.usable then return i end
	end
	return nil
end

-- Steps through the current bucket without wrapping
local function cycleWithinCategory(sel, startIndex, step)
	local cnt = sel and sel.weaponcount or 0
	if cnt < 2 then return nil end

	local idx = startIndex + step
	while idx >= 1 and idx <= cnt do
		if sel.weapons[idx].usable then return idx end
		idx = idx + step
	end

	return nil
end

-- Steps through the current bucket with wraparound
local function cycleWithinCategoryWrap(sel, startIndex, step)
	local cnt = sel and sel.weaponcount or 0
	if cnt < 1 then return nil end

	local idx = startIndex
	for _ = 1, cnt do
		idx = ((idx - 1 + step) % cnt) + 1
		if sel.weapons[idx].usable then return idx end
	end

	return nil
end

-- Tries to switch to a new weapon category with at least one usable weapon
local function switchCategory(currentCat, dir, player)
	for i = 1, CATEGORY_COUNT do
		local offset = (dir == 1 and i or -i)
		local newCat = (currentCat + offset + CATEGORY_COUNT) % CATEGORY_COUNT
		local sel = HL_GetWeapons(HLItems, newCat, player) or emptySelection()
		if getFirstUsableIndex(sel) then
			return newCat, sel
		end
	end
	local fallback = HL_GetWeapons(HLItems, 11, player)
	return CATEGORY_COUNT + 1, fallback or emptySelection() -- fallback if nothing usable
end

-- Main weapon cycling function (non-wrapping within category)
local function HL_CycleWeapon(player, direction)
	if not player or not player.hlinv.weapons then return end
	player.hl.wepmenu.isopen = true

	local dirstep = direction == "next" and 1 or -1
	local cat = player.hl.wepmenu.category or 0
	local sel = player.selectionlist or HL_GetWeapons(HLItems, cat, player) or emptySelection()
	local first = getFirstUsableIndex(sel)

	if sel.weaponcount == 0 or not first then
		local nc, ns = switchCategory(cat, dirstep, player)
		player.kombiprevhl1category = cat
		player.hl.wepmenu.category = nc
		player.selectionlist = ns
		player.hl.wepmenu.index = getFirstUsableIndex(ns) or 0
		return
	end

	local cur = player.hl.wepmenu.index or first
	local newIndex = cycleWithinCategory(sel, cur, dirstep)

	if newIndex then
		player.hl.wepmenu.index = newIndex
		return
	end

	local nc, ns = switchCategory(cat, dirstep, player)
	player.kombiprevhl1category = cat
	player.hl.wepmenu.category = nc
	player.selectionlist = ns

	if direction == "next" then
		player.hl.wepmenu.index = getFirstUsableIndex(ns) or 0
	else
		for i = #ns.weapons, 1, -1 do
			if ns.weapons[i].usable then
				player.hl.wepmenu.index = i
				break
			end
		end
		player.hl.wepmenu.index = player.hl.wepmenu.index or 0
	end
end

COM_AddCommand("invnext", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "prev")
end)

COM_AddCommand("invprev", function(player)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	HL_CycleWeapon(player, "next")
end)

local myTyping = ""
local myTypingMode = 0

-- Type message (public)
COM_AddCommand("messagemode", function(player)
	if not player then return end
	if player != consoleplayer then return end
	player.hl = $ or {}
	myTyping = ""
	myTypingMode = not $ and 1 or 0
end)

-- Type message (team)
COM_AddCommand("messagemode2", function(player)
	if not player then return end
	if player != consoleplayer then return end
	player.hl = $ or {}
	myTyping = ""
	myTypingMode = not $ and 2 or 0
end)

/*
violence_ablood 1	enable blood (0 will improve perfomance some, but you won't see any blood)
violence_agibs 1	enable gibs (0 will improve performance some, but you won't see body chunks)
violence_hblood 1	enable more blood (0 will improve perfomance some, but you won't see as much blood)
violence_hgibs 1	enable more gibs (0 will improve performance some, but you won't see as many body chunks)
*/
local function printTable(data, prefix)
	prefix = prefix or ""
	if type(data) == "table"
		for k, v in pairs(data or {}) do
			local key = prefix .. k
			if type(v) == "table" then
				CONS_Printf(server, "key " .. key .. " = a table:")
				printTable(v, key .. ".")
			else
				CONS_Printf(server, "key " .. key .. " = " .. tostring(v))
			end
		end
	else
		CONS_Printf(server, data)
	end
end

-- Define a helper that takes the base command name, and two functions: one for the '+' variant and one for the '-' variant.
local function RegisterDualCommand(cmd, onPress, onRelease)
	-- Create the press command ("+<cmd>")
	COM_AddCommand("+" .. cmd, function(player, ...)
		if not player.mo then
			return
		end
		-- Register that the player is holding the command
		player.hlcmds = player.hlcmds or {}
		player.hlcmds[cmd] = true
		-- Execute the onPress behavior if provided
		if onPress then onPress(player, ...) end
	end)

	-- Create the release command ("-<cmd>")
	COM_AddCommand("-" .. cmd, function(player, ...)
		if not player.mo then
			return
		end
		-- Mark the command as released
		player.hlcmds = player.hlcmds or {}
		player.hlcmds[cmd] = false
		-- Execute the onRelease behavior if provided
		if onRelease then onRelease(player, ...) end
	end)
end

local function FixedHypot3(x, y, z)
	return FixedHypot(FixedHypot(x, y), z)
end

local function HL_TheRaycastingAtHome(mobj)
    -- sanity
    if not (mobj and mobj.valid) then return end
    if mobj.dontraycast then return end

    local shooter = mobj.target
    -- give the shooter noclip so the beam/bullet never bumps into them
    shooter.flags = shooter.flags | MF_NOCLIP

    -- 1) figure out how many steps to take:
    local speed_fp  = mobjinfo[mobj.type].speed
    local maxdist   = mobj.dist or (FRACUNIT * 4096)                                 -- fallback range
    local diststeps = FixedCeil(FixedDiv(maxdist*HL.BULLETSPEED, speed_fp))/FRACUNIT -- override or compute

    -- 2) normalize the momentum vector so each tick moves exactly speed_fp:
    do
        local mag = FixedHypot3(mobj.momx, mobj.momy, mobj.momz)
        if mag > 0 then
            local ux = FixedDiv(mobj.momx, mag)
            local uy = FixedDiv(mobj.momy, mag)
            local uz = FixedDiv(mobj.momz, mag)
            mobj.momx = FixedMul(ux, speed_fp)
            mobj.momy = FixedMul(uy, speed_fp)
            mobj.momz = FixedMul(uz, speed_fp)
			mobj.scale = FRACUNIT
        end
    end

    -- 3) step the raycast!
    local hit = false
    for i = 1, diststeps do
        if not (mobj and mobj.valid) then break end
        if P_RailThinker(mobj) then
            hit = true
            break
        end
    end

    -- 4) handle post‑trace behavior
    if not hit then
        if mobj.stats and mobj.stats.israycaster then
            mobj.state = S_NULL
        else
            mobj.dontraycast = true
        end
    else
		if not mobj and mobj.valid then return end
		if mobj and mobj.valid then mobj.dontraycast = true end
    end

    -- clean up the flag
    shooter.flags = shooter.flags & ~MF_NOCLIP
end

local MAX_USE_ANGLE = ANGLE_45 -- how wide of a horizontal angle we can search
local MAX_USE_DIST = USERANGE -- How far the check can go before it's too far
RegisterDualCommand("use",
	function(player)
		if not player.mo then return end
		local ray = P_SpawnMobjFromMobj(player.mo, 0, 0, player.mo.height-8*FRACUNIT, MT_HLUSERAYCAST)
		ray.scale = player.mo.scale
		ray.target = player.mo
		HL_TheRaycastingAtHome(ray)
		S_StartSound(player.mo, sfx_hldeny)
	end)

addHook("MobjLineCollide", function(ray, hit)
	if not doom and DOOM_TryUse then return end
    if not (ray and ray.valid) then return end

    local usedLine = hit
    local lineSpecial = doom.linespecials[usedLine]
    if not lineSpecial then return end
    local whatIs = doom.lineActions[lineSpecial]

    if not whatIs then P_KillMobj(ray) return end
    if whatIs.activationType == "interact" then
        if whatIs.type == "exit" then
			DOOM_ExitLevel()
            return true
        end
        DOOM_AddThinker(usedLine.backsector, whatIs)
    elseif whatIs.activationType == "switch" then
		S_StartSound(ray.target, sfx_swtchn)
        for sector in sectors.tagged(usedLine.tag) do
            DOOM_AddThinker(sector, whatIs)
        end
    end

    P_KillMobj(ray)
    return true
end, MT_HLUSERAYCAST)

addHook("MobjMoveCollide", function(ray, hit)
	-- hit is the mobj the player just "used"
	local usedActor = hit
	if usedActor == ray.target then return false end

	-- do whatever you wanted to do with it:
	-- e.g. print its type and position
	CONS_Printf(ray.target.player, 
		"+use on object of typenum " .. usedActor.type
	)

	-- destroy the ray so it doesn't keep going
	P_KillMobj(ray)

	-- stop further collision processing on this ray
	return false
end, MT_HLUSERAYCAST)

RegisterDualCommand("duck")
RegisterDualCommand("jump")
RegisterDualCommand("reload")
RegisterDualCommand("attack")
RegisterDualCommand("attack2")
RegisterDualCommand("speed")
RegisterDualCommand("lookup",
	function(player) -- onPress
		player.hl.pitchLook = ($ or 0) + 1
	end,
	function(player) -- onRelease
		player.hl.pitchLook = ($ or 0) - 1
	end)

RegisterDualCommand("lookdown",
	function(player) -- onPress
		player.hl.pitchLook = ($ or 0) - 1
	end,
	function(player) -- onRelease
		player.hl.pitchLook = ($ or 0) + 1
	end)
RegisterDualCommand("left",
	function(player) -- onPress
		player.hl.yawLook = ($ or 0) + 1
	end,
	function(player) -- onRelease
		player.hl.yawLook = ($ or 0) - 1
	end)

RegisterDualCommand("right",
	function(player) -- onPress
		player.hl.yawLook = ($ or 0) - 1
	end,
	function(player) -- onRelease
		player.hl.yawLook = ($ or 0) + 1
	end)


function string.trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function stripOuterQuotes(s)
    if type(s) ~= "string" then return s end
    while s:sub(1,1)=='"' and s:sub(-1)=='"' do
        s = s:sub(2,-2)
    end
    while s:sub(1,1)=="'" and s:sub(-1)=="'" do
        s = s:sub(2,-2)
    end
    return s
end

-- Helper function: Get what the command is supposed to be ("+cmd" for dual, "cmd" for normal)
local function getBinding(bind)
    if type(bind) == "string" then
        bind = stripOuterQuotes(bind)
        local cmds = {}

        for piece in bind:gmatch("[^;]+") do
            piece = piece:trim()
            local dual = false
            if piece:sub(1,1)=="+" then
                dual = true
                piece = piece:sub(2)
            end
            table.insert(cmds, {command=piece, dual=dual})
        end
        return cmds
    end
    return bind
end

-- Reports if the player is able to do anything (quick-fixes some custom things)
local function playerHasControl(player)
return not (
  player.exiting
  or gamestate ~= GS_LEVEL
  or player.powers[pw_nocontrol]
  or P_PlayerInPain(player)
  or (player.pflags & PF_STASIS)
  or (player.pflags & PF_FULLSTASIS)
  or (player.powers[pw_carry] > CR_NONE)
  or (player.playerstate ~= PST_LIVE)
  or chatactive
  or (gamemap == 100 and player.mapmenu != nil)
) end

-- True character printout
local keyalias = {
	KEY123 = "{",
	KEY124 = "|",
	KEY125 = "}",
	KEY126 = "~",
	TILDE = "`",
	space = " ",
}

-- Used to automatically switch to shiftkeys if we're holding SHIFT
local shiftdown = {
	l = false,
	r = false
}

local function isShiftDown()
	return shiftdown.l or shiftdown.r
end

-- Aliased key binds.
-- Note: By prefixing the command with "+", you automatically mark the command as dual. The associated command should be prefixed with a "-"!!
-- e.g. "+something" "-something"
local defaultKeyBinds = {
	q				 = "lastinv",		-- SHIELD
	e				 = "+use",
	r				 = "+reload",		-- CUSTOM 1
	lctrl			 = "+duck",			-- SPIN
	f				 = "impulse 100",	-- CUSTOM 2
	lshift			 = "+speed",		-- CUSTOM 3
	g				 = "impulse 201",   -- TOSSFLAG
	z				 = "saveme",
	space			 = "+jump",
	["0"]			 = "slot0",
	["1"]			 = "slot1",			-- WPN SLOT 1
	["2"]			 = "slot2",			-- WPN SLOT 2
	["3"]			 = "slot3",			-- WPN SLOT 3
	["4"]			 = "slot4",			-- WPN SLOT 4
	["5"]			 = "slot5",			-- WPN SLOT 5
	["6"]			 = "slot6",			-- WPN SLOT 6
	["7"]			 = "slot7",			-- WPN SLOT 7
	["8"]			 = "slot8",
	["9"]			 = "slot9",
	["wheel 1 up"]	 = "invprev",
	["wheel 1 down"] = "invnext",
}

local myKeybinds = {}

-- Custom command that basically lets us have certain commands on any button
COM_AddCommand("hl_bind", function(player, key, command)
	if not command then
		CONS_Printf(player, "Usage: hl_bind <key> <command>", "Example: bind e +use")
		return
	end
	myKeybinds[key] = command
	saveTableToFile(HL.KEYBINDS_PATH, myKeybinds, player)
	CONS_Printf(player, "Bound key '" .. key .. "' to command '" .. command .. "'")
end, COM_LOCAL)

COM_AddCommand("hl_unbind", function(player, key)
	if not key then
		CONS_Printf(player, "Usage: hl_unbind <key>", "Example: unbind e")
		return
	end
	myKeybinds[key] = nil
	saveTableToFile(HL.KEYBINDS_PATH, myKeybinds, player)
end, COM_LOCAL)

-- KeyDown hook function
local function OnKeyDown(keyevent)
	-- print(keyevent.name)
	if not consoleplayer then return end
	local isshift = isShiftDown()
	if keyevent.name == "TILDE" and not isshift then return end
	if keyevent.name == "lshift" then shiftdown.l = true end
	if keyevent.name == "rshift" then shiftdown.r = true end
	local bindEntry = myKeybinds and myKeybinds[keyevent.name]
	local isTyping = myTypingMode
	local typeMode = myTypingMode == 1 and "say" or "sayteam"
	if isTyping then
		local totype = tostring(keyalias[keyevent.name] or keyevent.name)
		local typed = isshift and input.keyNumToName(input.shiftKeyNum(keyevent.num)) or totype
		if isshift then typed = keyalias[$] or $ end
		typed = tostring(typed)
		if typed == "enter" then
			if myTyping != "" then
				COM_BufInsertText(consoleplayer, typeMode .. ' "' .. myTyping .. '"')
				COM_BufInsertText(consoleplayer, "messagemode")
			end
		elseif typed == "backspace" then
			myTyping = string.sub($, 1, -2)
		elseif input.keyNumPrintable(keyevent.num)
			myTyping = ($ or "") .. typed
		end
		return true
	end
	if not consoleplayer.realmo then return end
	if (consoleplayer.playerstate ~= PST_LIVE) and bindEntry then
		local bindings = getBinding(bindEntry)
		for _, binding in ipairs(bindings) do
			if not keyevent.repeated then
				if binding.command != "jump" then return end
				if binding.dual then
					COM_BufInsertText(consoleplayer, "+" .. binding.command)
				else
					COM_BufInsertText(consoleplayer, binding.command)
				end
			end
		end
	end
	if not playerHasControl(consoleplayer) then return end
	if consoleplayer.realmo.skin != skin then return end
	if bindEntry then
		local bindings = getBinding(bindEntry)
		for _, binding in ipairs(bindings) do
			if not keyevent.repeated then
				if binding.dual then
					COM_BufInsertText(consoleplayer, "+" .. binding.command)
				else
					COM_BufInsertText(consoleplayer, binding.command)
				end
			end
		end
		return true
	end
	return false	-- No binding: allow normal processing.
end

local function isButtonBind(keyevent)
	for i = 0, NUM_GAMECONTROLS - 1 do
		if input.keyNumToName(input.gameControlToKeyNum(i)) == keyevent.name then
			return true
		end
	end
	return false
end

-- KeyUp hook function, only needed for dual commands.
local function OnKeyUp(keyevent)
	if not consoleplayer then return end
	if not consoleplayer.realmo then return end
	if not playerHasControl(consoleplayer) then return end
	if consoleplayer.realmo.skin != skin then return end
	if keyevent.name == "lshift" then shiftdown.l = false end
	if keyevent.name == "rshift" then shiftdown.r = false end
	local bindEntry = myKeybinds and myKeybinds[keyevent.name]
	if bindEntry then
		local bindings = getBinding(bindEntry)
		for _, binding in ipairs(bindings) do
			if binding.dual then
				COM_BufInsertText(consoleplayer, "-" .. binding.command)
			end
		end
		return not isButtonBind(keyevent)
	end
	return false
end

-- Register the hooks.
addHook("KeyDown", OnKeyDown)
addHook("KeyUp", OnKeyUp)
/*
local PLAYER_FATAL_FALL_SPEED = FixedMul(2769450, FRACUNIT*8/6)
local PLAYER_MAX_SAFE_FALL_SPEED = FixedMul(1107000, FRACUNIT*8/6)
local DAMAGE_FOR_FALL_SPEED = FixedDiv(100*FRACUNIT,(PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED))
local PLAYER_FALL_PUNCH_THRESHOLD = FixedMul(668000, FRACUNIT*8/6)

#define PLAYER_FATAL_FALL_SPEED		1024// approx 60 feet
#define PLAYER_MAX_SAFE_FALL_SPEED	580// approx 20 feet
#define DAMAGE_FOR_FALL_SPEED		(float) 100 / ( PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED )// damage per unit per second.
#define PLAYER_MIN_BOUNCE_SPEED		200
#define PLAYER_FALL_PUNCH_THRESHHOLD (float)350 // won't punch player's screen/make scrape noise unless player falling at least this fast.
*/
local function HLToDoom(hlUnit)
    return FixedMul(hlUnit, HL.ConvRatio)
end

local PLAYER_FATAL_FALL_SPEED = 45*FRACUNIT
local PLAYER_MAX_SAFE_FALL_SPEED = 26*FRACUNIT
local DAMAGE_FOR_FALL_SPEED = FixedDiv(100*FRACUNIT,(PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED))
local PLAYER_FALL_PUNCH_THRESHOLD = 18*FRACUNIT

local nofalldmgmaps = {
	["12 convoy assault"] = function(player)
		return player.awayviewtics
	end,
	["4 techno hill zone 1"] = function(player, fallSpeed)
		return player.mo.x > 16868*FRACUNIT and player.mo.z < 3840*FRACUNIT and (fallSpeed or 0) >= 2293760
	end,
}

local function HL_GetFallDamage(fallSpeed, player)
	local mapkey = gamemap .. " " .. string.lower(G_BuildMapTitle(gamemap) or "")
	local nofalldmg = nofalldmgmaps[mapkey]

	-- Skip fall damage if map says so, if in water, or player flags it off
	if fallSpeed
	and ((nofalldmg and (type(nofalldmg) ~= "function" or nofalldmg(player, fallSpeed)))
	or (player.mo.eflags & (MFE_TOUCHWATER|MFE_UNDERWATER) ~= 0)
	or (player.hl and (player.hl.nofalldmg or player.hl.fallcount)))
	then
		if player.hl.fallcount then player.hl.fallcount = $-1 end
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	local fallspeed_abs = abs(fallSpeed)

	-- Respect cv_kombifalldamage.value before checking for safe/fatal speed thresholds
	local falldmgmode = cv_kombifalldamage.value
	if falldmgmode == -1 then -- "Dont"
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	elseif falldmgmode == 0 then -- "Fixed"
		return {dmg = fallspeed_abs >= PLAYER_MAX_SAFE_FALL_SPEED and 10 or 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	-- Handle safe fall (no damage) and fatal fall (max damage)
	if fallspeed_abs <= PLAYER_MAX_SAFE_FALL_SPEED then
		return {dmg = 0, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	elseif fallspeed_abs >= PLAYER_FATAL_FALL_SPEED then
		-- If not "On", still apply damage based on custom setting.
		if falldmgmode == 1 then -- "On"
			local calcDamage = FixedMul(fallspeed_abs - PLAYER_MAX_SAFE_FALL_SPEED, DAMAGE_FOR_FALL_SPEED)
			return {dmg = min(FixedInt(calcDamage), 100), fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
		else
			return {dmg = 100, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
		end
	end

	-- Handle fall damage between safe and fatal fall
	if falldmgmode == 1 then -- "On"
		local calcDamage = FixedMul(fallspeed_abs - PLAYER_MAX_SAFE_FALL_SPEED, DAMAGE_FOR_FALL_SPEED)
		return {dmg = min(FixedInt(calcDamage), 100), fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
	end

	-- Default fixed value
	return {dmg = 10, fallpunch = (fallSpeed >= PLAYER_FALL_PUNCH_THRESHOLD)}
end

addHook("PlayerThink", function(player)
	if not player.hl then return end
	if not player.mo then return end
	if player.mo.skin != skin then return end

	if player.hl.pitchLook then
		player.aiming = $ + FixedAngle((player.hl.config.pitchspeed / 60) * player.hl.pitchLook)
	end

	if player.hl.yawLook then
		player.mo.angle = $ + FixedAngle((player.hl.config.yawspeed / 60) * player.hl.yawLook)
	end

	if not player.mo then return end

	if (player.pflags & PF_NOCLIP) then
		if not player.hl.noclippedtic then
			player.mo.flags = $ | MF_NOGRAVITY | MF_NOCLIPHEIGHT | MF_NOCLIP -- physics in QuakePhysics
		end
		player.hl.killcam = player.mo
	elseif player.hl.noclippedtic then
		player.mo.flags = $ & ~(MF_NOGRAVITY | MF_NOCLIPHEIGHT | MF_NOCLIP)
		player.awayviewaiming = 0
		player.awayviewtics = 0
		player.hl.noclippedtic = nil
		player.hl.killcam = nil
	end

	-- Handle impulse 201 call (since SRB2 seems to whine when we do it in the command itself)
	if player.hl and player.hl.spraying then
		SpawnSpray(player.mo)
		player.hl.spraying = false
	end

	-- If Freeman, handle fall damage
	if player.realmo.skin == "kombifreeman" then
		local mapkey = gamemap .. " " .. string.lower(G_BuildMapTitle(gamemap) or "")
		local nofalldmg = nofalldmgmaps[mapkey]
		if player.hl and (nofalldmg and (type(nofalldmg) ~= "function" or nofalldmg(player))) then
			player.hl.fallcount = 1
		end
		if player.mo.eflags & MFE_JUSTHITFLOOR then
			local fallhurt = HL_GetFallDamage(abs(player.kombifallz or 0), player)
			if fallhurt.dmg then
				P_DamageMobj(player.mo, nil, nil, fallhurt.dmg, HL.DMG.FALL)
				S_StartSound(player.mo,P_RandomRange(sfx_hlfal1,sfx_hlfal3))
				if player.mo.hl.health <= 0 then
					player.mo.killfallvel = player.kombifallz
				end
			end
			if fallhurt.fallpunch then
				player.hl = $ or {}
				player.hl.punchangle.z = (ANG350+ANG2+ANG2+ANG2) >> 16
			end
			player.kombifallz = 0
		elseif not P_IsObjectOnGround(player.mo) then
			-- Record the fall velocity for future fall damage checks
			player.kombifallz = player.mo.momz
		end
	end
end)

local laddertextures = {
    CUT10    = true,
	ConL     = true,
	LADDER1  = true,
}

local function intervalsIntersect(aBottom, aTop, bBottom, bTop)
    -- True if they share *any* non‑zero overlap
    return (aTop  > bBottom)
       and (aBottom < bTop)
end

addHook("MobjMoveBlocked", function(mo, thing, line)
    -- Basic sanity
    if not (mo and mo.valid and mo.player and line) then
        if mo.player then mo.player.hl = mo.player.hl or {} end
        return
    end

    local hl = mo.player.hl or {}
    mo.player.hl = hl

    -- Determine which side of the line we're on
    local sideIndex = P_PointOnLineSide(mo.x, mo.y, line)
    local mysec     = (sideIndex == 0) and line.frontsector or line.backsector
    local oppsec    = (sideIndex == 0) and line.backsector  or line.frontsector
    local sidedef   = (sideIndex == 0) and line.frontside   or line.backside

    local pBot = mo.z
    local pTop = mo.z + mo.height

    -- Prepare texture lookup table
    local ladderTexs = laddertextures

    -- Fast-path: iterate both sectors' ffloors lists in one go
    local sectors = { mysec, oppsec }
    for si = 1, 2 do
        local sec = sectors[si]
        if sec then
            for ff in sec.ffloors() do
                if ff.valid and (ff.flags & FOF_EXISTS) ~= 0 then
                    local fBot = ff.bottomheight
                    local fTop = ff.topheight

                    if intervalsIntersect(fBot, fTop, pBot, pTop) then
						local ms = ff.master.frontside
                        if ms then
                            -- grab all three texture names once
                            local mid  = R_TextureNameForNum(ms.midtexture)
                            local top  = R_TextureNameForNum(ms.toptexture)
                            local bot  = R_TextureNameForNum(ms.bottomtexture)

                            if ladderTexs[mid] or ladderTexs[top] or ladderTexs[bot] then
                                hl.climb             = true
                                hl.climbing          = line
                                hl.climbing_is_front = sideIndex
                                hl.ladderbottom     = fBot
                                hl.laddertop        = fTop
                                return
                            end
                        end
                    end
                end
            end
        end
    end

    -- No FOF ladder found — fall back on sidedef textures
    if sidedef then
        local mt = R_TextureNameForNum(sidedef.midtexture)
        local tt = R_TextureNameForNum(sidedef.toptexture)
        local bt = R_TextureNameForNum(sidedef.bottomtexture)

        if ladderTexs[mt] or ladderTexs[tt] or ladderTexs[bt] then
            hl.climb             = true
            hl.climbing          = line
            hl.climbing_is_front = sideIndex

            if mysec ~= oppsec then
                -- two different sectors
                hl.ladderbottom = mysec.floorheight
                hl.laddertop    = oppsec.floorheight
            else
                -- single-sided line
                hl.ladderbottom = mysec.floorheight
                hl.laddertop    = mysec.ceilingheight
            end

            return
        end
    end

    -- Not a ladder: clear stored data
    hl.climb        = nil
    hl.climbing     = nil
    hl.ladderbottom = nil
    hl.laddertop    = nil
end, MT_PLAYER)

local function ClosestPointOnSegment_t(px, py, x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    local denom = FixedMul(dx,dx) + FixedMul(dy,dy)
    if denom == 0 then
        return x1, y1, 0, true
    end

    -- projection numerator
    local num = FixedMul(px - x1, dx) + FixedMul(py - y1, dy)
    -- unclamped t in fixed [0..FRACUNIT] space
    local tUnc = FixedDiv(num, denom)

    local outside = false
    local t = tUnc
    if tUnc < 0 then
        t, outside = 0, true
    elseif tUnc > FRACUNIT then
        t, outside = FRACUNIT, true
    end

    local cx = x1 + FixedMul(t, dx)
    local cy = y1 + FixedMul(t, dy)
    return cx, cy, t, outside
end

addHook("PreThinkFrame", function()
    for player in players.iterate do
        local mo = player.mo
        if not (mo and mo.valid) then
            if mo then mo.flags = mo.flags & ~MF_NOGRAVITY end
            continue
        end

        local cmd = player.cmd
        local hl  = player.hl or {}
        player.hl = hl

        if hl.climb and hl.climbing then
            -- vertical check
            local bottom = min(hl.ladderbottom, hl.laddertop)
            local top    = max(hl.ladderbottom, hl.laddertop)
            if mo.z < bottom or mo.z > top then
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                cmd.forwardmove, cmd.sidemove = 0,0
                continue
            end

            -- corner-segment detach
            local x1,y1 = hl.climbing.v1.x, hl.climbing.v1.y
            local x2,y2 = hl.climbing.v2.x, hl.climbing.v2.y
            local ladangle = R_PointToAngle2(x1,y1, x2,y2)

            -- ladder-plane normal
            local nx,ny = cos(ladangle+ANGLE_90), sin(ladangle+ANGLE_90)
            if not hl.climbing_is_front then nx,ny = -nx,-ny end

            -- ladder tangent (for horizontal)
            local tx,ty = cos(ladangle), sin(ladangle)

            local radius = mo.radius
            local thr   = FixedMul(radius, abs(nx)+abs(ny))
            local SAFE  = FRACUNIT/8

            local anyOn = false
            for _,off in ipairs({{radius,radius},{radius,-radius},{-radius,radius},{-radius,-radius}}) do
                local px,py = mo.x+off[1], mo.y+off[2]
                local cx,cy,t,out = ClosestPointOnSegment_t(px,py, x1,y1, x2,y2)
                if not out then
                    local dx,dy = px-cx, py-cy
                    local dist  = FixedSqrt(FixedMul(dx,dx)+FixedMul(dy,dy))
                    if dist <= thr+SAFE then
                        anyOn = true
                        break
                    end
                end
            end
            if not anyOn then
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                cmd.forwardmove, cmd.sidemove = 0,0
                continue
            end

            -- climb movement + sound
            mo.flags = mo.flags | MF_NOGRAVITY

            -- scale inputs into fixed speeds
            local ZSPEED = 6*FRACUNIT
            local XSPEED = 6*FRACUNIT
            local f = cmd.forwardmove * FRACUNIT
            local s = cmd.sidemove    * FRACUNIT

            -- sound timer (16-tic interval)
            hl.sndtick = hl.sndtick or 0
            if f != 0 or s != 0 then
                hl.sndtick = hl.sndtick + 1
                if hl.sndtick >= 16 then
                    hl.sndtick = 0
                    local sfx = sfx_hlla1 + P_RandomRange(0,3)
                    S_StartSound(mo, sfx)
                end
            end

            -- map into velocities
            local fv = FixedMul(f, FixedDiv(ZSPEED, 50*FRACUNIT))
            -- band-aid invert sidemove so right>0 moves you right
            local rv = FixedMul(-s, FixedDiv(XSPEED, 50*FRACUNIT))

            cmd.forwardmove, cmd.sidemove = 0,0

            -- jump off
            if cmd.buttons & BT_JUMP ~= 0 then
				local ladderSpeed = HLToDoom(200*FRACUNIT)
                mo.momx = FixedMul(nx, ladderSpeed)
                mo.momy = FixedMul(ny, ladderSpeed)
				P_SetObjectMomZ(mo, 4*FRACUNIT)
                hl.climb = false
				hl.sndtick = 0
                mo.flags = mo.flags & ~MF_NOGRAVITY
                continue
            end

            -- build world-space vel exactly like HL
            local a = mo.angle
            local vpnx,vpny = cos(a), sin(a)
            local vrx, vry  = cos(a+ANGLE_90), sin(a+ANGLE_90)
            local vx = FixedMul(vpnx,fv) + FixedMul(vrx,rv)
            local vy = FixedMul(vpny,fv) + FixedMul(vry,rv)

            -- decompose: lateral XY + −normal→Z
            local normal = FixedMul(vx,nx) + FixedMul(vy,ny)
            local lx = vx - FixedMul(nx, normal)
            local ly = vy - FixedMul(ny, normal)

            mo.momx = lx
            mo.momy = ly
            mo.momz = -normal
        else
            mo.flags = mo.flags & ~MF_NOGRAVITY
        end
    end
end)

-- Constants for battery drain/recharge rates
local DRAIN_RATE = FRACUNIT / 42
local RECHARGE_RATE = FRACUNIT / 7
local MAX_BATTERY = 100 * FRACUNIT

COM_AddCommand("hl_loadspray", function(player, color, spray)
	player.hl = $ or {}
	player.hl.spray = {}
	player.hl.spray.spray = spray
	player.hl.spray.color = color
end)

HL.defaultConfig = {
	suitvolume = 255,
	viewkick = true,
	autoswitch = true,
	killfeed = true,
	fangdeath = true,
	pitchspeed = 300,
	yawspeed = 210,
	chairscale = FRACUNIT/2,
}

COM_AddCommand("hl_loadconfigkey", function(player, key, val)
	player.hl = $ or {}
	player.hl.config = $ or {}
	local key = stripOuterQuotes(key)
	local val = stripOuterQuotes(val)

	local num = tonumber(val)
	if num ~= nil then
		player.hl.config[key] = num
	elseif val ~= nil then
		player.hl.config[key] = val
	elseif HL.defaultConfig then
		player.hl.config[key] = HL.defaultConfig[key]
	end
end)

local function doConfigShit(player)
	myKeybinds = loadTableFromFile(HL.KEYBINDS_PATH, defaultKeyBinds)
	for k,v in pairs(myKeybinds) do
		myKeybinds[k] = stripOuterQuotes(v)
	end
	local mySpray = loadTableFromFile(HL.SPRAY_CONFIG_PATH, {spray = "lambda", color = nil})
	for k,v in pairs(mySpray) do
		mySpray[k] = stripOuterQuotes(v)
	end
	local myConfig = loadTableFromFile(HL.CONFIG_PATH, {
		suitvolume = 255,
		viewkick = true,
		autoswitch = true,
		killfeed = true,
		pitchspeed = 300,
		yawspeed = 210,
		chairscale = FRACUNIT/2,
	})
	for k,v in pairs(myConfig) do
		myConfig[k] = stripOuterQuotes(v)
	end
	COM_BufInsertText(player, "hl_loadspray '" .. mySpray.color .. "' '" .. mySpray.spray .. "'")
	for k, v in pairs(myConfig) do
		COM_BufInsertText(player, "hl_loadconfigkey '" .. k .. "' '" .. tostring(v) .. "'")
	end
end

local function deepcopy(orig)
	local orig_type = type(orig)
	if orig_type ~= 'table' then
		if orig_type == "boolean" then
			return orig == true
		else
			return tonumber(orig) == nil and tostring(orig) or tonumber(orig)
		end
	end
	local copy = {}
	for k, v in next, orig, nil do
		copy[deepcopy(k)] = deepcopy(v)
	end
	return copy
end

local function saveStatus(player)
	player.hl = $ or {}
	player.hlinv = $ or {}
	player.mo.hl = $ or {}
	player.hl.laststate = {}
	player.hl.laststate.clips = deepcopy(player.hlinv.wepclips)
	player.hl.laststate.ammo = deepcopy(player.hlinv.ammo)
	player.hl.laststate.weapons = deepcopy(player.hlinv.weapons)
	player.hl.laststate.suit = deepcopy(player.hlinv.hevsuit)
	player.hl.laststate.twoxammo = deepcopy(player.hl1doubleammo)
	player.hl.laststate.curwep = deepcopy(player.hl.curwep)
	player.hl.laststate.health = deepcopy(player.mo.hl.health)
	player.hl.laststate.armor = deepcopy(player.mo.hl.armor)
	player.hl.laststate.mhealth = deepcopy(player.mo.hl.maxhealth)
	player.hl.laststate.marmor = deepcopy(player.mo.hl.maxarmor)
	player.hl.laststate.flashlight = deepcopy(player.hl.curwep)
	player.hl.laststate.longjump = deepcopy(player.hlinv.longjump)
	player.hl.laststate.pos = {
		x = deepcopy(player.mo.x),
		y = deepcopy(player.mo.y),
		z = deepcopy(player.mo.z),
	}
	player.hl.laststate.momentum = {
		x = deepcopy(player.mo.momx),
		y = deepcopy(player.mo.momy),
		z = deepcopy(player.mo.momz),
	}
	player.hl.laststate.map = deepcopy(gamemap)
	player.hl.laststate.preset = deepcopy(player.hl.preset)
end

addHook("PlayerSpawn",function(player)
	if not player.mo return end
	if consoleplayer == player
	and player.mo.skin == "kombifreeman"
		camera.chase = false
	end
	player.hl = $ or {}
	player.hlinv = $ or {}
	player.hlcmds = {}
	player.voxBuffer = {{}, {}}
	player.hl.punchangle = $ or {x = 0, y = 0, z = 0}
	player.hl.suitvoicewait = {}
	player.hl.dmgicons = {}
	player.hl.config = $ or {}
	player.hl.wepmenu = {index = 0, category = 0, isopen = false}
	player.hl.cooking = false
	player.hl.noshoot = true
	player.pickuphistory = {index = 1}
	player.hl1deadtimer = 0
	player.hl.flashlightbattery = MAX_BATTERY

	local function pick(saved_val, default_val)
		return saved_val ~= nil and saved_val or default_val
	end

	-- preset defaults for each mode
	local invPresets = {
		empty = {
			ammo     = { ammo_melee = -1, ammo_none = -1 },
			clips    = {},
			weapons  = {},
			suit     = false,
			twoxammo = false,
			curwep   = "weapon_crowbar",
		},
		doom = {
			useinvbackups = true,
			ammo     = { ammo_9mm = 68, ammo_melee = -1, ammo_none = -1 },
			clips    = { weapon_9mmhandgun = { primary = 17, secondary = -1 } },
			weapons  = { weapon_crowbar = true, weapon_9mmhandgun = true },
			suit     = true,
			twoxammo = false,
			curwep   = "weapon_9mmhandgun",
		},
		campaign = {
			useinvbackups = true,
			ammo     = {
				ammo_9mm     = 68,
				ammo_357     = 36,
				ammo_buckshot= 125,
				ammo_bolt    = 50,
				ammo_grenade = 10,
				ammo_satchel = 5,
				ammo_tripmine= 5,
				ammo_melee   = -1,
				ammo_none    = -1,
			},
			clips    = {},
			weapons  = {
				weapon_crowbar      = true,
				weapon_9mmhandgun   = true,
				weapon_357          = true,
				weapon_mp5          = true,
				weapon_shotgun      = true,
				weapon_crossbow     = true,
				weapon_rpg          = true,
				weapon_handgrenade  = true,
				weapon_satchel      = true,
			},
			suit     = true,
			twoxammo = false,
			curwep   = "weapon_crowbar",
		},
		deathmatch = {
			ammo     = { ammo_9mm = 68, ammo_melee = -1, ammo_none = -1 },
			clips    = {},
			weapons  = { weapon_crowbar = true, weapon_9mmhandgun = true },
			suit     = true,
			twoxammo = false,
			curwep   = "weapon_9mmhandgun",
		},
		rsrdeathmatch = {
			ammo     = { ammo_9mm = 68, ammo_melee = -1, ammo_none = -1 },
			clips    = {},
			weapons  = { weapon_crowbar = true, weapon_9mmhandgun = true, weapon_357 = true, weapon_mp5 = true, weapon_shotgun = true, weapon_crossbow = true, weapon_handgrenade = true, weapon_satchel = true },
			suit     = true,
			twoxammo = false,
			curwep   = "weapon_9mmhandgun",
		},
	}

	-- pick which preset we need
	local mode
	if mapheaderinfo[gamemap].startempty then
		mode = "empty"
	elseif TOL_DOOM and (maptol & TOL_DOOM) then
		mode = "doom"
	elseif not cv_deathmatch.value then
		mode = "campaign"
	elseif HL_IsRSRGametype() then
		mode = "rsrdeathmatch"
	else
		mode = "deathmatch"
	end

	local preset = invPresets[mode]
	local saved  = player.hl.laststate

	local function shouldSave(player)
		return player.mo.skin == "kombifreeman" and preset.useinvbackups and saved and saved.preset == player.hl.preset
	end

	local function choose(field)
		if shouldSave(player) and saved[field] ~= nil then
			return saved[field]
		end
		return preset[field]
	end

	-- now do the assignments in one place
	player.hl.preset = mode
	local shouldDoSavedText = (player.hl.laststate and player.hl.laststate.map != gamemap) and (saved.preset == player.hl.preset)
	player.hlinv.ammo        = choose("ammo")
	player.hlinv.wepclips    = choose("clips")
	player.hlinv.weapons     = choose("weapons")
	player.hlinv.hevsuit     = choose("suit")
	player.hl.curwep         = choose("curwep")
	player.hl1doubleammo     = choose("twoxammo")
	player.hlinv.longjump    = choose("longjump")
	player.hl.rsr = $ or {}
	player.hl.rsr.railring = 0

	if not (player.hl.curwep and player.hlinv.wepclips[player.hl.curwep]) then
		local clipsize = HLItems[player.hl.curwep].primary and HLItems[player.hl.curwep].primary.clipsize or -1
		local clipsize2 = HLItems[player.hl.curwep].secondary and HLItems[player.hl.curwep].secondary.clipsize or -1
		player.hlinv.wepclips[player.hl.curwep] = {primary = clipsize, secondary = clipsize2}
	end
	HL_ChangeViewmodelState(player, "ready", "idle")
	if cv_ljmspawn.value then
		HL_ApplyPickupStats(player, {longjump = true})
	end
	if shouldSave(player) then
		HL_InitHealth(player.mo,
			{cur = player.hl.laststate and player.hl.laststate.health or 100, max = player.hl.laststate and player.hl.laststate.mhealth or 100},
			{cur = player.hl.laststate and player.hl.laststate.armor or 0, max = player.hl.laststate and player.hl.laststate.marmor or 100}
		)

		if not multiplayer and player.hl.laststate and player.hl.laststate.map == gamemap then
			P_SetOrigin(player.mo, player.hl.laststate.pos.x, player.hl.laststate.pos.y, player.hl.laststate.pos.z)
			player.mo.momx = player.hl.laststate.momentum.x
			player.mo.momy = player.hl.laststate.momentum.y
			player.mo.momz = player.hl.laststate.momentum.z
		end
	end
	saveStatus(player) -- for some fuckass reason I have to save this again RIGHT after the player spawns because srb2 CAN'T comprehend not having variables not be a live reference to eachother

	player.hl.messages = $ or {}
	if shouldDoSavedText then
		table.insert(player.hl.messages, convertToHLMessage(player, "GAMESAVED"))
	end
end)

addHook("PlayerSpawn",function(player)
	if player != consoleplayer then return end
	doConfigShit(player)
	if not player.hl or not player.hl.config or not player.hl.config.fangnag then
		table.insert(player.hl.messages, convertToHLMessage(player, "CCHARNAG"))
	end
end)

addHook("PlayerCanEnterSpinGaps", function(player)
	if not player.mo then return end
	return HL_IsCrouching(player)
end)

addHook("PlayerHeight", function(player)
	if player.mo.skin != "kombifreeman" then return end
	return HL_IsCrouching(player) and P_GetPlayerSpinHeight(player) or P_GetPlayerHeight(player)
end)

local CROUCH_TRANS_TIME = TICRATE * 4 / 10

local function HL_IsPhysDisabled(player)
	return player.hl.nophys or player.hl.nofalldmg or player.hl.nograv
end

addHook("PlayerThink", function(player)
    if not player.mo then return end

	if TOL_DOOM and (maptol & TOL_DOOM) then
		player.height = 56*FRACUNIT
		player.spinheight = player.height/2
		player.hl.heightadjust = true
	elseif player.hl.heightadjust then
		player.height = skins["kombifreeman"].height
		player.spinheight = skins["kombifreeman"].spinheight
	end

	local function shouldSave(player)
		if player.exiting >= 100 then return true end
		if doom and doom.intermission then
			if (player.doom.intpause >= TICRATE - 1 and player.doom.intstate == 1) then
				return true
			end
		end
		return false
	end

	if shouldSave(player) then
		saveStatus(player)
	end
	
	if player.hl.laststarpost == nil then
		player.hl.laststarpost = player.starpostnum
	end

	if player.hl.laststarpost != player.starpostnum then
		saveStatus(player)
		table.insert(player.hl.messages, convertToHLMessage(player, "GAMESAVED"))
		player.hl.laststarpost = player.starpostnum
	end

    if player.mo.skin ~= skin then return end
    player.hl = player.hl or {}

	if player.hl.zoomed then
		player.fovadd = $ - 40 * FRACUNIT
	end

    -- get target heights
    local normalH = P_GetPlayerHeight(player)
    local crouchH = P_GetPlayerSpinHeight(player)
    local targetCrouch = HL_IsCrouching(player)

    -- init timer if starting a new crouch/stand
    if targetCrouch and not player.hl.wasCrouching then
        player.hl.crouchTimer = 0
    elseif not targetCrouch and player.hl.wasCrouching then
        player.hl.crouchTimer = CROUCH_TRANS_TIME
    end

    -- advance or rewind the timer
    if targetCrouch and player.hl.crouchTimer < CROUCH_TRANS_TIME then
        player.hl.crouchTimer = player.hl.crouchTimer + 1
    elseif not targetCrouch and (player.hl.crouchTimer or 0) > 0 then
		if player.hl.crouchTimer > CROUCH_TRANS_TIME / 2 then
			player.hl.crouchTimer = CROUCH_TRANS_TIME / 2
		end
        player.hl.crouchTimer = player.hl.crouchTimer - 1
    end

    -- compute interpolated height
    local h = ease.linear(
        FixedDiv((player.hl.crouchTimer or 0), CROUCH_TRANS_TIME), 
        normalH, 
        crouchH
    )

	local delta = abs(normalH - crouchH)

	if not player.hl.ignorecrouchclock then
		if player.hl.crouchTimer == 1 and targetCrouch then
			-- just began crouching
			if not P_IsObjectOnGround(player.mo) and (player.mo.eflags & MFE_JUSTHITFLOOR) == 0 then
				player.mo.z = $ + (delta / 2) * P_MobjFlip(player.mo)
			end
		elseif player.hl.crouchTimer == (CROUCH_TRANS_TIME / 2) - 1 and not targetCrouch then
			-- just began uncrouching
			if not P_IsObjectOnGround(player.mo) and (player.mo.eflags & MFE_JUSTHITFLOOR) == 0 then
				player.mo.z = $ - (delta / 2) * P_MobjFlip(player.mo)
			end
		end
	end

    -- apply the new height & viewheight
    -- player.hl.height    = h
    player.viewheight   = h - 8*FRACUNIT

    -- adjust speed
    player.normalspeed = skins[player.realmo.skin].normalspeed
    if player.hlcmds and player.hlcmds.speed then
        player.normalspeed = FixedMul($, FRACUNIT*5/8)
    end
    if targetCrouch then
        player.cmd.forwardmove = $ / 3
        player.cmd.sidemove = $ / 3
    end

    -- animations
    local moving = abs(player.mo.momx) > 0 or abs(player.mo.momy) > 0
	if P_IsObjectOnGround(player.mo) and not player.hl.ignorecrouchclock then
		if targetCrouch then
			-- crouched
			if moving then
				if player.realmo.state != S_PLAY_FREEMCROUCHMOVE then
					player.realmo.state = S_PLAY_FREEMCROUCHMOVE
				end
			else
				if player.realmo.state != S_PLAY_FREEMCROUCH then
					player.realmo.state = S_PLAY_FREEMCROUCH
				end
			end
		elseif player.hl.crouchTimer == (CROUCH_TRANS_TIME / 2) - 1 then
			-- standing
			player.realmo.state = S_PLAY_STND
		end
	end

    -- remember for next tick
    player.hl.wasCrouching = targetCrouch
    player.prevpos = { x = player.mo.x, y = player.mo.y }

	-- Flashlight thinker
	if player.hl.flashlightbattery <= 0 then
		player.hl.flashlight = false
		S_StartSound(player.mo, sfx_hlflas)
	end

	if player.hl.flashlight then
		if player.hl.flashlightbeam and player.hl.flashlightbeam.valid then
			player.hl.flashlightbeam.flags2 = $&~MF2_DONTDRAW
		end
		player.hl.flashlightbattery = player.hl.flashlightbattery - DRAIN_RATE
		P_SpawnPlayerMissile(player.mo, MT_HLFLASHLIGHTBEAM)
		if player.hl.flashlightbattery < 0 then
			player.hl.flashlightbattery = 0
		end
	else
		if player.hl.flashlightbeam and player.hl.flashlightbeam.valid then
			player.hl.flashlightbeam.flags2 = $|MF2_DONTDRAW
		end
		if player.hl.flashlightbattery < MAX_BATTERY then
			player.hl.flashlightbattery = player.hl.flashlightbattery + RECHARGE_RATE
			if player.hl.flashlightbattery > MAX_BATTERY then
				player.hl.flashlightbattery = MAX_BATTERY
			end
		end
	end

	-- Disable falling damage under these conditions (maybe because of script breaks, or is unplayable otherwise)
	-- Functionally different from nofalldmgmaps, as this is checked for no matter what map we're on (so we don't have to add every map in existence)
	if player.powers[pw_carry] == CR_MACESPIN then
		player.hl = $ or {}
		player.hl.nophys = true
		player.hl.nofalldmg = true
		player.hl.nograv = true
	end

	if (player.mo.eflags & MFE_SPRUNG) then
		player.hl = $ or {}
		player.hl.nograv = true
	end

	-- ...But clear the associated variables when we don't need them anymore.
	if player.hl and HL_IsPhysDisabled(player) and P_IsObjectOnGround(player.mo) then
		player.hl = $ or {}
		player.hl.nophys = false
		player.hl.nofalldmg = false
		player.hl.nograv = false
	end
	
	if player.hl.spraydelay then player.hl.spraydelay = $ - 1 end
	if player.mo.sprite2 != SPR2_STND then return end
	player.mo.tics = 105
end)

addHook("PlayerThink", function(player)
	local history = player.pickuphistory or {}
	local dmgicons = player.hl and player.hl.dmgicons or {}

	-- decrement timers and remove expired entries
	for id, info in pairs(history) do
		if id == "index" then continue end
		if type(info) != "table" or not info.time or info.time <= 0 then
			history[id] = nil
		else
			info.time = $ - 1
		end
	end

	for id, info in pairs(dmgicons) do
		if type(info) != "table" or not info.time or info.time <= 0 then
			dmgicons[id] = nil
		else
			info.time = $ - 1
		end
	end

	player.hl = $ or {}

	player.hl.messages = $ or {}
	local messages = player.hl.messages

	for i, msg in ipairs(messages) do
		msg.clock = $ + 1
		if msg.clock > msg.disappear_time then
			messages[i] = nil
		end
	end
end)

local function printTable(data, prefix)
	prefix = prefix or ""
	if type(data) == "table"
		if data == {} then
			print("[Empty table]")
		else
			for k, v in pairs(data or {}) do
				local key = prefix .. k
				if type(v) == "table" then
					print("key " .. key .. " = a table:")
					printTable(v, key .. ".")
				else
					print("key " .. key .. " = " .. tostring(v))
				end
			end
		end
	else
		print(data)
	end
end

addHook("PlayerThink", function(player)
	if not player.mo return end
	if player.mo.skin != skin then return end

	-- Add Silverhorn title message after regaining control
	if mapheaderinfo[gamemap].mindscape
	and MindscapeSessionFlags
	and (MindscapeSessionFlags & MS_SEENINTRO)
	and not player.hl.silverhorn_title_shown
	then
		player.hl.silverhorn_title_shown = true
		table.insert(messages, convertToHLMessage(player, "SILVERHORNTITLE"))
	end
end)

local function hasUsableWeapons(sel)
	return getFirstUsableIndex(sel) ~= nil
end

addHook("PlayerThink", function(player)
    if not player.mo then return end
	if player.mo.skin != skin then return end

    -- Selection via BT_WEAPONNEXT/PREV
    if not player.kombipressingselkeys then
        if player.cmd.buttons & BT_WEAPONNEXT then
            HL_CycleWeapon(player, "prev")
            player.kombipressingselkeys = true
        elseif player.cmd.buttons & BT_WEAPONPREV then
            HL_CycleWeapon(player, "next")
            player.kombipressingselkeys = true
        end
    else
        player.kombipressingselkeys = false
    end

    -- Selection via slot keys
    local slotKey = player.desiredSlot
    local mask = player.cmd.buttons & BT_WEAPONMASK
    if mask ~= 0 then
        slotKey = mask
    end

    if slotKey ~= nil and not player.kombipressingwpnkeys then
        -- remember if this really is the “first open”
        local firstOpen = not player.hl.wepmenu.isopen

        local prevCat = player.hl.wepmenu.category or -1
        local newCat  = slotKey
        player.kombiprevhl1category = prevCat
        player.hl.wepmenu.category     = newCat

        -- get the new selection list
        local sel = HL_GetWeapons(HLItems, newCat, player) or emptySelection()
        player.selectionlist = sel

        if sel.weaponcount > 0 and hasUsableWeapons(sel) then
            if firstOpen then
                -- on first open always pick the first slot
                player.hl.wepmenu.index = 1
            else
                -- same-category wrap or new-category default
                if newCat ~= prevCat then
                    player.hl.wepmenu.index = getFirstUsableIndex(sel) or 0
                else
                    local cur = player.hl.wepmenu.index or 1
                    player.hl.wepmenu.index = cycleWithinCategoryWrap(sel, cur, 1) or cur
                end
            end
        else
            player.hl.wepmenu.index = 0
        end

        -- play sound, mark state
        player.hl.wepmenu.isopen = true
        S_StartSound(player.mo,
            (newCat ~= prevCat or firstOpen)
              and sfx_pwepst or sfx_pwepsl
        )
        player.kombipressingwpnkeys = true
        player.desiredSlot = nil
    elseif player.kombipressingwpnkeys then
        player.kombipressingwpnkeys = false
    end

	if player.powers[pw_shield] != player.hl.oldshield and player.powers[pw_shield] != 0 then
		if (player.mo.hl.armor < player.mo.hl.maxarmor) then
			local amount = 20
			if (player.powers[pw_shield] == SH_PINK) then
				amount = 25
			elseif (player.powers[pw_shield] == SH_PITY) then
				amount = 15
			elseif (player.powers[pw_shield] == SH_WHIRLWIND) then
				amount = 25
			elseif (player.powers[pw_shield] == SH_ARMAGEDDON) then
				amount = 30
			elseif (player.powers[pw_shield] == SH_ELEMENTAL) then
				amount = 18
			elseif (player.powers[pw_shield] == SH_ATTRACT) then
				amount = 10
			elseif (player.powers[pw_shield] == SH_FLAMEAURA) then
				amount = 35
			elseif (player.powers[pw_shield] == SH_BUBBLEWRAP) then
				amount = 28
			elseif (player.powers[pw_shield] == SH_THUNDERCOIN) then
				amount = 40
			end

			if (player.powers[pw_shield] & SH_FORCE) then
				amount = amount + (5 * ((player.powers[pw_shield] & SH_FORCEHP) + 1))
			end
			if (player.powers[pw_shield] & SH_FIREFLOWER) then
				amount = amount + 10
			end

			player.mo.hl.armor = min(player.mo.hl.armor + (amount * FRACUNIT), player.mo.hl.maxarmor)
		end
	end

	if player.rings != player.hl.oldrings and player.rings > (player.hl.oldrings or 0) then
		player.hl.partialhealth = ($ or 0) + (player.rings - (player.hl.oldrings or 0))
	end

	while (player.hl.partialhealth or 0) >= 2 do
		if player.mo.hl.health < player.mo.hl.maxhealth then
			player.mo.hl.health = min($ + 1, player.mo.hl.maxhealth)
		end
		player.hl.partialhealth = $ - 2
	end

	player.hl.oldshield = player.powers[pw_shield]
	player.hl.oldrings = player.rings
end)

local function HL_GetDamage(inf)
    -- Warn and seed a default entry if we have no stats for this aggressor
    if not HL1_DMGStats[inf.type] then
        print("DMGStats out of date. Rebuilding...")
        HL1_DMGStats[inf.type] = { damage = { dmg = 15 } }
    end

	if not HL1_DMGStats[inf.type] then return end
	local dmgstats = HL1_DMGStats[inf.type]
	local objdamage = dmgstats and dmgstats.damage or {}

	if objdamage.min and objdamage.max then
		local max = objdamage.max
		local min = objdamage.min
		local increment = objdamage.increments
		local divisor = increment or min
		return (P_RandomByte() % (max / divisor) + 1) * divisor
	else
		return objdamage.dmg
	end
end

local damageTypeMaps = {
	[DMG_CRUSHED] = HL.DMG.CRUSH|HL.DMG.TIMEBASED,
	[DMG_ELECTRIC] = HL.DMG.SHOCK|HL.DMG.TIMEBASED,
	[DMG_NUKE] = HL.DMG.BLAST|HL.DMG.TIMEBASED,
	[DMG_FIRE] = HL.DMG.BURN|HL.DMG.TIMEBASED,
	[DMG_DROWNED] = HL.DMG.DROWN|HL.DMG.TIMEBASED,
	[DMG_SPACEDROWN] = HL.DMG.DROWN|HL.DMG.TIMEBASED,
	[DMG_WATER] = HL.DMG.DROWN|HL.DMG.TIMEBASED,
	[DMG_SPIKE] = HL.DMG.SLASH,
	[DMG_DEATHPIT] = HL.DMG.FALL|HL.DMG.TIMEBASED,
}

local SUIT_NEXT_IN_30SEC = function(line, player)
	player.hl.suitvoicewait[line] = 30*TICRATE
end

local SUIT_NEXT_IN_1MIN = function(line, player)
	player.hl.suitvoicewait[line] = 1*TICRATE*60
end

local SUIT_NEXT_IN_5MIN = function(line, player)
	player.hl.suitvoicewait[line] = 5*TICRATE*60
end

local SUIT_NEXT_IN_10MIN = function(line, player)
	player.hl.suitvoicewait[line] = 10*TICRATE*60
end

local SUIT_NEXT_IN_30MIN = function(line, player)
	player.hl.suitvoicewait[line] = 30*TICRATE*60
end

local function DoDamageAndBursts(target, inf, damage, damagetype, noInvuln)
	local prevHealth = target.hl.health
    local kill = HL_DamageGordon(target, inf, damage, damagetype)

    -- On kill, burst emeralds/weapons/flags
    if kill then
        P_PlayerEmeraldBurst(target.player, false)
        P_PlayerWeaponAmmoBurst(target.player)
        P_PlayerFlagBurst(target.player, false)
    else
        -- compute trivial/major/critical on *post*-damage health
        local curHealth = target.hl.health
        local isTrivial = curHealth > 75 or damage < 5
        local isMajor   = damage > 25
        local isCritical= curHealth < 30

        -- save damage bits for HUD
        target.player.hl.bitsDamageType = damagetype
        target.player.hl.bitsHUDDamage  = -1

        -- iterate through each damage type
        local bits = damagetype
        local didOne = true
        while bits ~= 0
          and (not isTrivial or (bits & HL.DMG.TIMEBASED) ~= 0)
          and didOne
        do
            didOne = false

            if (bits & HL.DMG.CLUB) ~= 0 then
                if isMajor then
                    FVox_WarnDamage("HEV_DMG4", target.player, SUIT_NEXT_IN_30SEC)  -- minor fracture
                end
                bits = bits & ~HL.DMG.CLUB
                didOne = true
            end

            if (bits & (HL.DMG.FALL | HL.DMG.CRUSH)) ~= 0 then
                if isMajor then
                    FVox_WarnDamage("HEV_DMG5", target.player, SUIT_NEXT_IN_30SEC)  -- major fracture
                else
                    FVox_WarnDamage("HEV_DMG4", target.player, SUIT_NEXT_IN_30SEC)  -- minor fracture
                end
                bits = bits & ~(HL.DMG.FALL | HL.DMG.CRUSH)
                didOne = true
            end

            if (bits & HL.DMG.BULLET) ~= 0 then
                if damage > 5 then
                    FVox_WarnDamage("HEV_DMG6", target.player, SUIT_NEXT_IN_30SEC)  -- blood loss detected
                end
                bits = bits & ~HL.DMG.BULLET
                didOne = true
            end

            if (bits & HL.DMG.SLASH) ~= 0 then
                if isMajor then
                    FVox_WarnDamage("HEV_DMG1", target.player, SUIT_NEXT_IN_30SEC)  -- major laceration
                else
                    FVox_WarnDamage("HEV_DMG0", target.player, SUIT_NEXT_IN_30SEC)  -- minor laceration
                end
                bits = bits & ~HL.DMG.SLASH
                didOne = true
            end

            if (bits & HL.DMG.SONIC) ~= 0 then
                if isMajor then
                    FVox_WarnDamage("HEV_DMG2", target.player, SUIT_NEXT_IN_1MIN)   -- internal bleeding
                end
                bits = bits & ~HL.DMG.SONIC
                didOne = true
            end

            if (bits & (HL.DMG.POISON | HL.DMG.PARALYZE)) ~= 0 then
                FVox_WarnDamage("HEV_DMG3", target.player, SUIT_NEXT_IN_1MIN)      -- blood toxins detected
                bits = bits & ~(HL.DMG.POISON | HL.DMG.PARALYZE)
                didOne = true
            end

            if (bits & HL.DMG.ACID) ~= 0 then
                FVox_WarnDamage("HEV_DET1", target.player, SUIT_NEXT_IN_1MIN)     -- hazardous chemicals detected
                bits = bits & ~HL.DMG.ACID
                didOne = true
            end

            if (bits & HL.DMG.NERVEGAS) ~= 0 then
                FVox_WarnDamage("HEV_DET0", target.player, SUIT_NEXT_IN_1MIN)     -- biohazard detected
                bits = bits & ~HL.DMG.NERVEGAS
                didOne = true
            end

            if (bits & HL.DMG.RADIATION) ~= 0 then
                FVox_WarnDamage("HEV_DET2", target.player, SUIT_NEXT_IN_1MIN)     -- radiation detected
                bits = bits & ~HL.DMG.RADIATION
                didOne = true
            end

            if (bits & HL.DMG.SHOCK) ~= 0 then
                FVox_WarnDamage("HEV_SHOCK", target.player, SUIT_NEXT_IN_30SEC)
                bits = bits & ~HL.DMG.SHOCK
                didOne = true
            end

            if (bits & HL.DMG.BURN) ~= 0 then
                FVox_WarnDamage("HEV_FIRE", target.player, SUIT_NEXT_IN_30SEC)
                bits = bits & ~HL.DMG.BURN
                didOne = true
            end
        end

        -- view punch
        target.player.hl.punchangle = target.player.hl.punchangle or {}
        target.player.hl.punchangle.x = -2

        -- first time we take major damage
        if not isTrivial and isMajor and prevHealth >= 75 then
            FVox_WarnDamage("HEV_MED1", target.player, SUIT_NEXT_IN_30MIN)   -- automedic on
            FVox_WarnDamage("HEV_HEAL7", target.player, SUIT_NEXT_IN_30MIN)  -- morphine shot
        end

        -- escalating into critical
        if not isTrivial and isCritical and prevHealth < 75 then
            if curHealth < 6 then
                FVox_WarnDamage("HEV_HLTH3", target.player, SUIT_NEXT_IN_10MIN)  -- near death
            elseif curHealth < 20 then
                FVox_WarnDamage("HEV_HLTH2", target.player, SUIT_NEXT_IN_10MIN)  -- health critical
            end

            if (P_RandomRange(0,3) == 0) and prevHealth < 50 then
                FVox_WarnDamage("HEV_DMG7", target.player, SUIT_NEXT_IN_5MIN)     -- seek medical attention
            end
        end

        -- time‑based damage warnings
        if (damagetype & HL.DMG.TIMEBASED) ~= 0 and prevHealth < 75 then
            if prevHealth < 50 then
                if P_RandomRange(0,3) == 0 then
                    FVox_WarnDamage("HEV_DMG7", target.player, SUIT_NEXT_IN_5MIN) -- seek medical attention
                end
            else
                FVox_WarnDamage("HEV_HLTH1", target.player, SUIT_NEXT_IN_10MIN)   -- health dropping
            end
        end
    end

    -- Give invuln if this wasn't from another Freeman
	local stats = HL1_DMGStats[inf and inf.valid and inf.type] or {}
    if (damagetype & HL.DMG.TIMEBASED) or not (inf and inf.valid and (inf.stats or (inf.hl and inf.hl.dontdoinvuln) or (inf.target and inf.target.skin == "doomguy")))
	and not (stats.noflashing or noInvuln) then
        target.player.powers[pw_flashing] = 18
    end

    return kill
end

addHook("MobjDamage", function(target, inf, src, dmg, dmgType)
    if target.skin ~= "kombifreeman" then
        return
    end

	if target.player.powers[pw_shield] then
		P_RemoveShield(target.player)
		return true
	end

    -- world damage (no inf, no src)
    if not inf and not src then
        local baseDamage = ((dmgType and not damageTypeMaps[dmgType]) and dmg) or 15
        local baseType     = damageTypeMaps[dmgType & ~DMG_CANHURTSELF] or damageTypeMaps[dmgType] or dmgType
		S_StartSound(target, P_RandomRange(sfx_frpai1, sfx_frpai5))
        DoDamageAndBursts(target, nil, baseDamage, baseType)
        return true
    end

	if (HL.DoTDForestAccomodations and inf.type == MT_TAILSDOLL) then
		target.player.rings = $ + 1
	end

    -- damage from a valid source
    if not (src and src.valid) then
        return true
    end

    -- Figure out which mobj should count as the “inflictor”
    local stats     = HL1_DMGStats[src.type]
    local chosenInf = (stats and stats.damage and stats.damage.preferaggressor) and src or inf

    -- Play hurt sound
    S_StartSound(target, P_RandomRange(sfx_frpai1, sfx_frpai5))

    -- If inf is nil after choosing, bail out (no further stats)
    if not chosenInf then
        return true
    end

    -- Determine damage and damage type
	local targetIsDoomguy = chosenInf.target and chosenInf.target.skin == "doomguy"

	-- Final damage resolution:
	local finalDamage
	local dontDoInvuln

    if targetIsDoomguy then
        -- Doomguy override: always use the raw damage from the inflictor
        finalDamage = chosenInf.damage
        finalType = (HL1_DMGStats[chosenInf.type] and HL1_DMGStats[chosenInf.type].damagetype) or dmgType
    elseif RSR and RSR.GamemodeActive() then
		-- RSR Damage override: Lazycopy Ringslinger Revolution v2.0's code
		-- There's literally no good reason to make us have to do this, it could easily become outdated
		local infInfo = RSR.MOBJ_INFO and RSR.MOBJ_INFO[chosenInf.type]
		dontDoInvuln = true

		-- Projectiles registered with RSR
		if chosenInf.rsrProjectile then
			-- ProjectileMoveCollide normally sets rsrDamage already.
			if not chosenInf.rsrDamage then
				-- fall back to its mobj info if present, else keep nil
				finalDamage = (chosenInf.info and chosenInf.info.damage) or finalDamage
			else
				finalDamage = chosenInf.rsrDamage
			end
		-- Player as inflictor (melee, Armageddon special-case)
		elseif Valid(chosenInf.player) then
			dontDoInvuln = false
			if dmgType == DMG_NUKE and RSR.GetArmageddonDamage then
				finalDamage = RSR.GetArmageddonDamage(target, chosenInf)
			else
				-- melee hit from a player: use direct damage value
				finalDamage = dmg
			end
		-- Other things (enemies/environment)
		elseif not chosenInf.rsrRealDamage then
			if infInfo and infInfo.damage ~= nil then
				finalDamage = infInfo.damage
			else
				finalDamage = (dmg > 1 and dmg or HL_GetDamage(chosenInf)) or 1
			end
		end
    elseif dmg and dmg > 1 then
        -- Explicit dmg override if greater than default (1)
        finalDamage = dmg
    elseif not chosenInf.ignoredamagedef then
        -- Use HL1-defined damage if allowed
        finalDamage = HL_GetDamage(chosenInf)
    end

    if finalDamage == nil then
        finalDamage = 0
    end

	-- Pick damage type from stats or fallback to hardcoded damage map
	local finalType =
		(HL1_DMGStats[chosenInf.type] and HL1_DMGStats[chosenInf.type].damagetype)
		or damageTypeMaps[dmgType & ~DMG_CANHURTSELF]
		or dmgType

    target.player.timeshit = target.player.timeshit + 1

    -- Finally, do the damage and bursts
    DoDamageAndBursts(target, chosenInf, finalDamage, finalType, dontDoInvuln)
    return true

end, MT_PLAYER)

-- Helper to extract the numeric suffix from a sentinel string, e.g. "CROWBAR_SWING_1" => 1
local function getSentinelNumber(s)
	local num = s:match("(%d+)$")
	return tonumber(num) or 0
end

-- Set of functions to handle the 16-bit varient of angle_t (which usually takes up the whole 32-bit range)
local FULL_CIRCLE = ANGLE_MAX  >> 16
local HALF_CIRCLE = FULL_CIRCLE / 2

local function SignedAngle16(a)
    -- convert unsigned [0 … 65535] into signed [–32768 … +32767]
    if a >= HALF_CIRCLE then
        return a - FULL_CIRCLE
    else
        return a
    end
end

local function UnsignedAngle16(a)
    if a < 0 then
        return a + FULL_CIRCLE
    else
        return a
    end
end

addHook("PlayerThink", function(player)
    if not player.mo or player.mo.skin ~= skin then return end

    -- Decay HL1-style punch angle (viewkick)
    if player.hl.punchangle then
        local punch = player.hl.punchangle

        -- Turn vector into "true-value"
		local x = SignedAngle16(punch.x or 0)
		local y = SignedAngle16(punch.y or 0)
		local z = SignedAngle16(punch.z or 0)
        -- Compute magnitude len = sqrt(x^2 + y^2 + z^2)
        local len = FixedHypot(FixedHypot(x, y), z)
        if len > 0 then
            -- Normalize: nx,ny,nz are unit‐length in fixed
            local nx = FixedDiv(x, len)
            local ny = FixedDiv(y, len)
            local nz = FixedDiv(z, len)

            -- Decay factor: (10.0 + len*0.5) * frametime
            --   -> (10*FRACUNIT + (len/2)) * (FRACUNIT/TICRATE)
            local baseDecay   = ((10 * ANG1) >> 16)
            local variablePart = FixedDiv(len, 2*FRACUNIT)    -- len * 0.5
            local decayPerSec  = baseDecay + variablePart
            local frametimeFP  = FRACUNIT/TICRATE  -- = FRACUNIT*(1/35)
            local decay        = FixedMul(decayPerSec, frametimeFP)

            -- Subtract and clamp
            len = len - decay
            if len < 0 then len = 0 end

            -- Re‑scale punch vector
            punch.x = UnsignedAngle16(FixedMul(nx, len))
            punch.y = UnsignedAngle16(FixedMul(ny, len))
            punch.z = UnsignedAngle16(FixedMul(nz, len))
        end
    end

    -- Increment Damage Tics Clock
    player.hl1damagetics = (player.hl1damagetics or 0) + 1
end)

local function contains(mainStr, subStr)
	return string.find(mainStr, subStr) ~= nil
end

local function isOurPlayer(player)
    return player.mo and player.mo.skin == skin
end

local function normalizeFrameDurations(sparse)
    -- 1) collect and sort all defined frames
    local keys = {}
    for frameIdx in pairs(sparse) do
        table.insert(keys, frameIdx)
    end
    table.sort(keys)

    -- 2) find the max frame we need to fill
    local maxFrame = keys[#keys]

    -- 3) walk from 1..maxFrame, carrying the last known duration
    local dense = {}
    local lastDuration = sparse[keys[1]]
    for i = 1, maxFrame do
        if sparse[i] then
            lastDuration = sparse[i]
        end
        dense[i] = lastDuration
    end

    return dense
end

-- Advance the viewmodel animation by one tick.
local function tickViewmodel(player)
    local anim = player.hl1currentAnimation
    if not anim then
        return HL_ChangeViewmodelState(player, "idle", "idle")
    end

	if not anim.denseDurations then
        anim.denseDurations = normalizeFrameDurations(anim.frameDurations or { [1]=1 })
    end

    -- frame clock
    if player.hl1frameclock > 1 then
		player.hl1frameclock = $ - 1
        return
    end

    -- next frame
    player.hl1frame = player.hl1frame + 1
    local s = anim.frameSounds and anim.frameSounds[player.hl1frame]
    if s then
        if type(s) == "table" then
            S_StartSound(player.mo, s.sound + P_RandomRange(0, s.sounds-1))
        else
            S_StartSound(player.mo, s)
        end
    end

    -- determine last frame number
    local maxFrame = 0
    for idx in pairs(anim.frameDurations) do
        if idx > maxFrame then maxFrame = idx end
    end

    if player.hl1frame > maxFrame then
        if anim.loop then
            player.hl1frame = 1
            player.hl1frameclock = anim.denseDurations[1] or 1
        elseif anim.next then
            return HL_ChangeViewmodelState(player, anim.next, anim.next)
        else
            return HL_ChangeViewmodelState(player, "idle", "idle")
        end
    else
        -- set clock for the current frame
        local dur = anim.denseDurations[player.hl1frame] or 1
		if HL_IsRSRGametype()
			and player.rsrinfo
			and RSR.HasPowerup(player, RSR.POWERUP_SPEED) then
			dur = $ / 2
		end
        player.hl1frameclock = dur
    end
end

local function tryStartReload(player)
    local stats = HLItems[player.hl.curwep]
    local primary = stats.primary or HLItems["9mmhandgun"].primary
    local clips = player.hlinv.wepclips[player.hl.curwep]
    local viewAction = player.hl1viewmdaction or ""
	local needReload

	if clips.primary != nil and primary.clipsize != nil then
		needReload = clips.primary < primary.clipsize
	end
    local pressingReload = clips.primary == 0
	                     or (player.cmd.buttons & BT_CUSTOM1) ~= 0
                         or (player.hlcmds and player.hlcmds.reload)
    if needReload
	  and pressingReload
      and viewAction:find("idle")
      and not player.kombireloading
      and player.hl1weapondelay == 0
      and (player.hlinv.ammo[primary.ammo] or 0) > 0
    then
        if primary.reloadsound then
            S_StartSound(player.mo, primary.reloadsound)
        end
        player.kombireloading = true
        player.hl1weapondelay = stats.globalfiredelay.reloadstart
                             or stats.globalfiredelay.reload
        HL_ChangeViewmodelState(player, "reload start", "idle 1")
    end
end

local function doReloadTick(player)
    if not player.kombireloading or player.hl1weapondelay > 0 then
        return
    end

    local stats = HLItems[player.hl.curwep]
    local primary = stats.primary or HLItems["9mmhandgun"].primary
    local clips = player.hlinv.wepclips[player.hl.curwep]
    local ammo = player.hlinv.ammo[primary.ammo] or 0

    if primary.reloadincrement then
        -- incremental reload
        if player.hl1doreload then
            local toload = min(primary.reloadincrement,
                               primary.clipsize - clips.primary,
                               ammo)
            clips.primary = clips.primary + toload
            player.hlinv.ammo[primary.ammo] = ammo - toload
			ammo = player.hlinv.ammo[primary.ammo] or 0
        end

        if clips.primary >= primary.clipsize or ammo < 1 then
            HL_ChangeViewmodelState(player, "reload stop", "idle 1")
            player.kombireloading = false
            player.hl1doreload = nil
        else
            player.hl1weapondelay = stats.globalfiredelay.reloadloop
                                 or stats.globalfiredelay.reload
            player.hl1doreload = true
            HL_ChangeViewmodelState(player, "reload loop", "idle 1")
        end
    else
        -- one-shot reload
        local wasEmpty = clips.primary == 0
        local toload = min(primary.clipsize - clips.primary, ammo)
        clips.primary = clips.primary + toload
        player.hlinv.ammo[primary.ammo] = ammo - toload

        player.kombireloading = false
        player.hl1weapondelay = wasEmpty
          and (stats.globalfiredelay.reloadpost or 0)
          or 0
    end
end

addHook("PlayerThink", function(player)
    if not isOurPlayer(player) then return end

    -- ensure we have a clips table
    local cur = player.hl.curwep
	
	-- Quit if no weapon
	if not cur then return end
    player.hlinv.wepclips[cur] = player.hlinv.wepclips[cur]
      or { (HLItems[cur].primary or {}).clipsize or -1,
           (HLItems[cur].secondary or {}).clipsize or -1 }

    -- handle reload
    tryStartReload(player)
    doReloadTick(player)

    -- drive viewmodel animation
    tickViewmodel(player)
end)


-- Messaging
hud.add(function(v, player)
	if not myTypingMode then return end
	local prefix = myTypingMode and messagemodetxt or messagemode2txt
	v.drawString(0, 0, prefix .. (myTyping or ""), V_ORANGEMAP|V_ALLOWLOWERCASE)
end, "game")