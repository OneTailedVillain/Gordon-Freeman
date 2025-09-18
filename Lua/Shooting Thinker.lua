local function warn(player, str)
	CONS_Printf(player, "\130WARNING: \128"..str);
end

local skin = "kombifreeman"
local fire = BT_ATTACK
local altfire = BT_FIRENORMAL

local theproj = MT_NULL

local kombilastseen
local kombiseentime

local function HL_GetBulletDamage(mobj, stats)
	if stats.damagemin and stats.damagemax then
		local max = stats.damagemax
		local min = stats.damagemin
		local increment = stats.damageincs
		local divisor = increment or min
		return (P_RandomByte() % (max / divisor) + 1) * divisor
	else
		return stats.damage or 0
	end
end

local validcount = 0
local soundtarget = nil

-- Dummy line opening logic
local function P_LineOpening(line)
    if not (line.flags & ML_TWOSIDED) then return 0 end
    -- TODO: sector height shit
    return 1 -- nonzero = open
end

local function P_RecursiveSound(sec, soundblocks)
    if sec.validcount == validcount and sec.soundtraversed <= soundblocks + 1 then
        return
    end

    sec.validcount = validcount
    sec.soundtraversed = soundblocks + 1
    sec.soundtarget = soundtarget

    for i = 1, sec.linecount do
        local line = sec.lines[i]
        if not (line.flags & ML_TWOSIDED) then continue end

        local openrange = P_LineOpening(line)
        if openrange <= 0 then continue end

        local other = nil
        if line.frontsector == sec then
            other = line.backsector
        else
            other = line.frontsector
        end

        if (line.flags & ML_SOUNDBLOCK) ~= 0 then
            if soundblocks == 0 then
                P_RecursiveSound(other, 1)
            end
        else
            P_RecursiveSound(other, soundblocks)
        end
    end
end

local function P_NoiseAlert(target, emmiter)
    soundtarget = target
    validcount = validcount + 1
    P_RecursiveSound(emmiter.subsector.sector, 0)
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

local function contains(mainStr, subStr)
	return string.find(mainStr, subStr) ~= nil
end

