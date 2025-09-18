local function HLToDoom(hlUnit)
    return FixedMul(hlUnit, HL.ConvRatio)
end

local WATER_MAXSPEED	 = 24 * FRACUNIT   -- max swim speed
local WATER_ACCEL		 = 12 * FRACUNIT   -- roughly "trueaccel" from quake
local WATER_FRICTION	 = FRACUNIT / 2
local WATER_DRAWDOWN	 = -FRACUNIT * 2      -- sink-speed when going too slow
local WATER_DT 		 	 = FRACUNIT/TICRATE
local SWIM_UP_FORCE 	 = 12 * FRACUNIT
local SWIM_DOWN_FORCE	 = 12 * FRACUNIT
local NOCLIP_SPEED	     = 24 * FRACUNIT
local NOCLIP_WALK_SPEED  = 12 * FRACUNIT
local AIR_TIME			 = 12 * TICRATE -- "lung full of air lasts this many seconds"
local DROWN_RECOVER_TIME = TICRATE
local DROWN_DMG_PERIOD	 = TICRATE
local IN_LAVA_BURNFOR	 = 10
local IN_SLIME_HURTFOR	 = 4
-- Noclip = 500 Quake Units
-- Noclip +speed = 250 Quake Units

-- helper: 3-axis hypotenuse
local function FixedHypot3(x,y,z)
    return FixedHypot(FixedHypot(x,y), z)
end

-- the actual water-move function
local function WaterMove(player)
    local mo, c, hlcmds = player.mo, player.cmd, player.hlcmds
    if not mo or not c then return end

    local dt = WATER_DT
    local fwd = c.forwardmove * FRACUNIT
    local sde = -c.sidemove * FRACUNIT
    local ca, sa = cos(mo.angle), sin(mo.angle)

    local pitch = player.aiming or 0
    local sinp = sin(pitch)

    -- Horizontal wishvel
    local wishx = FixedMul(fwd, ca) - FixedMul(sde, sa)
    local wishy = FixedMul(fwd, sa) + FixedMul(sde, ca)

    -- Vertical component
    local wishz = 0
    local jumpPressed = ((c.buttons & BT_JUMP) ~= 0) or (hlcmds and hlcmds.jump)
    local duckPressed = ((c.buttons & BT_SPIN) ~= 0) or (hlcmds and hlcmds.duck)
    local verticalPressed = jumpPressed or duckPressed

    if jumpPressed then
        wishz = SWIM_UP_FORCE
    elseif duckPressed then
        wishz = -SWIM_DOWN_FORCE
    elseif fwd == 0 and sde == 0 then
        wishz = WATER_DRAWDOWN
    else
        -- use forward magnitude projected by pitch
        wishz = FixedMul(fwd, sinp)
    end

    -- compute original wish magnitude and normalize from that vector
    local raw_wishspeed = FixedHypot3(wishx, wishy, wishz)

    -- cap to max
    if raw_wishspeed > WATER_MAXSPEED then
        local s = FixedDiv(WATER_MAXSPEED, raw_wishspeed)
        wishx = FixedMul(wishx, s)
        wishy = FixedMul(wishy, s)
        wishz = FixedMul(wishz, s)
        raw_wishspeed = WATER_MAXSPEED
    end

    -- now compute normalized direction from the wish vector
    local dirx, diry, dirz = 0,0,0
    if raw_wishspeed > 0 then
        local inv = FixedDiv(FRACUNIT, raw_wishspeed)
        dirx = FixedMul(wishx, inv)
        diry = FixedMul(wishy, inv)
        dirz = FixedMul(wishz, inv)
    end

    -- wishspeed scalar used for accel is the slowed value
    local wishspeed = FixedMul(raw_wishspeed, 7*FRACUNIT/10)

    -- friction on full velocity magnitude
    local vx, vy, vz = mo.momx, mo.momy, mo.momz
    local speed = FixedHypot3(vx, vy, vz)
    local newspeed
    if speed > 0 then
        newspeed = speed - FixedMul(FixedMul(speed, dt), WATER_FRICTION)
        if newspeed < 0 then newspeed = 0 end
        local scale = FixedDiv(newspeed, speed)
        mo.momx, mo.momy, mo.momz = FixedMul(vx, scale), FixedMul(vy, scale), FixedMul(vz, scale)
    else
        newspeed = 0
    end

	if wishspeed >= (FRACUNIT/10) then
		-- normalized direction from the wish vector
		local inv = FixedDiv(FRACUNIT, raw_wishspeed > 0 and raw_wishspeed or FRACUNIT)
		local dirx, diry, dirz = FixedMul(wishx, inv), FixedMul(wishy, inv), FixedMul(wishz, inv)

		-- current speed projected onto wish direction
		local cur_along = FixedMul(mo.momx, dirx) + FixedMul(mo.momy, diry) + FixedMul(mo.momz, dirz)

		-- compute how much we still need along that axis
		local addspeed = wishspeed - cur_along

		if addspeed > 0 then
			local accelspeed = FixedMul(WATER_ACCEL, FixedMul(wishspeed, dt))
			if accelspeed > addspeed then accelspeed = addspeed end

			mo.momx = mo.momx + FixedMul(accelspeed, dirx)
			mo.momy = mo.momy + FixedMul(accelspeed, diry)
			mo.momz = mo.momz + FixedMul(accelspeed, dirz)
		end
	end

    -- clamp final speed
    local speed3d = FixedHypot3(mo.momx, mo.momy, mo.momz)
    if speed3d > WATER_MAXSPEED then
        local s = FixedDiv(WATER_MAXSPEED, speed3d)
        mo.momx, mo.momy, mo.momz = FixedMul(mo.momx, s), FixedMul(mo.momy, s), FixedMul(mo.momz, s)
    end
