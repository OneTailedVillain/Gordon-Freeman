-- Reserve a new mobj type for the spray projectile
freeslot("MT_SPRAY", "S_HL1_SPRAYSTATE", "S_HL1_FLASHSTATE", "SPR_HL1SPRAY", "MT_HLFLASHLIGHTBEAM", "MT_HLFLASHLIGHTPOINT", "SPR_HL1FLASHLIGHT")

states[S_HL1_SPRAYSTATE] = {
	sprite = SPR_HL1SPRAY,
	frame = FF_ADD|A,
	tics = -1,
	nextstate = S_HL1_SPRAYSTATE
}

mobjinfo[MT_SPRAY] = {
spawnstate = S_HL1_SPRAYSTATE,
spawnhealth = 100,
deathstate = S_NULL,
speed = 4*FRACUNIT,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY,
}

states[S_HL1_FLASHSTATE] = {
	sprite = SPR_HL1FLASHLIGHT,
	frame = FF_FULLBRIGHT | FF_PAPERSPRITE | FF_ADD | FF_TRANS50 | A,
	tics = -1,
	nextstate = S_HL1_FLASHSTATE
}

mobjinfo[MT_HLFLASHLIGHTBEAM] = {
spawnstate = S_HL1_SPRAYSTATE,
spawnhealth = 100,
deathstate = S_NULL,
speed = 64*FRACUNIT,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY | MF_PAPERCOLLISION,
}

mobjinfo[MT_HLFLASHLIGHTPOINT] = {
spawnstate = S_HL1_FLASHSTATE,
spawnhealth = 100,
deathstate = S_NULL,
radius = 1*FRACUNIT,
height = 2*FRACUNIT,
dispoffset = 4,
flags = MF_NOGRAVITY | MF_PAPERCOLLISION,
}

if not SPRAY then
	rawset(_G, "SPRAY", {})
end
SPRAY.sprays = {}

-- helper function
function SPRAY.addSpray(name, sprite, frame, frameflags, iscolorable)
    SPRAY.sprays[name] = {
		sprite      = sprite or SPR_HL1SPRAY,
        frame       = frame,
        frameflags  = frameflags == nil and FF_ADD or frameflags,
        iscolorable = iscolorable ~= false  -- default true if nil
    }
end

SPRAY.addSpray("pldecal",    SPR_HL1SPRAY,   0,  FF_ADD)
SPRAY.addSpray("v_1",        SPR_HL1SPRAY,   1,  FF_ADD)
SPRAY.addSpray("tiki",       SPR_HL1SPRAY,   2,  FF_ADD)
SPRAY.addSpray("splatt",     SPR_HL1SPRAY,   3,  FF_ADD)
SPRAY.addSpray("smiley",     SPR_HL1SPRAY,   4,  FF_ADD)
SPRAY.addSpray("chuckskull", SPR_HL1SPRAY,   5,  FF_ADD)
SPRAY.addSpray("skull",      SPR_HL1SPRAY,   6,  FF_ADD)
SPRAY.addSpray("lambda",     SPR_HL1SPRAY,   7,  FF_ADD)
SPRAY.addSpray("gun1",       SPR_HL1SPRAY,   8,  FF_ADD)
SPRAY.addSpray("devl1",      SPR_HL1SPRAY,   9,  FF_ADD)
SPRAY.addSpray("chick1",     SPR_HL1SPRAY,   10, FF_ADD)
SPRAY.addSpray("camp1",      SPR_HL1SPRAY,   11, FF_ADD)
SPRAY.addSpray("andre",      SPR_HL1SPRAY,   12, FF_ADD)
SPRAY.addSpray("8ball1",     SPR_HL1SPRAY,   13, FF_ADD)
SPRAY.addSpray("degagedi",   SPR_HL1SPRAY,   14, FF_ADD)

-- Hide ourselves for the moment
addHook("MobjSpawn", function(mobj)
	mobj.flags2 = $ | MF2_DONTDRAW
end, MT_SPRAY)

-- Fly forward until we hit something
local function HL_FlashlightStep(mobj, maxdist, nokill)
	if mobj.endcast then return end
    -- give the shooter noclip while we’re tracing
    local shooter = mobj.target
	if shooter and shooter.valid then
		shooter.flags = $ | MF_NOCLIP
	end

    -- compute the step‑distance per tick (fixed‑point)
    -- ignore mobj.scale here so every tick moves the same amount
    local speed_fp = mobjinfo[mobj.type].speed

    -- fuse = ceil(maxdist / speed_fp)
    local fuse = (maxdist + speed_fp - 1) / speed_fp

    local didhit = false
    for i = 1, fuse do
        if not mobj or not mobj.valid then
            break
        end

        -- P_RailThinker returns true on impact
        if P_RailThinker(mobj) or mobj.endcast then
            didhit = true
            break
        end
    end

    if not didhit and not nokill then
        P_KillMobj(mobj, nil, nil, DMG_INSTAKILL)
    end

    -- restore shooter’s flags
	if shooter and shooter.valid then
		shooter.flags = shooter.flags & ~MF_NOCLIP
	end
    return didhit