-- Separate function to spawn a shot (without input or animation checks)
local function HL_FireProjectile(player, mystats, mode)
	if player.playerstate == PST_DEAD then return end
	local weaponID = player.hl.curwep
	local stats = HLItems[weaponID]

	local clipMode = (mode == "secondary" and stats.altusesprimaryclip) and "primary" or mode
	local curModeStats = HLItems[weaponID][clipMode]
	local clipSize = curModeStats.clipsize or -1
	local ammoType = curModeStats.ammo
	local reserveCount = player.hlinv.ammo[ammoType] or 0

	-- If the weapon defines a clip (> -1), draw from it; else if ammo pool exists (> -1), draw from reserve; otherwise infinite
	local useClip = nil
	if clipSize > -1 then
		useClip = true
	elseif clipSize == -1 and ammoType and reserveCount >= 0 then
		useClip = false
	end

	local clip
	if useClip then
		clip = player.hlinv.wepclips[weaponID][clipMode]
	elseif useClip == false then
		clip = reserveCount
	else
		clip = INT32_MAX
	end
	if clip == nil then clip = 0 end

	-- Abort early if player doesn't own the weapon
	if not player.hlinv.weapons[weaponID] then return end

	-- Check ammo/clip availability
	if (clip < 1) and not mystats.neverdenyuse then
		-- Dryfire prevention only applies if we're not already in delay
		local delayed = (mode == "primary" and player.hl1weapondelay)
					or (mode == "secondary" and player.weaponaltdelay)

		if not delayed then
			S_StartSound(player.mo, sfx_hdryfi)
			player.hl = $ or {}
			player.hl.noshoot = true
			-- Make sure we count the shot anyways
			if player.currentvolley then
				player.currentvolley = $ - 1
			end
		end
		return
	end

	-- Interrupt reloading if we're in one
	if player.kombireloading then
		player.kombireloading = 0
		player.hl1weapondelay = 0
		player.weaponaltdelay = 0
	end

	-- Prevent firing if there is an active weapon delay
	if mode == "primary" and player.hl1weapondelay then return end
	if mode == "secondary" and player.weaponaltdelay then return end

	-- Make sure we DON'T crash servers.
	if curModeStats.parenttofirer and player.hl.objects and player.hl.objects[weaponID] then
		local objects = player.hl.objects[weaponID]

		if #objects >= (mystats.maxdeploy or HLItems[ammotype].max * 6 or 30) then
			S_StartSound(player.mo, sfx_hldeny)
			player.currentvolley = 0
			player.hl.noshoot = true
			return
		end
	end

	-- Initialize volley count if not already set
	if not player.currentvolley then
		player.currentvolley   = mystats.volley or 1
		player.volleymode      = mode
		player.volleyShotIndex = 1

		if player.firstVolleyDone == nil then
			player.firstVolleyDone = false
		end

		local chosenOffset = 0
		if not player.firstVolleyDone then
			chosenOffset = mystats.fireoffset or 0
		else
			chosenOffset = mystats.refireoffset or mystats.fireoffset or 0
		end
		player.hl1fireoffset = chosenOffset

		local newAnim = ((clip - (mystats.shotcost or 0)) <= 0)
		              and (mode .. "fire empty")
		              or (mode .. "fire normal")
		if weaponID ~= "doomchaingun" then
			HL_ChangeViewmodelState(player, newAnim, newAnim)
		end

		if chosenOffset > 0 then
			-- Skip firing this tick
			return
		end
	end

	if player.hl.config.viewkick and mystats.kickback then
		local kickback = mystats.kickback
		local sign
		if mystats.kickbackcanflip then
			sign = P_RandomChance(FRACUNIT/2) and -1 or 1
		else
			sign = 1
		end
		kickback = $ * sign
		player.hl.punchangle.x = FixedAngle(kickback) >> 16
	end

	-- Setup projectile info
	local ammotype = mystats.ammo
	local projectile = mystats.shootmobj or (HLItems[ammotype] and HLItems[ammotype].shootmobj) or MT_HL1_BULLET
	local theproj

	for i = 1, (mystats.pellets or 1) do
		if mystats.parenttofirer then
			player.hl.objects = $ or {}
			player.hl.objects[weaponID] = $ or {}
			table.insert(player.hl.objects[weaponID], theproj)
		end
		if not mystats.refireusesspread or player.refire then
			local ogangle, ogaiming = player.mo.angle, player.cmd.aiming << 16
			local hspr = FixedMul(P_RandomFixed() - FRACUNIT/2, (mystats.horizspread or 0) * 2)
			local vspr = FixedMul(P_RandomFixed() - FRACUNIT/2, (mystats.vertspread or 0) * 2)
			player.mo.angle = $ + FixedAngle(hspr)
			player.aiming = $ + FixedAngle(vspr)
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
			player.mo.angle, player.aiming = ogangle, ogaiming
		else
			theproj = P_SpawnPlayerMissile(player.mo, projectile)
		end

		if theproj and theproj.valid then
			theproj.shooter = player
			theproj.firemode = mode
			theproj.target = player.mo
			theproj.stats = mystats
			theproj.wepstats = HLItems[weaponID]
			theproj.hl1damage = HL_GetBulletDamage(theproj, mystats)
			if HL.DoDoomguyAccomodations then
				theproj.damage = theproj.hl1damage
			end
			theproj.z = $ + ((player.viewheight * P_MobjFlip(player.mo)) / 2)
			if mystats.israycaster then
				theproj.dist = (mystats.maxdistance or MISSILERANGE) /  HL.BULLETSPEED
			else
				theproj.fuse = player.hl.cooktime or mystats.fuse or 0
			end
			theproj.clip = clip
			if mystats.parenttofirer then
				player.hl.objects = $ or {}
				player.hl.objects[weaponID] = $ or {}
				table.insert(player.hl.objects[weaponID], theproj)
			end

			if mystats.carrymomentum then
				theproj.momx = $ + player.mo.momx
				theproj.momy = $ + player.mo.momy
				theproj.momz = $ + player.mo.momz
			end

			if HL.DoDoomguyAccomodations then
				theproj.dmomx, theproj.dmomy, theproj.dmomz = theproj.momx, theproj.momy, theproj.momz
			end
			
			if TOL_DOOM and (maptol & TOL_DOOM) and not contains(weaponID, "doom") then
				theproj.hl1damage = $ * 2
			end
		end
	end

	if stopthecount then return end

	-- Helper: get delay
	local function firstNumber(...)
		for i = 1, select("#", ...) do
			local v = select(i, ...)
			if type(v) == "number" then return v end
		end
		return 0
	end

	local nextDelay = firstNumber(mystats.firedelay)

	if player.volleyShotIndex < firstNumber(mystats.volley, 1) then
		nextDelay = firstNumber(mystats.volleyfiredelay, mystats.firedelay)
	else
		if not player.firstVolleyDone then
			nextDelay = firstNumber(mystats.firedelay)
		else
			nextDelay = firstNumber(mystats.refiredelay, mystats.firedelay)
		end
	end

	if mode == "primary" then
		player.hl1weapondelay = nextDelay
	else
		player.weaponaltdelay = nextDelay
	end

	-- Consume ammo
	HL_DecrementWeaponAmmo(player, mode == "secondary")

	-- Viewmodel animation and sound
	local chosenOffset = player.firstVolleyDone and (mystats.refireoffset or mystats.fireoffset) or (mystats.fireoffset or 0)
	local isEmpty = clip - (mystats.shotcost or 0) <= 0
	if not chosenOffset then
		local anim = isEmpty
		           and (mode .. "fire empty")
		           or (mode .. "fire normal")
		if weaponID ~= "doomchaingun" then
			HL_ChangeViewmodelState(player, anim, anim)
		end
	end

	if isEmpty and (reserveCount or 0) <= 0 then
		FVox_WarnDamage("HEV_AMO0", player)
	end

	if mystats.firesound then
		local sound_offset = (mystats.firesounds and mystats.firesounds > 1)
			and (P_RandomRange(1, mystats.firesounds) - 1)
			or 0
		S_StartSound(player.mo, mystats.firesound + sound_offset)
		-- P_NoiseAlert(player.mo, player.mo)
	end

	-- Volley tracking
	if player.currentvolley then
		player.currentvolley = $ - 1
	end

	if player.volleyShotIndex < (mystats.volley or 1) then
		player.volleyShotIndex = $ + 1
		player.hl1fireoffset = mystats.volleyfireoffset or mystats.fireoffset or 0
	else
		player.volleyShotIndex = nil
		player.currentvolley = nil
		player.firstVolleyDone = true
		player.volleymode = nil
	end

	player.refire = true
	
	return theproj
