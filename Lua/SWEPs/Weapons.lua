-- Weapon entries
HLItems.Add("weapon_crowbar", {
    viewmodel = "CROWBAR",
	vmdlflip = true,
    selectgraphic = "HL1HUDCROWBAR",
    autoswitchweight = 0,
    weaponslot = 1,
    priority = 1,
    killicon = "HLKILLCROWBAR",
    primary = {
    	israycaster = true, -- determines if the bullet object takes the guy with the lightning's advice if it doesn't hit anything (and applies a distance limit)
    	ammo = "ammo_melee",
    	ismelee = true, -- Gets affected by DoomGuy's berserk if set to true.
    	clipsize = WEAPON_NONE,
    	shotcost = 0,
    	damage = 5,
    	firesound = sfx_hlcbar,
    	firehitsound = sfx_hlcbh1,
    	firehitsounds = 2,
    	maxdistance = FixedMul(MELEERANGE, FRACUNIT*3/2),
    	firedelay = 18,
    	hitdelay = 9,
    },
    altfire = false,
    globalfiredelay = {
    	ready = 12,
    },
    realname = "Crowbar",
})
/*
HLItems.Add("weapon_knife", {
    viewmodel = "KNIFE",
    		vmdlflip = true,
    		selectgraphic = "HL1HUDCROWBAR",
    		autoswitchweight = 0,
    		weaponslot = 1,
    		priority = 1,
    		killicon = "HLKILLCROWBAR",
    		primary = {
    			israycaster = true,
    			ammo = "ammo_melee",
    			ismelee = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 0,
    			damage = 5,
    			firesound = sfx_hlcbar,
    			firehitsound = sfx_hlcbh1,
    			firehitsounds = 2,
    			maxdistance = FixedMul(MELEERANGE, FRACUNIT*3/2),
    			firedelay = 18,
    			hitdelay = 9,
    		},
    		altfire = false,
    		globalfiredelay = {
    			ready = 12,
    		},
    		realname = "Crowbar",
})
*/
HLItems.Add("weapon_9mmhandgun", {
    viewmodel = "PISTOL",
    		crosshair = "XHRPIS",
    		selectgraphic = "HL1HUD9MM",
    		autoswitchweight = 10,
    		weaponslot = 2,
    		priority = 1,
    		killicon = "HLKILL9MM",
    		nounderwater = true,
    		primary = {
    			ammo = "ammo_9mm",
    			israycaster = true,
    			pickupgift = 17,
    			clipsize = 17,
    			shotcost = 1,
    			damage = 8,
    			refireusesspread = true,
    			horizspread = 5*FRACUNIT,
    			vertspread = 5*FRACUNIT,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1g17,
    			firedelay = 12,
    		},
    		autoreload = true,
    		secondary = {
    			ammo = "ammo_none",
    			israycaster = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			horizspread = 5,
    			vertspread = 5,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1g17,
    			firedelay = 6,
    			damage = 8,
    		},
    		altfire = true,
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 12,
    			reload = 53,
    			reloadpost = 18,
    		},
    		substitutes = {
    			doomguy = "pistol",
    			duke = 1,
    			bj = 2,
    			other = "matchring"
    		},
    		realname = "9mm Handgun",
})

HLItems.Add("weapon_357", {
    viewmodel = "357-",
    		crosshair = "XHR357",
    		selectgraphic = "HL1HUD357",
    		autoswitchweight = 15,
    		weaponslot = 2,
    		priority = 2,
    		killicon = "HLKILL357",
    		primary = {
    			ammo = "ammo_357",
    			israycaster = true,
    			clipsize = 6,
    			pickupgift = 6,
    			shotcost = 1,
    			damage = 50,
    			horizspread = 0,
    			vertspread = 0,
    			kickback = 7*FRACUNIT,
    			firesound = sfx_hl3571,
    			firesounds = 2,
    			firedelay = 26,
    		},
    		secondary = {
    			firefunc = function()
    				return true
    			end
    		},
    		autoreload = true,
    		altfire = true,
    		secondary = {
    			firefunc = function(player, mystats)
    				if multiplayer then
    					player.hl.zoomed = not $
    				end
    				return true
    			end,
    			firedelay = 18,
    		},
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 18,
    			reload = 92
    		},
    		substitutes = {
    			doomguy = "supershotgun",
    			duke = 2,
    			bj = 2,
    			other = "railring"
    		},
    		realname = ".357",
})

