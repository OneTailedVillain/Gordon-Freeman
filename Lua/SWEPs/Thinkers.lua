local function SafeFreeSlot(...)
	for _,slot in ipairs({...}) do
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

SafeFreeSlot("SPR_LEGOBATTLESPROJ","S_KOMBI_SHURIKEN")

states[S_KOMBI_SNARK] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A,
	tics = TICRATE*5,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_SNARKDIE
}

states[S_KOMBI_SNARKDIE] = {
	sprite = SPR_NULL,
	frame = A,
	action = A_HLExplode,
	tics = 0,
	var1 = 60*FRACUNIT,
	var2 = 100,
	nextstate = S_NULL
}

mobjinfo[MT_HL1_SNARK] = {
	spawnstate = S_KOMBI_SNARK,
	spawnhealth = 100,
	deathstate = S_KOMBI_SNARKDIE,
	xdeathstate = S_KOMBI_SNARKDIE,
	radius = FRACUNIT*4,
	height = FRACUNIT*10,
	dispoffset = 4,
	flags = MF_GRENADEBOUNCE|MF_BOUNCE,
	activesound = sfx_hltmdp,
	attacksound = sfx_hltmac,
	missilestate = S_KOMBI_SNARK
}

addHook("MobjThinker", function(mobj)
	local grounded = (P_IsObjectOnGround(mobj) or mobj.eflags & MFE_JUSTHITFLOOR)
	if not mobj.tracer then
		if FixedHypot(mobj.momx, mobj.momy) then
			mobj.angle = R_PointToAngle2(0, 0, mobj.momx, mobj.momy)
		end
	elseif grounded then
		local targ = mobj.tracer
		mobj.angle = R_PointToAngle2(mobj.x, mobj.y, targ.x, targ.y)
	end
	P_InstaThrust(mobj, mobj.angle, FRACUNIT*10)
	if grounded and not mobj.tracer then
		local searchDist = 512 * FRACUNIT
		print("attempt to blockmap")
		searchBlockmap("objects", function(refmobj, foundmobj)
			print("searching...")
			if foundmobj == refmobj then return end
			print("NOT ourselves")
			if not (foundmobj.flags & MF_SHOOTABLE) then return end
			print("IS shootable")
			if foundmobj.type == refmobj.type then return end
			print("ISNT of same type")
			print(AngleFixed(R_PointToAngle2(foundmobj.x, foundmobj.y, refmobj.x, refmobj.y) - refmobj.angle)/FRACUNIT)
			if abs(R_PointToAngle2(foundmobj.x, foundmobj.y, refmobj.x, refmobj.y) - refmobj.angle) > ANGLE_45 then return end
			refmobj.tracer = foundmobj
			return true
		end, mobj, mobj.x + searchDist / 2, mobj.x - searchDist / 2, mobj.y + searchDist / 2, mobj.y - searchDist / 2)
	end
end, MT_HL1_SNARK)