local WG = SDC_WareGuild

--[[
For translation, you have to copy this file and rename it in xx.lua, and translated the strings below. 
you can get the xx for your language by typing following line in game chat
/script d(GetCVar("language.2"))
]]

WG.Lang = {
  --Craft Type, No Need to Translate
  ["BLACKSMITH"] = GetString(SI_ITEMFILTERTYPE13),
  ["CLOTH"] = GetString(SI_ITEMFILTERTYPE14),
  ["ENCHANT"] = GetString(SI_ITEMFILTERTYPE17),
  ["ALCHEMY"] = GetString(SI_ITEMFILTERTYPE16),
  ["COOK"] = GetString(SI_ITEMFILTERTYPE18),
  ["WOOD"] = GetString(SI_ITEMFILTERTYPE15),
  ["JEWELRY"] = GetString(SI_ITEMFILTERTYPE25),
  
  ["STYLE"] = GetString(SI_ITEMFILTERTYPE19),
  ["TRAIT"] = GetString(SI_ITEMFILTERTYPE20),
  
  --Info Displayed in Chat Window, Need to Translate
  
  ["CHAT_FUZZY"] = " (模糊匹配)", --Added to ItemName Matched by ItemId
  
  ["CHAT_TAKE_TO"] = "使背包中 <<1>> 数量为 <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_TAKE_ALL"] = "取出所有 <<1>>", -- <<1>> ItemName
  
  ["CHAT_STORE_TO"] = "使银行中 <<1>> 数量为 <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_STORE_ALL"] = "存储所有 <<1>>", -- <<1>> ItemName
  ["CHAT_STORE_UNKNOWN"] = "存入其他角色尚未学会的未绑定物品",
  ["CHAT_KNOWLEDGE_UNAVAILABLE"] = "跳过知识物品存入：LibCharacterKnowledge 未安装或不兼容。",
  ["GUILD_STORE_UNKNOWN"] = "存入我的其他角色尚未学会的物品",
  ["GUILD_STORE_UNKNOWN_TOOLTIP"] = "为此公会添加规则。存入本账号当前服务器至少一个其他已追踪角色需要的未绑定配方、家具图纸、样式书、篆刻物品和可研究装备。不包括当前角色、无数据、正在研究的特性以及锁定、被盗或受保护的物品。需要 LibCharacterKnowledge。遵循角色追踪和持有日常委托时禁用存入的设置。",
  ["CHAT_STORE_ALL_TYPE"] = "存储所有 <<1>> 材料", -- <<1>> Craft Type
  
  ["CHAT_DAILY_WRITS"] = "尝试取出 日常制造 材料/物品",
  
  ["CHAT_NE_TAKE"] = "[<<1>>] 取出 <<2>> 时，数量不足", -- <<1>> Guild Name, <<2>> ItemName
  ["CHAT_NE_STORE"] = "[<<1>>] 存储 <<2>> 时，数量不足", -- <<1>> Guild Name, <<2>> ItemName
  
  ["CHAT_DONE"] = "完工！",
  ["CHAT_NO_WORK"] = "无事可做！",
  ["CHAT_STOP"] = "停机！",
  ["CHAT_ERROR"] = "发生错误！",
  
  ["CHAT_BACKBAG_FULL"] = "背包已满！",
  ["CHAT_WITHDRAW_BLOCKED"] = "[<<1>>] 无法取出 <<2>>：<<3>>。",
  ["CHAT_WITHDRAW_FCOIS"] = "FCOItemSaver (FCOIS) 保护",
  ["CHAT_WITHDRAW_LOCKED"] = "物品被玩家锁定",
  ["CHAT_WITHDRAW_PERMISSION"] = "没有取出权限",
  ["CHAT_WITHDRAW_CHANGED"] = "物品在取出前已移动或改变",
  ["CHAT_WITHDRAW_GUILD_CHANGED"] = "转移过程中所选公会银行已改变",
  ["CHAT_WITHDRAW_ERROR"] = "转移错误 <<1>>：<<2>>",
  ["CHAT_WITHDRAW_TIMEOUT"] = "10秒后仍未确认；服务器或其他插件可能阻止了转移",
  ["CHAT_WITHDRAW_QUALITY"] = "品质不符合日常委托要求（需要白色品质）",
  ["CHAT_WITHDRAW_TRAIT"] = "特性不符合日常委托要求（需要无特性）",
  ["CHAT_WITHDRAW_LEVEL"] = "等级不匹配：需要 <<1>> / CP <<2>>，实际 <<3>> / CP <<4>>",
  ["CHAT_WITHDRAW_CONDITION"] = "物品不满足任务日志条件",
  ["CHAT_WITHDRAW_NOTICE"] = "[<<1>>] <<2>>：<<3>>。",
  ["CHAT_WITHDRAW_REFERENCE"] = "在制造台之外无法获取参考制造等级；不比较精确等级，由任务日志条件验证材料等级",
  ["CHAT_WITHDRAW_DATA"] = "WareGuild 缺少物品与制造材料的对应数据",
  ["CHAT_WITHDRAW_NOT_FOUND"] = "此银行中没有匹配物品；请检查此步骤所选的公会",
  ["CHAT_WITHDRAW_DISABLED"] = "成品取出功能已禁用；改为寻找材料",
  ["CHAT_BANK_WAIT"] = "[<<1>>] 正在等待公会银行物品...",
  ["CHAT_BANK_TIMEOUT"] = "[<<1>>] 已停止：20秒后仍未确认银行物品。请重新打开银行后再试。",
  ["CHAT_BANK_ERROR"] = "[<<1>>] 无法打开公会银行：<<2>>",
  ["CHAT_STACK_TIMEOUT"] = "<<1>> 合堆中断：10秒后仍未确认；服务器或其他插件可能阻止了移动。",
  ["CHAT_GUILD_BANK_FULL"] = "银行已满！",
  ["CHAT_REGROUP_NO_SPACE"] = "<<1>> 合堆已跳过：背包空间不足。继续正常存入。",
  ["CHAT_REGROUP_SKIPPED"] = "<<1>> 合堆已跳过：无取出权限或银行内容已变化。继续存入。",
  ["CHAT_REGROUP_FAILED"] = "<<1>> 转移中断。请检查背包和公会银行中剩余的物品后再重试。",
  ["CHAT_REGROUP_MISMATCH"] = "<<1>> 合堆已跳过：银行中的同一物品等级、品质或链接不同（背包：<<2>> 等级 <<3>> CP <<4>> 品质 <<5>>；银行：<<6>> 等级 <<7>> CP <<8>> 品质 <<9>>）。",
  
  --Setting, Need to Translate
  
  ["SETTING_CHARACTER_CONFIG"] = "为当前角色单独配置",
  ["SETTING_CHARACTER_CONFIG_TOOLTIP"] = "默认使用账户配置",
  
  ["SETTING_AUTO_OPEN_STORE"] = "需要存储时，自动打开公会银行",
  ["SETTING_AUTO_OPEN_STORE_TOOLTIP"] = "仅当WG发现有物品需要储存时生效\r\n对 [存储至 x 件] 操作步骤不生效",
  
  ["SETTING_AUTO_OPEN_WRITS"] = "生产日常时，自动打开公会银行",
  ["SETTING_AUTO_OPEN_WRITS_TOOLTIP"] = "仅当 [取出日常生产物品] 操作步骤存在\r\n且持有生产日常任务时生效",
  
  ["SETTING_AUTO_CLOSE"] = "自动关闭公会银行",
  ["SETTING_AUTO_CLOSE_TOOLTIP"] = "仅当WG实际进行存取操作后生效",
  
  ["SETTING_STEPS_LOG"] = "输出存取操作记录",
  ["SETTING_STEPS_LOG_TOOLTIP"] = "将WG实际存储物品的操作输出至聊天栏",
  
  ["SETTING_BAN_STORE_WRITS"] = "生产日常时，禁用存储相关步骤",
  ["SETTING_BAN_STORE_WRITS_TOOLTIP"] = "需要利用公会银行进行生产日常时，推荐开启",
  
  ["SETTING_IGNORE_INVENTORY"] = "[取出日常生产物品] 步骤无视库存",
  ["SETTING_IGNORE_INVENTORY_TOOLTIP"] = "开启后，该步骤将无视背包、个人银行和制作包裹中，可用于制作产物的材料数量（例：共需要42锭生产，已有30锭。开启后将尝试从公会银行取出42锭而不是12锭）",
  
  ["SETTING_LAZYCRAFTING"] = "使用 LazyCrafting 队列",
  ["SETTING_LAZYCRAFTING_TOOLTIP"] = "开启后，[日常委托取出]步骤还会统计 LazyCrafting（LibLazyCrafting，Lazy Writ Crafter 与 Lazy Set Crafter 使用）队列中待制作物品（锻造/制衣/木工）所需的基础材料。当同一材料同时被委托和队列需要时，只取出较多的数量",

  ["SETTING_LAZYCRAFTING_PRODUCT"] = "取出成品而非材料",
  ["SETTING_LAZYCRAFTING_PRODUCT_TOOLTIP"] = "开启后，待制作的物品（剑、头盔、法杖、盾牌、符文、药水、食物……）会先在背包和公会银行中查找，包括 LazyCrafting 队列和任务日志中的日常委托：若已有成品，则直接取出成品而非基础材料（材料数量相应减少）。日常委托的成品不限制风格、无特性且仅白色品质；带特性或套装的请求仅取出材料。珠宝、附魔、炼金和烹饪同样支持",

  ["SETTING_NE_TAKE"] = "物品不足时，取出所有剩余",
  ["SETTING_NE_TAKE_TOOLTIP"] = "关闭时，物品不足将跳过该取出步骤",
  
  ["SETTING_NE_STORE"] = "物品不足时，存储所有剩余",
  ["SETTING_NE_STORE_TOOLTIP"] = "关闭时, 物品不足将跳过该存储步骤",
  
  ["SETTING_IGNORE_FCOIS"] = "无视 FCO ItemSaver 插件",
  ["SETTING_IGNORE_FCOIS_TOOLTIP"] = "无视 FCO ItemSaver 插件对于存取公会银行物品的限制",
  
  ["SETTING_HEADER_SELECT_GUILD"] = "选择公会银行",
  ["SETTING_GUILD_TIPS"] = "小贴士:\r\nWG将按顺序依次执行各银行步骤，请自行确保公会银行权限\r\n新加入公会后需重新加载UI，以读取公会列表", -- \r\n Line Feed
  
  ["GUILD_ITEM_SCROLL"] = "选择背包物品,创建操作步骤",
  
  ["GUILD_FUZZY"] = "模糊匹配",
  ["GUILD_FUZZY_TOOLTIP"] = "物品链接(精确匹配)/物品ID(模糊匹配)\r\n不推荐启用",
  
  ["GUILD_UPDATE_ITEM_LIST"] = "刷新物品列表",
  ["GUILD_TAKE_ALL"] = "取出所有",
  ["GUILD_STORE_ALL"] = "存储所有",
  
  ["GUILD_TAKE_TO_SLIDER"] = "使背包中，物品数量为 x",
  ["GUILD_TAKE_TO"] = "取出至 x 件",
  
  ["GUILD_STORE_TO_SLIDER"] = "使银行中，物品数量为 x",
  ["GUILD_STORE_TO"] = "存储至 x 件",
  
  ["GUILD_STORE_ALL_TYPE_DROP"] = "选择存储的材料类型",
  ["GUILD_STORE_ALL_TYPE"] = "存储该类材料",
  
  ["GUILD_TAKE_WRITS"] = "取出日常生产物品",
  ["GUILD_TAKE_WRITS_TOOLTIP"] = "需要先接取日常制造任务！\n每个公会仅需添加一次，具体规则如下：\n为 锻铁、制衣、木匠、珠宝和附魔 取出制作缺少的原材料\n为 锻铁、制衣、木匠、珠宝和附魔 取出已有的成品（白色、无特性、任意风格）\n为 烹饪和炼金 取出成品\n为 附魔和炼金 取出需提交的材料\n*不含有样式材料",
  
  ["GUILD_HEADER_STEPS"] = "操作步骤",
  ["GUILD_STEPS_SLIDER"] = "选择步骤所在行",
  ["GUILD_STEPS_EMPTY"] = "清空步骤",
  ["GUILD_STEPS_DELETE"] = "删除所选步骤",
  
  ["CLIP"] = "剪切板",
  ["CLIP_PASTE"] = "粘贴",
  
  ["SETTING_BOTTOM_TIPS"] = "可在 Guar Protection/Splendid Achievers 公会群，找到作者 @MelanAster",
}
