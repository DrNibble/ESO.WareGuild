-- WareGuild offline test harness (Lua 5.1, lupa)
-- Loads the DELIVERED files (../WareGuild/Data.lua, Main.lua, lang/en.lua) with
-- stubs, then runs behavioral assertions on the LazyCrafting integration and the
-- guild bank fixes. Not for in-game loading.

local passed, failed = 0, 0
local function check(name, cond)
  if cond then passed = passed + 1
  else failed = failed + 1; print("FAIL: " .. name) end
end

-- ============ stubs ============
SDC_WareGuild = {}

-- inventory state (bag 1): [slot] = itemId
local Bag = {}
-- guild bank state (bag 3): [slot] = itemId (nil = empty bank)
local GuildBank = nil
-- per-item totals: backbag / bank / craftbag
local Stacks = {}
-- smithing pattern -> material itemId
local PatternMat = {[7] = 5413, [2] = 811, [3] = 803}

local function ToLink(id)
  return "|H1:item:" .. tostring(id) .. ":30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

GetBagSize = function(bag) if bag == 1 then return 12 end; return 0 end
GetItemLink = function(bag, slot)
  if bag == 1 then return Bag[slot] and ToLink(Bag[slot]) or "" end
  if bag == 3 then
    if not GuildBank then return "" end
    return GuildBank[slot] and ToLink(GuildBank[slot]) or ""
  end
  return ""
end
GetItemInfo = function(bag, slot) return true, 5 end
GetSlotStackSize = function(bag, slot) return 5, 100 end
GetItemLinkItemId = function(link)
  return tonumber(link:match("item:(%d+):")) or 0
end
IsItemLinkStolen = function() return false end
GetItemLinkCraftingSkillType = function() return 0 end
GetItemLinkFilterTypeInfo = function() return nil end
GetItemLinkStacks = function(link)
  local id = GetItemLinkItemId(link)
  local s = Stacks[id] or {0, 0, 0}
  return s[1], s[2], s[3]
end
GetNextGuildBankSlotId = function()
  if not GuildBank then return nil end
  for slot in pairs(GuildBank) do return slot end
  return nil
end
GetItemCreatorName = function() return "tester" end
GetUnitName = function() return "tester" end
DoesItemLinkFulfillJournalQuestCondition = function() return false end
GetSmithingPatternMaterialItemLink = function(pattern, matIndex, style)
  local id = PatternMat[pattern]
  if not id then return "" end
  return ToLink(id)
end

-- quest journal: [index] = {type, {{itemId, materialId, craftType, quality, cur, max}}}
local Journal = {}
GetJournalQuestInfo = function(idx)
  local q = Journal[idx]
  if not q then return nil, nil, nil, nil, nil, nil, nil, nil, nil, 0 end
  return "Writ", nil, nil, nil, nil, nil, nil, nil, nil, q.type
end
GetQuestConditionMasterWritInfo = function() return nil end
GetQuestConditionItemInfo = function(idx, step, cond)
  local q = Journal[idx]
  if not q or not q.conditions[cond] then return 0, 0, 0, 0 end
  local c = q.conditions[cond]
  return c[1], c[2], c[3], c[4]
end
GetJournalQuestConditionValues = function(idx, step, cond)
  local q = Journal[idx]
  if not q or not q.conditions[cond] then return 0, 0 end
  local c = q.conditions[cond]
  return c[5], c[6]
end

-- events / scenes / misc
EVENT_MANAGER = {
  RegisterForEvent = function() end,
  UnregisterForEvent = function() end,
  AddFilterForEvent = function() end,
}
SCENE_MANAGER = {
  RegisterCallback = function() end,
  UnregisterCallback = function() end,
  IsShowing = function() return false end,
}
d = function() end
zo_strformat = function(s) return s end
GetString = function(s) return "SI" .. tostring(s) end
CRAFTING_TYPE_BLACKSMITHING = 1
CRAFTING_TYPE_CLOTHIER = 2
CRAFTING_TYPE_ENCHANTING = 3
CRAFTING_TYPE_ALCHEMY = 4
CRAFTING_TYPE_PROVISIONING = 5
CRAFTING_TYPE_WOODWORKING = 6
CRAFTING_TYPE_JEWELRYCRAFTING = 7
for _, si in ipairs({13, 14, 15, 16, 17, 18, 19, 20, 25}) do
  _G["SI_ITEMFILTERTYPE" .. si] = si
end
for _, si in ipairs({1305, 1}) do _G["SI_" .. si] = si end

-- ============ load delivered files ============
local function loadFile(path)
  local f = assert(loadfile(path))
  setfenv(f, _G)
  f()
end
loadFile("../WareGuild/Data.lua")
loadFile("../WareGuild/lang/en.lua")
loadFile("../WareGuild/Main.lua")

local WG = SDC_WareGuild
WG.SV = {LazyCrafting = true, IgnoreInventory = false}

-- ============ LibLazyCrafting stub ============
local function setLLC(queue)
  if queue == nil then LibLazyCrafting = nil
  else LibLazyCrafting = {craftingQueue = queue} end
end

local function LLCRequest(station, pattern, matIndex, matQty, smithQty, reqType)
  return {
    ["type"] = reqType or "smithing",
    ["station"] = station,
    ["pattern"] = pattern,
    ["materialIndex"] = matIndex,
    ["materialQuantity"] = matQty,
    ["smithingQuantity"] = smithQty or 1,
  }
end

-- ============ tests ============

