-- Lua 5.1 behavioral tests against the delivered Data.lua and Main.lua.
-- Run from test/. Transfers, split and stack notifications are asynchronous.
local Passed, Failed = 0, 0
local function check(Name, Condition)
  if Condition then Passed = Passed + 1
  else Failed = Failed + 1; print("FAIL: " .. Name) end
end

local Bag, Bank, Handlers, Tasks, Timers, Messages, Operations
local Size, BankSize, Permission, SelectedGuild, BankFirst, FailTransfer
local LockedBag, LockedBank, LostSpace, Settings, OnWithdrawal
local EndCount, GuardWaits, FulfillVariant
local Bound, PlayerLocked, StolenItems, Knowledge, ResearchItems, ResearchKnowledge, HasWrit
local KnowledgeCalls, LastKnowledgeArgs, LastResearchArgs
local function item(Id, Count, Max, Variant, Level)
  return {id = Id, count = Count, max = Max or 200, variant = Variant or 1, level = Level or 1}
end
local function link(Item)
  if not Item then return "" end
  return "|H1:item:" .. Item.id .. ":30:" .. Item.level .. ":" .. Item.variant .. ":0|h|h"
end
local function contents(BagId) return BagId == 1 and Bag or Bank end
local function emit(Event, ...)
  local Copy = {}
  for Name, Events in pairs(Handlers) do
    if Events[Event] then Copy[#Copy + 1] = {Name, Events[Event]} end
  end
  for _, Entry in ipairs(Copy) do
    if Handlers[Entry[1]] and Handlers[Entry[1]][Event] == Entry[2] then Entry[2](Event, ...) end
  end
end
local function later(Fun) Tasks[#Tasks + 1] = Fun end
local function drain()
  local Iterations = 0
  while #Tasks > 0 do
    Iterations = Iterations + 1
    assert(Iterations < 1000, "event loop did not converge")
    local Fun = table.remove(Tasks, 1)
    Fun()
  end
end
local function total(BagId, Id)
  local Num, Slots = 0, 0
  for _, Item in pairs(contents(BagId)) do
    if Item.id == Id then Num, Slots = Num + Item.count, Slots + 1 end
  end
  return Num, Slots
end
local function numOps(Kind)
  local Num = 0
  for _, Op in ipairs(Operations) do if Op[1] == Kind then Num = Num + 1 end end
  return Num
end
local function hasMessage(Text)
  for _, Message in ipairs(Messages) do if Message:find(Text, 1, true) then return true end end
  return false
end

BAG_BACKPACK = 1
EVENT_ADD_ON_LOADED = "loaded"
EVENT_GUILD_BANK_ITEMS_READY = "ready"
EVENT_GUILD_BANK_SELECTED, EVENT_GUILD_BANK_DESELECTED = "selected", "deselected"
EVENT_OPEN_GUILD_BANK, EVENT_CLOSE_GUILD_BANK = "open", "close"
EVENT_GUILD_BANK_OPEN_ERROR = "open-error"
EVENT_GUILD_BANK_ITEM_ADDED = "added"
EVENT_GUILD_BANK_ITEM_REMOVED = "removed"
EVENT_GUILD_BANK_TRANSFER_ERROR = "error"
EVENT_INVENTORY_SINGLE_SLOT_UPDATE = "slot"
EVENT_INVENTORY_FULL_UPDATE = "full"
GUILD_PERMISSION_BANK_WITHDRAW = "withdraw"
SCENE_SHOWN, SCENE_HIDING = "shown", "hiding"
SETTING_TYPE_LOOT = "loot"
ITEMFILTERTYPE_CRAFTING = 99
ITEMFILTERTYPE_STYLE_MATERIALS, ITEMFILTERTYPE_TRAIT_ITEMS = 98, 97
ITEM_QUALITY_NORMAL, ITEM_TRAIT_TYPE_NONE = 1, 0
GetString = function(_, Index) return Index and ("guild bank error " .. tostring(Index)) or "" end
zo_strformat = function(Text, ...)
  assert(type(Text) == "string", "missing translation")
  local Values = {...}
  return (Text:gsub("<<(%d+)>>", function(Index) return tostring(Values[tonumber(Index)]) end))
end
d = function(Text) Messages[#Messages + 1] = Text end
zo_callLater = function(Fun) Timers[#Timers + 1] = Fun end
EVENT_MANAGER = {
  RegisterForEvent = function(_, Name, Event, Fun)
    Handlers[Name] = Handlers[Name] or {}
    Handlers[Name][Event] = Fun
  end,
  UnregisterForEvent = function(_, Name, Event)
    if Handlers[Name] then Handlers[Name][Event] = nil end
  end,
}
SCENE_MANAGER = {
  RegisterCallback = function() end, UnregisterCallback = function() end,
  IsShowing = function() return false end, Hide = function() end,
}
PLAYER_INVENTORY = {RefreshAllGuildBankItems = function() EndCount = EndCount + 1 end}
KEYBIND_STRIP = {UpdateKeybindButtonGroup = function() end}
GetBagSize = function(BagId) return BagId == 1 and Size or BankSize end
GetItemLink = function(BagId, Slot) return link(contents(BagId)[Slot]) end
GetItemLinkItemId = function(Link) return tonumber(Link:match("item:(%d+):")) or 0 end
GetSlotStackSize = function(BagId, Slot)
  local Item = contents(BagId)[Slot]
  return Item and Item.count or 0, Item and Item.max or 0
end
GetItemInfo = function(BagId, Slot) return "", GetSlotStackSize(BagId, Slot) end
GetNextGuildBankSlotId = function(Previous)
  local First
  for Slot in pairs(Bank) do
    if (Previous == nil or Slot > Previous) and (not First or Slot < First) then First = Slot end
  end
  return First
end
FindFirstEmptySlotInBag = function(BagId)
  if BagId == 1 and LostSpace then return nil end
  for Slot = 0, GetBagSize(BagId) - 1 do
    if not contents(BagId)[Slot] then return Slot end
  end
end
GetNumBagFreeSlots = function(BagId)
  if BagId == 1 and LostSpace then return 0 end
  local Used = 0
  for _ in pairs(contents(BagId)) do Used = Used + 1 end
  return GetBagSize(BagId) - Used
end
IsItemLinkStolen = function(Link) return StolenItems[GetItemLinkItemId(Link)] == true end
IsItemBound = function(BagId, Slot) return Bound[BagId][Slot] == true end
IsItemPlayerLocked = function(BagId, Slot) return PlayerLocked[BagId][Slot] == true end
GetDisplayName = function() return "@tester" end
GetCurrentCharacterId = function() return "self" end
GetItemLinkCraftingSkillType = function() return 4 end
GetItemLinkFilterTypeInfo = function(Link)
  if Link ~= "" then return ITEMFILTERTYPE_CRAFTING, nil end
end
FCOIS = {
  IsGuildBankDepositLocked = function(_, Slot) return LockedBag[Slot] == true end,
  IsGuildBankWithdrawLocked = function(_, Slot) return LockedBank[Slot] == true end,
}
DoesPlayerHaveGuildPermission = function() return Permission end
GetSelectedGuildBankId = function() return SelectedGuild end
GetGuildName = function() return "Guild" end
GetJournalQuestInfo = function() return nil, nil, nil, nil, nil, nil, nil, nil, nil, HasWrit and 4 or 0 end
GetSetting = function() return Settings end
SetSetting = function(_, _, Value) Settings = Value end
ClearCursor = function() end
GetItemLinkQuality = function() return 1 end
GetItemLinkTraitInfo = function() return 0 end
GetItemLinkRequiredLevel = function(Link) return tonumber(Link:match("item:%d+:%d+:(%d+):")) or 0 end
GetItemLinkRequiredChampionPoints = function() return 0 end
CallSecureProtected = function(Name, SourceBag, SourceSlot, DestBag, DestSlot, Count)
  assert(Name == "RequestMoveItem" and SourceBag == 1 and DestBag == 1)
  local Source, Dest = Bag[SourceSlot], Bag[DestSlot]
  assert(Source, "move from empty slot")
  local Amount = Count == -1 and math.min(Source.count, Source.max - Dest.count) or Count
  assert(Amount > 0 and Amount <= Source.count)
  --The game merges stacks by item data: the same ItemId stacks together
  --whatever the link variant (degraded guild-bank links).
  assert(not Dest or (GetItemLinkItemId(link(Source)) == GetItemLinkItemId(link(Dest))
    and Dest.count + Amount <= Dest.max))
  Operations[#Operations + 1] = {"move", SourceSlot, DestSlot, Amount}
  later(function()
    if not Bag[DestSlot] then Bag[DestSlot] = item(Source.id, 0, Source.max, Source.variant, Source.level) end
    Bag[DestSlot].count = Bag[DestSlot].count + Amount
    emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, DestSlot, true, nil, nil, Amount)
  end)
  later(function()
    Source.count = Source.count - Amount
    if Source.count == 0 then Bag[SourceSlot] = nil end
    emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, SourceSlot, false, nil, nil, -Amount)
  end)
end
TransferFromGuildBank = function(Slot)
  local Source = assert(Bank[Slot], "withdraw from empty bank slot")
  local Empty = assert(FindFirstEmptySlotInBag(1), "withdraw without free slot")
  assert(Permission and not LockedBank[Slot], "forbidden withdrawal")
  Operations[#Operations + 1] = {"take", Slot, Source.count}
  if FailTransfer then later(function() emit(EVENT_GUILD_BANK_TRANSFER_ERROR, "denied") end) return end
  local BankUpdate = function()
    Bank[Slot] = nil
    emit(EVENT_GUILD_BANK_ITEM_REMOVED, Slot, true)
    if BankFirst then GuardWaits = GuardWaits + (#Operations == 1 and 1 or 0) end
  end
  local BagUpdate = function()
    Bag[Empty] = item(Source.id, Source.count, Source.max, Source.variant, Source.level)
    if OnWithdrawal then OnWithdrawal() end
    emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, Empty, true, nil, nil, Source.count)
  end
  --Another Player's Bank Event Must Not Advance the Operation.
  later(function() emit(EVENT_GUILD_BANK_ITEM_REMOVED, Slot, false) end)
  if BankFirst then later(BankUpdate); later(BagUpdate)
  else later(BagUpdate); later(BankUpdate) end
end
TransferToGuildBank = function(BagId, Slot)
  local Source = assert(Bag[Slot], "deposit from stale slot")
  local Empty = assert(FindFirstEmptySlotInBag(3), "deposit into full bank")
  assert(not LockedBag[Slot], "deposit of protected item")
  Operations[#Operations + 1] = {"store", Slot, Source.count, Source.id}
  local BankUpdate = function()
    Bank[Empty] = item(Source.id, Source.count, Source.max, Source.variant, Source.level)
    emit(EVENT_GUILD_BANK_ITEM_ADDED, Empty, true)
  end
  local BagUpdate = function()
    Bag[Slot] = nil
    emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, Slot, false, nil, nil, -Source.count)
  end
  later(function() emit(EVENT_GUILD_BANK_ITEM_ADDED, 499, false) end)
  if BankFirst then later(BankUpdate); later(BagUpdate)
  else later(BagUpdate); later(BankUpdate) end
end

Handlers = {}
assert(loadfile("../WareGuild/Data.lua"))()
assert(loadfile("../WareGuild/lang/en.lua"))()
assert(loadfile("../WareGuild/Main.lua"))()
local WG = SDC_WareGuild
local OriginalAllGuildStep = WG.AllGuildStep
local BankStateHandlers = Handlers[WG.name .. "_BankState"]
local function reset()
  Bag, Bank, Handlers, Tasks, Timers, Messages, Operations = {}, {}, {}, {}, {}, {}, {}
  Handlers[WG.name .. "_BankState"] = BankStateHandlers
  Size, BankSize, Permission, SelectedGuild, BankFirst = 12, 500, true, 42, true
  FailTransfer, LostSpace, OnWithdrawal = false, false, nil
  LockedBag, LockedBank, Settings, EndCount, GuardWaits = {}, {}, "1", 0, 0
  Bound, PlayerLocked, StolenItems = {[1] = {}, [3] = {}}, {[1] = {}, [3] = {}}, {}
  Knowledge, ResearchItems, ResearchKnowledge, KnowledgeCalls = {}, {}, {}, {}
  LastKnowledgeArgs, LastResearchArgs, HasWrit, LibCharacterKnowledge = nil, nil, false, nil
  WG.SV = {KeepCraft = false, Log = false, AutoClose = false}
  WG.CV = {}
  emit(EVENT_CLOSE_GUILD_BANK)
end
local function start(Steps)
  WG.AllGuildStep = function() return Steps end
  WG.GuildBankCore({name = "guildBank"}, nil, SCENE_SHOWN)
  emit(EVENT_GUILD_BANK_ITEMS_READY)
end
local function run(Steps) start(Steps); drain() end
local function storeTo(Count) return {{GuildId = 42, Type = WAREGUILD_STORE_TO, ItemId = 30157, Count = Count}} end
local function storeAll() return {{GuildId = 42, Type = WAREGUILD_STORE_ALL, ItemId = 30157}} end
local function example()
  Bag[0] = item(30157, 25)
  Bank[4], Bank[5] = item(30157, 2), item(30157, 3)
end

reset(); example()
--Bank target 25 is generated, for example, by TAKE_TO keeping 5 in the bag.
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 30157, Count = 5}})
check("example: 5 columbines stay in backpack", total(1, 30157) == 5)
local Count, Slots = total(3, 30157)
check("example: 25 columbines form one bank stack", Count == 25 and Slots == 1)
check("example: both existing bank stacks withdrawn", numOps("take") == 2)
check("example: only one packed stack deposited", numOps("store") == 1)
check("example: conservation of all 30 items", total(1, 30157) + total(3, 30157) == 30)
check("bank event alone does not advance withdrawal", GuardWaits == 1)
check("auto craft bag setting restored", Settings == "1")
check("session finishes normally", EndCount == 1)

reset(); example(); BankFirst = false
run(storeTo(25))
check("backpack-first updates also complete", total(1, 30157) == 5 and total(3, 30157) == 25)
check("backpack-first: one bank stack", select(2, total(3, 30157)) == 1)

reset(); example()
run(storeAll())
check("store all empties matching backpack", total(1, 30157) == 0)
check("store all consolidates bank", total(3, 30157) == 30 and select(2, total(3, 30157)) == 1)

reset(); example()
start(storeAll())
WG.GuildBankQueue(false)
drain()
check("repeated queue invocation does not duplicate withdrawals", numOps("take") == 2)
check("repeated queue invocation preserves all items", total(1, 30157) == 0 and total(3, 30157) == 30)

reset(); example(); Bag[1] = item(999, 12); Bank[6] = item(999, 7)
run({{GuildId = 42, Type = WAREGUILD_STORE_A}})
check("craft category: first item consolidated", total(3, 30157) == 30 and select(2, total(3, 30157)) == 1)
check("craft category: second item consolidated", total(3, 999) == 19 and select(2, total(3, 999)) == 1)
check("craft category: no stale slots or residue", next(Bag) == nil)

reset(); Bag[0] = item(30157, 25); Bag[1] = item(30157, 10)
run(storeTo(5))
check("small net deposit retains large remainder", total(1, 30157) == 30 and total(3, 30157) == 5)
check("small net deposit: remainder is one stack", select(2, total(1, 30157)) == 1)

reset(); Bag[0] = item(30157, 190); Bag[1] = item(30157, 50)
Bank[4], Bank[5] = item(30157, 180), item(30157, 80)
run(storeTo(495))
check("over max stack: retained amount exact", total(1, 30157) == 5)
Count, Slots = total(3, 30157)
check("over max stack: minimum three stacks", Count == 495 and Slots == 3)
local FullStacks = 0
for _, Item in pairs(Bank) do if Item.count == 200 then FullStacks = FullStacks + 1 end end
check("over max stack: two full stacks and remainder", FullStacks == 2)

reset(); Size = 2; Bag[0] = item(30157, 25)
Bank[4], Bank[5] = item(30157, 200), item(30157, 200)
run(storeTo(420))
check("insufficient regroup space: no withdrawal", numOps("take") == 0)
check("insufficient regroup space: normal deposit completed", total(1, 30157) == 5 and total(3, 30157) == 420)
check("insufficient regroup space: announcement", hasMessage("insufficient backpack space"))

reset(); Size = 3; Bag[0] = item(30157, 25)
Bank[4], Bank[5] = item(30157, 200), item(30157, 200)
run(storeTo(420))
check("space preflight reuses slots released by full deposits", numOps("take") == 2)
check("space preflight: exact retained and deposited totals", total(1, 30157) == 5 and total(3, 30157) == 420)

reset(); Size = 2; Bag[0] = item(30157, 9, 10); Bank[4] = item(30157, 2, 10)
run(storeTo(10))
check("one free slot suffices when depositing a full stack", numOps("take") == 1)
check("full-stack deposit needs no spare split slot", total(1, 30157) == 1 and total(3, 30157) == 10)

reset(); Size = 2; example(); Bag[1] = item(999, 1)
run(storeAll())
check("completely full backpack: deposit still allowed", total(1, 30157) == 0 and total(3, 30157) == 30)
check("completely full backpack: skips regroup with notice", numOps("take") == 0 and hasMessage("insufficient backpack space"))

reset(); example(); Permission = false
run(storeTo(25))
check("no withdrawal permission: normal deposit", total(1, 30157) == 5 and total(3, 30157) == 25)
check("no withdrawal permission: no take", numOps("take") == 0 and hasMessage("withdrawal permission"))

reset(); example(); LockedBank[4] = true
run(storeAll())
check("protected bank stack left untouched", Bank[4] and Bank[4].count == 2)
check("protected bank stack: allowed stack consolidated", total(3, 30157) == 30 and select(2, total(3, 30157)) == 2)

reset(); example(); Bag[1] = item(30157, 7); LockedBag[1] = true
run(storeAll())
check("protected backpack stack never deposited", Bag[1] and Bag[1].count == 7)
check("protected backpack stack not merged", total(1, 30157) == 7 and total(3, 30157) == 30)

reset(); example(); Bank[6] = item(30157, 11, 200, 2)
run(storeAll())
check("stackable: same itemId with a different link variant is regrouped",
  total(3, 30157) == 41 and select(2, total(3, 30157)) == 1)
check("stackable: variant bank stack borrowed for regroup", numOps("take") == 3)

reset(); example(); Bank[6] = item(30157, 11, 200, 1, 2)
run(storeAll())
check("stackable: bank stack with another link level is regrouped",
  total(3, 30157) == 41 and select(2, total(3, 30157)) == 1 and numOps("take") == 3)

reset(); Bag[0] = item(30157, 25); Bank[4] = item(30157, 2, 200, 1, 2)
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 30157, Count = 5}})
check("stackable: degraded-link take-to keeps 5 in the bag", total(1, 30157) == 5)
check("stackable: degraded-link take-to ends with one bank stack of 22",
  total(3, 30157) == 22 and select(2, total(3, 30157)) == 1)
