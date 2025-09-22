local drawflags = V_ADD | V_PERPLAYER
local messagemodetxt = "say: "
local messagemode2txt = "say_team: "

local function getColormap(v, cmap)
	if not HL.cacheShit.colormaps[cmap] then
		HL.cacheShit.colormaps[cmap] = v.getColormap(nil, nil, cmap)
	end
	return HL.cacheShit.colormaps[cmap]
end

local function cachePatch(v, patch)
	if not HL.cacheShit.patches[patch] then
		HL.cacheShit.patches[patch] = v.cachePatch(patch)
	end
	return HL.cacheShit.patches[patch]
end


local function patchExists(v, patch)
	if not HL.cacheShit.patches[patch] then
		if v.patchExists(patch) then
			HL.cacheShit.patches[patch] = v.cachePatch(patch)
			return true
		end
	else
		return true
	end
	return false
end

local function K_DrawHL1Number(v,num,x,y,flags,colormap,redtintingmin,scale)
	local donum = tostring(abs(num or 0))
	local xpos = (x or 0) - FixedMul(scale or FRACUNIT/2, 20*FRACUNIT)
	local ypos = (y or 0) - FixedMul(scale or FRACUNIT/2, 24*FRACUNIT)
	local textflags = flags or 0
	local cmap
	if redtintingmin == nil or num > redtintingmin
		cmap = colormap or getColormap(v, "COLORSCALECLR" .. skincolors[SKINCOLOR_ORANGE].ramp[7])
	else
		cmap = getColormap(v, "COLORSCALECLR" .. skincolors[SKINCOLOR_RED].ramp[7])
	end
	for i = 0,#donum-1 do
		local dothis = (donum or 0)/(10^i)%10 or 0
		v.drawCropped(xpos, ypos, scale or FRACUNIT/2, scale or FRACUNIT/2, cachePatch(v, "HL1NUMS"), textflags, cmap, (24*FRACUNIT)*dothis, 0, 20*FRACUNIT, 24*FRACUNIT)
		xpos = $-(FixedMul(scale or FRACUNIT/2, 20*FRACUNIT))
	end
end

local function IsAboveVersion(major, sub)
	return (VERSION > major) or (VERSION == major and SUBVERSION >= sub)
end

local function dummy()
end

local function drawCount(v, x, y, count, ammostats, flags, colormap, hideonnone)
	if (hideonnone and not count) or count < 0 then return end
	K_DrawHL1Number(v, count, x, y, flags, colormap)
	if ammostats and ammostats.icon then
		v.drawScaled(
			x, y - 13 * FRACUNIT,
			FRACUNIT / 2,
			cachePatch(v, ammostats.icon),
			flags,
			colormap
		)
	end
end

local function shouldDraw(mode, player)
	local weapon   = player.hl.curwep
	local wpnStats = HLItems[weapon] or {}
	local modeStats = wpnStats[mode]
	if not modeStats then return false end

	-- figure out which clip stats to use (secondary may use primary clip)
	local clipMode = (mode == "secondary" and modeStats.altusesprimaryclip) and "primary" or mode
	local curStats = wpnStats[clipMode]
	if not curStats then return false end

	local clipSize	= curStats.clipsize or -1
	local ammoType	= curStats.ammo or "none"
	local reserveCnt  = player.hlinv.ammo[ammoType] or 0
	local clipCnt	 = (player.hlinv.wepclips[weapon] and player.hlinv.wepclips[weapon][clipMode]) or 0
	local neverDeny   = curStats.neverdenyuse

	-- infinite ammo / no-clip weapons: clipsize < 0 AND no ammo type
	if clipSize < 0 and (not ammoType or reserveCnt < 0) then
		return { drawReserve = false, drawClip = false }
	end

	-- clip-based weapons
	if clipSize > -1 then
		return {
			drawReserve = (reserveCnt >= 0 or neverDeny),
			drawClip	= (clipCnt >= 0 or neverDeny),
			reserveCnt  = reserveCnt,
			clipCnt	 = clipCnt,
			ammostats   = HLItems[ammoType] or {}
		}
	end

	-- pure reserve only (no clip)
	if ammoType then
		return {
			drawReserve = (reserveCnt >= 0 or neverDeny),
			drawClip	= false,
			reserveCnt  = reserveCnt,
			ammostats   = HLItems[ammoType] or {}
		}
	end

	return { drawReserve = false, drawClip = false }
end

local function warn(player, str)
	CONS_Printf(player, "\130WARNING: \128"..str);
end

