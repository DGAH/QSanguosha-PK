--[[
	太阳神三国杀武将单挑对战平台·智武将包
	武将总数：8
	武将一览：
		1、许攸（倨傲、贪婪、恃才）
		2、姜维（异才、北伐）
		3、蒋琬（后援、筹粮）
		4、孙策（霸王、危殆）
		5、张昭（笼络、辅佐、尽瘁）
		6、华雄（霸刀、温酒）
		7、田丰（识破、固守、狱刎）
		8、司马徽（授业、解惑）+（师恩）
]]--
--[[****************************************************************
	称号：恃才傲物
	武将：许攸
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：倨傲（阶段技）
	描述：你可以将两张手牌背面向上移出游戏并选择一名角色，该角色的下个回合开始阶段开始时，须获得你移出游戏的两张牌并跳过摸牌阶段。
]]--
JuAo = sgs.CreateLuaSkill{
	name = "wis",
	translation = "倨傲",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你可以将两张手牌背面向上移出游戏并选择一名角色，该角色的下个回合开始阶段开始时，须获得你移出游戏的两张牌并跳过摸牌阶段。",
}
--[[
	技能：贪婪
	描述：每当你受到其他角色造成的一次伤害后，可与伤害来源拼点：若你赢，你获得双方的拼点牌。
]]--
TanLan = sgs.CreateLuaSkill{
	name = "wisTanLan",
	translation = "贪婪",
	description = "每当你受到其他角色造成的一次伤害后，可与伤害来源拼点：若你赢，你获得双方的拼点牌。",
}
--[[
	技能：恃才（锁定技）
	描述：若你向其他角色发起拼点且你拼点赢时，或其他角色向你发起拼点且拼点没赢时，你摸一张牌。
]]--
ShiCai = sgs.CreateLuaSkill{
	name = "wisShiCai",
	translation = "恃才",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你向其他角色发起拼点且你拼点赢时，或其他角色向你发起拼点且拼点没赢时，你摸一张牌。",
}
--武将信息：许攸
XuYou = sgs.CreateLuaGeneral{
	name = "wis_xuyou",
	real_name = "xuyou",
	translation = "智·许攸",
	show_name = "许攸",
	title = "恃才傲物",
	kingdom = "wei",
	maxhp = 3,
	order = 4,
	cv = "",
	illustrator = "",
	skills = {JuAo, TanLan, ShiCai},
	last_word = "",
	resource = "xuyou",
}
--[[****************************************************************
	称号：天水麒麟
	武将：姜维
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：异才
	描述：每当你使用一张非延时类锦囊时，你可以使用一张【杀】。
]]--
YiCai = sgs.CreateLuaSkill{
	name = "wisYiCai",
	translation = "异才",
	description = "每当你使用一张非延时类锦囊时，你可以使用一张【杀】。",
}
--[[
	技能：北伐（锁定技）
	描述：当你失去最后的手牌时，视为你对一名其他角色使用了一张【杀】，若不能如此做，则视为你对自己使用了一张【杀】。
]]--
BeiFa = sgs.CreateLuaSkill{
	name = "wisBeiFa",
	translation = "北伐",
	description = "<font color=\"blue\"><b>锁定技</b></font>，当你失去最后的手牌时，视为你对一名其他角色使用了一张【杀】，若不能如此做，则视为你对自己使用了一张【杀】。",
}
--武将信息：姜维
JiangWei = sgs.CreateLuaGeneral{
	name = "wis_jiangwei",
	real_name = "jiangwei",
	translation = "智·姜维",
	show_name = "姜维",
	title = "天水麒麟",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	cv = "",
	illustrator = "",
	skills = {YiCai, BeiFa},
	last_word = "",
	resource = "jiangwei",
}
--[[****************************************************************
	称号：武侯后继
	武将：蒋琬
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：后援（阶段技）
	描述：你可以弃置两张手牌并令一名其他角色摸两张牌。
]]--
HouYuan = sgs.CreateLuaSkill{
	name = "wisHouYuan",
	translation = "后援",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置两张手牌并令一名其他角色摸两张牌。",
}
--[[
	技能：筹粮
	描述：回合结束阶段开始时，若你手牌少于三张，你可以从牌堆顶亮出4-X张牌（X为你的手牌数），你获得其中的基本牌，将其余的牌置入弃牌堆。
]]--
ChouLiang = sgs.CreateLuaSkill{
	name = "wisChouLiang",
	translation = "筹粮",
	description = "回合结束阶段开始时，若你手牌少于三张，你可以从牌堆顶亮出4-X张牌（X为你的手牌数），你获得其中的基本牌，将其余的牌置入弃牌堆。",
}
--武将信息：蒋琬
JiangWan = sgs.CreateLuaGeneral{
	name = "wis_jiangwan",
	real_name = "jiangwan",
	translation = "智·蒋琬",
	show_name = "蒋琬",
	title = "武侯后继",
	kingdom = "shu",
	maxhp = 3,
	order = 7,
	cv = "",
	illustrator = "",
	skills = {HouYuan, ChouLiang},
	last_word = "",
	resource = "jiangwan",
}
--[[****************************************************************
	称号：江东的小霸王
	武将：孙策
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：霸王
	描述：每当你使用的【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为你对至多两名角色各使用了一张【杀】（此杀不计入每阶段的使用限制）。
]]--
BaWang = sgs.CreateLuaSkill{
	name = "wisBaWang",
	translation = "霸王",
	description = "每当你使用的【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为你对至多两名角色各使用了一张【杀】（此杀不计入每阶段的使用限制）。",
}
--[[
	技能：危殆（主公技）[空壳技能]
	描述：当你需要使用一张【酒】时，你可以令其他吴势力角色将一张黑桃2~9的手牌置入弃牌堆，视为你将该牌当【酒】使用。
]]--
WeiDai = sgs.CreateLuaSkill{
	name = "wisWeiDai",
	translation = "危殆",
	description = "<font color=\"yellow\"><b>主公技</b></font>，当你需要使用一张【酒】时，你可以令其他吴势力角色将一张黑桃2~9的手牌置入弃牌堆，视为你将该牌当【酒】使用。",
}
--武将信息：孙策
SunCe = sgs.CreateLuaGeneral{
	name = "wis_sunce",
	real_name = "sunce",
	translation = "智·孙策",
	show_name = "孙策",
	title = "江东的小霸王",
	kingdom = "wu",
	maxhp = 4,
	order = 4,
	cv = "",
	illustrator = "",
	skills = {BaWang, WeiDai},
	last_word = "",
	resource = "sunce",
}
--[[****************************************************************
	称号：东吴重臣
	武将：张昭
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：笼络
	描述：回合结束阶段开始时，你可以令一名其他角色摸你于此回合弃牌阶段弃置的牌等量的牌。
]]--
LongLuo = sgs.CreateLuaSkill{
	name = "wisLongLuo",
	translation = "笼络",
	description = "回合结束阶段开始时，你可以令一名其他角色摸你于此回合弃牌阶段弃置的牌等量的牌。",
}
--[[
	技能：辅佐
	描述：每当其他角色拼点时，你可以弃置一张点数小于8的手牌，让其中一名角色的拼点牌的点数加上这张牌点数的二分之一（向下取整）。
]]--
FuZuo = sgs.CreateLuaSkill{
	name = "wisFuZuo",
	translation = "辅佐",
	description = "每当其他角色拼点时，你可以弃置一张点数小于8的手牌，让其中一名角色的拼点牌的点数加上这张牌点数的二分之一（向下取整）。",
}
--[[
	技能：尽瘁
	描述：当你死亡时，可选择一名角色，令该角色摸三张牌或者弃置三张牌。
]]--
JinCui = sgs.CreateLuaSkill{
	name = "wisJinCui",
	translation = "尽瘁",
	description = "当你死亡时，可选择一名角色，令该角色摸三张牌或者弃置三张牌。",
}
--武将信息：张昭
ZhangZhao = sgs.CreateLuaGeneral{
	name = "wis_zhangzhao",
	real_name = "zhangzhao",
	translation = "智·张昭",
	show_name = "张昭",
	title = "东吴重臣",
	kingdom = "wu",
	maxhp = 3,
	order = 1,
	cv = "",
	illustrator = "",
	skills = {LongLuo, FuZuo, JinCui},
	last_word = "",
	resource = "zhangzhao",
}
--[[****************************************************************
	称号：心高命薄
	武将：华雄
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：霸刀
	描述：当你成为黑色的【杀】的目标后，你可以使用一张【杀】。
]]--
BaDao = sgs.CreateLuaSkill{
	name = "wisBaDao",
	translation = "霸刀",
	description = "当你成为黑色的【杀】的目标后，你可以使用一张【杀】。",
}
--[[
	技能：温酒（锁定技）
	描述：你使用黑色的【杀】造成的伤害+1，你无法闪避红色的【杀】。
]]--
WenJiu = sgs.CreateLuaSkill{
	name = "wisWenJiu",
	translation = "温酒",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你使用黑色的【杀】造成的伤害+1，你无法闪避红色的【杀】。",
}
--武将信息：华雄
HuaXiong = sgs.CreateLuaGeneral{
	name = "wis_huaxiong",
	real_name = "huaxiong",
	translation = "智·华雄",
	show_name = "华雄",
	title = "心高命薄",
	kingdom = "qun",
	maxhp = 4,
	order = 5,
	cv = "",
	illustrator = "",
	skills = {BaDao, WenJiu},
	last_word = "",
	resource = "huaxiong",
}
--[[****************************************************************
	称号：甘冒虎口
	武将：田丰
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：识破
	描述：一名角色的判定阶段开始时，你可以弃置两张牌并获得该角色判定区内的所有牌。
]]--
ShiPo = sgs.CreateLuaSkill{
	name = "wisShiPo",
	translation = "识破",
	description = "一名角色的判定阶段开始时，你可以弃置两张牌并获得该角色判定区内的所有牌。",
}
--[[
	技能：固守
	描述：回合外，当你使用或打出一张基本牌时，你可以摸一张牌。
]]--
GuShou = sgs.CreateLuaSkill{
	name = "wisGuShou",
	translation = "固守",
	description = "回合外，当你使用或打出一张基本牌时，你可以摸一张牌。",
}
--[[
	技能：狱刎（锁定技）
	描述：当你死亡时，伤害来源为自己。
]]--
YuWen = sgs.CreateLuaSkill{
	name = "wisYuWen",
	translation = "狱刎",
	description = "<font color=\"blue\"><b>锁定技</b></font>，当你死亡时，伤害来源为自己。",
}
--武将信息：田丰
TianFeng = sgs.CreateLuaGeneral{
	name = "wis_tianfeng",
	real_name = "tianfeng",
	translation = "智·田丰",
	show_name = "田丰",
	title = "甘冒虎口",
	kingdom = "qun",
	maxhp = 3,
	order = 5,
	cv = "",
	illustrator = "",
	skills = {ShiPo, GuShou, YuWen},
	last_word = "",
	resource = "tianfeng",
}
--[[****************************************************************
	称号：水镜先生
	武将：司马徽
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：授业
	描述：出牌阶段，你可以弃置一张红色手牌，令至多两名其他角色各摸一张牌。“解惑”发动后，每阶段限一次。
]]--
ShouYe = sgs.CreateLuaSkill{
	name = "wisShouYe",
	translation = "授业",
	description = "出牌阶段，你可以弃置一张红色手牌，令至多两名其他角色各摸一张牌。“解惑”发动后，每阶段限一次。",
}
--[[
	技能：解惑（觉醒技）
	描述：当你发动“授业”不少于7人次时，须减1点体力上限，并获得技能“师恩”（其他角色使用非延时锦囊时，可以让你摸一张牌）。
]]--
JieHuo = sgs.CreateLuaSkill{
	name = "wisJieHuo",
	translation = "解惑",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，当你发动“授业”不少于7人次时，须减1点体力上限，并获得技能“师恩”（其他角色使用非延时锦囊时，可以让你摸一张牌）。",
}
--[[
	技能：师恩
	描述：其他角色使用非延时锦囊时，可以让你摸一张牌。
]]--
ShiEn = sgs.CreateLuaSkill{
	name = "wisShiEn",
	translation = "师恩",
	description = "其他角色使用非延时锦囊时，可以让你摸一张牌。",
}
--武将信息：司马徽
SiMaHui = sgs.CreateLuaGeneral{
	name = "wis_simahui",
	real_name = "simahui",
	translation = "智·司马徽",
	show_name = "司马徽",
	title = "水镜先生",
	kingdom = "qun",
	maxhp = 4,
	order = 1,
	cv = "",
	illustrator = "",
	skills = {ShouYe, JieHuo},
	related_skills = ShiEn,
	last_word = "",
	resource = "simahui",
}
--[[****************************************************************
	智武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "wisdom",
	translation = "智包",
	generals = {
		XuYou, JiangWei, JiangWan, SunCe,
		ZhangZhao, HuaXiong, TianFeng, SiMaHui,
	},
}