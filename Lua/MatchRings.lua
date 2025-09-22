-- helper: choose a key from a weights table
local function WeightedPick(weights)
	local candidates = {}
	local total = 0

	for key, weight in pairs(weights) do
		if weight > 0 then
			table.insert(candidates, {key = key, weight = weight})
			total = $ + weight
		end
	end

	if total == 0 then return nil end -- nothing to choose from

	-- Try each entry as a probabilistic choice
	for i = 1, #candidates do
		local chance = FixedDiv(candidates[i].weight * FRACUNIT, total * FRACUNIT)
		if P_RandomChance(chance) then
			return candidates[i].key
		end
	end

	-- Fallback: pick a random key (if all chances fail)
	local fallback = P_RandomKey(#candidates)
	return candidates[1].key
end

local function MergeStats(base, override)
	local result = {}
	-- Copy base
	for k, v in pairs(base) do
		result[k] = v
	end
	-- Copy override, possibly overwriting base
	for k, v in pairs(override) do
		result[k] = v
	end
	return result
end

-- pull pickupgift values from HLItems for convenience
HL.PickupGifts = {
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

-- 1) Weapon panels
HL.PanelPickupStats = {
  [MT_AUTOPICKUP] = {
    weights = { mp5=100 },
    defs = {
      mp5 = {
        weapon = "weapon_mp5"
      },
    }
  },

  [MT_SCATTERPICKUP] = {
    weights = { shotgun=100 },
    defs = {
      shotgun = {
        weapon = "weapon_shotgun"
      },
    }
  },

  [MT_BOUNCEPICKUP] = {
    weights = { handgrenade=60, satchel=40 },
    defs = {
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
    }
  },

  [MT_GRENADEPICKUP] = {
    weights = { handgrenade=60, satchel=40 },
    defs = {
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
    }
  },

  [MT_EXPLODEPICKUP] = {
    weights = { satchel=35, crossbow=35, handgrenade=30 },
    defs = {
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      crossbow = {
        weapon = "weapon_crossbow"
      },
    }
  },

  [MT_RAILPICKUP] = {
    weights = { ["357"]=50, crossbow=50 },
    defs = {
      ["357"] = {
        weapon = "weapon_357"
      },
      crossbow = {
        weapon = "weapon_crossbow"
      },
    }
  },
}

-- weapon‐panel touch handler
local function PanelTouch(special, toucher)
	if toucher.skin != "kombifreeman" then return end
	if not (special.valid and toucher.valid) then return end
	local player = toucher.player

	local entry = HL.PanelPickupStats[special.type]
	if not entry then return end

	local choice   = WeightedPick(entry.weights)
	local stats    = entry.defs[choice]

	local didthing = HL_ApplyPickupStats(player, stats)
	if didthing then
		P_KillMobj(special)
	end

	return true
end

-- install panel hooks
/*
addHook("TouchSpecial", PanelTouch, MT_AUTOPICKUP)
addHook("TouchSpecial", PanelTouch, MT_SCATTERPICKUP)
addHook("TouchSpecial", PanelTouch, MT_BOUNCEPICKUP)
addHook("TouchSpecial", PanelTouch, MT_GRENADEPICKUP)
addHook("TouchSpecial", PanelTouch, MT_EXPLODEPICKUP)
addHook("TouchSpecial", PanelTouch, MT_RAILPICKUP)
*/

-- 2) Ammo rings
HL.AmmoPickupStats = {
  [MT_INFINITYRING] = {
    weights={ ["9mmhandgun"]=20, ["357"]=15, mp5=15, shotgun=15, crossbow=15, handgrenade=10, satchel=10 },
    defs = {
      ["9mmhandgun"] = { ammo={ type={"ammo_9mm"}, give={HL.PickupGifts["9mmhandgun"]} } },
      ["357"]        = { ammo={ type={"ammo_357"}, give={HL.PickupGifts["357"]} } },
      mp5            = { ammo={ type={"ammo_9mm","ammo_argrenade"}, give={HL.PickupGifts["mp5"].primary,HL.PickupGifts["mp5"].secondary} } },
      shotgun        = { ammo={ type={"ammo_shotgun"}, give={HL.PickupGifts["shotgun"]} } },
      crossbow       = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
      handgrenade    = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel        = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
    }
  },
  [MT_AUTOMATICRING] = {
    weights={ mp5=100 },
    defs = {
      mp5 = { ammo={ type={"ammo_9mm"}, give={HL.PickupGifts["mp5"].primary} } },
    }
  },
  [MT_SCATTERRING] = {
    weights={ shotgun=100 },
    defs = {
      shotgun = { ammo={ type={"ammo_buckshot"}, give={HL.PickupGifts["shotgun"]} } },
    }
  },
  [MT_BOUNCERING] = {
    weights={ handgrenade=60, satchel=40 },
    defs = {
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
    }
  },
  [MT_GRENADERING] = {
    weights={ handgrenade=30, satchel=40, mp5 = 30 },
    defs = {
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
      mp5         = { ammo={ type={"ammo_argrenade"}, give={HL.PickupGifts["mp5"].secondary} } },
    }
  },
  [MT_EXPLOSIONRING] = {
    weights={ satchel=35, crossbow=35, handgrenade=15, mp5 = 15 },
    defs = {
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
      crossbow    = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      mp5         = { ammo={ type={"ammo_argrenade"}, give={HL.PickupGifts["mp5"].secondary} } },
    }
  },
  [MT_RAILRING] = {
    weights={ ["357"]=50, crossbow=50},
    defs = {
      ["357"] = { ammo={ type={"ammo_357"}, give={HL.PickupGifts["357"]} } },
      crossbow = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
    }
  },
}