local function noDraw(player, ignoresuit)
	if not player then return true end
	if not player.mo then return true end
	if player.mo.skin != "kombifreeman" then return true end
	if not player.hl then return true end
	if not player.hlinv then return true end
	if not player.hlinv.hevsuit then return not ignoresuit end
	if doom and doom.intermission then return true end
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

local oldskin

-- Viewmodel
hud.add(function(v, player)
	if not player.mo then return end
	if player.mo.skin ~= "kombifreeman" then 
		if oldskin == "kombifreeman" then
			hud.enable("score")
			hud.enable("time")
			hud.enable("rings")
			hud.enable("lives")
			hud.enable("weaponrings")
			hud.enable("crosshair")
		end
		oldskin = player.mo.skin
		return
	end

	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	hud.disable("lives")
	hud.disable("weaponrings")
	hud.disable("crosshair")

	oldskin = player.mo.skin

	if noDraw(player, true) then return end

    local suffixList = {
        {
			code = "MP",
			cond = function(player)
				return cv_deathmatch.value
			end
		}
    }

	if (player.hl and player.hl.zoomed)
	or player.playerstate == PST_DEAD
	or camera.chase
	or not (player.hlinv.weapons and player.hlinv.weapons[player.hl.curwep])
	or (player.awayviewtics and player.awayviewmobj != player.mo)
	then return end

	local weaponStats = HLItems[player.hl.curwep]
	local animationDef = player.hl1currentAnimation
	local curframe = player.hl1frame or 1

	local function drawViewmodelLayer(v, player, frameIndex, vmdl, sentinelOverride)
		local sentinel = sentinelOverride or (animationDef and animationDef.sentinel) or "PISTOLIDLE1-1"
		local prefix, baseNum = sentinel:match("^(.-)(%d+)$")
		baseNum = tonumber(baseNum) or 1
		local patchFrame = baseNum + (frameIndex - 1)
        -- build a list of *all* suffix‐strings whose cond is true
        -- e.g. {"MP"}, {"SIL"}, or {"MP","SIL"} if both true
        local active = {}
        for _, sdef in ipairs(suffixList) do
            if sdef.cond(player) then
                table.insert(active, sdef.code)
            end
        end

        -- generate all non‐empty combinations in list‐order
        -- e.g. for {"MP","SIL"} → {"MP","SIL","MPSIL"}
        local combos = {}
        local n = #active
        for mask = 1, 2^n - 1 do
            local s = ""
            for i = 1, n do
                if (mask >> (i-1)) & 1 == 1 then
                    s = s .. active[i]
                end
            end
            combos[#combos + 1] = s
        end
        -- sort so longer (more specific) combos are tried first
        table.sort(combos, function(a,b) return #a > #b end)

        -- now pick the first patchName that actually exists:
        local patchName
        for _, suf in ipairs(combos) do
            local candidate = prefix .. patchFrame .. suf
            if patchExists(v,candidate) then
                patchName = candidate
                break
            end
        end
        -- if no suffixed one found, try unsuffixed…
        if not patchName then
            local base = prefix .. patchFrame
            if patchExists(v,base) then
                patchName = base
            else
                -- ultimate fallback to frame 1
                patchName = prefix .. "1"
            end
        end

		local vmdlflags = V_PERPLAYER
		if vmdl.flags and (vmdl.flags & VMDL_FLIP) ~= 0 then
			vmdlflags = $
		end
		if vmdl.vflags then
			vmdlflags = $ | vmdl.vflags
		end

		local bobx, boby = 0, 0
		local angle = FixedAngle(leveltime * 12 * FRACUNIT)
		local bobOffset = 0

		if vmdl.bobtype == VBOB_DOOM then
			local bobAngle = ((128 * leveltime) & 8191) << 19
			bobx = FixedMul((player.hl1wepbob or 0), cos(bobAngle))
			bobAngle = ((128 * leveltime) & 4095) << 19
			boby = FixedMul((player.hl1wepbob or 0), sin(bobAngle))
		elseif vmdl.bobtype == VBOB_NONE then
		else
			bobOffset = (player.hl.bob or 0)
		end

		if animationDef and animationDef.frameOffsets then
			local offset = animationDef.frameOffsets[frameIndex]
			if offset then
				bobx = $ + (offset[1] or 0) * FRACUNIT
				boby = $ + (offset[2] or 0) * FRACUNIT
			end
		end

		local patch = cachePatch(v, patchName)
		local colormap = IsAboveVersion(202, 13)
			and v.getSectorColormap(player.mo.subsector.sector, player.mo.x, player.mo.y, player.mo.z, player.mo.subsector.sector.lightlevel)
			or nil

		local vmdlSizes = animationDef.frameSizes
		-- Check if size is defined in the viewmodel itself; otherwise, fallback to animationDef.frameSizes
		local wepSize = vmdl.size or (vmdlSizes and vmdlSizes[frameIndex]) or FRACUNIT

		v.drawCropped(
			160 * FRACUNIT + bobx,
			100 * FRACUNIT + boby,
			FixedMul(FRACUNIT + bobOffset, wepSize),
			FixedMul(FRACUNIT + bobOffset, wepSize),
			patch,
			vmdlflags,
			colormap,
			0, 0, patch.width*FRACUNIT, patch.height*FRACUNIT
		)

		if not patchExists(v,patchName) then
			warn(player, "Patch " .. tostring(patchName) .. " either doesn't exist, or you spelled it wrong!")
		end
	end

	local wepVMDLName = weaponStats.viewmodel -- or "PISTOL"
	wepVMDLName = $:lower()
    local baseViewmodelName = "v_" .. wepVMDLName
    local baseViewmodel     = HLItems[baseViewmodelName]

    local allLayers = {}

    if animationDef and animationDef.overlays then
        -- Insert the main weapon graphic as an overlay with layer=0
        table.insert(allLayers, {
            layer     = 0,
            viewmodel = baseViewmodelName,
            sentinel  = animationDef.sentinel
        })

        -- Copy each overlayDef, assigning a default numeric layer if none provided
        local nextDefaultLayer = 1
        for _, overlayDef in ipairs(animationDef.overlays) do
            if overlayDef.layer == nil then
                overlayDef.layer = nextDefaultLayer
                nextDefaultLayer = nextDefaultLayer + 1
            end
            table.insert(allLayers, overlayDef)
        end

        -- Sort by “current” layer value
		-- If table, each index # corresponds to a certain frame
        local function getLayerVal(overlay)
            if type(overlay.layer) == "table" then
                -- If curframe index is out of range or nil, default to 0
                return overlay.layer[curframe] or 0
            else
                return overlay.layer or 0
            end
        end

        table.sort(allLayers, function(a, b)
            return getLayerVal(a) < getLayerVal(b)
        end)

        -- 4) Draw each in sorted order
        for _, overlay in ipairs(allLayers) do
            local viewmodelName = overlay.viewmodel or baseViewmodelName
            local vmdl = HLItems[viewmodelName]
            local sent = overlay.sentinel or animationDef.sentinel
            drawViewmodelLayer(v, player, curframe, vmdl, sent)
        end

    else
        -- No `overlays` table: just draw the base weapon as always
        drawViewmodelLayer(v, player, curframe, baseViewmodel)
    end
end, "game")

-- Pickup History Display
hud.add(function(v, player)
    -- only for our kombifreeman skin
    if noDraw(player) then return end

    -- constants
    local ICON_SCALE   = FRACUNIT / 2
    local SPACING_Y    = 45 * ICON_SCALE      -- same spacing whether weapon or ammo
    local MARGIN_X     = 8 * FRACUNIT             -- distance from right screen edge
    local MARGIN_Y     = SPACING_Y + FRACUNIT * 3 -- extra distance from bottom screen edge (unhooked from SPACING_Y)
    local BASE_FLAGS   = drawflags | V_SNAPTORIGHT | V_SNAPTOBOTTOM | V_20TRANS
    local colormap     = getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color))

    -- Convert expected HUD-Space dimensions to fixed-point
    local viewW, viewH = 320 * FRACUNIT, 200 * FRACUNIT

    -- starting Y: a bit up from the bottom of the screen
    local yOffset = viewH - SPACING_Y - MARGIN_X - MARGIN_Y

	-- numeric loop over all 8 possible entries
	for i = 1, HL.MAX_HISTORY do
		local info = player.pickuphistory[i]

		-- skip any "hole" (nil) without touching yOffset
		if info then
		-- draw your icon/text exactly like before...
		if info.type == "weapon" then
			local iconName = HLItems[info.thing].selectgraphic or "HL1HUD9MM"
			local iconW, iconH = 170 * FRACUNIT, 45 * FRACUNIT
			local xPos = viewW - MARGIN_X - FixedMul(iconW, ICON_SCALE)
			local yPos = yOffset - (iconH * ICON_SCALE / (2 * FRACUNIT))
			v.drawScaled(xPos, yPos, ICON_SCALE, cachePatch(v, iconName), BASE_FLAGS, colormap)
		elseif info.type == "ammo" then
            local iconName = HLItems[info.thing].icon
            local iconSize = 24 * FRACUNIT
            local xPos = viewW - MARGIN_X - (FixedMul(iconSize, ICON_SCALE))
            local yPos = yOffset + 7 * FRACUNIT
            v.drawScaled(xPos, yPos, ICON_SCALE, cachePatch(v, iconName), BASE_FLAGS, colormap)

            -- count: right‑aligned just to the left of the ammo icon
            local countStr = tostring(info.count or 0)
			local scale = FRACUNIT / 4
            local digitWidth = FixedMul(scale or FRACUNIT/2, 20*FRACUNIT)
            local textX = xPos - (#countStr - 1) * digitWidth - (2 * FRACUNIT)
            local textY = yPos + (7 * FRACUNIT)
            K_DrawHL1Number(v, info.count, textX, textY, BASE_FLAGS, colormap, nil, scale)

            -- warn if icon missing
            if not patchExists(v,iconName) then
                warn(player, "Missing patch: " .. iconName .. " for ammo '" .. info.thing .. "'")
            end
		elseif info.type == "special" then
            local iconName = "HLPICKUP" .. info.thing:upper()
            local iconW, iconH = 44 * FRACUNIT, 44 * FRACUNIT
            local xPos = viewW - MARGIN_X - (FixedMul(iconW, ICON_SCALE))
            -- center vertically on this slot
            local yPos = yOffset - (iconH * ICON_SCALE / (2 * FRACUNIT))
            v.drawScaled(xPos, yPos, ICON_SCALE, cachePatch(v, iconName), BASE_FLAGS, colormap)
            if not patchExists(v,iconName) then
                warn(player, "Missing patch: " .. iconName)
            end
		end

		-- Now move up one for next entry
		yOffset = yOffset - SPACING_Y
		end
	end
end, "game")

