local function FreeSlotAndCaption(...)
    local args = {...}
    for i = 1, #args, 2 do
        local slotName, caption = args[i], args[i+1]
        if not _G[slotName] then
            local slotID = freeslot(slotName)
            if caption then
                sfxinfo[slotID].caption = caption
            end
        end
    end
end

FreeSlotAndCaption(
	"sfx_klaxon", "The Klaxon Beat",
    "sfx_frblip", "*Blip*",
    "sfx_frboop", "*Boop*",
    "sfx_frboo2", "*Boop..!*",
    "sfx_frboo3", "*Boop!!*",
    "sfx_frbeep", "*Beep!*",
    "sfx_frbee2", "*Beep!!*",
    "sfx_frbee3", "*Beep!!!*",
    "sfx_hlblip", "*Blip!*",
    "sfx_frhiss", "*Hiss...*",
    "sfx_frwar0", "Warning: Hazardous chemical detected.",
    "sfx_frwar1", "Blood loss detected.",
    "sfx_frwar2", "Minor lacerations detected.",
    "sfx_frwar3", "Major lacerations detected.",
    "sfx_frwar4", "Minor fracture detected.",
    "sfx_frwar5", "Major fracture detected.",
    "sfx_frwar6", "Electrical damage detected.",
    "sfx_frwar7", "Extreme heat damage detected!",
    "sfx_frseek", "Seek medical attention.",
    "sfx_frhdrp", "Vital signs are dropping.",
    "sfx_frcrit", "Warning: Vital signs critical.",
    "sfx_frevac", "Evacuate area.",
    "sfx_fremer", "Emergency! User death imminent!",
    "sfx_frenga", "Automatic medical systems engaged.",
    "sfx_frmorp", "Morphine administered.",
    "sfx_frnoam", "Ammunition depleted.",
    "sfx_hlpmov", "Power assist movement: Activated.",
	"sfx_hlplvl", "Power level is:",
	"sfx_hevpwr", "Power:",
	"sfx_hlfuzz", "*Doo*",
	"sfx_hev5",   "Five,",
	"sfx_hev10",  "Ten,",
	"sfx_hev15",  "Fifteen,",
	"sfx_hev20",  "Twenty,",
	"sfx_hev30",  "Thirty,",
	"sfx_hev40",  "Fourty,",
	"sfx_hev50",  "Fifty,",
	"sfx_hev60",  "Sixty,",
	"sfx_hev70",  "Seventy,",
	"sfx_hev80",  "Eighty,",
	"sfx_hev90",  "Ninety,",
	"sfx_hev100", "One hundred,",
	"sfx_hlperc", "Percent.",
	"sfx_hevcma", "...",
	"sfx_hevprd", "...",
	"sfx_frflat", "*Flatline*",
	"sfx_hevon0", "Welcome to the H.E.V. Mark IV protective system, for use in Hazardous EnVironment conditions.",
	"sfx_hevon1", "High impact reactive armor: Activated.",
	"sfx_hevon2", "Atmospheric contaminant sensors: Activated.",
	"sfx_hevon3", "Vital sign monitoring: Activated.",
	"sfx_hevon5", "Defensive weapon selection system: Activated.",
	"sfx_hevon6", "Munition level monitoring: Activated.",
	"sfx_hevon7", "Communications interface: Online.",
	"sfx_hevon8", "Have a very safe day.",
	"sfx_hlbell", "*Bell*",
	"sfx_hlwarn", "Warning:"
)

local hevsounds = {
    blip                = sfx_frblip,
    boop                = sfx_frboop,
    boop2               = sfx_frboo2,
    boop3               = sfx_frboo3,
    beep                = sfx_frbeep,
    beep2               = sfx_frbee2,
    beep3               = sfx_frbee3,
	bell                = sfx_hlbell,
	flatline            = sfx_frflat,
	blip                = sfx_hlblip,
    hiss                = sfx_frhiss,
    chemical_detected   = sfx_frwar0,
    blood_loss          = sfx_frwar1,
    minor_lacerations   = sfx_frwar2,
    major_lacerations   = sfx_frwar3,
    minor_fracture      = sfx_frwar4,
    major_fracture      = sfx_frwar5,
    shock_damage        = sfx_frwar6,
    heat_damage         = sfx_frwar7,
    seek_medic          = sfx_frseek,
    health_dropping2    = sfx_frhdrp,
    health_critical     = sfx_frcrit,
    evacuate_area       = sfx_frevac,
    near_death          = sfx_fremer,
    immediately         = sfx_frimme,
    automedic_on        = sfx_frenga,
    morphine_shot       = sfx_frmorp,
    ammo_depleted       = sfx_frnoam,
	powermove_on        = sfx_hlpmov,
	power_level_is      = sfx_hlplvl,
	power               = sfx_hevpwr,
	fuzz                = sfx_hlfuzz,
	five                = sfx_hev5,
	ten                 = sfx_hev10,
	fifteen             = sfx_hev15,
	twenty              = sfx_hev20,
	thirty              = sfx_hev30,
	fourty              = sfx_hev40,
	fifty               = sfx_hev50,
	sixty               = sfx_hev60,
	seventy             = sfx_hev70,
	eighty              = sfx_hev80,
	ninety              = sfx_hev90,
	one_hundred         = sfx_hev100,
	percent             = sfx_hlperc,
	_comma              = sfx_hevcma,
	_period             = sfx_hevprd,
	hev_logon           = sfx_hevon0,
	powerarmor_on       = sfx_hevon1,
	atmospherics_on     = sfx_hevon2,
	vitalsigns_on       = sfx_hevon3,
	weaponselect_on     = sfx_hevon5,
	munitionview_on     = sfx_hevon6,
	communications_on   = sfx_hevon7,
	safe_day            = sfx_hevon8,
	warning             = sfx_hlwarn,
}

