-- helper to generate a sequence of {x,y} offsets
local function genOffsets(x, y0, dy, count)
  local t = {}
  for i=1, count do
    t[i] = { x, y0 + (i-1)*dy }
  end
  return t
end

-- helper to generate a reverse sequence
local function genOffsetsReverse(x, y0, dy, count)
  local t = {}
  for i=1, count do
    t[i] = { x, y0 - (i-1)*(-dy) }
  end
  return t
end

-- Generic DOOM lower animation generator
local function makeLower(sentinel, x, y0, dy, count)
  return {
    sentinel       = sentinel,
    frameDurations = { [1]=1, [count+1]=1 },
    frameOffsets   = genOffsets(x, y0, dy, count),
  }
end

-- Generic DOOM ready animation generator
local function makeReady(sentinel, x, yMax, dy, count)
  return {
    sentinel       = sentinel,
    frameDurations = { [1]=1, [count+1]=1 },
    frameOffsets   = genOffsetsReverse(x, yMax, dy, count),
  }
end

-- Viewmodels
HLItems.Add("v_crowbar", {
    flags = 0,
    		hashitframes = true,
    		animations = {
    			ready = {
    				sentinel = "HLCBARREADY1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    			},
    			primaryfire = {
    				normal = {
    					{
    						sentinel = "HLCBARFIRE1-1",
    						frameDurations = {
    							[1] = 2,
    							[9] = 2,
    						},
    					},
    					{
    						sentinel = "HLCBARFIRE2-1",
    						frameDurations = {
    							[1] = 2,
    							[12] = 2,
    						},
    					},
    					{
    						sentinel = "HLCBARFIRE3-1",
    						frameDurations = {
    							[1] = 2,
    							[15] = 2,
    						},
    					},
    				},
    				hit = {
    					{
    						sentinel = "HLCBARHIT1-1",
    						frameDurations = {
    							[1] = 2,
    							[9] = 2,
    						},
    					},
    					{
    						sentinel = "HLCBARHIT2-1",
    						frameDurations = {
    							[1] = 2,
    							[12] = 2,
    						},
    					},
    					{
    						sentinel = "HLCBARHIT3-1",
    						frameDurations = {
    							[1] = 2,
    							[15] = 2,
    						},
    					},
    				},
    			},
    			idle = {
    				{
    					sentinel = "HLCBARIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[49] = 2,
    					},
    				},
    				{
    					sentinel = "HLCBARIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[97] = 2,
    					},
    				},
    				{
    					sentinel = "HLCBARIDLE3-1",
    					frameDurations = {
    						[1] = 2,
    						[97] = 2,
    					},
    				},
    			},
    		},
})

HLItems.Add("v_pistol", {
    flags = 0,
    		animations = {
    			ready = {
    				sentinel = "PISTOLREADY1",
    				frameDurations = {
    					[1] = 2,
    					[19] = 2,
    				},
    			},
    			primaryfire = {
    				normal = {
    					sentinel = "PISTOLFIRE1",
    					frameDurations = {
    						[1] = 2,
    						[12] = 2,
    					},
    				},
    				empty = {
    					sentinel = "PISTOLFIREEMPT1",
    					frameDurations = {
    						[1] = 2,
    						[12] = 2,
    					},
    				}
    			},
    			secondaryfire = {
    				normal = {
    					sentinel = "PISTOLFIRE1",
    					frameDurations = {
    						[1] = 2,
    						[12] = 2,
    					},
    				},
    				empty = {
    					sentinel = "PISTOLFIREEMPT1",
    					frameDurations = {
    						[1] = 2,
    						[12] = 2,
    					},
    				}
    			},
    			reload = {
    					sentinel = "PISTOLRELOAD1",
    					frameDurations = {
    						[1] = 2,
    						[42] = 2,
    					},
    					frameSounds = {
    						[4] = sfx_hl1pr1,
    						[23] = sfx_hl1pr2
    					},
    			},
    			idle = {
    				{
    					sentinel = "PISTOLIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[69] = 2,
    					},
    				},
    				{
    					sentinel = "PISTOLIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[47] = 2,
    					},
    				},
    				{
    					sentinel = "PISTOLIDLE3-1",
    					frameDurations = {
    						[1] = 2,
    						[65] = 2,
    					},
    				},
    			},
    		},
})

