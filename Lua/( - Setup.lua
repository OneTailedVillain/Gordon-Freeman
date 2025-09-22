-- HL_HurtMobj, HL_DamageGordon, and HL_GetDistance in WpnSetup due to SRB2 wanting to be "special."
local function SafeFreeSlot(...)
	for _,slot in ipairs({...})
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

SafeFreeSlot("sfx_hlwpnu","sfx_hdryfi","sfx_tfcrit","sfx_hldeny","sfx_hl1ljm","sfx_hlmedi","S_PLAY_LONGJUMP","S_PLAY_HLJUMP","SPR2_LJMP",
"MT_HL_HEWATCHES", "S_HL_GAYMAN", "SPR_HL1GMAN",
"sfx_hlgibd")

states[S_HL_GAYMAN] = {
	sprite = SPR_HL1GMAN,
	frame = FF_ANIMATE|A,
	tics = -1,
	var1 = 17,
	var2 = 5,
	nextstate = S_HL_GAYMAN
}
states[S_PLAY_LONGJUMP] = {
	sprite = SPR_PLAY,
	frame = FF_ANIMATE|SPR2_LJMP,
	tics = 56,
	var1 = 28,
	var2 = 2,
	nextstate = S_PLAY_FALL
}
states[S_PLAY_HLJUMP] = {
	sprite = SPR_PLAY,
	frame = FF_ANIMATE|SPR2_JUMP,
	tics = 40,
	var1 = 19,
	var2 = 2,
	nextstate = S_PLAY_FALL
}

mobjinfo[MT_HL_HEWATCHES] = {
	spawnstate = S_HL_GAYMAN,
	spawnhealth = 100,
	speed = 80*FRACUNIT,
	radius = 6*FRACUNIT,
	height = 12*FRACUNIT,
	dispoffset = 4,
}

SafeFreeSlot("SPR_HL1GIB", "S_HL_GIB", "MT_HL_GIBS")

states[S_HL_GIB] = {
	sprite = SPR_HL1GIB,
	frame = A,
	tics = -1,
	nextstate = S_HL_GIB
}

mobjinfo[MT_HL_GIBS] = {
	spawnstate = S_HL_GIB,
	spawnhealth = 100,
	speed = 80*FRACUNIT,
	radius = 6*FRACUNIT,
	height = 12*FRACUNIT,
	dispoffset = 4,
}

local function warn(player, str)
	CONS_Printf(player, "\130WARNING: \128"..str)
end

local pickupnotifytime = TICRATE*3 -- how long does each weapon notification last?

if not HL then
	rawset(_G, "HL", {})
end

HL.cacheShit = {
	patches = {},
	colormaps = {},
	weapons = {},
	items = {},
	ammos = {}
}

HL.MAX_HISTORY = 6
HL.BULLETSPEED = 8 * FRACUNIT
HL.GIB_HEALTH_VALUE	= -30
local BASE_PATH = "client/halflife/"
HL.KEYBINDS_PATH     = BASE_PATH.."keybinds.dat"
HL.SPRAY_CONFIG_PATH = BASE_PATH.."spray.cfg"
HL.CONFIG_PATH       = BASE_PATH.."config.cfg"
HL.SKILL_PATH        = BASE_PATH.."skill.cfg"
HL.killfeed = {}

HL.DMG = {
	-- Potential types of damage
	GENERIC       = 0,
	DROWN         = 1 << 0,
	BURN          = 1 << 1,
	SLASH         = 1 << 2,
	BULLET        = 1 << 3,
	FREEZE        = 1 << 4,
	FALL          = 1 << 5,
	BLAST         = 1 << 6,
	CLUB          = 1 << 7,
	SHOCK         = 1 << 8,
	SUPERSONIC    = 1 << 9,
	ENERGYBEAM    = 1 << 10,
	DIRECT        = 1 << 11,
	CRUSH         = 1 << 12,
	PARALYZE      = 1 << 13,
	NERVEGAS      = 1 << 14,
	POISON        = 1 << 15,
	RADIATION     = 1 << 16,
	DROWNRECOVER  = 1 << 17,
	ACID          = 1 << 18,
	SLOWBURN      = 1 << 19,
	REMOVEONDEATH = 1 << 20,
	PLASMA        = 1 << 21,
	ALWAYSGIB     = 1 << 6, -- same as BLAST (always gib)
	NEVERGIB	  = 1 << 22,	-- never gib, even if damage > critical threshold
	TIMEBASED     = 1 << 23,
	SONIC         = 1 << 24,
}

HL.ConvRatio = 28*FRACUNIT/320

HL.GmanSpots = {
	["gamemap 1 level greenflower zone 1"] = {
		{
			x = 6035,
			y = 7108,
			z = 1248,
			angle = {init = 180, leave = 30},
			leavedelay = TICRATE,
			leaverange = 256*FRACUNIT,
			despawncond = {passline = {{x = 7013, y = 8911}, {x = 7013, y = 4616}}}
		}
	},
	["gamemap 4 level techno hill zone 1"] = {
		{
		x = 15392,
		y = -9775,
		z = 3392,
		angle = {init = 55, leave = 270},
		leavedelay = TICRATE,
		leaverange = 256*FRACUNIT,
		spawncond = {passline = {{x = 16883, y = -6513}, {x = 0, y = -6849}}}
		}
	},
	["gamemap 5 level techno hill zone 2"] = {
		{
		x = -13641,
		y = 2755,
		z = 1920,
		angle = {init = 90},
		}
	},
	["gamemap 7 level deep sea zone 1"] = {
		{
		x = 5810,
		y = 816,
		z = 800,
		angle = {init = 215, leave = 45},
		leavedelay = TICRATE,
		leaverange = 1024*FRACUNIT,
		}
	},
	["gamemap 10 level castle eggman zone 1"] = {
		{
		x = 10700,
		y = 6049,
		z = 4096,
		angle = {init = 0, leave = 180},
		leavedelay = TICRATE*2,
		leaverange = 16384*FRACUNIT,
		}
	},
	["gamemap 11 level castle eggman zone 2"] = {
		{
		x = 1068,
		y = -18178,
		z = 1376,
		angle = {init = 195, leave = 90},
		leavedelay = TICRATE,
		leaverange = 16384*FRACUNIT,
		despawncond = {passline = {{x = 0, y = 0}, {x = 0, y = 0}}}
		}
	},
}

HL.weaponAmmoTypes = {
	[MT_RAILRING] = true,
	[MT_BOUNCERING] = true,
	[MT_SCATTERRING] = true,
	[MT_GRENADERING] = true,
	[MT_INFINITYRING] = true,
	[MT_AUTOMATICRING] = true,
	[MT_EXPLOSIONRING] = true,
}

addHook("MapLoad", function(mapid)
	HL.isDoom = TOL_DOOM and (maptol & TOL_DOOM)
	local which = "gamemap " .. tostring(mapid) .. " level " .. tostring(G_BuildMapTitle(mapid))
	which = $:lower()
	local whatspot = HL.GmanSpots[which]
	if whatspot then
		for _, spot in pairs(whatspot) do
			local gman = P_SpawnMobj(spot.x*FRACUNIT, spot.y*FRACUNIT, spot.z*FRACUNIT, MT_HL_HEWATCHES)
			gman.scale = $ / 2
			gman.angle = FixedAngle(spot.angle.init*FRACUNIT)
			gman.hl = $ or {}
			gman.hl.leaveclock = spot.leavedelay
			gman.hl.leaverange = spot.leaverange
			gman.hl.leaveangle = spot.angle.leave
		end
	end

	HL.positionMap = {}
end)

if not HL1_DMGStats rawset(_G, "HL1_DMGStats", {}) end

local function safeGetMT(mt)
	local success, value = pcall(function() return mt end)
	return success and value or nil
end

rawset(_G, "HL_SetMTStats", function(mt, wishhealth, wishdamage)
	local mobjType = type(mt) == "string" and _G[mt] or safeGetMT(mt)
	if not mobjType return end
	HL1_DMGStats[mobjType] = {health = wishhealth, damage = wishdamage}
end)

HL_SetMTStats(safeGetMT(MT_BLUECRAWLA), {health = 30}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_REDCRAWLA), {health = 45}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_GFZFISH), {health = 10}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_GOLDBUZZ), {health = 20}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_REDBUZZ), {health = 20}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_DETON), {health = 1}, {dmg = 60})
HL_SetMTStats(safeGetMT(MT_POPUPTURRET), {health = 40}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_CRAWLACOMMANDER), {health = 50}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SPRINGSHELL), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_YELLOWSHELL), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SKIM), {health = 60}, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_CRUSHSTACEAN), {health = 60}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_JETJAW), {health = 15}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BIGMINE), {health = 2}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_BANPYURA), {health = 60}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_FACESTABBER), {health = 100}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_FACESTABBERSPEAR), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_ROBOHOOD), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_EGGGUARD), {health = 10}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_GSNAPPER), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_VULTURE), {health = 40}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_POINTY), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_MINUS), {health = 16}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_CANARIVORE), {health = 25}, {dmg = 80})
HL_SetMTStats(safeGetMT(MT_UNIDUS), {health = 60}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_PYREFLY), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_PTERABYTE), {health = 60}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_DRAGONBOMBER), {health = 70}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_JETTBOMBER), {health = 50}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_JETTGUNNER), {health = 50}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SNAILER), {health = 60}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_SPINCUSHION), {health = 80}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_PENGUINATOR), {health = 40}, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_POPHAT), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_CACOLANTERN), {health = 40}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_HIVEELEMENTAL), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BUMBLEBORE), {health = 1}, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_SPINBOBERT), {health = 40}, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_HANGSTER), {health = 40}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_BUGGLE), {health = 30}, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_GOOMBA), {health = 40}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_BLUEGOOMBA), {health = 40}, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_FANG),         {health = 1}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE),      {health = 200}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE2),     {health = 400}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE3),     {health = 500}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_EGGMOBILE4),     {health = 600}, {dmg = 20})
HL_SetMTStats(safeGetMT(MT_METALSONIC_BATTLE), {health = 800}, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_CYBRAKDEMON),    {health = 900}, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_CYBRAKDEMON_ELECTRIC_BARRIER), nil, {dmg = 1000})
HL_SetMTStats(safeGetMT(MT_ROSY), {health = 30})
HL_SetMTStats(safeGetMT(MT_PLAYER), {health = 100})
--projectiles
HL_SetMTStats(safeGetMT(MT_REDRING), nil, {dmg = 6, noflashing = true})
HL_SetMTStats(safeGetMT(MT_THROWNBOUNCE), nil, {dmg = 3, noflashing = true})
HL_SetMTStats(safeGetMT(MT_THROWNAUTOMATIC), nil, {dmg = 9, noflashing = true})
HL_SetMTStats(safeGetMT(MT_THROWNSCATTER), nil, {dmg = 15, noflashing = true})
HL_SetMTStats(safeGetMT(MT_THROWNGRENADE), nil, {dmg = 15, noflashing = true})
HL_SetMTStats(safeGetMT(MT_THROWNEXPLOSION), nil, {dmg = 15, noflashing = true})
HL_SetMTStats(safeGetMT(MT_CORK), nil, {dmg = 10})
HL_SetMTStats(safeGetMT(MT_ROCKET), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_LASER), nil, {dmg = 30})
HL_SetMTStats(safeGetMT(MT_TORPEDO), nil, {dmg = 35})
HL_SetMTStats(safeGetMT(MT_TORPEDO2), nil, {dmg = 5})
HL_SetMTStats(safeGetMT(MT_ENERGYBALL), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_MINE), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_JETTBULLET), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_TURRETLASER), nil, {dmg = 3})
HL_SetMTStats(safeGetMT(MT_ARROW), nil, {dmg = 15})
HL_SetMTStats(safeGetMT(MT_DEMONFIRE), nil, {dmg = 25})
HL_SetMTStats(safeGetMT(MT_CANNONBALL), nil, {dmg = 40})
HL_SetMTStats(safeGetMT(MT_RING), {health = INT32_MAX}, {dmg = 40})

