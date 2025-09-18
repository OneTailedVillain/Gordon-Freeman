-- Utility function for safe slot freeing
local function SafeFreeSlot(...)
	for _, slot in ipairs({...}) do
		if not rawget(_G, slot) then
			freeslot(slot) -- Ensure we don't accidentally overlap existing freeslots
		end
	end
end

SafeFreeSlot("MT_FREEMDEATHCAM", "MT_FREEMCORPSE", "sfx_frbeep", "S_PLAY_FREEDYING1", "S_PLAY_FREEDYING2", "S_PLAY_FREEDYING3", "S_PLAY_FREEDEAD", "SPR2_DYIN")

states[S_PLAY_FREEDYING1] = {
	sprite = SPR_PLAY,
	frame = FF_ANIMATE|SPR2_DYIN,
	tics = 40,
	var1 = 4,
	var2 = 10,
	nextstate = S_PLAY_FREEDEAD
}

states[S_PLAY_FREEDEAD] = {
	sprite = SPR_PLAY,
	frame = SPR2_DEAD,
	tics = -1,
	nextstate = S_PLAY_FREEDEAD
}

mobjinfo[MT_FREEMDEATHCAM] = {
	spawnstate = S_INVISIBLE,
	spawnhealth = 100,
	deathstate = S_NULL,
	speed = 0,
	radius = 2*FRACUNIT,
	height = 2*FRACUNIT,
	dispoffset = 4,
	flags = MF_SCENERY,
}

mobjinfo[MT_FREEMCORPSE] = {
    spawnstate = S_PLAY_FREEDYING1,
    spawnhealth = 100,
    deathstate = S_NULL,
    speed = 0,
    radius = 2*FRACUNIT,
    height = 2*FRACUNIT,
    dispoffset = 4,
}

-- Fix some other chuckler's code
if not customdeaths then
	rawset(_G, "customdeaths", {})
end

customdeaths["kombifreeman"] = true

local damageTypeMaps = {
	[DMG_CRUSHED] = HL.DMG.CRUSH,
}

-- Hook for handling player death
addHook("MobjDeath", function(mobj, inflictor, source, damageType)
	if mobj.skin ~= "kombifreeman" then return end

	if (gametyperules & GTR_DEATHPENALTY) then
		if mobj.player.score >= 50 then
			P_AddPlayerScore(mobj.player, -50)
		else
			mobj.player.score = 0
		end
	end

	if (damageType & DMG_INSTAKILL) then
		HL_HandleKillFeed(mobj, source, inflictor, damageTypeMaps[damageType] or 0)
	end

	mobj.player.awayviewtics = TICRATE*2
	mobj.player.awayviewmobj = P_SpawnMobjFromMobj(mobj,
	0,
	0,
	0,
	-- mobj.player.height - 8 * FRACUNIT,
	MT_FREEMDEATHCAM)
	mobj.player.awayviewaiming = mobj.player.aiming
	mobj.player.viewrollangle = ANGLE_90-ANG10
	mobj.state = S_INVISIBLE
	mobj.hl.health = 0
	FVox_WarnDamage("HEV_DEAD0", mobj.player)
	local killcam = mobj.player.awayviewmobj
	killcam.radius = mobj.radius
	killcam.height = mobj.radius * 2
	-- killcam.height = mobj.height
	killcam.momx = mobj.momx
	killcam.momy = mobj.momy
	killcam.scale = mobj.scale
	killcam.momz = mobj.momz + (mobj.killfallvel or 0) + 3 * killcam.scale
	killcam.angle = mobj.angle
	killcam.parent = mobj
	mobj.child = killcam
	mobj.player.killcam = killcam

	if gametype != GT_SAXAMM then
		mobj.corpse = P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_FREEMCORPSE)
		local corpse = mobj.corpse
		corpse.radius = mobj.radius
		corpse.height = mobj.radius*2
		corpse.color = mobj.color
		corpse.angle = mobj.angle
		corpse.z = $ - (mobj.height - 8 * FRACUNIT)
		corpse.skin = "kombifreeman"
		corpse.state = S_PLAY_FREEDYING1
		corpse.momz = mobj.momz + (mobj.killfallvel or 0)
		corpse.fuse = cv_corpselifetime.value*TICRATE
	end

	-- De-init objects parented to the player if there were any this life
	local hl = mobj.player and mobj.player.hl
	maybeDoKillMsg(mobj, inflictor, source, damageType)
	if not hl or not hl.objects then return true end

	for listName, objectList in pairs(hl.objects) do
		if type(objectList) == "table" then
			for k, submobj in pairs(objectList) do
				if submobj and submobj.valid and submobj.state != S_DEATHSTATE then
					P_RemoveMobj(submobj)
				end
			end
			hl.objects[listName] = {} -- clear the sub-list
		end
	end

	return true
