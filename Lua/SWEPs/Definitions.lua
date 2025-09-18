local function SafeFreeSlot(...)
	for _,slot in ipairs({...}) do
		if not rawget(_G, slot) freeslot(slot) end -- overlapping = wasting, how do we not waste (as many of) them? don't do it in the first place!
	end
end

SafeFreeSlot("SPR_LEGOBATTLESPROJ","S_KOMBI_SHURIKEN",
"S_KOMBI_BULLETHOLE",
"S_KOMBI_SNARK",
"S_KOMBI_SNARKDIE",
"MT_HL1_BULLET",
"MT_HL1_BOLT",
"MT_HL1_ARGRENADE",
"MT_HL1_ROCKET",
"MT_HL1_HANDGRENADE",
"MT_HL1_SATCHEL",
"MT_HL1_TRIPMINE",
"MT_HL1_SNARK",
"MT_HL1_HORNET",
"S_ONETICINVIS",
"sfx_hl1wpn",
"sfx_hlcbar","sfx_hlcbb1","sfx_hlcbb2","sfx_hlcbb3","sfx_hlcbh1","sfx_hlcbh2",
"sfx_hl1g17","sfx_hl1pr1","sfx_hl1pr2",
"sfx_hl3571","sfx_hl3572","sfx_hl357r",
"sfx_hl1ar1","sfx_hl1ar2","sfx_hl1ar3","sfx_hlarr1","sfx_hlarr2","sfx_hlarg1","sfx_hlarg2",
"sfx_hl1sg1","sfx_hl1sgc","sfx_hldsht","sfx_hl1sr1","sfx_hl1sr2","sfx_hl1sr3",
"sfx_hlxbfr","sfx_hlxbre",
"sfx_hlrckt","sfx_hlexp1","sfx_hlexp2","sfx_hlexp3",
"sfx_hlgrn1","sfx_hlgrn2","sfx_hlgrn3",
"sfx_hltmdp","sfx_hltmch","sfx_hltmac",
"SPR_HLHITEFFECT","S_HL1_HIT",
"SPR_HL1EXPLOSION","S_HL1_EXPLODE","S_HL1_GRENADEEXPLODE","S_HL1_EXPLOSION",
"S_HL1_ROCKET","S_HL1_ROCKETACTIVE",
"S_HL1_TRIPMINETHROWN","S_HL1_INACTIVETRIPMINE","S_HL1_ACTIVETRIPMINE","S_HL1_TRIPLASER","SPR_HL1LASER","SPR_TRIP","MT_HL1_TRIPLASER")

sfxinfo[sfx_hlcbar].caption = "Crowbar Swing"
sfxinfo[sfx_hlcbh1].caption = "*CLANG!*"
sfxinfo[sfx_hlcbh2].caption = "*CLANG!*"
sfxinfo[sfx_hlcbb1].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hlcbb2].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hlcbb3].caption = "Crowbar Impact (Body)"
sfxinfo[sfx_hl1sg1].caption = "Shotgun Firing"
sfxinfo[sfx_hldsht].caption = "Double Shotgun Action"
sfxinfo[sfx_hl1sr1].caption = "Shotgun Loading"
sfxinfo[sfx_hl1sr2].caption = "Shotgun Loading"
sfxinfo[sfx_hl1sr3].caption = "Shotgun Loading"
sfxinfo[sfx_hl1g17].caption = "Pistol Firing"
sfxinfo[sfx_hl1pr1].caption = "Pistol Clip Out"
sfxinfo[sfx_hl1pr2].caption = "Pistol Clip In"
sfxinfo[sfx_hl3571].caption = ".357 Firing"
sfxinfo[sfx_hl3572].caption = ".357 Firing"
sfxinfo[sfx_hl357r].caption = ".357 Reloading"
sfxinfo[sfx_hl1ar1].caption = "MP5 Firing"
sfxinfo[sfx_hl1ar2].caption = "MP5 Firing"
sfxinfo[sfx_hl1ar3].caption = "MP5 Firing"
sfxinfo[sfx_hlarr1].caption = "MP5 Clip Out"
sfxinfo[sfx_hlarr2].caption = "MP5 Clip In"
sfxinfo[sfx_hlarg1].caption = "MP5 Grenade Launched"
sfxinfo[sfx_hlarg2].caption = "MP5 Grenade Launched"
sfxinfo[sfx_hlrckt].caption = "Rocket Launched"
sfxinfo[sfx_hlexp1].caption = "Royalty Free Explosion"
sfxinfo[sfx_hlexp2].caption = "Royalty Cheap Explosion"
sfxinfo[sfx_hlexp3].caption = "Royalty Expensive Explosion"

states[S_ONETICINVIS] = {
	sprite = SPR_NULL,
	frame = A,
	tics = 2,
	var1 = 0,
	var2 = 0,
	nextstate = S_NULL
}

states[S_KOMBI_SHURIKEN] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_SHURIKEN
}

states[S_KOMBI_BULLETHOLE] = {
	sprite = SPR_LEGOBATTLESPROJ,
	frame = A|FF_PAPERSPRITE,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_KOMBI_BULLETHOLE
}

mobjinfo[MT_HL1_BULLET] = {
	spawnstate = S_KOMBI_SHURIKEN,
	deathstate = S_INVISIBLE,
	spawnhealth = 100,
	speed = HL.BULLETSPEED,
	radius = 2*FRACUNIT,
	height = 2*FRACUNIT,
	dispoffset = 4,
	flags = MF_MISSILE|MF_NOGRAVITY,
}

mobjinfo[MT_HL1_BOLT] = {
	spawnstate = S_KOMBI_SHURIKEN,
	deathstate = S_INVISIBLE,
	spawnhealth = 100,
	speed = 80*FRACUNIT,
	radius = 6*FRACUNIT,
	height = 12*FRACUNIT,
	dispoffset = 4,
	flags = MF_MISSILE|MF_NOGRAVITY,
}