HLItems.Add("weapon_mp5", {
    viewmodel = "MP5-",
    		crosshair = "XHR9MM",
    		selectgraphic = "HL1HUDMP5",
    		autoswitchweight = 15,
    		weaponslot = 3,
    		priority = 1,
    		killicon = "HLKILLMP5",
    		nounderwater = true,
    		primary = {
    			pickupgift = 25,
    			ammo = "ammo_9mm",
    			israycaster = true,
    			clipsize = 50,
    			shotcost = 1,
    			damage = 8,
    			horizspread = 4*FRACUNIT,
    			vertspread = 4*FRACUNIT,
    			kickback = 1*FRACUNIT,
    			kickbackcanflip = true,
    			firesound = sfx_hl1ar1,
    			firesounds = 3,
    			firedelay = 4,
    		},
    		secondary = {
    			pickupgift = 2,
    			noreserveammo = true,
    			ammo = "ammo_argrenade",
    			killicon = "HLKILLGRENADEAR",
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			kickback = 10*FRACUNIT,
    			firesound = sfx_hlarg1,
    			explosionradius = 192*FRACUNIT,
    			firesounds = 2,
    			firedelay = 20,
    		},
    		globalfiredelay = {
    			ready = 12,
    			reload = 53
    		},
    		substitutes = {
    			doomguy = "chaingun",
    			duke = 3,
    			bj = 3,
    			other = "automaticring"
    		},
    		realname = "MP5",
})

HLItems.Add("weapon_shotgun", {
    viewmodel = "SHOTGUN",
    		crosshair = "XHRSHOT",
    		selectgraphic = "HL1HUDSHOTGUN",
    		autoswitchweight = 15,
    		weaponslot = 3,
    		priority = 2,
    		killicon = "HLKILLSHOTGUN",
    		nounderwater = true,
    		primary = {
    			reloadincrement = 1,
    			israycaster = true,
    			ammo = "ammo_buckshot",
    			pellets = 6,
    			clipsize = 8,
    			shotcost = 1,
    			pickupgift = 12, -- why does the shotgun have 12 shells in it? is it stupid?
    			damage = 5,
    			horizspread = 5*FRACUNIT,
    			vertspread = 5*FRACUNIT,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1sg1,
    			firedelay = 36,
    		},
    		autoreload = true,
    		secondary = {
    			ammo = "ammo_none",
    			israycaster = true,
    			pellets = 12,
    			clipsize = WEAPON_NONE,
    			shotcost = 2,
    			damage = 5,
    			horizspread = 5*FRACUNIT,
    			vertspread = 5*FRACUNIT,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hldsht,
    			firedelay = 59,
    		},
    		altfire = true,
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 12,
    			["reloadstart"] = 18,
    			["reloadloop"] = 20,
    		},
    		substitutes = {
    			doomguy = "shotgun",
    			duke = 3,
    			bj = 3,
    			other = "scatterring"
    		},
    		realname = "SPAS-12",
})