HLItems.Add("v_357-", {
    flags = 0,
    		animations = {
    			ready = {
    				sentinel = "357READY1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    			},
    			primaryfire = {
    				sentinel = "357FIRE1",
    				frameDurations = {
    					[1] = 2,
    					[19] = 2,
    				},
    			},
    			reload = {
    				sentinel = "357RELOAD1",
    				frameDurations = {
    					[1] = 2,
    					[56] = 2,
    				},
    				frameSounds = {
    					[35] = sfx_hl357r,
    				}
    			},
    			idle = {
    				{
    					sentinel = "357IDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[43] = 2,
    					},
    				},
    				{
    					sentinel = "357IDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[37] = 2,
    					},
    				},
    				{
    					sentinel = "357IDLE3-1",
    					frameDurations = {
    						[1] = 2,
    						[54] = 2,
    					},
    				},
    				{
    					sentinel = "357IDLE4-1",
    					frameDurations = {
    						[1] = 2,
    						[103] = 2,
    					},
    				},
    			},
    		},
})

HLItems.Add("v_shotgun", {
    flags = 0,
    		animations = {
    			ready = {
    				sentinel = "SHOTGUNREADY1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    			},
    			primaryfire = {
    				sentinel = "SHOTGUNFIRE1",
    				frameDurations = {
    					[1] = 2,
    					[19] = 2,
    				},
    				frameSounds = {
    					[9] = sfx_hl1sgc
    				}
    			},
    			secondaryfire = {
    				sentinel = "SHOTGUNAFIRE1",
    				frameDurations = {
    					[1] = 2,
    					[28] = 2,
    				},
    				frameSounds = {
    					[15] = sfx_hl1sgc,
    				}
    			},
    			reload = {
    				start = {
    					sentinel = "SHOTGUNRELOADS1",
    					frameDurations = {
    						[1] = 2,
    						[13] = 2,
    					},
    				},
    				loop = {
    					sentinel = "SHOTGUNRELOADL1",
    					frameDurations = {
    						[1] = 2,
    						[11] = 2,
    					},
    					frameSounds = {
    						[4] = {sound = sfx_hl1sr1, sounds = 3},
    					}
    				},
    				stop = {
    					sentinel = "SHOTGUNRELOADE1",
    					frameDurations = {
    						[1] = 2,
    						[15] = 2,
    					},
    					frameSounds = {
    						[6] = sfx_hl1sgc,
    					}
    				},
    			},
    			idle = {
    				{
    					sentinel = "SHOTGUNIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[41] = 2,
    					},
    				},
    				{
    					sentinel = "SHOTGUNIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[41] = 2,
    					},
    				},
    				{
    					sentinel = "SHOTGUNIDLE3-1",
    					frameDurations = {
    						[1] = 2,
    						[91] = 2,
    					},
    				},
    			},
    		}
})