local function weightedRandom(chances) -- returns one random entry based on the weighted chances
	local total = 0
	for _, entry in ipairs(chances) do
		total = total + tonumber(entry.chance)
	end
	local r = P_RandomFixed() * total
	local highestChanceEntry
	for _, entry in ipairs(chances) do
		if not highestChanceEntry or entry.chance > highestChanceEntry.chance then
			highestChanceEntry = entry
		end
		r = r - tonumber(entry.chance)
		if r <= 0 then
			return entry
		end
	end
	return highestChanceEntry -- Ensures a valid return value
end

local function removeFromChanceList(chances, toremove) -- get a new weighted chance, without some specific item
	local newList = {}
	local dudChance = 0
	local otherItems = 0

	-- separate the dud and count the non-dud entries
	for _, entry in ipairs(chances) do
		if entry.name == toremove then
			dudChance = tonumber(entry.chance)
		else
			otherItems = otherItems + 1
			-- copy the entry to avoid mutating the original list
			table.insert(newList, { name = entry.name, chance = tonumber(entry.chance) })
		end
	end

	-- add an equal share of the dud's chance to every remaining weapon
	local bonus = dudChance / otherItems
	for _, entry in ipairs(newList) do
		entry.chance = entry.chance + bonus
	end

	return newList
end

rawset(_G, "HL_IsCrouching", function(player)
    -- Are we crouching (or otherwise need to crouch)?
    local mo = player.mo
    if not mo then return false end

    local normalH = P_GetPlayerHeight(player)
    local space = mo.ceilingz - mo.floorz

    -- Not enough space to stand upright
    if space < normalH then
        return true
    end

    return (player.cmd.buttons & BT_SPIN)
        or (player.hlcmds and player.hlcmds.duck)
end)

rawset(_G, "HL_GetPrefix", function(str)
	local prefix = str:match("^(.-)_")
	if prefix then
		return true, prefix .. "_"
	end
	return false
end)

rawset(_G, "HL_GetMonitorPickUps", function(chanceList, amount) -- get an amount-length list of weapons, chances determined by chanceList. Main purpose is to get pick-ups dropped by Monitors.
	local results = {}
	for i = 1, amount do
		local selected = weightedRandom(chanceList)
		if selected.name == "crowbar" then -- we got a dud!! make sure we don't rip people off by getting another weapon
			local reweightedList = removeFromChanceList(chanceList, "crowbar")
			selected = weightedRandom(reweightedList)
		end
		table.insert(results, selected)
	end
	return results
end)

local function mathyHealthCalc(mobj)
	return max(1, FixedInt(FixedSqrt(max(1, FixedDiv(FixedMul(mobj.radius * 2, mobj.height),4*FRACUNIT/3)))))
end

rawset(_G, "HL_InitHealth", function(mobj, prefhealth, prefarmor) -- Sets up mobjs.
	mobj.hl = $ or {}
	mobj.hl.health = (prefhealth and prefhealth.cur) or $ or (HL1_DMGStats[mobj.type] and HL1_DMGStats[mobj.type].health and HL1_DMGStats[mobj.type].health.health) or mathyHealthCalc(mobj)
	mobj.hl.armor = prefarmor and prefarmor.cur or 0
	mobj.hl.maxhealth = prefhealth and prefhealth.max or mobj.hl.health or 100
	mobj.hl.maxarmor = prefarmor and (prefarmor.max * FRACUNIT) or 100*FRACUNIT
end)

local function printTable(data, prefix)
	prefix = prefix or ""
	if type(data) == "table"
		if not next(data) then
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

-- Helper to extract the numeric suffix from a sentinel string, e.g. "CROWBAR_SWING_1" => 1
local function getSentinelNumber(s, player)
	if not s warn(player, "Invalid state '" .. player.hl1viewmdaction .."'!") printTable(player.hl1currentAnimation, "PRINTOUT: " .. player.hl1viewmdaction .. ".") return 1 end
	local num = s:match("(%d+)$")
	return tonumber(num) or 0
end

