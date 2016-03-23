--[[
	太阳神三国杀武将单挑对战平台·一将成名2011武将包
	武将总数：16
	武将一览：
		1、曹植（落英、酒诗）
		2、陈宫（智迟、明策）
		3、法正（恩怨、眩惑）
		4、高顺（陷阵、禁酒）
		5、凌统（旋风）
		6、马谡（心战、挥泪）
		7、吴国太（甘露、补益）
		8、徐盛（破军）
		9、徐庶（无言、举荐）
		10、于禁（毅重）
		11、张春华（绝情、伤逝）
		12、钟会（权计、自立）+（排异）
		13、法正·改（恩怨、眩惑）
		14、凌统·改（旋风）
		15、徐庶·改（无言、举荐）
		16、张春华·改（绝情、伤逝）
]]--
--[[****************************************************************
	版本控制
]]--****************************************************************
local old_version = true --原版武将开关，开启后将出现 法正、凌统、徐庶、张春华 四位武将
local new_version = true --新版武将开关，开启后将出现 法正·改、凌统·改、徐庶·改、张春华·改 四位武将
local yjcm2011 = {}
--[[****************************************************************
	称号：八斗之才
	武将：曹植
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：落英
	描述：其他角色的牌因判定或弃置而置入弃牌堆时，你可以获得其中至少一张梅花牌。
]]--
LuoYing = sgs.CreateLuaSkill{
	name = "yj1LuoYing",
	translation = "落英",
	description = "其他角色的牌因判定或弃置而置入弃牌堆时，你可以获得其中至少一张梅花牌。",
	audio = {},
}
--[[
	技能：酒诗
	描述：若你的武将牌正面朝上，你可以将武将牌翻面，视为你使用了一张【酒】。每当你受到伤害扣减体力前，若武将牌背面朝上，你可以在伤害结算后将武将牌翻至正面朝上。
]]--
JiuShi = sgs.CreateLuaSkill{
	name = "yj1JiuShi",
	translation = "酒诗",
	description = "若你的武将牌正面朝上，你可以将武将牌翻面，视为你使用了一张【酒】。每当你受到伤害扣减体力前，若武将牌背面朝上，你可以在伤害结算后将武将牌翻至正面朝上。",
	audio = {},
}
--武将信息：曹植
CaoZhi = sgs.CreateLuaGeneral{
	name = "yj_i_caozhi",
	real_name = "caozhi",
	translation = "曹植",
	title = "八斗之才",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	designer = "Foxear",
	cv = "殆尘",
	illustrator = "木美人",
	skills = {LuoYing, JiuShi},
	last_word = "捐躯赴国难，视死忽如归呀……",
	resource = "caozhi",
}
table.insert(yjcm2011, CaoZhi)
--[[****************************************************************
	称号：刚直壮烈
	武将：陈宫
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：明策（阶段技）
	描述：你可以将一张装备牌或【杀】交给一名其他角色：若如此做，该角色可以视为对其攻击范围内由你选择的一名角色使用一张【杀】，否则其摸一张牌。
]]--
MingCe = sgs.CreateLuaSkill{
	name = "yj1MingCe",
	translation = "明策",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张装备牌或【杀】交给一名其他角色：若如此做，该角色可以视为对其攻击范围内由你选择的一名角色使用一张【杀】，否则其摸一张牌。",
	audio = {},
}
--[[
	技能：智迟（锁定技）
	描述：你的回合外，每当你受到伤害后，【杀】和非延时锦囊牌对你无效，直到回合结束。
]]--
ZhiChi = sgs.CreateLuaSkill{
	name = "yj1ZhiChi",
	translation = "智迟",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的回合外，每当你受到伤害后，【杀】和非延时锦囊牌对你无效，直到回合结束。",
	audio = {},
}
--武将信息：陈宫
ChenGong = sgs.CreateLuaGeneral{
	name = "yj_i_chengong",
	real_name = "chengong",
	translation = "陈宫",
	title = "刚直壮烈",
	kingdom = "qun",
	maxhp = 3,
	order = 1,
	designer = "Kaycent",
	cv = "V7, 官方",
	illustrator = "黑月乱",
	skills = {MingCe, ZhiChi},
	last_word = "请出就戮！",
	resource = "chengong",
}
table.insert(yjcm2011, ChenGong)
if old_version then
--[[****************************************************************
	称号：蜀汉的辅翼
	武将：法正
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：恩怨（锁定技）
	描述：每当你回复1点体力后，令你回复体力的角色摸一张牌；每当你受到伤害后，伤害来源选择一项：交给你一张红桃手牌，或失去1点体力。
]]--
EnYuan = sgs.CreateLuaSkill{
	name = "yj1EnYuan",
	translation = "恩怨",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你回复1点体力后，令你回复体力的角色摸一张牌；每当你受到伤害后，伤害来源选择一项：交给你一张红桃手牌，或失去1点体力。",
	audio = {},
}
--[[
	技能：眩惑（阶段技）
	描述：你可以将一张红桃手牌交给一名其他角色：若如此做，你获得该角色的一张牌，然后将此牌交给除该角色外的另一名角色。
]]--
XuanHuo = sgs.CreateLuaSkill{
	name = "yj1XuanHuo",
	translation = "眩惑",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张红桃手牌交给一名其他角色：若如此做，你获得该角色的一张牌，然后将此牌交给除该角色外的另一名角色。",
	audio = {},
}
--武将信息：法正
FaZheng = sgs.CreateLuaGeneral{
	name = "yj_i_fazheng",
	real_name = "fazheng",
	translation = "法正",
	title = "蜀汉的辅翼",
	kingdom = "shu",
	maxhp = 3,
	order = 4,
	designer = "Michael_Lee",
	illustrator = "雷没才",
	skills = {EnYuan, XuanHuo},
	last_word = "辅翼既折，蜀汉哀矣……",
	resource = "fazheng_v1",
}
table.insert(yjcm2011, FaZheng)
end
--[[****************************************************************
	称号：攻无不克
	武将：高顺
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：陷阵（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，本回合，该角色的防具无效，你无视与该角色的距离，你对该角色使用【杀】无次数限制；若你没赢，你不能使用【杀】，直到回合结束。
]]--
XianZhen = sgs.CreateLuaSkill{
	name = "yj1XianZhen",
	translation = "陷阵",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，本回合，该角色的防具无效，你无视与该角色的距离，你对该角色使用【杀】无次数限制；若你没赢，你不能使用【杀】，直到回合结束。",
	audio = {},
}
--[[
	技能：禁酒（锁定技）
	描述：你的【酒】视为【杀】。
]]--
JinJiu = sgs.CreateLuaSkill{
	name = "yj1JinJiu",
	translation = "禁酒",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的【酒】视为【杀】。",
	audio = {},
}
--武将信息：高顺
GaoShun = sgs.CreateLuaGeneral{
	name = "yj_i_gaoshun",
	real_name = "gaoshun",
	translation = "高顺",
	title = "攻无不克",
	kingdom = "qun",
	maxhp = 4,
	order = 3,
	designer = "羽柴文理",
	illustrator = "鄧Sir",
	skills = {XianZhen, JinJiu},
	last_word = "生死……有……命……",
	resource = "gaoshun",
}
table.insert(yjcm2011, GaoShun)
if old_version then
--[[****************************************************************
	称号：豪情胆烈
	武将：凌统
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：旋风
	描述：每当你失去一次装备区的牌后，你可以选择一项：视为使用一张无距离限制的【杀】，或对距离1的一名角色造成1点伤害。
]]--
XuanFeng = sgs.CreateLuaSkill{
	name = "yj1XuanFeng",
	translation = "旋风",
	description = "每当你失去一次装备区的牌后，你可以选择一项：视为使用一张无距离限制的【杀】，或对距离1的一名角色造成1点伤害。",
	audio = {},
}
--武将信息：凌统
LingTong = sgs.CreateLuaGeneral{
	name = "yj_i_lingtong",
	real_name = "lingtong",
	translation = "凌统",
	title = "豪情胆烈",
	kingdom = "wu",
	maxhp = 4,
	order = 8,
	illustrator = "绵Myan",
	skills = XuanFeng,
	last_word = "大丈夫不惧死亡……",
	resource = "lingtong_v1",
}
table.insert(yjcm2011, LingTong)
end
--[[****************************************************************
	称号：怀才自负
	武将：马谡
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：心战（阶段技）
	描述：若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后你可以展示并获得其中至少一张红桃牌，然后将其余的牌置于牌堆顶。
]]--
XinZhan = sgs.CreateLuaSkill{
	name = "yj1XinZhan",
	translation = "心战",
	description = "<font color=\"green\"><b>阶段技</b></font>，若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后你可以展示并获得其中至少一张红桃牌，然后将其余的牌置于牌堆顶。",
	audio = {},
}
--[[
	技能：挥泪（锁定技）
	描述：你死亡时，杀死你的其他角色弃置其所有牌。
]]--
HuiLei = sgs.CreateLuaSkill{
	name = "yj1HuiLei",
	translation = "挥泪",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你死亡时，杀死你的其他角色弃置其所有牌。",
	audio = {},
}
--武将信息：马谡
MaSu = sgs.CreateLuaGeneral{
	name = "yj_i_masu",
	real_name = "masu",
	translation = "马谡",
	title = "怀才自负",
	kingdom = "shu",
	maxhp = 3,
	order = 4,
	designer = "点点",
	illustrator = "张帅",
	skills = {XinZhan, HuiLei},
	resource = "masu",
}
table.insert(yjcm2011, MaSu)
--[[****************************************************************
	称号：武烈皇后
	武将：吴国太
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：甘露（阶段技）
	描述：你可以令装备区的牌数量差不超过你已损失体力值的两名角色交换他们装备区的装备牌。
]]--
GanLu = sgs.CreateLuaSkill{
	name = "yj1GanLu",
	translation = "甘露",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令装备区的牌数量差不超过你已损失体力值的两名角色交换他们装备区的装备牌。",
	audio = {},
}
--[[
	技能：补益
	描述：每当一名角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌为非基本牌，该角色弃置此牌，然后回复1点体力。
]]--
BuYi = sgs.CreateLuaSkill{
	name = "yj1BuYi",
	translation = "补益",
	description = "每当一名角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌为非基本牌，该角色弃置此牌，然后回复1点体力。",
	audio = {},
}
--武将信息：吴国太
WuGuoTai = sgs.CreateLuaGeneral{
	name = "yj_i_wuguotai",
	real_name = "wuguotai",
	translation = "吴国太",
	title = "武烈皇后",
	kingdom = "wu",
	maxhp = 3,
	order = 2,
	designer = "章鱼咬你哦",
	illustrator = "zoo",
	skills = {GanLu, BuYi},
	last_word = "卿等……务必用心辅佐……仲谋……",
	resource = "wuguotai",
}
table.insert(yjcm2011, WuGuoTai)
--[[****************************************************************
	称号：江东的铁壁
	武将：徐盛
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：破军
	描述：每当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌，然后将其武将牌翻面。（X为该角色的体力值且至多为5）
]]--
PoJun = sgs.CreateLuaSkill{
	name = "yj1PoJun",
	translation = "破军",
	description = "每当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌，然后将其武将牌翻面。（X为该角色的体力值且至多为5）",
	audio = {},
}
--武将信息：徐盛
XuSheng = sgs.CreateLuaGeneral{
	name = "yj_i_xusheng",
	real_name = "xusheng",
	translation = "徐盛",
	title = "江东的铁壁",
	kingdom = "wu",
	maxhp = 4,
	order = 3,
	designer = "阿江",
	illustrator = "天空之城",
	skills = PoJun,
	last_word = "盛不能奋身出命，不亦辱乎？……",
	resource = "xusheng",
}
table.insert(yjcm2011, XuSheng)
if old_version then
--[[****************************************************************
	称号：忠孝的侠士
	武将：徐庶
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：无言（锁定技）
	描述：你使用的非延时锦囊牌对其他角色无效。其他角色使用的非延时锦囊牌对你无效。
]]--
WuYan = sgs.CreateLuaSkill{
	name = "yj1WuYan",
	translation = "无言",
	description = "<font color=\"blue\"><b>无言</b></font>，你使用的非延时锦囊牌对其他角色无效。其他角色使用的非延时锦囊牌对你无效。",
	audio = {},
}
--[[
	技能：举荐（阶段技）
	描述：你可以弃置至多三张牌并选择一名其他角色：若如此做，该角色摸等量的牌。若你以此法弃置三张同一类别的牌，你回复1点体力。
]]--
JuJian = sgs.CreateLuaSkill{
	name = "yj1JuJian",
	translation = "举荐",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置至多三张牌并选择一名其他角色：若如此做，该角色摸等量的牌。若你以此法弃置三张同一类别的牌，你回复1点体力。",
	audio = {},
}
--武将信息：徐庶
XuShu = sgs.CreateLuaGeneral{
	name = "yj_i_xushu",
	real_name = "xushu",
	translation = "徐庶",
	title = "忠孝的侠士",
	kingdom = "shu",
	maxhp = 3,
	order = 1,
	illustrator = "XINA",
	skills = {WuYan, JuJian},
	resource = "xushu_v1",
}
table.insert(yjcm2011, XuShu)
end
--[[****************************************************************
	称号：魏武之刚
	武将：于禁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：毅重（锁定技）
	描述：若你的装备区没有防具牌，黑色【杀】对你无效。
]]--
YiZhong = sgs.CreateLuaSkill{
	name = "yj1YiZhong",
	translation = "毅重",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的装备区没有防具牌，黑色【杀】对你无效。",
	audio = {},
}
--武将信息：于禁
YuJin = sgs.CreateLuaGeneral{
	name = "yj_i_yujin",
	real_name = "yujin",
	translation = "于禁",
	title = "魏武之刚",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "城管无畏",
	illustrator = "Yi章",
	skills = YiZhong,
	last_word = "我……无颜面对……丞相了……",
	resource = "yujin",
}
table.insert(yjcm2011, YuJin)
--[[****************************************************************
	称号：冷血皇后
	武将：张春华
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝情（锁定技）
	描述：伤害结算开始前，你将要造成的伤害视为失去体力。
]]--
JueQing = sgs.CreateLuaSkill{
	name = "yj1JueQing",
	translation = "绝情",
	description = "<font color=\"blue\"><b>锁定技</b></font>，伤害结算开始前，你将要造成的伤害视为失去体力。",
	audio = {},
}
if old_version then
--[[
	技能：伤逝
	描述：每当你的手牌数、体力值或体力上限改变后，若你的手牌数小于X，你可以将手牌补至X张。（X为你已损失的体力值）
]]--
ShangShi = sgs.CreateLuaSkill{
	name = "yj1ShangShi",
	translation = "伤逝",
	description = "每当你的手牌数、体力值或体力上限改变后，若你的手牌数小于X，你可以将手牌补至X张。（X为你已损失的体力值）",
	audio = {},
}
--武将信息：张春华
ZhangChunHua = sgs.CreateLuaGeneral{
	name = "yj_i_zhangchunhua",
	real_name = "zhangchunhua",
	translation = "张春华",
	title = "冷血皇后",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	designer = "JZHIEI",
	illustrator = "樱花闪乱",
	skills = {JueQing, ShangShi},
	last_word = "怎能如此对我？……",
	resource = "zhangchunhua_v1",
}
table.insert(yjcm2011, ZhangChunHua)
end
--[[****************************************************************
	称号：桀骜的野心家
	武将：钟会
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：权计
	描述：每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”。每有一张“权”，你的手牌上限+1。
]]--
QuanJi = sgs.CreateLuaSkill{
	name = "yj1QuanJi",
	translation = "权计",
	description = "每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”。每有一张“权”，你的手牌上限+1。",
	audio = {},
}
--[[
	技能：自立（觉醒技）
	描述：准备阶段开始时，若“权”大于或等于三张，你失去1点体力上限，摸两张牌或回复1点体力，然后获得“排异”（阶段技。你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害）。
]]--
ZiLi = sgs.CreateLuaSkill{
	name = "yj1ZiLi",
	translation = "自立",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若“权”大于或等于三张，你失去1点体力上限，摸两张牌或回复1点体力，然后获得“排异”（<font color=\"green\"><b>阶段技</b></font>。你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害）。",
	audio = {},
}
--[[
	技能：排异（阶段技）
	描述：你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害。
]]--
PaiYi = sgs.CreateLuaSkill{
	name = "yj1PaiYi",
	translation = "排异",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害。",
	audio = {},
}
--武将信息：钟会
ZhongHui = sgs.CreateLuaGeneral{
	name = "yj_i_zhonghui",
	real_name = "zhonghui",
	translation = "钟会",
	title = "桀骜的野心家",
	kingdom = "wei",
	maxhp = 4,
	order = 8,
	cv = "风叹息",
	illustrator = "雪君S",
	skills = {QuanJi, ZiLi},
	related_skills = PaiYi,
	last_word = "大权在手竟一夕败亡，时耶？命耶？",
	resource = "zhonghui",
}
table.insert(yjcm2011, ZhongHui)
if new_version then
--[[****************************************************************
	称号：蜀汉的辅翼
	武将：法正·改
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：恩怨
	描述：每当你获得一名其他角色的两张或更多的牌后，你可以令其摸一张牌。每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。
]]--
EnYuan = sgs.CreateLuaSkill{
	name = "yj1xEnYuan",
	translation = "恩怨",
	description = "每当你获得一名其他角色的两张或更多的牌后，你可以令其摸一张牌。每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。",
	audio = {},
}
--[[
	技能：眩惑
	描述：摸牌阶段开始时，你可以放弃摸牌并选择一名其他角色：若如此做，该角色摸两张牌，然后该角色可以对其攻击范围内由你选择的一名角色使用一张【杀】，否则令你获得其两张牌。
]]--
XuanHuo = sgs.CreateLuaSkill{
	name = "yj1xXuanHuo",
	translation = "眩惑",
	description = "摸牌阶段开始时，你可以放弃摸牌并选择一名其他角色：若如此做，该角色摸两张牌，然后该角色可以对其攻击范围内由你选择的一名角色使用一张【杀】，否则令你获得其两张牌。",
	audio = {},
}
--武将信息：法正·改
FaZheng = sgs.CreateLuaGeneral{
	name = "yj_i_new_fazheng",
	real_name = "fazheng",
	translation = "法正·改",
	show_name = "法正",
	title = "蜀汉的辅翼",
	kingdom = "shu",
	maxhp = 3,
	order = 2,
	designer = "Michael_Lee",
	illustrator = "雷没才",
	skills = {EnYuan, XuanHuo},
	last_word = "汉室复兴，我……是看不到了……",
	resource = "fazheng_v2",
}
table.insert(yjcm2011, FaZheng)
--[[****************************************************************
	称号：豪情胆烈
	武将：凌统·改
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：旋风
	描述：每当你失去一次装备区的牌后，或弃牌阶段结束时若你于本阶段内弃置了至少两张你的牌，你可以弃置一名其他角色的一张牌，然后弃置一名其他角色的一张牌。
]]--
XuanFeng = sgs.CreateLuaSkill{
	name = "yj1xXuanFeng",
	translation = "旋风",
	description = "每当你失去一次装备区的牌后，或弃牌阶段结束时若你于本阶段内弃置了至少两张你的牌，你可以弃置一名其他角色的一张牌，然后弃置一名其他角色的一张牌。",
	audio = {},
}
--武将信息：凌统·改
LingTong = sgs.CreateLuaGeneral{
	name = "yj_i_new_lingtong",
	real_name = "lingtong",
	translation = "凌统·改",
	show_name = "凌统",
	title = "豪情胆烈",
	kingdom = "wu",
	maxhp = 4,
	order = 7,
	illustrator = "绵Myan",
	skills = XuanFeng,
	last_word = "大丈夫不惧死亡……",
	resource = "lingtong_v2",
}
table.insert(yjcm2011, LingTong)
--[[****************************************************************
	称号：忠孝的侠士
	武将：徐庶·改
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：无言（锁定技）
	描述：每当你造成或受到伤害时，防止锦囊牌的伤害。
]]--
WuYan = sgs.CreateLuaSkill{
	name = "yj1x",
	translation = "无言",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你造成或受到伤害时，防止锦囊牌的伤害。",
	audio = {},
}
--[[
	技能：举荐
	描述：结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。
]]--
JuJian = sgs.CreateLuaSkill{
	name = "yj1xJuJian",
	translation = "举荐",
	description = "结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。",
	audio = {},
}
--武将信息：徐庶·改
XuShu = sgs.CreateLuaGeneral{
	name = "yj_i_new_xushu",
	real_name = "xushu",
	translation = "徐庶·改",
	show_name = "徐庶",
	title = "忠孝的侠士",
	kingdom = "shu",
	maxhp = 3,
	order = 1,
	illustrator = "XINA",
	skills = {WuYan, JuJian},
	last_word = "忠孝不能两全，孩儿……",
	resource = "xushu_v2",
}
table.insert(yjcm2011, XuShu)
--[[****************************************************************
	称号：冷血皇后
	武将：张春华·改
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝情（锁定技）
	描述：伤害结算开始前，你将要造成的伤害视为失去体力。
]]--
--[[
	技能：伤逝
	描述：每当你的手牌数、体力值或体力上限改变后，你可以将手牌补至X张。（X为你已损失的体力值且至多为2）
]]--
ShangShi = sgs.CreateLuaSkill{
	name = "yj1xShangShi",
	translation = "伤逝",
	description = "每当你的手牌数、体力值或体力上限改变后，你可以将手牌补至X张。（X为你已损失的体力值且至多为2）",
	audio = {},
}
--武将信息：张春华·改
ZhangChunHua = sgs.CreateLuaGeneral{
	name = "yj_i_new_zhangchunhua",
	real_name = "zhangchunhua",
	translation = "张春华·改",
	show_name = "张春华",
	title = "冷血皇后",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	designer = "JZHIEI",
	illustrator = "樱花闪乱",
	skills = {JueQing, ShangShi},
	last_word = "怎能如此对我？……",
	resource = "zhangchunhua_v2",
}
table.insert(yjcm2011, ZhangChunHua)
end
--[[****************************************************************
	一将成名2011武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2011",
	translation = "一将成名",
	generals = yjcm2011,
}