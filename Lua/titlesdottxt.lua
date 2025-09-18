local SECUNIT = 1000 -- better deals with 0.4

-- Helper function: converts a numeric string into a fixed-point integer.
-- It always checks for a decimal point. If none is found, the value is treated as whole.
local function parseFixed(numstr)
    if string.find(numstr, "%.") then
        -- Split into integer and fractional parts
        local intPart = tonumber(string.match(numstr, "^(.-)%.")) or 0
        local fracPartStr = string.match(numstr, "%.(.*)$") or "0"
        local fracPart = tonumber(fracPartStr) or 0
        local divisor = 10 ^ (#fracPartStr)
        return intPart * SECUNIT + (fracPart * SECUNIT) / divisor
    else
        return tonumber(numstr) * SECUNIT
    end
end

-- Main function: converts a time string (formats like "1.5", "2:30", "9:59:59.99", etc.)
-- into a tic count based on TICRATE.
local function timeToTics(timeStr)
    local totalFixedSeconds = 0
    local parts = {}

    -- Split the string on ':' (supports H:M:S, M:S, or just seconds)
    for part in string.gmatch(timeStr, "[^:]+") do
        table.insert(parts, part)
    end

    if #parts > 1 then
        -- Process seconds (always using parseFixed to check for decimals)
        local secondsFixed = parseFixed(parts[#parts])
        totalFixedSeconds = totalFixedSeconds + secondsFixed

        if #parts >= 2 then
            -- Process minutes: if a dot is found, handle it as a fractional minute; otherwise treat as whole.
            local minutesFixed = parseFixed(parts[#parts - 1])
            totalFixedSeconds = totalFixedSeconds + minutesFixed * 60
        end

        if #parts >= 3 then
            -- Process hours similarly.
            local hoursFixed = parseFixed(parts[#parts - 2])
            totalFixedSeconds = totalFixedSeconds + hoursFixed * 3600
        end
    else
        -- If there's no colon, treat the entire string as seconds.
        totalFixedSeconds = parseFixed(timeStr)
    end

    -- Multiply by TICRATE to convert fixed seconds into tics.
    -- Dividing by SECUNIT reverses the fixed-point multiplication.
    return (totalFixedSeconds * TICRATE) / SECUNIT
end

-- Style references for basic compression
local style1 = {
  effect = 2,
  normalcolor = { 100, 100, 100, 255 },
  highlightcolor = { 240, 110, 0, 255 },
  fade_in_t = timeToTics("0.01"),
  fx_lag_t = timeToTics("0.25"),
  hold_t = timeToTics("3.5"),
  fade_out_t = timeToTics("1.5"),
}

local style2 = {
  effect = 1,
  normalcolor = { 128, 128, 128, 255 },
  highlightcolor = { 0, 0, 0, 255 },
  fade_in_t = timeToTics("1.5"),
  fx_lag_t = timeToTics("0.25"),
  hold_t = timeToTics("1.2"),
  fade_out_t = timeToTics("0.5"),
}

local style3 = {
  effect = 0,
  normalcolor = { 128, 128, 128, 255 },
  highlightcolor = { 0, 0, 0, 255 },
  fade_in_t = timeToTics("0.5"),
  fx_lag_t = timeToTics("0.25"),
  hold_t = timeToTics("4"),
  fade_out_t = timeToTics("0.5"),
}

local style4 = {
  effect = 2,
  normalcolor = { 100, 100, 100, 255 },
  highlightcolor = { 240, 110, 0, 255 },
  fade_in_t = timeToTics("0.03"),
  fx_lag_t = timeToTics("0.25"),
  hold_t = timeToTics("9"),
  fade_out_t = timeToTics("1.5"),
}

local style5 = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.01"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("2.0"),
      fade_out_t = timeToTics("0.5"),
    }

local style6 = {
      effect = 0,
      normalcolor = { 180, 180, 180, 255 },
      highlightcolor = { 0, 0, 0, 255 },
      fade_in_t = timeToTics("1.0"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("3.0"),
      fade_out_t = timeToTics("1.5"),
    }

local messages = {
  CR27 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "Black Mesa Research Facility", "Black Mesa, New Mexico" },
    style = style1,
  },
  -- INTRO CREDITS
  CR1 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Ted Backman" },
    style = style2,
  },
  CR2 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "TK Backman" },
    style = style2,
  },
  CR3 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Kelly Bailey" },
    style = style2,
  },
  CR4 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Yahn Bernier" },
    style = style2,
  },
  CR5 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Ken Birdwell" },
    style = style2,
  },
  CR6 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Steve Bond" },
    style = style2,
  },
  CR7 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Dario Casali" },
    style = style2,
  },
  CR8 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "John Cook" },
    style = style2,
  },
  CR9 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Greg Coomer" },
    style = style2,
  },
  CR10 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Wes Cumberland" },
    style = style2,
  },
  CR11 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "John Guthrie" },
    style = style2,
  },
  CR12 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Mona Lisa Guthrie" },
    style = style2,
  },
  CR13 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Mike Harrington" },
    style = style2,
  },
  CR14 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Monica Harrington" },
    style = style2,
  },
  CR15 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Brett Johnson" },
    style = style2,
  },
  CR16 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Chuck Jones" },
    style = style2,
  },
  CR17 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Marc Laidlaw" },
    style = style2,
  },
  CR18 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Karen Laur" },
    style = style2,
  },
  CR19 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Randy Lundeen" },
    style = style2,
  },
  CR20 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Yatsze Mark" },
    style = style2,
  },
  CR21 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Lisa Mennet" },
    style = style2,
  },
  CR22 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Gabe Newell" },
    style = style2,
  },
  CR23 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Dave Riller" },
    style = style2,
  },
  CR24 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Aaron Stackpole" },
    style = style2,
  },
  CR25 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Jay Stelly" },
    style = style2,
  },
  CR26 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Harry Teasley" },
    style = style2,
  },
  CR35 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Steve Theodore" },
    style = style2,
  },
  CR36 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Bill Van Buren" },
    style = style2,
  },
  CR37 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Robin Walker" },
    style = style2,
  },
  CR38 = {
    pos = { x = 32, y = 160 },
    alignment = 0,
    lines = { "Douglas R. Wood" },
    style = style2,
  },
  -- END CREDITS
  VALVEIS = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "Valve is:" },
    style = style3,
  },
  END1 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "Ted Backman", "TK Backman", "Kelly Bailey", "Yahn Bernier", "Ken Birdwell", "Steve Bond", "Dario Casali", "John Cook", "Greg Coomer", "Wes Cumberland" },
    style = style3,
  },
  END2 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "John Guthrie", "Mona Lisa Guthrie", "Mike Harrington", "Monica Harrington", "Brett Johnson", "Chuck Jones", "Marc Laidlaw", "Karen Laur", "Randy Lundeen", "Yatsze Mark" },
    style = style3,
  },
  END3 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "Lisa Mennet", "Gabe Newell", "Dave Riller", "Aaron Stackpole", "Jay Stelly", "Harry Teasley", "Steve Theodore", "Bill Van Buren", "Robin Walker", "Douglas R. Wood" },
    style = style3,
  },
  -- INTRO TITLES
  CR28 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:", "Gordon Freeman", "Male, age 27" },
    style = style1,
  },
  CR29 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "EDUCATION:", "Ph.D., MIT, Theoretical Physics" },
    style = style1,
  },
  CR30 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "POSITION:", "Research Associate" },
    style = style1,
  },
  CR31 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "ASSIGNMENT:", "Anomalous Materials Laboratory" },
    style = style1,
  },
  CR32 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "CLEARANCE:", "Level 3" },
    style = style1,
  },
  CR33 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "ADMINISTRATIVE SPONSOR:", "Classified" },
    style = style1,
  },
  CR34 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "DISASTER RESPONSE PRIORITY:", "Discretionary" },
    style = style1,
  },
  GAMEOVER = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:  FREEMAN", "STATUS:  EVALUATION TERMINATED", "POSTMORTEM:", "Subject failed to effectively utilize", "human assets in achievement of goal." },
    style = style4,
  },
  TRAITOR = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:  FREEMAN", "STATUS:  HIRED", "AWAITING ASSIGNMENT" },
    style = style4,
  },
  LOSER = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:  FREEMAN", "STATUS:  OBSERVATION TERMINATED", "POSTMORTEM:", "Subject declined offer of employment." },
    style = style4,
  },
  GAMEOVERALT = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:  FREEMAN", "STATUS:  ASSIGNMENT TERMINATED", "POSTMORTEM:", "Subject demonstrated exceedingly poor judgement." },
    style = style4,
  },
  -- CHAPTER TITLES
  T0A0TITLE = {
    pos = { x = "center", y = 80 },
    alignment = 0,
    lines = { "HAZARD COURSE" },
    style = style1,
  },
  C0A0TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "BLACK MESA INBOUND" },
    style = style1,
  },
  OPENTITLE3 = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  OPENTITLE4 = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  C0A1TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "ANOMALOUS MATERIALS" },
    style = style1,
  },
  C1A1TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "UNFORESEEN CONSEQUENCES" },
    style = style1,
  },
  C1A2TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "OFFICE COMPLEX" },
    style = style1,
  },
  C1A3TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "\"WE'VE GOT HOSTILES\"" },
    style = style1,
  },
  C1A4TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "BLAST PIT" },
    style = style1,
  },
  C2A1TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "POWER UP" },
    style = style1,
  },
  C2A2TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "ON A RAIL" },
    style = style1,
  },
  C2A3TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "APPREHENSION" },
    style = style1,
  },
  C2A4TITLE1 = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "RESIDUE PROCESSING" },
    style = style1,
  },
  C2A4TITLE2 = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "QUESTIONABLE ETHICS" },
    style = style1,
  },
  C2A5TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "SURFACE TENSION" },
    style = style1,
  },
  C3A1TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "\"FORGET ABOUT FREEMAN!\"" },
    style = style1,
  },
  C3A2TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "LAMBDA CORE" },
    style = style1,
  },
  C4A1TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "XEN" },
    style = style1,
  },
  C4A1ATITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "INTERLOPER" },
    style = style1,
  },
  C4A1BTITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  C4A1CTITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  C4A1ETITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  C4A1FTITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = style1,
  },
  C4A2TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "GONARCH'S LAIR" },
    style = style1,
  },
  C4A3TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "NIHILANTH" },
    style = style1,
  },
  C5TITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "ENDGAME" },
    style = style1,
  },
  -- In-Game messages
  GAMESAVED = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "Saved..." },
    style = style5,
  },
  -- Game title
  GAMETITLE = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "Half-Life" },
    style = style6,
  },
  -- HAZARD COURSE TEXT
  HZBUTTON1 = {
    pos = { x = "center", y = 60 },
    alignment = 0,
    lines = { "PRESS ${+use} TO PUSH A BUTTON" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZBUTTON2 = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+use} TO PUSH A BUTTON" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZMOVE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "MOVE FORWARD BY PRESSING ${+forward}", "MOVE BACKWARD BY PRESSING ${+back}", "MOVE LEFT BY PRESSING ${+moveleft}", "MOVE RIGHT BY PRESSING ${+moveright}" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZJUMP = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} TO RUN FORWARD", "PRESS JUMP KEY TO JUMP" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZDUCK = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} TO RUN FORWARD", "PRESS ${+duck} TO DUCK", "PRESS ${+forward} + ${+duck} TOGETHER", "TO MOVE IN STEALTH MODE" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZCOMBO = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} TO RUN FORWARD", "PRESS ${+jump} TO JUMP", "PRESS ${+duck} TO DUCK", "PRESS ${+jump} TO JUMP" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZDUCKJUMP = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} + ${+jump} TOGETHER,", "THEN ${+duck}" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZLADDER = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} TO MOVE UP LADDERS", "PRESS ${+back} TO MOVE DOWN LADDERS" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZLJUMP = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "WHILE MOVING FORWARD,", "HOLD DOWN ${+duck}--", "THEN PRESS ${+jump}" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZLMOD = {
    pos = { x = "center", y = 60 },
    alignment = 0,
    lines = { "BE SURE YOU PICKED UP THE LONG-JUMP MODULE", "AT THE BEGINNING OF THE OBSTACLE" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZMEDKIT = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "USE MED-KITS BY HOLDING DOWN ${+use}", "HOLD DOWN ${+use} UNTIL HEALTH IS", "AT 100 OR KIT IS DEPLETED" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZMOMENT = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "ACTIVATE WHEELS AND DIALS", "BY HOLDING DOWN ${+use}", "HOLD ${+use} UNTIL BRIDGE IS IN POSITION" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZPUSH = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+forward} TO MOVE AGAINST BOX", "KEEP PRESSING FORWARD TO PUSH BOX" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZPULL = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+use} + ${+back} TOGETHER", "TO PULL BOX BACKWARD" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZCROWBAR = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "MOVE UP TO CROWBAR", "PRESS ${+attack} TO BREAK OBJECTS" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZLITEON = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${impulse 100}", "TO TURN FLASHLIGHT ON" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZLITEOFF = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${impulse 100} AGAIN", "TO TURN FLASHLIGHT OFF" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZWEAPON = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "MOVE UP TO WEAPON TO PICK IT UP" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZFIREWEAP = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS ${+attack} FOR PRIMARY ATTACK", "PRESS ${+attack2} FOR ALTERNATE ATTACK", "PRESS ${+reload} TO RELOAD AT WILL" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZARMOR = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS AND HOLD ${+use}", "HOLD DOWN UNTIL SUIT ARMOR IS CHARGED", "OR CHARGER IS DEPLETED" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZSWIM = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS YOUR FORWARD KEY", "AIM WITH THE MOUSE AS YOU SWIM", "FIND AIR IF YOU BEGIN TO LOSE HEALTH", "WAIT IN THE AIR UNTIL HEALTH", "RETURNS TO FORMER LEVEL" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZDAMAGE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "CERTAIN TYPES OF DAMAGE WILL REGISTER", "ON YOUR HEADS-UP DISPLAY.", "DIRECTION OF DAMAGE IS INDICATED BY RED", "FLASHES IN THE CENTER OF YOUR SCREEN" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZHAZARD = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "RADIATION HAZARDS", "ACTIVATE A GEIGER COUNTER" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZSCIENTIST = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "APPROACH SCIENTIST", "PRESS USE KEY TO RECEIVE HEALTH FROM SCIENTIST" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZBARNEY = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "APPROACH SECURITY GUARD", "PRESS YOUR USE KEY TO GET HIS HELP", "WALK TOWARD DOOR AND GUARD", "WILL ACTIVATE BUTTONS" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZTRAIN = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "PRESS USE KEY TO ENGAGE TRAIN", "PRESS FORWARD KEY TO ACCELERATE", "PRESS BACKWARD KEY TO DECELERATE", "PRESS USE KEY AGAIN TO DISENGAGE" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  HZDONE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "CONGRATULATIONS!", "YOU HAVE COMPLETED", "THE BLACK MESA HAZARD COURSE.", "COME BACK ANY TIME." },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.005"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  -- DEMO CHAPTER TITLES
  UPLINK = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = {  },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 0, 200, 50, 255 },
      fade_in_t = timeToTics("0.01"),
      fx_lag_t = timeToTics("0.5"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  -- DEMO INTRO TEXT
  -- FROM INTRO TITLES
  DEMOTXT1 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "SUBJECT:", "GORDON FREEMAN, Ph.D." },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  DEMOTXT2 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "CURRENT LOCATION:", "LAMBDA REACTOR COMPLEX", "BLACK MESA RESEARCH FACILITY" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  DEMOTXT3 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "TIME:", "CONTAINMENT FAILURE + 48.00 HRS" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  DEMOTXT4 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "STATUS:", "EVALUATION IN PROGRESS" },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("3.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  DEMOTXT6 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "CURRENT EVALUATION:", "UPLINK COMPLETED." },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("7.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  DEMOTXT7 = {
    pos = { x = "center", y = "center" },
    alignment = 0,
    lines = { "REQUIRE FURTHER DATA." },
    style = {
      effect = 2,
      normalcolor = { 100, 100, 100, 255 },
      highlightcolor = { 240, 110, 0, 255 },
      fade_in_t = timeToTics("0.02"),
      fx_lag_t = timeToTics("0.25"),
      hold_t = timeToTics("7.5"),
      fade_out_t = timeToTics("1.5"),
    },
  },
  SILVERHORNTITLE = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "MINDSCAPE" },
    style = style1,
  },
  CCHARNAG = {
    pos = { x = "center", y = 130 },
    alignment = 0,
    lines = { "REMEMBER TO CHECK hl_ohthatsgoreofmy", "IF YOU DO NOT WANT TO SEE GORE OF", "MY COMFORT CHARACTER (FANG)" },
    style = style1,
  },
}

