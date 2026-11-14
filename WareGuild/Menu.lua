local WG = SDC_WareGuild
local LAM = LibAddonMenu2

---------------------
----Tool Function----
---------------------
--Transient menu state of each of the five guild bank slots. Only the
--guild index differs between the five sections, so the controls are
--built by GuildSelector/GuildRules below instead of being copied.
--Item: selected item link; Material: selected store type; Fuzzy;
--TakeTo/StoreTo: slider values; Line: selected rule line.
local GuildState = {}
for GuildIndex = 1, 5 do
  GuildState[GuildIndex] = {Item = nil, Material = nil, Fuzzy = false,
    TakeTo = 0, StoreTo = 0, Line = 1}
end
local ClipGuild, ClipSteps = false, {}
-- local function KnowledgeDepositButton(GuildIndex)
  -- return {
    -- type = "button",
    -- name = WG.Lang.GUILD_STORE_UNKNOWN,
    -- tooltip = WG.Lang.GUILD_STORE_UNKNOWN_TOOLTIP,
    -- disabled = function() return not WG.HasCharacterKnowledge() end,
    -- func = function()
      -- local GuildId = WG.SV.Guild[GuildIndex]
      -- if not GuildId or not WG.HasCharacterKnowledge() then return end
      -- local Rules = WG.SV["Guild" .. GuildIndex]
      -- for _, Rule in ipairs(Rules) do
        -- if Rule.Type == WAREGUILD_STORE_UNKNOWN then return end
      -- end
      -- table.insert(Rules, {GuildId = GuildId, Type = WAREGUILD_STORE_UNKNOWN})
    -- end,
    -- width = "full",
  -- }
-- end
local MaterialChoices = {
  "/", 
  WG.Lang.BLACKSMITH, 
  WG.Lang.CLOTH, 
  WG.Lang.WOOD, 
  WG.Lang.JEWELRY, 
  WG.Lang.COOK, 
  WG.Lang.ENCHANT, 
  WG.Lang.ALCHEMY, 
  WG.Lang.STYLE, 
  WG.Lang.TRAIT,
}
local MaterialChoicesValue = {
  "/", 
  WAREGUILD_STORE_B,
  WAREGUILD_STORE_C,
  WAREGUILD_STORE_W,
  WAREGUILD_STORE_J,
  WAREGUILD_STORE_P,
  WAREGUILD_STORE_E,
  WAREGUILD_STORE_A,
  WAREGUILD_STORE_S,
  WAREGUILD_STORE_T,
}

--List of Guilds
local function GuildList()
  local Name = {"/", }
  local Id = {false, }
  for i = 1, 5 do
    local Tep = GetGuildId(i)
    if Tep ~= 0 then
      table.insert(Id, Tep)
      table.insert(Name, GetGuildName(Tep))
    end
  end
  return Name, Id
end

--List of Items
local function ItemList()
  local Link = {"/", }
  local Repeat = {}
  local Sort = {}
  for i = 0, GetBagSize(1) - 1 do
    local Tep = GetItemLink(1, i)
    if Tep ~= "" then
      if not Repeat[Tep] then
        table.insert(Sort, {Tep, GetItemLinkDisplayQuality(Tep),
          LocaleAwareToLower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(Tep)))})
        Repeat[Tep] = true
      end
    end
  end
  table.sort(Sort, 
    function(a, b)
      if a[2] ~= b[2] then return a[2] < b[2] end
      if a[3] ~= b[3] then return a[3] < b[3] end
      return a[1] < b[1]
    end
  )
  for i = 1, #Sort do
    table.insert(Link, Sort[i][1])
  end
  return Link
end

--Display of Rules
local function Desc(RuleTable)
  local String = ""
  for i = 1, #RuleTable do
    String = String..string.format("%03d", i).." "..WG.StepToString(RuleTable[i]).."\r\n"
  end
  return String
end