local function getFrameData(player, state, animations)
    -- Split the incoming state string into keys (numbers stay numbers)
    local keys = {}
    for key in state:gmatch("%S+") do
        table.insert(keys, tonumber(key) or key)
    end

    local node = animations
    local pathParts = {}   -- keep the actual key path, for debugging
    local lastValidNode, lastValidKey

    -- Traverse as far as we can
    for _, key in ipairs(keys) do
        if node and node[key] then
            lastValidNode = node
            lastValidKey  = key
            node = node[key]
            table.insert(pathParts, tostring(key))
        else
            break
        end
    end

    -- If we ended up on nil, back up one step
    if not node and lastValidNode and lastValidKey then
        node = lastValidNode[lastValidKey]
    end

    -- Build a dot-style prefix for printTable (e.g. "primaryfire.normal.")
    local prefix = (#pathParts > 0) and (table.concat(pathParts, ".") .. ".") or ""

    -- If this node has *no* numeric keys but *does* have multiple anim-tables,
    -- that means the user stopped at an ambiguous branch—dump them out:
    do
        local hasNumbered = false
        local branches = {}
        for k, v in pairs(node or {}) do
            if type(k) == "number" then
                hasNumbered = true
            elseif type(v) == "table" and v.sentinel and type(v.frameDurations) == "table" then
                table.insert(branches, k)
            end
        end
        if not hasNumbered and #branches > 0 then
            warn(player, "HL_ChangeViewmodelState: State '" .. state .. "' is ambiguous, available sub-states:")
            printTable(node, prefix)
            return nil, nil
        end
    end

    -- If it *is* a list of numbered frames, pick one at random
    if type(node) == "table" then
        local numberedKeys = {}
        for k in pairs(node) do
            if type(k) == "number" then
                table.insert(numberedKeys, k)
            end
        end
        if #numberedKeys > 0 then
            local choice = numberedKeys[P_RandomRange(1, #numberedKeys)]
            table.insert(pathParts, tostring(choice))
            node = node[choice]
        end
    end

    -- Finally check for a valid animation definition
    if type(node) == "table" and node.sentinel and type(node.frameDurations) == "table" then
        return node, table.concat(pathParts, " ")
    else
        warn(player, "HL_ChangeViewmodelState: State '" .. state .. "' is not a valid animation definition!")
        return nil, nil
    end
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

rawset(_G, "HL_ChangeViewmodelState", function(player, action, backup)
    local weapon    = player.hl.curwep
    local viewmodel = HLItems["v_"..(HLItems[weapon].viewmodel):lower()] or HLItems["v_pistol"]

    local frameData, realPath = getFrameData(player, action, viewmodel.animations)
    if not frameData then
        frameData, realPath = getFrameData(player, backup, viewmodel.animations)
    end
    if not frameData then
        return
    end

    player.hl1viewmdaction     = realPath or action
    player.hl1currentAnimation = frameData
	player.hl1frame            = 1
    player.hl1frameclock       = frameData.frameDurations[1] or 1
	if frameData.frameSounds and frameData.frameSounds[0] then
		S_StartSound(player.mo, frameData.frameSounds[0])
	end
end)

rawset(_G, "HL_AddKillFeedEntry", function(killer, victim, icon, durationTics)
    local function bake(who)
        if type(who) == "userdata" and userdataType(who) == "player_t" then
            -- grab name & team info
            local name  = who.name
            local cmap  = who.ctfteam and skincolors[who.mo.color].chatcolor or V_ORANGEMAP
            return name, cmap
        else
            return tostring(who), V_ORANGEMAP
        end
    end

    local kname, kcol = bake(killer)
    local vname, vcol = bake(victim)

    local entry = {
        killer    = kname,
        killcmap  = kcol,
        victim    = vname,
        victcmap  = vcol,
        icon      = icon or "HLKILLGENER",
        time      = durationTics or (5 * TICRATE)
    }

	table.insert(HL.killfeed, entry)
end)

local function HL_IsWeaponUsable(player, name)
	local wpnStats = HLItems[name]
	if not wpnStats then return false end

	-- Primary mode check
	local function isUsable(mode)
		local stats = wpnStats[mode]
		if not stats then return false end

		local clipMode = (mode == "secondary" and stats.altusesprimaryclip) and "primary" or mode
		local curModeStats = wpnStats[clipMode]
		if not curModeStats then return false end

		local clipSize = curModeStats.clipsize or -1
		local ammoType = curModeStats.ammo
		local reserveCount = (ammoType and player.hlinv.ammo[ammoType]) or 0
		local clipCount = (player.hlinv.wepclips[name] and player.hlinv.wepclips[name][clipMode]) or 0
		local neverDeny = curModeStats.neverdenyuse

		if clipSize > -1 then
			return clipCount > 0 or reserveCount > 0 or neverDeny
		elseif ammoType == "none" then
			return clipCount > 0 or neverDeny
		elseif ammoType and reserveCount >= 0 then
			return reserveCount > 0 or neverDeny
		else
			return true -- truly infinite ammo (e.g., crowbar or fists)
		end
	end

	return isUsable("primary") or isUsable("secondary")
end

rawset(_G, "HL_GetWeapons", function(items, targetSlot, player)
	local filtered = {}
	local filteredweps = {
		usable = {},   -- usable entries
		railring = {}, -- entries marked as "rail ring"
	}
	for i = 0, 9 do
		filteredweps[i] = 0
		filteredweps.usable[i] = {}
		filteredweps.railring[i] = {}
	end

	if not player then
		local errortype = type(player) == "userdata" and userdataType(player) or type(player)
		error("Bad argument #3 to 'HL_GetWeapons' (PLAYER_T* expected, got "..errortype..")", 2)
		return
	end

	-- Temporary table for normalization per slot
	local slotTables = {}
	for i = 0, 9 do slotTables[i] = {} end

	for name, data in pairs(items) do
		if not HL.cacheShit.weapons[name] then continue end
		if data.weaponslot == nil or data.priority == nil then
			if not data.weaponslot then
				warn(player, 'Weapon "' .. data.realname .. '" missing weapon slot!')
				data.weaponslot = 1
			end
			if data.priority == nil then
				warn(player, 'Weapon "' .. data.realname .. '" missing slot priority!')
				data.priority = INT32_MIN
			end
		end

		local slot = data.weaponslot
		if slot >= 0 and slot <= 9 then
			if player.hlinv.weapons and player.hlinv.weapons[name] then
				local usable = HL_IsWeaponUsable(player, name)
				filteredweps[slot] = (filteredweps[slot] or 0) + 1

				-- Add to normalization table
				table.insert(slotTables[slot], {
					name = name,
					priority = data.priority,
					railring = data.rsrrailring,
					usable = usable
				})

				-- If in the selected slot, insert into filtered (which is already sorted below)
				if slot == targetSlot then
					table.insert(filtered, {
						name = name,
						priority = data.priority,
						railring = data.rsrrailring,
						id = #filtered + 1,
						usable = usable
					})
				end
			end
		else
			warn(player, 'Weapon "' .. data.realname .. '" has an out-of-bounds weaponslot: ' .. slot)
		end
	end

	-- Normalize `usable` entries per slot
	for slot, weps in pairs(slotTables) do
		table.sort(weps, function(a, b)
			return a.priority < b.priority
		end)

		for i, wep in ipairs(weps) do
			filteredweps.usable[slot][i] = wep.usable
			filteredweps.railring[slot][i] = wep.railring
		end
	end

	-- Sort the filtered list for the selected slot
	table.sort(filtered, function(a, b)
		return a.priority < b.priority
	end)

	return {
		weapons = filtered,
		weaponcount = (#filtered or 0),
		wepslotamounts = filteredweps
	}
end)

rawset(_G, "HL_AddAmmo", function(freeman, ammotype, ammo, limitOverride)
	if not ammotype
		error("Bad argument #2 to 'HL_AddAmmo' (AMMO_T* expected, got '" .. tostring(ammotype) .. "')", 2)
	end

	if not freeman.hlinv.ammo
		error("HL_AddAmmo called, but no ammo inventory was found for the player!", 2)
	end

	-- Initialize ammo table if missing
	if not freeman.hlinv.ammo[ammotype] then
		freeman.hlinv.ammo[ammotype] = 0
	end

	-- Grant weapon if defined and not already owned
	local weapon = HLItems[ammotype] and HLItems[ammotype].weapongive
	if weapon and not freeman.hlinv.weapons[weapon] then
		freeman.hlinv.weapons[weapon] = true

		-- Play weapon pickup sound
		S_StartSound(nil, HLItems[weapon] and HLItems[weapon].pickupsound or sfx_hlwpnu, freeman)

		-- Log pickup to history
		freeman.pickuphistory[freeman.pickuphistory.index] = {
			thing = weapon,
			type = "weapon",
			time = pickupnotifytime
		}
		freeman.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
	end

	local curammo = freeman.hlinv.ammo[ammotype]
	local maxammo = HLItems[ammotype] and HLItems[ammotype].max or 0

	if not HLItems[ammotype] then
		warn(freeman, "Ammo type '\$ammotype\' doesn't have an associated HLItems index!")
	end

	local doubleammo = freeman.hl1doubleammo
	local effectiveMaxAmmo = limitOverride or (
		doubleammo
		and (HLItems[ammotype] and HLItems[ammotype].backpackmax or maxammo * 2)
		or maxammo
	)

	local spaceleft = effectiveMaxAmmo - curammo
	local actualgain = min(ammo or 0, spaceleft)

	freeman.hlinv.ammo[ammotype] = curammo + actualgain

	if actualgain > 0 then
		-- Play ammo pickup sound
		S_StartSound(nil, HLItems[ammotype] and HLItems[ammotype].pickupsound or sfx_hl1pr2, freeman)

		-- Log pickup to history
		freeman.pickuphistory[freeman.pickuphistory.index] = {
			thing = ammotype,
			count = actualgain,
			type = "ammo",
			time = pickupnotifytime
		}
		freeman.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
	end

	return actualgain > 0
end)

rawset(_G, "HL_SwitchWeapon", function(player, weaponName, nobuild)
	if not HL.cacheShit.weapons[weaponName] then printTable(HL.cacheShit.weapons) warn(player, "Invalid weapon name " .. tostring(weaponName) .. "!") return end

	-- Only switch if it's a new weapon
	if player.hl.curwep ~= weaponName then
		player.hl.lastused = player.hl.curwep
		player.hl.curwep = weaponName
		player.hl1weapondelay = HLItems[weaponName].globalfiredelay.ready

		-- Set animation
		HL_ChangeViewmodelState(player, "ready", "idle 1")
		player.kombireloading = 0

		if nobuild then return end
		-- Initialize clips if missing
		if not player.hlinv.wepclips[weaponName] then
			local clipsize = HLItems[weaponName].primary and HLItems[weaponName].primary.clipsize or -1
			local clipsize2 = HLItems[weaponName].secondary and HLItems[weaponName].secondary.clipsize or -1
			player.hlinv.wepclips[weaponName] = {primary = clipsize, secondary = clipsize2}
		end
	end
end)

rawset(_G, "HL_AddWeapon", function(freeman, weapon, silent, autoswitch) -- give some amount of weapon to freeman
	-- Push weapon to the weapon list if not already
	local didsomething = false
	if not freeman.hlinv.weapons then
		error("HL_AddWeapon called, but no inventory was found for the player!", 2)
		return
	end

	if not HLItems[weapon] then
		error("Weapon " .. weapon .. " is not registered! Did you forget to load its associated mod?", 2)
		return
	end

	if not freeman.hlinv.weapons[weapon]
		freeman.hlinv.weapons[weapon] = true

		if not silent
			S_StartSound(nil, HLItems[weapon] and HLItems[weapon].pickupsound or sfx_hlwpnu, freeman)
			freeman.pickuphistory[freeman.pickuphistory.index] = {
				thing = weapon, -- What did we get?
				type = "weapon", -- What kind?
				time = pickupnotifytime -- Clock
			}
			freeman.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
		end

		if autoswitch then
			-- get the new weapon's autoswitchweight, or 0 if the weapon maker neglected to add it (which would be #AWKWARD!)
			local newWeight = (HLItems[weapon].autoswitchweight or 0)
			-- find the currently equipped weapon
			local cur = freeman.hl.curwep
			-- get its autoswitchweight (or 0)
			local curWeight = (cur and HLItems[cur] and HLItems[cur].autoswitchweight) or 0

			-- only switch if the new one has higher priority
			if newWeight > curWeight then
				HL_SwitchWeapon(freeman, weapon, true)
			end
		end

		if freeman.selectionlist then
			freeman.selectionlist = HL_GetWeapons(HLItems, freeman.hl.wepmenu.category, freeman)
		end

		-- Handle initial clip fill from pickup gift
		freeman.hlinv.wepclips = freeman.hlinv.wepclips or {}
		freeman.hlinv.wepclips[weapon] = {0, 0}

		local function handleClipGift(clipIndex, gift, clipsize, ammotype)
			if gift
				if clipsize < 0
					HL_AddAmmo(freeman, ammotype, gift)
				else
					local remaining_gift = gift
					local clip = max(freeman.hlinv.wepclips[weapon][clipIndex] or 0, 0)
					local space_in_clip = clipsize - clip
					local clip_to_add = min(remaining_gift, space_in_clip)
					freeman.hlinv.wepclips[weapon][clipIndex] = clip + clip_to_add
					remaining_gift = remaining_gift - clip_to_add
					-- Defer any excess to HL_AddAmmo
					if remaining_gift > 0 and ammotype
						HL_AddAmmo(freeman, ammotype, remaining_gift)
					end
				end
			end
		end
		if HLItems[weapon].primary and HLItems[weapon].primary.pickupgift
			if not HLItems[weapon].primary.ammo
				warn(freeman, "Weapon " .. weapon .. " missing primary.ammo property!")
			else
				handleClipGift("primary", HLItems[weapon].primary.pickupgift, HLItems[weapon].primary.clipsize or -1, HLItems[weapon].primary.ammo)
			end
		end
		if HLItems[weapon].secondary and HLItems[weapon].secondary.pickupgift
			if not HLItems[weapon].secondary.ammo
				warn(freeman, "Weapon " .. weapon .. " missing secondary.ammo property!")
			else
				handleClipGift("secondary", HLItems[weapon].secondary.pickupgift, HLItems[weapon].secondary.clipsize or -1, HLItems[weapon].secondary.ammo)
			end
		end

		didsomething = true -- We gave the player a gun, so we did something there.
	else
		if HLItems[weapon].primary
			if HLItems[weapon].primary.pickupgift and HLItems[weapon].primary.ammo
				didsomething = HL_AddAmmo(freeman, HLItems[weapon].primary.ammo, HLItems[weapon].primary.pickupgift) or $
			end
		end
		if HLItems[weapon].secondary
			if HLItems[weapon].secondary.pickupgift and HLItems[weapon].secondary.ammo
				didsomething = HL_AddAmmo(freeman, HLItems[weapon].secondary.ammo, HLItems[weapon].secondary.pickupgift) or $
			end
		end
	end

	return didsomething -- Report that something happened for stuff like pick-up removal.
end)

rawset(_G, "HL_TakeWeapon", function(freeman, weapon) -- no more weapon privileges
	local didsomething = false
	if not freeman.hlinv.weapons error("HL_TakeWeapon called, but no inventory was found for the player!", 2) return end
	if not weapon
		freeman.hlinv.weapons = {}
		if freeman.hl.wepmenu.index
			freeman.selectionlist = HL_GetWeapons(HLItems, freeman.hl.wepmenu.category, freeman)
		end
		didsomething = true
	else
		if freeman.hlinv.weapons[weapon]
			freeman.hlinv.weapons[weapon] = false
			if freeman.hl.wepmenu.index
				freeman.selectionlist = HL_GetWeapons(HLItems, freeman.hl.wepmenu.category, freeman)
			end
			didsomething = true
		end
	end
	return didsomething
end)

rawset(_G, "HL_TakeAmmo", function(freeman, ammotype, ammocount) -- remove some amount of ammo from freeman
	if not freeman.hlinv.ammo error("HL_TakeAmmo called, but no ammo inventory was found for the player!", 2) return end
	ammocount = ammocount or 0
	if not ammotype and not ammocount
		freeman.hlinv.ammo = {}
		return
	end
	if not ammotype
		for atype, acount in pairs(freeman.hlinv.ammo) do
			freeman.hlinv.ammo[atype] = acount - ammocount
		end
	else
		freeman.hlinv.ammo[ammotype] = (freeman.hlinv.ammo[ammotype] or 0) - ammocount
	end
end)

rawset(_G, "HL_TakeClip", function(player, weapon, amount, alt) -- remove some amount of clip from freeman
	if weapon == nil
		for weapName, clips in pairs(player.hlinv.wepclips) do
			if alt == nil -- search for SPECIFICALLY nil.
				if amount
					player.hlinv.wepclips[weapName].primary = max(player.hlinv.wepclips[weapName].primary - amount, 0)
					player.hlinv.wepclips[weapName].secondary = max(player.hlinv.wepclips[weapName].secondary - amount, 0)
				else
					player.hlinv.wepclips[weapName].primary = 0
					player.hlinv.wepclips[weapName].secondary = 0
				end
			elseif alt
				if amount
					player.hlinv.wepclips[weapName].secondary = max(player.hlinv.wepclips[weapName].secondary - amount, 0)
				else
					player.hlinv.wepclips[weapName].secondary = 0
				end
			else
				if amount
					player.hlinv.wepclips[weapName].primary = max(player.hlinv.wepclips[weapName].primary - amount, 0)
				else
					player.hlinv.wepclips[weapName].primary = 0
				end
			end
		end
	else
		if player.hlinv.wepclips[weapon]
			if alt == nil
				if amount
					player.hlinv.wepclips[weapon].primary = max(player.hlinv.wepclips[weapon].primary - amount, 0)
					player.hlinv.wepclips[weapon].secondary = max(player.hlinv.wepclips[weapon].secondary - amount, 0)
				else
					player.hlinv.wepclips[weapon].primary = 0
					player.hlinv.wepclips[weapon].secondary = 0
				end
			elseif alt
				if amount
					player.hlinv.wepclips[weapon].secondary = max(player.hlinv.wepclips[weapon].secondary - amount, 0)
				else
					player.hlinv.wepclips[weapon].secondary = 0
				end
			else
				if amount
					player.hlinv.wepclips[weapon].primary = max(player.hlinv.wepclips[weapon].primary - amount, 0)
				else
					player.hlinv.wepclips[weapon].primary = 0
				end
			end
		else
			print("Invalid weapon: " .. tostring(weapon))
		end
	end
end)

rawset(_G, "HL_DecrementWeaponAmmo", function(player, secondary)
    local wepID = player.hl.curwep
    local wepData = HLItems[wepID]
    
    if not wepData then return end
    
    local function takeFromClip(altFire)
        if altFire and wepData.altusesprimaryclip then
            HL_TakeClip(player, wepID, wepData.secondary.shotcost, false)
        elseif altFire then
            HL_TakeClip(player, wepID, wepData.secondary.shotcost, true)
        else
            HL_TakeClip(player, wepID, wepData.primary.shotcost, false)
        end
    end
    
    local function takeFromAmmo(altFire)
        local ammoType
        if altFire and wepData.altusesprimaryclip then
            ammoType = wepData.primary.ammo
        elseif altFire then
            ammoType = wepData.secondary.ammo
        else
            ammoType = wepData.primary.ammo
        end
        local shotcost = altFire and wepData.secondary.shotcost or wepData.primary.shotcost
        HL_TakeAmmo(player, ammoType, shotcost)
    end

    if secondary then
        if wepData.secondary and wepData.secondary.shotcost then
            if wepData.altusesprimaryclip and wepData.primary.clipsize > 0 then
                takeFromClip(true)
            elseif not wepData.altusesprimaryclip and wepData.secondary.clipsize > 0 then
                takeFromClip(true)
            else
                takeFromAmmo(true)
            end
        end
    else
        if wepData.primary and wepData.primary.shotcost then
            if wepData.primary.clipsize > 0 then
                takeFromClip(false)
            else
                takeFromAmmo(false)
            end
        end
    end
end)

local ff = CV_FindVar("friendlyfire")

local function getHangout()
	local function hasTol(mask, tol)
		return tol and mask & tol ~= 0
	end

	if hasTol(maptol, TOL_HANGOUT) then
		return true
	end

	if hasTol(maptol, TOL_HANGSP) then
		return true
	end
end

rawset(_G, "HL_IsAlly", function(player1, player2, useff)
	-- Hangout hack because I can't be bothered to figure out how the ringslinger convar interacts with shit
	if (ff.value and useff) then return false end

	-- you are not your own ally (1984.gif)
	if player1 == player2 or (ff.value and useff) then return false end

	if (gametyperules & GTR_FRIENDLY) then
		return true
	end

	if G_GametypeHasTeams()
		return player1.ctfteam == player2.ctfteam
	else // Everyone is an ally, or everyone is a foe!
		return not G_RingSlingerGametype()
	end
end)

local function ExtractMobj(obj)
	if type(obj) == "userdata" then
		local utype = userdataType(obj)
		if utype == "mobj_t" then
			return obj
		elseif utype == "player_t" and obj.mo then
			return obj.mo
		end
	end
	return nil
end

local function ExtractPlayer(obj)
	if type(obj) == "userdata" then
		local utype = userdataType(obj)
		if utype == "player_t" then
			return obj
		elseif utype == "mobj_t" and obj.player then
			return obj.player
		end
	end
	return nil
end

local function parseFPStat(input, baseFP, limitFP)
    if type(input) == "string" then
        if     input == "max"   or input == "maxhp"  then return baseFP
        elseif input == "limit"              then return limitFP
        elseif input:sub(-1) == "%"         then
            local pct = tonumber(input:sub(1,-2))
            if pct then
                -- baseFP * (pct/100)  in fixed‑point: FixedMul(baseFP, pct * FRACUNIT / 100)
                return FixedMul(baseFP, pct * FRACUNIT / 100)
            end
        end
    elseif type(input) == "number" then
        -- numeric literal always treated as “that many health points”,
        -- so convert to fixed‑point.
        return input * FRACUNIT
    end
    error("Invalid stat value: "..tostring(input), 2)
end

rawset(_G, "HL_ApplyPickupStats", function(mobj, stats)
	local mobj = ExtractMobj(mobj)
	local player = ExtractPlayer(mobj)
	if not (player and mobj) then print("No player or mobj") return false end

    local isAKeeper = true

	local function clampStat(stat, max, limit)
		return min(stat, min(max, limit))
	end

    -- Double‐ammo
    if stats.doubleammo and not player.hl1doubleammo then
        player.hl1doubleammo = true
    end

	-- Health
    if stats.health then
		-- Convert everything into fixed‑point.
		local baseFP   = mobj.hl.maxhealth * FRACUNIT
		local maxmul   = stats.health.maxmult or FRACUNIT
		local ceilingFP = FixedMul(baseFP, maxmul)

		if stats.health.limit then
			ceilingFP = min(ceilingFP, stats.health.limit * FRACUNIT)
		end

		-- Only proceed if current health < ceiling
		if mobj.hl.health * FRACUNIT < ceilingFP then
			-- Compute how much to give/set in FP
			local newHPfp
			if stats.health.give then
				newHPfp = (mobj.hl.health * FRACUNIT)
						+ parseFPStat(stats.health.give, baseFP, ceilingFP)
			elseif stats.health.set then
				newHPfp = parseFPStat(stats.health.set, baseFP, ceilingFP)
			else
				error("Pickup has health entry without give/set!", 1)
			end

			-- Clamp to ceiling, then convert back to integer HP
			mobj.hl.health = FixedFloor(min(newHPfp, ceilingFP)) / FRACUNIT
			player.pickuphistory[player.pickuphistory.index] = { thing = "health", type = "special", time = pickupnotifytime }
			player.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
            isAKeeper = false
            S_StartSound(nil, sfx_hlmedi, player)
        end
    end

	-- Armor
    if stats.armor then
		local baseFP    = mobj.hl.maxarmor
		local maxmul    = stats.armor.maxmult or FRACUNIT
		local ceilingFP = FixedMul(baseFP, maxmul)

		if stats.armor.limit then
			ceilingFP = min(ceilingFP, stats.armor.limit * FRACUNIT)
		end

		if mobj.hl.armor < ceilingFP then
			local newARfp
			if stats.armor.give then
				newARfp = mobj.hl.armor
						+ parseFPStat(stats.armor.give,
									  baseFP, ceilingFP)
			elseif stats.armor.set then
				newARfp = parseFPStat(stats.armor.set,
									  baseFP, ceilingFP)
			else
				error("Pickup has armor entry without give/set!", 1)
			end

			mobj.hl.armor = min(newARfp, ceilingFP)
			if stats.armor.novox then
				player.prevarmor = {real = player.mo.hl.armor, rounded = FixedFloor(player.mo.hl.armor / 5)}
			end

            player.pickuphistory[player.pickuphistory.index] = { thing = "battery", type = "special", time = pickupnotifytime }
			player.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
            isAKeeper = false
            S_StartSound(nil, sfx_hlwpnu, player)
        end
    end

    -- Ammo
	if stats.ammo then
		local types = type(stats.ammo.type) == "table" and stats.ammo.type
				   or { stats.ammo.type }
		local gives = type(stats.ammo.give)== "table" and stats.ammo.give
				   or { stats.ammo.give }
		local sets   = stats.ammo.set
				   and (type(stats.ammo.set)=="table" and stats.ammo.set
						or { stats.ammo.set })
				   or nil

		for i, atype in ipairs(types) do
			local giveVal = gives[i]
			local setVal  = sets   and sets[i]
			if not giveVal and not setVal then
				error("Missing give/set for ammo type "..tostring(atype), 2)
			end

			-- Base and ceiling in FIXED‑POINT
			local base    = player.hl1doubleammo and (HLItems[atype] and HLItems[atype].backpackmax or HLItems[atype].max * 2) or HLItems[atype].max
			local baseFP  = base * FRACUNIT
			local maxmul  = stats.ammo.maxmult or FRACUNIT
			local ceilingFP = FixedMul(baseFP, maxmul)
			if stats.ammo.limit then
				ceilingFP = min(ceilingFP, stats.ammo.limit * FRACUNIT)
			end

			-- Current ammo in FP
			local curInt = player.hlinv.ammo[atype] or 0
			local curFP  = curInt * FRACUNIT

			if setVal then
				-- ==== SET BRANCH ====
				local finalFP = parseFPStat(setVal, baseFP, ceilingFP)
				finalFP = min(finalFP, ceilingFP)
				local finalInt = FixedFloor(finalFP / FRACUNIT)

				player.hlinv.ammo[atype] = finalInt
				S_StartSound(nil, HLItems[atype].pickupsound or sfx_hl1pr2, player)
				player.pickuphistory[player.pickuphistory.index] = { thing = atype, count = finalInt, type = "ammo", time = pickupnotifytime }
				player.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
				isAKeeper = false

			else
				-- ==== GIVE BRANCH ====
				-- 1) compute desired give in FP
				local wantFP = parseFPStat(giveVal, baseFP, ceilingFP)
				-- 2) clamp to remaining space
				local spaceFP = max(0, ceilingFP - curFP)
				local giveFP  = min(wantFP, spaceFP)
				-- 3) convert to integer rounds
				local giveInt = FixedFloor(giveFP) / FRACUNIT

				-- 4) hand that delta to HL_AddAmmo
				if giveInt > 0 then
					HL_AddAmmo(player, atype, giveInt, FixedFloor(ceilingFP / FRACUNIT))
					isAKeeper = false
				end
			end
		end
	end

	if stats.rsrrailring then
		player.hl.rsr = $ or {}
		local curAmmo = player.hl.rsr.railring
		player.hl.rsr.railring = ($ or 0) + (stats.rsrrailring or 1)
		if player.hl.rsr.railring > 10 then
			player.hl.rsr.railring = 10
		end
		isAKeeper = curAmmo == player.hl.rsr.railring
	end

    -- Weapon(s)
    if stats.weapon then
        if type(stats.weapon) == "table" then
            for _, w in ipairs(stats.weapon) do
                if HL_AddWeapon(player, w) then
                    isAKeeper = false
                end
            end
        else
            if HL_AddWeapon(player, stats.weapon, false, true) then
                isAKeeper = false
            end
        end
    end

    -- Invulnerability
    if stats.invuln then
        player.powers[pw_invulnerability] = stats.invuln.set
        isAKeeper = false
    end

    -- Berserk
    if stats.berserk then
        player.hl1berserk = INT32_MAX
        isAKeeper = false
    end

    -- Long-Jump Module
    if stats.longjump then
		if player.hlinv.hevsuit and not (player.hlinv and player.hlinv.longjump) then 
			player.hlinv = player.hlinv or {}
			player.hlinv.longjump = true
			FVox_WarnDamage(14, player)
			player.pickuphistory[player.pickuphistory.index] = { thing = "ljm", type = "special", time = pickupnotifytime }
			player.pickuphistory.index = ($ % HL.MAX_HISTORY) + 1
			isAKeeper = false
		end
    end

    -- H.E.V. Suit
    if stats.suit then
		if type(stats.suit) == "table" then
			if not (player.hlinv and player.hlinv.hevsuit) then 
				player.hlinv = player.hlinv or {}
				player.hlinv.hevsuit = true
				if stats.suit.shortlogon then
					FVox_WarnDamage("HEV_LOGONS", player, stats.suit.klaxonbeat)
				else
					FVox_WarnDamage("HEV_LOGON", player, stats.suit.klaxonbeat)
				end
				isAKeeper = false
			end
		else
			if not (player.hlinv and player.hlinv.hevsuit) then 
				player.hlinv = player.hlinv or {}
				player.hlinv.hevsuit = true
				FVox_WarnDamage("HEV_LOGON", player, stats.suit.klaxonbeat)
				isAKeeper = false
			end
		end
    end

    return not isAKeeper
end)

