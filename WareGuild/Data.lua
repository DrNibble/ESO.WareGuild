--Name Space
SDC_WareGuild = {}
local WG = SDC_WareGuild

--StepType_TAKE
WAREGUILD_TAKE_TO = 11
WAREGUILD_TAKE_ALL = 12
WAREGUILD_DAILY = 31
--StepType_STORE
WAREGUILD_STORE_TO = 21
WAREGUILD_STORE_ALL = 22
--Materials
WAREGUILD_STORE_B = 1 --BlackSmith
WAREGUILD_STORE_C = 2 --Clothing
WAREGUILD_STORE_E = 3 --Enchanting
WAREGUILD_STORE_A = 4 --Alchemy
WAREGUILD_STORE_P = 5 --Provisioning
WAREGUILD_STORE_W = 6 --Woodworking
WAREGUILD_STORE_J = 7 --Jewelry

WAREGUILD_STORE_S = 8 --Style Materials
WAREGUILD_STORE_T = 9 --Trait Items
--QueueType
WAREGUILD_QUEUE_TAKE = 0
WAREGUILD_QUEUE_STORE = 1
WAREGUILD_QUEUE_SPLIT = 2

-------------------
----Daily Writs----
-------------------
--[[
function Test(Item, Material, Type)
  for i = 0, Material do
    local PI, MI = GetSmithingPatternInfoForItemId(Item, i, Type)
    if MI then
      local Link = GetSmithingPatternMaterialItemLink(PI, MI)
      d(i..Link..GetItemLinkItemId(Link))
    end
  end
end
]]