--Copy Steps
local function CopySteps(GuildId, StepsTable)
  local Tep = {}
  for i = 1, #StepsTable do
    local Step = {
        ["GuildId"] = GuildId,
        ["Type"] = StepsTable[i]["Type"],
        ["ItemId"] = StepsTable[i]["ItemId"],
        ["ItemLink"] = StepsTable[i]["ItemLink"],
        ["Count"] = StepsTable[i]["Count"],
      }
    table.insert(Tep, Step)
  end
  return Tep
end

--Insert one rule (step) into the rule list of guild bank GuildIndex.
local function InsertStep(GuildIndex, Step)
  Step["GuildId"] = WG.SV.Guild[GuildIndex]
  table.insert(WG.SV["Guild" .. GuildIndex], Step)
end

--One item rule (step) built from the menu state: fuzzy rules match the
--ItemId, plain rules keep the whole item link. Count is optional.
local function ItemStep(GuildIndex, State, RuleType, Count)
  local Step = {["Type"] = RuleType}
  if Count then Step["Count"] = Count end
  if State.Fuzzy then
    Step["ItemId"] = GetItemLinkItemId(State.Item)
  else
    Step["ItemLink"] = State.Item
  end
  return InsertStep(GuildIndex, Step)
end

--Dropdown assigning a guild to guild bank slot GuildIndex. Changing the
--guild empties the rule list, as before.
local function GuildSelector(GuildIndex)
  return {
    type = "dropdown",
    name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER) .. " " .. GuildIndex,
    choices = GuildList(),
    choicesValues = select(2, GuildList()),
    scrollable = true,
    getFunc = function() if WG.SV.Guild[GuildIndex] then return WG.SV.Guild[GuildIndex] else return false end end,
    setFunc = function(var)
      if WG.SV.Guild[GuildIndex] ~= var then
        WG.SV.Guild[GuildIndex] = var
        WG.SV["Guild" .. GuildIndex] = {}
      end
    end,
    width = "full",
  }
end