HLItems.Add("v_mp5-", {
    flags = 0,
    		animations = {
    			ready = {
    				sentinel = "MP5READY1",
    				frameDurations = {
    					[1] = 2,
    					[19] = 2,
    				},
    			},
    			primaryfire = {
    				{
    					sentinel = "MP5FIRE1-1",
    					frameDurations = {
    						[1] = 2,
    						[13] = 2,
    					},
    				},
    				{
    					sentinel = "MP5FIRE2-1",
    					frameDurations = {
    						[1] = 2,
    						[13] = 2,
    					},
    				},
    				{
    					sentinel = "MP5FIRE3-1",
    					frameDurations = {
    						[1] = 2,
    						[13] = 2,
    					},
    				},
    			},
    			secondaryfire = {
    				sentinel = "MPARGRENADE1",
    				frameDurations = {
    					[1] = 2,
    					[21] = 2,
    				}
    			},
    			reload = {
    				sentinel = "MP5RELOAD1",
    				frameDurations = {
    					[1] = 2,
    					[29] = 2,
    				},
    				frameSounds = {
    					[3] = sfx_hlarr1,
    					[14] = sfx_hlarr2,
    				}
    			},
    			idle = {
    				{
    					sentinel = "MP5IDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[58] = 2,
    					},
    				},
    				{
    					sentinel = "MP5IDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[91] = 2,
    					},
    				},
    			},
    		}
})

HLItems.Add("v_grenade", {
    flags = VMDL_FLIP,
    		animations = {
    			ready = {
    				sentinel = "GRENADEREADY1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    			},
    			primaryfire = {
    				sentinel = "GRENADETHROW1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    				next = "ready"
    			},
    			startcook = {
    				sentinel = "GRENADEFIRE1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    				next = "cookloop"
    			},
    			cookloop = {
    				sentinel = "GRENADEREADY1",
    				frameDurations = {
    					[1] = 10,
    				},
    				loop = true
    			},
    			reload = {
    				sentinel = "MP5RELOAD1",
    				frameDurations = {
    					[1] = 5,
    					[2] = 4,
    					[13] = 4,
    				},
    				frameSounds = {
    					[1] = sfx_hlarr1,
    					[7] = sfx_hlarr2,
    				}
    			},
    			idle = {
    				{
    					sentinel = "GRENADEIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[55] = 2,
    					},
    				},
    				{
    					sentinel = "GRENADEIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[46] = 2,
    					},
    				},
    			},
    		}
})

HLItems.Add("v_crossbow", {
    flags = VMDL_FLIP,
    		animations = {
    			ready = {
    				sentinel = "CROSSBOWREADY1",
    				frameDurations = {
    					[1] = 2,
    					[10] = 2,
    				},
    			},
    			primaryfire = {
    				normal = {
    					sentinel = "CROSSBOWFIRE1",
    					frameDurations = {
    						[1] = 2,
    						[34] = 2,
    					},
    					frameSounds = {
    						[0] = sfx_hlxbre
    					}
    				},
    				empty = {
    					sentinel = "CROSSBOWFIREEMPT1",
    					frameDurations = {
    						[1] = 2,
    						[10] = 2,
    					}
    				},
    			},
    			reload = {
    				sentinel = "CROSSBOWRELOAD1",
    				frameDurations = {
    					[1] = 2,
    					[82] = 2,
    				},
    				frameSounds = {
    					[4] = sfx_hlxbre,
    				}
    			},
    			idle = {
    				{
    					sentinel = "CROSSBOWIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[55] = 2,
    					},
    				},
    				{
    					sentinel = "CROSSBOWIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[49] = 2,
    					},
    				}
    			},
    			emptyidle = {
    				{
    					sentinel = "CROSSBOWEMPTIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[19] = 2,
    					},
    				},
    				{
    					sentinel = "CROSSBOWEMPTIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[55] = 2,
    					},
    				}
    			},
    		},
})