end

-- No-clipped movement
local function NoclipMove(player) -- Noclip is unfeeling towards inertia.
	player.hl.noclippedtic = true
	if camera.chase then
		if player == displayplayer then
			camera.z = player.mo.z + player.viewheight
		end
	else
		player.awayviewtics = 2
		player.awayviewaiming = player.aiming
		player.awayviewmobj = player.mo
	end
	local mo, c = player.mo, player.cmd
	if not mo or not c then return end

	-- Angle and aiming
	local ang = mo.angle
	local pitch = player.aiming
	local sinp, cosp = sin(pitch), cos(pitch)
	local totspeed = (c.buttons & BT_SPIN) and NOCLIP_WALK_SPEED or NOCLIP_SPEED

	-- Input scaling
	local fwd = c.forwardmove * FRACUNIT
	local sde = -c.sidemove * FRACUNIT

	-- Horizontal (XY) direction
	local ca, sa = cos(ang), sin(ang)
	local wishx = FixedMul(fwd, ca) - FixedMul(sde, sa)
	local wishy = FixedMul(fwd, sa) + FixedMul(sde, ca)

	-- Vertical (Z) direction based on pitch
	local fwdVel = FixedMul(wishx, ca) + FixedMul(wishy, sa)
	local wishz = FixedMul(FixedDiv(fwdVel, totspeed), sinp)
	wishz = FixedMul(wishz, totspeed)

	-- Normalize and scale to target speed
	local wishspd = FixedHypot3(wishx, wishy, wishz)
	if wishspd > 0 then
		local s = FixedDiv(totspeed, wishspd)
		mo.momx = FixedMul(wishx, s)
		mo.momy = FixedMul(wishy, s)
		mo.momz = FixedMul(wishz, s)
	else
		-- Stop dead if no input
		mo.momx = 0
		mo.momy = 0
		mo.momz = 0
	end