end

local function FireWeapon(player, mode)
	local mode = mode or "primary" -- Default to primary if not specified

	-- If we aren't supposed to be shooting, don't. (world peace solved!)
	if player.hl and ((player.hl.holdyourfire and mode == "primary") or player.hl.noshoot or player.hl1viewmdaction == "lower") then return end

	-- Use the current weapon's stats if available; otherwise, fall back to our trusty 9mm... Only if primary fire, though.
	local weaponID = player.hl.curwep
	if not weaponID then return end
	local _, whatis = HL_GetPrefix(weaponID)
	if tostring(whatis) != "weapon_" then
		-- warn("Invalid item prefix for current weapon! (Expected weapon_*, got '" .. tostring(whatis) .. "')")
		-- player.hl.curwep = "weapon_crowbar"
	end
	local mystats = HLItems[weaponID] and HLItems[weaponID][mode]

	-- Exit early if we still don't have valid stats
	if not mystats then return end

	-- Weapon selection and preparation
	if player.selectionlist and player.selectionlist["weapons"] and player.hl.wepmenu.isopen and mode == "primary" then
		local selectedWeapon = player.selectionlist["weapons"][player.hl.wepmenu.index]

		-- Check if the selected weapon is unselectable
		if not selectedWeapon or not HLItems[selectedWeapon.name] then
			-- If so, close the menu and do nothing extra
			player.hl.wepmenu.isopen = false
			player.hl.holdyourfire = true
			S_StartSound(player.mo, sfx_pwepen)
			return
		end

		if not mystats.doomwepswitch then
			HL_SwitchWeapon(player, selectedWeapon.name)
			player.hl.holdyourfire = true
		else
			player.hl.doomPending    = true
			player.hl.doomPendingWep = selectedWeapon.name
			HL_ChangeViewmodelState(player, "lower", "idle")
		end
			S_StartSound(player.mo, sfx_pwepen)
			player.hl.wepmenu.isopen = false
		return
	end

	-- Check if the weapon is available in inventory and has clips
    if not player.hlinv.wepclips[weaponID] then return end

	-- Either use clip or reserve depending on if clipsize is nil or -1
    local useClip
	local stats = HLItems[player.hl.curwep]
	local clipMode = (mode == "secondary" and stats.altusesprimaryclip) and "primary" or mode
	local curModeStats = HLItems[weaponID][clipMode]
    local clipSize = curModeStats.clipsize or -1
    local ammoType = curModeStats.ammo
    local reserveCount = player.hlinv.ammo[ammoType] or 0

	-- Break if we're in the weapon selection menu
	if player.kombipressingwpnkeys then return end

	-- Use the viewmodel from the weapon whose stats we are using
	local viewmodel = HLItems[HLItems[weaponID].viewmodel or "v_pistol"]

	if mode == "primary" and player.hl1weapondelay then return end
	if mode == "secondary" and player.weaponaltdelay then return end

	-- Run firing function, if available
	local firefunc = mystats.firefunc
	if firefunc and firefunc(player, mystats) then
		if mode == "primary" then
			player.hl1weapondelay = mystats.firedelay
		else
			player.weaponaltdelay = mystats.firedelay
		end
		return -- Exit without firing if firefunc returns true
	end

	-- Are we still waiting on the offset countdown?
	if player.hl1fireoffset and player.hl1fireoffset > 0 then
		player.hl1fireoffset = player.hl1fireoffset - 1
		return
	end

	-- If we're still in the "offset" period, decrement and bail out without spawning
	if player.hl1fireoffset then
		player.hl1fireoffset = player.hl1fireoffset - 1
		return
	end

	if mystats.cookable then
		if not player.hl.cooking then
			player.hl.cooking = true
			player.hl.cooktime = mystats.fuse
			HL_ChangeViewmodelState(player, "startcook", "primaryfire")
		elseif player.hl1viewmdaction == "cookloop" then
			player.hl.cooktime = $ - 1
		end
		return
	end

	HL_FireProjectile(player, mystats, mode)