HL.killfeedNames = {
	-- Projectiles
	[MT_CORK] = "fangcork",
	[MT_LHRT] = "loveheart",

	-- Enemies
	[MT_BLUECRAWLA]          = "monster_bluecrawla",
	[MT_REDCRAWLA]           = "monster_redcrawla",
	[MT_GFZFISH]             = "monster_gfzfish",
	[MT_GOLDBUZZ]            = "monster_goldbuzz",
	[MT_REDBUZZ]             = "monster_redbuzz",
	[MT_JETTBOMBER]          = "monster_jettbomber",
	[MT_JETTGUNNER]          = "monster_jettgunner",
	[MT_CRAWLACOMMANDER]     = "monster_crawla_commander",
	[MT_DETON]               = "monster_deton",
	[MT_SKIM]                = "monster_skim",
	[MT_TURRET]              = "monster_turret",
	[MT_POPUPTURRET]         = "monster_popup_turret",
	[MT_SPINCUSHION]         = "monster_spincushion",
	[MT_CRUSHSTACEAN]        = "monster_crushstacean",
	[MT_BANPYURA]            = "monster_banpyura",
	[MT_JETJAW]              = "monster_jetjaw",
	[MT_SNAILER]             = "monster_snailer",
	[MT_VULTURE]             = "monster_vulture",
	[MT_POINTY]              = "monster_pointy",
	[MT_ROBOHOOD]            = "monster_robohood",
	[MT_FACESTABBER]         = "monster_facestabber",
	[MT_EGGGUARD]            = "monster_eggguard",
	[MT_GSNAPPER]            = "monster_gsnapper",
	[MT_MINUS]               = "monster_minus",
	[MT_SPRINGSHELL]         = "monster_springshell",
	[MT_YELLOWSHELL]         = "monster_yellowshell",
	[MT_UNIDUS]              = "monster_unidus",
	[MT_CANARIVORE]          = "monster_canarivore",
	[MT_PYREFLY]             = "monster_pyrefly",
	[MT_PTERABYTESPAWNER]    = "monster_pterabyte_spawner",
	[MT_PIAN]                = "monster_pian",
	[MT_SHLEEP]              = "monster_shleep",
	[MT_PENGUINATOR]         = "monster_penguinator",
	[MT_POPHAT]              = "monster_pophat",
	[MT_HIVEELEMENTAL]       = "monster_hiveelemental",
	[MT_BUMBLEBORE]          = "monster_bumblebore",
	[MT_BUGGLE]              = "monster_buggle",
	[MT_CACOLANTERN]         = "monster_cacolantern",
	[MT_SPINBOBERT]          = "monster_spinbobert",
	[MT_HANGSTER]            = "monster_hangster",

	-- Bosses
	[MT_EGGMOBILE]           = "monster_eggmobile",
	[MT_EGGMOBILE2]          = "monster_eggslimer",
	[MT_EGGMOBILE3]          = "monster_seaegg",
	[MT_EGGMOBILE4]          = "monster_eggcolo",
	[MT_EGGROBO1]            = "monster_eggrobo",
	[MT_FANG]                = "monster_fang",
	[MT_BLACKEGGMAN]         = "monster_brakeggman",
	[MT_CYBRAKDEMON]         = "monster_cybrakdemon",
	[MT_METALSONIC_RACE]     = "monster_metalsonic_race",
	[MT_METALSONIC_BATTLE]   = "monster_metalsonic_battle",
}