-- for some DOG ASS REASON, I HAVE TO PUT THESE HERE. fuck this dumbass game vro

local function getVanillaCharWep(player, realname)
	if realname then
		if RingslingerRev then
			-- Ringslinger Revolution
			local mobjToName = {
				[MT_RSR_PROJECTILE_BASIC] = "Match Ring",
				[MT_RSR_PROJECTILE_SCATTER] = "Scatter Ring",
				[MT_RSR_PROJECTILE_AUTO] = "Automatic Ring",
				[MT_RSR_PROJECTILE_BOUNCE] = "Bounce Ring",
				[MT_RSR_PROJECTILE_GRENADE] = "Grenade Ring",
				[MT_RSR_PROJECTILE_BOMB] = "Bomb Ring",
				[MT_RSR_PROJECTILE_HOMING] = "Homing Ring",
				[MT_RSR_PROJECTILE_RAIL] = "Rail Ring",
				[MT_CORK] = "Fang's Cork",
				[MT_LHRT] = "Love Heart"
			}
			return "World Spawn"
		elseif RingSlinger and RingSlinger.Weapons then
			-- Ringslinger NEO
			return "World Spawn"
		else
			-- Base Ringslinger
			local wepmap = {
				[0] = "Match Ring",
				[WEP_AUTO] = "Automatic Ring",
				[WEP_BOUNCE] = "Bounce Ring",
				[WEP_SCATTER] = "Scatter Ring",
				[WEP_GRENADE] = "Grenade Ring",
				[WEP_EXPLODE] = "Explosion Ring",
				[WEP_RAIL] = "Rail Ring",
			}
			return wepmap[player.currentweapon] or "World Spawn"
		end
	else
		if RingslingerRev then
			-- Ringslinger Revolution
			local mobjToName = {
				[MT_RSR_PROJECTILE_BASIC] = "matchring",
				[MT_RSR_PROJECTILE_SCATTER] = "scatterring",
				[MT_RSR_PROJECTILE_AUTO] = "automaticring",
				[MT_RSR_PROJECTILE_BOUNCE] = "bouncering",
				[MT_RSR_PROJECTILE_GRENADE] = "grenadering",
				[MT_RSR_PROJECTILE_BOMB] = "bombring",
				[MT_RSR_PROJECTILE_HOMING] = "homingring",
				[MT_RSR_PROJECTILE_RAIL] = "railring",
				[MT_CORK] = "fangcork",
				[MT_LHRT] = "loveheart"
			}
			return "worldspawn"
		elseif RingSlinger and RingSlinger.Weapons then
			-- Ringslinger NEO
			return "worldspawn"
		else
			-- Base Ringslinger
			local wepmap = {
				[0] = "matchring",
				[WEP_AUTO] = "automaticring",
				[WEP_BOUNCE] = "bouncering",
				[WEP_SCATTER] = "scatterring",
				[WEP_GRENADE] = "grenadering",
				[WEP_EXPLODE] = "explosionring",
				[WEP_RAIL] = "railring",
			}
			return wepmap[player.currentweapon] or "worldspawn"
		end
	end
end

local HP_PER_PIP    = 6  -- was 5; increase to make players "harder to gib"
local MIN_DAMAGE_HP = 1  -- never deal 0 HP in PvP (avoids useless hits)

