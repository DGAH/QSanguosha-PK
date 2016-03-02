--[[
	太阳神三国杀武将单挑对战平台·山武将包
	武将总数：8
	武将一览：
		1、张郃（巧变）
		2、邓艾（屯田、凿险）+（急袭）
		3、姜维（挑衅、志继）+（观星）
		4、刘禅（享乐、放权、若愚）+（激将）
		5、孙策（激昂、魂姿、制霸）+（英姿、英魂）
		6、张昭张纮（直谏、固政）
		7、左慈（化身、新生）
		8、蔡文姬（悲歌、断肠）
]]--
--[[****************************************************************
	称号：料敌机先
	武将：张郃
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：巧变
	描述：除准备阶段和结束阶段的阶段开始前，你可以弃置一张手牌：若如此做，你跳过该阶段。若以此法跳过摸牌阶段，你可以依次获得一至两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌置于另一名角色相应的区域内。
]]--
QiaoBian = sgs.CreateLuaSkill{
	name = "QiaoBian",
	translation = "巧变",
	description = "除准备阶段和结束阶段的阶段开始前，你可以弃置一张手牌：若如此做，你跳过该阶段。若以此法跳过摸牌阶段，你可以依次获得一至两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌置于另一名角色相应的区域内。",
	audio = {
		"虚招令旗，以之惑敌。",
		"绝其汲道，困其刍粮。",
		"以守为攻，后发制人。",
		"停止前进，扎营御敌！",
	},
}
--武将信息：张郃
ZhangHe = sgs.CreateLuaGeneral{
	name = "zhanghe",
	translation = "张郃",
	title = "料敌机先",
	kingdom = "wei",
	order = 5,
	cv = "爪子",
	illustrator = "张帅",
	skills = QiaoBian,
	last_word = "归兵勿追，追兵难归啊……",
	resource = "zhanghe",
}
--[[****************************************************************
	称号：矫然的壮士
	武将：邓艾
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：屯田
	描述：你的回合外，每当你失去一次牌后，你可以进行判定：若结果不为♥，将判定牌置于武将牌上，称为“田”。你与其他角色的距离-X。（X为“田”的数量） 
]]--
TunTian = sgs.CreateLuaSkill{
	name = "TunTian",
	translation = "屯田",
	description = "你的回合外，每当你失去一次牌后，你可以进行判定：若结果不为红心，将判定牌置于武将牌上，称为“田”。你与其他角色的距离-X。（X为“田”的数量）",
	audio = {
		"食者，兵之所系；农者，胜之所依。",
		"积军资之粮，通漕运之道。",
	},
}
--[[
	技能：凿险（觉醒技）
	描述：准备阶段开始时，若你的“田”大于或等于三张，你失去1点体力上限，然后获得“急袭”（你可以将一张“田”当【顺手牵羊】使用）。
]]--
ZaoXian = sgs.CreateLuaSkill{
	name = "ZaoXian",
	translation = "凿险",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的“田”大于或等于三张，你失去1点体力上限，然后获得“急袭”。\
\
☆<b>急袭</b>：你可以将一张“田”当【顺手牵羊】使用。",
	audio = "孤注一掷，胜败在此一举！",
}
--[[
	技能：急袭
	描述：你可以将一张“田”当【顺手牵羊】使用。
]]--
JiXi = sgs.CreateLuaSkill{
	name = "JiXi",
	translation = "急袭",
	description = "你可以将一张“田”当【顺手牵羊】使用。",
	audio = {
		"给我一张，又何妨？",
		"明修栈道，暗度陈仓！",
	},
}
--武将信息：邓艾
DengAi = sgs.CreateLuaGeneral{
	name = "dengai",
	translation = "邓艾",
	title = "矫然的壮士",
	kingdom = "wei",
	order = 7,
	cv = "烨子",
	skills = {TunTian, ZaoXian},
	related_skills = JiXi,
	last_word = "吾破蜀克敌，竟葬于奸贼之手！",
	resource = "dengai",
}
--[[****************************************************************
	称号：龙的衣钵
	武将：姜维
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：挑衅（阶段技）
	描述：你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。
]]--
TiaoXin = sgs.CreateLuaSkill{
	name = "TiaoXin",
	translation = "挑衅",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。",
	audio = {
		"贼将早降，可免一死！",
		"哼，贼将莫不是怕了？",
		"敌将可破得我八阵？",
	},
}
--[[
	技能：志继（觉醒技）
	描述：准备阶段开始时，若你没有手牌，你失去1点体力上限，然后回复1点体力或摸两张牌，并获得“观星”。
]]--
ZhiJi = sgs.CreateLuaSkill{
	name = "ZhiJi",
	translation = "志继",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你没有手牌，你失去1点体力上限，然后回复1点体力或摸两张牌，并获得“观星”。",
	audio = "今虽穷极，然先帝之志、丞相之托，维岂敢忘？！",
}
--[[
	技能：观星
	描述：
]]--
--武将信息：姜维
JiangWei = sgs.CreateLuaGeneral{
	name = "jiangwei",
	translation = "姜维",
	title = "龙的衣钵",
	kingdom = "shu",
	order = 8,
	cv = "Jr. Wakaran，LeleK",
	skills = {TiaoXin, ZhiJi},
	related_skills = "guanxing",
	last_word = "臣等正欲死战，陛下何故先降？",
	resource = "jiangwei",
}
--[[****************************************************************
	称号：无为的真命主
	武将：刘禅
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：享乐（锁定技）
	描述：每当你成为【杀】的目标时，【杀】的使用者须弃置一张基本牌，否则此【杀】对你无效。
]]--
XiangLe = sgs.CreateLuaSkill{
	name = "XiangLe",
	translation = "享乐",
	description = "<font color=\"blue\"><b>享乐</b></font>，每当你成为【杀】的目标时，【杀】的使用者须弃置一张基本牌，否则此【杀】对你无效。",
	audio = {
		"此间乐，不思蜀。呵呵呵……",
		"如此甚好，哈哈，甚好！",
	},
}
--[[
	技能：放权
	描述：你可以跳过你的出牌阶段。若以此法跳过出牌阶段，结束阶段开始时你可以弃置一张手牌并选择一名其他角色：若如此做，该角色进行一个额外的回合。
]]--
FangQuan = sgs.CreateLuaSkill{
	name = "FangQuan",
	translation = "放权",
	description = "你可以跳过你的出牌阶段。若以此法跳过出牌阶段，结束阶段开始时你可以弃置一张手牌并选择一名其他角色：若如此做，该角色进行一个额外的回合。",
	audio = {
		"一切但凭相父作主。",
		"孩儿……愚钝。",
	},
}
--[[
	技能：若愚（主公技、觉醒技）[空壳技能]
	描述：准备阶段开始时，若你的体力值为场上最少（或之一），你增加1点体力上限，回复1点体力，然后获得“激将”。
]]--
RuoYu = sgs.CreateLuaSkill{
	name = "RuoYu",
	translation = "若愚",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的体力值为场上最少（或之一），你增加1点体力上限，回复1点体力，然后获得“激将”。",
}
--[[
	技能：激将
	描述：
]]--
--武将信息：刘禅
LiuShan = sgs.CreateLuaGeneral{
	name = "liushan",
	translation = "刘禅",
	title = "无为的真命主",
	kingdom = "shu",
	maxhp = 3,
	order = 6,
	cv = "V7",
	illustrator = "LiuHeng",
	skills = {XiangLe, FangQuan, RuoYu},
	related_skills = "jijiang",
	last_word = "吾降！吾降矣……",
	resource = "liushan",
}
--[[****************************************************************
	称号：江东的小霸王
	武将：孙策
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：激昂
	描述：每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。
]]--
JiAng = sgs.CreateLuaSkill{
	name = "JiAng",
	translation = "激昂",
	description = "每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。",
	audio = {
		"所向皆破，敌莫敢当！",
		"众将听令，直讨敌酋！",
	},
}
--[[
	技能：魂姿（觉醒技）
	描述：准备阶段开始时，若你的体力值为1，你失去1点体力上限，然后获得“英姿”和“英魂”。
]]--
HunZi = sgs.CreateLuaSkill{
	name = "HunZi",
	translation = "魂姿",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的体力值为1，你失去1点体力上限，然后获得“英姿”和“英魂”。",
	audio = "父亲在上，魂佑江东；公瑾在旁，智定天下！",
}
--[[
	技能：制霸（主公技、阶段技）[空壳技能]
	描述：其他吴势力角色的出牌阶段，该角色可以与你拼点：若该角色没赢，你可以获得你与该角色的拼点牌。若你已发动“魂姿”，你可以拒绝此拼点。
]]--
ZhiBa = sgs.CreateLuaSkill{
	name = "ZhiBa",
	translation = "制霸",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"green\"><b>阶段技</b></font>，其他吴势力角色的出牌阶段，该角色可以与你拼点：若该角色没赢，你可以获得你与该角色的拼点牌。若你已发动“魂姿”，你可以拒绝此拼点。",
}
--[[
	技能：英姿
	描述：
]]--
--[[
	技能：英魂
	描述：
]]--
--武将信息：孙策
SunCe = sgs.CreateLuaGeneral{
	name = "sunce",
	translation = "孙策",
	title = "江东的小霸王",
	kingdom = "wu",
	order = 6,
	cv = "猎狐",
	skills = {JiAng, HunZi, ZhiBa},
	related_skills = {"YingZi", "YingHun"},
	last_word = "内事不决问张昭，外事不决问周瑜……",
	resource = "sunce",
}
--[[****************************************************************
	称号：经天纬地
	武将：张昭张纮
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：直谏
	描述：出牌阶段，你可以将你手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。
]]--
ZhiJian = sgs.CreateLuaSkill{
	name = "ZhiJian",
	translation = "直谏",
	description = "出牌阶段，你可以将你手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。",
	audio = "忠謇方直，动不为己。",
}
--[[
	技能：固政
	描述：其他角色的弃牌阶段结束时，你可以令其获得一张弃牌堆中此阶段中因弃置而置入弃牌堆的该角色的手牌：若如此做，你获得弃牌堆中其余此阶段因弃置而置入弃牌堆的牌。
]]--
GuZheng = sgs.CreateLuaSkill{
	name = "GuZheng",
	translation = "固政",
	description = "其他角色的弃牌阶段结束时，你可以令其获得一张弃牌堆中此阶段中因弃置而置入弃牌堆的该角色的手牌：若如此做，你获得弃牌堆中其余此阶段因弃置而置入弃牌堆的牌。",
	audio = {
		"隐息师徒，广开播殖。",
		"任贤使能，务崇宽惠。",
	},
}
--武将信息：张昭张纮
ZhangZhaoZhangHong = sgs.CreateLuaGeneral{
	name = "zhangzhaozhanghong",
	translation = "张昭张纮",
	title = "经天纬地",
	kingdom = "wu",
	maxhp = 3,
	crowded = true,
	order = 1,
	cv = "喵小林，风叹息",
	illustrator = "废柴男",
	skills = {ZhiJian, GuZheng},
	last_word = "此生智谋，已为江东尽……",
	resource = "zhangzhaozhanghong",
}
--[[****************************************************************
	称号：迷之仙人
	武将：左慈
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：化身
	描述：游戏开始前，你获得两张未加入游戏的武将牌，称为“化身牌”，然后选择一张“化身牌”的一项技能（除主公技、限定技与觉醒技）。回合开始时和回合结束后，你可以更换“化身牌”，然后你可以为当前“化身牌”重新选择一项技能。你拥有你以此法选择的技能且性别与势力改为与“化身牌”相同。
]]--
HuaShen = sgs.CreateLuaSkill{
	name = "HuaShen",
	translation = "化身",
	description = "游戏开始前，你获得两张未加入游戏的武将牌，称为“化身牌”，然后选择一张“化身牌”的一项技能（除主公技、限定技与觉醒技）。回合开始时和回合结束后，你可以更换“化身牌”，然后你可以为当前“化身牌”重新选择一项技能。你拥有你以此法选择的技能且性别与势力改为与“化身牌”相同。",
	audio = {
		"藏形变身，自在吾心。（男声）",
		"遁形幻千，随意所欲。（男声）",
		"藏形变身，自在吾心。（女声）",
		"遁形幻千，随意所欲。（女声）",
	},
}
--[[
	技能：新生
	描述：每当你受到1点伤害后，你可以获得一张“化身牌”。
]]--
XinSheng = sgs.CreateLuaSkill{
	name = "XinSheng",
	translation = "新生",
	description = "每当你受到1点伤害后，你可以获得一张“化身牌”。",
	audio = {
		"吐故纳新，师法天地。（男声）",
		"灵根不灭，连绵不绝。（男声）",
		"吐故纳新，师法天地。（女声）",
		"灵根不灭，连绵不绝。（女声）",
	},
}
--武将信息：左慈
ZuoCi = sgs.CreateLuaGeneral{
	name = "zuoci",
	translation = "左慈",
	title = "迷之仙人",
	kingdom = "qun",
	maxhp = 3,
	order = 8,
	cv = "东方胤弘，眠眠",
	illustrator = "废柴男",
	skills = {HuaShen, XinSheng},
	last_word = "释知遗形，神灭形消……",
	resource = "zuoci",
	marks = {"@huashen"},
}
--[[****************************************************************
	称号：异乡的孤女
	武将：蔡文姬
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：悲歌
	描述：每当一名角色受到一次【杀】的伤害后，你可以弃置一张牌令该角色进行判定：若结果为♥，该角色回复1点体力；♦，该角色摸两张牌；♠，伤害来源将其武将牌翻面；♣，伤害来源弃置两张牌。
]]--
BeiGe = sgs.CreateLuaSkill{
	name = "BeiGe",
	translation = "悲歌",
	description = "每当一名角色受到一次【杀】的伤害后，你可以弃置一张牌令该角色进行判定：若结果为红心，该角色回复1点体力；方块，该角色摸两张牌；黑桃，伤害来源将其武将牌翻面；草花，伤害来源弃置两张牌。",
	audio = {
		"欲死不能得，欲生无一可。",
		"此行远兮，君尚珍重。",
		"翩翩吹我衣，肃肃入我耳。",
		"岂偕老之可期，庶尽欢于余年。",
	},
}
--[[
	技能：断肠（锁定技）
	描述：杀死你的角色失去所有武将技能。
]]--
DuanChang = sgs.CreateLuaSkill{
	name = "DuanChang",
	translation = "断肠",
	description = "<font color=\"blue\"><b>锁定技</b></font>，杀死你的角色失去所有武将技能。",
	audio = {
		"雁飞高兮邈难寻，空断肠兮思喑喑。",
		"胡人落泪沾边草，汉使断肠对归客。",
	},
}
--武将信息：蔡文姬
CaiWenJi = sgs.CreateLuaGeneral{
	name = "caiwenji",
	real_name = "caiyan",
	translation = "蔡文姬",
	title = "异乡的孤女",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 5,
	cv = "呼呼",
	illustrator = "Sonia Tang",
	skills = {BeiGe, DuanChang},
	resource = "caiyan",
	marks = {"@duanchang"},
}
--[[****************************************************************
	山武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "mountain",
	translation = "山包",
	generals = {
		ZhangHe, DengAi, JiangWei, LiuShan, SunCe, ZhangZhaoZhangHong, ZuoCi, CaiWenJi,
	},
}