rawset(_G, "HL_IsRSRGametype", function()
    return RSR and RSR.GamemodeActive()
end)

rawset(_G, "HL_HandleKillFeed", function(victim, source, inflictor, dmgType)
    local killerPlayer = nil
    local attacker = ""

    if source then
        local resolvedSource =
            ((inflictor.flags & MF_MISSILE) or inflictor.stats)
            and (inflictor.shooter or inflictor.target)
            or inflictor

        if type(resolvedSource) == "userdata" and userdataType(resolvedSource) ~= "player_t" then
            if resolvedSource and (resolvedSource ~= victim or (resolvedSource.player and resolvedSource.player ~= victim))
               and resolvedSource.player then
                killerPlayer = resolvedSource.player
                attacker = killerPlayer.name
            end
        else
            killerPlayer = resolvedSource
            attacker = killerPlayer and killerPlayer.name or ""
        end
    end

    local killicon = inflictor and ((inflictor.stats and inflictor.stats.killicon)
                 or (inflictor.wepstats and inflictor.wepstats.killicon))
                 or "HLKILLGENER"

    if killicon == "HLKILLGENER" and ((dmgType or 0) & HL.DMG.CRUSH) then
        killicon = "HLKILLCRUSH"
    end

    -- Keep existing "blank killer" rule
    if (killerPlayer == nil and not (type(source) == "userdata" and userdataType(source) == "mobj_t"))
       or victim.player == killerPlayer then
        killerPlayer = nil
    end

    -- Fallback: if no killerPlayer, try to name the inflictor
    if not killerPlayer then
        local nameFromTable = inflictor and HL.killfeedNames[inflictor.type]
        killerPlayer = nameFromTable or ""
    end

    -- Only add if victim is a player
    if victim.player and killerPlayer then
        HL_AddKillFeedEntry(victim.player, killerPlayer, killicon)
    end
end)