end

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin != "kombifreeman" then return end
	player.hl = $ or {}
	local hl = player.hl

	local previousWaterState = player.lastWaterState or 0
	local currentWaterState = (player.mo.eflags & MFE_UNDERWATER)

	-- Just entered water
	if currentWaterState and not previousWaterState then
		local scale = FixedDiv(457*FRACUNIT, 780*FRACUNIT)
		player.mo.momz = FixedMul(player.mo.momz, scale) -- Remove SRB2's default water boost
		player.justEnteredWater = true
	elseif not currentWaterState and previousWaterState then
		hl.drowntimer = DROWN_RECOVER_TIME
	end

	-- Override drowning conditions
	if (player.pflags & PF_GODMODE or (player.powers[pw_shield] & SH_PROTECTWATER))
		or not (maptol & TOL_NIGHTS)
		and not ((netgame or multiplayer) and (player.spectator or player.quittime)) then

		-- Treat as if just resurfaced
		if currentWaterState then
			currentWaterState = 0
			player.powers[pw_underwater] = underwatertics - 1
			hl.drowntimer = DROWN_RECOVER_TIME
		end
	end

	if player.powers[pw_underwater] == underwatertics then
		if not previousWaterState and drownrecover then
			local drownrecover = min(hl.drownedtorecover or 0, 10)
			HL_DamageGordon(player.mo, nil, -drownrecover, HL.DMG.DROWNRECOVER)
			hl.drownedtorecover = $ - drownrecover
		end
		hl.drowntimer = AIR_TIME
		hl.drowningdmg = 0
	end
	
	if currentWaterState then
		player.powers[pw_underwater] = underwatertics - 5
	elseif player.powers[pw_spacetime] == 1 then
		currentWaterState = 64
		hl.drowntimer = 0
	end

	player.lastWaterState = currentWaterState
	if (hl.drowntimer or 0) <= 0 then
		if currentWaterState then
			hl.drowningdmg = min(($ or -3) + 5, 5)
			hl.drownedtorecover = ($ or 0) + hl.drowningdmg
			HL_DamageGordon(player.mo, nil, hl.drowningdmg, HL.DMG.DROWN)
			hl.drowntimer = DROWN_DMG_PERIOD
		elseif hl.drownedtorecover then
			local drownrecover = min(hl.drownedtorecover, 10)
			HL_DamageGordon(player.mo, nil, -drownrecover, HL.DMG.DROWNRECOVER)
			hl.drowntimer = DROWN_RECOVER_TIME
			hl.drownedtorecover = $ - drownrecover
		end
	else
		hl.drowntimer = ($ or 0) - 1
	end
end)

local TRUEACCEL = 12*FRACUNIT
local MAXACCEL = 5*FRACUNIT
local MINACCEL = 5*FRACUNIT/4

local function doPhys(player)
	return player.playerstate == PST_LIVE
	and player.exiting == 0
	and player.powers[pw_carry] == 0
	and player.powers[pw_nocontrol] == 0
	and player.climbing == 0
	and not (player.mo.state >= S_PLAY_SUPER_TRANS1 and player.mo.state <= S_PLAY_SUPER_TRANS6)
	and P_PlayerInPain(player) == false
	and not (player.pflags & PF_STASIS)
	and not (player.pflags & PF_STARTDASH)
end

local function maybeRunCustomPhys(player)
	if not doPhys(player) then return true end
	if (player.pflags & PF_NOCLIP) then
		NoclipMove(player)
		return true
	elseif (player.mo.eflags & MFE_UNDERWATER) ~= 0 then
		WaterMove(player)
		return true
	end
end

-- Approximate natural log for 16.16 fixed_t in (0, FRACUNIT]
-- Based on ln(x) ≈ 2 * ((x-1)/(x+1) + 1/3 * ((x-1)/(x+1))^3 + ...)
-- Accurate within ~0.002 for [0.25, 1]