rawset(_G, "kombiHL1SpecialHandlers", {
    -- praying none of these people push an update that breaks our code
    ["doomguy"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            -- Map each HL.DMG flag to the desired Doom damage type:
            local hlToDoomMap = {
                [HL.DMG.SLASH]      = DAMAGETYPE_MELEE,
                [HL.DMG.CLUB]       = DAMAGETYPE_MELEE,
                [HL.DMG.BULLET]     = DAMAGETYPE_GUNSHOT,
                [HL.DMG.CRUSH]      = DAMAGETYPE_EXPLOSION,
                [HL.DMG.BLAST]      = DAMAGETYPE_EXPLOSION,
                [HL.DMG.ENERGYBEAM] = DAMAGETYPE_BFGTRACER,
                [HL.DMG.PLASMA]     = DAMAGETYPE_PLASMA,
                [HL.DMG.DIRECT]     = DAMAGETYPE_PROJECTILE,
                [HL.DMG.GENERIC]    = DAMAGETYPE_PROJECTILE,
            }

            -- Priority list: highest‐priority flags first
            local priority = {
                HL.DMG.BLAST,
                HL.DMG.CRUSH,
                HL.DMG.ENERGYBEAM,
                HL.DMG.PLASMA,
                HL.DMG.BULLET,
                HL.DMG.SLASH,
                HL.DMG.CLUB,
                HL.DMG.DIRECT,
                HL.DMG.GENERIC,
            }

            local function band(a, b)
                local result, bitval = 0, 1
                for i = 0, 31 do
                    if (a % 2 == 1) and (b % 2 == 1) then
                        result = result + bitval
                    end
                    a, b, bitval = a >> 1, b >> 1, bitval << 1
                end
                return result
            end

            local function HL_ConvertDamageType(mask)
                for _, flag in ipairs(priority) do
                    if band(mask, flag) ~= 0 then
                        return hlToDoomMap[flag]
                    end
                end
                return DAMAGETYPE_PROJECTILE
            end

            P_DamageMobj(thing, tmthing, tmthing.target, dmg, HL_ConvertDamageType(dmgType))
        end,
		getwep = function(player, realname)
			if not player.doom then return "unknown" end
			local weapon = player.doom.weapon
			if realname then
				weapon = DoomGuy
				and DoomGuy.Weapons
				and DoomGuy.Weapons[player.doom.weapon_slot]
				and DoomGuy.Weapons[player.doom.weapon_slot][player.doom.weapon]
				and DoomGuy.Weapons[player.doom.weapon_slot][player.doom.weapon].name
			end
			if not weapon then weapon = player.doom.weapon end
			return weapon
		end,
		getmaxhealth = function(player)
			return player.doom.health_max / FRACUNIT -- Codebase expects int
		end,
		seenametext = function(player)
			local smo = player.mo

			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.doomguy.getwep(player, true)
				table.insert(lines, "Wielding " .. tostring(weapon))
			end

			local healthline = tostring(player.doom.health / FRACUNIT) .. "%"
			if player.doom.armor then
				healthline = $ .. " | " .. tostring(player.doom.armor / FRACUNIT) .. "%"
			end
			table.insert(lines, healthline)

			return lines
		end
    },

    ["bj"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            if not thing.player.wolfenstein then return end
            thing.player.wolfenstein.health = $ - dmg
            P_DamageMobj(thing, tmthing, tmthing.target, 0, 0)
            if thing.player.wolfenstein.health < 0 then
                P_KillMobj(thing, tmthing, tmthing.target, 0)
            end
        end,
		getwep = function(player, realname)
			if not player.wolfenstein then return "???" end
			local wepmap
			if realname then
				wepmap = {
					"Knife",
					"Pistol",
					"Machine Gun",
					"Chaingun",
				}
			else
				wepmap = {
					"knife",
					"pistol",
					"machinegun",
					"chaingun",
				}
			end
			return wepmap[player.wolfenstein.wep] or "???"
		end,
		getmaxhealth = function(player)
			return 100 -- Assumption
		end,
		seenametext = function(player)
			local smo = player.mo

			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.bj.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = tostring(player.wolfenstein.health) .. "%"
			table.insert(lines, healthline)

			return lines
		end
    },

    ["duke"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            if not duke_roboinfo then
                error("Duke was shot, but no roboinfo was found! Please stop breaking the fabric of reality.", 2)
            end
            duke_roboinfo[MT_HL1_BULLET] = {
                unshrinkable = true,
                damage = dmg,
                ringslingerdamage = true
            }
            P_DamageMobj(thing, tmthing, tmthing.target, 1, 0)
        end,
		getwep = function(player, realname)
			if not player.duke then return "???" end
			local wepmap
			if realname then
				wepmap = {
					"Pistol",
					"Shotgun",
					"Chaingun",
					"RPG",
					"Shrinker",
					"Devastator",
					"Freezethrower"
				}
			else
				wepmap = {
					"pistol",
					"shotgun",
					"chaingun",
					"rpg",
					"shrinker",
					"devastator",
					"freezethrower"
				}
			end
			return wepmap[player.duke.curweapon] or "???"
		end,
		getmaxhealth = function(player)
			return 100 -- everything about this man is hardcoded to hell and back, so im not gonna bother
					   -- Im barely putting up with this mod as-is, I should've just dropped support for him
		end,
		seenametext = function(player)
			local smo = player.mo

			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.duke.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = tostring(player.duke.health) .. "%"
			if player.duke.inventory[6] then
				healthline = $ .. " | " .. tostring(player.duke.inventory[6]) .. "%"
			end
			table.insert(lines, healthline)

			return lines
		end
    },

    ["tailsguy"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            local damage = dmg or 1
            thing.player.tgvars.health = thing.player.tgvars.health - dmg + 10
            P_DamageMobj(thing, tmthing, tmthing.target, 100, 0)
            if thing.player.tgvars.health < 0 then
                P_KillMobj(thing, tmthing, tmthing.target, 0)
            end
            thing.player.powers[pw_flashing] = 0
        end,
		getwep = function(player, realname)
			if not player.tgvars then return "???" end
			local wepmap
			if realname then
				wepmap = {
					"Shotgun",
					"Rocket",
					"Chaingun"
				}
			else
				wepmap = {
					"shotgun",
					"rocket",
					"chaingun"
				}
			end
			return wepmap[player.tgvars.weapon + 1] or "???"
		end,
		getmaxhealth = function(player)
			return 100
		end,
		seenametext = function(player)
			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.tailsguy.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = player.tgvars.health .. "%"
			table.insert(lines, healthline)

			return lines
		end
    },

    ["samus"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            TakeSamusEnergy(thing.player, dmg, true, tmthing, tmthing.target)
			if (gametyperules & GTR_TAG) then
				thing.player.pflags = $|PF_TAGIT
			end
		end,
		getwep = function(player, realname)
			if realname then
				return "World Spawn" -- I give up
			else
				return "worldspawn"
			end
		end,
		getmaxhealth = function(player)
			return 99 * (player.sam_energytanksmax + 1)
		end,
		seenametext = function(player)
			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.samus.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = (player.sam_hudenergy + (99 * (player.sam_energytanksmax + 1))) .. "%"
			table.insert(lines, healthline)

			return lines
		end
    },

    ["basesamus"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            TakeSamusEnergy(thing.player, dmg, true, tmthing, tmthing.target)
			if (gametyperules & GTR_TAG) then
				thing.player.pflags = $|PF_TAGIT
			end
        end,
		getwep = function(player, realname)
			if realname then
				return "World Spawn" -- I give up
			else
				return "worldspawn"
			end
		end,
		getmaxhealth = function(player)
			return 99 * (player.sam_energytanksmax + 1)
		end,
		seenametext = function(player)
			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.samus.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = (player.sam_hudenergy + (99 * (player.sam_energytanksmax + 1))) .. "%"
			table.insert(lines, healthline)

			return lines
		end
    },

    ["mcsteve"] = {
        damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
            if not stevehelper then return end
            stevehelper.damage(thing.player, tmthing, dmg / 5)
			if (gametyperules & GTR_TAG) then
				thing.player.pflags = $|PF_TAGIT
			end
        end,
		getwep = function(_, _)
			return "fist"
		end,
		getmaxhealth = function(player)
			return 100
		end,
		seenametext = function(player)
			return {""}
		end
    },

    ["kombifreeman"] = {
		damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
			local attacker = tmthing and tmthing.target or tmthing
			P_DamageMobj(thing, tmthing, attacker, dmg, dmgType) -- custom damage type if provided
		end,
		getwep = function(player, realname)
			if not player.hl then return "worldspawn" end
			if realname then
				return HLItems[player.hl.curwep].realname or "World Spawn"
			else
				return player.hl.curwep or "worldspawn"
			end
		end,
		getmaxhealth = function(player)
			return player.mo.hl.maxhealth or 100
		end,
		seenametext = function(player)
			if not (player and player.mo and player.mo.valid and player.mo.hl) then
				return {"Invalid Freeman"}
			end

			local smo = player.mo

			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.kombifreeman.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = tostring(smo.hl.health) .. "%"
			if smo.hl.armor then
				healthline = $ .. " | " .. tostring(smo.hl.armor / FRACUNIT) .. "%"
			end
			table.insert(lines, healthline)

			return lines
		end
    },

	["metalman"] = {
		damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end

			local scaled_hp = dmg / HP_PER_PIP

			-- guard against zero-damage due to truncation (e.g., tiny weapons)
			if scaled_hp < MIN_DAMAGE_HP then scaled_hp = MIN_DAMAGE_HP end

			-- store as "pips" for UI/debug if you want
			tmthing.megaman = { damage = scaled_hp }

			-- instant-kill/gib logic: compare scaled HP to the target's current HP (curpips * HP_PER_PIP)
			local target_current_hp = thing.player.megaman.curpips * HP_PER_PIP
			local target_max_hp = thing.player.megaman.maxpips * HP_PER_PIP

			-- If the incoming (scaled) hit is >= current HP, kill
			if scaled_hp >= target_current_hp then
				local gibAnyways = (thing.player.megaman.curpips - scaled_hp) < (thing.player.megaman.maxpips / -2)
				P_KillMobj(thing, tmthing, tmthing.target, (HL.DMG.BLAST or gibAnyways) and DMG.GIB or 0)
				thing.player.megaman.curpips = 0
				return true
			end

			-- Otherwise apply scaled HP damage
			P_DamageMobj(thing, tmthing, tmthing.target, scaled_hp, (HL.DMG.BLAST and DMG.GIB) or 0)
			thing.player.powers[pw_flashing] = 0
		end,

		getwep = function(_, realname)
			return realname and "Metal Blade" or "metalblade"
		end,

		getmaxhealth = function(player)
			-- easy place to tune overall durability
			return player.megaman.maxpips * HP_PER_PIP
		end,

		seenametext = function(player)
			local lines = {}
			table.insert(lines, "Wielding Metal Blade")
			local healthline = player.megaman.curpips * HP_PER_PIP .. "%"
			table.insert(lines, healthline)
			return lines
		end
	},

	other = {
		damage = function(tmthing, thing, dmg, dmgType)
			if tmthing.target.hl.dontkillplayers then return false end
			local vplayer = thing.player
			if not vplayer then return end
			if vplayer.powers[pw_shield] then
				P_RemoveShield(vplayer)
			else
				vplayer.rings = $ - FixedMul(dmg, FRACUNIT*2/5)
				S_StartSound(thing, sfx_antiri)
				P_DoPlayerPain(vplayer, tmthing, tmthing and tmthing.target or tmthing)
				if vplayer.rings < 0 then
					P_PlayerWeaponPanelOrAmmoBurst(vplayer)
					P_PlayerEmeraldBurst(vplayer)
					P_PlayerFlagBurst(vplayer)
					HL_HandleKillFeed(thing, tmthing and tmthing.target or tmthing, tmthing, dmgType)
					maybeDoKillMsg(thing, tmthing, tmthing and tmthing.target or tmthing, dmgType)
					P_KillMobj(thing, tmthing, tmthing and tmthing.target or tmthing)
				end
			end
			if (gametyperules & GTR_TAG) then
				vplayer.pflags = $|PF_TAGIT
			end
		end,
		getwep = function(player, realname)
			return getVanillaCharWep(player, realname)
		end,
		getmaxhealth = function(player)
			return player and player.mo and player.mo.hl and player.mo.hl.maxhealth or 100
		end,
		seenametext = function(player)
			local lines = {}

			if gametype != GT_SAXAMM then
				local weapon = kombiHL1SpecialHandlers.other.getwep(player, true)
				table.insert(lines, "Wielding " .. weapon)
			end

			local healthline = tostring(player.rings) .. " Rings (" .. FixedMul(player.rings + 1, FRACUNIT*5/2) .. "%)"
			table.insert(lines, healthline)

			return lines
		end
	}
})