HL.matchRingDefs = {
  [MT_INFINITYRING] = {
    weights={ ["9mmhandgun"]=20, ["357"]=15, mp5=15, shotgun=15, crossbow=15, handgrenade=10, satchel=10 },
    defs = {
      ["9mmhandgun"] = { ammo={ type={"ammo_9mm"}, give={HL.PickupGifts["9mmhandgun"]} } },
      ["357"]        = { ammo={ type={"ammo_357"}, give={HL.PickupGifts["357"]} } },
      mp5            = { ammo={ type={"ammo_9mm","ammo_argrenade"}, give={HL.PickupGifts["mp5"].primary,HL.PickupGifts["mp5"].secondary} } },
      shotgun        = { ammo={ type={"ammo_shotgun"}, give={HL.PickupGifts["shotgun"]} } },
      crossbow       = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
      handgrenade    = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel        = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
    }
  },
  [MT_AUTOMATICRING] = {
    weights={ mp5=100 },
    defs = {
      mp5 = { ammo={ type={"ammo_9mm"}, give={HL.PickupGifts["mp5"].primary} } },
    }
  },
  [MT_SCATTERRING] = {
    weights={ shotgun=100 },
    defs = {
      shotgun = { ammo={ type={"ammo_buckshot"}, give={HL.PickupGifts["shotgun"]} } },
    }
  },
  [MT_BOUNCERING] = {
    weights={ handgrenade=60, satchel=40 },
    defs = {
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
    }
  },
  [MT_GRENADERING] = {
    weights={ handgrenade=30, satchel=40, mp5 = 30 },
    defs = {
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
      mp5         = { ammo={ type={"ammo_argrenade"}, give={HL.PickupGifts["mp5"].secondary} } },
    }
  },
  [MT_EXPLOSIONRING] = {
    weights={ satchel=35, crossbow=35, handgrenade=15, mp5 = 15 },
    defs = {
      satchel     = { ammo={ type={"ammo_satchel"}, give={HL.PickupGifts["satchel"]} } },
      crossbow    = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
      handgrenade = { ammo={ type={"ammo_grenade"}, give={HL.PickupGifts["handgrenade"]} } },
      mp5         = { ammo={ type={"ammo_argrenade"}, give={HL.PickupGifts["mp5"].secondary} } },
    }
  },
  [MT_RAILRING] = {
    weights={ ["357"]=50, crossbow=50},
    defs = {
      ["357"] = { ammo={ type={"ammo_357"}, give={HL.PickupGifts["357"]} } },
      crossbow = { ammo={ type={"ammo_bolt"}, give={HL.PickupGifts["crossbow"]} } },
    }
  },
  
  [MT_AUTOPICKUP] = {
    weights = { mp5=100 },
    defs = {
      mp5 = {
        weapon = "weapon_mp5"
      },
    }
  },

  [MT_SCATTERPICKUP] = {
    weights = { shotgun=100 },
    defs = {
      shotgun = {
        weapon = "weapon_shotgun"
      },
    }
  },

  [MT_BOUNCEPICKUP] = {
    weights = { handgrenade=60, satchel=40 },
    defs = {
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
    }
  },

  [MT_GRENADEPICKUP] = {
    weights = { handgrenade=60, satchel=40 },
    defs = {
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
    }
  },

  [MT_EXPLODEPICKUP] = {
    weights = { satchel=35, crossbow=35, handgrenade=30 },
    defs = {
      satchel = {
        ammo = {
          type={"ammo_satchel"},
          give={HL.PickupGifts["satchel"]},
        }
      },
      handgrenade = {
        ammo = {
          type={"ammo_grenade"},
          give={HL.PickupGifts["handgrenade"]},
        }
      },
      crossbow = {
        weapon = "weapon_crossbow"
      },
    }
  },

  [MT_RAILPICKUP] = {
    weights = { ["357"]=50, crossbow=50 },
    defs = {
      ["357"] = {
        weapon = "weapon_357"
      },
      crossbow = {
        weapon = "weapon_crossbow"
      },
    }
  },
}