local hgruntdict = {

}

local function BroadcastVoiceMessage(player, soundNames, priority)
	player.voxBuffer = $ or {{}, {}}
	local target = priority and player.voxBuffer[1] or player.voxBuffer[2]
    if type(soundNames) == "table" then
        for _, name in ipairs(soundNames) do
            table.insert(target, name)
        end
    else
        table.insert(target, soundNames)
    end
end

local BeepSoundCount = BeepSoundCount or 2

rawset(_G, "FVox_WarnDamage", function(sentence, player, param)
	if (player.hl.suitvoicewait[sentence] or 0) > 0 then
		-- print("Line '" .. sentence .. "' cancelled! Need to wait " .. player.hl.suitvoicewait[sentence]/TICRATE .. " more seconds before it can play.")
		return
	end

    if sentence == "HEV_LOGON" then
		-- Param toggles "C1A0 behavior" (playing Klaxon Beat)
		if param then S_StartSound(nil, sfx_klaxon, player) end
        BroadcastVoiceMessage(player, "bell", true)
        BroadcastVoiceMessage(player, "hev_logon", true)
        BroadcastVoiceMessage(player, "powerarmor_on", true)
        BroadcastVoiceMessage(player, "atmospherics_on", true)
        BroadcastVoiceMessage(player, "vitalsigns_on", true)
        BroadcastVoiceMessage(player, "automedic_on", true)
        BroadcastVoiceMessage(player, "weaponselect_on", true)
        BroadcastVoiceMessage(player, "munitionview_on", true)
        BroadcastVoiceMessage(player, "communications_on", true)
        BroadcastVoiceMessage(player, "safe_day", true)
    elseif sentence == "HEV_LOGONS" then
		if param then S_StartSound(nil, sfx_klaxon, player) end
        BroadcastVoiceMessage(player, "bell", true)
        BroadcastVoiceMessage(player, "hev_logon", true)
    elseif sentence == "HEV_DEAD0" then
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "_comma", true)
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "_comma", true)
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "_comma", true)
        BroadcastVoiceMessage(player, "beep", true)
        BroadcastVoiceMessage(player, "_comma", true)
        BroadcastVoiceMessage(player, "flatline", true)
    elseif sentence == "HEV_HLTH3" then
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "near_death")
	elseif sentence == "HEV_HEAL7" then
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "hiss")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "morphine_shot")
	elseif sentence == "HEV_DMG4" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "minor_fracture")
	elseif sentence == "HEV_DMG5" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "major_fracture")
	elseif sentence == "HEV_MED1" then
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "automedic_on")
	elseif sentence == "HEV_SHOCK" then
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "warning")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "shock_damage")
	elseif sentence == "HEV_FIRE" then
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "warning")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "heat_damage")
	elseif sentence == "HEV_DET0" then
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "biohazard_detected")
	elseif sentence == "HEV_DET1" then
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "chemical_detected")
	elseif sentence == "HEV_DET2" then
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "radiation_detected")
	elseif sentence == "HEV_DMG0" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "minor_lacerations")
	elseif sentence == "HEV_DMG1" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "major_lacerations")
	elseif sentence == "HEV_DMG2" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "internal_bleeding")
	elseif sentence == "HEV_DMG3" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "blood_toxins")
	elseif sentence == "HEV_DMG6" then
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop3")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "blood_loss")
	elseif sentence == "HEV_DMG7" then
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "boop2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "seek_medic")
	elseif sentence == "HEV_HLTH1" then
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "health_dropping2")
	elseif sentence == "HEV_HLTH2" then
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "beep2")
        BroadcastVoiceMessage(player, "_comma")
        BroadcastVoiceMessage(player, "health_critical")
    elseif sentence == "HEV_AMO0" then
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "ammo_depleted")	
	elseif sentence == 14 then
        BroadcastVoiceMessage(player, "blip")
        BroadcastVoiceMessage(player, "blip")
		BroadcastVoiceMessage(player, "powermove_on")	
	elseif sentence == "HEV_BATT" then
		if not param or type(param) != "number" then error("HEV Sentence HEV_BATT called without proper param argument!") end
		-- two "fuzz" beeps
		BroadcastVoiceMessage(player, "fuzz")
		BroadcastVoiceMessage(player, "fuzz")
		BroadcastVoiceMessage(player, "_comma")

		-- Choose between "power" and "power_level_is"
		if param == player.mo.hl.maxarmor then
			BroadcastVoiceMessage(player, "power_level_is")
		else
			BroadcastVoiceMessage(player, "power")
			BroadcastVoiceMessage(player, "_comma")
		end

		-- get integer percent
		local percent = param >> FRACBITS

		-- round down to nearest multiple of 5
		local rounded = percent - (percent % 5)

		-- 3) map values to spoken names
		local nameMap = {
			[5]   = "five",         [10]  = "ten",        [15]  = "fifteen",
			[20]  = "twenty",       [30]  = "thirty",     [40]  = "fourty",
			[50]  = "fifty",        [60]  = "sixty",      [70]  = "seventy",
			[80]  = "eighty",       [90]  = "ninety",
		}

		-- handle 100+ separately
		if percent >= 100 then
			BroadcastVoiceMessage(player, "one_hundred")
			local subpercent = percent - 100
			local roundedSub = subpercent - (subpercent % 5)

			if nameMap[roundedSub] then
				BroadcastVoiceMessage(player, nameMap[roundedSub])
			else
				local tens = roundedSub - (roundedSub % 10)
				local ones = roundedSub % 10
				if nameMap[tens] then BroadcastVoiceMessage(player, nameMap[tens]) end
				if ones ~= 0 then BroadcastVoiceMessage(player, nameMap[ones]) end
			end

		else
			if nameMap[rounded] then
				BroadcastVoiceMessage(player, nameMap[rounded])
			else
				local tens = rounded - (rounded % 10)
				local ones = rounded % 10
				if nameMap[tens] then BroadcastVoiceMessage(player, nameMap[tens]) end
				if ones ~= 0 then BroadcastVoiceMessage(player, nameMap[ones]) end
			end
		end

		BroadcastVoiceMessage(player, "percent")
	end
	
	if type(param) == "function" then
		param(sentence, player)
	end