HLItems.Add("weapon_crossbow", {
    viewmodel = "CROSSBOW",
    		crosshair = "XHRXBW",
    		selectgraphic = "HL1HUDCROSSBOW",
    		autoswitchweight = 10,
    		weaponslot = 3,
    		priority = 3,
    		killicon = "HLKILLCROSSBOW",
    		primary = {
    			ammo = "ammo_bolt",
    			clipsize = 5,
    			shotcost = 1,
    			pickupgift = 5,
    			damage = 50,
    			kickback = 3*FRACUNIT,
    			firesound = sfx_hlxbfr,
    			firedelay = 24,
    			explodeonhit = function()
    				return cv_deathmatch.value
    			end,
    			explosiondamage = 60,
    			explosionradius = 96 * FRACUNIT,
    		},
    		autoreload = true,
    		secondary = {
    			firefunc = function(player, mystats)
    				player.hl.zoomed = not $
    				player.weaponaltdelay = TICRATE
    				return true
    			end,
    			firedelay = TICRATE,
    		},
    		altfire = true,
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 16,
    			reload = 104,
    			reloadpost = 48,
    		},
    		substitutes = {
    			doomguy = "supershotgun",
    			duke = 2,
    			bj = 1,
    			other = "railring"
    		},
    		realname = "Crossbow",
})
/*
HLItems.Add("weapon_deagle", {
    viewmodel = "357-",
    		crosshair = "XHRDEA",
    		selectgraphic = "HL1HUDDEAGLE",
    		autoswitchweight = 15,
    		weaponslot = 2,
    		priority = 2,
    		killicon = "HLKILL357",
    		primary = {
    			ammo = "ammo_357",
    			israycaster = true,
    			clipsize = 7,
    			pickupgift = 19,
    			shotcost = 1,
    			damage = 80,
    			horizspread = 0,
    			vertspread = 0,
    			kickback = 11*FRACUNIT/2,
    			firesound = sfx_hl3571,
    			firesounds = 2,
    			firedelay = 18,
    		},
    		secondary = {
    			firefunc = function()
    				return true
    			end
    		},
    		autoreload = true,
    		altfire = true,
    		secondary = {
    			firefunc = function(player, mystats)
    				if multiplayer then
    					player.hl.zoomed = not $
    				end
    				return true
    			end,
    			firedelay = 18,
    		},
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 24,
    			ammoin = 54,
    			reload = 63
    		},
    		substitutes = {
    			doomguy = "supershotgun",
    			duke = 2,
    			bj = 1,
    			other = "railring"
    		},
    		realname = "Desert Eagle",
})
*/
HLItems.Add("weapon_rpg", {
    viewmodel = "PISTOL",
    		crosshair = "XHRRPG",
    		selectgraphic = "HL1HUDRPG",
    		autoswitchweight = 20,
    		weaponslot = 4,
    		priority = 1,
    		killicon = "HLKILLRPG",
    		nounderwater = true,
    		primary = {
    			pickupgift = 1,
    			ammo = "ammo_rocket",
    			clipsize = 1,
    			shotcost = 1,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hlrckt,
    			firedelay = 35,
    		},
    		autoreload = true,
    		altfire = false,
    		globalfiredelay = {
    			ready = 15,
    			["normal"] = 35,
    			reload = 36,
    			["reloadpost"] = 24,
    		},
    		realname = "Rocket Launcher",
})

HLItems.Add("weapon_gauss", {
    viewmodel = "PISTOL",
    		crosshair = "XHRGAUS",
    		selectgraphic = "HL1HUDTAU",
    		autoswitchweight = 20,
    		pickupgift = 20,
    		weaponslot = 4,
    		priority = 2,
    		killicon = "HLKILLTAU",
    		nounderwater = true,
    		primary = {
    			ammo = "ammo_uranium",
    			israycaster = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1g17,
    			firedelay = 12,
    		},
    		autoreload = true,
    		altfire = false,
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 12,
    			["normal"] = 12,
    			["alt"] = 6,
    			reload = 54,
    		},
    		realname = "Tau Cannon",
})

HLItems.Add("weapon_egon", {
    viewmodel = "PISTOL",
    		crosshair = "XHREGON",
    		selectgraphic = "HL1HUDGAUSS",
    		autoswitchweight = 20,
    		pickupgift = 20,
    		weaponslot = 4,
    		priority = 3,
    		killicon = "HLKILLGLUON",
    		nounderwater = true,
    		primary = {
    			ammo = "ammo_uranium",
    			israycaster = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1g17,
    			firedelay = 12,
    		},
    		autoreload        = true,
    		altfire           = false,
    		altusesprimaryclip= true,
    		globalfiredelay = {
    			ready = 12,
    			["normal"] = 12,
    			["alt"] = 6,
    			reload = 54,
    		},
    		realname = "Gluon Gun",
})

HLItems.Add("weapon_hornetgun", {
    viewmodel = "PISTOL",
    		crosshair = "XHRHNET",
    		selectgraphic = "HL1HUDHORNET",
    		autoswitchweight = 15,
    		weaponslot = 4,
    		priority = 4,
    		killicon = "HLKILLHIVEHAND",
    		primary = {
    			ammo = "ammo_hornet",
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			kickback = 5*FRACUNIT/2,
    			firesound = sfx_hl1g17,
    			firedelay = 12,
    		},
    		autoreload = true,
    		altfire = false,
    		altusesprimaryclip = true,
    		globalfiredelay = {
    			ready = 12,
    			reload = 54,
    		},
    		realname = "Hivehand",
})