-- ammo‐ring touch handler
local function RingTouch(special, toucher)
	if toucher.skin != "kombifreeman" then return end
	if not special.valid or not toucher.valid then return end
	local player = toucher.player

	local entry = HL.AmmoPickupStats[special.type]
	if not entry then return end

	local choice = WeightedPick(entry.weights)
	local stats  = entry.defs[choice]

	if special.stats then
		print("double ammo!")
		stats = MergeStats(stats, {doubleammo = true})
	end

	if HL_ApplyPickupStats(player, stats) then
		P_KillMobj(special)
	end
	return true
end

-- install ammo hooks
/*
addHook("TouchSpecial", RingTouch, MT_INFINITYRING)
addHook("TouchSpecial", RingTouch, MT_AUTOMATICRING)
addHook("TouchSpecial", RingTouch, MT_SCATTERRING)
addHook("TouchSpecial", RingTouch, MT_BOUNCERING)
addHook("TouchSpecial", RingTouch, MT_GRENADERING)
addHook("TouchSpecial", RingTouch, MT_EXPLOSIONRING)
addHook("TouchSpecial", RingTouch, MT_RAILRING)
*/

addHook("MobjSpawn", function(mobj)
	if not (mobj and mobj.valid) then return end

	local entry = HL.matchRingDefs[mobj.type]
	if not entry then return end

	local choice = WeightedPick(entry.weights)
	if not choice then return end

	local stats = entry.defs[choice]

	if mobj.pickupstats then
		stats = MergeStats(stats, mobj.pickupstats)
	end

	mobj.pickupstats = stats
	--mobj.hl.nobasebehavior = true

	if TOL_DOOM and (maptol & TOL_DOOM) or not TOL_DOOM then return end
	if not HL.botsOnMobius then return end

	HL.positionMap = $ or {}

	-- Construct a position key
	local posKey = string.format("%d,%d,%d", mobj.x, mobj.y, mobj.z)

	-- Initialize or append to the list
	if not HL.positionMap[posKey] then
		HL.positionMap[posKey] = {mobj}
	else
		table.insert(HL.positionMap[posKey], mobj)
	end

	-- Now handle any overlapping ammo items
	local howmany = HL.positionMap[posKey]
	if #howmany >= 6 then
		mobj.pickupstats.doubleammo = true
	end
end)