end, MT_PLAYER)

local function FixedSquare(a)
	return FixedMul(a, a)
end

addHook("MobjThinker", function(mobj)
	/*
	-- immediately killing momentum when your dead, rotting corpse hits the floor IS technically accurate, but it stinks and is bad and FUUUCK!!! I HATE IT!!!
	if gametype == GT_SAXAMM and mobj.z == mobj.floorz then
		mobj.momx = 0
		mobj.momy = 0
	end
	*/
	local curfric = (mobj.floorrover and mobj.floorrover.sector and mobj.floorrover.sector.friction) or mobj.subsector.sector.friction
	mobj.friction = FixedMul(curfric, FRACUNIT*46/50)
	if not (mobj.parent and mobj.parent.valid) or (mobj.parent and mobj.parent.player and mobj.parent.player.quittime) then
		P_KillMobj(mobj)
		return
	end
end, MT_FREEMDEATHCAM)

addHook("MobjThinker", function(mobj)
	if not mobj.fuse then
		P_KillMobj(mobj)
	end
end, MT_FREEMCORPSE)

-- ThinkFrame Hook
addHook("ThinkFrame", function()
	local killfeed = HL.killfeed

	for id, info in pairs(killfeed) do
		if type(info) != "table" or not info.time or info.time <= 0 then
			killfeed[id] = nil
		else
			info.time = $ - 1
		end
	end

	for player in players.iterate do
		if not player.mo then continue end
		if player.mo.skin != "kombifreeman" then continue end
		if player.playerstate == PST_DEAD then
			local mo = player.mo
			local gravity = P_GetMobjGravity(mo)

			player.viewrollangle = ANGLE_90-ANG10
			player.awayviewaiming = player.cmd.aiming<<16
			if player.awayviewmobj and player.awayviewmobj.valid then
				player.awayviewmobj.angle = player.cmd.angleturn<<16
			end
			local corpse = player.mo.corpse
			if corpse and corpse.valid then
				corpse.fuse = cv_corpselifetime.value*TICRATE
				if not (corpse and corpse.valid) then return end
				if not (player.awayviewmobj and player.awayviewmobj.valid) then return end
				P_MoveOrigin(corpse, player.awayviewmobj.x,player.awayviewmobj.y,corpse.z)
			end
			if not (gametyperules & GTR_RESPAWNDELAY) then
				-- Dead timer logic
				local timer = player.hl1deadtimer or 0
				if timer > 106 then
					player.deadtimer = timer - (107 + TICRATE)
				else
					player.deadtimer = 0
				end

				if ((player.cmd.buttons & BT_JUMP) or player.hlcmds.jump) and timer > TICRATE then
					player.deadtimer = 100*TICRATE
					player.cmd.buttons = 0
					player.hlcmds.jump = nil
				end

				player.hl1deadtimer = timer + 1
			end
			player.awayviewtics = TICRATE * 2
		elseif player.playerstate == PST_REBORN then
			-- ensure objects get decoupled if for SOME reason player.mo doesn't refresh
			if player.mo.child and player.mo.child.valid then
				player.mo.child.parent = nil
			end
			player.mo.corpse = nil
		end
	end
end)

-- Hook for handling damage direction
addHook("MobjDamage", function(target, inflictor, source, damage, damageType)
	if inflictor then
		target.player.hl1dmgdir = FixedInt(AngleFixed(R_PointToDist2(target.x, target.y, inflictor.x, inflictor.y)))
	end
end, MT_PLAYER)