HLItems.Add("v_knife", {
    flags = VMDL_FLIP,
    		hashitframes = true,
    		animations = {
    			ready = {
    				sentinel = "KNIFEREADY1",
    						frameDurations = {
    							[1] = 3,
    							[6] = 3,
    						},
    			},
    			primaryfire = {
    				normal = {
    					{
    						sentinel = "KNIFEMISS1-1",
    						frameDurations = {
    							[1] = 3,
    							[6] = 3,
    						},
    					},
    					{
    						sentinel = "KNIFEMISS2-1",
    						frameDurations = {
    							[1] = 4,
    							[7] = 4,
    						},
    					},
    					{
    						sentinel = "KNIFEMISS3-1",
    						frameDurations = {
    							[1] = 4,
    							[5] = 4,
    						},
    					},
    				},
    				hit = {
    					{
    						sentinel = "KNIFEHIT1-1",
    						frameDurations = {
    							[1] = 2,
    							[6] = 2,
    						},
    					},
    					{
    						sentinel = "KNIFEHIT2-1",
    						frameDurations = {
    							[1] = 2,
    							[7] = 2,
    						},
    					},
    					{
    						sentinel = "KNIFEHIT3-1",
    						frameDurations = {
    							[1] = 2,
    							[11] = 2,
    						},
    					},
    				},
    			},
    			idle = {
    				{
    					sentinel = "KNIFEIDLE1-1",
    					frameDurations = {
    						[1] = 10,
    						[12] = 10,
    					},
    				},
    				{
    					sentinel = "KNIFEIDLE2-1",
    					frameDurations = {
    						[1] = 8,
    						[20] = 8,
    					},
    				},
    				{
    					sentinel = "KNIFEIDLE3-1",
    					frameDurations = {
    						[1] = 8,
    						[20] = 8,
    					},
    				},
    			},
    			backstab = {
    				start = {
    					sentinel = "KNIFEBACKSTAB1",
    					frameDurations = {
    						[1] = 2,
    						[10] = 2
    					},
    					next = "backstab loop"
    				},
    				loop = {
    					sentinel = "KNIFEREADY1",
    					frameDurations = {
    						[1] = INT32_MAX
    					},
    					loop = true
    				},
    				hit = {
    					sentinel = "KNIFEBACKSTABHIT1",
    					frameDurations = {
    						[1] = 2,
    						[10] = 2
    					}
    				}
    			}
    		},
})

HLItems.Add("v_medkittfc", {
    flags = VMDL_FLIP,
    		hashitframes = true,
    		animations = {
    			ready = {
    				sentinel = "TFCMEDKITREADY1",
    						frameDurations = {
    							[1] = 2,
    							[10] = 2,
    						},
    			},
    			primaryfire = {
    				normal = {
    					sentinel = "TFCMEDKITFAIL1",
    					frameDurations = {
    						[1] = 2,
    						[44] = 2,
    					},
    				},
    				hit = {
    					sentinel = "TFCMEDKITUSE1",
    					frameDurations = {
    						[1] = 2,
    						[22] = 2,
    					},
    				},
    			},
    			idle = {
    				{
    					sentinel = "TFCMEDKITIDLE1-1",
    					frameDurations = {
    						[1] = 2,
    						[22] = 2,
    					},
    				},
    				{
    					sentinel = "TFCMEDKITIDLE2-1",
    					frameDurations = {
    						[1] = 2,
    						[44] = 2,
    					},
    				},
    			},
    		},
})

HLItems.Add("v_doom_chainsaw", {
	idleanims = 1,
	bobtype   = VBOB_DOOM,
	vflags    = V_SNAPTOBOTTOM,
	animations = {
		lower       = makeLower("WP1AIDLE1", 0,   6,  6, 22),
		ready       = makeReady("WP1AIDLE1", 0, 132, -6, 22),
		primaryfire = { sentinel="WP1AFIRE1", frameDurations={6,4,5} },
		reload      = { sentinel="WP1AIDLE1",  frameDurations={6} },
		idle        = { sentinel="WP1AIDLE1",  frameDurations={ 4, 4 }, frameSounds = {sfx_sawidl, sfx_sawidl} },
	},
})

HLItems["v_doom_chainsaw"].animations.ready.frameSounds = {[0] = sfx_sawup}