check("stackable: no mismatch message for a stackable item",
  not hasMessage("different level, quality or link"))

reset(); example()
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 30157, Count = 5}})
check("no mismatch message when regroup works", not hasMessage("different level, quality or link"))

reset(); example()
OnWithdrawal = function() Permission = false end
run(storeTo(25))
check("permission lost after first take: no further withdrawal", numOps("take") == 1)
check("partial regroup returns borrowed items and keeps 5", total(1, 30157) == 5 and total(3, 30157) == 25)
check("partial regroup reports fallback", hasMessage("withdrawal permission"))

reset(); example()
OnWithdrawal = function() Bank[5] = item(30157, 4) end
run(storeTo(25))
check("bank slot changed mid-regroup: no stale take", numOps("take") == 1)
check("bank slot changed mid-regroup: original retained quantity preserved", total(1, 30157) == 5 and total(3, 30157) == 26)

reset(); example(); BankSize = 2; Bank = {[0] = item(30157, 2), [1] = item(30157, 3)}
run(storeAll())
check("full bank: withdrawals create room for consolidated deposit", total(3, 30157) == 30 and select(2, total(3, 30157)) == 1)

reset(); example()
run(storeTo(5))
check("bank target already met: no regroup or transfer", #Operations == 0 and total(1, 30157) == 25)

reset(); example(); Bag[1] = item(999, 20); Bank[6] = item(999, 8)
run({{GuildId = 42, Type = WAREGUILD_STORE_TO, ItemId = 30157, Count = 25},
  {GuildId = 42, Type = WAREGUILD_STORE_ALL, ItemId = 999}})
check("sequential rules preserve each object's retained quantity", total(1, 30157) == 5 and total(3, 30157) == 25)
check("sequential rules use fresh slot positions", total(1, 999) == 0 and total(3, 999) == 28)
local BeforeTimers = #Operations
for _, Timer in ipairs(Timers) do Timer() end
check("completed-operation timers cannot restart transfers", #Operations == BeforeTimers and not hasMessage("Transfer interrupted"))

reset(); Bag[0] = item(30157, 1, 1)
Bank[4] = item(30157, 1, 1)
run(storeAll())
check("non-stackable item deposits without regroup", numOps("take") == 0 and numOps("store") == 1)

reset(); example(); FailTransfer = true
run(storeAll())
check("server error stops without item loss", total(1, 30157) == 25 and total(3, 30157) == 5)
check("server error reports interrupted transfer", hasMessage("Transfer interrupted"))
check("server error clears transaction listeners", next(Handlers.WareGuild_Deposit) == nil)

reset(); example()
OnWithdrawal = function() FailTransfer = true end
run(storeAll())
check("server error after borrowing: no item loss", total(1, 30157) == 27 and total(3, 30157) == 3)
check("server error after borrowing: interruption is reported", hasMessage("Transfer interrupted"))

reset(); example()
start(storeAll())
WG.GuildBankCore({name = "guildBank"}, nil, SCENE_HIDING)
drain()
for _, Timer in ipairs(Timers) do Timer() end
check("closing cancels callbacks and timeout continuations", numOps("take") == 1 and numOps("store") == 0)
check("closing restores craft bag setting", Settings == "1")
check("closing leaves in-flight withdrawal in bag safely", total(1, 30157) + total(3, 30157) == 30)

reset(); example()
start(storeAll())
SelectedGuild = 99
drain()
check("guild switch stops the old transaction", numOps("store") == 0 and hasMessage("Transfer interrupted"))
check("guild switch leaves withdrawn items in backpack", total(1, 30157) + total(3, 30157) == 30)

reset(); example()
start(storeAll())
--No server replies: the real 10-second timeout must release the session.
for _, Timer in ipairs(Timers) do Timer() end
check("timeout reports interruption", hasMessage("Transfer interrupted"))
check("timeout restores settings and removes listeners", Settings == "1" and next(Handlers.WareGuild_Deposit) == nil)
Tasks = {}

--Quantity matrix with a small stack limit: pack, keep and split across boundaries.
for Case = 1, 20 do
  reset(); Size = 40
  local BackpackTotal, BankTotal, Keep = Case * 3 + 2, Case * 2 + 3, Case
  local Left, Slot = BackpackTotal, 0
  while Left > 0 do
    local Num = math.min(7, Left)
    Bag[Slot] = item(30157, Num, 10)
    Left, Slot = Left - Num, Slot + 1
  end
  Left, Slot = BankTotal, 0
  while Left > 0 do
    local Num = math.min(6, Left)
    Bank[Slot] = item(30157, Num, 10)
    Left, Slot = Left - Num, Slot + 1
  end
  local Target = BackpackTotal + BankTotal - Keep
  run(storeTo(Target))
  check("matrix " .. Case .. ": exact retained amount", total(1, 30157) == Keep)
  check("matrix " .. Case .. ": exact bank amount", total(3, 30157) == Target)
  check("matrix " .. Case .. ": minimum bank stacks", select(2, total(3, 30157)) == math.ceil(Target / 10))
end

--Daily withdrawals: early READY, sparse slots, selected guild and useful failures.
local OriginalJournalInfo, OriginalQuality, OriginalTrait = GetJournalQuestInfo, GetItemLinkQuality, GetItemLinkTraitInfo
local OriginalGuildName, OriginalTransfer, OriginalMove = GetGuildName, TransferFromGuildBank, CallSecureProtected
local WantedId, WantQuality, WantTrait, QuestMatches, NoPattern, NoReference, Selections
GetGuildName = function(Id) return "Guild" .. tostring(Id) end
GetJournalQuestInfo = function(Index)
  return nil, nil, nil, nil, nil, nil, nil, nil, nil, Index == 1 and 4 or 0
end
GetQuestConditionMasterWritInfo = function() return nil end
GetQuestConditionItemInfo = function(Index, _, Condition)
  if Index == 1 and Condition == 1 then return WantedId, 153, 6, 1 end
  return 0, 0, 0, 0
end
GetJournalQuestConditionValues = function(Index, _, Condition)
  return 0, Index == 1 and Condition == 1 and 1 or 0
end
GetSmithingPatternInfoForItemId = function() if not NoPattern then return 99, 2 end end
GetSmithingPatternResultLink = function()
  return NoReference and "" or link(item(WantedId, 1, 1, 1, 16))
end
GetItemCreatorName, GetUnitName = function() return "tester" end, function() return "tester" end
GetItemLinkStacks = function(Link) return total(1, GetItemLinkItemId(Link)), 0, 0 end
DoesItemLinkFulfillJournalQuestCondition = function(Link)
  -- FulfillVariant: only items of that variant belong to the writ material tier
  local Variant = tonumber(Link:match("item:%d+:%d+:%d+:(%d+)"))
  return QuestMatches and GetItemLinkItemId(Link) == WantedId and (FulfillVariant == nil or Variant == FulfillVariant)
end
GetItemLinkQuality = function(Link)
  return GetItemLinkItemId(Link) == WantedId and WantQuality or 1
end
GetItemLinkTraitInfo = function(Link)
  return GetItemLinkItemId(Link) == WantedId and WantTrait or 0
end
SelectGuildBank = function(Id)
  Selections[#Selections + 1] = Id
  SelectedGuild = Id
  emit(EVENT_GUILD_BANK_SELECTED, Id)
end
local function dailySetup()
  reset()
  FulfillVariant = nil
  WantedId, WantQuality, WantTrait, QuestMatches, NoPattern, NoReference = 43559, 1, 0, true, false, false
  SelectedGuild, Selections = 44, {}
  WG.SV.LazyCraftingProduct, WG.SV.LazyCrafting = true, false
  Bank[2], Bank[2456] = item(999, 1), item(43559, 1, 1, 1, 16)
end
local function dailySteps() return {{GuildId = 44, Type = WAREGUILD_DAILY}} end
local function openDaily(Scene)
  WG.AllGuildStep = dailySteps
  WG.GuildBankCore({name = Scene or "guildBank"}, nil, SCENE_SHOWN)
end
local function allTimers() for _, Timer in ipairs(Timers) do Timer() end end
local function messageCount(Text)
  local Count = 0
  for _, Message in ipairs(Messages) do if Message:find(Text, 1, true) then Count = Count + 1 end end
  return Count
end

dailySetup()
check("sparse iterator finds staff beyond first slot + 500", WG.FindItem(3, 43559).Total == 1)
local MaterialList, StaffFound, RawFound = WG.FindDailyItem(), false, false
for _, Entry in ipairs(MaterialList) do
  if Entry.ItemId == 43559 then StaffFound = Entry.CraftLevel == 16 and Entry.CraftChampionPoints == 0 end
  if Entry.ItemId == 533 then RawFound = true end
end
check("oak lightning staff fulfills writ at level 16 without requesting oak", StaffFound and not RawFound)
openDaily()
check("SCENE_SHOWN before READY waits with a chat message", #Operations == 0 and hasMessage("Waiting for guild bank contents"))
emit(EVENT_GUILD_BANK_ITEMS_READY)
drain()
check("daily withdrawal retrieves staff from sparse slot 2456", total(1, 43559) == 1 and total(3, 43559) == 0)
check("daily withdrawal restores craft-bag setting", Settings == "1" and EndCount == 1)
local FinishedOps = #Operations
emit(EVENT_GUILD_BANK_ITEMS_READY); allTimers()
check("duplicate READY and stale timers cannot restart finished daily withdrawal", #Operations == FinishedOps and EndCount == 1)

dailySetup(); emit(EVENT_GUILD_BANK_ITEMS_READY); openDaily(); drain()
check("READY before SCENE_SHOWN starts immediately without waiting again", total(1, 43559) == 1 and not hasMessage("Waiting for guild bank contents"))
dailySetup(); emit(EVENT_GUILD_BANK_ITEMS_READY); openDaily("gamepad_guild_bank"); drain()
check("gamepad scene handles READY-before-SHOWN race too", total(1, 43559) == 1 and Settings == "1")
for _, InvalidateEvent in ipairs({EVENT_OPEN_GUILD_BANK, EVENT_CLOSE_GUILD_BANK,
  EVENT_GUILD_BANK_SELECTED, EVENT_GUILD_BANK_DESELECTED}) do
  dailySetup(); emit(EVENT_GUILD_BANK_ITEMS_READY); emit(InvalidateEvent); openDaily()
  check("bank readiness invalidated by " .. InvalidateEvent, #Operations == 0)
  emit(EVENT_GUILD_BANK_ITEMS_READY); drain()
  check("new READY after " .. InvalidateEvent .. " safely resumes", total(1, 43559) == 1)
end
dailySetup(); BankFirst = false
run(dailySteps())
check("ordinary withdrawal accepts backpack-first events", total(1, 43559) == 1 and total(3, 43559) == 0 and EndCount == 1)
dailySetup()
local OriginalItemLink, OriginalRequiredLevel, StaffReads = GetItemLink, GetItemLinkRequiredLevel, 0
GetItemLink = function(BagId, Slot)
  local Link = OriginalItemLink(BagId, Slot)
  if BagId == 3 and Slot == 2456 then
    StaffReads = StaffReads + 1
    if StaffReads < 4 then return (Link:gsub("(:43559:30:)16:", "%10:")) end
  end
  return Link
end
GetItemLinkRequiredLevel = function(Link)
  if GetItemLinkItemId(Link) == 43559 then return 16 end
  return OriginalRequiredLevel(Link)
end
run(dailySteps())
check("withdrawal preserves native internal-level link workaround without false changed-item error",
  StaffReads >= 4 and total(1, 43559) == 1 and not hasMessage("moved or changed"))
GetItemLink, GetItemLinkRequiredLevel = OriginalItemLink, OriginalRequiredLevel

dailySetup(); SelectedGuild = 42; emit(EVENT_GUILD_BANK_ITEMS_READY); openDaily()
check("configured third guild selected even when another bank is already ready",
  #Selections == 1 and Selections[1] == 44 and #Operations == 0)
SelectedGuild = 99; emit(EVENT_GUILD_BANK_ITEMS_READY)
check("READY for another guild cannot start a third-guild rule", #Operations == 0)
SelectedGuild = 44; emit(EVENT_GUILD_BANK_SELECTED, 44); emit(EVENT_GUILD_BANK_ITEMS_READY); drain()
check("third-guild rule starts only after its own contents are ready", total(1, 43559) == 1 and EndCount == 1)

dailySetup(); openDaily(); allTimers()
check("missing bank READY times out with guild name and explicit reason",
  hasMessage("Guild44") and hasMessage("not confirmed after 20 seconds") and #Operations == 0)
check("bank-ready timeout restores the craft-bag setting", Settings == "1")
emit(EVENT_GUILD_BANK_ITEMS_READY)
check("late READY after timeout does not resume an abandoned run", #Operations == 0)
openDaily(); drain()
check("a new run works after a bank-ready timeout", total(1, 43559) == 1)
dailySetup(); openDaily(); emit(EVENT_GUILD_BANK_OPEN_ERROR, 14)
check("native bank-open error includes guild and server reason", hasMessage("Cannot open guild bank") and hasMessage("guild bank error 14"))
check("native bank-open error restores settings without a transfer", Settings == "1" and #Operations == 0)

dailySetup(); LockedBank[2456] = true
run(dailySteps())
check("FCOIS-protected daily staff is not withdrawn", numOps("take") == 0 and total(3, 43559) == 1)
check("FCOIS protection is explained with the item and guild", hasMessage("43559") and hasMessage("Guild44") and hasMessage("FCOItemSaver"))
WG.FindDailyItem(); WG.FindItem(3, 43559)
check("repeated scans do not spam the same FCOIS reason", messageCount("FCOItemSaver") == 1)
local ProductsAfterBlock = WG.FindDailyItem()
local BlockedProduct, FallbackOak = false, false
for _, Entry in ipairs(ProductsAfterBlock) do
  if Entry.ItemId == 43559 then BlockedProduct = true end
  if Entry.ItemId == 533 and Entry.Count == 4 then FallbackOak = true end
end
check("blocked staff never substitutes for required raw oak", not BlockedProduct and FallbackOak)
dailySetup(); PlayerLocked[3][2456] = true; run(dailySteps())
check("player lock is reported without attempting withdrawal", hasMessage("locked by the player") and numOps("take") == 0)
dailySetup(); Permission = false; run(dailySteps())
check("missing withdrawal permission is reported for the daily staff", hasMessage("missing withdrawal permission") and numOps("take") == 0)
dailySetup(); WantQuality = 2; run(dailySteps())
check("wrong daily quality is reported", hasMessage("white quality required") and numOps("take") == 0)
dailySetup(); WantTrait = 1; run(dailySteps())
check("wrong daily trait is reported", hasMessage("no trait required") and numOps("take") == 0)
dailySetup(); Bank[2456].level = 24; run(dailySteps())
check("wrong daily level reports required and found values", hasMessage("expected 16 / CP 0, found 24 / CP 0") and numOps("take") == 0)
dailySetup(); QuestMatches = false; run(dailySteps())
check("quest-condition rejection is reported", hasMessage("journal quest condition") and numOps("take") == 0)
dailySetup(); NoPattern = true; run(dailySteps())
check("missing smithing pattern still withdraws the finished staff and says why",
  hasMessage("reference craft level unavailable") and numOps("take") == 1 and total(1, 43559) == 1)
check("missing-reference note is not worded as a blocked withdrawal", not hasMessage("Cannot withdraw"))
dailySetup(); NoReference = true; run(dailySteps())
check("empty reference link still withdraws the finished staff",
  hasMessage("reference craft level unavailable") and numOps("take") == 1 and total(1, 43559) == 1)
dailySetup(); NoReference = true; WantQuality = 2; run(dailySteps())
check("without reference a non-white staff is still refused", hasMessage("white quality required") and numOps("take") == 0)
dailySetup(); NoReference = true; QuestMatches = false; run(dailySteps())
check("without reference the journal condition still decides", hasMessage("journal quest condition") and numOps("take") == 0)
dailySetup(); WantedId = 88888; run(dailySteps())
check("missing craft mapping is reported without a Lua error", hasMessage("mapping missing") and numOps("take") == 0 and Settings == "1")
dailySetup(); Bank[2456] = nil; run(dailySteps())
check("absent finished staff reports which bank was searched", hasMessage("no matching item found in this bank") and hasMessage("Guild44"))
dailySetup(); WG.SV.LazyCraftingProduct = false; run(dailySteps())
check("disabled finished-product setting is explained", hasMessage("finished-item retrieval disabled") and numOps("take") == 0)

-- Same itemId in another material tier (maple vs ruby ash): only the tier accepted by the
-- journal condition may be withdrawn, even without a reference craft level.
local function tierSetup(WithBag)
  dailySetup(); NoReference = true; FulfillVariant = 3
  Bank[2455] = item(43559, 1, 1, 2, 16)   -- maple: same id, smaller stack, rejected by the journal
  Bank[2456] = item(43559, 2, 5, 3, 16)   -- ruby ash: accepted by the journal
  if WithBag then Bag[0] = item(43559, 1, 1, 2, 16) end
end
local function bagVariants()
  local Seen = {}
  for _, Item in pairs(Bag) do if Item.id == 43559 then Seen[Item.variant] = (Seen[Item.variant] or 0) + Item.count end end
  return Seen[2] or 0, Seen[3] or 0
end
tierSetup(); run(dailySteps())
local Maple, RubyAsh = bagVariants()
check("no reference: only the journal-accepted tier is withdrawn", Maple == 0 and RubyAsh >= 1 and total(3, 43559) >= 1)
check("no per-item tracking line is printed", not hasMessage("in backpack:"))
check("no reference: the rejected tier stays in the bank", Bank[2455] ~= nil and Bank[2455].variant == 2)
tierSetup(true); run(dailySteps())
Maple, RubyAsh = bagVariants()
check("no reference: a rejected-tier item in the backpack does not count as stock",
  RubyAsh >= 1 and Bank[2455] ~= nil)
dailySetup(); FailTransfer = true; run(dailySteps())
check("native transfer error includes returned error code", hasMessage("transfer error denied") and hasMessage("guild bank error denied"))
check("failed transfer leaves staff in bank and restores settings", total(3, 43559) == 1 and total(1, 43559) == 0 and Settings == "1")
dailySetup()
TransferFromGuildBank = function(Slot) Operations[#Operations + 1] = {"take", Slot} end
start(dailySteps())
emit(EVENT_GUILD_BANK_ITEM_REMOVED, 2456, false)
emit(EVENT_GUILD_BANK_ITEM_REMOVED, 777, true)
check("other-player and wrong-slot events cannot complete a withdrawal", EndCount == 0 and Settings == 0)
allTimers()
check("silently cancelled withdrawal times out with item-specific reason", hasMessage("43559") and hasMessage("no confirmation after 10 seconds") and EndCount == 1)
check("silent failure does not automatically retry", numOps("take") == 1 and total(3, 43559) == 1 and Settings == "1")
TransferFromGuildBank = OriginalTransfer

dailySetup()
TransferFromGuildBank = function(Slot) Operations[#Operations + 1] = {"take", Slot} end
start(dailySteps())
local Taken = Bank[2456]; Bank[2456] = nil
emit(EVENT_GUILD_BANK_ITEM_REMOVED, 2456, true)
check("bank acknowledgement alone waits for actual backpack receipt", EndCount == 0 and Settings == 0)
Bag[0] = Taken; emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, 0)
check("actual backpack receipt releases acknowledged withdrawal", EndCount == 1 and Settings == "1")
TransferFromGuildBank = OriginalTransfer

dailySetup()
TransferFromGuildBank = function(Slot) Operations[#Operations + 1] = {"take", Slot} end
start(dailySteps())
SelectedGuild = 99; emit(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 1, 0)
check("bank change during withdrawal has a distinct diagnostic", hasMessage("selected guild bank changed") and Settings == "1")
TransferFromGuildBank = OriginalTransfer

dailySetup()
TransferFromGuildBank = function(Slot) Operations[#Operations + 1] = {"take", Slot} end
start(dailySteps())
local AbandonedTimers = Timers
WG.GuildBankCore({name = "guildBank"}, nil, SCENE_HIDING)
check("closing during a pending withdrawal immediately restores settings", Settings == "1")
emit(EVENT_CLOSE_GUILD_BANK)
TransferFromGuildBank = OriginalTransfer
start(dailySteps()); drain()
for _, Timer in ipairs(AbandonedTimers) do Timer() end
check("closed-run timers cannot interrupt a reopened withdrawal",
  total(1, 43559) == 1 and Settings == "1" and not hasMessage("no confirmation after 10 seconds"))


--Corrected TakeGuildBankItem: a bank slot that changed between the rule
--analysis and the actual withdrawal (another item, or the same item with a
--different stack size) is skipped silently and the run continues.
reset()
Bank[4], Bank[5] = item(30157, 2), item(30157, 3)
OnWithdrawal = function() Bank[5] = item(30158, 3) end --slot 5 replaced after the first take
run({{GuildId = 42, Type = WAREGUILD_TAKE_ALL, ItemId = 30157}})
check("changed slot: first stack still withdrawn", total(1, 30157) == 2)
check("changed slot: replaced stack not taken", total(1, 30158) == 0 and numOps("take") == 1)
check("changed slot: no report message", not hasMessage(WG.Lang.CHAT_WITHDRAW_CHANGED))

reset()
Bank[4], Bank[5] = item(30157, 2), item(30157, 3)
OnWithdrawal = function() Bank[5] = item(30157, 7) end --same item, new stack size
run({{GuildId = 42, Type = WAREGUILD_TAKE_ALL, ItemId = 30157}})
check("changed count: resized stack not taken", total(1, 30157) == 2 and total(3, 30157) == 7)
check("changed count: exactly one withdrawal", numOps("take") == 1)

dailySetup(); Bank[7788] = item(43559, 1, 1, 1, 16)
OnWithdrawal = function()
  for Slot, Item in pairs(Bank) do if Item.id == 43559 then LockedBank[Slot] = true end end
end
run({{GuildId = 44, Type = WAREGUILD_TAKE_ALL, ItemId = 43559}})
check("queued withdrawal rechecks newly applied FCOIS protection", numOps("take") == 1 and total(1, 43559) == 1 and total(3, 43559) == 1 and hasMessage("FCOItemSaver"))
dailySetup(); Bank[7788] = item(43559, 1, 1, 1, 16)
OnWithdrawal = function()
  for _, Item in pairs(Bank) do if Item.id == 43559 then Item.id = 888 end end
end
run({{GuildId = 44, Type = WAREGUILD_TAKE_ALL, ItemId = 43559}})
check("queued withdrawal rejects a slot replaced with another item", numOps("take") == 1 and total(3, 888) == 1 and hasMessage("moved or changed"))
dailySetup(); Bank[7788] = item(43559, 1, 1, 1, 16)
OnWithdrawal = function() Permission = false end
run({{GuildId = 44, Type = WAREGUILD_TAKE_ALL, ItemId = 43559}})
check("queued withdrawal rechecks lost permission", numOps("take") == 1 and total(3, 43559) == 1 and hasMessage("missing withdrawal permission"))

dailySetup(); Bag[0], Bag[1], LockedBag[0] = item(888, 2), item(888, 3), true
run(dailySteps())
check("protected unrelated backpack stacks cannot stall a daily withdrawal", total(1, 43559) == 1 and numOps("move") == 0 and EndCount == 1)
dailySetup(); Bag[0], Bag[1], PlayerLocked[1][0] = item(888, 2), item(888, 3), true
run(dailySteps())
check("player-locked backpack stacks are not merged during daily withdrawal", total(1, 43559) == 1 and numOps("move") == 0 and EndCount == 1)
dailySetup(); Bag[0], Bag[1] = item(888, 2), item(888, 3)
CallSecureProtected = function() end --Another addon silently blocks a global stack.
run(dailySteps()); allTimers()
check("silently cancelled global stack has a timeout and explanation", hasMessage("Stacking") and hasMessage("no confirmation after 10 seconds") and Settings == "1")
CallSecureProtected = OriginalMove

GetJournalQuestInfo, GetItemLinkQuality, GetItemLinkTraitInfo = OriginalJournalInfo, OriginalQuality, OriginalTrait
GetGuildName = OriginalGuildName

--LibCharacterKnowledge rule: real filtering, real deposits and actual menu.
local function entry(Id, State, Account, Remaining)
  return {id = Id, knowledge = State, account = Account or "@tester", remaining = Remaining}
end
local function installLCK()
  LibCharacterKnowledge = {
    KNOWLEDGE_INVALID = -1, KNOWLEDGE_NODATA = 0, KNOWLEDGE_KNOWN = 1, KNOWLEDGE_UNKNOWN = 2,
    GetItemKnowledgeList = function(Link, Server, Included, Account)
      local Id = GetItemLinkItemId(Link)
      KnowledgeCalls[Id] = (KnowledgeCalls[Id] or 0) + 1
      LastKnowledgeArgs = {server = Server, included = Included, account = Account}
      return Knowledge[Id]
    end,
    GetSmithingResearchFromItemLink = function(Link)
      local Research = ResearchItems[GetItemLinkItemId(Link)]
      if Research then return unpack(Research) end
    end,
    GetSmithingResearchStatusForCharacters = function(Craft, Line, Trait, Server, Included, Account)
      LastResearchArgs = {craft = Craft, line = Line, trait = Trait,
        server = Server, included = Included, account = Account}
      return ResearchKnowledge[Line]
    end,
  }
end
local function unknownRule() return {{GuildId = 42, Type = WAREGUILD_STORE_UNKNOWN}} end
local function needsRecipe(Id) Knowledge[Id] = {entry("alt", 2)} end
local function isNeeded(Id) return WG.IsUnknownToOtherCharacters(link(item(Id, 1))) end

reset()
check("LCK missing: availability false", not WG.HasCharacterKnowledge())
check("LCK missing: no eligible items", #WG.FindUnknownCharacterItems() == 0)
check("LCK missing: unknown predicate is false", not isNeeded(30157))
installLCK()
needsRecipe(30157)
check("LCK loaded: availability true", WG.HasCharacterKnowledge())
check("unknown to one alt qualifies", isNeeded(30157))
check("queries default server without tracking overrides",
  LastKnowledgeArgs.server == nil and LastKnowledgeArgs.included == nil)
check("queries restrict to current account", LastKnowledgeArgs.account == "@tester")

Knowledge[30157] = {entry("self", 2), entry("alt", 1)}
check("unknown only to current character is excluded", not isNeeded(30157))
Knowledge[30157] = {entry("alt", 1), entry("alt2", 2)}
check("not necessary for every alt to be unknown", isNeeded(30157))
Knowledge[30157] = {entry("alt", 1), entry("alt2", 1)}
check("known by all alts is excluded", not isNeeded(30157))
Knowledge[30157] = {entry("alt", 0), entry("alt2", -1)}
check("NODATA and INVALID are not unknown", not isNeeded(30157))
Knowledge[30157] = {entry("foreign", 2, "@someoneelse")}
check("foreign imported account is excluded defensively", not isNeeded(30157))
Knowledge[30157] = {entry("alt", 2, "@TESTER")}
check("account comparison is case insensitive", isNeeded(30157))
Knowledge[30157] = {entry(nil, 2)}
check("missing character id cannot qualify", not isNeeded(30157))
Knowledge[30157] = {}
check("empty tracked-character list cannot qualify", not isNeeded(30157))
Knowledge[30157] = nil
check("library not initialized returning nil is safe", not isNeeded(30157))
LibCharacterKnowledge.KNOWLEDGE_UNKNOWN = nil
check("incompatible library cannot classify nil as unknown", not WG.HasCharacterKnowledge() and not isNeeded(30157))

reset(); installLCK()
ResearchItems[20001] = {1, 3, 2}
ResearchKnowledge[3] = {entry("alt", 2)}
check("equipment needed for alt research qualifies", isNeeded(20001))
check("research API receives the correct indices",
  LastResearchArgs.craft == 1 and LastResearchArgs.line == 3 and LastResearchArgs.trait == 2)
check("research query filters same account and current server",
  LastResearchArgs.account == "@tester" and LastResearchArgs.server == nil and LastResearchArgs.included == nil)
ResearchKnowledge[3] = {entry("alt", 2, nil, 300)}
check("research already in progress is excluded", not isNeeded(20001))
ResearchKnowledge[3] = {entry("alt", 2, nil, 0)}
check("pending-completed research is excluded", not isNeeded(20001))
ResearchKnowledge[3] = {entry("alt", 2, nil, -10)}
check("expired research on an offline alt is excluded", not isNeeded(20001))
ResearchKnowledge[3] = {entry("self", 2), entry("foreign", 2, "@someoneelse")}
check("research excludes current character and other accounts", not isNeeded(20001))
ResearchKnowledge[3] = {entry("alt", 0)}
check("research without data is excluded", not isNeeded(20001))
ResearchKnowledge[3] = {entry("alt", 1)}
check("known research is excluded", not isNeeded(20001))
ResearchKnowledge[3] = {entry("alt", 2)}
LibCharacterKnowledge.GetSmithingResearchFromItemLink = nil
check("missing optional research API does not guess", not isNeeded(20001))

reset(); installLCK(); needsRecipe(30157)
Bag[0], Bag[1], Bag[2] = item(30157, 25), item(30157, 3), item(30157, 2)
Bound[1][1], PlayerLocked[1][2] = true, true
Bag[3], Knowledge[10003] = item(10003, 5), {entry("alt", 1)}
Bag[4], Knowledge[10004] = item(10004, 5), {entry("self", 2)}
Bag[5], Knowledge[10005] = item(10005, 5), {entry("foreign", 2, "@someoneelse")}
Bag[6], ResearchItems[20001], ResearchKnowledge[3] = item(20001, 1, 1), {1, 3, 2}, {entry("alt", 2)}
Bag[7] = item(777, 5)
Bag[8] = item(10008, 5); needsRecipe(10008); StolenItems[10008] = true
Bag[9] = item(10009, 5); needsRecipe(10009); LockedBag[9] = true
Bag[10], Knowledge[10010] = item(10010, 5), {entry("alt", 0)}
Bag[11] = item(30157, 4)
local Eligible, SlotSet = WG.FindUnknownCharacterItems(), {}
for _, Slot in ipairs(Eligible) do SlotSet[Slot.SlotId] = true end
check("scan finds only eligible unbound recipes and research gear", #Eligible == 3 and SlotSet[0] and SlotSet[6] and SlotSet[11])
check("scan excludes bound and player-locked copies of the same link", not SlotSet[1] and not SlotSet[2])
check("scan excludes stolen and FCOIS-protected items", not SlotSet[8] and not SlotSet[9])
check("scan excludes known, self-only, foreign, unsupported and missing data",
  not SlotSet[3] and not SlotSet[4] and not SlotSet[5] and not SlotSet[7] and not SlotSet[10])
check("scan caches knowledge per link", KnowledgeCalls[30157] == 1)

reset(); installLCK(); needsRecipe(30157); example()
Bag[1] = item(30157, 7); Bound[1][1] = true
run(unknownRule())
check("knowledge deposit keeps bound duplicate in bag", Bag[1] and Bag[1].count == 7)
check("knowledge deposit regroups all unbound copies in bank", total(3, 30157) == 30 and select(2, total(3, 30157)) == 1)
check("knowledge deposit preserves all 37 items", total(1, 30157) + total(3, 30157) == 37)

reset(); installLCK()
Bag[0], ResearchItems[20001], ResearchKnowledge[3] = item(20001, 1, 1), {1, 3, 2}, {entry("alt", 2)}
Bank[4] = item(20001, 1, 1)
run(unknownRule())
check("research gear deposits asynchronously without borrowing existing gear",
  numOps("take") == 0 and numOps("store") == 1 and total(3, 20001) == 2)
check("research gear: no residual backpack copy", total(1, 20001) == 0)

reset(); installLCK(); needsRecipe(30157)
Bag[0], Bag[1], Bank[4] = item(30157, 2), item(20001, 1, 1), item(30157, 2)
ResearchItems[20001], ResearchKnowledge[3] = {1, 3, 2}, {entry("alt", 2)}
OnWithdrawal = function() Bound[1][1] = true end
run(unknownRule())
check("binding state rechecked before later queued gear deposit", total(1, 20001) == 1 and total(3, 20001) == 0)
check("binding change does not block other eligible deposit", total(3, 30157) == 4 and EndCount == 1)

reset(); installLCK(); needsRecipe(30157)
Bag[0], Bag[1], Bank[4] = item(30157, 2), item(20001, 1, 1), item(30157, 2)
ResearchItems[20001], ResearchKnowledge[3] = {1, 3, 2}, {entry("alt", 2)}
OnWithdrawal = function() ResearchKnowledge[3] = {entry("alt", 1)} end
run(unknownRule())
check("knowledge rechecked before later queued gear deposit", total(1, 20001) == 1 and total(3, 20001) == 0)
check("learning change safely completes other eligible deposit", total(3, 30157) == 4 and EndCount == 1)

reset(); installLCK(); needsRecipe(30157)
Bag[0], Bag[1], Bag[2], Bank[4] =
  item(30157, 2), item(20001, 1, 1), item(20001, 1, 1), item(30157, 2)
ResearchItems[20001], ResearchKnowledge[3] = {1, 3, 2}, {entry("alt", 2)}
OnWithdrawal = function() Bound[1][1] = true end
run(unknownRule())
check("partially bound queued group clips its deposit to eligible copies",
  total(1, 20001) == 1 and total(3, 20001) == 1 and Bag[1] ~= nil)
check("partially bound queued group completes without timeout", EndCount == 1 and not hasMessage("Transfer interrupted"))

reset(); installLCK(); needsRecipe(30157); Size = 2
Bag[0], Bag[1], Bound[1][1] = item(30157, 25), item(30157, 7), true
Bank[4] = item(30157, 2)
run(unknownRule())
check("full backpack: bound and unbound copies are not globally merged", total(1, 30157) == 7 and total(3, 30157) == 27)
check("full backpack: knowledge rule uses normal-deposit fallback", numOps("take") == 0 and hasMessage("insufficient backpack space"))

reset(); example()
run(unknownRule())
check("saved knowledge rule with LCK missing performs no transfers", #Operations == 0)
check("saved knowledge rule with LCK missing reports why", hasMessage("LibCharacterKnowledge"))
reset(); installLCK(); needsRecipe(30157); example(); HasWrit = true; WG.SV.KeepCraft = true
run(unknownRule())
check("knowledge rule respects disable-storage-while-holding-writs", #Operations == 0)

reset(); installLCK(); needsRecipe(30157); Bag[0] = item(30157, 1)
WG.AllGuildStep = unknownRule
WG.SV.AutoOpen = true
check("auto-open detects eligible knowledge item", WG.ShouldOpenGuildBank())
Knowledge[30157] = {entry("alt", 1)}
check("auto-open does not trigger for all-known items", not WG.ShouldOpenGuildBank())
LibCharacterKnowledge = nil
check("auto-open safely ignores unavailable library", not WG.ShouldOpenGuildBank())
check("step description identifies the new rule", WG.StepToString(unknownRule()[1]):find(WG.Lang.CHAT_STORE_UNKNOWN, 1, true) ~= nil)

--Build the actual LibAddonMenu options and invoke the real buttons.
reset(); installLCK()
WG.SV.Guild = {}
for Index = 1, 5 do WG.SV.Guild[Index] = 41 + Index; WG.SV["Guild" .. Index] = {} end
local Options
LibAddonMenu2 = {
  RegisterAddonPanel = function() end,
  RegisterOptionControls = function(_, _, Controls) Options = Controls end,
}
GetGuildId = function(Index) return 41 + Index end
assert(loadfile("../WareGuild/Menu.lua"))()
WG.BuildMenu()
local Buttons = {}
for _, Option in ipairs(Options) do
  if Option.controls then
    for _, Control in ipairs(Option.controls) do
      if Control.name == WG.Lang.GUILD_STORE_UNKNOWN then table.insert(Buttons, Control) end
    end
  end
end
check("menu exposes one knowledge button per configured guild", #Buttons == 5)
check("menu button enabled with library", not Buttons[3].disabled())
Buttons[3].func()
check("menu creates rule in selected guild only", #WG.SV.Guild3 == 1 and WG.SV.Guild3[1].GuildId == 44
  and WG.SV.Guild3[1].Type == WAREGUILD_STORE_UNKNOWN and #WG.SV.Guild1 == 0)
--The reworked button inserts one rule per click, like every other rule
--button, and no longer deduplicates or requires a selected guild.
Buttons[3].func()
check("deposit button adds one rule per click", #WG.SV.Guild3 == 2)
WG.SV.Guild[4] = false
Buttons[4].func()
check("deposit button still creates the rule for an unselected guild slot",
  #WG.SV.Guild4 == 1 and WG.SV.Guild4[1].GuildId == false)
LibCharacterKnowledge = nil
check("menu button disabled without library", Buttons[2].disabled())
Buttons[2].func()
check("disabled menu function cannot add rule", #WG.SV.Guild2 == 0)
WG.AllGuildStep = OriginalAllGuildStep
local SavedSteps = WG.AllGuildStep()
check("saved knowledge rules survive ordinary rule flattening", #SavedSteps == 3
  and SavedSteps[1].Type == WAREGUILD_STORE_UNKNOWN and SavedSteps[1].GuildId == 44)

--Exercise the real dropdown choices, selections and refresh callbacks.
reset()
WG.SV.Guild = {}
for Index = 1, 5 do WG.SV.Guild[Index] = 41 + Index; WG.SV["Guild" .. Index] = {} end
local MenuInfo = {
  [99999] = {0, "Zzz"}, [900] = {1, "ALPHA^ns"}, [901] = {1, "alpha^ms"},
  [10] = {1, "zinc"}, [1] = {2, "Abricot"}, [2] = {2, "beta"},
  [3] = {3, "gamma"}, [4] = {4, "ambre"}, [5] = {5, "Citron"},
}
GetItemLinkDisplayQuality = function(Link) return MenuInfo[GetItemLinkItemId(Link)][1] end
GetItemLinkName = function(Link) return MenuInfo[GetItemLinkItemId(Link)][2] end
LocaleAwareToLower = string.lower
SI_TOOLTIP_ITEM_NAME = "item-name-format"
local OriginalFormat = zo_strformat
zo_strformat = function(Format, ...)
  if Format == SI_TOOLTIP_ITEM_NAME then return ((...):gsub("%^.*", "")) end
  return OriginalFormat(Format, ...)
end
local Ordered = {
  item(99999, 1), item(900, 1), item(900, 1, 200, 2), item(901, 1),
  item(10, 1), item(1, 1), item(2, 1), item(3, 1), item(4, 1), item(5, 1),
}
for Index, Item in ipairs(Ordered) do Bag[12 - Index] = Item end
Bag[0] = item(900, 8) --Duplicate link, different stack count; slot 1 is empty.
WG.BuildMenu()
local Dropdowns, RefreshButtons, StoreButtons = {}, {}, {}
for _, Option in ipairs(Options) do
  if Option.controls then
    for _, Control in ipairs(Option.controls) do
      if Control.name == WG.Lang.GUILD_ITEM_SCROLL then table.insert(Dropdowns, Control) end
      if Control.name == WG.Lang.GUILD_UPDATE_ITEM_LIST then table.insert(RefreshButtons, Control) end
      if Control.name == WG.Lang.GUILD_STORE_ALL then table.insert(StoreButtons, Control) end
    end
  end
end
check("item dropdown exists in all five guild menus", #Dropdowns == 5 and #RefreshButtons == 5 and #StoreButtons == 5)
for Index, Dropdown in ipairs(Dropdowns) do
  local Choices = Dropdown.choices
  check("guild " .. Index .. ": placeholder remains first", Choices[1] == "/")
  check("guild " .. Index .. ": empty slots and duplicate links excluded", #Choices == #Ordered + 1)
  local Correct = true
  for Position, Item in ipairs(Ordered) do
    if Choices[Position + 1] ~= link(Item) then Correct = false end
  end
  check("guild " .. Index .. ": ascending quality, case-insensitive name and deterministic tie", Correct)
  check("guild " .. Index .. ": no LAM sort overrides the precomputed order", Dropdown.sort == nil and Dropdown.choicesValues == nil)
  Dropdown.setFunc(Choices[4])
  check("guild " .. Index .. ": selected value remains the original item link", Dropdown.getFunc() == link(Ordered[3]))
  StoreButtons[Index].func()
  check("guild " .. Index .. ": new rule targets exactly the selected variant",
    WG.SV["Guild" .. Index][1].ItemLink == link(Ordered[3]))
  local Updates = 0
  local Control = {data = {}}
  Control.UpdateChoices = function() Updates = Updates + 1 end
  _G["WG_Guild_" .. Index .. "_Item"] = Control
  MenuInfo[5] = {0, "Aaa"}
  RefreshButtons[Index].func()
  check("guild " .. Index .. ": refresh recomputes quality and name order",
    Control.data.choices[2] == link(Ordered[10]) and Control.data.choices[3] == link(Ordered[1]) and Updates == 1)
  check("guild " .. Index .. ": refresh clears previous selection", Dropdown.getFunc() == "/")
  MenuInfo[5] = {5, "Citron"}
end
Bag = {}
RefreshButtons[1].func()
check("empty backpack produces only the placeholder", #WG_Guild_1_Item.data.choices == 1 and WG_Guild_1_Item.data.choices[1] == "/")
zo_strformat = OriginalFormat

--Guild-bank link bug beyond level 0/1: the same rune's bank link reports a
--different internal level (50 here) and an unparsable quality/CP. Runes and
--other stackable items have no level notion: the same ItemId is the same
--item and every bank stack must be borrowed and regrouped.
reset()
Bag[0] = item(45856, 12)
Bank[4], Bank[5] = item(45856, 3), item(45856, 5)
local RealGetItemLink2 = GetItemLink
GetItemLink = function(BagId, Slot)
  local Text = RealGetItemLink2(BagId, Slot)
  if BagId == 3 and Text ~= "" then
    return (Text:gsub("^(|H1:item:%d+:%d+):%d+:", "%1:50:"))
  end
  return Text
end
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 45856, Count = 10}})
GetItemLink = RealGetItemLink2
check("rune link bug: 10 stay in the backpack", total(1, 45856) == 10)
check("rune link bug: one bank stack of 10", total(3, 45856) == 10 and select(2, total(3, 45856)) == 1)
check("rune link bug: both bank stacks borrowed", numOps("take") == 2)
check("rune link bug: no mismatch message", not hasMessage("different level, quality or link"))

--Guild-bank link bug: the bank reports internal level 0/1 in its item links
--while the backpack reports the real level. A TAKE_TO rule keeping 10 with 12
--in the bag must borrow every existing bank stack (3+2+5), stack them in the
--backpack and redeposit the whole amount (12) as one stack.
reset()
Bag[0] = item(30157, 12)
Bank[4], Bank[5], Bank[6] = item(30157, 3), item(30157, 2), item(30157, 5)
local RealGetItemLink = GetItemLink
GetItemLink = function(BagId, Slot)
  local Text = RealGetItemLink(BagId, Slot)
  if BagId == 3 and Text ~= "" then
    return Text:gsub("^(|H1:item:%d+:%d+):%d+:", "%1:0:")
  end
  return Text
end
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 30157, Count = 10}})
GetItemLink = RealGetItemLink
check("link bug: exactly 10 stay in the backpack", total(1, 30157) == 10)
check("link bug: all 22 items conserved", total(1, 30157) + total(3, 30157) == 22)
check("link bug: the 12 redeposited form one bank stack",
  total(3, 30157) == 12 and select(2, total(3, 30157)) == 1)
check("link bug: all three bank stacks borrowed", numOps("take") == 3)
check("link bug: no mismatch message when regroup runs",
  not hasMessage("different level, quality or link"))
check("link bug: borrowing the stacks is announced", hasMessage("withdrawing"))
check("link bug: the redeposit is announced", hasMessage("deposited back"))

--Same scenario without the link bug: identical behavior, still one message.
reset()
Bag[0] = item(30157, 12)
Bank[4], Bank[5], Bank[6] = item(30157, 3), item(30157, 2), item(30157, 5)
run({{GuildId = 42, Type = WAREGUILD_TAKE_TO, ItemId = 30157, Count = 10}})
check("no link bug: 10 in the bag and one bank stack of 12",
  total(1, 30157) == 10 and total(3, 30157) == 12 and select(2, total(3, 30157)) == 1)
check("no link bug: borrowing announced once", numOps("take") == 3)


--Withdraw-unknown rule: the active character retrieves every guild bank
--item it has not learned yet (LibCharacterKnowledge), through the menu
--button next to the deposit one and through the step itself.
reset(); installLCK()
local function selfUnknown(Id) Knowledge[Id] = {entry("self", 2)} end
local function selfKnown(Id) Knowledge[Id] = {entry("self", 1)} end
selfUnknown(30157)
check("current character unknown item qualifies", WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))
selfKnown(30157)
check("current character known item does not qualify", not WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))
Knowledge[30157] = {entry("alt", 2)}
check("alt-only unknown does not qualify for the active character", not WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))
Knowledge[30157] = {entry("self", 0)}
check("nodata never counts as unknown", not WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))
Knowledge[30157] = {entry("self", 2, "@someoneelse")}
check("foreign account never counts", not WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))
ResearchItems[10003] = {1, 3, 5}
ResearchKnowledge[3] = {entry("self", 2, nil, 300)}
check("research in progress not requested", not WG.IsUnknownToCurrentCharacter(link(item(10003, 1))))
ResearchKnowledge[3] = {entry("self", 2)}
check("unresearched trait requested", WG.IsUnknownToCurrentCharacter(link(item(10003, 1))))
LibCharacterKnowledge = nil
check("LCK missing: current-character predicate false", not WG.IsUnknownToCurrentCharacter(link(item(30157, 1))))

--Execution: only the items unknown to the active character are withdrawn.
reset(); installLCK()
selfUnknown(30157); selfKnown(30158)
Knowledge[30159] = {entry("alt", 2)}
Bank[4], Bank[5], Bank[6] = item(30157, 1), item(30158, 1), item(30159, 1)
run({{GuildId = 42, Type = WAREGUILD_TAKE_UNKNOWN}})
check("unknown item withdrawn to the backpack", total(1, 30157) == 1)
check("known item stays in the bank", total(3, 30158) == 1)
check("alt-only item stays in the bank", total(3, 30159) == 1)
check("exactly one withdrawal", numOps("take") == 1)
check("step description identifies the new rule",
  WG.StepToString({Type = WAREGUILD_TAKE_UNKNOWN}):find(WG.Lang.CHAT_TAKE_UNKNOWN, 1, true) ~= nil)

--Menu: the withdraw button sits right of the deposit button in every guild.
reset(); installLCK()
WG.SV.Guild = {}
for Index = 1, 5 do WG.SV.Guild[Index] = 41 + Index; WG.SV["Guild" .. Index] = {} end
GetGuildId = function(Index) return 41 + Index end
WG.BuildMenu()
local DepositButtons, WithdrawButtons = {}, {}
for _, Option in ipairs(Options) do
  if Option.controls then
    local DepositAt, WithdrawAt
    for Position, Control in ipairs(Option.controls) do
      if Control.name == WG.Lang.GUILD_STORE_UNKNOWN then
        DepositAt = Position; table.insert(DepositButtons, Control)
      end
      if Control.name == WG.Lang.GUILD_TAKE_UNKNOWN then
        WithdrawAt = Position; table.insert(WithdrawButtons, Control)
      end
    end
    if DepositAt then
      check("withdraw button right of the deposit button", WithdrawAt == DepositAt + 1)
    end
  end
end
check("one button pair per guild", #DepositButtons == 5 and #WithdrawButtons == 5)
check("buttons are half width", DepositButtons[1].width == "half" and WithdrawButtons[1].width == "half")
check("withdraw button enabled with library", not WithdrawButtons[3].disabled())
WithdrawButtons[3].func()
check("menu creates rule in selected guild only", #WG.SV.Guild3 == 1 and WG.SV.Guild3[1].GuildId == 44
  and WG.SV.Guild3[1].Type == WAREGUILD_TAKE_UNKNOWN and #WG.SV.Guild1 == 0)
WithdrawButtons[3].func()
check("each click adds one rule, like the deposit button", #WG.SV.Guild3 == 2)
WG.SV.Guild[4] = false
WithdrawButtons[4].func()
check("rule still created for an unselected guild slot, like the deposit button",
  #WG.SV.Guild4 == 1 and WG.SV.Guild4[1].GuildId == false)
LibCharacterKnowledge = nil
check("withdraw button disabled without library", WithdrawButtons[2].disabled())
WithdrawButtons[2].func()
check("disabled withdraw function cannot add rule", #WG.SV.Guild2 == 0)

print(string.format("deposit, knowledge and menu passed=%d failed=%d", Passed, Failed))
if Failed > 0 then os.exit(1) end
