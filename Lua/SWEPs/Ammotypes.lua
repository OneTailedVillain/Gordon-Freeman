-- Ammo entries
HLItems.Add("ammo_9mm", {
    max = 250, -- How much of an ammo type the player can hold.
    icon = "AMMOTYPE9MM",
    -- shootmobj omitted because the MT_* that'd go here is the last resort, anyway.
})

HLItems.Add("ammo_357", {
    max = 36,
    icon = "AMMOTYPE357",
})

HLItems.Add("ammo_buckshot", {
    max = 125,
    icon = "AMMOTYPEBUCKSHOT",
})

HLItems.Add("ammo_bolt", {
    max = 50,
    icon = "AMMOTYPEARROW",
    shootmobj = MT_HL1_BOLT
})

HLItems.Add("ammo_rocket", {
    max = 5,
    shootmobj = MT_HL1_ROCKET,
    icon = "AMMOTYPEROCKET",
    safetycatch = true,
    explosionradius = 128
})

HLItems.Add("ammo_grenade", {
    max = 10,
    shootmobj = MT_HL1_HANDGRENADE,
    icon = "AMMOTYPEGRENADE",
    weapongive = "weapon_handgrenade",
    weapontake = "weapon_handgrenade",
    safetycatch = true
})

HLItems.Add("ammo_satchel", {
    max = 5,
    icon = "AMMOTYPESATCHEL",
    weapongive = "weapon_satchel",
    weapontake = "weapon_satchel",
    shootmobj = MT_HL1_SATCHEL,
    safetycatch = true
})

HLItems.Add("ammo_tripmine", {
    max = 5,
    icon = "AMMOTYPETRIPMINE",
    weapongive = "weapon_tripmine",
    weapontake = "weapon_tripmine",
    shootmobj = MT_HL1_TRIPMINE,
    safetycatch = true
})

HLItems.Add("ammo_snark", {
    max = 15,
    icon = "AMMOTYPESNARK",
    weapongive = "weapon_snark",
    weapontake = "weapon_snark",
    shootmobj = MT_HL1_SNARK,
    safetycatch = true
})

HLItems.Add("ammo_uranium", {
    max = 100,
    icon = "AMMOTYPEURANIUM",
})

HLItems.Add("ammo_hornet", {
    max = 8,
    rechargerate = TICRATE/2,
    rechargeamount = 1,
    shootmobj = MT_HL1_HORNET,
    icon = "AMMOTYPEHORNET",
})

HLItems.Add("ammo_argrenade", {
    max = 10,
    icon = "AMMOTYPEARGRENADE",
    shootmobj = MT_HL1_ARGRENADE,
    explosionradius = 128
})

HLItems.Add("ammo_bull", {
    max = 200,
    icon = "AMMOTYPE9MM",
})

HLItems.Add("ammo_shel", {
    max = 50,
    icon = "AMMOTYPEBUCKSHOT",
})

HLItems.Add("ammo_rckt", {
    max = 50,
    icon = "AMMOTYPEROCKET",
    safetycatch = true,
    explosionradius = 128
})

HLItems.Add("ammo_cell", {
    max = 300,
    icon = "AMMOTYPEURANIUM",
})