end

local function StopFire(player, mode)
	local weaponID = player.hl.curwep
	local mystats = HLItems[weaponID] and HLItems[weaponID][mode]
	if not mystats and mode == "primary" then
		weaponID = "9mmhandgun"
		mystats = HLItems[weaponID] and HLItems[weaponID][mode]
	end
	if not (mystats and mystats.cookable) then return true end
	if player.hl.cooking and player.hl1viewmdaction == "cookloop" then
		player.hl.cooking = false
		if mystats.cookable then
			local grenade = HL_FireProjectile(player, mystats, mode)
			if not grenade then return end
			if grenade.fuse <= 0 then
				grenade.state = S_XDEATHSTATE
			end
			player.hl.cooktime = nil
			return true
		end
	end
	return false
end

local function IsIdleState(state)
    -- Returns true if state is "idle" or "idle X" where X can be any suffix
    return state:match("^idle") ~= nil
end

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

addHook("PlayerThink", function(player)
	if player == consoleplayer and (kombiseentime or -1) >= 0 then
		kombiseentime = ($ or 0) - 1
	end

	if not player.mo or player.mo.skin ~= skin return end

    if player.hl.doomPending then
        -- once the lower animation has finished, viewmdaction will be idle
        if IsIdleState(player.hl1viewmdaction) then
            -- 1) swap the weapon
            HL_SwitchWeapon(player, player.hl.doomPendingWep)
            -- 2) immediately start the raise animation
            HL_ChangeViewmodelState(player, "ready", "idle")
            -- 3) clear the pending flag so we only do this once
            player.hl.doomPending    = nil
            player.hl.doomPendingWep = nil
        end
    end

	-- Decrease weapon delay timers
	if player.weaponaltdelay player.weaponaltdelay = $ - 1 end
	if player.hl1weapondelay player.hl1weapondelay = $ - 1 end

	-- Prevent Freeman from using vanilla firing mechanics
	player.weapondelay = 2

	-- Reset refire flag if the fire button is released
	if not player.hl1weapondelay and not (player.cmd.buttons & fire) and player.refire
		player.refire = false
	end

	if not (player.cmd.buttons & fire) and not (player.cmd.buttons & altfire) then
		player.hl.holdyourfire = false
		player.hl.noshoot = false
	end

	-- Handle primary and secondary fire inputs
	local isFire = (player.cmd.buttons & fire) or player.hlcmds.attack
	local isAlt = (player.cmd.buttons & altfire) or player.hlcmds.attack2
	local isFiring = isFire or isAlt
	local isVolley = player.currentvolley

	-- Fire if input is held or volley is active
	if isFiring or isVolley then
		-- Call FireWeapon depending on input
		if isFire or player.volleymode == "primary"
			FireWeapon(player, "primary")
			player.hl.fireMode = "primary"
		elseif isAlt or player.volleymode == "secondary"
			FireWeapon(player, "secondary")
			player.hl.fireMode = "secondary"
		end

		-- Mark that fire input was active
		player.hl.wasFiring = true

	elseif player.hl.wasFiring and not isVolley then
		-- Just released fire and volley is over
		player.hl.wasFiring = not StopFire(player, player.hl.fireMode)
	end