-- Helper clamp
local function clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

-- totalTime = fadeIn + hold + fadeOut
local function getFadeAlpha(fadeTimer, fadeIn, fadeHold, fadeOut)
    local totalTime       = fadeIn + fadeHold + fadeOut
    local alphaInvisible  = 10  -- step index for fully invisible
    local alphaBase       = 2   -- V_20TRANS
    fadeTimer = fadeTimer % totalTime

    local function interp(tRaw, duration, fromStep, toStep)
        -- scale tRaw [0…duration] → [0…FRACUNIT]
        local t = clamp((tRaw * FRACUNIT) / duration, 0, FRACUNIT)
        -- linear interpolation
        local level = ease.linear(t, fromStep, toStep)
        -- clamp back to integer step
        return clamp(level, min(fromStep, toStep), max(fromStep, toStep))
    end

    if fadeTimer < fadeIn then
        -- fade in: invisible → base
        local lvl = interp(fadeTimer, fadeIn, alphaInvisible, alphaBase)
        return lvl << V_ALPHASHIFT

    elseif fadeTimer < fadeIn + fadeHold then
        -- hold at base
        return alphaBase << V_ALPHASHIFT

    else
        -- fade out: base → invisible
        local tOut = fadeTimer - (fadeIn + fadeHold)
        local lvl  = interp(tOut, fadeOut, alphaBase, alphaInvisible)
        return lvl << V_ALPHASHIFT
    end
