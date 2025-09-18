local elapsed = 0

if not srb2p
	hud.add(function(v, player)
		if HL.disableTitleScreen then return end
		v.drawFill()
		if elapsed > 349 then
			v.drawScaled(0, -20*FRACUNIT, FRACUNIT*2/5, v.cachePatch("HLMENUBG"))
			return
		end
		elapsed = $ + 1
		S_ChangeMusic("hlvalv", false)
		v.drawScaled(0, -20*FRACUNIT, FRACUNIT/2, v.cachePatch("VALVEINTRO" .. elapsed))
	end, "title")
end

addHook("MusicChange", function(oldname, newname, mflags, looping, position, prefadems, fadeinms)
	if oldname == "hlvalv" and elapsed <= 329 and not consoleplayer then return true end
	if newname == "_title" and elapsed > 329 and not consoleplayer then return "null" end
end)