setmetatable(kombiHL1SpecialHandlers, {
  __index = function(t, key)
    return t.other
  end
})

rawset(_G, "HL_GetDistance", function(obj1, obj2) -- get distance between two objects; useful for things like explosion damage calculation
	if not obj1 or not obj2 then return 0 end -- Ensure both objects exist

	local dx = obj1.x - obj2.x
	local dy = obj1.y - obj2.y
	local dz = obj1.z - obj2.z

	return FixedHypot(FixedHypot(dx, dy), dz) -- 3D distance calculationd
end)

local damagetypes = {
	{dmgtype = HL.DMG.BURN|HL.DMG.SLOWBURN,  icon = "DMGICON-BURN"},
	{dmgtype = HL.DMG.SHOCK,  icon = "DMGICON-ELEC"},
	{dmgtype = HL.DMG.ACID|HL.DMG.PLASMA,  icon = "DMGICON-CHEM"},
	{dmgtype = HL.DMG.DROWN,  icon = "DMGICON-DRWN"},
	{dmgtype = HL.DMG.NERVEGAS,  icon = "DMGICON-NERV"},
	{dmgtype = HL.DMG.RADIATION,  icon = "DMGICON-RAD"},
	{dmgtype = HL.DMG.POISON,  icon = "DMGICON-POIS"},
	{dmgtype = HL.DMG.FREEZE,  icon = "DMGICON-FREZ"},
}