local function stinkyVanillaCharHandler(inflictor, source)
	local player = source.player
	if RingslingerRev then
		-- Ringslinger Revolution
		local mobjToName = {
			[MT_RSR_PROJECTILE_BASIC] = "matchring",
			[MT_RSR_PROJECTILE_SCATTER] = "scatterring",
			[MT_RSR_PROJECTILE_AUTO] = "automaticring",
			[MT_RSR_PROJECTILE_BOUNCE] = "bouncering",
			[MT_RSR_PROJECTILE_GRENADE] = "grenadering",
			[MT_RSR_PROJECTILE_BOMB] = "bombring",
			[MT_RSR_PROJECTILE_HOMING] = "homingring",
			[MT_RSR_PROJECTILE_RAIL] = "railring",
			[MT_CORK] = "fangcork",
			[MT_LHRT] = "loveheart"
		}
		return mobjToName[inflictor.type]
	elseif RingSlinger and RingSlinger.Weapons then
		-- Ringslinger NEO
		return string.lower((inflictor.info.name):gsub(" ", ""))
	else
		-- Base Ringslinger
		local wepmap = {
			[0] = "matchring",
			[WEP_AUTO] = "automaticring",
			[WEP_BOUNCE] = "bouncering",
			[WEP_SCATTER] = "scatterring",
			[WEP_GRENADE] = "grenadering",
			[WEP_EXPLODE] = "explosionring",
			[WEP_RAIL] = "railring",
		}
		return wepmap[player.currentweapon] or "???"
	end
end

local function getItemName(inflictor, source)
    if not inflictor then return "worldspawn" end

    local player = (source and source.player) or (inflictor and inflictor.player)
    if player and player.mo then
        local handler = kombiHL1SpecialHandlers[player.mo.skin]
        if handler and handler.getwep then
            return handler.getwep(player)
        end
        return stinkyVanillaCharHandler(inflictor, source)
    end

    return HL.killfeedNames[inflictor.type] or "worldspawn"
end

-- Player killed Player2/self with Item/worldspawn
rawset(_G, "maybeDoKillMsg", function(mobj, inflictor, source, damageType)
	if not mobj.player then return end
	local vplayer = mobj.player
	local toprint = ""

	if not inflictor then
		-- Falldamage/Enemy
		toprint = vplayer.name .. " killed self with worldspawn"
		return
	end

	local aplayer = source and source.player
	local weapon = getItemName(inflictor, source)

	if not aplayer then
		-- Object
		toprint = vplayer.name .. " was killed by " .. weapon
	elseif vplayer == aplayer then
		-- Self-own
		toprint = aplayer.name .. " killed self with " .. weapon
	else
		-- Murder
		toprint = aplayer.name .. " killed " .. vplayer.name .. " with " .. weapon
	end
	for player in players.iterate() do
		if not player.hl.config or not player.hl.config.killfeed then continue end
		CONS_Printf(player, toprint)
	end
end)

addHook("TouchSpecial", function(item, mobj)
    if mobj.skin ~= "kombifreeman" then return end
    local stats = item.pickupstats or HL_PickupStats[item.type]

	if item.rsrIsPanel and stats.ammo and stats.ammo.give then
		for i, amount in ipairs(stats.ammo.give) do
			stats.ammo.give[i] = amount * 2
		end
	end

    if not stats then return end

    if HL_ApplyPickupStats(mobj, stats) then
		if RSR then
			-- GOD why does RSR need to be a needy baby sometimes
			RSR.SetItemFuse(item)
		end
		P_KillMobj(item)
    elseif item.hl.nobasebehavior then return true end
end)

/*
local giveables = {
  -- Enemies
  monster_bluecrawla        = MT_BLUECRAWLA,
  monster_redcrawla         = MT_REDCRAWLA,
  monster_gfzfish           = MT_GFZFISH,
  monster_goldbuzz          = MT_GOLDBUZZ,
  monster_redbuzz           = MT_REDBUZZ,
  monster_jettbomber        = MT_JETTBOMBER,
  monster_jettgunner        = MT_JETTGUNNER,
  monster_crawla_commander  = MT_CRAWLACOMMANDER,
  monster_deton             = MT_DETON,
  monster_skim              = MT_SKIM,
  monster_turret            = MT_TURRET,
  monster_popup_turret      = MT_POPUPTURRET,
  monster_spincushion       = MT_SPINCUSHION,
  monster_crushstacean      = MT_CRUSHSTACEAN,
  monster_banpyura          = MT_BANPYURA,
  monster_jetjaw            = MT_JETJAW,
  monster_snailer           = MT_SNAILER,
  monster_vulture           = MT_VULTURE,
  monster_pointy            = MT_POINTY,
  monster_robohood          = MT_ROBOHOOD,
  monster_facestabber       = MT_FACESTABBER,
  monster_eggguard          = MT_EGGGUARD,
  monster_gsnapper          = MT_GSNAPPER,
  monster_minus             = MT_MINUS,
  monster_springshell       = MT_SPRINGSHELL,
  monster_yellowshell       = MT_YELLOWSHELL,
  monster_unidus            = MT_UNIDUS,
  monster_canarivore        = MT_CANARIVORE,
  monster_pyrefly           = MT_PYREFLY,
  monster_pterabyte_spawner = MT_PTERABYTESPAWNER,
  monster_pian              = MT_PIAN,
  monster_shleep            = MT_SHLEEP,
  monster_penguinator       = MT_PENGUINATOR,
  monster_pophat            = MT_POPHAT,
  monster_hiveelemental     = MT_HIVEELEMENTAL,
  monster_bumblebore        = MT_BUMBLEBORE,
  monster_buggle            = MT_BUGGLE,
  monster_cacolantern       = MT_CACOLANTERN,
  monster_spinbobert        = MT_SPINBOBERT,
  monster_hangster          = MT_HANGSTER,

  -- Bosses
  monster_eggmobile         = MT_EGGMOBILE,
  monster_eggslimer         = MT_EGGMOBILE2,
  monster_seaegg            = MT_EGGMOBILE3,
  monster_eggcolo           = MT_EGGMOBILE4,
  monster_eggrobo           = MT_EGGROBO1,
  monster_fang              = MT_FANG,
  monster_brakeggman        = MT_BLACKEGGMAN,
  monster_cybrakdemon       = MT_CYBRAKDEMON,
  monster_metalsonic_race   = MT_METALSONIC_RACE,
  monster_metalsonic_battle = MT_METALSONIC_BATTLE,

  -- Collectibles
  item_ring                 = MT_RING,
  item_bluesphere           = MT_BLUESPHERE,
  item_bombsphere           = MT_BOMBSPHERE,
  item_ctf_redteamring      = MT_REDTEAMRING,
  item_ctf_blueteamring     = MT_BLUETEAMRING,
  item_emerald_token        = MT_TOKEN,
  item_ctf_redflag          = MT_REDFLAG,
  item_ctf_blueflag         = MT_BLUEFLAG,
  item_emblem               = MT_EMBLEM,
  item_emerald1             = MT_EMERALD1,
  item_emerald2             = MT_EMERALD2,
  item_emerald3             = MT_EMERALD3,
  item_emerald4             = MT_EMERALD4,
  item_emerald5             = MT_EMERALD5,
  item_emerald6             = MT_EMERALD6,
  item_emerald7             = MT_EMERALD7,
  misc_emerhunt             = MT_EMERHUNT,
  misc_emeraldspawn         = MT_EMERALDSPAWN,

  -- Springs & fans
  func_fan                  = MT_FAN,
  func_gas_jet              = MT_STEAM,
  func_bumper               = MT_BUMPER,
  func_balloon              = MT_BALLOON,
  func_yellowspring         = MT_YELLOWSPRING,
  func_redspring            = MT_REDSPRING,
  func_bluespring           = MT_BLUESPRING,
  func_yellowspring_diag    = MT_YELLOWDIAG,
  func_redspring_diag       = MT_REDDIAG,
  func_bluespring_diag      = MT_BLUEDIAG,
  func_yellowspring_horiz   = MT_YELLOWHORIZ,
  func_redspring_horiz      = MT_REDHORIZ,
  func_bluespring_horiz     = MT_BLUEHORIZ,

  -- Interactive objects
  func_starpost             = MT_STARPOST,
  func_big_mine             = MT_BIGMINE,
  func_cannon_launcher      = MT_CANNONLAUNCHER,

  -- Monitors (item-boxes)
  item_mon_ring10           = MT_RING_BOX,
  item_mon_pity             = MT_PITY_BOX,
  item_mon_attract          = MT_ATTRACT_BOX,
  item_mon_force            = MT_FORCE_BOX,
  item_mon_armageddon       = MT_ARMAGEDDON_BOX,
  item_mon_whirlwind        = MT_WHIRLWIND_BOX,
  item_mon_elemental        = MT_ELEMENTAL_BOX,
  item_mon_sneakers         = MT_SNEAKERS_BOX,
  item_mon_invincibility    = MT_INVULN_BOX,
  item_mon_extra_life       = MT_1UP_BOX,
  item_mon_eggman_box       = MT_EGGMAN_BOX,
  item_mon_teleporter       = MT_MIXUP_BOX,
  item_mon_gravity_boots    = MT_GRAVITY_BOX,
  item_mon_recycler         = MT_RECYCLER_BOX,
  item_mon_score_1k         = MT_SCORE1K_BOX,
  item_mon_score_10k        = MT_SCORE10K_BOX,

  -- Weapon rings
  weapon_bounce_ring        = MT_BOUNCEPICKUP,
  weapon_rail_ring          = MT_RAILPICKUP,
  weapon_automatic_ring     = MT_AUTOMATICPICKUP,
  weapon_explosion_ring     = MT_EXPLOSIONPICKUP,
  weapon_scatter_ring       = MT_SCATTERPICKUP,
  weapon_grenade_ring       = MT_GRENADEPICKUP,
  item_bounce_ring          = MT_BOUNCERING,
  item_rail_ring            = MT_RAILRING,
  item_infinity_ring        = MT_INFINITYRING,
  item_automatic_ring       = MT_AUTOMATICRING,
  item_explosion_ring       = MT_EXPLOSIONRING,
  item_scatter_ring         = MT_SCATTERRING,
  item_grenade_ring         = MT_GRENADERING,

  -- Mario crossover
  item_coin                 = MT_COIN,
  monster_goomba            = MT_GOOMBA,
  monster_bluegoomba        = MT_BLUEGOOMBA,
  item_fireflower           = MT_FIREFLOWER,
  monster_fireball          = MT_FIREBALL,
  item_koopa_shell          = MT_SHELL,
  monster_puma              = MT_PUMA,
  monster_king_bowser       = MT_KOOPA,
  item_axe                  = MT_AXE,
  env_mario_bush1           = MT_MARIOBUSH1,
  env_mario_bush2           = MT_MARIOBUSH2,
  monster_toad              = MT_TOAD,

  -- NiGHTS
  monster_ideya_drone       = MT_NIGHTSDRONE,
  entity_nights_bumper      = MT_NIGHTSBUMPER,
  item_super_paraloop       = MT_NIGHTSSUPERLOOP,
  item_super_paraloop       = MT_NIGHTSDRILLREFILL,
  item_super_paraloop       = MT_NIGHTSHELPER,
  item_super_paraloop       = MT_NIGHTSEXTRATIME,
  item_super_paraloop       = MT_NIGHTSLINKFREEZE,
  monster_ideya_capture     = MT_EGGCAPSULE,
  monster_ideya_anchor      = MT_IDEYAANCHOR,
}
*/