WG.MaterialExcel = { --craftingSkillType, ItemId, MaterialId -> Count
  [1] = { --Black
    --146铁锭 152钢锭 156山铜 160矮人 164乌木 168月长 172水钢 176水银 180虚无 188赤晶
    [43529] = {
      [146] = {5413 ,  3}, [152] = {4487 ,  4}, [156] = {23107, 5 }, [160] = {6000 , 6 }, [164] = {6001 , 7 },
      [168] = {46127,  8}, [172] = {46128,  9}, [176] = {46129, 10}, [180] = {46130, 11}, [188] = {64489, 11},
      },
    [43530] = {
      [146] = {5413 ,  3}, [152] = {4487 ,  4}, [156] = {23107, 5 }, [160] = {6000 , 6 }, [164] = {6001 , 7 },
      [168] = {46127,  8}, [172] = {46128,  9}, [176] = {46129, 10}, [180] = {46130, 11}, [188] = {64489, 11},
      },
    [43531] = {
      [146] = {5413 ,  3}, [152] = {4487 ,  4}, [156] = {23107, 5 }, [160] = {6000 , 6 }, [164] = {6001 , 7 },
      [168] = {46127,  8}, [172] = {46128,  9}, [176] = {46129, 10}, [180] = {46130, 11}, [188] = {64489, 11},
      },
    [43532] = {
      [146] = {5413 , 5 }, [152] = {4487 , 6 }, [156] = {23107, 7 }, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 14},
      },
    [43533] = {
      [146] = {5413 , 5 }, [152] = {4487 , 6 }, [156] = {23107, 7 }, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 14},
      },
    [43534] = {
      [146] = {5413 , 5 }, [152] = {4487 , 6 }, [156] = {23107, 7 }, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 14},
      },
    [43535] = {
      [146] = {5413 ,  2}, [152] = {4487 ,  3}, [156] = {23107,  4}, [160] = {6000 , 5 }, [164] = {6001 , 6 },
      [168] = {46127,  7}, [172] = {46128,  8}, [176] = {46129,  9}, [180] = {46130, 10}, [188] = {64489, 10},
      },
    --Armor
    [43537] = {
      [146] = {5413 , 7 }, [152] = {4487 ,  8}, [156] = {23107,  9}, [160] = {6000 , 10}, [164] = {6001 , 11},
      [168] = {46127, 12}, [172] = {46128, 13}, [176] = {46129, 14}, [180] = {46130, 15}, [188] = {64489, 15},
      },
    [43538] = {
      [146] = {5413 ,  5}, [152] = {4487 ,  6}, [156] = {23107,  7}, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 13},
      },
    [43539] = {
      [146] = {5413 ,  5}, [152] = {4487 ,  6}, [156] = {23107,  7}, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 13},
      },
    [43562] = {
      [146] = {5413 ,  5}, [152] = {4487 ,  6}, [156] = {23107,  7}, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 13},
      },
    [43540] = {
      [146] = {5413 ,  6}, [152] = {4487 ,  7}, [156] = {23107,  8}, [160] = {6000 , 9 }, [164] = {6001 , 10},
      [168] = {46127, 11}, [172] = {46128, 12}, [176] = {46129, 13}, [180] = {46130, 14}, [188] = {64489, 14},
      },
    [43541] = {
      [146] = {5413 ,  5}, [152] = {4487 ,  6}, [156] = {23107,  7}, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 13},
      },
    [43542] = {
      [146] = {5413 ,  5}, [152] = {4487 ,  6}, [156] = {23107,  7}, [160] = {6000 , 8 }, [164] = {6001 , 9 },
      [168] = {46127, 10}, [172] = {46128, 11}, [176] = {46129, 12}, [180] = {46130, 13}, [188] = {64489, 13},
      },
    },
  [2] = { --Cloth
    --149黄麻 155亚麻 159棉花 163蛛丝 167乌丝 169克雷 173紫苑 177银叶 181虚无 194先祖
    [43543] = {
      [149] = {811  , 7 }, [155] = {4463 , 8 }, [159] = {23125, 9 }, [163] = {23126, 10}, [167] = {23127, 11},
      [169] = {46131, 12}, [173] = {46132, 13}, [177] = {46133, 14}, [181] = {46134, 15}, [194] = {64504, 15},
      },
    [44241] = {
      [149] = {811  , 7 }, [155] = {4463 , 8 }, [159] = {23125, 9 }, [163] = {23126, 10}, [167] = {23127, 11},
      [169] = {46131, 12}, [173] = {46132, 13}, [177] = {46133, 14}, [181] = {46134, 15}, [194] = {64504, 15},
      },
    [43544] = {
      [149] = {811  , 5 }, [155] = {4463 , 6 }, [159] = {23125, 7 }, [163] = {23126, 8 }, [167] = {23127, 9 },
      [169] = {46131, 10}, [173] = {46132, 11}, [177] = {46133, 12}, [181] = {46134, 13}, [194] = {64504, 13},
      },
    [43545] = {
      [149] = {811  , 5 }, [155] = {4463 , 6 }, [159] = {23125, 7 }, [163] = {23126, 8 }, [167] = {23127, 9 },
      [169] = {46131, 10}, [173] = {46132, 11}, [177] = {46133, 12}, [181] = {46134, 13}, [194] = {64504, 13},
      },
    [43564] = {
      [149] = {811  , 5 }, [155] = {4463 , 6 }, [159] = {23125, 7 }, [163] = {23126, 8 }, [167] = {23127, 9 },
      [169] = {46131, 10}, [173] = {46132, 11}, [177] = {46133, 12}, [181] = {46134, 13}, [194] = {64504, 13},
      },
    [43546] = {
      [149] = {811  , 6 }, [155] = {4463 , 7 }, [159] = {23125, 8 }, [163] = {23126, 9 }, [167] = {23127, 10},
      [169] = {46131, 11}, [173] = {46132, 12}, [177] = {46133, 13}, [181] = {46134, 14}, [194] = {64504, 14},
      },
    [43547] = {
      [149] = {811  , 5 }, [155] = {4463 , 6 }, [159] = {23125, 7 }, [163] = {23126, 8 }, [167] = {23127, 9 },
      [169] = {46131, 10}, [173] = {46132, 11}, [177] = {46133, 12}, [181] = {46134, 13}, [194] = {64504, 13},
      },
    [43548] = {
      [149] = {811  , 5 }, [155] = {4463 , 6 }, [159] = {23125, 7 }, [163] = {23126, 8 }, [167] = {23127, 9 },
      [169] = {46131, 10}, [173] = {46132, 11}, [177] = {46133, 12}, [181] = {46134, 13}, [194] = {64504, 13},
      },
    --148生皮 154兽皮 158皮革 162厚皮 166脱落 170顶级 174铁制 178上等 182暗影 190发红
    [43550] = {
      [148] = {794  , 7 }, [154] = {4447 , 8 }, [158] = {23099, 9 }, [162] = {23100, 10}, [166] = {23101, 11},
      [170] = {46135, 12}, [174] = {46136, 13}, [178] = {46137, 14}, [182] = {46138, 15}, [190] = {64506, 15},
      },
    [43551] = {
      [148] = {794  , 5 }, [154] = {4447 , 6 }, [158] = {23099, 7 }, [162] = {23100, 8 }, [166] = {23101, 9 },
      [170] = {46135, 10}, [174] = {46136, 11}, [178] = {46137, 12}, [182] = {46138, 13}, [190] = {64506, 13},
      },
    [43552] = {
      [148] = {794  , 5 }, [154] = {4447 , 6 }, [158] = {23099, 7 }, [162] = {23100, 8 }, [166] = {23101, 9 },
      [170] = {46135, 10}, [174] = {46136, 11}, [178] = {46137, 12}, [182] = {46138, 13}, [190] = {64506, 13},
      },
    [43563] = {
      [148] = {794  , 5 }, [154] = {4447 , 6 }, [158] = {23099, 7 }, [162] = {23100, 8 }, [166] = {23101, 9 },
      [170] = {46135, 10}, [174] = {46136, 11}, [178] = {46137, 12}, [182] = {46138, 13}, [190] = {64506, 13},
      },
    [43553] = {
      [148] = {794  , 6 }, [154] = {4447 , 7 }, [158] = {23099, 8 }, [162] = {23100, 9 }, [166] = {23101, 10},
      [170] = {46135, 11}, [174] = {46136, 12}, [178] = {46137, 13}, [182] = {46138, 14}, [190] = {64506, 14},
      },
    [43554] = {
      [148] = {794  , 5 }, [154] = {4447 , 6 }, [158] = {23099, 7 }, [162] = {23100, 8 }, [166] = {23101, 9 },
      [170] = {46135, 10}, [174] = {46136, 11}, [178] = {46137, 12}, [182] = {46138, 13}, [190] = {64506, 13},
      },
    [43555] = {
      [148] = {794  , 5 }, [154] = {4447 , 6 }, [158] = {23099, 7 }, [162] = {23100, 8 }, [166] = {23101, 9 },
      [170] = {46135, 10}, [174] = {46136, 11}, [178] = {46137, 12}, [182] = {46138, 13}, [190] = {64506, 13},
      },
  },
  [6] = { --Wood
    --147枫木 153橡木 157榉木 161核桃 165紫衫 171桦木 175梣木 179红木 183夜木 192赤晶
    [43549] = {
      [147] = {803  , 3 }, [153] = {533,   4 }, [157] = {23121, 5 }, [161] = {23122, 6 }, [165] = {23123, 7 }, 
      [171] = {46139, 8 }, [175] = {46140, 9 }, [179] = {46141, 10}, [183] = {46142, 11}, [192] = {64502, 12}, 
      },
    [43556] = {
      [147] = {803  , 6 }, [153] = {533,   7 }, [157] = {23121, 8 }, [161] = {23122, 9 }, [165] = {23123, 10}, 
      [171] = {46139, 11}, [175] = {46140, 12}, [179] = {46141, 13}, [183] = {46142, 14}, [192] = {64502, 14}, 
      },
    [43557] = {
      [147] = {803  , 3 }, [153] = {533,   4 }, [157] = {23121, 5 }, [161] = {23122, 6 }, [165] = {23123, 7 }, 
      [171] = {46139, 8 }, [175] = {46140, 9 }, [179] = {46141, 10}, [183] = {46142, 11}, [192] = {64502, 12}, 
      },
    [43558] = {
      [147] = {803  , 3 }, [153] = {533,   4 }, [157] = {23121, 5 }, [161] = {23122, 6 }, [165] = {23123, 7 }, 
      [171] = {46139, 8 }, [175] = {46140, 9 }, [179] = {46141, 10}, [183] = {46142, 11}, [192] = {64502, 12}, 
      },
    [43559] = {
      [147] = {803  , 3 }, [153] = {533,   4 }, [157] = {23121, 5 }, [161] = {23122, 6 }, [165] = {23123, 7 }, 
      [171] = {46139, 8 }, [175] = {46140, 9 }, [179] = {46141, 10}, [183] = {46142, 11}, [192] = {64502, 12}, 
      },
    [43560] = {
      [147] = {803  , 3 }, [153] = {533,   4 }, [157] = {23121, 5 }, [161] = {23122, 6 }, [165] = {23123, 7 }, 
      [171] = {46139, 8 }, [175] = {46140, 9 }, [179] = {46141, 10}, [183] = {46142, 11}, [192] = {64502, 12}, 
      },
  },
  [7] = { --Jawelly
    --6 56 137 139 255
    [43536] = {
      [6] = {135138, 2}, [56] = {135140, 3}, [137] = {135142, 4}, [139] = {135144, 6}, [255] = {135146, 10},
      },
    [43561] = {
      [6] = {135138, 3}, [56] = {135140, 5}, [137] = {135142, 6}, [139] = {135144, 8}, [255] = {135146, 15},
      },
  },
  [3] = { --Enchant
    ["Level"] = { --Potency
      [102] = {45855, 45817},--1
      [103] = {45856, 45818},--5
      [104] = {45857, 45819},--10
      [105] = {45806, 45820},--15
      [106] = {45807, 45821},--20
      [107] = {45808, 45822},--25
      [108] = {45809, 45823},--30
      [109] = {45810, 45824},--35
      [110] = {45811, 45825},--40
      [111] = {45812, 45826},--cp10
      [112] = {45813, 45827},--cp30
      [113] = {45814, 45828},--cp50
      [114] = {45815, 45829},--cp70
      [115] = {45816, 45830},--cp100
      [207] = {64509, 64508},--cp150
      [225] = {68341, 68340},--cp160
    },
    ["Id"] = { --Essence
      [26580] = {1, 45831}, [43573] = {2, 45831},
      [26582] = {1, 45832}, [45868] = {2, 45832},
      [26588] = {1, 45833}, [45867] = {2, 45833},
      [26581] = {1, 45834}, [45869] = {2, 45834},
      [26583] = {1, 45835}, [45870] = {2, 45835},
      [26589] = {1, 45836}, [45871] = {2, 45836},
      [26587] = {1, 45837}, [26586] = {2, 45837},
      [26848] = {1, 45838}, [26849] = {2, 45838},
      [5365]  = {1, 45839},  [5364] = {2, 45839},
      [26844] = {1, 45840}, [43570] = {2, 45840},
      [26841] = {1, 45841}, [26847] = {2, 45841},
      [5366]  = {1, 45842}, [26845] = {2, 45842},
      [54484] = {1, 45843}, [26591] = {2, 45843},
      [45874] = {1, 45846}, [45875] = {2, 45846},
      [45883] = {1, 45847}, [45885] = {2, 45847}, 
      [45884] = {1, 45848}, [45886] = {2, 45848},
      [45872] = {1, 45849}, [45873] = {2, 45849},
      [68343] = {1, 68342}, [68344] = {2, 68342}, --Hakeijo
      [166047]= {1, 166045},[166046]= {2, 166045},
    },
    ["Quilty"] = { --Aspect
      [1] = 45850,  --Ta
      [2] = 45851,  --Jejota
      [3] = 45852,  --Denata
      [4] = 45853,  --Rekuta
      [5] = 45854,  --Kuta
    },
  },
}