--Submenu with the deposit/withdraw rules of guild bank GuildIndex:
--item selection, fuzzy toggle, withdraw/store (all or up to a count),
--craft materials, daily writs, and the rule list editor. Identical for
--the five guilds; only the index (and the saved rule list) differs.
local function GuildRules(GuildIndex)
  local State = GuildState[GuildIndex]
  return {
    type = "submenu",
    name = function() return GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER) .. " " .. GuildIndex .. " > " .. GetGuildName(WG.SV.Guild[GuildIndex] or 0) end,
    disabled = function() if WG.SV.Guild[GuildIndex] then return false else return true end end,
    controls = {
      { --Item Scroll
      type = "dropdown",
      name = WG.Lang.GUILD_ITEM_SCROLL,
      choices = ItemList(),
      scrollable = true,
      getFunc = function() if State.Item then return State.Item else return "/" end end,
      setFunc = function(var)
        if var ~= "/" then
          State.Item = var
        else
          State.Item = nil
        end
      end,
      reference = "WG_Guild_" .. GuildIndex .. "_Item",
      width = "full",
      },
      { --Fuzzy
      type = "checkbox",
      name = WG.Lang.GUILD_FUZZY,
      tooltip = WG.Lang.GUILD_FUZZY_TOOLTIP,
      getFunc = function() return State.Fuzzy end,
      setFunc = function(var) State.Fuzzy = var end,
      width = "half",
      },
      {
    type = "button",
    name = WG.Lang.GUILD_STORE_UNKNOWN,
    tooltip = WG.Lang.GUILD_STORE_UNKNOWN_TOOLTIP,
    disabled = function() return not WG.HasCharacterKnowledge() end,
    func = function()
      -- local GuildId = WG.SV.Guild[GuildIndex]
      if not WG.HasCharacterKnowledge() then return end
      -- local Rules = WG.SV["Guild" .. GuildIndex]
      -- for _, Rule in ipairs(Rules) do
        -- if Rule.Type == WAREGUILD_STORE_UNKNOWN then return end
      -- end
      InsertStep(GuildIndex, {["Type"] = WAREGUILD_STORE_UNKNOWN})
      --table.insert(Rules, {GuildId = GuildId, Type = WAREGUILD_STORE_UNKNOWN})
    end,
    width = "half",
  },
      { --Withdraw every bank item unknown to the active character.
    type = "button",
    name = WG.Lang.GUILD_TAKE_UNKNOWN,
    tooltip = WG.Lang.GUILD_TAKE_UNKNOWN_TOOLTIP,
    disabled = function() return not WG.HasCharacterKnowledge() end,
    func = function()
      if not WG.HasCharacterKnowledge() then return end
      InsertStep(GuildIndex, {["Type"] = WAREGUILD_TAKE_UNKNOWN})
    end,
    width = "half",
  },
      { --UpdateList
      type = "button",
      name = WG.Lang.GUILD_UPDATE_ITEM_LIST,
      func = function()
        State.Item = nil
        local Control = _G["WG_Guild_" .. GuildIndex .. "_Item"]
        Control.data.choices = ItemList()
        Control:UpdateChoices()
      end,
      width = "half",
      },
      { --Withdraw all
      type = "button",
      name = WG.Lang.GUILD_TAKE_ALL,
      func = function()
        if not State.Item then return end
        ItemStep(GuildIndex, State, WAREGUILD_TAKE_ALL)
      end,
      width = "half",
      },
      { --Store All
      type = "button",
      name = WG.Lang.GUILD_STORE_ALL,
      func = function()
        if not State.Item then return end
        ItemStep(GuildIndex, State, WAREGUILD_STORE_ALL)
      end,
      width = "half",
      },
      { --TakeTo
      type = "slider",
      name = WG.Lang.GUILD_TAKE_TO_SLIDER,
      getFunc = function() return 0 end,
      setFunc = function(var) State.TakeTo = var end,
      min = 0,
      max = 10000,
      step = 1,
      width = "half",
      },
      {
      type = "button",
      name = WG.Lang.GUILD_TAKE_TO,
      func = function()
        if not State.Item then return end
        ItemStep(GuildIndex, State, WAREGUILD_TAKE_TO, State.TakeTo)
      end,
      width = "half",
      },
      { --StoreTo
      type = "slider",
      name = WG.Lang.GUILD_STORE_TO_SLIDER,
      getFunc = function() return 0 end,
      setFunc = function(var) State.StoreTo = var end,
      min = 0,
      max = 10000,
      step = 1,
      width = "half",
      },
      {
      type = "button",
      name = WG.Lang.GUILD_STORE_TO,
      func = function()
        if not State.Item then return end
        ItemStep(GuildIndex, State, WAREGUILD_STORE_TO, State.StoreTo)
      end,
      width = "half",
      },
      {
      type = "header",
      name = GetString(SI_FURNITURETHEMETYPE1),
      },
      { --Store Craft Materials
      type = "dropdown",
      name = WG.Lang.GUILD_STORE_ALL_TYPE_DROP,
      choices = MaterialChoices,
      choicesValues = MaterialChoicesValue,
      scrollable = true,
      getFunc = function() return "/" end,
      setFunc = function(var)
        if var ~= "/" then
          State.Material = var
        else
          State.Material = nil
        end
      end,
      width = "full",
      },
      { --Withdraw for Daily Writs
      type = "button",
      name = WG.Lang.GUILD_TAKE_WRITS,
      tooltip = WG.Lang.GUILD_TAKE_WRITS_TOOLTIP,
      func = function()
        InsertStep(GuildIndex, {["Type"] = WAREGUILD_DAILY})
      end,
      width = "half",
      },
      {
      type = "button",
      name = WG.Lang.GUILD_STORE_ALL_TYPE,
      func = function()
        if not State.Material then return end
        InsertStep(GuildIndex, {["Type"] = State.Material})
      end,
      width = "half",
      },
      {
      type = "header",
      name = WG.Lang.GUILD_HEADER_STEPS,
      },
      { --Rules Display
      type = "description",
      title = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER) .. " " .. GuildIndex .. " > ",
      text = function() return Desc(WG.SV["Guild" .. GuildIndex]) end,
      width = "full",
      enableLinks = true,
      },
      { --Which Line
      type = "slider",
      name = WG.Lang.GUILD_STEPS_SLIDER,
      getFunc = function() return 1 end,
      setFunc = function(var) State.Line = var end,
      min = 1,
      max = 1000,
      step = 1,
      width = "full",
      },
      { --Empty Rule
      type = "button",
      name = WG.Lang.GUILD_STEPS_EMPTY,
      func = function()
        WG.SV["Guild" .. GuildIndex] = {}
      end,
      width = "half",
      },
      { --Delete Rule
      type = "button",
      name = WG.Lang.GUILD_STEPS_DELETE,
      func = function()
        table.remove(WG.SV["Guild" .. GuildIndex], State.Line)
      end,
      width = "half",
      },
    },
  }
