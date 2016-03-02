--[[
	太阳神三国杀武将单挑对战平台·火武将包
	武将总数：8
	武将一览：
		1、典韦（强袭）
		2、荀彧（驱虎、节命）
		3、庞统（连环、涅槃）
		4、诸葛亮（八阵、火计、看破）
		5、太史慈（天义）
		6、袁绍（乱击、血裔）
		7、颜良文丑（双雄）
		8、庞德（马术、猛进）
]]--
--[[****************************************************************
	称号：古之恶来
	武将：典韦
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：强袭（阶段技）
	描述：你可以失去1点体力或弃置一张武器牌，并选择攻击范围内的一名角色：若如此做，你对该角色造成1点伤害。
]]--
QiangXi = sgs.CreateLuaSkill{
	name = "QiangXi",
	translation = "强袭",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以失去1点体力或弃置一张武器牌，并选择攻击范围内的一名角色：若如此做，你对该角色造成1点伤害。",
	audio = "五步之内，汝命休矣！",
}
--武将信息：典韦
DianWei = sgs.CreateLuaGeneral{
	name = "dianwei",
	translation = "典韦",
	title = "古之恶来",
	kingdom = "wei",
	order = 6,
	cv = "褪色",
	illustrator = "小冷",
	skills = QiangXi,
	last_word = "主公……我就到……这儿了……",
	resource = "dianwei",
}
--[[****************************************************************
	称号：王佐之才
	武将：荀彧
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：驱虎（阶段技）
	描述：你可以与一名体力值大于你的角色拼点：若你赢，该角色对其攻击范围内的一名由你选择的角色造成1点伤害；若你没赢，该角色对你造成1点伤害。
]]--
QuHu = sgs.CreateLuaSkill{
	name = "QuHu",
	translation = "驱虎",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名体力值大于你的角色拼点：若你赢，该角色对其攻击范围内的一名由你选择的角色造成1点伤害；若你没赢，该角色对你造成1点伤害。",
	audio = {
		"主公莫忧，吾有一计。",
		"驱虎吞狼，坐收渔利。",
	},
}
--[[
	技能：节命
	描述：每当你受到1点伤害后，你可以令一名角色将手牌补至X张。（X为该角色体力上限且至多为5）
]]--
JieMing = sgs.CreateLuaSkill{
	name = "JieMing",
	translation = "节命",
	description = "每当你受到1点伤害后，你可以令一名角色将手牌补至X张。（X为该角色体力上限且至多为5）",
	audio = {
		"为守汉节，不惜吾命！",
		"秉忠贞之志，守谦退之节。",
	},
}
--武将信息：荀彧
XunYu = sgs.CreateLuaGeneral{
	name = "xunyu",
	translation = "荀彧",
	title = "王佐之才",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	cv = "听雨",
	illustrator = "LiuHeng",
	skills = {QuHu, JieMing},
	last_word = "身为汉臣，至死不渝。",
	resource = "xunyu",
}
--[[****************************************************************
	称号：凤雏
	武将：庞统
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：连环
	描述：你可以将一张♣手牌当【铁索连环】使用或重铸。
]]--
LianHuan = sgs.CreateLuaSkill{
	name = "LianHuan",
	translation = "连环",
	description = "你可以将一张草花手牌当【铁索连环】使用或重铸。",
	audio = "舟船成排，潮水何惧？",
}
--[[
	技能：涅槃（限定技）
	描述：每当你处于濒死状态时，你可以弃置你区域内的牌，将武将牌恢复至初始状态，然后摸三张牌并回复至3点体力。
]]--
NiePan = sgs.CreateLuaSkill{
	name = "NiePan",
	translation = "涅槃",
	description = "<font color=\"red\"><b>限定技</b></font>，每当你处于濒死状态时，你可以弃置你区域内的牌，将武将牌恢复至初始状态，然后摸三张牌并回复至3点体力。",
	audio = "凤凰涅槃，浴火重生！",
}
--武将信息：庞统
PangTong = sgs.CreateLuaGeneral{
	name = "pangtong",
	translation = "庞统",
	title = "凤雏",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "无花有酒",
	skills = {LianHuan, NiePan},
	last_word = "落凤坡？此地不利于吾。",
	resource = "pangtong",
	marks = {"@nirvana"},
}
--[[****************************************************************
	称号：卧龙
	武将：诸葛亮
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：八阵（锁定技）
	描述：若你的装备区没有防具牌，视为你装备【八卦阵】。
]]--
BaZhen = sgs.CreateLuaSkill{
	name = "BaZhen",
	translation = "八阵",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的装备区没有防具牌，视为你装备【八卦阵】。",
	audio = "此阵可挡精兵十万！",
}
--[[
	技能：火计
	描述：你可以将一张红色手牌当【火攻】使用。
]]--
HuoJi = sgs.CreateLuaSkill{
	name = "HuoJi",
	translation = "火计",
	description = "你可以将一张红色手牌当【火攻】使用。",
	audio = {
		"欲破敌军，宜用火攻。",
		"且备硫磺焰硝，待命引火！",
	},
}
--[[
	技能：看破
	描述：你可以将一张黑色手牌当【无懈可击】使用。
]]--
KanPo = sgs.CreateLuaSkill{
	name = "KanPo",
	translation = "看破",
	description = "你可以将一张黑色手牌当【无懈可击】使用。",
	audio = "哼！此小计尔。",
}
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "wolong",
	real_name = "zhugeliang",
	translation = "卧龙诸葛亮",
	title = "卧龙",
	show_name = "诸葛亮",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "彗星",
	illustrator = "北",
	skills = {BaZhen, HuoJi, KanPo},
	last_word = "悠悠苍天，曷此其极……",
	resource = "zhugeliang",
}
--[[****************************************************************
	称号：笃烈之士
	武将：太史慈
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：天义（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，本回合，你可以额外使用一张【杀】，你使用【杀】可以额外选择一名目标且无距离限制；若你没赢，你不能使用【杀】，直到回合结束。
]]--
TianYi = sgs.CreateLuaSkill{
	name = "TianYi",
	translation = "天义",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，本回合，你可以额外使用一张【杀】，你使用【杀】可以额外选择一名目标且无距离限制；若你没赢，你不能使用【杀】，直到回合结束。",
	audio = "大丈夫生于乱世，当立不世之功！",
}
--武将信息：太史慈
TaiShiCi = sgs.CreateLuaGeneral{
	name = "taishici",
	translation = "太史慈",
	title = "笃烈之士",
	kingdom = "wu",
	order = 4,
	cv = "口渴口樂",
	illustrator = "Tuu.",
	skills = TianYi,
	last_word = "今所志未遂，奈何死乎？",
	resource = "taishici",
}
--[[****************************************************************
	称号：高贵的名门
	武将：袁绍
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：乱击
	描述：你可以将两张相同花色的手牌当【万箭齐发】使用。
]]--
LuanJi = sgs.CreateLuaSkill{
	name = "LuanJi",
	translation = "乱击",
	description = "你可以将两张相同花色的手牌当【万箭齐发】使用。",
	audio = {
		"弓箭手出列！",
		"放箭！",
	},
}
--[[
	技能：血裔（主公技、锁定技）[空壳技能]
	描述：你的手牌上限+2X。（X为其他群雄角色的数量）
]]--
XueYi = sgs.CreateLuaSkill{
	name = "XueYi",
	translation = "血裔",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"blue\"><b>锁定技</b></font>，你的手牌上限+2X。（X为其他群雄角色的数量）",
}
--武将信息：袁绍
YuanShao = sgs.CreateLuaGeneral{
	name = "yuanshao",
	translation = "袁绍",
	title = "高贵的名门",
	kingdom = "qun",
	order = 1,
	cv = "耗子王",
	illustrator = "Sonia Tang",
	skills = {LuanJi, XueYi},
	last_word = "天不助袁哪！",
	resource = "yuanshao",
}
--[[****************************************************************
	称号：虎狼兄弟
	武将：颜良文丑
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：双雄
	描述：摸牌阶段开始时，你可以放弃摸牌并进行判定：若如此做，判定牌生效后你获得之，本回合你可以将与此牌颜色不同的手牌当【决斗】使用。
]]--
ShuangXiong = sgs.CreateLuaSkill{
	name = "ShuangXiong",
	translation = "双雄",
	description = "摸牌阶段开始时，你可以放弃摸牌并进行判定：若如此做，判定牌生效后你获得之，本回合你可以将与此牌颜色不同的手牌当【决斗】使用。",
	audio = {
		"虎狼兄弟，无往不利！",
		"兄弟同心，其利断金！",
	},
}
--武将信息：颜良文丑
YanLiangWenChou = sgs.CreateLuaGeneral{
	name = "yanliangwenchou",
	translation = "颜良文丑",
	title = "虎狼兄弟",
	kingdom = "qun",
	crowded = true,
	order = 6,
	cv = "墨染の飞猫，霸气爷们",
	skills = ShuangXiong,
	last_word = "生不逢时啊！",
	resource = "yanliangwenchou",
}
--[[****************************************************************
	称号：人马一体
	武将：庞德
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：猛进
	描述：你使用的【杀】被目标角色的【闪】抵消后，你可以弃置该角色的一张牌。
]]--
MengJin = sgs.CreateLuaSkill{
	name = "MengJin",
	translation = "猛进",
	description = "你使用的【杀】被目标角色的【闪】抵消后，你可以弃置该角色的一张牌。",
	audio = "西凉铁骑，杀汝片甲不留！",
}
--武将信息：庞德
PangDe = sgs.CreateLuaGeneral{
	name = "pangde",
	translation = "庞德",
	title = "人马一体",
	kingdom = "qun",
	order = 5,
	cv = "Glory",
	illustrator = "LiuHeng",
	skills = {"mashu", MengJin},
	last_word = "宁做国家鬼，不为贼将也！",
	resource = "pangde",
}
--[[****************************************************************
	火武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "fire",
	translation = "火包",
	generals = {
		DianWei, XunYu, PangTong, ZhuGeLiang, TaiShiCi, YuanShao, YanLiangWenChou, PangDe,
	},
}