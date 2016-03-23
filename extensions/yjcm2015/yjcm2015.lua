--[[
	太阳神三国杀武将单挑对战平台·一将成名2015武将包
	武将总数：11
	武将一览：
		1、曹叡（明鉴、恢拓、兴衰）
		2、曹休（讨袭）
		3、公孙渊（怀异）
		4、郭图逄纪（急攻、饰非）
		5、刘谌（战绝、勤王）
		6、全琮（振赡）
		7、孙休（宴诛、兴学、诏缚）
		8、夏侯氏（樵拾、燕语）
		9、张嶷（抚戎、矢志）
		10、钟繇（活墨、佐定）
		11、朱治（安国）
]]--
--[[****************************************************************
	称号：天资的明君
	武将：曹叡
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：明鉴
	描述：你可以跳过出牌阶段并将所有手牌交给一名其他角色。若如此做，你结束此回合，然后该角色进行一个额外的出牌阶段。
]]--
MingJian = sgs.CreateLuaSkill{
	name = "yj5MingJian",
	translation = "明鉴",
	description = "你可以跳过出牌阶段并将所有手牌交给一名其他角色。若如此做，你结束此回合，然后该角色进行一个额外的出牌阶段。",
}
--[[
	技能：恢拓
	描述：每当你受到伤害后，你可以令一名角色进行一次判定，若结果为红色，该角色回复1点体力；若结果为黑色，该角色摸X张牌（X为此次伤害的伤害数）。
]]--
HuiTuo = sgs.CreateLuaSkill{
	name = "yj5HuiTuo",
	translation = "恢拓",
	description = "每当你受到伤害后，你可以令一名角色进行一次判定，若结果为红色，该角色回复1点体力；若结果为黑色，该角色摸X张牌（X为此次伤害的伤害数）。",
}
--[[
	技能：兴衰（主公技、限定技）[空壳技能]
	描述：当你进入濒死状态时，其他魏势力角色可依次令你回复1点体力，然后这些角色依次受到1点伤害。
]]--
XingShuai = sgs.CreateLuaSkill{
	name = "yj5XingShuai",
	translation = "兴衰",
	description = "<font color=\"yellow\"><b>主公技</b></font>，<font color=\"red\"><b>限定技</b></font>，当你进入濒死状态时，其他魏势力角色可依次令你回复1点体力，然后这些角色依次受到1点伤害。",
}
--武将信息：曹叡
CaoRui = sgs.CreateLuaGeneral{
	name = "yj_v_caorui",
	real_name = "caorui",
	translation = "曹叡",
	title = "天资的明君",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	skills = {MingJian, HuiTuo, XingShuai},
	resource = "caorui",
}
--[[****************************************************************
	称号：千里骐骥
	武将：曹休
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：讨袭（阶段技）
	描述：你使用牌指定一名其他角色为唯一目标后，你可以亮出其一张手牌直到回合结束，并且你可以于此回合内将此牌如手牌般使用。回合结束时，若该角色未失去此手牌，则你失去1点体力。
]]--
TaoXi = sgs.CreateLuaSkill{
	name = "yj5TaoXi",
	translation = "讨袭",
	description = "<font color=\"green\"><b>阶段技</b></font>，你使用牌指定一名其他角色为唯一目标后，你可以亮出其一张手牌直到回合结束，并且你可以于此回合内将此牌如手牌般使用。回合结束时，若该角色未失去此手牌，则你失去1点体力。",
}
--武将信息：曹休
CaoXiu = sgs.CreateLuaGeneral{
	name = "yj_v_caoxiu",
	real_name = "caoxiu",
	translation = "曹休",
	title = "千里骐骥",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	skills = TaoXi,
	resource = "caoxiu",
}
--[[****************************************************************
	称号：狡徒悬海
	武将：公孙渊
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：怀异（阶段技）
	描述：你可以展示所有手牌，若其中包含不止一种颜色，则你选择一种颜色并弃置该颜色的所有手牌，然后你获得至多X名其他角色的各一张牌（X为你以此法弃置的手牌数）；若你以此法获得的牌不少于两张，你失去1点体力。
]]--
HuaiYi = sgs.CreateLuaSkill{
	name = "yj5HuaiYi",
	translation = "怀异",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以展示所有手牌，若其中包含不止一种颜色，则你选择一种颜色并弃置该颜色的所有手牌，然后你获得至多X名其他角色的各一张牌（X为你以此法弃置的手牌数）；若你以此法获得的牌不少于两张，你失去1点体力。",
}
--武将信息：公孙渊
GongSunYuan = sgs.CreateLuaGeneral{
	name = "yj_v_gongsunyuan",
	real_name = "gongsunyuan",
	translation = "公孙渊",
	title = "狡徒悬海",
	kingdom = "qun",
	maxhp = 4,
	order = 5,
	skills = HuaiYi,
	resource = "gongsunyuan",
}
--[[****************************************************************
	称号：凶蛇两端
	武将：郭图逄纪
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：急攻
	描述：出牌阶段开始时，你可以摸两张牌。若如此做，此回合你的手牌上限改为X(X为你此阶段造成的伤害数)。
]]--
JiGong = sgs.CreateLuaSkill{
	name = "yj5JiGong",
	translation = "急攻",
	description = "出牌阶段开始时，你可以摸两张牌。若如此做，此回合你的手牌上限改为X(X为你此阶段造成的伤害数)。",
}
--[[
	技能：饰非
	描述：当你需要使用或打出【闪】时，你可以令当前回合角色摸一张牌，然后若其手牌数不为全场最多，则你弃置全场手牌数最多（或之一）角色的一张牌，视为你使用或打出了一张【闪】。
]]--
ShiFei = sgs.CreateLuaSkill{
	name = "yj5ShiFei",
	translation = "饰非",
	description = "当你需要使用或打出【闪】时，你可以令当前回合角色摸一张牌，然后若其手牌数不为全场最多，则你弃置全场手牌数最多（或之一）角色的一张牌，视为你使用或打出了一张【闪】。",
}
--武将信息：郭图逄纪
GuoTuPangJi = sgs.CreateLuaGeneral{
	name = "yj_v_guotupangji",
	real_name = "guotupangji",
	translation = "郭图逄纪",
	title = "凶蛇两端",
	kingdom = "qun",
	maxhp = 3,
	order = 2,
	crowded = true,
	skills = {JiGong, ShiFei},
	resource = "guotupangji",
}
--[[****************************************************************
	称号：血荐轩辕
	武将：刘谌
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：战绝
	描述：出牌阶段，你可以将所有手牌当【决斗】使用，结算后你和以此法受到伤害的角色各摸一张牌。若你在同一阶段内以此法摸了两张或更多的牌，则此技能失效直到回合结束。
]]--
ZhanJue = sgs.CreateLuaSkill{
	name = "yj5ZhanJue",
	translation = "战绝",
	description = "出牌阶段，你可以将所有手牌当【决斗】使用，结算后你和以此法受到伤害的角色各摸一张牌。若你在同一阶段内以此法摸了两张或更多的牌，则此技能失效直到回合结束。",
}
--[[
	技能：勤王（主公技）[空壳技能]
	描述：你可以弃置一张牌，然后视为你发动“激将”。若有角色响应，则该角色打出【杀】时摸一张牌。
]]--
QinWang = sgs.CreateLuaSkill{
	name = "yj5QinWang",
	translation = "勤王",
	description = "<font color=\"yellow\"><b>主公技</b></font>，你可以弃置一张牌，然后视为你发动“激将”。若有角色响应，则该角色打出【杀】时摸一张牌。",
}
--武将信息：刘谌
LiuChen = sgs.CreateLuaGeneral{
	name = "yj_v_liuchen",
	real_name = "liuchen",
	translation = "刘谌",
	title = "血荐轩辕",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	skills = {ZhanJue, QinWang},
	resource = "liuchen",
}
--[[****************************************************************
	称号：慕势耀族
	武将：全琮
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：振赡
	描述：每名角色的回合限一次，每当你需要使用或打出一张基本牌时，你可以与一名手牌数少于你的角色交换手牌。若如此做，视为你使用或打出了此牌。
]]--
ZhenShan = sgs.CreateLuaSkill{
	name = "yj5ZhenShan",
	translation = "振赡",
	description = "每名角色的回合限一次，每当你需要使用或打出一张基本牌时，你可以与一名手牌数少于你的角色交换手牌。若如此做，视为你使用或打出了此牌。",
}
--武将信息：全琮
QuanCong = sgs.CreateLuaGeneral{
	name = "yj_v_quancong",
	real_name = "quancong",
	translation = "全琮",
	title = "慕势耀族",
	kingdom = "wu",
	maxhp = 4,
	order = 4,
	skills = ZhenShan,
	resource = "quancong",
}
--[[****************************************************************
	称号：弥殇的景君
	武将：孙休
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：宴诛（阶段技）
	描述：你可以令一名有牌的其他角色选择一项：令你获得其装备区里所有的牌，然后你失去技能“宴诛”，直到游戏结束；或弃置一张牌。
]]--
YanZhu = sgs.CreateLuaSkill{
	name = "yj5YanZhu",
	translation = "宴诛",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令一名有牌的其他角色选择一项：令你获得其装备区里所有的牌，然后你失去技能“宴诛”，直到游戏结束；或弃置一张牌。",
}
--[[
	技能：兴学
	描述：结束阶段开始时，你可以令至多X名角色依次摸一张牌并将一张牌置于牌堆顶（X为你的体力值）；若你已失去技能“宴诛”，则将X改为你的体力上限。
]]--
XingXue = sgs.CreateLuaSkill{
	name = "yj5XingXue",
	translation = "兴学",
	description = "结束阶段开始时，你可以令至多X名角色依次摸一张牌并将一张牌置于牌堆顶（X为你的体力值）；若你已失去技能“宴诛”，则将X改为你的体力上限。",
}
--[[
	技能：诏缚（主公技、锁定技）[空壳技能]
	描述：你距离为1的角色视为在其他吴势力角色的攻击范围内。
]]--
ZhaoFu = sgs.CreateLuaSkill{
	name = "yj5ZhaoFu",
	translation = "诏缚",
	description = "<font color=\"yellow\"><b>主公技</b></font>，<font color=\"blue\"><b>锁定技</b></font>，你距离为1的角色视为在其他吴势力角色的攻击范围内。",
}
--武将信息：孙休
SunXiu = sgs.CreateLuaGeneral{
	name = "yj_v_sunxiu",
	real_name = "sunxiu",
	translation = "孙休",
	title = "弥殇的景君",
	kingdom = "wu",
	maxhp = 3,
	order = 3,
	skills = {YanZhu, XingXue, ZhaoFu},
	resource = "sunxiu",
}
--[[****************************************************************
	称号：采缘撷睦
	武将：夏侯氏
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：樵拾
	描述：其他角色的结束阶段开始时，若你的手牌数与其相等，则你可以与其各摸一张牌。
]]--
QiaoShi = sgs.CreateLuaSkill{
	name = "yj5QiaoShi",
	translation = "樵拾",
	description = "其他角色的结束阶段开始时，若你的手牌数与其相等，则你可以与其各摸一张牌。",
}
--[[
	技能：燕语
	描述：出牌阶段，你可以重铸【杀】。出牌阶段结束时，若你于此阶段以此法重铸了两张或更多的【杀】，则你可以令一名男性角色摸两张牌。
]]--
YanYu = sgs.CreateLuaSkill{
	name = "yj5YanYu",
	translation = "燕语",
	description = "出牌阶段，你可以重铸【杀】。出牌阶段结束时，若你于此阶段以此法重铸了两张或更多的【杀】，则你可以令一名男性角色摸两张牌。",
}
--武将信息：夏侯氏
XiaHouJuan = sgs.CreateLuaGeneral{
	name = "yj_v_xiahoushi",
	real_name = "xiahoujuan",
	translation = "夏侯氏",
	title = "采缘撷睦",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 2,
	skills = {QiaoShi, YanYu},
	resource = "xiahoushi",
}
--[[****************************************************************
	称号：通壮逾古
	武将：张嶷
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：抚戎（阶段技）
	描述：你可以令一名其他角色与你同时展示一张手牌：若你展示的是【杀】且该角色展示的不是【闪】，则你弃置此【杀】并对其造成1点伤害；若你展示的不是【杀】且该角色展示的是【闪】，则你弃置你展示的牌并获得其一张牌。
]]--
FuRong = sgs.CreateLuaSkill{
	name = "yj5FuRong",
	translation = "抚戎",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令一名其他角色与你同时展示一张手牌：若你展示的是【杀】且该角色展示的不是【闪】，则你弃置此【杀】并对其造成1点伤害；若你展示的不是【杀】且该角色展示的是【闪】，则你弃置你展示的牌并获得其一张牌。",
}
--[[
	技能：矢志（锁定技）
	描述：当你体力为1时，你的【闪】均视为【杀】。
]]--
ShiZhi = sgs.CreateLuaSkill{
	name = "yj5ShiZhi",
	translation = "矢志",
	description = "<font color=\"blue\"><b>锁定技</b></font>，当你体力为1时，你的【闪】均视为【杀】。",
}
--武将信息：张嶷
ZhangYi = sgs.CreateLuaGeneral{
	name = "yj_v_zhangyi",
	real_name = "zhangyi",
	translation = "张嶷",
	title = "通壮愈古",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	skills = {FuRong, ShiZhi},
	resource = "zhangyi",
}
--[[****************************************************************
	称号：正楷萧曹
	武将：钟繇
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：活墨
	描述：每当你需要使用一张你于此回合内未使用过的基本牌时，你可以将一张黑色非基本牌置于牌堆顶，然后视为你使用了此基本牌。
]]--
HuoMo = sgs.CreateLuaSkill{
	name = "yj5HuoMo",
	translation = "活墨",
	description = "每当你需要使用一张你于此回合内未使用过的基本牌时，你可以将一张黑色非基本牌置于牌堆顶，然后视为你使用了此基本牌。",
}
--[[
	技能：佐定
	描述：一名其他角色于其出牌阶段内使用黑桃牌指定目标后，若此阶段没有角色受到过伤害，则你可以令其中一名目标角色摸一张牌。
]]--
ZuoDing = sgs.CreateLuaSkill{
	name = "yj5ZuoDing",
	translation = "佐定",
	description = "一名其他角色于其出牌阶段内使用黑桃牌指定目标后，若此阶段没有角色受到过伤害，则你可以令其中一名目标角色摸一张牌。",
}
--武将信息：钟繇
ZhongYao = sgs.CreateLuaGeneral{
	name = "yj_v_zhongyao",
	real_name = "zhongyao",
	translation = "钟繇",
	title = "正楷萧曹",
	kingdom = "wei",
	maxhp = 3,
	order = 6,
	skills = {HuoMo, ZuoDing},
	resource = "zhongyao",
}
--[[****************************************************************
	称号：王事靡盬
	武将：朱治
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：安国（阶段技）
	描述：你可以选择一名其他角色装备区里的一张牌，令其将此牌收回手牌。然后若该角色攻击范围内的角色数因此减少，你摸一张牌。
]]--
AnGuo = sgs.CreateLuaSkill{
	name = "yj5AnGuo",
	translation = "安国",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以选择一名其他角色装备区里的一张牌，令其将此牌收回手牌。然后若该角色攻击范围内的角色数因此减少，你摸一张牌。",
}
--武将信息：朱治
ZhuZhi = sgs.CreateLuaGeneral{
	name = "yj_v_zhuzhi",
	real_name = "zhuzhi",
	translation = "朱治",
	title = "王事靡盬",
	kingdom = "wu",
	maxhp = 4,
	order = 4,
	skills = AnGuo,
	resource = "zhuzhi",
}
--[[****************************************************************
	一将成名2015武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2015",
	translation = "五将成名",
	generals = {
		CaoRui, CaoXiu, GongSunYuan, GuoTuPangJi, LiuChen,
		QuanCong, SunXiu, XiaHouJuan, ZhangYi, ZhongYao, ZhuZhi,
	},
}