rawset(_G, "sv_cheats", CV_RegisterVar({
	name = "sv_cheats",
	defaultvalue = "Off",
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {Off = 0, On = 1},
}))

COM_AddCommand("use", function(player, wep)
	/*
	auto-switch to weapon, like "use weapon_9mmhandgun"
	(internally, all weapons don't use the weapon_ prefix,
	but for accuracy's sake we'll do it here.)
	*/
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
end)

COM_AddCommand("give", function(player, item)
	-- Was also used to summon objects, but no.
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
	if not sv_cheats.value then return end
	if item == "item_longjump" then
		HL_ApplyPickupStats(player, {longjump = true})
	elseif item == "item_battery" then
		HL_ApplyPickupStats(player, {armor = {give = 15}})
	elseif item == "item_healthkit" then
		HL_ApplyPickupStats(player, {health = {give = 25}})
	elseif item == "item_suit" then
		HL_ApplyPickupStats(player, {suit = true})
	elseif item == "monster_gib" then
		local gib = P_SpawnMobjFromMobj(player.mo, 0, 0, player.mo.height/2, MT_HL_GIBS)
		gib.scale = FRACUNIT*2/3
		gib.frame = 1
	end
end)

rawset(_G, "cv_kombifalldamage", CV_RegisterVar({
	name = "mp_falldamage",
	defaultvalue = "On",
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {On = 1, Fixed = 0, Dont = -1},
}))

rawset(_G, "cv_hldecaldelay", CV_RegisterVar({
	name = "hl_decalfrequency",
	defaultvalue = 30,
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = CV_Unsigned,
}))

rawset(_G, "cv_gruntenable", CV_RegisterVar({
	name = "hl_allowimpulse76",
	defaultvalue = 0,
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = CV_OnOff,
}))

-- TFC Command - yells out for a medic
COM_AddCommand("saveme", function(player)
	if not player then return end
	if not player.mo then return end
	S_StartSound(player.mo, P_RandomChance(FRACUNIT/2) and sfx_hlmed1 or sfx_hlmed2)
end)

-- Switch to last-used weapon
COM_AddCommand("lastinv", function(player)
	if not player then return end
	if not player.hl.lastused then return end
	HL_SwitchWeapon(player, player.hl.lastused)
end)

COM_AddCommand("impulse", function(player, impulse)
	if gamestate ~= GS_LEVEL
		return
	end
	if not player.mo then return end
	if player.mo.skin != "kombifreeman" then return end
	if impulse == "101"
		if not sv_cheats.value then return end
		for wepname, wepstats in pairs(HLItems) do
			local _, whatis = HL_GetPrefix(wepname)
			if tostring(whatis) != "weapon_" then continue end
			if wepstats.noimpulse then continue end
			HL_AddWeapon(player, wepname, false, true)
		end
		HL_ApplyPickupStats(player, {armor = {give = 15}})
	elseif impulse == "100"
		if not player.hlinv.hevsuit then return end
		player.hl = $ or {}
		player.hl.flashlight = not $
		S_StartSound(player.mo, sfx_hlflas)
	elseif impulse == "201"
		if player.hl.spraydelay then S_StartSound(nil, sfx_hldeny, player) CONS_Printf(player, "Need to wait " .. player.hl.spraydelay/TICRATE .. " more seconds before using your spray again.") return end
		player.hl = $ or {}
		player.hl.spraying = true
	elseif impulse == "76"
		if not cv_gruntenable.value then return end
		if not sv_cheats.value then return end
		if not HL.GruntCache then
			HL.GruntCache = true
			local type = MT_THOK
			local truetype = MT_JETTGUNNER
			local typeinfo = mobjinfo[truetype]
			local cache = P_SpawnMobjFromMobj(player.mo, sin(player.mo.angle), cos(player.mo.angle), 0, type)
			cache.state = S_INVISIBLE
			cache.fuse = 1
			cache.alpha = 1
			local initstate = typeinfo.spawnstate
			cache.sprite = states[initstate].sprite
		else
			local type = MT_JETTGUNNER
			local typeinfo = mobjinfo[type]
			-- Emulate GoldSrc "origin == center" by stuffing them half-into the ground
			P_SpawnMobjFromMobj(player.mo, 0, 0, (typeinfo.height / 2) * P_MobjFlip(player.mo), type)
		end
	end
end)

-- suicide
COM_AddCommand("kill", function(player, victim)
	if not (player and player.mo)
		return
	end
	-- kill runner as a placeholder
	P_PlayerEmeraldBurst(player, false)
	P_PlayerWeaponAmmoBurst(player)
	P_PlayerFlagBurst(player, false)
	P_KillMobj(player.mo, player.mo, player.mo, DMG_SPECTATOR|DMG_CANHURTSELF)
end)

-- Weapon slot commands (for key binding)
local function setSlot(player, slot)
	if not (player and player.mo) then
		return
	end
	player.desiredSlot = slot
end

for slot = 0, 9 do
	COM_AddCommand("slot" .. slot, function(player) setSlot(player, slot) end)
end

rawset(_G, "cv_stopspeed", CV_RegisterVar({
	name = "hl_stopspeed",
	defaultvalue = 100,
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {MIN = -2341, MAX = 2341},
}))

rawset(_G, "cv_friction", CV_RegisterVar({
	name = "hl_friction",
	defaultvalue = 4,
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {MIN = -2341, MAX = 2341},
}))

rawset(_G, "cv_corpselifetime", CV_RegisterVar({
	name = "hl_corpselifetime",
	defaultvalue = 30,
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {MIN = -1, MAX = INT32_MAX/TICRATE},
}))

rawset(_G, "cv_ljmspawn", CV_RegisterVar({
	name = "hl_longjumponspawn",
	defaultvalue = "On",
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {Off = 0, On = 1},
}))

rawset(_G, "cv_deathmatch", CV_RegisterVar({
	name = "hl_deathmatch",
	defaultvalue = "Off",
	flags = CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {Off = 0, On = 1},
}))

-- Helper: converts "12.5" → integer (FRACUNIT * 25 / 2)
local function parseFixed(numstr)
    local intPart, fracPartStr = numstr:match("^(%d*)%.?(%d*)$")
    intPart = tonumber(intPart) or 0
    fracPartStr = fracPartStr or ""
    local fracPart  = tonumber(fracPartStr) or 0
    local divisor   = 10 ^ #fracPartStr
    -- scale both parts into 16.16 fixed‑point
    return intPart * FRACUNIT + (fracPart * FRACUNIT) / divisor
end

-- On/Off parser
local function parseOnOff(str)
    str = str:lower()
    if str == "on" or str == "1" then return true end
    if str == "off" or str == "0" then return false end
    return nil
end