end)

addHook("MobjMoveBlocked", function(mobj, thing, line)
	if line
		local side = P_PointOnLineSide(mobj.x, mobj.y, line)
		mobj.angle = line.angle + (ANGLE_180 * side)
		mobj.state = S_MISSILESTATE
		mobj.momx = 0
		mobj.momy = 0
		mobj.momz = 0
	end
end, MT_HL1_TRIPMINE)

local function ExplosionCheck(mobj)
	if not (mobj and mobj.valid) then return end
	local mode    = mobj.firemode or "primary"
	local stats   = mobj.stats or {}
	local explode = stats.explodeonhit
	if ((type(explode) == "function" and explode(shooter, mode, stats)) or (explode == true)) and not mobj.exploded then
		mobj.info.deathstate = S_HL1_EXPLOSION
		mobj.exploded = true
		mobj.fuse = -1
		A_HLExplode(mobj, stats.explosionradius or 256 * FRACUNIT, stats.explosiondamage or 192)
	elseif not (mobj.exploded or mobj.fuse > 0) then
		P_KillMobj(mobj)
	end
end

-- common helper for viewmodel / sound / delay
local function DoFireHitEffects(shooter, bullet, mode, stats)
    local weapon    = shooter.hl.curwep
    local viewmodel = HLItems[HLItems[weapon].viewmodel] or HLItems["v_pistol"]
    -- change viewmodel
    if not stats.fireoffset and viewmodel.hashitframes then
        HL_ChangeViewmodelState(shooter, mode .. "fire hit")
    end

    -- play a randomized hit sound, if any
    if stats.firehitsound then
        local count = stats.firehitsounds or 1
        local offs   = (count > 1) and (P_RandomRange(1, count) - 1) or 0
        S_StartSound(shooter.mo, stats.firehitsound + offs)
    end

    -- apply the hit delay
	if stats.hitdelay then
		local delay = stats.hitdelay or 0
		if mode == "primary" then
			shooter.hl1weapondelay = delay
		else
			shooter.weaponaltdelay = delay
		end
	end

	bullet.hitenemy = true

	ExplosionCheck(bullet)