end

-- Damage Icons
-- Bottom is latest, the bottom of the icon goes just above where the second row of Health would have. Icons go upwards, higher meaning older.
-- Maybe 1-second fade in-out? maybe 4 seconds total view time
hud.add(function(v, player)
    if noDraw(player) then return end

    -- set up your fade times (in tics; TICRATE=35 tics≈1s)
    local fadeIn  = TICRATE*3/4
    local fadeHold= 0
    local fadeOut = TICRATE*3/4

    -- get the looping alpha flag
    local alphaFlag = getFadeAlpha(leveltime, fadeIn, fadeHold, fadeOut)
	local alpha = alphaFlag >> V_ALPHASHIFT

    -- combine with whatever other drawflags you need:
    local df = drawflags
        | V_SNAPTOBOTTOM
        | V_SNAPTOLEFT
        | alphaFlag

    -- skip if fully transparent
    if alpha >= 10 then return end

    -- draw each icon, newest first at bottom (y=170),
    -- stepping up by half‑height (here /2 scale)
    for i, iconData in ipairs(player.hl.dmgicons or {}) do
		if iconData.time <= TICRATE then continue end
        local iconPatch = cachePatch(v, iconData.icon)
        local y = 184*FRACUNIT - (i * (64*FRACUNIT/2))
        v.drawScaled(5*FRACUNIT, y, FRACUNIT/2,
                     iconPatch,
                     df,
                     getColormap(v, "COLORSCALECLR"..(player.hl.cmap or player.mo.color)))
    end
end, "game")