-- Generic builder: cmdname, config‑key, parser, usage
local function addConfigCmd(cmdname, realname, key, parser, usage, silent)
    COM_AddCommand(cmdname, function(player, val)
        if not (player and player.mo) then
            CONS_Printf(player, "Can't do that right now.")
            return
        end
        if val == nil then
            CONS_Printf(player, string.format("Usage: %s <%s>", cmdname, usage))
            return
        end
        local v = parser(val)
        player.hl.config[key] = v
		if not silent then
			CONS_Printf(player, tostring(realname) .. " set to " .. tostring(v))
		end
		if player != consoleplayer then return end
		saveTableToFile(HL.CONFIG_PATH, player.hl.config, player)
    end)
end

-- number
addConfigCmd("hl_suitvolume",     "Suit volume",                              "suitvolume", tonumber,   "0–255")

-- boolean
addConfigCmd("hl_allowviewkick",  "Viewkicking",                              "viewkick",   parseOnOff, "1/0")
addConfigCmd("hl_autowepswitch",  "(un-coded in) Automatic weapon switching", "autoswitch", parseOnOff, "1/0")
addConfigCmd("hl_printkillfeed",  "Killfeed",                                 "killfeed",   parseOnOff, "1/0")
addConfigCmd("hl_flipscrolling",  "Inverted scroll wheel direction",          "scrwheel",   parseOnOff, "1/0")
addConfigCmd("hl_ohthatsgoreofmy",  "Gore of my comfort character",           "fangdeath",  parseOnOff, "1/0")
addConfigCmd("hl_nagtoggle",  "Gore of my comfort character",                 "fangnag",    parseOnOff, "1/0", true)

-- fixed-point
addConfigCmd("hl_pitchspeed",     "Look up speed",                            "pitchspeed", parseFixed, "number")
addConfigCmd("hl_yawspeed",       "Rotation speed",                           "yawspeed",   parseFixed, "number")
addConfigCmd("hl_crosshairscale", "Crosshair scale",                          "chairscale", parseFixed, "positive number") 

HL.SKILL = loadTableFromFile(HL.SKILL_PATH,
{
    easy = {
        agrunt = {
            health = 60,
            dmg = {
                punch = 10,
            },
        },
        apache = {
            health = 150,
        },
        barney = {
            health = 35,
        },
        bullsquid = {
            health = 40,
            dmg = {
                bite = 15,
                whip = 25,
                spit = 10,
            },
        },
        bigmomma = {
            health = {
                factor = "1.0",
            },
            dmg = {
                slash = 50,
                blast = 100,
            },
            radius = {
                blast = 250,
            },
        },
        gargantua = {
            health = 800,
            dmg = {
                slash = 10,
                fire = 3,
                stomp = 50,
            },
        },
        hassassin = {
            health = 30,
        },
        headcrab = {
            health = 10,
            dmg = {
                bite = 5,
            },
        },
        hgrunt = {
            health = 50,
            kick = 5,
            pellets = 3,
            gspeed = 400,
        },
        houndeye = {
            health = 20,
            dmg = {
                blast = 10,
            },
        },
        islave = {
            health = 30,
            dmg = {
                claw = 8,
                clawrake = 25,
                zap = 10,
            },
        },
        ichthyosaur = {
            health = 200,
            shake = 20,
        },
        leech = {
            health = 2,
            dmg = {
                bite = 2,
            },
        },
        controller = {
            health = 60,
            dmgzap = 15,
            speedball = 650,
            dmgball = 3,
        },
        nihilanth = {
            health = 800,
            zap = 30,
        },
        scientist = {
            health = 20,
            heal = 25,
        },
        snark = {
            health = 2,
            dmg = {
                bite = 10,
                pop = 5,
            },
        },
        zombie = {
            health = 50,
            dmg = {
                one_slash = 10,
                both_slash = 25,
            },
        },
        turret = {
            health = 50,
        },
        miniturret = {
            health = 40,
        },
        sentry = {
            health = 40,
        },
        plr = {
            crowbar = 10,
            ["9mm"] = {
                bullet = 8,
            },
            ["357"] = {
                bullet = 40,
            },
            ["9mmAR"] = {
                bullet = 5,
                grenade = 100,
            },
            buckshot = 5,
            xbow = {
                bolt_client = 10,
                bolt_monster = 50,
            },
            rpg = 100,
            gauss = 20,
            egon = {
                narrow = 6,
                wide = 14,
            },
            hand = {
                grenade = 100,
            },
            satchel = 150,
            tripmine = 150,
        },
        ["12mm"] = {
            bullet = 8,
        },
        ["9mmAR"] = {
            bullet = 3,
        },
        ["9mm"] = {
            bullet = 5,
        },
        hornet = {
            dmg = 4,
        },
        monster = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
        player = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
    },
    normal = {
        agrunt = {
            health = 90,
            dmg = {
                punch = 20,
            },
        },
        apache = {
            health = 250,
        },
        barney = {
            health = 35,
        },
        bullsquid = {
            health = 40,
            dmg = {
                bite = 25,
                whip = 35,
                spit = 10,
            },
        },
        bigmomma = {
            health = {
                factor = "1.5",
            },
            dmg = {
                slash = 60,
                blast = 120,
            },
            radius = {
                blast = 250,
            },
        },
        gargantua = {
            health = 800,
            dmg = {
                slash = 30,
                fire = 5,
                stomp = 100,
            },
        },
        hassassin = {
            health = 50,
        },
        headcrab = {
            health = 10,
            dmg = {
                bite = 10,
            },
        },
        hgrunt = {
            health = 50,
            kick = 10,
            pellets = 5,
            gspeed = 600,
        },
        houndeye = {
            health = 20,
            dmg = {
                blast = 15,
            },
        },
        islave = {
            health = 30,
            dmg = {
                claw = 10,
                clawrake = 25,
                zap = 10,
            },
        },
        ichthyosaur = {
            health = 200,
            shake = 35,
        },
        leech = {
            health = 2,
            dmg = {
                bite = 2,
            },
        },
        controller = {
            health = 60,
            dmgzap = 25,
            speedball = 800,
            dmgball = 4,
        },
        nihilanth = {
            health = 800,
            zap = 30,
        },
        scientist = {
            health = 20,
            heal = 25,
        },
        snark = {
            health = 2,
            dmg = {
                bite = 10,
                pop = 5,
            },
        },
        zombie = {
            health = 50,
            dmg = {
                one_slash = 20,
                both_slash = 40,
            },
        },
        turret = {
            health = 50,
        },
        miniturret = {
            health = 40,
        },
        sentry = {
            health = 40,
        },
        plr = {
            crowbar = 10,
            ["9mm"] = {
                bullet = 8,
            },
            ["357"] = {
                bullet = 40,
            },
            ["9mmAR"] = {
                bullet = 5,
                grenade = 100,
            },
            buckshot = 5,
            xbow = {
                bolt_client = 10,
                bolt_monster = 50,
            },
            rpg = 100,
            gauss = 20,
            egon = {
                narrow = 6,
                wide = 14,
            },
            hand = {
                grenade = 100,
            },
            satchel = 150,
            tripmine = 150,
        },
        ["12mm"] = {
            bullet = 10,
        },
        ["9mmAR"] = {
            bullet = 4,
        },
        ["9mm"] = {
            bullet = 5,
        },
        hornet = {
            dmg = 5,
        },
        monster = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
        player = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
    },
    hard = {
        agrunt = {
            health = 120,
            dmg = {
                punch = 20,
            },
        },
        apache = {
            health = 400,
        },
        barney = {
            health = 35,
        },
        bullsquid = {
            health = 120,
            dmg = {
                bite = 25,
                whip = 35,
                spit = 15,
            },
        },
        bigmomma = {
            health = {
                factor = "2",
            },
            dmg = {
                slash = 70,
                blast = 160,
            },
            radius = {
                blast = 275,
            },
        },
        gargantua = {
            health = 1000,
            dmg = {
                slash = 30,
                fire = 5,
                stomp = 100,
            },
        },
        hassassin = {
            health = 50,
        },
        headcrab = {
            health = 20,
            dmg = {
                bite = 10,
            },
        },
        hgrunt = {
            health = 80,
            kick = 10,
            pellets = 6,
            gspeed = 800,
        },
        houndeye = {
            health = 30,
            dmg = {
                blast = 15,
            },
        },
        islave = {
            health = 60,
            dmg = {
                claw = 10,
                clawrake = 25,
                zap = 15,
            },
        },
        ichthyosaur = {
            health = 400,
            shake = 50,
        },
        leech = {
            health = 2,
            dmg = {
                bite = 2,
            },
        },
        controller = {
            health = 100,
            dmgzap = 35,
            speedball = 1000,
            dmgball = 5,
        },
        nihilanth = {
            health = 1000,
            zap = 50,
        },
        scientist = {
            health = 20,
            heal = 25,
        },
        snark = {
            health = 2,
            dmg = {
                bite = 10,
                pop = 5,
            },
        },
        zombie = {
            health = 100,
            dmg = {
                one_slash = 20,
                both_slash = 40,
            },
        },
        turret = {
            health = 60,
        },
        miniturret = {
            health = 50,
        },
        sentry = {
            health = 50,
        },
        plr = {
            crowbar = 10,
            ["9mm"] = {
                bullet = 8,
            },
            ["357"] = {
                bullet = 40,
            },
            ["9mmAR"] = {
                bullet = 5,
                grenade = 100,
            },
            buckshot = 5,
            xbow = {
                bolt_client = 10,
                bolt_monster = 50,
            },
            rpg = 100,
            gauss = 20,
            egon = {
                narrow = 6,
                wide = 14,
            },
            hand = {
                grenade = 100,
            },
            satchel = 150,
            tripmine = 150,
        },
        ["12mm"] = {
            bullet = 10,
        },
        ["9mmAR"] = {
            bullet = 5,
        },
        ["9mm"] = {
            bullet = 8,
        },
        hornet = {
            dmg = 8,
        },
        monster = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
        player = {
            head = 3,
            chest = 1,
            stomach = 1,
            arm = 1,
            leg = 1,
        },
    },
})