--Material Id to Link
local function ToLink(Id)
  if not Id then return "" end
  return "|H1:item:"..Id..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

--Materials still need to take
local function MaterialCount(ItemId, NumTotal, Ignore)
  --ItemLink
  local ItemLink = ToLink(ItemId)
  --Current Stack
  local BackbagCount, BankCount, CraftbagCount =  GetItemLinkStacks(ItemLink)
  
  --Ignore Inventory Setting
  if WG.SV.IgnoreInventory or Ignore then 
    return (NumTotal + BackbagCount)
  end
  
  --Count Inventory
  local NumLack = NumTotal - BackbagCount - BankCount - CraftbagCount
  if NumLack > 0 then
    --Need to Withdraw
    return (NumLack + BackbagCount)
  else
    --No Need to Withdraw
    return 0
  end
end

--Find a Slot of an Item in the Backpack or the Guild Bank
--(the Enchanting/Alchemy Result Link Functions Need Slots)
local function FindSlot(ItemId)
  local Slot = WG.FindItem(1, ItemId, nil)
  if #Slot > 0 then return 1, Slot[1]["SlotId"] end
  Slot = WG.FindItem(3, ItemId, nil)
  if #Slot > 0 then return 3, Slot[1]["SlotId"] end
end

--Count Stacks of an Item in the Backpack and the Guild Bank
local function ProductTotal(ItemId)
  return WG.FindItem(1, ItemId, nil)["Total"] + WG.FindItem(3, ItemId, nil)["Total"]