local cacheShit = {
	clrs = {},
	font = {}
}

local font = "HLTTL"

local function initFontCache(v)
    for i = 0, 255 do  -- ASCII range
        local char = string.char(i)
        local patchName = font .. i
        local patch = v.cachePatch(patchName)
        cacheShit.font[char] = {
            width = patch.width * FRACUNIT / 2,
            name = patchName
        }
    end
    cacheShit.font[" "] = { width = 4 * FRACUNIT, name = nil }  -- Special handling for space
end

local function calculateDisappearTime(msg)
    if msg.effect == "typewriter" then
        local total_letters = type(msg.text) == "string" and #msg.text or 
                            #table.concat(msg.text, "")
        return (total_letters - 1) * msg.appear_time + msg.fx_time + msg.hold_time + msg.fade_out_time
    else -- fade or flicker
        return msg.appear_time + msg.hold_time + msg.fade_out_time
    end
end

rawset(_G, "convertToHLMessage", function(player, sourceMsgKey)
    -- Get the actual message table from the messages table
    local sourceMsg = messages[sourceMsgKey]
    if not sourceMsg then
        error("Message not found in messages table: " .. tostring(sourceMsgKey))
    end

    local effectMap = {
        [0] = "fade",
        [1] = "flicker",
        [2] = "typewriter"
    }

    -- Resolve position
    local x = sourceMsg.pos.x == "center" and 160 or tonumber(sourceMsg.pos.x) or 0
    local y = sourceMsg.pos.y == "center" and 100 or tonumber(sourceMsg.pos.y) or 0
    local alignment = sourceMsg.alignment

    local normal_color = sourceMsg.style.normalcolor
    local highlight_color = sourceMsg.style.highlightcolor

	-- Map of command strings to game control constants
	local commandToGC = {
		["+forward"] = GC_FORWARD,
		["+back"] = GC_BACKWARD,
		["+moveleft"] = GC_STRAFELEFT,
		["+moveright"] = GC_STRAFERIGHT,
		["+jump"] = GC_JUMP,
		["+attack"] = GC_FIRE,
	}

	-- Helper to determine if a key is a button bind
	local function isButtonBind(keyname)
		for i = 0, NUM_GAMECONTROLS - 1 do
			if input.keyNumToName(input.gameControlToKeyNum(i)) == keyname then
				return true
			end
		end
		return false
	end

	-- Replaces `${command}` with actual key bound to the command
	local function resolveBinds(line)
		return (line:gsub("%${(.-)}", function(command)
			-- Check user-defined binds
			for key, bind in pairs(player.keyBinds or {}) do
				if bind == command then
					return string.upper(key)
				end
			end

			-- If unbound, try to fall back using GC_ mapping
			local gc = commandToGC[command]
			if gc then
				local keynum = input.gameControlToKeyNum(gc)
				local keyname = input.keyNumToName(keynum)
				if keyname and isButtonBind(keyname) then
					return string.upper(keyname)
				end
			end

			return "<UNBOUND>" -- Still couldn't resolve
		end))
	end

    local lines = {}
    if #sourceMsg.lines == 1 then
        lines = resolveBinds(sourceMsg.lines[1])
    else
        for _, line in ipairs(sourceMsg.lines) do
            table.insert(lines, resolveBinds(line))
        end
    end

    local message = {
        position = {x = x, y = y},
        alignment = alignment,
        text = lines,
        highlight_color = highlight_color,
        normal_color = normal_color,
        fx_time = sourceMsg.style.fx_lag_t,
        hold_time = sourceMsg.style.hold_t,
        fade_out_time = sourceMsg.style.fade_out_t,
        appear_time = sourceMsg.style.fade_in_t or 1,
        effect = effectMap[sourceMsg.style.effect] or "fade",
        clock = 0,
        source_key = sourceMsgKey
    }

    message.disappear_time = calculateDisappearTime(message)

    return message
end)