local function FixedLog(x, scale)
	if x <= 0 then return UINT32_MAX end
	if x == scale then return 0 end       -- ln(1) = 0

	-- Range reduction: convert x to fixed-point [0.5, 1] by shifting
	local shift = 0
	while x > scale do
		x = x >> 1
		shift = shift + 1
	end
	while x < (scale >> 1) do
		x = x << 1
		shift = shift - 1
	end

	-- Compute y = (x - 1) / (x + 1)
	local num = x - scale
	local den = x + scale
	local y = FixedDiv(num, den)

	local y2 = FixedMul(y, y)

	-- Taylor series: ln(x) ≈ 2 * (y + y^3/3 + y^5/5)
	local term1 = y
	local term2 = FixedDiv(FixedMul(FixedMul(y2, y), FRACUNIT), 3*FRACUNIT)
	local term3 = FixedDiv(FixedMul(FixedMul(FixedMul(y2, y2), y), FRACUNIT), 5*FRACUNIT)
	local lnfrac = FixedMul(2*FRACUNIT, term1 + term2 + term3)

	-- ln(x) = ln(x / 2^shift) = ln(x') - shift * ln(2)
	local LN2 = 45426 -- ln(2) ≈ 0.6931 * 65536
	local result = lnfrac + shift * -LN2

	return result
end

addHook("PlayerThink", function(player)
	if not player.mo then return end
	if player.mo.skin != "kombifreeman" return end

	if maybeRunCustomPhys(player) then return end -- This **replaces** the default mover, so make sure we don't physic twice
/*
	if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) and not (player.powers[pw_carry] or player.hl.nograv) then
		local grav = P_GetMobjGravity(player.mo)
		player.mo.momz = $ - grav
		player.mo.momz = $ + HLToDoom(FixedMul(FixedMul((cv_gravity and cv_gravity.value or 800*FRACUNIT), WATER_DT), grav*3/2))
	end
*/
	if player.hl and player.hl.nophys then
		player.thrustfactor = skins[player.realmo.skin].thrustfactor
		return
	else
		--a cheap way of dissabling srb2 acceleration
		player.thrustfactor = 0
	end

	if abs(player.cmd.forwardmove) + abs(player.cmd.sidemove) ~= 0
		if player.mrce and MRCE_isHyper(player) then
			player.mrce.physics = true
		elseif player.powers[pw_sneakers] > 0 then
			if player.mrce then player.mrce.physics = true end
		else
			if player.mrce then player.mrce.physics = false end
		end

		local wishang
		wishang = R_PointToAngle2(0, 0, player.cmd.forwardmove * FRACUNIT, player.cmd.sidemove * -FRACUNIT) + player.mo.angle
		if (player.pflags & PF_ANALOGMODE) and not (player.mo.flags2 & MF2_TWOD) then
			wishang = player.cmd.angleturn<<16 + R_PointToAngle2(0, 0, player.cmd.forwardmove * FRACUNIT, player.cmd.sidemove * -FRACUNIT)
		end
		if (player.mo.flags2 & MF2_TWOD) then wishang = player.mo.angle end
		local analog = FixedHypot(player.cmd.forwardmove * 1311, -player.cmd.sidemove * 1311)

		--where am i going
		local movedir = R_PointToAngle2(0, 0, player.rmomx, player.rmomy)
		local movespd = FixedHypot(player.rmomx, player.rmomy)

		--wish varibles
		local wishspd
		wishspd = FixedMul(player.normalspeed, player.mo.scale)
		if player.mo.eflags & MFE_UNDERWATER then wishspd = $/2 end
		if player.powers[pw_sneakers] > 0 or player.powers[pw_super] > 0 then wishspd = 5*$/3 end
		if (player.pflags & PF_SPINNING) or P_IsObjectOnGround(player.mo) == false then
			if player.powers[pw_super] > 0
				wishspd = $/12
			else
				wishspd = $/16
			end
		end

		--funny dot product
		local angdiff
		local curspeed
		local addspeed
		local accelspeed
		angdiff = abs(movedir - wishang)
		curspeed = FixedMul(movespd, cos(angdiff))

		--accel hell
		local ACELTHRSH = 4*wishspd/5
		local minaccel
		local maxaccel
		local trueaccel
		minaccel = FixedMul(MINACCEL + ((player.accelstart - 96) * 224), player.mo.scale)
		maxaccel = FixedMul(MAXACCEL + ((player.acceleration - 40) * 256), player.mo.scale)
		trueaccel = FixedMul(TRUEACCEL + ((player.acceleration - 40) * 192), player.mo.scale)
		if player.powers[pw_super] > 0 then
			minaccel = $ + 3*player.mo.scale/4
			maxaccel = 2*$
			trueaccel = FixedMul($, 4*FRACUNIT/3)
			if player.mrce and MRCE_isHyper(player) then
				if not P_IsObjectOnGround(player.mo) then
					trueaccel = max(wishspd, FixedMul($, 8*FRACUNIT/7))
				end
				maxaccel = 5*$/4
				minaccel = $ + player.mo.scale/2
			end
		end
		if player.powers[pw_sneakers] > 0 and player.powers[pw_super] == 0 then
			minaccel = $ + player.mo.scale/3
			maxaccel = FixedMul($, 5*FRACUNIT/3) + player.mo.scale/2
		end
		if player.mo.eflags & MFE_UNDERWATER then
			trueaccel = $/2
			maxaccel = $/2
			minaccel = $/2
		end
		if movespd == 0 then
			if player.dashmode >= TICRATE*3 then accelspeed = maxaccel else accelspeed = minaccel end
		elseif movespd < ACELTHRSH then
			if player.dashmode >= TICRATE*3
				accelspeed = maxaccel
			else
				accelspeed = ease.insine(min(FixedDiv(movespd, ACELTHRSH), FRACUNIT), minaccel, maxaccel)
			end
		elseif movespd >= ACELTHRSH and movespd < wishspd - 4*player.mo.scale then
			local TRUEDIV = FixedInt((wishspd - 4*player.mo.scale) - ACELTHRSH) or 1
			accelspeed = ease.outquad(min(FixedDiv((movespd - ACELTHRSH), TRUEDIV), FRACUNIT), maxaccel, trueaccel)
		else accelspeed = TRUEACCEL end
		addspeed = min(max(wishspd - curspeed, 0), accelspeed)

		--lmfao
		P_Thrust(player.mo, wishang, FixedMul(addspeed, analog))

		player.rmomx = player.mo.momx - player.cmomx
		player.rmomy = player.mo.momy - player.cmomy
		player.speed = P_AproxDistance(player.rmomx, player.rmomy)

		--if shit fucked up? have this!
		if abs(addspeed) > 300*FRACUNIT
			print("bullshit error! thanks" + player.name + "!")
			print(trueaccel/FRACUNIT)
			print(maxaccel/FRACUNIT)
			print(minaccel/FRACUNIT)
			print(curspeed/FRACUNIT)
			print(accelspeed/FRACUNIT)
			print(addspeed/FRACUNIT)
		end
	else
		if not ((player.mo.eflags & MFE_JUSTHITFLOOR) or P_IsObjectOnGround(player.mo)) then return end
		-- 1) calculate frametime in fixed_t
		local frametime_fp = FixedDiv(1 * FRACUNIT, TICRATE * FRACUNIT)

		-- 2) get normalized friction log
		local base_fric_fp = max(min(player.hl.friction or 4, FRACUNIT), 0)
		local ln_fp        = FixedLog( base_fric_fp, FRACUNIT )        -- ≈ ln(base_fric/65536)
		local k_fp         = FixedDiv( -ln_fp, frametime_fp )          -- = -ln(fr_norm)/dt

		-- 3) apply HL‐style friction using k_fp
		local stopspeed_fp = HLToDoom(cv_stopspeed.value)
		local vx = player.mo.momx - player.cmomx
		local vy = player.mo.momy - player.cmomy
		local speed_fp = FixedHypot(vx, vy)
		if speed_fp > 0 then
			local control = (speed_fp < stopspeed_fp) and stopspeed_fp or speed_fp
			local drop_fp = FixedMul( FixedMul(control, k_fp), frametime_fp )
			local newsp  = speed_fp - drop_fp
			if newsp < 0 then newsp = 0 end
			local scale = FixedDiv(newsp, speed_fp)
			player.mo.momx = FixedMul(vx, scale) + player.cmomx
			player.mo.momy = FixedMul(vy, scale) + player.cmomy
		end
	end

	-- "Slow down, I'm pulling it! (a box maybe) but only when I'm standing on ground" - HL1 Source Code
	if player.hlcmds and player.hlcmds.use == true and P_IsObjectOnGround(player.mo) then
		player.mo.momx = FixedMul($, FRACUNIT*3/10)
		player.mo.momy = FixedMul($, FRACUNIT*3/10)
	end
end)