end

------------
----Menu----
------------

function WG.BuildMenu()
  local panelData = {
    type = "panel",
    name = WG.name,
    displayName = WG.title,
    author = WG.author,
    version = WG.version,
    registerForRefresh = true,
	}
	LAM:RegisterAddonPanel(WG.name.."_Options", panelData)
  local options = {
    { --Account/Character setting
		type = "checkbox",
		name = WG.Lang.SETTING_CHARACTER_CONFIG,
    tooltip = WG.Lang.SETTING_CHARACTER_CONFIG_TOOLTIP,
		getFunc = function() return WG.CV.CV end,
		setFunc = function(var)
      WG.CV.CV = var
      WG.SwitchSV()
    end,
    width = "full",
    },
  --Setting
    {
    type = "header",
    name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1305),
		},
    { --Auto Open When Need Store
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_OPEN_STORE,
    tooltip = WG.Lang.SETTING_AUTO_OPEN_STORE_TOOLTIP,
		getFunc = function() return WG.SV.AutoOpen end,
		setFunc = function(var) WG.SV.AutoOpen = var end,
    width = "full",
    },
    { --Auto Open When Daily Writs
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_OPEN_WRITS,
    tooltip = WG.Lang.SETTING_AUTO_OPEN_WRITS_TOOLTIP,
		getFunc = function() return WG.SV.ForceOpen end,
		setFunc = function(var) WG.SV.ForceOpen = var end,
    width = "full",
    },
    { --Auto Close
		type = "checkbox",
		name = WG.Lang.SETTING_AUTO_CLOSE,
    tooltip = WG.Lang.SETTING_AUTO_CLOSE_TOOLTIP,
		getFunc = function() return WG.SV.AutoClose end,
		setFunc = function(var) WG.SV.AutoClose = var end,
    width = "full",
    },
    { --Display Log
		type = "checkbox",
		name = WG.Lang.SETTING_STEPS_LOG,
    tooltip = WG.Lang.SETTING_STEPS_LOG_TOOLTIP,
		getFunc = function() return WG.SV.Log end,
		setFunc = function(var) WG.SV.Log = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    { --KeepCraft
		type = "checkbox",
		name = WG.Lang.SETTING_BAN_STORE_WRITS,
    tooltip = WG.Lang.SETTING_BAN_STORE_WRITS_TOOLTIP,
		getFunc = function() return WG.SV.KeepCraft end,
		setFunc = function(var) WG.SV.KeepCraft = var end,
    width = "full",
    },
    { --Ignore Inventory
		type = "checkbox",
		name = WG.Lang.SETTING_IGNORE_INVENTORY,
    tooltip = WG.Lang.SETTING_IGNORE_INVENTORY_TOOLTIP,
		getFunc = function() return WG.SV.IgnoreInventory end,
		setFunc = function(var) WG.SV.IgnoreInventory = var end,
    width = "full",
    },
    { --Use LazyCrafting Queue
		type = "checkbox",
		name = WG.Lang.SETTING_LAZYCRAFTING,
    tooltip = WG.Lang.SETTING_LAZYCRAFTING_TOOLTIP,
		getFunc = function() return WG.SV.LazyCrafting end,
		setFunc = function(var) WG.SV.LazyCrafting = var end,
    width = "full",
    },
    { --Take Finished Products Instead of Materials
		type = "checkbox",
		name = WG.Lang.SETTING_LAZYCRAFTING_PRODUCT,
    tooltip = WG.Lang.SETTING_LAZYCRAFTING_PRODUCT_TOOLTIP,
		getFunc = function() return WG.SV.LazyCraftingProduct end,
		setFunc = function(var) WG.SV.LazyCraftingProduct = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    { --Not enough to take
		type = "checkbox",
		name = WG.Lang.SETTING_NE_TAKE,
    tooltip = WG.Lang.SETTING_NE_TAKE_TOOLTIP,
		getFunc = function() return WG.SV.NE_Take end,
		setFunc = function(var) WG.SV.NE_Take = var end,
    width = "full",
    },
    { --Not enough to store
		type = "checkbox",
		name = WG.Lang.SETTING_NE_STORE,
    tooltip = WG.Lang.SETTING_NE_STORE_TOOLTIP,
		getFunc = function() return WG.SV.NE_Store end,
		setFunc = function(var) WG.SV.NE_Store = var end,
    width = "full",
    },
    {
    type = "divider",
    alpha = 0.2,
    },
    {
    type = "checkbox",
		name = WG.Lang.SETTING_IGNORE_FCOIS,
    tooltip = WG.Lang.SETTING_IGNORE_FCOIS_TOOLTIP,
		getFunc = function() return WG.SV.IgnoreFCOIS end,
		setFunc = function(var) WG.SV.IgnoreFCOIS = var end,
    width = "full",
    },
  --Guild Bank
    {
    type = "header",
    name = WG.Lang.SETTING_HEADER_SELECT_GUILD,
		},
    {
		type = "description",
		title = WG.Lang.SETTING_GUILD_TIPS,
    },
    GuildSelector(1),
    GuildSelector(2),
    GuildSelector(3),
    GuildSelector(4),
    GuildSelector(5),
    GuildRules(1),
    GuildRules(2),
    GuildRules(3),
    GuildRules(4),
    GuildRules(5),
    { --Clipboard
    type = "submenu",
		name = WG.Lang.CLIP,
    disabled = false,
		controls = {
        { --Select Bank
        type = "dropdown",
        name = GetString(SI_GAMEPAD_GUILD_BANK_CATEGORY_HEADER), 
        choices = {"/", "1", "2", "3", "4", "5"},
        choicesValues = {false, 1, 2, 3, 4, 5},
        scrollable = true,
        getFunc = function() if ClipGuild then return ClipGuild else return false end end,
        setFunc = function(var)
          if var and WG.SV.Guild[var] then
            ClipGuild = var
          end
        end,
        width = "full",
        },
        { --Copy
        type = "button",
        name = GetString(SI_UI_ERROR_COPY),
        func = function()
          if not ClipGuild then return end
          ClipSteps = WG.SV["Guild" .. ClipGuild]
        end,
        width = "half",	
        },
        { --Paste
        type = "button",
        name = WG.Lang.CLIP_PASTE,
        func = function()
          if not ClipGuild then return end
          WG.SV["Guild" .. ClipGuild] = CopySteps(WG.SV.Guild[ClipGuild], ClipSteps)
        end,
        width = "half",	
        },
        { --Rules Display
        type = "description",
        title = WG.Lang.GUILD_HEADER_STEPS,
        text = function() return Desc(ClipSteps) end,
        width = "full",
        enableLinks = true,
        },
      },
    },
    { --Help
      type = "description",
      title = WG.Lang.SETTING_BOTTOM_TIPS,
      width = "full",
      enableLinks = true,
    },
  --End of options
  }
	LAM:RegisterOptionControls(WG.name.."_Options", options)
end