hud.add(function(v, player)
    if not player.hl or not player.hl.messages then return end

    local messages = player.hl.messages

	if not next(cacheShit.font) then initFontCache(v) end

	-- Helper function to get palette index from RGB with opacity
	local function getPaletteWithOpacity(rgb, opacity)
		local key = (rgb[1] << 16) | (rgb[2] << 8) | rgb[3] | (opacity << 24)
		if not cacheShit.clrs[key] then
			local r = (rgb[1] * opacity) / FRACUNIT
			local g = (rgb[2] * opacity) / FRACUNIT
			local b = (rgb[3] * opacity) / FRACUNIT
			cacheShit.clrs[key] = color.rgbToPalette(r, g, b)
		end
		return cacheShit.clrs[key]
	end

    for _, msg in ipairs(messages) do
        local lines = type(msg.text) == "string" and {msg.text} or msg.text
        local total_letters = 0
        
        -- Calculate total width of each line
		local line_widths = {}
		local max_width = 0
		for _, line in ipairs(lines) do
			local line_width = 0
			for char_pos = 1, #line do
				local char = line:sub(char_pos, char_pos)
				local fontData = cacheShit.font[char]
				line_width = line_width + fontData.width
			end
			line_widths[#line_widths + 1] = line_width
			if line_width > max_width then
				max_width = line_width
			end
			total_letters = total_letters + #line
		end

        local t = msg.clock
        local flags = msg.alignment | V_ADD
        local current_y = msg.position.y * FRACUNIT - (#lines * 9 * FRACUNIT) / 2  -- Center vertically based on line count
        
        -- Calculate overall opacity
        local overall_opacity = FRACUNIT
        if msg.effect == "typewriter" then
            local fade_out_start = (total_letters - 1) * msg.appear_time + msg.fx_time + msg.hold_time
            if t >= fade_out_start then
                local fade_progress = t - fade_out_start
                if fade_progress >= msg.fade_out_time then
                    overall_opacity = 0
                else
                    overall_opacity = FRACUNIT - (fade_progress * FRACUNIT) / msg.fade_out_time
                end
            end
        else  -- fade or flicker
            if t < msg.appear_time then
                overall_opacity = (t * FRACUNIT) / msg.appear_time
            elseif t < msg.appear_time + msg.hold_time then
                overall_opacity = FRACUNIT
            else
                local fade_start = msg.appear_time + msg.hold_time
                local fade_progress = t - fade_start
                if fade_progress >= msg.fade_out_time then
                    overall_opacity = 0
                else
                    overall_opacity = FRACUNIT - (fade_progress * FRACUNIT) / msg.fade_out_time
                end
            end
        end

        -- Skip rendering if completely transparent
        if overall_opacity <= 0 then continue end

        -- Precompute flicker color if needed
        local flicker_color
        if msg.effect == "flicker" and overall_opacity > 0 then
            local weight = v.RandomFixed()
            local r = (msg.highlight_color[1] * weight + msg.normal_color[1] * (FRACUNIT - weight)) / FRACUNIT
            local g = (msg.highlight_color[2] * weight + msg.normal_color[2] * (FRACUNIT - weight)) / FRACUNIT
            local b = (msg.highlight_color[3] * weight + msg.normal_color[3] * (FRACUNIT - weight)) / FRACUNIT
            flicker_color = {r, g, b}
        end

        local letter_index = 1
        for line_num, line in ipairs(lines) do
            local current_x = -line_widths[line_num] / 2  -- Center horizontally for this line
            
            for char_pos = 1, #line do
                local char = line:sub(char_pos, char_pos)
                if char == " " then current_x = $ + 4 * FRACUNIT continue end
				local fontData = cacheShit.font[char]
                local char_code = string.byte(char)
                local patch_name = font .. char_code
                local patch = v.cachePatch(patch_name)
                
                -- Typewriter letter timing
                if msg.effect == "typewriter" then
                    local appear_time = (letter_index - 1) * msg.appear_time
                    if t >= appear_time then
                        local color_to_use = {0, 0, 0}  -- Start with black
                        local hilighttime = msg.fx_time + 1

                        if t < appear_time + hilighttime then
                            -- Interpolate between highlight and normal during fx_time
                            local progress = t - appear_time
                            local lerp_factor = (progress * FRACUNIT) / hilighttime
                            local inv_factor = FRACUNIT - lerp_factor
                            
                            color_to_use[1] = (msg.highlight_color[1] * inv_factor + msg.normal_color[1] * lerp_factor) / FRACUNIT
                            color_to_use[2] = (msg.highlight_color[2] * inv_factor + msg.normal_color[2] * lerp_factor) / FRACUNIT
                            color_to_use[3] = (msg.highlight_color[3] * inv_factor + msg.normal_color[3] * lerp_factor) / FRACUNIT
                        else
                            -- After fx_time, use normal color
                            color_to_use = msg.normal_color
                        end
                        
                        local palette_idx = getPaletteWithOpacity(color_to_use, overall_opacity)
                        local colormap = v.getColormap(nil, nil, "TEXTSCALECLR" .. palette_idx)
                        v.drawScaled((msg.position.x * FRACUNIT) + current_x, current_y, FRACUNIT/2, patch, flags, colormap)
                    end
                else  -- fade or flicker
                    local palette_idx
                    if msg.effect == "fade" then
                        palette_idx = getPaletteWithOpacity(msg.normal_color, overall_opacity)
                    else  -- flicker
                        palette_idx = getPaletteWithOpacity(flicker_color, overall_opacity)
                    end
                    local colormap = v.getColormap(nil, nil, "TEXTSCALECLR" .. palette_idx)
                    v.drawScaled((msg.position.x * FRACUNIT) + current_x, current_y, FRACUNIT/2, patch, flags, colormap)
                end
                
                current_x = $ + fontData.width
                letter_index = letter_index + 1
            end
            
            current_y = $ + 9 * FRACUNIT  -- Move to next line
        end
    end
end, "game")

COM_AddCommand("hl_titletest", function(player, message)
	if gamestate ~= GS_LEVEL then
		CONS_Printf(player, "Can't do that right now.")
		return
	end
	local message = convertToHLMessage(player, message)
	if message then
		player.hl = $ or {}
		player.hl.messages = $ or {}
		table.insert(player.hl.messages, message)
	end
end)