end)

addHook("PlayerThink", function(player)
	if not player.hl then return end
	if not player.hl.config.suitvolume then return end
	if not player.mo then return end
	player.voxBuffer = $ or {{}, {}} -- Two channels: [1] (priority) and [2] (main)
	local voxBuffer = player.voxBuffer

	-- Initialize channel states if not already set
	player.voxCurrent = $ or {nil, nil}
	player.voxDelay = $ or {nil, nil}

	for ch = 1, 2 do
		-- If not delaying and nothing playing, try to play the next sound
		if not player.voxDelay[ch] and (not player.voxCurrent[ch] or not S_IdPlaying(player.voxCurrent[ch])) then
			local nextSoundName = table.remove(voxBuffer[ch], 1)
			if nextSoundName then
				local sfxIndex = hevsounds[nextSoundName] or nextSoundName
				if sfxIndex == sfx_hevcma or sfxIndex == sfx_hevprd then
					player.voxDelay[ch] = 7
				else
					player.voxCurrent[ch] = sfxIndex
					if type(sfxIndex) == "string" then error("Sound " .. sfxIndex .. " is a string! Did you make sure to properly register or freeslot it?") end
					S_StartSoundAtVolume(nil, sfxIndex, player.hl.config.suitvolume, player)
				end
			end
		elseif player.voxDelay[ch] then
			player.voxDelay[ch] = $ - 1
		end
	end

	-- Play voice if armor goes above a multiple of five
	if player.prevarmor and (player.mo.hl.armor > player.prevarmor.real and FixedFloor(player.mo.hl.armor / 5) > player.prevarmor.rounded) then
		FVox_WarnDamage("HEV_BATT", player, player.mo.hl.armor)
	end
	player.prevarmor = {real = player.mo.hl.armor, rounded = FixedFloor(player.mo.hl.armor / 5)}
	for k, v in pairs(player.hl.suitvoicewait or {}) do
		if v == nil or v <= 0 then continue end
		player.hl.suitvoicewait[k] = (v or 0) - 1
	end
end)

COM_AddCommand("hl_hevtest", function(player, line)
	if not (player and player.mo)
		CONS_Printf(player,"Can't do that right now.")
		return
	end
	
	FVox_WarnDamage(line, player)
end)