end

local function MaybeHitFloor(bullet, line)
	local shooter = bullet.shooter
	if not (shooter and shooter.valid) then return end

	local mode  = bullet.firemode or "primary"
	local stats = bullet.stats or {}
	local bottom = bullet.z
	local top = bullet.z + bullet.height
/*
	-- Wall check using closest point on the given line
	if line then
		local side = P_PointOnLineSide(bullet.x, bullet.y, line)
		local sector = (side == 0 and line.backsector) or line.frontsector

		if sector then
			local floor = sector.floorheight
			local ceil  = sector.ceilingheight
			local bz = bullet.z
			local tz = bullet.z + bullet.height

			if bz < floor or tz > ceil then
				print("Bullet inside invalid sector space")
				DoFireHitEffects(shooter, bullet, mode, stats)
				return
			end
		else
			print("Bullet inside invalid space in general")
			DoFireHitEffects(shooter, bullet, mode, stats)
			return
		end
	end
*/
	if not bullet.hitenemy and bottom <= bullet.floorz then
		bullet.z = bullet.floorz
		DoFireHitEffects(shooter, bullet, mode, stats)
	elseif not bullet.hitenemy and top >= bullet.ceilingz then
		bullet.z = bullet.ceilingz - bullet.height
		DoFireHitEffects(shooter, bullet, mode, stats)
	end
end

-- bullet blocked hook
local function BulletHit(bullet, target, line)
    local shooter = bullet.shooter
    if not (shooter and shooter.valid) then return end
    local mode  = bullet.firemode or "primary"
    local stats = bullet.stats or {}
	if target then
		if not (target.z + target.height >= bullet.z and target.z <= bullet.z + bullet.height) then return end
	end
    DoFireHitEffects(shooter, bullet, mode, stats)
end

-- bullet collide hook
local function BulletHitObject(tmthing, thing)
	-- print("Collision!")
    if tmthing.hitenemy then return false end
	-- print(tmthing.target, thing, tmthing.target == thing, thing.type != MT_METALSONIC_BATTLE)
    if tmthing.target == thing then return false end
	-- print(thing.type, thing.type == MT_METALSONIC_BATTLE)
	if thing.type != MT_METALSONIC_BATTLE and (not (thing.z + thing.height >= tmthing.z and thing.z <= tmthing.z + tmthing.height)) then return end
	if thing.type == MT_METALSONIC_BATTLE then print("Accomodating Metal Sonic...") thing.flags = $|MF_SHOOTABLE end
	if not (thing.flags & MF_SHOOTABLE) then return false end

    -- run any custom per‐mode hitfunc
    local shooter  = tmthing.shooter
    if shooter and shooter.valid then
        local mode       = tmthing.firemode or "primary"
        local statsTable = HLItems[shooter.hl.curwep]
        local stats      = statsTable and statsTable[mode]
        if stats and stats.firehitfunc then
            local override = stats.firehitfunc(shooter, thing)
            if type(override) == "number" then
                tmthing.hl1damage = override
            end
        end
    end

    -- apply damage
    local damage = HL_HurtMobj(tmthing, thing, tmthing.hl1damage)
    if (damage or 0) > 0 and not tmthing.exploding then
        -- turn the bullet into a hit-effect
        tmthing.fuse      = 9
        tmthing.state     = S_HL1_HIT
        tmthing.scale     = FRACUNIT/2
        tmthing.momx      = 0
        tmthing.momy      = 0
        tmthing.momz      = 0
        tmthing.hitenemy  = true
    end

    -- now do the shared viewmodel/sound/delay
    if shooter and shooter.valid then
        local mode  = tmthing.firemode or "primary"
        local stats = tmthing.stats or {}
        DoFireHitEffects(shooter, tmthing, mode, stats)
    end

    return false
