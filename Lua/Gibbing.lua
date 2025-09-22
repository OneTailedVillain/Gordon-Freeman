HL.GIB_FRAMES = 11

local function HLToDoom(hlUnit)
    return FixedMul(hlUnit, HL.ConvRatio)
end

local function VectorLength(x, y, z)
	return FixedHypot(FixedHypot(x,y), z)
end

local function NormalizeVector(vector)
    local length = VectorLength(vector.x, vector.y, vector.z)
    if length == 0 then
        return 0, 0, 0
    end
	local x = vector.x
	local y = vector.y
	local z = vector.z
    return {x = FixedDiv(x, length), y = FixedDiv(y, length), z = FixedDiv(z, length)}
end

local function LimitVelocity(mobj)
    local maxSpeed = HLToDoom(1500 * FRACUNIT)
    local momx, momy, momz = mobj.momx, mobj.momy, mobj.momz
    
    local currentSpeed = VectorLength(momx, momy, momz)
    if currentSpeed > maxSpeed then
        local scale = FixedDiv(maxSpeed, currentSpeed)
        mobj.momx = FixedMul(momx, scale)
        mobj.momy = FixedMul(momy, scale)
        mobj.momz = FixedMul(momz, scale)
    end
end

local function SpawnRandomGibs(victim, cGibs, human, skull)
    for i = 1, cGibs do
        local gib = P_SpawnMobjFromMobj(victim, 0, 0, 0, MT_HL_GIBS)
		-- Frame 0 is reserved for the head gib. Don't pick that one
        gib.frame = not skull and P_RandomRange(1, HL.GIB_FRAMES - 1) or 0
		gib.scale = $ / 2

        -- Set random position within victim's bounds
        do
            local radius = victim.radius or 0
            local height = victim.height or 0

            local xoff, yoff = 0, 0
            if radius > 0 then
                local radius_sq = FixedMul(radius, radius)

                local tries = 0
                repeat
                    local rx = P_RandomFixed() - (FRACUNIT / 2)
                    rx = FixedMul(rx, 2 * FRACUNIT)
                    local ry = P_RandomFixed() - (FRACUNIT / 2)
                    ry = FixedMul(ry, 2 * FRACUNIT)

                    -- scale by radius
                    xoff = FixedMul(rx, radius)
                    yoff = FixedMul(ry, radius)

                    tries = tries + 1
                    -- safety bail after many tries (shouldn't happen unless radius==0)
                until FixedMul(xoff, xoff) + FixedMul(yoff, yoff) <= radius_sq or tries > 8
            end
/*
            -- Spawning already put us at height/2, so make sure we account for that
            local zoff = 0
            if height > 0 then
                local randZ = P_RandomFixed()
                zoff = FixedMul(randZ, height) - FixedDiv(height, FRACUNIT*2)
            end
*/
			P_SetOrigin(gib,
			victim.x + xoff,
			victim.y + yoff,
			victim.z + height / 2--FixedDiv(victim.height, FRACUNIT*2) + zoff --+ FRACUNIT
			)
        end

        -- Set velocity (using attack direction from HL data)
        local attackDir = NormalizeVector(victim.hl.attackDir)
        gib.momx = -attackDir.x * 3
        gib.momy = -attackDir.y * 3
        gib.momz = -attackDir.z * 3
        
        -- Add noise
		local rand = P_RandomFixed()
		local centered = rand - FRACUNIT / 2
		local noise_small = FixedDiv(centered, 2*FRACUNIT)
		gib.momx = gib.momx + HLToDoom(noise_small)
		gib.momy = gib.momy + HLToDoom(noise_small)
		gib.momz = gib.momz + HLToDoom(noise_small)

        -- Scale velocity
		local rand300_400 = P_RandomRange(300,400)*FRACUNIT -- P_RandomRange complains if I have the range set to (300*FRACUNIT, 400*FRACUNIT) so do this instead
		local scale = HLToDoom(rand300_400)

		gib.momx = FixedMul(gib.momx, scale)
		gib.momy = FixedMul(gib.momy, scale)
		gib.momz = FixedMul(gib.momz, scale)

		scale = 4*FRACUNIT
		
		if victim.hl.health > -50 then
			scale = FRACUNIT*7/10
		elseif victim.hl.health > -200 then
			scale = FRACUNIT*2
		end

		gib.momx = FixedMul(gib.momx, scale)
		gib.momy = FixedMul(gib.momy, scale)
		gib.momz = FixedMul(gib.momz, scale)

        --LimitVelocity(gib)
    end
end

rawset(_G, "HL_DoGibFX", function(mo)
	SpawnRandomGibs(mo, 1, human, true)
	SpawnRandomGibs(mo, 4, human)
end)

COM_AddCommand("gibtest", function(player)
	local mo = player.mo
	mo.hl = $ or {}
	local hl = mo.hl
	hl.attackDir = {x = FRACUNIT*10, y = FRACUNIT*5, z = 0}
	HL_DoGibFX(mo)
end)