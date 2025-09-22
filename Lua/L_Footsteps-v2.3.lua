local function warn(player, str)
	CONS_Printf(player, "\130WARNING: \128"..str);
end

local DEBUG_FOOTSTEP = 1
local DEBUG_FALLDMG  = 2

rawset(_G, "cv_hldebug", CV_RegisterVar({
	name = "hl_debug",
	defaultvalue = "Off",
	flags = CV_SAVE|CV_SHOWMODIF|CV_NETVAR,
	PossibleValue = {Off = 0, Footsteps = 1},
}))

local materialDefs = {
    { name = "concrete",     prefix = "hlco", count = 4 },
    { name = "dirt",         prefix = "hldi", count = 4 },
    { name = "snow",         prefix = "hlsn", count = 4 },
    { name = "water",        prefix = "hlsp", count = 4 },
    { name = "glass",        prefix = "hlgl", count = 5 },
    { name = "wood_heavy",   prefix = "hlwo", count = 4 },
    { name = "metal_heavy",  prefix = "hlme", count = 4 },
    { name = "grate",        prefix = "hlgr", count = 4 },
    { name = "duct",         prefix = "hldu", count = 4 },
    { name = "organic",      prefix = "hlor", count = 4 },
    { name = "swim",         prefix = "hlsw", count = 4 },
}

local function SafeFreeSlot(defs)
    for _, def in ipairs(defs) do
        for i = 1, def.count do
            local name = ("sfx_%s%d"):format(def.prefix, i)
            if not rawget(_G, name) then
                -- freeslot returns an index; set caption to "/" so we don't register as a caption
                local idx = freeslot(name)
                sfxinfo[idx].caption = "/"
            end
        end
    end
end

SafeFreeSlot(materialDefs)

if not HLFootsteps then
	rawset(_G, "HLFootsteps", {
		flatsounds     = {},
		soundinfolist = {},
		surfaceSounds = {},
		registerFlatMaterial = function(flat, material)
			HLFootsteps.flatsounds[flat] = material
		end,
		registerSurfaceSound = function(material, sounds)
			HLFootsteps.soundinfolist[material] = sounds
		end,
	})
end

-- Ensure PlayerAnimInfo exists
local PlayerAnimInfo = {}