-- 1. FindLazyCraftingItem: basic accumulation + smithingQuantity multiplier
setLLC({
  ["LazyWritCrafter"] = {
    [1] = {LLCRequest(1, 7, 1, 5, 2)},             -- steel: 5 x 2 = 10
    [2] = {LLCRequest(2, 2, 1, 3)},                -- textile: 3 x 1 = 3
    [6] = {LLCRequest(6, 3, 1, 4, 1)},             -- wood: 4
    [7] = {LLCRequest(7, 7, 1, 9)},                -- jewelry: ignored (not in list)
  },
})
local M = WG.FindLazyCraftingItem()
check("LLC steel 10", M[5413] == 10)
check("LLC textile 3", M[811] == 3)
check("LLC wood 4", M[803] == 4)
check("LLC jewelry ignored", M[135138] == nil)

-- 2. multiple requests same material accumulate
setLLC({["A"] = {[1] = {LLCRequest(1, 7, 1, 5), LLCRequest(1, 7, 1, 3)}}})
M = WG.FindLazyCraftingItem()
check("LLC accumulate same mat", M[5413] == 8)

-- 3. non-smithing / malformed requests skipped
setLLC({["A"] = {
  [1] = {LLCRequest(1, 7, 1, 5, 1, "improvement"), {["type"] = "smithing"}, LLCRequest(1, nil, nil, 5)},
}})
M = WG.FindLazyCraftingItem()
check("LLC improvement skipped", M[5413] == nil)
check("LLC missing pattern skipped", next(M) == nil)

-- 4. no LibLazyCrafting / setting off
setLLC(nil)
M = WG.FindLazyCraftingItem()
check("LLC absent -> empty", next(M) == nil)
setLLC({["A"] = {[1] = {LLCRequest(1, 7, 1, 5)}}})
WG.SV.LazyCrafting = false
M = WG.FindLazyCraftingItem()
check("LLC setting off -> empty", next(M) == nil)
WG.SV.LazyCrafting = true

-- 5. FindDailyItem merge: quest needs 6 steel, LLC needs 10 -> max 10
setLLC({["A"] = {[1] = {LLCRequest(1, 7, 1, 5, 2)}}})
Journal[1] = {type = 4, conditions = {
  -- blacksmith writ: 2 items of pattern 43529, mat 146 (excel: 5413 x 3) => 6
  {43529, 146, 1, 1, 0, 2},
}}
Stacks[5413] = {0, 0, 0} -- nothing owned: withdraw full amount
local D = WG.FindDailyItem()
local found
for _, e in ipairs(D) do if e.ItemId == 5413 then found = e.Count end end
check("merge max(quest 6, LLC 10) -> 10", found == 10)

-- 6. merge: LLC less than quest -> quest value kept
setLLC({["A"] = {[1] = {LLCRequest(1, 7, 1, 2)}}}) -- LLC 2
D = WG.FindDailyItem()
found = nil
for _, e in ipairs(D) do if e.ItemId == 5413 then found = e.Count end end
check("merge max(quest 6, LLC 2) -> 6", found == 6)

-- 7. merge: LLC only (no writ quest) -> LLC value
Journal[1] = nil
Stacks[5413] = {0, 0, 0}
D = WG.FindDailyItem()
found = nil
for _, e in ipairs(D) do if e.ItemId == 5413 then found = e.Count end end
check("LLC only -> 2", found == 2)

-- 8. MaterialCount integration: some in bag -> only missing withdrawn
Stacks[5413] = {4, 0, 0} -- 4 in backpack
D = WG.FindDailyItem()
found = nil
for _, e in ipairs(D) do if e.ItemId == 5413 then found = e.Count end end
check("inventory-aware count (2 - 4 owned => no entry)", found == nil)
Stacks[5413] = {0, 0, 0}

-- 9. empty guild bank: alchemy/cook scan does not crash (nil GetNextGuildBankSlotId)
GuildBank = nil
Journal[1] = {type = 4, conditions = {
  -- alchemy production: item with materialId ~= 0 -> guild bank scan path
  {99999, 1, 4, 1, 0, 1},
}}
local ok = pcall(WG.FindDailyItem)
check("empty guild bank, alchemy scan no crash", ok)
Journal[1] = nil

-- 10. FindItem on empty guild bank: no crash, empty result
local Slot = WG.FindItem(3, 5413, nil)
check("FindItem empty guild bank Total 0", Slot.Total == 0 and #Slot == 0)

-- 11. FindItem backpack loop bounds: slot indices 0..GetBagSize-1 only
local maxSlot = -1
local realGetItemLink = GetItemLink
GetItemLink = function(bag, slot)
  if bag == 1 then if slot > maxSlot then maxSlot = slot end end
  return realGetItemLink(bag, slot)
end
Bag = {[0] = 5413, [1] = 5413, [11] = 5413}
Slot = WG.FindItem(1, 5413, nil)
GetItemLink = realGetItemLink
check("FindItem bag bounds (max slot 11 < size 12)", maxSlot == 11)
check("FindItem finds all 3 stacks", #Slot == 3 and Slot.Total == 15)
Bag = {}

-- 12. FindItemType loop bounds
maxSlot = -1
local realGIL2 = GetItemLink
GetItemLink = function(bag, slot)
  if bag == 1 then if slot > maxSlot then maxSlot = slot end end
  return realGIL2(bag, slot)
end
WG.FindItemType(1)
GetItemLink = realGIL2
check("FindItemType bag bounds", maxSlot == 11)

print(string.format("passed=%d failed=%d", passed, failed))
if failed > 0 then os.exit(1) end