end

-- install hooks
for _, mt in ipairs({MT_HL1_BULLET, MT_HL1_BOLT}) do
	addHook("MobjThinker", MaybeHitFloor, mt)
    addHook("MobjMoveBlocked", BulletHit, mt)
    addHook("MobjMoveCollide", BulletHitObject, mt)
end

local function HLToDoom(hlUnit)
    return FixedMul(hlUnit, HL.ConvRatio)
end

local PLAYER_LONGJUMP_SPEED = HLToDoom(350*FRACUNIT)

local function playerHasControl(player)
return not (
	player.exiting
	or player.powers[pw_nocontrol]
	or P_PlayerInPain(player)
	or (player.pflags & PF_STASIS)
	or (player.pflags & PF_FULLSTASIS)
	or (player.pflags & PF_NOCLIP)
	or (player.powers[pw_carry] > CR_NONE)
	or (player.playerstate ~= PST_LIVE)
) end

addHook("PreThinkFrame", function()
	for player in players.iterate do
		if not player.mo then continue end
		if player.hl.punchangle and player.hl.punchangle.x then
			player.cmd.aiming = player.cmd.aiming - player.hl.punchangle.x
			player.aiming = (player.cmd.aiming - player.hl.punchangle.x)<<16
		end
		if player.mo.skin != "kombifreeman" then continue end
		player.hl.friction = (player.mo.floorrover and player.mo.floorrover.sector and player.mo.floorrover.sector.friction) or player.mo.subsector.sector.friction
		player.hl.cmap = skincolors[player.mo.color].ramp[7]

		local targetCrouch = HL_IsCrouching(player)

		if ((player.cmd.buttons & BT_JUMP) or (player.hlcmds and player.hlcmds.jump)) and P_IsObjectOnGround(player.mo) and playerHasControl(player) then
			if targetCrouch and player.speed > HLToDoom(50*FRACUNIT) then
				local longJumpSpeed = FixedMul(PLAYER_LONGJUMP_SPEED, FRACUNIT * 8 / 5)
				if player.hlinv.longjump then
					if player.hl.config.viewkick then
						player.hl.punchangle.x = (ANG2 + ANG2 + ANG1) >> 16
					end
					P_InstaThrust(player.mo, player.mo.angle, FixedMul(player.cmd.forwardmove * FRACUNIT / 50, longJumpSpeed))
					player.mo.momz = P_MobjFlip(player.mo) * FixedMul(FixedMul(FixedMul(FRACUNIT * 4, player.mo.scale), player.jumpfactor), FixedDiv(191*FRACUNIT, 180*FRACUNIT) * 2)
					S_StartSound(player.mo, sfx_hl1ljm)
					player.mo.state = S_PLAY_LONGJUMP
					player.hl.ignorecrouchclock = 4
				else
					player.mo.momz = P_MobjFlip(player.mo) * FixedMul(FixedMul(FRACUNIT * 4, player.mo.scale), player.jumpfactor*2)
					if not targetCrouch then
						if player.mo.state != S_PLAY_LONGJUMP then
							player.mo.state = S_PLAY_HLJUMP
						end
					elseif player.mo.state != S_PLAY_LONGJUMP
						local moving = abs(player.mo.momx) > 0 or abs(player.mo.momy) > 0
						player.mo.state = moving and S_PLAY_FREEMCROUCHMOVE or S_PLAY_FREEMCROUCH
					end
				end
			else
				L_MakeFootstep(player, "jump")
				player.mo.momz = P_MobjFlip(player.mo) * FixedMul(FixedMul(FRACUNIT * 4, player.mo.scale), player.jumpfactor*2)
				if not targetCrouch then
					if player.mo.state != S_PLAY_LONGJUMP then
						player.mo.state = S_PLAY_HLJUMP
					end
				elseif player.mo.state != S_PLAY_LONGJUMP
					local moving = abs(player.mo.momx) > 0 or abs(player.mo.momy) > 0
					player.mo.state = moving and S_PLAY_FREEMCROUCHMOVE or S_PLAY_FREEMCROUCH
				end
			end
			player.cmd.buttons = $ & ~BT_JUMP
		end

		if player.hl.ignorecrouchclock then
			player.hl.ignorecrouchclock = $ - 1
		end

		if not (player.hl.killcam and player.hl.killcam.valid) then continue end
		player.hl.killcam.z = $ - (player.hl.killcam.height - 8 * player.hl.killcam.scale)
	end
end)

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

    -- Scale how many steps we can take to current size
    local speed_fp  = mobjinfo[mobj.type].speed
    local maxdist   = mobj.dist or (FRACUNIT * 4096)                                 -- fallback range
    local diststeps = FixedCeil(FixedDiv(maxdist*HL.BULLETSPEED, speed_fp))/FRACUNIT -- override or compute

    -- normalize momentum vector
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

    -- Start the hitscan!
    local hit = false
    for i = 1, diststeps do
        if not (mobj and mobj.valid) then break end
        if P_RailThinker(mobj) then
            hit = true
            break
        end
    end

    -- Post-trace shit
    if not hit then
        if mobj.stats and mobj.stats.israycaster then
            mobj.state = S_NULL
        else
            mobj.dontraycast = true
        end
    else
        -- we hit: spawn splashes, arcs, whatever
		if not mobj and mobj.valid then return end
        ExplosionCheck(mobj)
		if mobj and mobj.valid then mobj.dontraycast = true end
    end

    -- clean up the flag
    shooter.flags = shooter.flags & ~MF_NOCLIP