end

--Count the Daily Writs Products: Any Style, No Trait, White Quality Only
--(a Gear ItemId Does Not Encode the Trait or the Quality, So the Bank
--Stacks Are Checked With GetItemLinkQuality / GetItemLinkTraitInfo)
local function SmithingProductTotal(ItemId)
  local Total = 0
  for _, BagId in ipairs({1, 3}) do
    local Slot = WG.FindItem(BagId, ItemId, nil)
    for i = 1, #Slot do
      local Link = GetItemLink(BagId, Slot[i]["SlotId"])
      if GetItemLinkQuality(Link) == ITEM_QUALITY_NORMAL
        and GetItemLinkTraitInfo(Link) == ITEM_TRAIT_TYPE_NONE then
        Total = Total + Slot[i]["Count"]
      end
    end
  end
  return Total
end

--LazyCrafting (LibLazyCrafting) Queue
--Materials Needed for the Items to Craft, and Finished Products
--Available in the Backpack or the Guild Bank: When the Finished Product
--Is Available, It Is Retrieved from the Guild Bank Instead of Withdrawing
--the Materials (the Material Count Is Reduced Accordingly).
--
--Daily Writs Products (Sword, Helmet, Staff, Shield...): Any Style,
--No Trait, White Quality. The Style Does Not Change the ItemId, So Any
--Style Is Used to Build the Link When the Request Has a Free Style
--Choice (LLC_FREE_STYLE_CHOICE, Used by Lazy Writ Crafter for the
--Writs). A Request With a Trait or a Set Cannot Be Fulfilled by Such a
--Product: Materials Only. Jewelry (Station 7), Enchanting, Alchemy and
--Provisioning Are Supported Too When LibLazyCrafting Queues Them.
--Returns: Materials[ItemId] = Count, Products[ItemId] = {ItemLink, Count},
--Replaced[ItemId] = Count (Materials Covered by the Products)
function WG.FindLazyCraftingItem()
  local Materials = {}
  local Products = {}
  local Replaced = {}
  --Setting Off or LibLazyCrafting Missing
  if not WG.SV.LazyCrafting then return Materials, Products, Replaced end
  if not LibLazyCrafting or type(LibLazyCrafting.craftingQueue) ~= "table" then return Materials, Products, Replaced end

  --Add Materials Still Needed
  local function AddMaterial(ItemId, Count)
    if ItemId and ItemId ~= 0 and Count > 0 then
      Materials[ItemId] = (Materials[ItemId] or 0) + Count
    end
  end

  --Add a Finished Product to Retrieve
  local function AddProduct(ItemId, ItemLink, Count)
    if not Products[ItemId] then
      Products[ItemId] = {["ItemLink"] = ItemLink, ["Count"] = 0}
    end
    Products[ItemId]["Count"] = Products[ItemId]["Count"] + Count
  end

  --Cover Materials With the Available Products
  local function AddReplaced(ItemId, Count)
    if ItemId and ItemId ~= 0 and Count > 0 then
      Replaced[ItemId] = (Replaced[ItemId] or 0) + Count
    end
  end

  --Station: 1 BlackSmith(Steel) 2 Clothier(Textile) 6 Woodworking(Wood) 7 Jewelry
  local StationList = {
    [CRAFTING_TYPE_BLACKSMITHING] = true,
    [CRAFTING_TYPE_CLOTHIER] = true,
    [CRAFTING_TYPE_WOODWORKING] = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
  }

  --Smithing Request (BlackSmith/Clothier/Woodworking/Jewelry)
  local function HandleSmithing(Request)
    if Request["type"] ~= "smithing" then return end
    if not (Request["pattern"] and Request["materialIndex"]) then return end
    --Number of Items Requested
    local Num = Request["smithingQuantity"] or 1
    --Finished Product (Sword, Helmet, Staff, Shield...)
    --No Trait and No Set Only: Writ Products Are White, No Trait, Any Style
    local Have = 0
    local ProductId, ProductLink
    if WG.SV.LazyCraftingProduct
      and (Request["trait"] == nil or Request["trait"] == 1)
      and (Request["setIndex"] == nil or Request["setIndex"] == 0) then
      --The Style Does Not Change the ItemId: Use Any Style
      local Style = type(Request["style"]) == "number" and Request["style"] or 1
      ProductLink = GetSmithingPatternResultLink(
        Request["pattern"], Request["materialIndex"],
        Request["materialQuantity"] or 1, Style, 1, 0)
      if ProductLink and ProductLink ~= "" then
        ProductId = GetItemLinkItemId(ProductLink)
        if not ProductId or ProductId == 0 then ProductId = nil end
      end
      if ProductId then
        Have = math.min(Num, SmithingProductTotal(ProductId))
      end
    end
    --Material Link of this Pattern and Tier
    local Link = GetSmithingPatternMaterialItemLink(Request["pattern"], Request["materialIndex"], 0)
    local ItemId, Per
    if Link ~= "" then
      ItemId = GetItemLinkItemId(Link)
      Per = Request["materialQuantity"] or 0
    end
    --Take the Finished Product Instead of the Materials
    if Have > 0 and ItemId and ItemId ~= 0 and Per > 0 then
      Num = Num - Have
      AddProduct(ProductId, ProductLink, Have)
      AddReplaced(ItemId, Per * Have)
    end
    --Materials for the Items Still to Craft
    if Num > 0 and ItemId and ItemId ~= 0 and Per > 0 then
      AddMaterial(ItemId, Per * Num)
    end
  end

  --Enchanting Request (Runes): the Glyph Is the Finished Product
  local function HandleEnchanting(Request)
    local Potency = Request["potencyItemID"]
    local Essence = Request["essenceItemID"]
    local Aspect = Request["aspectItemID"]
    if not (Potency and Essence and Aspect) then return end
    local Num = Request["quantity"] or 1
    --Finished Product: the Glyph Link Needs the Rune Slots
    local Have = 0
    local ProductId, ProductLink
    if WG.SV.LazyCraftingProduct then
      local pBag, pSlot = FindSlot(Potency)
      local eBag, eSlot = FindSlot(Essence)
      local aBag, aSlot = FindSlot(Aspect)
      if pBag and eBag and aBag then
        ProductLink = GetEnchantingResultingItemLink(pBag, pSlot, eBag, eSlot, aBag, aSlot, 0)
        if ProductLink and ProductLink ~= "" then
          ProductId = GetItemLinkItemId(ProductLink)
          if ProductId and ProductId ~= 0 then
            Have = math.min(Num, ProductTotal(ProductId))
          else
            ProductId = nil
          end
        end
      end
    end
    --Take the Glyph Instead of the Runes
    if Have > 0 then
      Num = Num - Have
      AddProduct(ProductId, ProductLink, Have)
      AddReplaced(Potency, Have)
      AddReplaced(Essence, Have)
      AddReplaced(Aspect, Have)
    end
    --Runes for the Glyphs Still to Craft
    if Num > 0 then
      AddMaterial(Potency, Num)
      AddMaterial(Essence, Num)
      AddMaterial(Aspect, Num)
    end
  end

  --Alchemy Request (Solvent and Reagents): the Potion Is the Finished Product
  local function HandleAlchemy(Request)
    local Solvent = Request["solventId"]
    local Reagent1 = Request["reagentId1"]
    local Reagent2 = Request["reagentId2"]
    local Reagent3 = Request["reagentId3"]
    if not (Solvent and Reagent1 and Reagent2) then return end
    local Num = Request["timesToMake"] or 1
    --Finished Product: the Potion Link Needs the Solvent/Reagent Slots
    local Have = 0
    local ProductId, ProductLink
    if WG.SV.LazyCraftingProduct then
      local sBag, sSlot = FindSlot(Solvent)
      local r1Bag, r1Slot = FindSlot(Reagent1)
      local r2Bag, r2Slot = FindSlot(Reagent2)
      if sBag and r1Bag and r2Bag then
        if Reagent3 then
          local r3Bag, r3Slot = FindSlot(Reagent3)
          if r3Bag then
            ProductLink = GetAlchemyResultingItemLink(sBag, sSlot, r1Bag, r1Slot, r2Bag, r2Slot, r3Bag, r3Slot, 0)
          end
        else
          ProductLink = GetAlchemyResultingItemLink(sBag, sSlot, r1Bag, r1Slot, r2Bag, r2Slot, nil, nil, 0)
        end
        if ProductLink and ProductLink ~= "" then
          ProductId = GetItemLinkItemId(ProductLink)
          if ProductId and ProductId ~= 0 then
            Have = math.min(Num, ProductTotal(ProductId))
          else
            ProductId = nil
          end
        end
      end
    end
    --Take the Potion Instead of the Materials
    if Have > 0 then
      Num = Num - Have
      AddProduct(ProductId, ProductLink, Have)
      AddReplaced(Solvent, Have)
      AddReplaced(Reagent1, Have)
      AddReplaced(Reagent2, Have)
      AddReplaced(Reagent3, Have)
    end
    --Materials for the Potions Still to Craft
    if Num > 0 then
      AddMaterial(Solvent, Num)
      AddMaterial(Reagent1, Num)
      AddMaterial(Reagent2, Num)
      AddMaterial(Reagent3, Num)
    end
  end

  --Provisioning Request (Recipe): the Food/Drink Is the Finished Product
  local function HandleProvisioning(Request)
    local ListIndex = Request["recipeListIndex"]
    local RecipeIndex = Request["recipeIndex"]
    if not (ListIndex and RecipeIndex) then return end
    local Num = Request["timesToMake"] or 1
    local _, _, NumIngredients = GetRecipeInfo(ListIndex, RecipeIndex)
    --Finished Product Link
    local Have = 0
    local ProductId, ProductLink, Per = nil, nil, 1
    if WG.SV.LazyCraftingProduct then
      ProductLink = Request["resultLink"]
      if not ProductLink or ProductLink == "" then
        ProductLink = GetRecipeResultItemLink(ListIndex, RecipeIndex, 0)
      end
      if ProductLink and ProductLink ~= "" then
        ProductId = GetItemLinkItemId(ProductLink)
        if ProductId and ProductId ~= 0 then
          --Items Made per Craft (Recipes Make 1, 2 or 4 Items)
          Per = GetRecipeResultQuantity(ListIndex, RecipeIndex, 1)
          if not Per or Per < 1 then Per = 1 end
          Have = math.min(Num * Per, ProductTotal(ProductId))
        else
          ProductId = nil
        end
      end
    end
    --Take the Food/Drink Instead of the Ingredients
    if Have > 0 then
      --Crafts Covered by the Available Products
      local Covered = math.floor(Have / Per)
      Num = Num - Covered
      AddProduct(ProductId, ProductLink, Have)
      for i = 1, NumIngredients do
        local Link = GetRecipeIngredientItemLink(ListIndex, RecipeIndex, i, 0)
        AddReplaced(GetItemLinkItemId(Link), GetRecipeIngredientRequiredQuantity(ListIndex, RecipeIndex, i) * Covered)
      end
    end
    --Ingredients for the Crafts Still to Do
    if Num > 0 then
      for i = 1, NumIngredients do
        local Link = GetRecipeIngredientItemLink(ListIndex, RecipeIndex, i, 0)
        AddMaterial(GetItemLinkItemId(Link), GetRecipeIngredientRequiredQuantity(ListIndex, RecipeIndex, i) * Num)
      end
    end
  end

  --Queue: [AddonName][Station][n] = Request
  for _, Requests in pairs(LibLazyCrafting.craftingQueue) do
    if type(Requests) == "table" then
      for StationId, List in pairs(Requests) do
        if type(List) == "table" then
          for i = 1, #List do
            local Request = List[i]
            if type(Request) == "table" then
              if StationList[StationId] then
                HandleSmithing(Request)
              elseif StationId == CRAFTING_TYPE_ENCHANTING then
                HandleEnchanting(Request)
              elseif StationId == CRAFTING_TYPE_ALCHEMY then
                HandleAlchemy(Request)
              elseif StationId == CRAFTING_TYPE_PROVISIONING then
                HandleProvisioning(Request)
              end
            end
          end
        end
      end
    end
  end
  return Materials, Products, Replaced