local function getDmgIcon(player, dmgType)
	for _, entry in ipairs(damagetypes) do
		if (dmgType & entry.dmgtype) ~= 0 then
			local found = false
			for _, existing in ipairs(player.hl.dmgicons) do
				if existing.icon == entry.icon then
					found = true
					break
				end
			end

			if not found then
				table.insert(player.hl.dmgicons, 1, {icon = entry.icon, time = TICRATE*5})
			end
		end
	end

	-- Refresh all clocks to 5*TICRATE
	for _, entry in ipairs(player.hl.dmgicons) do
		entry.clock = 5 * TICRATE
	end
end

local function HL_HandleKillFeed(victim, source, inflictor, dmgType)
	local killerPlayer = nil
	local attacker = ""

	if source then
		local resolvedSource = ((inflictor.flags & MF_MISSILE) or inflictor.stats) and (inflictor.shooter or inflictor.target) or inflictor

		if type(resolvedSource) == "userdata" and userdataType(resolvedSource) != "player_t" then
			if resolvedSource and (resolvedSource ~= victim or (resolvedSource.player and resolvedSource.player ~= victim)) and resolvedSource.player then
				killerPlayer = resolvedSource.player
				attacker = killerPlayer.name
			end
		else
			killerPlayer = resolvedSource
			attacker = killerPlayer and killerPlayer.name or ""
		end
	end

	local killicon = inflictor and ((inflictor.stats and inflictor.stats.killicon) or (inflictor.wepstats and inflictor.wepstats.killicon)) or "HLKILLGENER"
	if killicon == "HLKILLGENER" and ((dmgType or 0) & HL.DMG.CRUSH) then
		killicon = "HLKILLCRUSH"
	end

	if (killerPlayer == nil and not (type(source) == "userdata" and userdataType(source) == "mobj_t")) or victim.player == killerPlayer then
		killerPlayer = ""
	end

	if victim.player and killerPlayer then
		HL_AddKillFeedEntry(victim.player, killerPlayer, killicon)
	end
end

rawset(_G, "HL_DamageGordon", function(thing, tmthing, dmg, dmgType)
	local player = thing and thing.player
	local dmgType = dmgType or 0
	if (dmg or 15) > 0 then
		local damageDir = -FRACUNIT
		if tmthing and not (dmgType & (HL.DMG.CRUSH|HL.DMG.SONIC)) or HL_GetDistance(thing, tmthing) > 24*FRACUNIT then
			local source = tmthing and tmthing.target or tmthing
			damageDir = abs(AngleFixed(R_PointToAngle2(thing.x, thing.y, tmthing.x, tmthing.y)) - AngleFixed(thing.angle))
		end
		thing.hl1dmgdir = damageDir
		if player and not (dmgType and (dmgType & HL.DMG.FALL)) then
			player.hl1damagetics = 0
			local dmgIcon = getDmgIcon(player, dmgType)
		end
	end

	local hldamage = dmg or (tmthing and tmthing.hl1damage)
	if (not thing.hl.health) then
		HL_InitHealth(thing)
	end

	if hldamage then
		if thing.hl.armor and not ((dmgType or 0) & (HL.DMG.DROWN | HL.DMG.DROWNRECOVER | HL.DMG.FALL))then
			thing.hl.armor = $ - (2 * (hldamage * FRACUNIT) / 5)
			thing.hl.health = $ - hldamage / 5 + min(thing.hl.armor / FRACUNIT, 0)
			thing.hl.health = max($, 0)
			thing.hl.armor = max($, 0)
		else
			thing.hl.health = ($ or 0) - hldamage
		end

		if thing.hl.health <= 0 and not thing.facc then -- Please don't actually kill Facc
			HL_HandleKillFeed(thing, tmthing, tmthing, dmgType)
			P_KillMobj(thing, tmthing, (tmthing and tmthing.target) or tmthing, dmgType)
		end
	end
	
	return thing and thing.hl.health <= 0
end)