HLItems.Add("v_doom_pistol", {
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        lower       = makeLower("WP2IDLE1", 0,   6,  6, 22),
        ready       = makeReady("WP2IDLE1", 0, 132, -6, 22),
        primaryfire = { sentinel="WP2FIRE1", frameDurations={6,4,5} },
        reload      = { sentinel="WP2IDLE1",  frameDurations={6} },
        idle        = { sentinel="WP2IDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_doom_shotgun", {
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        lower       = makeLower("WP3IDLE1", 0,   6,  6, 22),
        ready       = makeReady("WP3IDLE1", 0, 132, -6, 22),
        primaryfire = {
            sentinel       = "WP3FIRE1",
            frameDurations = {4,3,5,4,5,nil,3,7},
        },
        reload      = { sentinel="WP3IDLE1", frameDurations={6} },
        idle        = { sentinel="WP3IDLE1", frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_doom_supershotgun", {  -- Super-Shotgun
	  idleanims = 1,
	  bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
	  animations = {
		lower = makeLower("WP3AIDLE1", 0,   6,  6, 22),
		ready = makeReady("WP3AIDLE1", 0, 132, -6, 22),
		primaryfire = {
		  sentinel       = "WP3AFIRE1",
		  frameDurations = {
			[1] = 3,
			[3] = 4,
			[4] = 7,
			[9] = 5,
			[10] = 6,
		  },
		  frameSounds = {
			[5] = sfx_ssgo,
			[7] = sfx_ssgl,
			[9] = sfx_ssgc,
		  },
		},
		reload = {
		  sentinel       = "WP3AIDLE1",
		  frameDurations = {
			[1] = 6,
		  },
		},
		idle = {
		  sentinel       = "WP3AIDLE1",
		  frameDurations = {
			[1] = INT32_MAX,
		  },
		},
	  },
	})

HLItems.Add("v_doom_chaingun", {  -- Chaingun
	  idleanims = 1,
	  bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
	  animations = {
		lower = makeLower("WP4IDLE1", 0,   6,  6, 22),
		ready = makeReady("WP4IDLE1", 0, 132, -6, 22),
		primaryfire = {
		  sentinel       = "WP4FIRE1",
		  frameDurations = {
			[1] = 2,
			[2] = 2,
		  },
		},
		reload = {
		  sentinel       = "WP4IDLE1",
		  frameDurations = {
			[1] = 6,
		  },
		},
		idle = {
		  sentinel       = "WP4IDLE1",
		  frameDurations = {
			[1] = INT32_MAX,
		  },
		},
	  },
	})

HLItems.Add("v_doom_rpg", {
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        lower       = makeLower("WP5IDLE1", 0,   6,  6, 22),
        ready       = makeReady("WP5IDLE1", 0, 132, -6, 22),
        primaryfire = {
            sentinel       = "WP5FIRE1",
            frameDurations = {4,4,4,4,4},
			overlays = { {sentinel = "WP5FIRE6", layer = {1, 1, 1, 1, 1} } }
        },
        reload      = { sentinel="WP5IDLE1", frameDurations={6} },
        idle        = { sentinel="WP5IDLE1", frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_doom_plasmarifle", {  -- Plasma Rifle
	  idleanims = 1,
	  bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
	  animations = {
		lower = makeLower("WP6IDLE1", 0,   6,  6, 22),
		ready = makeReady("WP6IDLE1", 0, 132, -6, 22),
		primaryfire = {
		  {
		    sentinel       = "WP6FIRE1",
		    randomFrames   = true,
		    frameDurations = {
			  [1] = 3,
		    },
		  },
		  {
		    sentinel       = "WP6FIRE2",
		    randomFrames   = true,
		    frameDurations = {
			  [2] = 3,
		    },
		  },
		},
		reload = {
		  sentinel       = "WP6IDLE1",
		  frameDurations = {
			[1] = 6,
		  },
		},
		idle = {
		  sentinel       = "WP6IDLE1",
		  frameDurations = {
			[1] = INT32_MAX,
		  },
		},
	  },
	})

HLItems.Add("v_doom_bfg9000", {
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        lower       = makeLower("WP3IDLE1", 0,   6,  6, 22),
        ready       = makeReady("WP3IDLE1", 0, 132, -6, 22),
        primaryfire = {
            sentinel       = "WP3FIRE1",
            frameDurations = {4,3,5,4,5,nil,3,7},
        },
        reload      = { sentinel="WP3IDLE1", frameDurations={6} },
        idle        = { sentinel="WP3IDLE1", frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_duke_pistol", { -- Duke3D Pistol
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        ready       = { sentinel="DUKEPISTIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="DUKEPISTFIRE1", frameDurations={1,1} },
        reload      = { sentinel="DUKEPISTRELOAD1", frameDurations={5, 10, 1, 1, 1, 3, 4, 3}, overlays = { {sentinel = "DUKEPISTRELHAND1", layer = {0, 0, 1, 1, 1, -1, -1, 0} } } },
        idle        = { sentinel="DUKEPISTIDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_duke_shotgun", { -- Duke3D Shotgun
      idleanims = 1,
      bobtype   = VBOB_DOOM,
	  vflags    = V_SNAPTOBOTTOM,
      animations = {
        ready       = { sentinel="DUKESHOTIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="DUKESHOTFIRE1", frameDurations={3,1,1,3,4,3,6,3,5,5}, frameSounds = {nil, nil, nil, nil, nil, sfx_shtcck}, overlays = { {sentinel = "DUKESHOTFMUZ1"} } },
        reload      = { sentinel="DUKESHOTIDLE1",  frameDurations={6} },
        idle        = { sentinel="DUKESHOTIDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_wolf_knife", { -- Wolf3D Knife
      idleanims = 1,
      bobtype   = VBOB_WOLF3D,
	  vflags    = V_SNAPTOBOTTOM,
	  size      = 2*FRACUNIT,
      animations = {
        ready       = { sentinel="WOLFKNIFIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="WOLFKNIFFIRE1", frameDurations={3,3,3,3} },
        reload      = { sentinel="WOLFKNIFIDLE1",  frameDurations={6} },
        idle        = { sentinel="WOLFKNIFIDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_wolf_pistol", { -- Wolf3D Pistol
      idleanims = 1,
      bobtype   = VBOB_WOLF3D,
	  vflags    = V_SNAPTOBOTTOM,
	  size      = 2*FRACUNIT,
      animations = {
        ready       = { sentinel="WOLFPISTIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="WOLFPISTFIRE1", frameDurations={3,3,3,3} },
        reload      = { sentinel="WOLFPISTIDLE1",  frameDurations={6} },
        idle        = { sentinel="WOLFPISTIDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_wolf_machinegun", { -- Wolf3D Machine Gun
      idleanims = 1,
      bobtype   = VBOB_WOLF3D,
	  vflags    = V_SNAPTOBOTTOM,
	  size      = 2*FRACUNIT,
      animations = {
        ready       = { sentinel="WOLFMACHIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="WOLFMACHFIRE1", frameDurations={2,2,2,2} },
        reload      = { sentinel="WOLFMACHIDLE1",  frameDurations={6} },
        idle        = { sentinel="WOLFMACHIDLE1",  frameDurations={ INT32_MAX } },
      },
    })

HLItems.Add("v_wolf_chaingun", { -- Wolf3D Chaingun
      idleanims = 1,
      bobtype   = VBOB_WOLF3D,
	  vflags    = V_SNAPTOBOTTOM,
	  size      = 2*FRACUNIT,
      animations = {
        ready       = { sentinel="WOLFCHAIIDLE1",  frameDurations={ 1 } },
        primaryfire = { sentinel="WOLFCHAIFIRE1", frameDurations={2,2,2,2} },
        reload      = { sentinel="WOLFCHAIIDLE1",  frameDurations={6} },
        idle        = { sentinel="WOLFCHAIIDLE1",  frameDurations={ INT32_MAX } },
      },
    })