end

addHook("MobjThinker", HL_TheRaycastingAtHome, MT_HL1_BULLET)
addHook("MobjThinker", HL_TheRaycastingAtHome, MT_HL1_TRIPMINE)

addHook("MobjThinker", function(mobj)
	mobj.info.activesound = sfx_hlgrn1 + leveltime%3
end, MT_HL1_HANDGRENADE)

addHook("PostThinkFrame", function()
	for player in players.iterate do
		if not player.mo continue end
		if player.hl.punchangle.x
			player.aiming = (player.cmd.aiming + player.hl.punchangle.x)<<16
		end
		if player.mo.skin != "kombifreeman" then continue end
		player.bob = 0
		player.deltaviewheight = 0
		if not (player.hl.killcam and player.hl.killcam.valid) then continue end
		player.hl.killcam.z = $ + (player.hl.killcam.height - 8 * player.hl.killcam.scale)
	end
end)

-- DOOM Raise speed ~6 pixels
addHook("SeenPlayer", function(player,splayer)
	kombilastseen = splayer -- "Do not alter player_t in HUD rendering code!" - ☝️🤓
	kombiseentime = 8
end)

local cv_seenames = CV_FindVar("seenames")

hud.add(function(v, player)
	if (kombiseentime or -1) < 0 then return end

	local y = 124
	local splayer = kombilastseen
	local function drawNext(str, color)
		v.drawString(160, y, str, color|V_ALLOWLOWERCASE|V_HUDTRANSHALF, "thin-center")
		y = $ + 8
	end

	local textcolor = 0

	if not cv_seenames.value or cv_seenames.value == 1 then
	elseif cv_seenames.value == 2 then
		if (G_GametypeHasTeams())
			textcolor = splayer.ctfteam == 1 and V_REDMAP or V_BLUEMAP
		end
	else
		// Green = Ally, Red = Foe
		textcolor = HL_IsAlly(player, splayer, false) and V_GREENMAP or V_REDMAP
	end


    if kombilastseen and kombilastseen.valid and kombilastseen.mo and (kombilastseen.mo.skin == "kombifreeman" or player.mo.skin == "kombifreeman") then
        local seename = kombiHL1SpecialHandlers[kombilastseen.mo.skin] and kombiHL1SpecialHandlers[kombilastseen.mo.skin].seenametext(kombilastseen)
		for k, v in ipairs(seename) do
			drawNext(v, textcolor)
		end
    end
end, "game")