end

local function FixedHypot3(x, y, z)
	return FixedHypot(FixedHypot(x, y), z)
end

addHook("MobjThinker", function(mobj)
    -- only run once, at spawn
    if mobj.tics == 1 then
        local pmo = mobj.target
        mobj.z = pmo.player.viewheight / 2 + pmo.z

        -- record that we haven’t hit anything yet
        mobj.endcast = false

        -- now *rebuild* momx/momy/momz so that the beam always moves
        -- at the *base* speed, not scaled.  We normalize the old mom
        -- to a unit vector and then multiply by speed_fp.

        local speed_fp = mobjinfo[mobj.type].speed
        -- get current direction unit vector (in fixed point)
        local mag = FixedHypot3(mobj.momx, mobj.momy, mobj.momz)
        if mag > 0 then
            local ux = FixedDiv(mobj.momx, mag)
            local uy = FixedDiv(mobj.momy, mag)
            local uz = FixedDiv(mobj.momz, mag)
            -- rebuild mom so every tick moves exactly `speed_fp`
            mobj.momx = FixedMul(ux, speed_fp)
            mobj.momy = FixedMul(uy, speed_fp)
            mobj.momz = FixedMul(uz, speed_fp)
			mobj.scale = FRACUNIT
        end
    end

    -- now do the ray‑trace for up to 4096 units
    HL_FlashlightStep(mobj, 4096 * FRACUNIT)
end, MT_SPRAY)

addHook("MobjThinker", function(mobj)
    -- only run once, at spawn
    if not mobj.flashinitted then
		mobj.flags2 = $ | MF2_DONTDRAW
		mobj.sprite = SPR_HL1FLASHLIGHT
        -- lift it up to mid‑chest
        local pmo = mobj.target
        mobj.z = pmo.player.viewheight / 2 + pmo.z

        -- record that we haven’t hit anything yet
        mobj.endcast = false

        -- now *rebuild* momx/momy/momz so that the beam always moves
        -- at the *base* speed, not scaled.  We normalize the old mom
        -- to a unit vector and then multiply by speed_fp.

        local speed_fp = mobjinfo[mobj.type].speed
        -- get current direction unit vector (in fixed point)
        local mag = FixedHypot3(mobj.momx, mobj.momy, mobj.momz)
        if mag > 0 then
            local ux = FixedDiv(mobj.momx, mag)
            local uy = FixedDiv(mobj.momy, mag)
            local uz = FixedDiv(mobj.momz, mag)
            -- rebuild mom so every tick moves exactly `speed_fp`
            mobj.momx = FixedMul(ux, speed_fp)
            mobj.momy = FixedMul(uy, speed_fp)
            mobj.momz = FixedMul(uz, speed_fp)
			mobj.scale = FRACUNIT

			-- now do the ray‑trace for up to 4096 units
			HL_FlashlightStep(mobj, 4096 * FRACUNIT)
			if not (mobj and mobj.valid) then return end
			mobj.momx, mobj.momy, mobj.momz = 0, 0, 0
        end
		mobj.flashinitted = true
	else
		P_RemoveMobj(mobj)
    end
end, MT_HLFLASHLIGHTBEAM)

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