-- Build the master sound info list
for _, def in ipairs(materialDefs) do
    -- collect the SFX constants into an array
    local steps = {}
    for i = 1, def.count do
        steps[#steps+1] = _G[("sfx_%s%d"):format(def.prefix, i)]
    end

    -- assign steps/jump/land to the same array
    HLFootsteps.soundinfolist[def.name] = {
        steps = steps,
        jump  = steps,
        land  = steps,
    }
end

-- Everything with the same footsteps as something else
local aliases = {
    slosh        = "water",
    lava         = "water",
    tile         = "glass",
    ice          = "glass",
    grass        = "dirt",
    cloth        = "dirt",
    sand         = "dirt",
    metal_light  = "grate",
    wood_light   = "wood_heavy",
	wood         = "wood_heavy",
}

for alias, target in pairs(aliases) do
    HLFootsteps.soundinfolist[alias] = HLFootsteps.soundinfolist[target]
end

-- TD Forest uses REDFLR for blood

local materialGroups = {
	cloth = { "184 kori's cafe DCASPHW", "184 kori's cafe SPEC3", "261 emerald hill zone 2FORTFB", "45 hyper house SFLR06", "ACZFLR14", "ACZFLR15", "ACZFLR22", "ACZFLR23", "ARCADE", "CECRPTB", "CECRPTBE", "CECRPTBN", "CECRPTBS", "CECRPTBW", "CECRPTG1", "CECRPTG2", "CECRPTGE", "CECRPTGN", "CECRPTGS", "CECRPTGW", "CECRPTP", "CECRPTR", "CECRPTRE", "CECRPTRN", "CECRPTRS", "CECRPTRW", "CHACARPE", "DISCOF1", "DISCOF2", "DISCOF3", "DISCOF5", "DTDMM0", "DTDMQ0", "DTDMR0", "EGGCARPE", "FI_WIRE", "FTDMI0", "FTDMJ0", "FTDMK0", "FTDML0", "FTDMM0", "GRIM00", "GRIMQ0", "HOTIND", "IMPCOVER", "MIKUBACK", "OFTABLE", "PVDEMF", "SSNEWE", "TRRSA1", "TRRSA2", "ZIMTILE1", "ZIMTILE2", "ZIMTILE3", "ZIMTILE4", "ZIMWALL1", "798 tails dolls' forest zone 5 DCYELLW", "CRATOP1" },
	concrete = { "1003 neon night THZFLR24", "17 gm_construct TILE", "17 gm_construct TILEB", "173 crossfire zone THZFLR24", "2FORTFB", "2FORTFC", "AC2_8_2_", "ACROAD1", "ACROCKY1", "ACROCKY2", "ACROCKY3", "ACROCKY4", "ACROCKY5", "ACROPF1", "ACROPF2", "ACROPF3", "ACROPF4", "ACSBCAN1", "ACSBCAN3", "ACZFLR01", "ACZFLR02", "ACZFLR03", "ACZFLR20", "ACZFLR21", "ACZFLR24", "ACZFLR25", "ACZFLR26", "ACZFLR27", "ACZFLR28", "ACZRAILP", "ACZRFL1A", "ACZRFL1B", "ACZRFL1C", "ACZRFL1D", "ACZRFL1E", "ACZRFL1F", "ACZRFL1G", "ACZRFL1H", "ACZRFL2A", "ACZRFL2B", "ACZRFL2C", "ACZRFL2D", "ACZRFL2E", "ACZRFL2F", "ACZRFL2G", "ACZRFL2H", "ACZROCK3", "ACZROKF1", "ACZROKF2", "ACZWAL2", "ACZWALN", "AGZFLR01", "AGZFLR02", "ASPECF", "ASPECF2", "ASPECF3", "ATSLATE", "BLUEFLR", "BLUINSID", "BLUWALL", "BRICK1", "BRICK2", "BRICK3", "BRICK4", "BRIDGEA2", "BRIDGEA3", "BSPECF", "BSPECF2", "BSPECF3", "BSZFLR03", "BSZROCK", "BUSTFLR", "CASINOF1", "CASINOF2", "CASINOF3", "CASINOF4", "CASTLEA", "CAVEF1", "CAVEF2", "CAVEF3", "CAVEF4", "CAVEF5", "CAVEF6", "CAVEF7", "CAVEF8", "CAVEF9", "CAVEFA", "CAVEFB", "CEBRICK1", "CEBRICKC", "CEBRICKS", "CEBURST1", "CEBURST2", "CEBURST3", "CEBUSTC1", "CEMENT2", "CESBCA00", "CESBFO01", "CESTONB1", "CESTONB5", "CESTOND1", "CESTOND2", "CESTOND3", "CESTOND4", "CESTOND5", "CESTOND6", "CESTOND7", "CESTOND8", "CESTOND9", "CESTONE", "CESTONE1", "CESTONE2", "CESTONE3", "CESTONE4", "CESTONE5", "CESTONE6", "CESTONE7", "CESTONE8", "CESTONE9", "CESTP1E", "CESTP1N", "CESTP1S", "CESTP1W", "CETILB1", "CETILB1B", "CETILB2", "CETILB2B", "CETILB3", "CETILC4", "CETILC4B", "CETILD1", "CETILD1B", "CETILD2", "CETILD2B", "CETILD3", "CETILE1", "CETILE1B", "CETILE2", "CETILE2B", "CETILE3", "CETILE4", "CETILE4B", "CETILL1", "CETILL1B", "CETILL2", "CETILL2B", "CETILL3", "CETILL4", "CETILL5", "CETILL6", "CEZBIG5", "CEZCLOUD", "CEZFLR01", "CEZFLR06", "CEZFLR09", "CEZRCK0", "CEZRCKF0", "CEZROCKA", "CF0", "CF1", "CF2", "CHEKSMOL", "CLIFF1", "CLIFF1S", "CLIFF2", "CLIFF2S", "CLIFF3", "CLIFF3S", "CLIFF4", "CLIFF4S", "CLIFF5", "CLIFF5S", "CLIFF6", "CLIFF6S", "CLIFF7", "CLIFF7S", "CLIFF8", "CLIFF8S", "CLIFF9", "CLIFF9S", "CLIFFA", "CLIFFAS", "CLIFFB", "CLIFFBS", "CLIFFC", "CLIFFCS", "CLIFFD", "CLIFFDS", "CLIFFE", "CLIFFES", "CLIFFF", "CLIFFFS", "CLIFFG", "CLIFFGS", "CLIFFH", "CLIFFHS", "CLIFFW1", "CLIFFW2", "CLIFFW3", "CONCBLAK", "CRCROSS", "CRGRND", "CRGRND2", "CRISIS01", "CRISIS02", "CRISIS03", "CRISIS04", "CRISIS05", "CRISIS10", "CRISIS11", "CRISIS12", "CRISIS13", "CRISIS14", "CRISIS15", "CRISIS16", "CRISIS21", "CRISIS22", "CSPECF", "CSPECF2", "CSPECF3", "CUT1", "CYANFLR", "CYANWALL", "D2LAVA", "DC1", "DCASPHW", "DCFLR01", "DCFLR02", "DCFLR03", "DCFLR04", "DCFLR05", "DCFLR06", "DCFLR07", "DCFLR08", "DCFLR09", "DCFLR10", "DCFLR11", "DCFLR12", "DCFLR13", "DCFLR14", "DCFLR15", "DCFLR16", "DCFLR17", "DCFLR18", "DCFLR19", "DCFLR20", "DCFLR21", "DCFLR22", "DCFLR23", "DCFLR24", "DCFLR25", "DCTOP", "DCTOP2", "DCWHITEW", "DCZFLR01", "DCZFLR03", "DCZFLR04", "DCZFLR05", "DCZFLR06", "DCZFLR09", "DCZFLR13", "DCZFLR14", "DCZFLR15", "DCZFLR16", "DCZFLR17", "DEM1_1", "DFZCLD1", "DFZCLD2", "DFZCLD3", "DLAVA1", "DLAVA2", "DLAVA3", "DLAVA4", "DMAFLAT1", "DMAFLAT2", "DMAFLAT3", "DMAFLAT4", "DMAFLAT5", "DMAFLAT6", "DMAFLAT7", "DMAFLAT8", "DMAWALL3", "DPFLAT1", "DPFLAT2", "DPPILL2F", "DPPILLRF", "DSBLOCB1", "DSBLOCK2", "DSBLOCK3", "DSBLOCK4", "DSCYAN3", "DSDAWAL1", "DSDEBRIS", "DSFLOOR2", "DSKNUXB1", "DSNOCLM2", "DSRFLOR1", "DSRFLOR2", "DSROCK_2", "DSSWIT1", "DSSWIT2", "DSSWIT3", "DSSWIT4", "DSSWIT5", "DSSWIT6", "DSTILEN1", "DSTRACK1", "DSTRACK2", "DSWHEELF", "DSZ10", "DSZ11", "DSZFLR01", "DSZFLR02", "DSZFLR03", "DSZFLR07", "DSZFLR09", "DSZFLR11", "DSZFLR12", "DSZFLR14", "DSZFLR15", "DSZFLR16", "DSZFLR17", "DSZFLR18", "DSZFLR19", "DSZRCKF1", "DSZRCKF2", "DSZRCKF3", "DSZROCK1", "DTDMB0", "DTDMD0", "DTDMH0", "DTDMV0", "DUSTY02", "DUSTY03", "DUSTY04", "DUSTY05", "DUSTY06", "DUSTY07", "DUSTY08", "DUSTY09", "DUSTY10", "DUSTY11", "DUSTY12", "DUSTY13", "DUSTY14", "DUSTY15", "DUSTY16", "DUSTY17", "DUSTY18", "DUSTY19", "DUSTY20", "EHZWAL1", "ERZAI200", "ERZAI201", "ERZAI202", "ERZAI203", "ERZAI204", "ERZAI205", "ERZAI206", "ERZAI207", "ERZAI208", "ERZAI209", "ERZAI210", "ERZAI211", "ERZAI212", "ERZAI213", "ERZAI214", "ERZAI215", "ERZAIR00", "ERZAIR01", "ERZAIR02", "ERZAIR03", "ERZAIR04", "ERZAIR05", "ERZAIR06", "ERZAIR07", "ERZAIR08", "ERZAIR09", "ERZAIR10", "ERZAIR11", "ERZAIR12", "ERZAIR13", "ERZAIR14", "ERZAIR15", "ERZRCKF1", "ERZRCKF2", "ERZRCKF3", "ERZRCKF4", "ERZRCKF5", "ERZRCKF8", "ERZRCKF9", "ERZRED4", "ERZROCK3", "FGZROKFL", "FHZICEFL", "FHZICEWL", "FLAMEC01", "FLAMEC02", "FLAMEC03", "FLAMEC04", "FLAMEC05", "FLOOR0_4", "FLOOR6_1", "FLOOR6_2", "FOSSIL", "FROST01", "FROST02", "FRSTRCK1", "FRSTRCKF", "FTDMP0", "FTDMQ0", "FTDMR0", "F_SKY1", "GATE2", "GEOBMP1", "GEOBMP1S", "GFZBLOCK", "GFZBRICK", "GFZCHEK1", "GFZFLR01", "GFZFLR11", "GFZFLR12", "GFZFLR14", "GFZFLR15", "GFZFLR16", "GFZFLR17", "GFZFLR20", "GFZINSID", "GFZROCK", "GFZROCKA", "GFZROCKC", "GFZTIL01", "GFZTIL02", "GFZVINE2", "GFZWAVE", "GFZWAVEF", "GHTILE2", "GHTILE3", "GHZFLR07", "GHZFLR08", "GHZFLR0C", "GHZROCKF", "GHZWALL7", "GHZWALLA", "GHZWALLC", "GOLDFLR", "GREENFLR", "GREYFLR", "GRIDGREY", "GRIDORAN", "GRIMA0", "GRIMC0", "GRIMD0", "GRIML0", "GRIMM0", "GRIMP0", "GRIMR0", "GRIMS0", "GRIMT0", "GRIMU0", "GRIMX0", "GRNLITE1", "GRYWALL", "GSPECF", "GSPECF2", "GSPECF3", "HHZBLAC2", "HHZBLACK", "HHZCRACF", "HHZSTNF1", "HHZSTNF2", "HONEYF", "HOTELWA3", "HPEMERAL", "HPFLOOR", "HPZBLOK", "HPZROCK", "ICEFLR0", "ICEFLR1", "ICEFLR2", "ICEFLR3S", "ICEFLR4", "ICEFLR4S", "ICEFLR5", "ICEFLR6", "ICEFLR7", "ICEFLR8", "ICEFLR9S", "ICEWABT", "ICEWALL1", "ICEWALL3", "ICEWALL4", "ICEWALLP", "ICEWALLV", "ICEWALP", "IMG_2021", "ISSFLR", "JNGF13S", "JNGF14S", "JNGF15S", "JNGF16S", "JNGFLR01", "JNGFLR02", "JNGFLR03", "JNGFLR04", "JNGFLR13", "JNGFLR14", "JNGFLR15", "JNGFLR16", "JNGRCKF1", "JNGRCKF2", "JNGRCKF3", "JNGRCKF4", "KINVAL03", "KINVAL05", "KINVAL06", "KINVAL07", "KINVAL08", "KINVAL09", "KINVAL10", "KINVAL11", "KINVAL12", "KINVAL13", "KINVAL15", "KINVAL16", "KINVAL17", "KINVAL18", "LAKEFLR5", "LAKEFLR6", "LAKEFLR7", "LAKEFLRD", "LAKEFLRE", "LAKEFLRF", "LAKEWALB", "LBZFLOR7", "LBZFLOR8", "LBZFLOR9", "LBZFLORA", "LBZFLORB", "LBZFLORC", "LFLRA1", "LFLRA2", "LFLRA3", "LFLRB1", "LFLRB2", "LFLRB3", "LFLRB4", "LFLRC1", "LFLRC2", "LFLRC3", "LFLRC4", "LFLRD1", "LFLRD2", "LFLRE1", "LFLRE2", "LFLRF1", "LFLRF1B", "LFLRF2", "LFLRF2B", "LFLRF3", "LFLRF4", "LFZFLR1", "LIMEFLR", "LIMEWALL", "LVASAND1", "LVASAND2", "MARIOF1", "MARIOF10", "MARIOF11", "MARIOF12", "MARIOF13", "MARIOF14", "MARIOF15", "MARIOF16", "MARIOF2", "MARIOF4", "MARIOF5", "MARIOF5A", "MARIOF7", "MARIOF8", "MARIOF9", "MARROCK1", "MARROCK2", "MARROCK3", "MARROCK4", "MINECRAT", "MM8", "MMB2", "MMB3", "MMB6", "MMB8", "MMBFLR9", "MMBFLRA", "MMBFLRB", "MMBFLRC", "MMFLR7", "MMFLR8", "MMFLR9", "MMFLRA", "MMFLRB2", "MMFLRB3", "MMFLRB4", "MMFLRB5", "MMFLRB5A", "MMFLRB6", "MMFLRB7", "MMFLRB8", "MMFLRD", "MMFLRE", "MMFLRF", "MRNR1T1", "MRNR1T2", "MRNR2T1", "MRNR2T2", "MRNR3T1", "MRNR3T2", "MRNR4T1", "MRNR4T2", "NEOGFLR", "NEOGWALL", "NIZF01", "NNB3", "NOODL3", "OJCROCK", "OJCTILA1", "OJCWALL", "OLDCEZF1", "OLDCEZW", "OLDGFZF4", "OLDGFZW1", "OLDROCKW", "ORANGE", "ORFLOOR1", "ORFLOOR2", "ORFLOOR3", "ORFLOOR4", "ORFLOOR5", "ORFLOOR6", "ORFLOOR7", "ORFLOOR8", "ORFLOOR9", "ORGFLR", "ORPEBBLE", "PAZFLR05", "PCBRICK1", "PIT", "PLACEH12", "PLACEH13", "PLHD2", "PLHD26", "PLHD3", "PLHD30", "PLHD4", "PRZTIL01", "PRZTIL23", "PRZTIL25", "PRZTIL26", "PRZTIL27", "PSPECF", "PSPECF2", "PSPECF3", "PURFLR", "RAINBOW1", "RAINBOW2", "RAINBOW3", "RAINBOW4", "RCZCRSF1", "RCZCRSF2", "RCZCRSF3", "RCZCRSF4", "RCZFLPV4", "RCZFLR1", "RCZFLR2", "RCZFLR3", "RCZFLR4", "RCZFLR5", "RCZFLR6", "RCZFLR7", "RCZFLR8", "RCZWLL1", "RCZWLL2", "RECORD", "REDFLR", "REDWALL", "REVWALL3", "REVWALL4", "ROCK2", "ROCKBOIL", "ROCKBOIM", "ROCKF1", "ROCKF2", "ROCKF3", "ROCKF4", "ROCKF5", "ROCKFLR1", "ROCKFLR2", "ROCKFLR3", "ROCKFLR4", "ROCKMF11", "ROCKY1F", "ROCKY2F", "ROCKY3F", "ROCKY4F", "ROCKY5F", "ROCKY6F", "ROKFLR1", "RSPECF", "RSPECF2", "RSPECF3", "RUINS1_1", "RUINS1_2", "RVDARKF1", "RVDARKF2", "RVPUMICF", "RVRCKTTO", "RVZ1SBTM", "RVZ2SBTM", "RVZ2STOP", "RVZDRUMT", "RVZWALF1", "RVZWALF2", "RVZWALF3", "RVZWALF4", "RVZWALF5", "RVZWALF6", "RVZWALF7", "SAINYF1", "SANDFLRA", "SANDFLRB", "SANDFLRC", "SASPHALT", "SEGAWHIT", "SEGGF01", "SEGGF02", "SEGGF03", "SEGGF04", "SEGGF05", "SEGOUTSI", "SFLR01", "SFLR01B", "SFLR02", "SFLR02B", "SFLR03", "SFLR04", "SFLR05", "SFLR06", "SFLR07", "SFLR09", "SFLR10", "SFLR12", "SFLR13", "SFLR14", "SFLR15", "SFLR16", "SFLR17", "SFLR18", "SFLR19", "SFLR20", "SFLR21", "SFLR22", "SFLR23", "SFLR24", "SFLR25", "SFLR26", "SFLR27", "SFLR28", "SFLR29", "SFLR30", "SFLR31", "SFLR32", "SFLR33", "SFLR34", "SFLR35", "SHALE1", "SHALE2", "SHALEF1", "SHALEF2", "SKY1024", "SKY1026", "SKY1028", "SLF_174", "SNDPILRA", "SNDWALLD", "SPACEBL", "SPACEBM", "SPACEBS", "SPACEGL", "SPACEGM", "SPACEGS", "SPACERL", "SPACERM", "SPACERS", "SPACEYL", "SPACEYM", "SPACEYS", "SPFLOOR1", "SRB1FE1", "SRB1FIP1", "SRB1FKB1", "SRB1FV1", "SRB1FV2", "SRB1FV3", "SSCHJ", "SSCROSSW", "SSIDEWAL", "SSTRAIH", "STONE01", "STONEF1", "STONEF2", "TARMAC", "TEMP", "TEMP2", "TERROCKS", "TH2_SF1", "TH2_SF2", "TH2_SF3", "THPIPEFA", "THPIPEFB", "THPIPEFC", "THPIPEFD", "THROCKF", "THROCKF2", "THROCKLF", "THWOMPFL", "THZ2FN1", "THZ3DPF1", "THZ3DPF2", "THZ3DPF3", "THZ3DPF4", "THZFLR30", "TLITE6_1", "TLITE6_5", "TLITE6_6", "TOMBNTOP", "TRAIN02", "TRAIN08", "TRAIN09", "TRAIN10", "TRAIN21", "TRAIN22", "TRAIN23", "TROPIC08", "TROPIC13", "TROPIC14", "TROPIC15", "TROPIC18", "TRRSG0", "VIOFLR", "WAVE03", "WAVE06", "WAVE07", "WAVE08", "WAVE09", "WAVE10", "WAVE14", "WHITE06", "WHITE09", "WHITE10", "WHITE11", "WHITE12", "WHITE13", "WHITE14", "WHITE15", "WHITE16", "WHITE17", "WHITE18", "WHITE19", "WHITEFLR", "WSPECF", "XMSFLR01", "XMSFLR03", "XMSFLR04", "XMSFLR07", "XMSFLR15", "XMSFLR17", "XMSFLR18", "XMSFLR19", "XMSFLR20", "XTRMCHK", "YELFLR", "YELWALL", "YLOPIPF1", "YLOPIPF2", "YLOPIPF3", "YLOPIPF4", "YSPECF", "YSPECF2", "YSPECF3", "ZIMFLR01", "ZIMWALL3", "~000", "~001", "~003", "~004", "~005", "~006", "~007", "~008", "~009", "~010", "~011", "~012", "~013", "~014", "~015", "~016", "~017", "~018", "~019", "~020", "~021", "~022", "~023", "~024", "~025", "~026", "~027", "~028", "~029", "~030", "~031", "~032", "~033", "~034", "~035", "~036", "~037", "~038", "~039", "~040", "~041", "~042", "~043", "~044", "~045", "~046", "~047", "~048", "~049", "~050", "~051", "~052", "~053", "~054", "~055", "~056", "~057", "~058", "~059", "~060", "~061", "~062", "~063", "~064", "~065", "~066", "~067", "~068", "~069", "~070", "~071", "~072", "~073", "~074", "~075", "~076", "~077", "~078", "~079", "~080", "~081", "~082", "~083", "~084", "~085", "~086", "~087", "~088", "~089", "~090", "~091", "~092", "~093", "~094", "~095", "~096", "~097", "~098", "~099", "~100", "~101", "~102", "~103", "~104", "~105", "~106", "~107", "~108", "~109", "~110", "~111", "~112", "~113", "~114", "~115", "~116", "~117", "~118", "~119", "~120", "~121", "~122", "~123", "~124", "~125", "~126", "~127", "~128", "~129", "~130", "~131", "~132", "~133", "~134", "~135", "~136", "~137", "~138", "~139", "~140", "~141", "~142", "~143", "~144", "~145", "~146", "~147", "~148", "~149", "~150", "~151", "~152", "~153", "~154", "~155", "~156", "~157", "~158", "~159", "~160", "~161", "~162", "~163", "~164", "~165", "~166", "~167", "~168", "~169", "~170", "~171", "~172", "~173", "~174", "~175", "~176", "~177", "~178", "~179", "~180", "~181", "~182", "~183", "~184", "~185", "~186", "~187", "~188", "~189", "~190", "~191", "~192", "~193", "~194", "~195", "~196", "~197", "~198", "~199", "~200", "~201", "~202", "~203", "~204", "~205", "~206", "~207", "~208", "~209", "~210", "~211", "~212", "~213", "~214", "~215", "~216", "~217", "~218", "~219", "~220", "~221", "~222", "~223", "~224", "~225", "~226", "~227", "~228", "~229", "~230", "~231", "~232", "~233", "~234", "~235", "~236", "~237", "~238", "~239", "~240", "~241", "~242", "~243", "~244", "~245", "~246", "~247", "~248", "~249", "~250", "~251", "~252", "~253", "~254", "~255", "798 tails dolls' forest zone 5 THZMETL3", "ROCKY2", "ZIMWALL5", "DCWAL14", "ERZROCK2", "CESTONB9", "WKPL_GNC", "MILBSWBL", "GFZCHEKB", "GFZCHEK2", "DCWAL26", "TH2_SB2", "CESTEP4", "LAB1_BRD", "568 starlit warehouse zone THZFLR24", "ERZROCK1", "194 cave of mystery TRAPFLR", "HPZTP4", "HPZTP3", "HPZROCK2" },
	dirt = { "1003 neon night BUSTFLR", "ACROPE1", "ACROPE2", "ACSBDSRC", "ACSBDSRT", "CARPET01", "CARPET02", "CARPET03", "CARPET04", "CARPET05", "CARPET06", "CARPET07", "CARPET08", "CARPET09", "CARPET10", "CARPET11", "CARPET12", "CARPET13", "CARPET14", "CEZBRWL1", "CEZDRT0", "CEZDRTF0", "CEZGRS2", "CEZPLD1F", "CRISIS17", "CRISIS18", "CRWLK", "CRWLKR", "CRZDS", "DIRT", "DIRT1", "DIRT1F", "DIRT2", "DIRT2F", "DIRT3", "DIRT3F", "DIRT4", "DIRT4F", "DIRT5F", "DSROCK_1", "DSSBFLR1", "DSZFLR04", "DSZFLR05", "DSZFLR06", "ERZRCKF6", "ERZRCKF7", "FACSB_3", "FLOOR0_2", "FTDMB0", "GFZFLR08", "GRAVEL", "JNGMUDF1", "JNGMUDF2", "JNGMUDF3", "JNGMUDF4", "JNGMUDF5", "LAKEFLR1", "LAKEWAL7", "LFZFLR4", "LFZFLR5", "LFZWALL1", "LFZWALL2", "LFZWALL3", "MHFL1", "MHFL3", "MHFL4", "MRMUD", "OLDGFZF1", "PVDIRT1F", "RVZGRSW6", "SAND", "SANDFLR", "SHROOM1", "SHROOM2", "SHROOM3", "THDIRT", "TRAIN01", "TRAIN07", "TRAIN11", "TRAIN12", "TRAIN16", "TRAIN17", "DIRT5", "390 mansion CESTONB9" },
	glass = { "182 chrispy's arcade zone GFZINSID", "182 chrispy's arcade zone GFZTIL01", "182 chrispy's arcade zone GFZTIL02", "DIMFLRA", "DISCOD1", "DTDMA0", "DTDME0", "DTDMF0", "DTDMW0", "GLASE5", "GRIMN0", "ICEFLR9", "ICEFLRA", "ICEWALLA", "KINVAL19", "PAZFLR01", "PAZFLR02", "PAZFLR03", "PAZFLR04", "SKY21", "SPEC2", "WHITE07", "ZIMTILE5", "GLASSVER", "GLASS", "GLASS3" },
	grass = { "BSZFLOOR", "BSZGRAS2", "BSZGRASF", "BSZRPLAN", "CEBRAMBL", "CEVBARF", "CEZFLR02", "CEZFLR03", "CEZFLR05", "CEZFLR12", "CEZFLR13", "CEZGRS0", "CEZGRS1", "CEZGRS10", "CEZGRS11", "CEZLEAF0", "CEZTRA1", "CHKGRASF", "CVCOFL2", "DCZGRASS", "DEM1_2", "DKLEAFLR", "DMGF1", "DMGF2", "EC_VINES", "EC_VINET", "EHZTESF2", "EHZTEST3", "FACSB_4", "FFZGRAS1", "FLBWY_02", "FLBWY_R2", "FLOBY_02", "FLOWB_01", "FLOWB_02", "FLOWB_03", "FLOWB_04", "FLOWG_01", "FLOWO_01", "FLOWO_02", "FLOWO_03", "FLOWO_04", "FLOWP_01", "FLOWP_02", "FLOWP_03", "FLOWP_04", "FLOWR_01", "FLOWR_02", "FLOWR_03", "FLOWR_04", "FLOWW_01", "FLOWW_02", "FLOWW_03", "FLOWW_04", "FLOWY_01", "FLOWY_02", "FLOWY_03", "FLOWY_04", "FPGRAS2", "FWALL_04", "FWBOW_04", "FWBOY_04", "FWBPW_04", "FWBPY_04", "FWBP_04", "FWBWY_02", "FWBWY_04", "FWBY_04", "FWB_04", "FWOPY_04", "FWOP_04", "FWORY_04", "FWOWY_04", "FWO_04", "FWPW_04", "FWP_04", "FWR_04", "FWWY_04", "FWW_04", "GFZFLR02", "GFZFLR10", "GFZFLR21", "GFZFLR22", "GFZFWR01", "GFZFWR02", "GFZGRSW", "GRASS", "GRASS1", "GRASS2", "GRASS2W", "GRASS3", "GRASSF", "GRASSY", "GVZGRA2", "HHZGRAS1", "HHZGRAS2", "HNYLEAFF", "JNGFLR09", "JNGFLR10", "JNGFLR11", "JNGFLR12", "JNGGRS01", "JNGGRS02", "JNGGRS03", "JNGGRS04", "JNGGRS05", "JNGGRS06", "JNGGRS07", "JNGGRS08", "JNGGRS09", "JNGGRS10", "JNGGRS11", "JNGGRS12", "JVZFW01", "JVZFW02", "JVZFW03", "JVZFW04", "JVZFW05", "J_HOGHED", "KHZGRA4", "KINVAL01", "KINVAL02", "KINVAL04", "KINVAL14", "LAKEFLR4", "LFZFLR2", "LFZFLR3", "MARGRA", "MGGRASS", "MHFL2A", "MHFL2B", "MRGRAASS", "MRGRASSS", "NOODL1", "OLDCEZF2", "OLDCEZF3", "OLDGFZF2", "OLDGFZF3", "PLHD2F", "RVZGRS01", "RVZGRS02", "RVZGRS03", "RVZGRS04", "RVZGRS05", "RVZGRS06", "RVZGRS07", "RVZGRSW1", "RVZGRSW2", "RVZGRSW3", "SBSHRUBS", "SEGAGRAS", "SFZLEAF", "SSBUSHES", "THZGRS1", "THZGRS2", "TRAIN05", "TRAIN06", "TRAIN14", "TRAIN15", "TROPIC01", "TROPIC02", "TROPIC03", "TROPIC04", "TROPIC05", "TROPIC09", "TROPIC10", "TROPIC11", "VFZFLR01", "WAVE02", "WAVE12", "WAVE15", "WEBBIGF", "WEBBIGF2", "WEBBIGF3", "GRASS3W", "856 frozen creek ICEFLR0", "BSZBPLAN", "AAZGRSA", "BSZGRAS1" },
	ice = { "546 silver shiver zone XMSFLR03", "ICEPALCE", "ICEWAL9S", "ICEWALBU", "ICEWALL5", "ICEWALL9", "ICEWALLR" },
	lava = { "ERLAVA1", "FLAMEC06", "LAVA1", "LAVA2", "LAVA3", "LAVA4", "RLAVA1", "RLAVA2", "RLAVA3", "RLAVA4", "RLAVA5", "RLAVA6", "RLAVA7", "RLAVA8", "RVZ1S_BF", "TAR" },
	metal_heavy = { "285 clockwork towers zone DCZFLR14", "3 station square KITTOP", "3 station square SBTVPANE", "3 station square SCAREWAR", "3 station square TOMKTOP", "ACDEBRI2", "ACDEBRIS", "ACSTEAM0", "ACZBARLF", "ACZFLR12", "ACZFLR13", "ACZRAILF", "ACZWALI", "ALTBOXF1", "ALTBOXF2", "ALTBOXF3", "ALTBOXF4", "APFLOR1", "APFLOR2", "APFLOR3", "APFLOR4", "APFLOR5", "APFLOR6", "APFLOR7", "AQUA01", "AQUA02", "AQUA03", "AQUA04", "AQUA05", "AQUA06", "AQUA07", "AQUA08", "AQUA09", "AQUA10", "AQUA11", "AQUA12", "AQUA13", "AQUA14", "AQUA15", "AQUA16", "AQUA17", "AQUA18", "AQUA19", "AQUA20", "BOX02", "BOX3", "BOXWARN2", "BOXWARNG", "BSFLR1", "BSFLR1B", "BSFLR1C", "BSFLR1D", "BSFLR1DB", "BSFLR1E", "BSFLR1F", "BSFLR2", "BSFLR2B", "BSFLR2C", "BSFLR2D", "BSFLR2DB", "BSFLR2E", "BSFLR2F", "BSFLR3", "BSFLR3B", "BSFLR3C", "BSFLR3D", "BSFLR3DB", "BSFLR3E", "BSFLR3F", "BSFLR4", "BSFLR4E", "BSFLR5", "BSFLR5B", "BSFLR5C", "BSFLR5D", "BSFLR5DB", "BSFLR5E", "BSFLR5F", "BSFLR6B", "BSFLR6C", "BSFLR6D", "BSFLR6DB", "BSFLR6E", "BSFLR6F", "BSZFLR01", "BSZFLR02", "BSZFLR04", "CATFLR03", "CATFLR04", "CEIL3_1", "COMP7A", "COMP7B", "CONI", "CONVEY1", "CONVEY2", "CRISIS07", "CRISIS08", "CRISIS09", "CRISIS19", "CRISIS20", "DCZFLR02", "DCZFLR07", "DCZFLR08", "DCZFLR11", "DCZFLR12", "DEM1_3", "DEZBLKF1", "DEZBLKF2", "DEZBLKF3", "DEZBLKF4", "DEZBLKF5", "DEZBLKF6", "DEZBLKF7", "DEZBLKF8", "DEZBLOKF", "DEZBRKF", "DMAPIPE", "DMAPIPE2", "DSHIPF1", "DSHIPF2", "DSHIPF3", "DSHIPF4", "DSHIPF5", "DSHIPF6", "DSHIPF7", "DSHIPF8", "DSHIPF9", "DSHIPFA", "DSHIPFB", "DSHIPFC", "DSHIPFD", "DSHIPFE", "DTDMZ0", "EFLR1", "EGRIDF1", "EGRIDF2", "EGRIDF3", "ERFANFL1", "ERFANFL2", "ERFANFL3", "ERZBG3", "ERZBGF1", "ERZBGF2", "ERZBGF3", "ERZBGF4", "ERZBGF5", "ERZBGF6", "ERZBLCAU", "ERZBLUF1", "ERZBLUF2", "ERZBLUF3", "ERZBLUF4", "ERZBLUF5", "ERZCRTF1", "ERZFAN1", "ERZFAN2", "ERZFAN3", "ERZFAN4", "ERZFANR1", "ERZFANR2", "ERZFANR3", "ERZFANR4", "ERZFLR00", "ERZFLR01", "ERZFLR02", "ERZFLR03", "ERZFLR04", "ERZFLR05", "ERZFLR06", "ERZFLR07", "ERZFLR08", "ERZFLR09", "ERZFLR10", "ERZFLR11", "ERZFLR12", "ERZFLR13", "ERZFLR14", "ERZGREY4", "ERZGREY5", "ERZGREYF", "ERZGRTF1", "ERZGRYF1", "ERZGRYF2", "ERZGRYF3", "ERZGRYF4", "ERZGRYF5", "ERZLITF2", "ERZMASH1", "ERZMASH2", "ERZMASH3", "ERZMASH4", "ERZMASH5", "ERZMASH6", "ERZMASH7", "ERZMASH8", "ERZPI2F1", "ERZPIPEB", "ERZPIPF1", "ERZPIPF2", "ERZPIPF3", "ERZPIPF5", "ERZPIPF6", "ERZPIPF8", "ERZPIPF9", "ERZPLTF1", "ERZPLTF2", "ERZPLTF3", "ERZPLTF4", "ERZPLTF5", "ERZPLTF6", "ERZRDCAU", "ERZREDF1", "ERZREDF2", "ERZREDF3", "ERZREDF4", "ERZREDF5", "ERZWRNF1", "ERZYLCAU", "FLAT1_2", "F_METAL2", "GFZFLR03", "GFZFLR04", "HHZF1", "LAKEPIF1", "LAKEPIF2", "LAKEPIP2", "LBZFLR07", "LBZFLR08", "LBZFLR09", "LEGFLR01", "LEGFLR08", "LEGFLR18", "LIFTFLAT", "LITEB1", "LITEB2", "LITEB3", "LITEN1", "LITEN2", "LITEN3", "LITER1", "LITER2", "LITER3", "LITEY1", "LITEY2", "LITEY3", "MARIOF3", "MARIOF6", "MEKPIPE5", "MEKPIPF1", "MEKPIPF2", "MEKPIPF3", "MEKPIPF4", "MEKPIPF5", "MEKPIPF6", "MEKPIPF7", "PIPE2F", "PIPE3F", "RRZYELF3", "SCBBLKF1", "SCBFLR01", "SCBFLR02", "SCBFLR03", "SCBFLR04", "SCBGRATE", "SPAD01", "SPAD02", "SPAD03", "SPAD04", "SPADD01", "SPADD02", "SPADD03", "SPADD04", "SRB1FR1", "SRB1FRB1", "STEEL", "STEEL01", "STEEL02", "STEEL03", "STEEL04", "STEEL05", "STEEL06", "STEEL07", "STEEL08", "STEEL08B", "STEEL2", "STEEL3", "STKBOXK1", "STKBOXK2", "STKBOXK3", "STKBOXK4", "STKBOXS1", "STKBOXS2", "STKBOXS3", "STKBOXS4", "STKBOXT1", "STKBOXT2", "STKBOXT3", "STKBOXT4", "STLBLKF1", "STLBLKF2", "STLFLR01", "STLFLR02", "THCOMPF1", "THCOMPF2", "THCOMPF3", "THCOMPF4", "THCOMPF5", "THCOMPF6", "THCOMPW1", "THCOMPW7", "THPIPE1", "THPIPE2", "THPIPEF1", "THPIPEF2", "THTILEF1", "THZ2CN1", "THZ2CN1B", "THZ2CN2", "THZ2CN2B", "THZ2CN3", "THZ2CN3B", "THZ2CN4", "THZ2CN4B", "THZ2CN5", "THZ2CN5B", "THZ2CN6", "THZ2CN6B", "THZ2CN7", "THZ2CN7B", "THZ2CN8", "THZ2CN8B", "THZ2FN2", "THZ2FN3", "THZ2FN4", "THZ2FN4B", "THZ2FN5", "THZ2FN5B", "THZ2FN6", "THZ2FN6B", "THZ2FN7", "THZ2FN7B", "THZ2FN8", "THZ2FN9", "THZ2WN5", "THZ2WN5B", "THZ2WN6", "THZ2WN6B", "THZ2WN7", "THZ2WN7B", "THZ2WN8", "THZ2WN8B", "THZ3DPFA", "THZ3DPFB", "THZ3DPFC", "THZ3DPFD", "THZBOX", "THZBOXF1", "THZBOXF2", "THZBOXF3", "THZBOXF4", "THZELA1", "THZELA2", "THZELB1", "THZELB2", "THZELC1", "THZELC2", "THZELD1", "THZELD2", "THZELE1", "THZELE2", "THZELF1", "THZELF2", "THZELG1", "THZELG2", "THZELH1", "THZELH2", "THZELI1", "THZELI2", "THZELJ1", "THZELJ2", "THZFLR01", "THZFLR02", "THZFLR03", "THZFLR04", "THZFLR05", "THZFLR06", "THZFLR07", "THZFLR08", "THZFLR09", "THZFLR10", "THZFLR11", "THZFLR12", "THZFLR13", "THZFLR14", "THZFLR15", "THZFLR16", "THZFLR17", "THZFLR18", "THZFLR19", "THZFLR20", "THZFLR21", "THZFLR22", "THZFLR23", "THZFLR24", "THZFLR25", "THZFLR26", "THZFLR27", "THZFLR28", "THZFLR29", "THZFLR31", "THZFLR32", "THZFLR33", "THZFLR34", "THZFLR35", "THZFLR36", "THZFLR37", "THZGRYP1", "THZGRYP2", "THZLIG1", "THZLIG2", "THZLITS", "THZPIPE", "THZREDP1", "THZREDP2", "TRAIN13", "TRAIN18", "TRAIN19", "TRAIN20", "TRAIN24", "TRAIN25", "TRAIN26", "TRAIN27", "TRAPFLR", "TRRSC0", "VENT1F", "WAVE11", "WAVE13", "WHITE08", "THZWAL09", "ALTBOX01", "TUBEV" },
	metal_light = { "1003 neon night ZIMTILE2", "3 station square SATUSIDE", "BOXFLR3", "CASTLEFF", "CASTLET", "CHAOBOXF", "COMP1", "FFZMTLF1", "FI_WA2", "FI_WA3", "F_METAL1", "MRMETAL", "SACER", "SCZRINGP", "SEGAGRAY", "SIGNFLR", "SRB1WMM1", "SSTRAIA", "TECGRATE", "TEKGRATE", "THBARL1", "THZMETL1", "THZMETL2", "TRRSB0", "VIDO1", "THZMETL3", "VENT1", "VENT2", "STEEL06B", "TNNLFLR1", "SP1A", "THZPIPE2"},
	sand = { "BSZSAND", "D2SANDV", "DCZFLR10", "DEM1W5", "DEM1_5", "DPSAND", "DPSAND2", "DSSANDV", "DTDMX0", "DUSTY01", "FTDMA0", "ISSANDF", "LAKEFLR2", "LAKEFLR3", "MRSAND", "MRSBND", "QUIK2", "QUIK3", "QUIK4", "QUIK5", "QUIK6", "QUIK7", "QUIKNOAN", "SBBEACH", "TERFLOOR", "DCYELLW" },
	snow = { "SNOW01", "SNOW02", "SNOW03", "SSNOW2", "WHITE01", "WHITE02", "WHITE03", "WHITE04", "WHITE05", "XMAS20", "XMSFLR02", "SNOW", "ICEFLR3" },
	tile = { "184 kori's cafe STEEL08B", "184 kori's cafe THZLIG2", "2 sega 1998 SATURN", "2 sega 1998 SMGREYST", "2 sega 1998 SMSYSTEM", "BSFLR6", "CETILC1", "CETILC2", "DBTILL1", "DBTILL2", "DBTILS1", "DISCO1", "DISCO2", "DISCO3", "DISCO4", "DSCYAN1", "DSCYAN2", "DSFLOOR1", "DSLTILE1", "DSLTILE2", "DSZFLR08", "DTDMN0", "DTDMO0", "DTDMP0", "DTDMS0", "DTDMT0", "DTDMU0", "DTDMY0", "FDROOF", "HOTINC", "KITTOP", "LAKEWALD", "MEGADRIV", "PRZTIL22", "PRZTIL24", "SBMFLOOR", "SFLR08", "SFLR11", "SMFLOOR", "SMMARBLE", "SQFLOOR", "SRB1WIP1", "SSTATINB", "SSTATIND", "SSWIMTIL", "TILE", "TILEB", "DSTILE_1", "DSBLOCK1", "CEZFLR04", "MAN2KITL", "ATSTUC", "DSZFLR13", "BRIDGEA1", "DSZFLR10", "ZIMTILE6", "HPZPT8", "BLOKZILA", "CRATOP2" },
	water = { "BWATER01", "BWATER02", "BWATER03", "BWATER04", "BWATER05", "BWATER06", "BWATER07", "BWATER08", "BWATER09", "BWATER10", "BWATER11", "BWATER12", "BWATER13", "BWATER14", "BWATER15", "BWATER16", "CEZWATR0", "CEZWATR1", "CHEMG01", "CHEMG02", "CHEMG03", "CHEMG04", "CHEMG05", "CHEMG06", "CHEMG07", "CHEMG08", "CHEMG09", "CHEMG10", "CHEMG11", "CHEMG12", "CHEMG13", "CHEMG14", "CHEMG15", "CHEMG16", "CRISIS06", "DSSBFLR2", "DSSBFLR3", "DSSBFLR4", "DSSKSEA1", "DSSKSEA2", "DSWATER1", "DSWATER2", "FWATER1", "FWATER10", "FWATER11", "FWATER12", "FWATER13", "FWATER14", "FWATER15", "FWATER16", "FWATER2", "FWATER3", "FWATER4", "FWATER5", "FWATER6", "FWATER7", "FWATER8", "FWATER9", "GOOP01", "GOOP02", "GOOP03", "GOOP04", "GOOP05", "GOOP06", "GOOP07", "GOOP08", "GOOP09", "GOOP10", "GOOP11", "GOOP12", "GOOP13", "GOOP14", "GOOP15", "GOOP16", "GWATER01", "GWATER02", "GWATER03", "GWATER04", "GWATER05", "GWATER06", "GWATER07", "GWATER08", "GWATER09", "GWATER10", "GWATER11", "GWATER12", "GWATER13", "GWATER14", "GWATER15", "GWATER16", "HHWATR01", "HHWATR02", "HHWATR03", "HHWATR04", "HHWATR05", "HHWATR06", "HHWATR07", "HHWATR08", "HHWATR09", "HHWATR10", "HHWATR11", "HHWATR12", "HHWATR13", "HHWATR14", "HHWATR15", "HHWATR16", "LWATER1", "LWATER10", "LWATER11", "LWATER12", "LWATER13", "LWATER14", "LWATER15", "LWATER16", "LWATER2", "LWATER3", "LWATER4", "LWATER5", "LWATER6", "LWATER7", "LWATER8", "LWATER9", "OIL01", "OIL02", "OIL03", "OIL04", "OIL05", "OIL06", "OIL07", "OIL08", "OIL09", "OIL10", "OIL11", "OIL12", "OIL13", "OIL14", "OIL15", "OIL16", "SICK01", "SICK02", "SICK03", "SICK04", "SICK05", "SICK06", "SICK07", "SICK08", "SICK09", "SICK10", "SICK11", "SICK12", "SICK13", "SICK14", "SICK15", "SICK16", "SURF01", "SURF02", "SURF03", "SURF04", "SURF05", "SURF06", "SURF07", "SURF08", "WATER0", "WATER1", "WATER2", "WATER3", "WATER4", "WATER5", "WATER6", "WATER7", "WFA1" },
	wood = { "ACMINE6", "FTDMN0", "FTDMO0", "SBWAFLOO" },
	wood_heavy = { "2FORTF1", "2FORTF2", "2FORTF5", "2FORTF6", "2FORTF7", "2FORTF8", "2FORTF9", "2FORTFA", "ACMTRKF1", "ACSBDSRR", "ACWOOD1F", "ACWOOD2F", "ACWOOD3F", "ACWOOD4F", "ACWOODBX", "ACWOODS1", "ACWOODS2", "ACZCRATF", "ACZFLR04", "ACZFLR05", "ACZFLR06", "ACZFLR07", "ACZFLR08", "ACZFLR09", "ACZFLR10", "ACZFLR11", "ACZFLR16", "ACZFLR17", "ACZFLR18", "ACZFLR19", "BOX01", "CASTLE2", "CASTLE3", "CASTLE4", "CASTLE5", "CASTLED", "CASTLEE", "CASTLEF", "CASTLEG", "CEZFLR07", "CEZFLR08", "CEZFLR10", "CEZFLR11", "DEM1_6", "FLOOR1_2", "FLOOR1_3", "FTDMT0", "GFZFLR05", "GFZFLR06", "GFZFLR07", "GFZFLR09", "GFZFLR13", "GFZFLR18", "GFZFLR19", "GFZFNCF", "GFZFNCG", "GHZBRDG1", "GHZBRDG2", "GHZBRDG3", "GHZBRDG4", "GHZFLR02", "GHZFLR09", "JNGFLR05", "JNGFLR06", "JNGFLR07", "JNGFLR08", "JNGWD1", "JNGWD4", "JNGWD8", "JNGWDF1", "JNGWDF1B", "JNGWDF1S", "JNGWDF2", "JNGWDF2B", "JNGWDF2S", "JNGWDF3", "JNGWDF3B", "JNGWDF3S", "JNGWDF4", "JNGWDF4B", "JNGWDF4S", "JNGWDF5", "JNGWDF6", "JNGWDF7", "JNGWDF8", "JNGWDF9", "JNGWDFA", "JNGWDFB", "JNGWDFC", "LIBFLR1", "LIBFLR2", "SBTBARK", "TRAIN03", "TRAIN04", "TROPIC06", "TROPIC07", "TROPIC12", "TROPIC16", "TROPIC17", "WAVE01", "WAVE04", "WAVE05", "WOODFLR", "WOODFLR2", "WOODFLR3", "WOODFLR4", "WOODWALL", "XMSFLR05", "XMSFLR06", "XMSFLR08", "XMSFLR09", "XMSFLR10", "XMSFLR11", "XMSFLR12", "XMSFLR13", "XMSFLR14", "XMSFLR16", "OWOODW" },
	wood_light = { "2FORTF3", "2FORTF4", "ACWOOD1", "ACWOOD2", "ACWOOD3", "ACWOOD4", "BOXFLR1", "CCBLU2", "CCRED1", "CCYEL1", "CYFLOR", "DCWALL1", "DTDMG0", "DTDMI0", "DTDMJ0", "DTDMK0", "DTDML0", "FTDMC0", "FTDMD0", "FTDME0", "FTDMF0", "FTDMG0", "FTDMH0", "FTDMS0", "GRIMB0", "GRIMO0", "GRIMV0", "GRIMW0", "KHBRIDA", "LIBRARY9", "MRPLANKS", "PTNX", "SBSTORE", "SBWOODPA", "SFXWALL2", "TOMKTOP", "TRRSD0", "TRRSE0", "TTBASE1", "WODBLU", "WODRED", "WOODWLL1", "WOODWLL2", "WOODWLL3", "LIBRARY4", "ACZCRATE", "2FORTWL1", "ACTOWNA2" },
	grate = {"{GRATE4A", "CATFLR02"},
}

for material, textures in pairs(materialGroups) do
    for _, texture in ipairs(textures) do
        HLFootsteps.flatsounds[texture] = material
    end
end

-- player.mo.frame & FF_FRAMEMASK
local playeraniminfo = {
	kombifreeman = {
		runFrames		 = { B, G },
		dashFrames		 = { -1 },
		walkFrames		 = { B, F },
		crouchFrames	 = { E, I },
		milnekickFrames  = { 0, 4 },
		run				 = true,
		dash			 = false,
		walk			 = true,
		idle			 = false,
		wait			 = false,
		crouch			 = true,
		milnekick		 = true,
		superRun		 = false,
		superDash		 = false,
		superWalk		 = true,
		superIdle		 = true,
		superWait		 = false,
		superCrouch		 = true,
	},
}

for skin, animinfo in pairs(playeraniminfo) do
	PlayerAnimInfo[skin] = animinfo
end

-- Returns if a map object (mo) is valid.
local function valid(mo)
	return mo and mo.valid
end

-- Resets player state, if the player's map object is valid.
local function reset(player)
	if player.mo and player.mo.valid then
		player.lastframe = 0
		player.lastanim = nil
		player.playsound = false
		player.wasfalling = false
		player.variablesset = true
		player.groundtexture = nil
		player.lastgroundtexture = nil
	end
end

-- Utility: Checks if a table contains a given value.
local function has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Returns the ground texture based on the map object's state.
local function getGroundTexture(mo)
	local result = nil

	if mo.eflags & MFE_VERTICALFLIP then
		if mo.ceilingrover then
			result = mo.ceilingrover.bottompic
		elseif mo.standingslope and mo.standingslope == mo.subsector.sector.c_slope then
			result = mo.subsector.sector.ceilingpic
		elseif mo.ceilingz == mo.subsector.sector.ceilingheight then
			result = mo.subsector.sector.ceilingpic
		end
	else
		if mo.floorrover then
			result = mo.floorrover.toppic
		elseif mo.standingslope and mo.standingslope == mo.subsector.sector.f_slope then
			result = mo.subsector.sector.floorpic
		elseif mo.floorz == mo.subsector.sector.floorheight then
			result = mo.subsector.sector.floorpic
		end
	end

	return result
end

local function stripColorTags(text)
	return text:gsub("[%z\128-\143]", "") -- I HATE YOU
end

-- Register the footstep function in the global environment.
rawset(_G, "L_MakeFootstep", function(player, steptype)
	player.groundtexture = getGroundTexture(player.mo)
	if not player.groundtexture and player.lastgroundtexture then
		player.groundtexture = player.lastgroundtexture
	end

	local backupmap = "A"
	local mapTitle = stripColorTags(G_BuildMapTitle(gamemap) or backupmap)
	local lowerMapTitle = string.lower(mapTitle)
	local textureKey = tostring(gamemap) .. " " .. tostring(lowerMapTitle) .. " " .. tostring(player.groundtexture)
	local material = HLFootsteps.flatsounds[textureKey] or HLFootsteps.flatsounds[player.groundtexture]

	if not HLFootsteps.soundinfolist[material] then
		if material == nil then
			CONS_Printf(player,
				"Attempt to index texture " .. tostring(player.groundtexture) .. " in level " ..
				tostring(gamemap) .. " " .. string.lower(tostring(G_BuildMapTitle(gamemap))) ..
				" returned nil! Lmfaooo imagine",
				"...But still. Please report it I need to know"
			)
			CONS_Printf(player, "Flatsounds out of date. Rebuilding...")
			HLFootsteps.flatsounds[player.groundtexture] = "concrete"
		else
			warn(player, "Invalid material '" .. tostring(material) .. "'!")
			CONS_Printf(player, "Flatsounds out of date. Rebuilding...")
			HLFootsteps.flatsounds[HLFootsteps.flatsounds[textureKey] and textureKey or player.groundtexture] = "concrete"
		end
	end

	local sounds = HLFootsteps.soundinfolist[material] and HLFootsteps.soundinfolist[material][steptype]
	if sounds then
		S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
	end
end)

-- Hook into the player thinking cycle.
addHook("PlayerThink", function(player)
	if player.mo and player.mo.state ~= S_PLAY_DEAD and player.mo.skin == "kombifreeman" then
		local panimInfo = PlayerAnimInfo[player.mo.skin]
		if panimInfo then
			if player.variablesset == nil then
				reset(player)
			end

			player.groundtexture = getGroundTexture(player.mo)
			if not player.groundtexture and player.lastgroundtexture then
				player.groundtexture = player.lastgroundtexture
			end

			local material, soundType
			player.playsound = false

			if P_IsObjectOnGround(player.mo) and not (player.pflags & PF_NOCLIP) then
				if not player.wasfalling then
					if player.skidtime == 16 then
						player.playsound = true
						soundType = "skid"
					elseif not player.powers[pw_carry] then
						if player.milnecarry then
							if player.mo.state == S_PLAY_WALK then
								player.playsound = panimInfo.run and (player.powers[pw_super] == 0 or panimInfo.superRun) and
									(has_value(panimInfo.runFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.runFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_FLY or player.mo.state == S_PLAY_SWIM then
								player.playsound = panimInfo.walk and (player.powers[pw_super] == 0 or panimInfo.superWalk) and
									(has_value(panimInfo.walkFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.walkFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_GLIDE_LANDING then
								player.playsound = panimInfo.idle and (player.powers[pw_super] == 0 or panimInfo.superIdle) and
									(player.lastanim ~= player.panim)
							elseif player.mo.state == S_PLAY_FREEMCROUCHMOVE then
								player.playsound = panimInfo.crouch and (player.powers[pw_super] == 0 or panimInfo.superCrouch) and
									(has_value(panimInfo.crouchFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.crouchFrames, player.mo.frame))
							end
						else
							if player.mo.state == S_PLAY_RUN then
								player.playsound = panimInfo.run and (player.powers[pw_super] == 0 or panimInfo.superRun) and
									(has_value(panimInfo.runFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.runFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_DASH then
								player.playsound = panimInfo.dash and (player.powers[pw_super] == 0 or panimInfo.superDash) and
									(has_value(panimInfo.dashFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.dashFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_WALK then
								player.playsound = panimInfo.walk and (player.powers[pw_super] == 0 or panimInfo.superWalk) and
									(has_value(panimInfo.walkFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.walkFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_STND or player.mo.state == S_PLAY_EDGE then
								player.playsound = panimInfo.idle and (player.powers[pw_super] == 0 or panimInfo.superIdle) and
									(player.lastanim ~= player.panim)
							elseif player.milnekick and player.mo.state == S_MILNE_KICK then
								player.playsound = panimInfo.milnekick and
									(has_value(panimInfo.milnekickFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.milnekickFrames, player.mo.frame))
							elseif player.mo.state == S_PLAY_FREEMCROUCHMOVE then
								player.playsound = panimInfo.crouch and (player.powers[pw_super] == 0 or panimInfo.superCrouch) and
									(has_value(panimInfo.crouchFrames, player.mo.frame & FF_FRAMEMASK) or has_value(panimInfo.crouchFrames, player.mo.frame))
							end
						end

						soundType = "steps"
						if player.lastframe == player.mo.frame then
							player.playsound = false
						end
						player.lastframe = player.mo.frame
						player.lastanim = player.panim
					end
				else
					player.wasfalling = false
					player.playsound = true
					soundType = "land"
				end
			else
				if not player.wasfalling and player.mo.state == S_PLAY_JUMP then
					local backupmap = "A"
					local mapTitle = stripColorTags(G_BuildMapTitle(gamemap) or backupmap)
					local lowerMapTitle = string.lower(mapTitle)
					local textureKey = gamemap .. " " .. lowerMapTitle .. " " .. player.groundtexture
					local mat = HLFootsteps.flatsounds[textureKey] or HLFootsteps.flatsounds[player.groundtexture]
					if not HLFootsteps.soundinfolist[mat] then
						warn(player, "Invalid material " .. tostring(mat) .. "!")
					end

					local jumpType = "jump"
					local sounds = HLFootsteps.soundinfolist[mat] and HLFootsteps.soundinfolist[mat][jumpType]
					if sounds then
						S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
					end
				end
				player.wasfalling = true
			end

			if player.playsound then
				local backupmap = "A"
				local mapTitle = stripColorTags(G_BuildMapTitle(gamemap) or backupmap)
				local lowerMapTitle = string.lower(mapTitle)
				local textureKey = gamemap .. " " .. lowerMapTitle .. " " .. tostring(player.groundtexture)
				local mat = HLFootsteps.flatsounds[textureKey] or HLFootsteps.flatsounds[player.groundtexture]

				if not (player.mo.eflags & MFE_GOOWATER) then
					if player.groundtexture and mat then
						material = mat
					else
						if not mat then
							CONS_Printf(player,
								"Attempt to index texture " .. tostring(player.groundtexture) .. " in level " ..
								tostring(gamemap) .. " " .. string.lower(tostring(G_BuildMapTitle(gamemap))) ..
								" returned nil! Lmfaooo imagine",
								"...But still. Please report it I need to know"
							)
							CONS_Printf(player, "Flatsounds out of date. Rebuilding...")
							HLFootsteps.flatsounds[player.groundtexture] = "concrete"
						end
						material = "concrete"
					end
				end

				if (cv_hldebug.value & DEBUG_FOOTSTEP) ~= 0 then
					CONS_Printf(player,
						"indexing texture " .. player.groundtexture .. " in level " ..
						gamemap .. " " .. string.lower(G_BuildMapTitle(gamemap)) ..
						", which is returning " .. tostring(material) .. "..."
					)
				end

				if (player.mo.eflags & MFE_TOUCHLAVA) ~= 0 then
					local sounds = HLFootsteps.soundinfolist.lava[soundType]
					if sounds then
						S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
					end
				elseif (player.mo.eflags & MFE_TOUCHWATER) ~= 0 or (player.mo.eflags & MFE_GOOWATER) ~= 0 then
					local sounds = HLFootsteps.soundinfolist.water[soundType]
					if sounds then
						S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
					end
				else
					if material then
						player.lastgroundtexture = player.groundtexture
						if not HLFootsteps.soundinfolist[material] then
							warn(player, "Invalid material " .. material .. "!")
						end
						local sounds = HLFootsteps.soundinfolist[material] and HLFootsteps.soundinfolist[material][soundType]
						if sounds then
							S_StartSound(player.mo, sounds[P_RandomKey(#sounds) + 1])
						end
					end
				end
			end
		end
	end
end)