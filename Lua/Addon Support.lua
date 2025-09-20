local WEAPON_NONE = -1

local function safeGetMT(mt)
	local success, value = pcall(function() return type(mt) == "string" and _G[mt] or mt end)
	return success and value or nil
end

local function HL_CreateItem(mt, stats)
	local mobj = type(mt) == "string" and _G[mt] or mt
	if not mobj return end
	HL_PickupStats[mobj] = stats
end

local function scaleFaccioloHealth(facc)
	local h = facc.health or 0

	if facc.phase == 1 then
		-- Phase 1 (short)
		return h * 50 -- Makes each point ~.357 power
	elseif facc.phase == 2 then
		-- Phase 2 (scalable)
		-- Optional: Add scaling based on actual player count
		local playercount = 0
		for player in players.iterate do
			if player.mo and player.mo.valid then
				playercount = $ + 1
			end
		end

		local base = 400
		local perplayer = 100
		local expectedmax = 146

		-- Normalize and scale
		local ratio = FRACUNIT * h / expectedmax
		local scaledhp = base + (perplayer * (playercount - 1))
		return FixedMul(scaledhp * FRACUNIT, ratio) / FRACUNIT
	end

	-- Fallback if we don't recognize the health
	return h * 10
end

local function CheckAddons()
	if RSR then
		-- Ringslinger Revolution:
		HL_CreateItem(safeGetMT("MT_RSR_HEALTH_SMALL"), {health = {give = 10}})
		HL_CreateItem(safeGetMT("MT_RSR_HEALTH"), {health = {give = 25}})
		HL_CreateItem(safeGetMT("MT_RSR_HEALTH_BIG"), {health = {give = 50}})
		HL_CreateItem(safeGetMT("MT_RSR_ARMOR_SMALL"), {armor = {give = 10}})
		HL_CreateItem(safeGetMT("MT_RSR_ARMOR"), {armor = {give = 25}})
		HL_CreateItem(safeGetMT("MT_RSR_ARMOR_BIG"), {armor = {give = 50}})
		RSR.SKIN_INFO["kombifreeman"] = {
			noweapons = true,
			nodamage = true,
			noenemydamage = true,
			hudmodname = ""
		}
	end
	if DoomGuy
		-- DOOM:
		HL_CreateItem(safeGetMT(MT_ITEM_STIMPACK), {health = {give = 10}})
		HL_CreateItem(safeGetMT(MT_ITEM_HEALTHPACK), {health = {give = 25}})
		HL_CreateItem(safeGetMT(MT_ITEM_COMBAT_ARMOR), {armor = {set = "limit", maxmult = FRACUNIT*2, novox = true}})
		HL_CreateItem(safeGetMT(MT_ITEM_SECURITY_ARMOR), {armor = {set = "limit", maxmult = FRACUNIT, novox = true}})
		HL_CreateItem(safeGetMT(MT_POWERUP_BERSERK), {berserk = INT32_MAX})
		HL_CreateItem(safeGetMT(MT_POWERUP_BACKPACK), {ammo = {type = {"bull","shel","rckt","cell"}, give = {10,4,1,20}}, doubleammo = true})
		HL_CreateItem(safeGetMT(MT_ITEM_HEALTH), {health = {give = 1, maxmult = FRACUNIT*2}})
		HL_CreateItem(safeGetMT(MT_ITEM_ARMOR), {armor = {give = 1, maxmult = FRACUNIT*2}})
		HL_CreateItem(safeGetMT(MT_AMMO_CLIP), {ammo = {type = "bull", give = 10}})
		HL_CreateItem(safeGetMT(MT_AMMO_CLIP_BOX), {ammo = {type = "bull", give = 50}})
		HL_CreateItem(safeGetMT(MT_AMMO_SHELL), {ammo = {type = "shel", give = 4}})
		HL_CreateItem(safeGetMT(MT_AMMO_SHELL_BOX), {ammo = {type = "shel", give = 20}})
		HL_CreateItem(safeGetMT(MT_AMMO_ROCKET), {ammo = {type = "rckt", give = 1}})
		HL_CreateItem(safeGetMT(MT_AMMO_ROCKET_BOX), {ammo = {type = "rckt", give = 5}})
		HL_CreateItem(safeGetMT(MT_AMMO_CELL), {ammo = {type = "cell", give = 20}})
		HL_CreateItem(safeGetMT(MT_AMMO_CELL_PACK), {ammo = {type = "cell", give = 200}})
		HL_CreateItem(safeGetMT(MT_WEAPON_CHAINSAW), {weapon = "weapon_doom_chainsaw"})
		HL_CreateItem(safeGetMT(MT_WEAPON_PISTOL), {weapon = "weapon_doom_pistol"})
		HL_CreateItem(safeGetMT(MT_WEAPON_SHOTGUN), {weapon = "weapon_doom_shotgun"})
		HL_CreateItem(safeGetMT(MT_WEAPON_CHAINGUN), {weapon = "weapon_doom_chaingun"})
		if DOOMPREFS_ALWAYSRUN then
			HL_CreateItem(safeGetMT(MT_ITEM_SOUL_SPHERE), {health = {give = "maxhp", maxmult = FRACUNIT*2}})
			HL_CreateItem(safeGetMT(MT_ITEM_MEGA_SPHERE), {health = {give = "limit", maxmult = FRACUNIT*2}, armor = {give = "limit", maxmult = FRACUNIT*2, novox = true}})
			HL_CreateItem(safeGetMT(MT_ITEM_INVULNERABILITY_SPHERE), {invuln = {set = 20*TICRATE}})
			HL_CreateItem(safeGetMT(MT_WEAPON_SUPER_SHOTGUN), {weapon = "weapon_doom_supershotgun"})
			HL_CreateItem(safeGetMT(MT_WEAPON_ROCKET_LAUNCHER), {weapon = "weapon_doom_rpg"})
			HL_CreateItem(safeGetMT(MT_WEAPON_PLASMA_RIFLE), {weapon = "weapon_doom_plasma_rifle"})
			HL_CreateItem(safeGetMT(MT_WEAPON_BFG9000), {weapon = "weapon_doom_bfg9000"})
		else
			HL_CreateItem(safeGetMT(MT_ITEM_SOUL), {health = {give = "maxhp", maxmult = FRACUNIT*2}})
			HL_CreateItem(safeGetMT(MT_ITEM_MEGA), {health = {give = "limit", maxmult = FRACUNIT*2}, armor = {give = "limit", maxmult = FRACUNIT*2, novox = true}})
			HL_CreateItem(safeGetMT(MT_ITEM_INVULNERABILITY), {invuln = {set = 20*TICRATE}})
			HL_CreateItem(safeGetMT(MT_WEAPON_SUPERSHOTGUN), {weapon = "weapon_doom_supershotgun"})
			HL_CreateItem(safeGetMT(MT_WEAPON_ROCKETLAUNCHER), {weapon = "weapon_doom_rpg"})
			HL_CreateItem(safeGetMT(MT_WEAPON_PLASMARIFLE), {weapon = "weapon_doom_plasma_rifle"})
			HL_CreateItem(safeGetMT(MT_WEAPON_BFG9000), {weapon = "weapon_doom_bfg9000"})
		end
		HLItems.Add("weapon_doom_chainsaw", {
			viewmodel = "doom_chainsaw",
			weaponclass = "doom",
			neverdenyuse = true,
			weaponslot = 1,
			priority = 999,
			doomwepswitch = true,
			primary = {
				ammo = "ammo_melee",
				clipsize = WEAPON_NONE,
				israycaster = true,
				shotcost = 0,
				damagemin = 2,
				damagemax = 20,
				damageincs = 2,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_sawful,
				firedelay = 4,
			},
			pickupsound = sfx_wpnup,
			hitsound = sfx_sawhit,
			autoreload = true,
			maxdistance = 8,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Chainsaw (DOOM)",
		})
		HLItems.Add("weapon_doom_pistol", {
			viewmodel = "doom_pistol",
			weaponclass = "doom",
			weaponslot = 2,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 10,
				ammo = "ammo_9mm", -- Holy shit, DoomGuy uses live bulls as ammunition?! (no
				refireusesspread = true,
				israycaster = true,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_pist,
				firedelay = 14,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Pistol (DOOM)",
		})
		HLItems.Add("weapon_doom_shotgun", {
			viewmodel = "doom_shotgun",
			weaponclass = "doom",
			selectgraphic = "HL1HUDSHOTGUN",
			weaponslot = 3,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 4,
				israycaster = true,
				ammo = "ammo_buckshot",
				pellets = 7,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_sht,
				firedelay = 41,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Shotgun (DOOM)",
		})
		HLItems.Add("weapon_doom_supershotgun", {
			viewmodel = "doom_supershotgun",
			weaponclass = "doom",
			selectgraphic = "HL1HUDSHOTGUN",
			weaponslot = 3,
			priority = 998,
			doomwepswitch = true,
			primary = {
				pickupgift = 4,
				israycaster = true,
				ammo = "ammo_buckshot",
				pellets = 20,
				clipsize = WEAPON_NONE,
				shotcost = 2,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_ssg,
				firedelay = 48,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Super Shotgun",
		})
		HLItems.Add("weapon_doom_chaingun", {
			viewmodel = "doom_chaingun",
			weaponclass = "doom",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 4,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 10,
				ammo = "ammo_9mm",
				refireusesspread = true,
				israycaster = true,
				volley = 2,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 15,
				damageincs = 5,
				horizspread = 11*FRACUNIT/2,
				vertspread = 11*FRACUNIT/2,
				firesound = sfx_pist,
				firedelay = 4,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Chaingun",
		})
		HLItems.Add("weapon_doom_rpg", {
			viewmodel = "doom_rpg",
			weaponclass = "doom",
			selectgraphic = "HL1HUDRPG",
			weaponslot = 5,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 2,
				ammo = "ammo_rckt",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 20,
				damagemax = 160,
				damageincs = 20,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_rklaun,
				firedelay = 18,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
			},
			realname = "Rocket Launcher (DOOM)",
		})
		HLItems.Add("weapon_doom_plasma_rifle", {
			viewmodel = "doom_plasmarifle",
			weaponclass = "doom",
			selectgraphic = "HL1HUDGAUSS",
			weaponslot = 6,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 100,
				ammo = "ammo_cell",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 5,
				damagemax = 40,
				damageincs = 5,
				horizspread = 0,
				vertspread = 0,
				firesound = sfx_plasma,
				firedelay = 3,
			},
			pickupsound = sfx_wpnup,
			globalfiredelay = {
				ready = 23,
				firepost = 20,
			},
			realname = "Plasma Rifle",
		})
		HLItems.Add("weapon_doom_bfg9000", { -- UNFINISHED!! i mean most of these things are but this is majorly unfinished
			viewmodel = "doom_bfg9000",
			weaponclass = "doom",
			selectgraphic = "HL1HUDTAU",
			weaponslot = 7,
			priority = 999,
			doomwepswitch = true,
			primary = {
				pickupgift = 100,
				firefunc = function(player, mystats)
					S_StartSound(player.mo, sfx_bfg)
					return true
				end,
				ammo = "ammo_cell",
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damagemin = 100,
				damagemax = 800,
				damageincs = 100,
				horizspread = 0,
				vertspread = 0,
				firedelay = 10,
			},
			pickupsound = sfx_wpnup,
			autoreload = true,
			vmdlflip = false,
			globalfiredelay = {
				ready = 23,
				tilshootmobj = 30,
			},
			realname = "BFG9000",
		})
		if DOOMPREFS_ALWAYSRUN then
			HLItems.ammo_rckt.shootmobj = MT_DOOM_ROCKET
			HLItems.ammo_cell.shootmobj = MT_DOOM_PLASMA
		else
			HLItems.ammo_rckt.shootmobj = MT_DROCKET
			HLItems.ammo_cell.shootmobj = MT_DPLASMA
		end
		HL.DoDoomguyAccomodations = true -- Because the Rocket Launcher uses variables that WILL break DoomGuy if I just... *spawn* the object
	end

	-- SONIC DOOM II:
	do
	HL_SetMTStats(safeGetMT("MT_SD2_BUZZBOMBER"), {
		health = 400,
		dmgmult = 2*FRACUNIT,
		flinches = true
	}, {
		min = 10,
		max = 80,
		increments = 10
	})
	HL_SetMTStats(safeGetMT("MT_SD2_COCONUTS"), {health = 60, dmgmult = 2*FRACUNIT, flinches = true}, {min = 8, max = 24, increments = 8})
	HL_SetMTStats(safeGetMT("MT_SD2_GROUNDER_PISTOL"), {health = 20, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_GROUNDER_SHOTGUN"), {health = 30, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_GROUNDER_CHAINGUN"), {health = 30, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_METALSONIC"), {health = 700, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_PSEUDOKNUCKLES"), {health = 300, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 15, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_PSEUDOFLICKY"), {health = 300, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 24, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_PSEUDOTAILS"), {health = 400, dmgmult = 2*FRACUNIT, flinches = true}, {min = 3, max = 24, increments = 3})
	HL_SetMTStats(safeGetMT("MT_SD2_VILE_FIRE"), 0, {dmg = 90})
	HL_SetMTStats(safeGetMT("MT_SD2_OVASHORT"), {health = 150, dmgmult = 2*FRACUNIT, flinches = true}, {min = 4, max = 40, increments = 4})
	HL_SetMTStats(safeGetMT("MT_SD2_OVASHORT_SHADOW"), {health = 150, dmgmult = 2*FRACUNIT, flinches = true}, {min = 4, max = 40, increments = 4})
	HL_SetMTStats(safeGetMT("MT_SD2_OVASHOT"), 0, {min = 8, max = 64, increments = 8})
	HL_SetMTStats(safeGetMT("MT_SD2_OVARED"), {health = 1000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT("MT_SD2_OVAGRAY"), {health = 1000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT("MT_SD2_PSEUDOSUPER"), {health = 500, dmgmult = 2*FRACUNIT, flinches = true}, 0)
	HL_SetMTStats(safeGetMT("MT_SD2_PSEUDOSUPER_BALL"), 0, {min = 5, max = 40, increments = 5})
	HL_SetMTStats(safeGetMT("MT_SD2_REDMETALSONIC"), {health = 4000, dmgmult = 2*FRACUNIT, flinches = true}, {min = 10, max = 80, increments = 10})
	HL_SetMTStats(safeGetMT("MT_SD2_ROCKET"), 0, {min = 20, max = 160, increments = 20})
	end

	if safeGetMT("MT_BIGRING") then
		HL_CreateItem(MT_BIGRING, {health = {give = "maxhp", maxmult = FRACUNIT*2}})
		HL_CreateItem(MT_MEGARING, {health = {give = "limit", maxmult = FRACUNIT*2}, armor = {give = "limit", maxmult = FRACUNIT*2}})
		HL_CreateItem(MT_CHAOS_ARMOR_GREEN, {armor = {set = "limit", maxmult = FRACUNIT}})
		HL_CreateItem(MT_CHAOS_ARMOR_BLUE, {
			armor = {
				set = "limit",
				maxmult = FRACUNIT*2,
				novox = true
			}
		})
		HL_CreateItem(MT_CHAOS_ARMOR_ELEMENTAL, {armor = {set = "limit", maxmult = FRACUNIT*3/2}})
		HL.botsOnMobius = true
		/*
		HL.weaponAmmoTypes[MT_FAKE8] = true
		HL.weaponAmmoTypes[MT_FAKEBOMB] = true
		HL.weaponAmmoTypes[MT_FAKEHOME] = true
		HL.weaponAmmoTypes[MT_FAKERAIL] = true
		HL.weaponAmmoTypes[MT_FAKEAUTO] = true
		HL.weaponAmmoTypes[MT_FAKEBOUNCE] = true
		HL.weaponAmmoTypes[MT_FAKESPREAD] = true
		HL.weaponAmmoTypes[MT_FAKEGRENADE] = true
		*/

		local PG = {
			["9mmhandgun"] = HLItems["weapon_9mmhandgun"].primary.pickupgift,
			["357"]        = HLItems["weapon_357"].primary.pickupgift,
			["mp5"]        = {
				primary   = HLItems["weapon_mp5"].primary.pickupgift,
				secondary = HLItems["weapon_mp5"].secondary.pickupgift,
			},
			shotgun       = HLItems["weapon_shotgun"].primary.pickupgift,
			crossbow      = HLItems["weapon_crossbow"].primary.pickupgift,
			handgrenade   = HLItems["weapon_handgrenade"].primary.pickupgift,
			satchel       = HLItems["weapon_satchel"].primary.pickupgift,
		}

		HL.matchRingDefs[MT_FAKE8] = HL.matchRingDefs[MT_INFINITYRING]
		HL.matchRingDefs[MT_FAKEAUTO] = HL.matchRingDefs[MT_AUTOMATICRING]
		HL.matchRingDefs[MT_FAKESPREAD] = HL.matchRingDefs[MT_SCATTERRING]
		HL.matchRingDefs[MT_FAKEBOUNCE] = HL.matchRingDefs[MT_BOUNCERING]
		HL.matchRingDefs[MT_FAKEGRENADE] = HL.matchRingDefs[MT_GRENADERING]
		HL.matchRingDefs[MT_FAKEBOMB] = HL.matchRingDefs[MT_EXPLOSIONRING]
		HL.matchRingDefs[MT_FAKERAIL] = HL.matchRingDefs[MT_RAILRING]

		HL.matchRingDefs[MT_FAKEAUTOPANEL] = HL.matchRingDefs[MT_AUTOPICKUP]
		HL.matchRingDefs[MT_FAKESCATTERPANEL] = HL.matchRingDefs[MT_SCATTERPICKUP]
		HL.matchRingDefs[MT_FAKEBOUNCEPANEL] = HL.matchRingDefs[MT_BOUNCEPICKUP]
		HL.matchRingDefs[MT_FAKEGRENADEPANEL] = HL.matchRingDefs[MT_GRENADEPICKUP]
		HL.matchRingDefs[MT_FAKEEXPLODEPANEL] = HL.matchRingDefs[MT_EXPLODEPICKUP]
		HL.matchRingDefs[MT_FAKERAILPANEL] = HL.matchRingDefs[MT_RAILPICKUP]
	end

	if Silverhorn then
		HL_SetMTStats(MT_UNA_FORCE, {health = 300})

		addHook("ThinkFrame", function()
			local mo
			local facc

			for mobj in mobjs.iterate() do
				if mobj.type == MT_FACCIOLO_BOSS and mobj.facc then
					mo = mobj
					facc = mobj.facc
					break
				end
			end

			if not (mo and facc) then return end

			if (facc.health or 0) > (facc.hloldhealth or 0) then
				mo.hl.health = scaleFaccioloHealth(facc)
				mo.hl.maxhealth = mo.hl.health
				print("Refresh...", facc.health .. " health makes " .. mo.hl.health .. "(Old HP was " .. facc.hloldhealth .. ")")
			end
			facc.hloldhealth = facc.health
		end)
	end
	
	if sfx_BALPOF and sfx_puyo1 and sfx_pspawn and sfx_blkout then
		HL_SetMTStats(MT_SF94_OLDNPC, {health = INT32_MAX})
		HL_SetMTStats(MT_SF94_OLDSTANDNPC, {health = INT32_MAX})
	end
	
	if sfx_scream and sfx_tdsee and sfx_redscr then
		HL.DoTDForestAccomodations = true
	end

	if MM then
		MM.addHook("MovementSpeedCap", function(player)
			if player.mo.skin != "kombifreeman" then return end
			return 60*FRACUNIT
		end)
		MM.addHook("CorpseThink", function(corpse)
			if corpse.skin != "kombifreeman" then return end
			local player = players[corpse.playerid]
			local pcam = player.awayviewmobj
			if pcam and pcam.valid then
				P_MoveOrigin(corpse, player.awayviewmobj.x,player.awayviewmobj.y,corpse.z)
				corpse.backup = {x = pcam.momx, y = pcam.momy, z = pcam.momz}
			elseif corpse.backup then
				corpse.momx, corpse.momy, corpse.momz = corpse.backup.x, corpse.backup.y, corpse.backup.z
			end
		end)
		MM.addHook("GiveStartWeapon", function(player)
			local EpicMMItemSwaps = {
				[MMROLE_SHERIFF] = "357",
				[MMROLE_MURDERER] = "crowbar"
			}
			HL_ApplyPickupStats(player, {weapon = EpicMMItemSwaps[player.mm.role]})
		end)
	end
	
	if MetroidVanguard then
	
	end

	-- Duke Nukem 3D Weapons
	if duke_roboinfo and sfx_shtcck then
		local mightyboot = {
			ammo = "ammo_none",
			clipsize = WEAPON_NONE,
			shotcost = 0,
			damage = 6,
			horizspread = 5*FRACUNIT,
			vertspread = 5*FRACUNIT,
			firedelay = 6,
		}

		HLItems.Add("weapon_duke_pistol", {
			viewmodel = "duke_pistol",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 1,
			priority = 999,
			primary = {
				ammo = "ammo_9mm",
				israycaster = true,
				pickupgift = 48,
				clipsize = 12,
				shotcost = 1,
				damage = 6,
				refireusesspread = true,
				horizspread = 5*FRACUNIT,
				vertspread = 5*FRACUNIT,
				firesound = sfx_pistol,
				reloadsound = sfx_pstcck,
				firedelay = 6,
			},
			secondary = mightyboot,
			pickupsound = sfx_pstcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Pistol (Duke3D)",
		})

		HLItems.Add("weapon_duke_shotgun", {
			viewmodel = "duke_shotgun",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUDSHOTGUN",
			weaponslot = 2,
			priority = 999,
			primary = {
				ammo = "ammo_buckshot",
				israycaster = true,
				pickupgift = 48,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damage = 10,
				pellets = 7,
				horizspread = 7*FRACUNIT,
				vertspread = 7*FRACUNIT,
				firesound = sfx_shtgun,
				firedelay = 36,
			},
			secondary = mightyboot,
			pickupsound = sfx_shtcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Shotgun (Duke3D)",
		})
/*
		HLItems.Add("weapon_duke_chaingun", {
			viewmodel = "duke_shotgun",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 3,
			priority = 999,
			primary = {
				ammo = "ammo_9mm",
				israycaster = true,
				pickupgift = 48,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				damage = 6,
				horizspread = 5*FRACUNIT,
				vertspread = 5*FRACUNIT,
				kickback = 5*FRACUNIT/2,
				firesound = sfx_dchain,
				firedelay = 4,
			},
			secondary = mightyboot,
			pickupsound = sfx_pstcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Chaingun (Duke3D)",
		})
*/
	end

	-- Wolfenstein 3D Weapons
	if sfx_wpist then
		local function W3D_RangedHit(player, victim)
			local wolf3DTileToFrac = 64*FRACUNIT
			local dist2 = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y)
			if dist2 < (wolf3DTileToFrac*2*FRACUNIT)^2 then
				return P_RandomByte() >> 2
			elseif dist2 < (wolf3DTileToFrac*4*FRACUNIT)^2 then
				return P_RandomByte() / 6
			else
				local misschance = P_RandomByte() / 12
				local approx_dist_tiles = dist2 / (64*FRACUNIT)
				if misschance < approx_dist_tiles then
					return 0
				end
				return P_RandomByte() / 6
			end
		end

		HLItems.Add("weapon_wolf_knife", {
			viewmodel = "wolf_knife",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 1,
			priority = 999,
			primary = {
				ammo = "ammo_melee",
				israycaster = true,
				clipsize = WEAPON_NONE,
				shotcost = 0,
				damagemin = 1,
				damagemax = 15,
				damageincs = 1,
				firesound = sfx_wknif,
				firedelay = 12,
				maxdistance = 96*FRACUNIT,
				fireoffset = 6,
			},
			pickupsound = sfx_wammo,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Knife (Wolf3D)",
		})

		HLItems.Add("weapon_wolf_pistol", {
			viewmodel = "wolf_pistol",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 2,
			priority = 999,
			primary = {
				ammo = "ammo_9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				firesound = sfx_wpist,
				firedelay = 12,
				fireoffset = 3,
				firehitfunc = W3D_RangedHit
			},
			pickupsound = sfx_wammo,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Pistol (Wolf3D)",
		})

		HLItems.Add("weapon_wolf_machinegun", {
			viewmodel = "wolf_machinegun",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 3,
			priority = 999,
			primary = {
				ammo = "ammo_9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				refiredelay = 2,
				firedelay = 8,
				fireoffset = 2,
				refireoffset = 0,
				firesound = sfx_wmgun,
				firehitfunc = W3D_RangedHit
			},
			pickupsound = sfx_wmgpic,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Machine Gun (Wolf3D)",
		})

		HLItems.Add("weapon_wolf_chaingun", {
			viewmodel = "wolf_chaingun",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 4,
			priority = 999,
			primary = {
				ammo = "ammo_9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = WEAPON_NONE,
				shotcost = 1,
				refiredelay = 0,
				firedelay = 8,
				fireoffset = 2,
				refireoffset = 0,
				volleyfireoffset = 2,
				volleyfiredelay = 2,
				volley = 2,
				firesound = sfx_wcgun,
				firehitfunc = W3D_RangedHit
			},
			pickupsound = sfx_wcgpic,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Chaingun (Wolf3D)",
		})
	end
end

addHook("AddonLoaded", function()
	if OLDC and OLDC.SkinFullNames and not OLDC.SkinFullNames["kombifreeman"]
		if P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "JOHN HALFLIFE"
		elseif P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "GORDON FREEMAN THE THEORETICAL PHYSICIST"
		elseif P_RandomChance(FRACUNIT/4)
			OLDC.SkinFullNames["kombifreeman"] = "GORDON THE FREEMAN"
		else
			OLDC.SkinFullNames["kombifreeman"] = "GORDON FREEMAN"
		end
	end
	CheckAddons()
end)

CheckAddons()
/*
	if duke_roboinfo then
		HLItems.v_duke3dshotgun.animations.primaryfire.frameSounds = {nil, nil, nil, nil, nil, sfx_shtcck}
		local mightyboot = {
			ammo = "none",
			clipsize = -1,
			shotcost = 0,
			damage = 6,
			horizspread = 5*FRACUNIT,
			vertspread = 5*FRACUNIT,
			firedelay = 6,
		}
		HL_DefineWeapon("dukepistol", {
			viewmodel = "DUKEPIST",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 1,
			priority = 999,
			primary = {
				ammo = "9mm",
				israycaster = true,
				pickupgift = 48,
				clipsize = 12,
				shotcost = 1,
				damage = 6,
				refireusesspread = true,
				horizspread = 5*FRACUNIT,
				vertspread = 5*FRACUNIT,
				firesound = sfx_pistol,
				reloadsound = sfx_pstcck,
				firedelay = 6,
			},
			secondary = mightyboot,
			pickupsound = sfx_pstcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Pistol (Duke3D)",
		})
		HL_DefineWeapon("dukeshotgun", {
			viewmodel = "DUKESHOT",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUDSHOTGUN",
			weaponslot = 2,
			priority = 999,
			primary = {
				ammo = "buckshot",
				israycaster = true,
				pickupgift = 48,
				clipsize = -1,
				shotcost = 1,
				damage = 10,
				pellets = 7,
				horizspread = 7*FRACUNIT,
				vertspread = 7*FRACUNIT,
				firesound = sfx_shtgun,
				firedelay = 36,
			},
			secondary = mightyboot,
			pickupsound = sfx_shtcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Pistol (Duke3D)",
		})
		HL_DefineWeapon("dukechaingun", {
			viewmodel = "DUKESHOT",
			weaponclass = "duke3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 3,
			priority = 999,
			primary = {
				ammo = "9mm",
				israycaster = true,
				pickupgift = 48,
				clipsize = -1,
				shotcost = 1,
				damage = 6,
				horizspread = 5*FRACUNIT,
				vertspread = 5*FRACUNIT,
				kickback = 5*FRACUNIT/2,
				firesound = sfx_dchain,
				firedelay = 4,
			},
			secondary = mightyboot,
			pickupsound = sfx_pstcck,
			globalfiredelay = {
				ready = 9,
				reload = 30,
			},
			realname = "Chaingun (Duke3D)",
		})
	end

	if sfx_wpist then
		HL_DefineWeapon("wolfknife", {
			viewmodel = "WOLFKNIF",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 1,
			priority = 999,
			primary = {
				ammo = "melee",
				israycaster = true,
				clipsize = -1,
				shotcost = 0,
				damagemin = 1,
				damagemax = 15,
				damageincs = 1,
				firesound = nil,
				firedelay = 12,
				maxdistance = 12,
				fireoffset = 6,
				firesound = sfx_wknif,
			},
			pickupsound = sfx_wammo,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Knife (Wolf3D)",
		})
		HL_DefineWeapon("wolfpistol", {
			viewmodel = "WOLFPIST",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUD9MM",
			weaponslot = 2,
			priority = 999,
			primary = {
				ammo = "9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = -1,
				shotcost = 1,
				firesound = nil,
				firedelay = 12,
				fireoffset = 3,
				firesound = sfx_wpist,
				firehitfunc = function(player, victim)
					local dist2 = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y)

					if dist2 < (64*2*FRACUNIT)^2 then
						return P_RandomByte() >> 2
					elseif dist2 < (64*4*FRACUNIT)^2 then
						return P_RandomByte() / 6
					else
						local misschance = P_RandomByte() / 12
						-- Compare misschance to "distance in tiles", rounded down
						local approx_dist_tiles = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y) / (64*FRACUNIT)
						if misschance < approx_dist_tiles then
							return 0  -- Missed
						end
						return P_RandomByte() / 6
					end
				end
			},
			pickupsound = sfx_wammo,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Pistol (Wolf3D)",
		})
		HL_DefineWeapon("wolfmachinegun", {
			viewmodel = "WOLFMACH",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 3,
			priority = 999,
			primary = {
				ammo = "9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = -1,
				shotcost = 1,
				firesound = nil,
				refiredelay = 2,
				firedelay = 8,
				fireoffset = 2,
				refireoffset = 0,
				firesound = sfx_wmgun,
				firehitfunc = function(player, victim)
					local dist2 = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y)

					if dist2 < (64*2*FRACUNIT)^2 then
						return P_RandomByte() >> 2
					elseif dist2 < (64*4*FRACUNIT)^2 then
						return P_RandomByte() / 6
					else
						local misschance = P_RandomByte() / 12
						-- Compare misschance to "distance in tiles", rounded down
						local approx_dist_tiles = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y) / (64*FRACUNIT)
						if misschance < approx_dist_tiles then
							return 0  -- Missed
						end
						return P_RandomByte() / 6
					end
				end
			},
			pickupsound = sfx_wmgpic,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Machine Gun (Wolf3D)",
		})
		HL_DefineWeapon("wolfchaingun", {
			viewmodel = "WOLFCHAI",
			weaponclass = "wolf3d",
			selectgraphic = "HL1HUDMP5",
			weaponslot = 4,
			priority = 999,
			primary = {
				ammo = "9mm",
				pickupgift = 6,
				israycaster = true,
				clipsize = -1,
				shotcost = 1,
				firesound = nil,
				refiredelay = 0,
				firedelay = 8,
				fireoffset = 2,
				refireoffset = 0,
				volleyfireoffset = 2,
				volleyfiredelay = 2,
				volley = 2,
				firesound = sfx_wcgun,
				firehitfunc = function(player, victim)
					local dist2 = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y)

					if dist2 < (64*2*FRACUNIT)^2 then
						return P_RandomByte() >> 2
					elseif dist2 < (64*4*FRACUNIT)^2 then
						return P_RandomByte() / 6
					else
						local misschance = P_RandomByte() / 12
						-- Compare misschance to "distance in tiles", rounded down
						local approx_dist_tiles = R_PointToDist2(player.mo.x, player.mo.y, victim.x, victim.y) / (64*FRACUNIT)
						if misschance < approx_dist_tiles then
							return 0  -- Missed
						end
						return P_RandomByte() / 6
					end
				end
			},
			pickupsound = sfx_wcgpic,
			globalfiredelay = {
				ready = 9,
			},
			realname = "Chaingun (Wolf3D)",
		})
	end
*/