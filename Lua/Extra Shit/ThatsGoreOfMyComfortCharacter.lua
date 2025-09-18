freeslot("SPR_HL1BLUD", "S_HL1_BLOOD", "MT_HL1_BLEEDOUT", "MT_HL1_BLEDOUT")

states[S_HL1_BLOOD] = {
	sprite = SPR_HL1BLUD,
	frame = FF_ADD|FF_FLOORSPRITE|A,
	tics = -1,
	nextstate = S_HL1_BLOOD
}

mobjinfo[MT_HL1_BLEEDOUT] = {
	spawnstate = S_HL1_BLOOD,
	spawnhealth = 100,
	radius = 6*FRACUNIT,
	height = FRACUNIT,
	dispoffset = 4,
	flags = MF_SCENERY|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

mobjinfo[MT_HL1_BLEDOUT] = {
	spawnstate = S_HL1_BLOOD,
	spawnhealth = 100,
	radius = 6*FRACUNIT,
	height = FRACUNIT,
	dispoffset = 4,
	flags = MF_SCENERY|MF_NOGRAVITY
}

addHook("MobjThinker", function(mobj)
	if mobj.state != S_FANG_DIE4 then return end
	mobj.flags = $ & ~MF_NOGRAVITY
	if mobj.hl.died then mobj.momz = 0 return end
	if mobj.fuse > 0 then
		mobj.hl.bleedoutclock = TICRATE*2
		mobj.fuse = -1
	end
	if mobj.hl.bleedoutclock then mobj.hl.bleedoutclock = $ - 1 return end
	P_SpawnMobjFromMobj(mobj, 0, 0, 0, MT_HL1_BLEEDOUT)
	A_BossDeath(mobj)
	mobj.hl.died = true
	mobj.momx = 0
	mobj.momy = 0
	mobj.momz = 0
end, MT_FANG)

addHook("MobjSpawn", function(mobj)
	mobj.color = SKINCOLOR_GREEN
	mobj.colorized = true
	mobj.translation = "TEXTSCALECLR255"
	mobj.lifetime = ($ or 0) + 1
	mobj.scale = 1 + min(mobj.lifetime * FRACUNIT/256, FRACUNIT*3/4)
end, MT_HL1_BLEEDOUT)
/*
addHook("MobjThinker", function(mobj)
	if not (consoleplayer.hl
	and consoleplayer.hl.config
	and consoleplayer.hl.config.fangdeath)
	then
		mobj.color = 0
	else
		mobj.color = 0
	end
	mobj.lifetime = ($ or 0) + 1
	mobj.scale = 1 + min(mobj.lifetime * FRACUNIT/256, FRACUNIT*3/4)
end, MT_HL1_BLEDOUT)
*/