HLItems.Add("weapon_handgrenade", {
    viewmodel = "GRENADE",
    		selectgraphic = "HL1HUDGRENADE",
    		autoswitchweight = 5,
    		weaponslot = 5,
    		priority = 1,
    		killicon = "HLKILLGRENADEAR",
    		primary = {
    			carrymomentum = true,
    			pickupgift = 5,
    			ammo = "ammo_grenade",
    			clipsize = WEAPON_NONE,
    			fuse = 3*TICRATE,
    			cookable = true,
    			shotcost = 1,
    			damage = 1,
    			firesound = sfx_none,
    			firedelay = 12,
    		},
    		autoreload = true,
    		altfire = false,
    		globalfiredelay = {
    			ready = 12,
    			reload = 54,
    		},
    		substitutes = {
    			doomguy = "rpg",
    			duke = 2,
    			bj = 4,
    			other = "bouncering"
    		},
    		realname = "Grenades",
})

HLItems.Add("weapon_satchel", {
    viewmodel = "PISTOL",
    		selectgraphic = "HL1HUDSATCHEL",
    		autoswitchweight = 5,
    		weaponslot = 5,
    		priority = 2,
    		killicon = "HLKILLSATCHEL",
    		primary = {
    			pickupgift = 1,
    			ammo = "ammo_satchel",
    			maxdeploy = 30,
    			carrymomentum = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			firesound = sfx_none,
    			firedelay = 12,
    			parenttofirer = true,
    		},
    		secondary = {
    			ammo = "ammo_none",
    			neverdenyuse = true,
    			firefunc = function(player)
    				for k, mobj in pairs(player.hl.objects.weapon_satchel) do
						if not (mobj and mobj.valid) then continue end
    					mobj.state = S_HL1_EXPLOSION
    					A_HLExplode(mobj, 192*FRACUNIT, 192)
    				end
    				player.hl.objects.weapon_satchel = {}
    				return true
    			end
    		},
    		altfire = true,
    		globalfiredelay = {
    			ready = 12,
    			["alt"] = 6,
    			reload = 54,
    		},
    		substitutes = {
    			doomguy = "rpg",
    			duke = 2,
    			bj = 4,
    			other = "bouncering"
    		},
    		realname = "Satchels",
})

HLItems.Add("weapon_tfcmedkit", {
    viewmodel = "MEDKITTFC",
    		selectgraphic = "HL1HUDSATCHEL",
    		autoswitchweight = 5,
    		weaponslot = 1,
    		priority = 0,
    		killicon = "HLKILLSATCHEL",
    		primary = {
    			ammo = "ammo_none",
    			israycaster = true,
    			maxdistance = FixedMul(MELEERANGE, FRACUNIT*3/2),
    			damage = 1000000,
    			carrymomentum = true,
    			neverdenyuse = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 0,
    			firesound = sfx_none,
    			firedelay = 12,
    			firehitfunc = function(shooter, victim)
    				if not victim.player then return 9 end
    				if HL_IsAlly(shooter, victim.player, false) then
    					return -10
    				else
    					victim.player.hl.infectionclock = 5*TICRATE
    					return 9
    				end
    			end
    		},
    		globalfiredelay = {
    			ready = 12,
    			["alt"] = 6,
    			reload = 54,
    		},
    		realname = "Medkit",
})

HLItems.Add("weapon_tripmine", {
    viewmodel = "PISTOL",
    		selectgraphic = "HL1HUDTRIPMINE",
    		autoswitchweight = -10, -- VERY unlikely we'll even need to check past here.
    		weaponslot = 5,
    		priority = 3,
    		killicon = "HLKILLTRIPMINE",
    		primary = {
    			pickupgift = 1,
    			ammo = "ammo_tripmine",
    			israycaster = true,
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			firesound = sfx_none,
    			firedelay = 12,
    			maxdistance = MELEERANGE,
    		},
    		autoreload = true,
    		altfire = false,
    		globalfiredelay = {
    			ready = 12,
    			["normal"] = 12,
    			["alt"] = 6,
    			reload = 54,
    		},
    		realname = "Tripmines",
})

HLItems.Add("weapon_snark", {
    viewmodel = "PISTOL",
    		selectgraphic = "HL1HUDSNARK",
    		autoswitchweight = -10,
    		weaponslot = 5,
    		priority = 4,
    		killicon = "HLKILLSNARK",
    		primary = {
    			ammo = "ammo_snark",
    			clipsize = WEAPON_NONE,
    			shotcost = 1,
    			pickupgift = 5,
    			firesound = sfx_none,
    			equipframeSound = sfx_none,
    			firedelay = 12,
    		},
    		autoreload = true,
    		altfire = false,
    		globalfiredelay = {
    			ready = 12,
    			reload = 54,
    		},
    		realname = "Snarks",
})