-- On wall collision: stick the sprite, show, and stop thinking
local function SprayHitWall(mobj, thing, line)
    if not mobj.touchwall then
        mobj.touchwall = true
        mobj.flags = mobj.flags | MF_PAPERCOLLISION | MF_NOCLIP | MF_NOCLIPHEIGHT | MF_NOTHINK
		mobj.flags2 = $ & ~MF2_DONTDRAW

        -- compute exact wall-impact point
        local x, y = P_ClosestPointOnLine(mobj.x, mobj.y, line)
		local side = P_PointOnLineSide(mobj.x, mobj.y, line)
		mobj.angle = line.angle + (ANGLE_180 * side)
        P_SetOrigin(mobj, x, y, mobj.z)

        local plspray = mobj.tracer.player.hl.spray
        local sprayName = (plspray and plspray.spray) or "lambda"
        local sprayEntry = SPRAY.sprays[sprayName] or SPRAY.sprays["lambda"]

        -- set proper state and play spraying sound
        mobj.frame = FF_PAPERSPRITE | sprayEntry.frameflags | sprayEntry.frame
        mobj.sprite = SPR_HL1SPRAY
		local color = ((plspray and plspray.color) == nil and 
					  skincolors[mobj.tracer and mobj.tracer.color or default_color].ramp[7]) 
					  or (plspray and plspray.color)
		color = stripOuterQuotes($)
		mobj.translation = "COLORSCALECLR" .. color
		S_StartSound(mobj, sfx_hlspra)

        -- stop movement and get rid of tracer
        mobj.momx = 0
        mobj.momy = 0
		mobj.momz = 0
		
		local hl = mobj.tracer and mobj.tracer.player and mobj.tracer.player.hl
		hl.spraydelay = cv_hldecaldelay.value * TICRATE
		if hl.sprayobject and hl.sprayobject.valid then
			P_RemoveMobj(hl.sprayobject)
		end
		hl.sprayobject = mobj
		
		mobj.tracer = nil
    end
end
addHook("MobjMoveBlocked", SprayHitWall, MT_SPRAY)

local function GoldSrcFlashlight(mobj, thing, line)
	if not line then return end
	mobj.flags = $ | MF_NOCLIP | MF_NOCLIPHEIGHT
	-- compute exact wall-impact point
	local x, y = P_ClosestPointOnLine(mobj.x, mobj.y, line)
	mobj.target.player.hl.flashlightbeam = (not $ or not $.valid) and P_SpawnMobj(x, y, mobj.z, MT_HLFLASHLIGHTPOINT) or $
	local flash = mobj.target.player.hl.flashlightbeam
	P_SetOrigin(flash, x, y, mobj.z)
	flash.angle = line.angle
	mobj.endcast = true
end
addHook("MobjMoveBlocked", GoldSrcFlashlight, MT_HLFLASHLIGHTBEAM)

COM_AddCommand("hl_logofile", function(player, sprayName)
    if gamestate ~= GS_LEVEL or not player then return end
	if not player.hl then return end

    local sprays = SPRAY.sprays
    if not sprayName then
        CONS_Printf(player, "Usage: hl_logofile <spray>")
        CONS_Printf(player, "Available options:")
        for name,_ in pairs(sprays) do
            CONS_Printf(player, "  "..name)
        end
        return
    end

    if sprays[sprayName] then
        player.hl.spray.spray = sprayName
    else
        CONS_Printf(player, "Invalid spray '"..sprayName.."'")
        CONS_Printf(player, "Available options:")
        for name,_ in pairs(sprays) do
            CONS_Printf(player, "  "..name)
        end
    end

	if consoleplayer != player then return end
    saveTableToFile(HL.SPRAY_CONFIG_PATH, player.hl.spray, player)
end)

COM_AddCommand("hl_logocolor", function(player, colorr, g, b)
	if gamestate ~= GS_LEVEL then return end
	if not player then return end
	if not player.hl then return end
	if not colorr then
		CONS_Printf(player, 'Usage: hl_logofile <skincolor>/<palette index>/<r, g, b>/"skincolor"')
		return
	end
	local tonum = tonumber(colorr)
	if not tonum then
		if colorr == "skincolor"
			player.hl.spray.color = nil
			CONS_Printf(player, "Spray color will now always use your skincolor.")
		else
			local whatclr = R_GetColorByName(colorr)
			if not whatclr then CONS_Printf(player, "'" .. colorr .. "' isn't a valid color!") return end
			player.hl.spray.color = skincolors[whatclr].ramp[7]
			CONS_Printf(player, "Spray color set to skincolor " .. colorr)
		end
	else
		if not g then
			CONS_Printf(player, "Spray color set to palette index " .. colorr)
			player.hl.spray.color = tonum
		else
			local r = tonum
			local g = tonumber(g)
			local b = tonumber(b)
			if r > 255 then
				CONS_Printf(player, r .. " is too high! (Expected range 0 - 255)")
			elseif g > 255 then
				CONS_Printf(player, g .. " is too high! (Expected range 0 - 255)")
			elseif b > 255 then
				CONS_Printf(player, b .. " is too high! (Expected range 0 - 255)")
			end
			local pal = color.rgbToPalette(r, g, b)
			local readable = string.format("%06x", color.packRgb(r, g, b))
			CONS_Printf(player, "Spray color set to #" .. readable)
			player.hl.spray.color = pal
		end
	end


	if consoleplayer != player then return end
	saveTableToFile(HL.SPRAY_CONFIG_PATH, player.hl.spray, player)
end)