-- Ammo
hud.add(function(v, player)
	if noDraw(player) then return end

	local xPosition = 308 * FRACUNIT
	local weapon	= player.hl.curwep
	local wpnStats  = HLItems[weapon] or {}
	local colormap  = getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color))
	local drawFlags = drawflags | V_SNAPTOBOTTOM | V_SNAPTORIGHT

	local topY = 196 * FRACUNIT

	-- Primary
	local primary = shouldDraw("primary", player)
	if primary.drawReserve then
		topY = 180 * FRACUNIT
		drawCount(v, xPosition, 196 * FRACUNIT, primary.reserveCnt, primary.ammostats, drawFlags, colormap)
	end
	if primary.drawClip then
		topY = 180 * FRACUNIT
		v.drawScaled(
			xPosition - 32 * FRACUNIT,
			184 * FRACUNIT,
			FRACUNIT / 2,
			cachePatch(v, "HL1HUDDIVIDE"),
			drawFlags,
			colormap
		)
		K_DrawHL1Number(
			v,
			primary.clipCnt,
			xPosition - 35 * FRACUNIT,
			196 * FRACUNIT,
			drawFlags,
			colormap
		)
	end

	-- Secondary (only if defined and not using primary clip exclusively)
	if wpnStats.secondary and not wpnStats.secondary.altusesprimaryclip then
		local secondary = shouldDraw("secondary", player)
		if secondary.drawReserve and secondary.reserveCnt > 0 then
			topY = 164 * FRACUNIT
			drawCount(v, xPosition, 180 * FRACUNIT, secondary.reserveCnt, secondary.ammostats, drawFlags, colormap, true)
		end
		if secondary.drawClip then
			topY = 164 * FRACUNIT
			v.drawScaled(
				xPosition - 32 * FRACUNIT,
				168 * FRACUNIT,
				FRACUNIT / 2,
				cachePatch(v, "HL1HUDDIVIDE"),
				drawFlags,
				colormap
			)
			K_DrawHL1Number(
				v,
				secondary.clipCnt,
				xPosition - 35 * FRACUNIT,
				180 * FRACUNIT,
				drawFlags,
				colormap
			)
		end
	end

	if not wpnStats.rsrrailring then return end

    local railAmmo = player.hl.rsr and player.hl.rsr.railring or 0

	if not railAmmo then return end
    local railStats = { icon = "RAILRINGMODIFIER" }

    drawCount(v, xPosition, topY, railAmmo, railStats, drawFlags, colormap, false)
end, "game")

-- Crosshair
hud.add(function(v, player)
	if noDraw(player, false) then hud.enable("crosshair") return end
	local flags = drawflags|V_20TRANS
	local isZoomed = cv_deathmatch.value
	local weaponStats = HLItems[player.hl.curwep]
	local scale = player.hl.config.chairscale or FRACUNIT/2
	if weaponStats.crosshair then
		if isZoomed and patchExists(v, weaponStats.crosshair .. "Z") then
			v.drawScaled(160 * FRACUNIT, 100 * FRACUNIT, scale, cachePatch(v, weaponStats.crosshair), flags, getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color)))
		else
			v.drawScaled(160 * FRACUNIT, 100 * FRACUNIT, scale, cachePatch(v, weaponStats.crosshair), flags, getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color)))
		end
	else
		hud.enable("crosshair")
	end
end, "game")

-- Health
hud.add(function(v, player)
	if noDraw(player) then return end
	local flags = drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_20TRANS
	local healthColor = (player.mo.hl.health > 25) and player.mo.color or SKINCOLOR_RED
	v.drawScaled(5 * FRACUNIT, 182 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HL1HUDCROSS"), flags, getColormap(v, "COLORSCALECLR" .. skincolors[healthColor].ramp[7]))
	K_DrawHL1Number(v, player.mo.hl.health, 50 * FRACUNIT, 196 * FRACUNIT, flags, getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color)), 25)
	v.drawScaled(50 * FRACUNIT, 184 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HL1HUDDIVIDE"), flags, getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color)))
end, "game")

-- Flashlight
hud.add(function(v, player)
	if noDraw(player) then return end

	local maxVal  = 100*FRACUNIT
	local armor   = min((player.hl.flashlightbattery or 0), maxVal)
	local crop	= FixedDiv((maxVal - armor) * 32, maxVal)

	local x0	  = 290 * FRACUNIT
	local y0	  =   7 * FRACUNIT
	local hscale  = FRACUNIT/2
	local vscale  = FRACUNIT/2
	local flags   = drawflags | V_SNAPTOTOP | V_SNAPTORIGHT
	if not player.hl.flashlight then
		flags = $|V_20TRANS
	end
	local cm	  = armor > 25*FRACUNIT and getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color)) or getColormap(v, "COLORSCALECLR" .. skincolors[SKINCOLOR_RED].ramp[7])

	v.drawScaled(
	  x0, y0,
	  hscale,
	  cachePatch(v, "HL1HUDFLASHE"),
	  flags, cm
	)

	v.drawCropped(
	  x0 + (crop / 2), y0,
	  hscale, vscale,
	  cachePatch(v, "HL1HUDFLASHF"),
	  flags, cm,
	  crop, 0,
	  (32 * FRACUNIT) - crop,
	  32 * FRACUNIT
	)

	if player.hl.flashlight then
		for i = 1, 2 do
			  v.drawScaled(
				306 * FRACUNIT, 7 * FRACUNIT, FRACUNIT/2,
				cachePatch(v, "HL1HUDFLASHB"),
			   flags,
				cm
			  )
		end
	end