rawset(_G, "HL_HurtMobj", function(tmthing, thing, customDamage, customDamageType) -- damage something depending on its health logic
	-- Use the provided damage override if given, otherwise default to tmthing.hl1damage
	local damage = customDamage or tmthing.hl1damage or 15
	local attacker = tmthing and tmthing.target or tmthing
	local victim = thing
	local aplayer
	local vplayer
	local isfriend
	local aplayer
	local vplayer
	local result
	if attacker and victim then
		aplayer = attacker.player
		vplayer = victim.player
		local isfriend = false

		if aplayer and vplayer and type(vplayer) == "userdata" and userdataType(vplayer) == "player_t" then
			isfriend = HL_IsAlly(aplayer, vplayer, true)
		end

		if isfriend and (damage or 0) > 0 then
			return 0
		end
	end
	if (HL.DoTDForestAccomodations and thing.type == MT_TAILSDOLL) then thing.flags = $ | MF_SHOOTABLE end
	if thing.type == MT_METALSONIC_BATTLE then thing.flags = $|MF_SHOOTABLE end
	if not (thing.flags & MF_SHOOTABLE) then return end -- Return early if we're not supposed to get shot.
	if damage and (not tmthing or not tmthing.hitenemy) -- Don't double tap
		if thing.player and kombiHL1SpecialHandlers[thing.skin] and kombiHL1SpecialHandlers[thing.skin].damage -- already has its own health system?
			result = kombiHL1SpecialHandlers[thing.skin].damage(tmthing, thing, damage, customDamageType or 0)
		elseif thing.facc or thing.breaktime or thing.breakdelay
			-- Silverhorn support
			print(thing.hl.health)
			HL_DamageGordon(thing, tmthing, damage, customDamageType)
			print(thing.hl.health)
			if thing.hl.health <= 0 then
				if thing.facc then
					thing.facc.health = min($, thing.facc.phase)
				end
				if thing.breaktime or thing.breakdelay then
					P_StartQuake(32*FU, TICRATE)
					S_StartSound(nil, sfx_bxdmg)
					thing.state = S_UNA_FORCE_BREAK1
					thing.health = 0
				end
				P_DamageMobj(thing, tmthing, attacker)
			else
				if thing.facc then
					-- Scale HL health back to facc-scale health
					local max = thing.hl.maxhealth or 800
					local scaledHealth = thing.hl.health or 0

					-- Normalize to a 0-1 range and multiply by expected facc max
					local phase = thing.facc.phase or 1
					local faccMax = (phase == 1 and 8)
						or (phase == 2 and (50 + min(#players, 6) * 16))
						or 100 -- fallback

					thing.facc.health = FixedCeil((scaledHealth * faccMax * FRACUNIT) / max) / FRACUNIT
				end
				if thing.breaktime or thing.breakdelay then
				
				end
			end
		elseif victim.doom then
			P_DamageMobj(thing, tmthing, attacker, damage)
		else
			HL_DamageGordon(thing, tmthing, damage, customDamageType)
		end
	end

    -- Award 50 points for non-self-inflicted, non-eggman-monitor kills
	local victimmaxhealth = vplayer and (kombiHL1SpecialHandlers[thing.skin] and kombiHL1SpecialHandlers[thing.skin].getmaxhealth(vplayer)) or 100
    if result != false and vplayer and ((gametyperules & GTR_RINGSLINGER) or CV_FindVar("ringslinger").value) then
        P_AddPlayerScore(aplayer, (damage * 50) / victimmaxhealth)
    end

	return damage
end)

function A_StopMomentum(actor)
	if not (actor and actor.valid) then return end
	actor.angle = R_PointToAngle2(0, 0, actor.momx, actor.momy)
	local horizontalSpeed = R_PointToDist2(0, 0, actor.momx, actor.momy)
	actor.pitch = -R_PointToAngle2(0, 0, horizontalSpeed, actor.momz)
	actor.momx = 0
	actor.momy = 0
	actor.momz = 0
	actor.flags = $|MF_NOGRAVITY
end

function A_HLRocketThinker(actor, speed)
	actor.momx = FixedMul(speed, cos(actor.angle)) * cos(actor.pitch)
	actor.momy = FixedMul(speed, sin(actor.angle)) * cos(actor.pitch)
	actor.momz = -FixedMul(speed, sin(actor.pitch))
end

function A_HLExplode(actor, range, baseDamage)
	if not (actor and actor.valid) then return end -- Ensure the actor exists

	-- Process breakable FOFs in affected sectors
	local function ProcessFOFs(sector)
		if sector then
			for rover in sector.ffloors() do
				if (rover.flags & FOF_BUSTUP) and (rover.flags & FOF_EXISTS) then  -- Check if the FOF is real and is breakable
					EV_CrumbleChain(sector, rover)
				end
			end
		end
	end

	local function ProcessSectorLines(refmobj, line)
		-- Check both front and back sectors of the line
		ProcessFOFs(line.frontsector)
		ProcessFOFs(line.backsector)
	end

	-- Search for lines in the affected area
	searchBlockmap("lines", ProcessSectorLines, actor, actor.x - (range/2), actor.x + (range/2), actor.y - (range/2), actor.y + (range/2))

	local function DamageAndBoostNearby(refmobj, foundmobj)
		refmobj.ignoredamagedef = true
		local dist = HL_GetDistance(refmobj, foundmobj)
		if dist > range then return end -- Only affect objects within range

		if not foundmobj or foundmobj == refmobj then return end -- Skip if no object or self
		if not P_CheckSight(refmobj, foundmobj) then return end -- Skip if we don't have a clear view
		if foundmobj.type == MT_SPIKE and not (foundmobj.state == S_SPIKED1 or foundmobj.state == S_SPIKED2) then
			P_KillMobj(foundmobj, refmobj, refmobj)
			return
		end
		if foundmobj.type == MT_METALSONIC_BATTLE then foundmobj.flags = $|MF_SHOOTABLE end
		if not (foundmobj.flags & MF_SHOOTABLE) then return end -- Don't attempt to hurt things that shouldn't be hurt

		-- Damage Boosting: apply shockwave momentum to boost objects
		local impulseFactor = FixedDiv(range - dist, range) -- Closer objects get a stronger boost
		local boostFactor = FRACUNIT * 36 -- Base multiplier for force
		if P_IsObjectOnGround(foundmobj) then
			boostFactor = $ / 2 -- Bad rocket jump "multiplier"
		end

		-- Compute horizontal direction and thrust
		local angle = R_PointToAngle2(refmobj.x, refmobj.y, foundmobj.x, foundmobj.y)
		local thrustPower = FixedMul(boostFactor, impulseFactor)
		P_Thrust(foundmobj, angle, thrustPower)

		-- Get the vertical thrust that we'll use later
		local heightDiff = foundmobj.z - refmobj.z
		local heightFactor = FixedDiv(abs(heightDiff), range + FRACUNIT) -- Normalize height effect
		local verticalBoost = FixedMul(boostFactor, impulseFactor) -- Base scaling
		verticalBoost = FixedMul(verticalBoost, (FRACUNIT - heightFactor)) -- Reduce if higher up

		P_SetObjectMomZ(foundmobj, verticalBoost, true)

		-- Recheck the object just in case it died from some edge case during thrust
		if not foundmobj then return end

		-- Calculate and apply damage
		local damage = max(1, FixedMul(baseDamage, FixedDiv(range - dist, range)))
		HL_HurtMobj(refmobj, foundmobj, damage, HL.DMG.BLAST)
	end

	-- Process nearby objects for damage and boosting
	searchBlockmap("objects", DamageAndBoostNearby, actor, actor.x - range, actor.x + range, actor.y - range, actor.y + range)

	-- Stop momentum and play a random explosion sound
	A_StopMomentum(actor)
	if not (actor and actor.valid) then return end
	actor.scale = FRACUNIT * 3
	S_StartSound(actor, P_RandomRange(sfx_hlexp1, sfx_hlexp3))
end

local function HL_TheRaycastingAtHome(mobj, shooter, maxHits)
	if mobj.dontraycast then return end

	shooter.flags = $ | MF_NOCLIP

	local dist = mobj.dist or MISSILERANGE / mobj.info.speed
	local elapsed = 0
	local hits = 0

	for i = 1, dist do
		if not (mobj and mobj.valid) then
			elapsed = i
			break
		end

		local hit = P_RailThinker(mobj)

		if hit then
			if hits >= (maxHits or 0) then break end
			hits = $ + 1
			-- Force the ray forward using its velocity to avoid stalling
			P_SetOrigin(mobj,
				mobj.x + mobj.momx,
				mobj.y + mobj.momy,
				mobj.z + mobj.momz)
		end

		elapsed = i
	end

	shooter.flags = $ & ~MF_NOCLIP

	return elapsed
end

function A_HLSetupLaserMine(actor, var1, var2)
    S_StartSound(actor, actor.info.attacksound)

    actor.flags = $ | MF_SOLID
    local angle = actor.angle
    local x, y, z = actor.x, actor.y, actor.z + (actor.height / 2)
    local lasertype = MT_HL1_TRIPLASER
    local info = mobjinfo[lasertype]
    local laser = P_SpawnMobjFromMobj(actor, 0, 0, 0, lasertype)

    -- Pre-calculate direction
    local dirx = cos(angle)
    local diry = sin(angle)

    laser.angle = angle + ANGLE_90
    laser.flags = $ | MF_NOCLIPTHING
    laser.momx = FixedMul(dirx, info.speed)
    laser.momy = FixedMul(diry, info.speed)

    -- Run raycast to get total distance
    local dist = HL_TheRaycastingAtHome(laser, actor.target) * info.speed
    print("Total Distance:", dist / FRACUNIT)

    -- Move laser to midpoint between Tripmine and end of laser
    local midpoint = dist / 2
	laser.flags = $ | MF_NOCLIPHEIGHT
    local midx = x - FixedMul(dirx, midpoint)
    local midy = y - FixedMul(diry, midpoint)
    local midz = z  -- Keep same height

    P_SetOrigin(laser, midx, midy, midz)
    laser.radius = midpoint
	laser.spritexscale = FixedDiv(laser.radius, FRACUNIT)
end

addHook("TouchSpecial", function()
	print("Touch!")
end, MT_HL1_TRIPLASER)

states[S_HL1_HIT] = {
	sprite = SPR_HLHITEFFECT,
	frame = A|FF_ANIMATE,
	tics = 9,
	var1 = 9,
	var2 = 1,
	nextstate = S_NULL
}

states[S_HL1_EXPLODE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLExplode,
	tics = 0,
	var1 = 256*FRACUNIT, -- range
	var2 = 192, -- damage
	nextstate = S_HL1_EXPLOSION
}

states[S_HL1_GRENADEEXPLODE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLExplode,
	tics = 0,
	var1 = 192*FRACUNIT, -- range
	var2 = 192, -- damage
	nextstate = S_HL1_EXPLOSION
}

states[S_HL1_EXPLOSION] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A|FF_ADD|FF_ANIMATE,
	tics = 13*3,
	var1 = 13,
	var2 = 3,
	nextstate = S_NULL
}

states[S_HL1_TRIPMINETHROWN] = {
	sprite = SPR_TRIP,
	frame = A|FF_PAPERSPRITE,
	action = A_PlayActiveSound,
	tics = 0,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_INACTIVETRIPMINE
}

states[S_HL1_INACTIVETRIPMINE] = {
	sprite = SPR_TRIP,
	frame = A|FF_PAPERSPRITE,
	action = A_PlaySound, -- SRB2 uses seesound for when the missile gets launched, so don't use it
	tics = 105,           -- ^ costs us an action, but we weren't using it anyways
	var1 = sfx_hltmch,
	var2 = 1,
	nextstate = S_HL1_ACTIVETRIPMINE
}

states[S_HL1_ACTIVETRIPMINE] = {
	sprite = SPR_TRIP,
	frame = A|FF_PAPERSPRITE,
	action = A_HLSetupLaserMine,
	tics = -1,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_EXPLODE
}

states[S_HL1_ROCKET] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_StopMomentum,
	tics = 18,
	var1 = 0,
	var2 = 0,
	nextstate = S_HL1_ROCKETACTIVE
}

states[S_HL1_ROCKETACTIVE] = {
	sprite = SPR_HL1EXPLOSION,
	frame = A,
	action = A_HLRocketThinker,
	tics = -1,
	var1 = 30*FRACUNIT,
	var2 = 0,
	nextstate = S_HL1_EXPLODE
}

states[S_HL1_TRIPLASER] = {
	sprite = SPR_HL1LASER,
	frame = A|FF_ADD|FF_PAPERSPRITE,
	tics = -1,
	nextstate = S_HL1_TRIPLASER
}

mobjinfo[MT_HL1_ROCKET] = {
spawnstate = S_HL1_ROCKET,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
reactiontime = 18,
activesound = sfx_hlrckt,
speed = 30*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE|MF_NOGRAVITY,
}

mobjinfo[MT_HL1_ARGRENADE] = {
spawnstate = S_KOMBI_SHURIKEN,
spawnhealth = 100,
deathstate = S_HL1_EXPLODE,
speed = 20*FRACUNIT,
radius = mobjinfo[MT_CORK].radius,
height = mobjinfo[MT_CORK].height,
dispoffset = 4,
flags = MF_MISSILE,
}

mobjinfo[MT_HL1_HANDGRENADE] = {
	spawnstate = S_KOMBI_SHURIKEN,
	spawnhealth = 100,
	deathstate = S_HL1_GRENADEEXPLODE,
	xdeathstate = S_HL1_GRENADEEXPLODE,
	activesound = sfx_hlgrn1,
	speed = 12*FRACUNIT,
	radius = mobjinfo[MT_CORK].radius,
	height = mobjinfo[MT_CORK].height,
	dispoffset = 4,
	flags = MF_MISSILE|MF_BOUNCE|MF_GRENADEBOUNCE,
}

mobjinfo[MT_HL1_SATCHEL] = {
	spawnstate = S_KOMBI_SHURIKEN,
	spawnhealth = 100,
	xdeathstate = S_HL1_EXPLODE,
	speed = 12*FRACUNIT,
	radius = mobjinfo[MT_CORK].radius,
	height = mobjinfo[MT_CORK].height,
	dispoffset = 4,
	flags = MF_SLIDEME|MF_SCENERY,
}

mobjinfo[MT_HL1_TRIPMINE] = {
	spawnstate = S_HL1_TRIPMINETHROWN,
	spawnhealth = 100,
	deathstate = S_HL1_EXPLODE,
	speed = FRACUNIT,
	radius = FRACUNIT*4,
	height = FRACUNIT*10,
	dispoffset = 4,
	flags = MF_NOGRAVITY|MF_SCENERY,
	activesound = sfx_hltmdp,
	attacksound = sfx_hltmac,
	missilestate = S_HL1_TRIPMINETHROWN
}

mobjinfo[MT_HL1_TRIPLASER] = {
	spawnstate = S_HL1_TRIPLASER,
	spawnhealth = 100,
	speed = FRACUNIT * 16,
	radius = FRACUNIT,
	height = FRACUNIT*3,
	dispoffset = 4,
	flags = MF_SPECIAL|MF_NOGRAVITY|MF_SCENERY|MF_PAPERCOLLISION,
}

rawset(_G, "VMDL_FLIP", 1)

rawset(_G, "VBOB_DOOM", 1)
rawset(_G, "VBOB_NONE", 2)
rawset(_G, "VBOB_WOLF3D", VBOB_NONE)

rawset(_G, "WEAPON_NONE", -1)

rawset(_G, "HL_PickupStats", {})

local baseAmmo = {
	max = 250, -- How much of an ammo type the player can hold.
	icon = "AMMOTYPE9MM",
	safetycatch = false, -- toggles disabling autofire on weapon switch.
	explosionradius = 0,
	rechargerate = -1,-- how long until the next recharge tick.
	rechargeamount = 1, -- how many of this gets added to the RESERVE when recharged.
	shootmobj = MT_HL1_BULLET, -- the mobj this weapon shoots.
	/*
	UNREFERENCED:
	weapongive = What weapon to give if we attain this ammo
	weapontake = What weapon to take if ammo is depleted
	*/
}

local baseWeapon = {
	viewmodel = "PISTOL",
	selectgraphic = "HL1HUD9MM",
	autoswitchweight = INT32_MIN,
	weaponslot = 1,
	priority = INT32_MIN,
	killicon = "HLKILL9MM",
	nounderwater = false,
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
	globalfiredelay = {
		ready = 12,
		reload = 53,
		reloadpost = 18,
	},
	realname = "9mm Handgun",
}

local baseViewmodel = {}

local baseItem = {}

if not HLItems then
	rawset(_G, "HLItems", {})
end

local baseTables = {
  weapon_ = baseWeapon,
  ammo_   = baseAmmo,
  item_   = baseItem,
  v_      = baseViewmodel,
}

function HLItems.Add(name, item)
	if HLItems[name] != nil then
		error(("Item '%s' conflicts with an existing item and will not be registered!"):format(name))
	end

	local ok, prefix = HL_GetPrefix(name)
	if not ok then
		error(("Item '%s' missing a prefix!"):format(name))
	end

	-- find the right base table
	local base = baseTables[prefix]
	if not base then
		error(("Invalid prefix '%s'!"):format(prefix))
	end

	-- set up fallback
	setmetatable(item, { __index = base })

	-- now register it
	local itemtype = prefix:sub(0, #prefix-1)
	if itemtype == "v" then
		itemtype = "viewmodel"
	end
	local itemtypecapital = prefix:sub(0, 1)
	itemtypecapital = itemtypecapital:upper()
	local itemtypelower = itemtype:sub(2, #itemtype)
	HLItems[name] = item
	HL.cacheShit[itemtype .. "s"] = $ or {}
	HL.cacheShit[itemtype .. "s"][name] = true -- add string name to cache so we don't have to do much indexing (and it helps us NOT have to make a check to build a cache everytime we wanna do something)
	print(itemtypecapital .. itemtypelower .. " " .. name .. " successfully registered.")
end

HL.killfeedNames[MT_HL1_ARGRENADE] = "grenade"
HL.killfeedNames[MT_HL1_HANDGRENADE] = "grenade"
HL.killfeedNames[MT_HL1_SATCHEL] = "satchel"
HL.killfeedNames[MT_HL1_SNARK] = "snark"
HL.killfeedNames[MT_HL1_TRIPMINE] = "tripmine"
HL.killfeedNames[MT_HL1_BOLT] = "bolt"
HL.killfeedNames[MT_HL1_ROCKET] = "rpg_rocket"
HL.killfeedNames[MT_HL1_BULLET] = "bullet"