end


--Find Missing Item for Daily Writs
function WG.FindDailyItem()
  local Materials = {
    --["ItemLink"], ["Count"], ["ItemId"]
  }
  local SmithM = {
    --[ItemId] = Num
  }
  --Finished Products (Sword, Helmet, Staff, Shield, Glyph, Potion, Food...)
  --[ItemId] = {["ItemLink"], ["Count"] (Units Claimed From the Guild Bank)}
  local Products = {}
  local function AddProduct(ItemId, ItemLink, Count, CraftLevel, CraftChampionPoints)
    if not ItemId or ItemId == 0 or not Count or Count <= 0 then return end
    local Old = Products[ItemId]
    if Old then
      --Several Sources (Writ Conditions and LazyCrafting) May Claim the Same Product
      --The Actual Take is Capped by the Guild Bank Availability
      Old["Count"] = Old["Count"] + Count
    else
      Products[ItemId] = {
        ["ItemLink"] = ItemLink, ["Count"] = Count,
        ["CraftLevel"] = CraftLevel, ["CraftChampionPoints"] = CraftChampionPoints,
      }
    end
  end
  --Check Quests
  for a = 1, 25 do
    local Type = select(10, GetJournalQuestInfo(a))
    --Daily Writs
    if Type == 4 and not GetQuestConditionMasterWritInfo(a, 1, 1) then
      --Writ Condition
      local Enchant2T
      for b = 1, 6 do
        local ItemId, MaterialId, CraftType, Quilty = GetQuestConditionItemInfo(a, 1, b)
        local NumHold, NumCondition = GetJournalQuestConditionValues(a, 1, b) 
        local Need = NumCondition - NumHold
        if ItemId ~= 0 then
          --Black/Cloth/Wood/Jewelry
          if Need > 0 and (CraftType == 1 or CraftType == 2 or CraftType == 6 or CraftType == 7) then
            --Finished Product (Shield, Sword, Staff, Helmet...) in the Guild Bank
            --Fulfilling the Writ: Take It Instead of the Raw Materials
            --White, no Trait, and the Exact Craft Level Required by the Writ
            local Have = 0
            if WG.SV.LazyCraftingProduct then
              local Pattern, MaterialIndex = GetSmithingPatternInfoForItemId(ItemId, MaterialId, CraftType)
              local ReferenceLink
              if Pattern and MaterialIndex then
                local _, NumPer = unpack(WG.MaterialExcel[CraftType][ItemId][MaterialId])
                ReferenceLink = GetSmithingPatternResultLink(Pattern, MaterialIndex, NumPer, 1, 1, 0)
              end
              --No Reliable Reference: Keep the Raw Materials Rather Than Guess a Level
              local CraftLevel, CraftChampionPoints
              if ReferenceLink and ReferenceLink ~= "" then
                CraftLevel = GetItemLinkRequiredLevel(ReferenceLink)
                CraftChampionPoints = GetItemLinkRequiredChampionPoints(ReferenceLink)
              end
              --GetNextGuildBankSlotId Returns nil When the Bank is Empty
              local StartPoint = GetNextGuildBankSlotId()
              if StartPoint and CraftLevel ~= nil and CraftChampionPoints ~= nil then
                for i = StartPoint, StartPoint + 500 do
                  local ItemLink = GetItemLink(3, i)
                  if ItemLink ~= "" and Have < Need
                    and GetItemLinkQuality(ItemLink) == ITEM_QUALITY_NORMAL
                    and GetItemLinkTraitInfo(ItemLink) == ITEM_TRAIT_TYPE_NONE
                    and GetItemLinkRequiredLevel(ItemLink) == CraftLevel
                    and GetItemLinkRequiredChampionPoints(ItemLink) == CraftChampionPoints
                    and DoesItemLinkFulfillJournalQuestCondition(ItemLink, a, 1, b, GetItemCreatorName(3, i) == GetUnitName("player")) then
                    local Count = select(2, GetItemInfo(3, i))
                    AddProduct(GetItemLinkItemId(ItemLink), ItemLink, Count, CraftLevel, CraftChampionPoints)
                    Have = Have + Count
                  end
                end
              end
            end
            --Raw Materials for the Items Still to Craft
            local Missing = Need - Have
            if Missing > 0 then
              local RawId, NumPer = unpack(WG.MaterialExcel[CraftType][ItemId][MaterialId])
              SmithM[RawId] = SmithM[RawId] or 0
              SmithM[RawId] = SmithM[RawId] + (NumPer * Missing)
            end
          end
          --Alchemy and Cook Production
          if Need > 0 and ((CraftType == 4 and MaterialId ~= 0) or CraftType == 5) then
            --GetNextGuildBankSlotId Returns nil When the Bank is Empty
            local StartPoint = GetNextGuildBankSlotId()
            if StartPoint then
              for i = StartPoint, StartPoint + 500 do
                local ItemLink = GetItemLink(3, i)
                if ItemLink ~= "" and DoesItemLinkFulfillJournalQuestCondition(ItemLink, a, 1, b, GetItemCreatorName(3, i) == GetUnitName("player")) then
                  table.insert(Materials, {["ItemLink"] = ItemLink, ["Count"] = 1})
                end
              end
            end
          end
          --Alchemy Raw Materials
          if Need > 0 and CraftType == 4 and MaterialId == 0 then
            local Target = MaterialCount(ItemId, Need, true)
            table.insert(Materials, {["ItemId"] = ItemId, ["Count"] = Target})
          end
          --Enchant Production
          if Need > 0 and CraftType == 3 and MaterialId ~= 0 then
            --Finished Glyph in the Guild Bank Fulfilling the Writ
            local Have = 0
            if WG.SV.LazyCraftingProduct then
              --GetNextGuildBankSlotId Returns nil When the Bank is Empty
              local StartPoint = GetNextGuildBankSlotId()
              if StartPoint then
                for i = StartPoint, StartPoint + 500 do
                  local ItemLink = GetItemLink(3, i)
                  if ItemLink ~= "" and Have < Need
                    and DoesItemLinkFulfillJournalQuestCondition(ItemLink, a, 1, b, GetItemCreatorName(3, i) == GetUnitName("player")) then
                    local Count = select(2, GetItemInfo(3, i))
                    AddProduct(GetItemLinkItemId(ItemLink), ItemLink, Count)
                    Have = Have + Count
                  end
                end
              end
            end
            --Runes for the Glyphs Still to Craft
            if Need - Have > 0 then
              local Fork, Rule1 = unpack(WG.MaterialExcel[CraftType]["Id"][ItemId])
              local Rule2, Rule3 = WG.MaterialExcel[CraftType]["Level"][MaterialId][Fork], WG.MaterialExcel[CraftType]["Quilty"][Quilty]
              SmithM[Rule1] = 1
              SmithM[Rule2] = 1
              SmithM[Rule3] = 1
            end
          end
          --Enchant Raw Material
          if Need > 0 and CraftType == 3 and MaterialId == 0 then
            Enchant2T = ItemId
          end
        end
      end
      --Enchant Writ Patch
      if Enchant2T then
        if SmithM[Enchant2T] and MaterialCount(Enchant2T, 1) > 0 then
          local Target = MaterialCount(Enchant2T, 2, true)
          table.insert(Materials, {["ItemId"] = Enchant2T, ["Count"] = Target})
          SmithM[Enchant2T] = nil
        else
          local Target = MaterialCount(Enchant2T, 1, true)
          table.insert(Materials, {["ItemId"] = Enchant2T, ["Count"] = Target})
        end
      end
    end
  end
  --LazyCrafting Queue (Items to Craft: Steel/Textile/Wood)
  --Finished Products Available Replace the Raw Materials
  local LazyM, LazyP, LazyR = WG.FindLazyCraftingItem()
  --Products Cover the Writ Crafts Too: Reduce the Writ Material Need
  for ItemId, Count in pairs(LazyR) do
    if SmithM[ItemId] then
      SmithM[ItemId] = math.max(0, SmithM[ItemId] - Count)
    end
  end
  --Take Max Per Item to Avoid Double Counting with the Writ Conditions
  for ItemId, Count in pairs(LazyM) do
    if not SmithM[ItemId] or SmithM[ItemId] < Count then
      SmithM[ItemId] = Count
    end
  end
  --Raw Materials
  for ItemId, Count in pairs(SmithM) do
    local Target = MaterialCount(ItemId, Count)
    if Target > 0 then
      table.insert(Materials, {["ItemId"] = ItemId, ["Count"] = Target})
    end
  end
  --LazyCrafting Products Merge With the Writ Products
  for ItemId, Product in pairs(LazyP) do
    AddProduct(ItemId, Product["ItemLink"], Product["Count"])
  end
  --Finished Products (Sword, Helmet, Staff, Shield, Glyph, Potion, Food...)
  --Retrieve Them from the Guild Bank Instead of the Materials
  for ItemId, Product in pairs(Products) do
    --Target: Keep (Current Backbag + Claimed) in the Backbag
    --The Actual Take is Capped by the Guild Bank Availability
    local Target = WG.FindItem(1, ItemId, Product["ItemLink"], Product)["Total"] + Product["Count"]
    table.insert(Materials, {
      ["ItemLink"] = Product["ItemLink"], ["ItemId"] = ItemId, ["Count"] = Target,
      ["CraftLevel"] = Product["CraftLevel"], ["CraftChampionPoints"] = Product["CraftChampionPoints"],
    })
  end
  --End
  return Materials
end