end, "game")

-- Armor
hud.add(function(v, player)
	if noDraw(player) then return end
	local colormap = getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color))
	local armor = min((player.mo.hl.armor or 0), player.mo.hl.maxarmor)
	local crop = FixedDiv((100 * FRACUNIT - armor) * 40, 100 * FRACUNIT)
	local flags = drawflags|V_SNAPTOBOTTOM|V_SNAPTOLEFT | V_20TRANS
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT, FRACUNIT / 2, FRACUNIT / 2, cachePatch(v, "HL1SUITE"), flags, colormap, 0, 0, 40 * FRACUNIT, crop)
	v.drawCropped(52 * FRACUNIT, 178 * FRACUNIT + crop / 2, FRACUNIT / 2, FRACUNIT / 2, cachePatch(v, "HL1SUITF"), flags, colormap, 0, crop, 40 * FRACUNIT, 40 * FRACUNIT - crop)
	K_DrawHL1Number(v, (player.mo.hl.armor or 0) / FRACUNIT, 99 * FRACUNIT, 196 * FRACUNIT, flags, colormap)
end, "game")

local damageFadeTics = 5

-- Damage Direction Indicator
hud.add(function(v, player)
	if noDraw(player) then return end
	if player.mo.hl1dmgdir == nil return end
	local fade = ease.linear(FixedDiv(player.hl1damagetics, damageFadeTics), 0, 10)
	if fade >= 10 return end
	fade = fade<<V_ALPHASHIFT

	local centerdist = 50 * FRACUNIT
	local flags = drawflags | fade
	local hitAngle = player.mo.hl1dmgdir

	-- Un-angled hit, all indicators light up
	if hitAngle == -FRACUNIT then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) - centerdist, FRACUNIT / 2, cachePatch(v, "HLPAINUP"), flags)
		v.drawScaled((160 * FRACUNIT) - centerdist, 100 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HLPAINRIGHT"), flags | V_FLIP)
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) + centerdist, FRACUNIT / 2, cachePatch(v, "HLPAINDOWN"), flags)
		v.drawScaled((160 * FRACUNIT) + centerdist, 100 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HLPAINRIGHT"), flags)
		return
	end

	-- The tolerance for each indicator
	local tolerance = 45 * FRACUNIT

	-- Normalize the angle to a 0 - 360° range
	local function normalizeAngle(angle)
		local full = 360 * FRACUNIT
		return angle % full
	end

	hitAngle = normalizeAngle(hitAngle)

	-- Helper: Check if the absolute difference between two angles is within tolerance
	local function isWithin(angle, target, tol)
		local diff = abs(angle - target)
		if diff > 180 * FRACUNIT then
			diff = (360 * FRACUNIT) - diff
		end
		return diff <= tol
	end

	-- SRB2 has no native knowledge on cardinal directions, let's fix that by defining our own
	local centers = {
		up = 0,
		right = 90 * FRACUNIT,
		down = 180 * FRACUNIT,
		left = 270 * FRACUNIT,
	}

	-- Only draw an indicator if the hit angle is within tolerance
	if isWithin(hitAngle, centers.up, tolerance) then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) - centerdist, FRACUNIT / 2, cachePatch(v, "HLPAINUP"), flags)
	end
	if isWithin(hitAngle, centers.right, tolerance) then
		v.drawScaled((160 * FRACUNIT) - centerdist, 100 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HLPAINRIGHT"), flags | V_FLIP)
	end
	if isWithin(hitAngle, centers.down, tolerance) then
		v.drawScaled(160 * FRACUNIT, (100 * FRACUNIT) + centerdist, FRACUNIT / 2, cachePatch(v, "HLPAINDOWN"), flags)
	end
	if isWithin(hitAngle, centers.left, tolerance) then
		v.drawScaled((160 * FRACUNIT) + centerdist, 100 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HLPAINRIGHT"), flags)
	end
end, "game")

-- Weapon Selection Menu
hud.add(function(v, player)
	if noDraw(player) then return end
	if not player.hl.wepmenu.isopen then return end

	local weaponamount   = player.selectionlist.weaponcount
	local weaponlist	 = player.selectionlist.weapons
	local weaponslots	 = player.selectionlist.wepslotamounts
	local colormap		 = getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color))

	-- Determine extra separation value based on whether the selected bucket has weapons.
	local extraSepValue = (player.hl.wepmenu.index > 0 and weaponslots and weaponslots[player.hl.wepmenu.category] and weaponslots[player.hl.wepmenu.category] > 0) and 65 or -10

	-- Draw small weapon icons in each category
	for i = 0, 9 do
		local sep = (i > player.hl.wepmenu.category) and extraSepValue or -10
		local drawx = (sep * FRACUNIT) + ((i + 1) * 12 * FRACUNIT)

		v.drawScaled(drawx, 2 * FRACUNIT, FRACUNIT / 2, cachePatch(v, "HUDSELBUCKET" .. i),
			drawflags|V_SNAPTOTOP|V_SNAPTOLEFT, colormap)

		local count = weaponslots and weaponslots[i] or 0
		local usable = (weaponslots.usable and weaponslots.usable[i]) or {}
		local railring = (weaponslots.railring and weaponslots.railring[i]) or {}

		for d = 1, count do
			if player.hl.wepmenu.index ~= 0 and i == player.hl.wepmenu.category then break end

			local isUsable = usable[d]
			local usecolor = (not isUsable) and SKINCOLOR_RED or player.mo.color
			local previewColor = getColormap(v, "COLORSCALECLR" .. skincolors[usecolor].ramp[7])

			v.drawScaled(drawx, 2 * FRACUNIT + (d * 12 * FRACUNIT), FRACUNIT / 2,
				cachePatch(v, "HUDSELBUCKETITEM"),
				drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS, previewColor)

			-- draw railring modifier only if the weapon at this slot/index has railring enabled
			if railring[d] then
				v.drawScaled(drawx, 2 * FRACUNIT + (d * 12 * FRACUNIT), FRACUNIT / 2,
					cachePatch(v, "RAILRINGMODIFIERBUCKET"),
					drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS, previewColor)
			end
		end
	end

	if player.hl.wepmenu.index == 0 then return end

	-- Individual Weapon Selection
	for i = 1, weaponamount do
		local currentweapon = weaponlist[i].name
		local usable = weaponlist[i].usable
		local railring = weaponlist[i].railring
		local wepproperties = HLItems[currentweapon]
		local selectgraphic = wepproperties.selectgraphic or "HL1HUD9MM"
		local ammostats = HLItems[ (wepproperties.primary and wepproperties.primary.ammo) or "9mm" ] or { max = 0 }
		local altammostats = HLItems[ (wepproperties.secondary and wepproperties.secondary.ammo) or "none" ] or { max = 0 }
		local border

		-- Highlight Selected Weapon
		if i == player.hl.wepmenu.index then
			selectgraphic = selectgraphic .. "S"
			border = i
		end

		-- If unusable, then mark as red.
		if not usable then
			colormap = getColormap(v, "COLORSCALECLR" .. skincolors[SKINCOLOR_RED].ramp[7])
		else
			colormap = getColormap(v, "COLORSCALECLR" .. (player.hl.cmap or player.mo.color))
		end

		local weaponXPos = -10 * FRACUNIT + ((player.hl.wepmenu.category + 1) * 12 * FRACUNIT)
		local weaponYPos = (14 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2)

		-- Draw Weapon Icon
		v.drawScaled(weaponXPos,
			weaponYPos,
			FRACUNIT / 2, cachePatch(v, selectgraphic),
			drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS, colormap)

		if i == border then
			v.drawScaled(weaponXPos,
				weaponYPos,
				FRACUNIT / 2, cachePatch(v, "HL1HUDWPNSEL"),
				drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS, colormap)
		end

		if railring then
			v.drawScaled(weaponXPos + 2 * FRACUNIT / 2,
				weaponYPos + 7 * FRACUNIT / 2,
				FRACUNIT / 2, cachePatch(v, "RAILRINGMODIFIERBUCKET"),
				drawflags|V_SNAPTOTOP|V_SNAPTOLEFT|V_20TRANS, colormap)
		end

		local ammoKey = (wepproperties.primary and wepproperties.primary.ammo) or "9mm"
		local have = player.hlinv.ammo[ammoKey] or 0

		-- Draw Ammo Bars
		if have > 0 then
			local effectiveMaxAmmo = player.hl1doubleammo and (ammostats.backpackmax or ammostats.max * 2) or ammostats.max
			v.drawStretched(-9 * FRACUNIT + ((player.hl.wepmenu.category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FRACUNIT * 10, 5 * FRACUNIT / 2, cachePatch(v, "HL1HUDSELGRAY"),
				V_PERPLAYER|V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawStretched(-9 * FRACUNIT + ((player.hl.wepmenu.category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FixedDiv((player.hlinv.ammo[ (wepproperties.primary and wepproperties.primary.ammo or "9mm") ] or 0) * 10, effectiveMaxAmmo or 10),
				5 * FRACUNIT / 2,
				cachePatch(v, "HL1HUDSELGREEN"),
				V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT)
		end

		local ammoKey = (wepproperties.secondary and wepproperties.secondary.ammo) or "none"
		local have = player.hlinv.ammo[ammoKey] or 0

		if not have then continue end
		if have > 0 then
			local effectiveMaxAmmo = player.hl1doubleammo and (altammostats.backpackmax or altammostats.max * 2) or altammostats.max
			v.drawStretched((5 * FRACUNIT / 2) + ((player.hl.wepmenu.category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FRACUNIT * 10, 5 * FRACUNIT / 2, cachePatch(v, "HL1HUDSELGRAY"),
				V_PERPLAYER|V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawStretched((5 * FRACUNIT / 2) + ((player.hl.wepmenu.category + 1) * 12 * FRACUNIT),
				(15 * FRACUNIT) + ((49 * (i - 1)) * FRACUNIT / 2),
				FixedDiv((player.hlinv.ammo[ (wepproperties.secondary and wepproperties.secondary.ammo or "9mm") ] or 0) * 10, effectiveMaxAmmo or 10),
				5 * FRACUNIT / 2,
				cachePatch(v, "HL1HUDSELGREEN"),
				V_PERPLAYER|V_SNAPTOTOP|V_SNAPTOLEFT)
		end
	end
end, "game")

-- Killfeed
hud.add(function(v, player)
    -- constants
	local ICON_SCALE  = FRACUNIT / 2
	local ICON_W      = 32 * FRACUNIT
	local ICON_H      = 32 * FRACUNIT
	local SPACING_Y   = 24 * ICON_SCALE
	local TEXT_FLAGS  = V_ALLOWLOWERCASE
	local FONT_TYPE   = "thin-fixed"
	local WIDTH_TYPE  = "thin"
	local MARGIN_X    = 8 * FRACUNIT
	local spacing     = 1 * FRACUNIT
	local MARGIN_Y    = SPACING_Y + 3 * FRACUNIT
	local BASE_FLAGS  = V_SNAPTORIGHT | V_SNAPTOTOP

	local viewW, viewH = 320 * FRACUNIT, 200 * FRACUNIT
	local yOffset      = SPACING_Y + MARGIN_Y

	-- Build a sorted list of kill entries
	local feed = {}
	for id, info in pairs(HL.killfeed) do
		table.insert(feed, { id = id, data = info })
	end
	table.sort(feed, function(a,b) return a.id < b.id end)

	for _, entry in ipairs(feed) do
		local id, info = entry.id, entry.data

        -- prepare strings & widths
        local killer, victim = info.killer, info.victim
		local icon
        if patchExists(v,info.icon) then
            icon = cachePatch(v, info.icon)
        else
            icon = cachePatch(v, "HL1KILLGENER")
            warn(player, "Missing killfeed icon: "..info.icon)
        end
        local kw = v.stringWidth(killer, TEXT_FLAGS, WIDTH_TYPE) * FRACUNIT
        local vw = v.stringWidth(victim, TEXT_FLAGS, WIDTH_TYPE) * FRACUNIT
        local iconW_s = FixedMul(icon.width * FRACUNIT, ICON_SCALE)

        -- total line width, right-aligned
        local totalW = vw + spacing + iconW_s + spacing + kw
        local xStart = viewW - MARGIN_X - totalW
        local yPos   = yOffset - (FixedMul(icon.height, ICON_SCALE) / 2)

        -- draw victim name
        v.drawString(xStart, yPos, victim, BASE_FLAGS|TEXT_FLAGS|(info.victcmap), FONT_TYPE)

        -- draw icon in the middle
        local iconX = xStart + vw + spacing
        v.drawScaled(iconX, yPos, ICON_SCALE, icon, BASE_FLAGS|V_ADD, getColormap(v, "COLORSCALECLR34"))

        -- draw killer name
        local killerX = iconX + iconW_s + spacing
        v.drawString(killerX, yPos, killer, BASE_FLAGS|TEXT_FLAGS|(info.killcmap), FONT_TYPE)

        -- next line up
        yOffset = yOffset + SPACING_Y
    end
end, "game")