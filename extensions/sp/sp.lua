--[[
	太阳神三国杀武将单挑对战平台·SP武将包
	武将总数：39
	武将一览：
		1、杨修（啖酪、鸡肋）
		2、貂蝉（离间、闭月）
		3、公孙瓒（义从）
		4、袁术（庸肆、伪帝）
		5、孙尚香（结姻、枭姬）
		6、庞德（马术、猛进）
		7、关羽（武圣、单骑）+（马术）
		8、蔡文姬（悲歌、断肠）
		9、马超（马术、铁骑）
		10、贾诩（完杀、乱武、帷幕）
		11、曹洪（援护）
		12、关银屏（血祭、虎啸、武继）
		13、甄姬（倾国、洛神）
		14、刘协（天命、密诏）
		15、灵雎（竭缘、焚心）
		16、伏完（谋溃）
		17、夏侯霸（豹变）+（挑衅、咆哮、神速）
		18、陈琳（笔伐、颂词）
		19、大乔小乔（星舞、落雁）+（天香、流离）
		20、吕布（狂暴、无谋、无前、神愤）+（无双）
		21、夏侯氏（燕语、孝德）
		22、乐进（骁果）
		23、张宝（咒缚、影兵）
		24、曹昂（慷忾）
		25、诸葛瑾（弘援、缓释、明哲）
		26、星彩（甚贤、枪舞）
		27、潘凤（狂斧）
		28、祖茂（引兵、绝地）
		29、丁奉（短兵、奋迅）
		30、诸葛诞（功獒、举义）+（崩坏、威重）
		31、何太后（鸩毒、戚乱）
		32、孙鲁育（魅步、穆穆）
		33、马良（协穆、纳蛮）
		34、程昱（设伏、贲育）
		35、甘夫人（淑慎、神智）
		36、黄巾雷使（符箓、助祭）
		37、文聘（镇卫）
		38、司马朗（去疾、郡兵）
		39、孙皓（残蚀、仇海、归命）
]]--
--[[****************************************************************
	称号：恃才放旷
	武将：杨修
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：啖酪
	描述：每当至少两名角色成为锦囊牌的目标后，若你为目标角色，你可以摸一张牌，然后该锦囊牌对你无效。
]]--
DanLao = sgs.CreateLuaSkill{
	name = "spDanLao",
	translation = "啖酪",
	description = "每当至少两名角色成为锦囊牌的目标后，若你为目标角色，你可以摸一张牌，然后该锦囊牌对你无效。",
	audio = {},
}
--[[
	技能：鸡肋
	描述：每当你受到伤害后，你可以选择一种牌的类别，伤害来源不能使用、打出或弃置其该类别的手牌，直到回合结束。
]]--
JiLei = sgs.CreateLuaSkill{
	name = "spJiLei",
	translation = "鸡肋",
	description = "每当你受到伤害后，你可以选择一种牌的类别，伤害来源不能使用、打出或弃置其该类别的手牌，直到回合结束。",
	audio = {},
}
--武将信息：杨修
YangXiu = sgs.CreateLuaGeneral{
	name = "sp_yangxiu",
	real_name = "yangxiu",
	translation = "杨修",
	title = "恃才放旷",
	kingdom = "wei",
	maxhp = 3,
	order = 1,
	cv = "幻象迷宫",
	illustrator = "张可",
	skills = {DanLao, JiLei},
	last_word = "恃才傲物，方有此命……",
	resource = "yangxiu",
}
--[[****************************************************************
	称号：绝世的舞姬（隐藏武将）
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：离间（阶段技）[空壳技能]
	描述：你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】。
]]--
--[[
	技能：闭月
	描述：结束阶段开始时，你可以摸一张牌。
]]--
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "sp_diaochan",
	real_name = "diaochan",
	translation = "SP·貂蝉",
	show_name = "貂蝉",
	title = "绝世的舞姬",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	hidden = true,
	order = 7,
	illustrator = "",
	skills = {"LiJian", "BiYue"},
	last_word = "父亲大人……对不起……",
	resource = "diaochan",
}
--[[****************************************************************
	称号：白马将军
	武将：公孙瓒
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：义从（锁定技）
	描述：若你的体力值大于2，你与其他角色的距离-1；若你的体力值小于或等于2，其他角色与你的距离+1。
]]--
YiCong = sgs.CreateLuaSkill{
	name = "spYiCong",
	translation = "义从",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的体力值大于2，你与其他角色的距离-1；若你的体力值小于或等于2，其他角色与你的距离+1。",
	audio = {},
}
--武将信息：公孙瓒
GongSunZan = sgs.CreateLuaGeneral{
	name = "sp_gongsunzan",
	real_name = "gongsunzan",
	translation = "公孙瓒",
	title = "白马将军",
	kingdom = "qun",
	maxhp = 4,
	order = 2,
	illustrator = "Vincent",
	skills = YiCong,
	last_word = "我军将败，我已无颜苟活于世！……",
	resource = "gongsunzan",
}
--[[****************************************************************
	称号：仲家帝
	武将：袁术
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：庸肆（锁定技）
	描述：摸牌阶段，你额外摸X张牌。弃牌阶段开始时，你须弃置X张牌。（X为现存势力数）
]]--
YongSi = sgs.CreateLuaSkill{
	name = "spYongSi",
	translation = "庸肆",
	description = "<font color=\"blue\"><b>锁定技</b></font>，摸牌阶段，你额外摸X张牌。弃牌阶段开始时，你须弃置X张牌。（X为现存势力数）",
	audio = {},
}
--[[
	技能：伪帝（锁定技）[空壳技能]
	描述：你拥有且可以发动主公的主公技。
]]--
--武将信息：袁术
YuanShu = sgs.CreateLuaGeneral{
	name = "sp_yuanshu",
	real_name = "yuanshu",
	translation = "SP·袁术",
	show_name = "袁术",
	title = "仲家帝",
	kingdom = "qun",
	maxhp = 4,
	order = 9,
	illustrator = "吴昊",
	skills = {YongSi, "weidi"},
	last_word = "可恶！就差一步了……",
	resource = "yuanshu",
}
--[[****************************************************************
	称号：梦醉良缘
	武将：孙尚香
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：结姻（阶段技）
	描述：你可以弃置两张手牌并选择一名已受伤的男性角色：若如此做，你和该角色各回复1点体力。
]]--
--[[
	技能：枭姬
	描述：每当你失去一张装备区的装备牌后，你可以摸两张牌。
]]--
--武将信息：孙尚香
SunShangXiang = sgs.CreateLuaGeneral{
	name = "sp_sunshangxiang",
	real_name = "sunshangxiang",
	translation = "SP·孙尚香",
	show_name = "孙尚香",
	title = "梦醉良缘",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 4,
	cv = "喵小林，官方",
	illustrator = "",
	skills = {"JieYin", "XiaoJi"},
	resource = "sunshangxiang",
}
--[[****************************************************************
	称号：抬榇之悟
	武将：庞德
	势力：魏
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
--武将信息：庞德
PangDe = sgs.CreateLuaGeneral{
	name = "sp_pangde",
	real_name = "pangde",
	translation = "SP·庞德",
	show_name = "庞德",
	title = "抬榇之悟",
	kingdom = "wei",
	maxhp = 4,
	order = 5,
	illustrator = "",
	skills = {"mashu", "MengJin"},
	resource = "pangde",
}
--[[****************************************************************
	称号：汉寿亭侯
	武将：关羽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：单骑（觉醒技）[空壳技能]
	描述：准备阶段开始时，若你的手牌数大于体力值，且本局游戏主公为曹操，你失去1点体力上限，然后获得“马术”。
]]--
DanJi = sgs.CreateLuaSkill{
	name = "spDanJi",
	translation = "单骑",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的手牌数大于体力值，且本局游戏主公为曹操，你失去1点体力上限，然后获得“马术”。",
	audio = {},
}
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "sp_guanyu",
	real_name = "guanyu",
	translation = "SP·关羽",
	show_name = "关羽",
	title = "汉寿亭侯",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	illustrator = "LiuHeng",
	skills = {"WuSheng", DanJi},
	resource = "guanyu",
}
--[[****************************************************************
	称号：金碧之才
	武将：蔡文姬
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：悲歌
	描述：每当一名角色受到一次【杀】的伤害后，你可以弃置一张牌令该角色进行判定：若结果为红桃，该角色回复1点体力；方块，该角色摸两张牌；黑桃，伤害来源将其武将牌翻面；梅花，伤害来源弃置两张牌。
]]--
--[[
	技能：断肠（锁定技）
	描述：杀死你的角色失去所有武将技能。
]]--
--武将信息：蔡文姬
CaiYan = sgs.CreateLuaGeneral{
	name = "sp_caiwenji",
	real_name = "caiyan",
	translation = "SP·蔡文姬",
	show_name = "蔡文姬",
	title = "金碧之才",
	kingdom = "wei",
	maxhp = 3,
	female = true,
	order = 5,
	illustrator = "",
	skills = {"BeiGe", "DuanChang"},
	resource = "caiwenji",
}
--[[****************************************************************
	称号：西凉的猛狮
	武将：马超
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：铁骑
	描述：每当你指定【杀】的目标后，你可以进行判定：若结果为红色，该角色不能使用【闪】响应此【杀】。
]]--
--武将信息：马超
MaChao = sgs.CreateLuaGeneral{
	name = "sp_machao",
	real_name = "machao",
	translation = "SP·马超",
	show_name = "马超",
	title = "西凉的猛狮",
	kingdom = "qun",
	maxhp = 4,
	order = 7,
	illustrator = "",
	skills = {"mashu", "TieJi"},
	resource = "machao",
}
--[[****************************************************************
	称号：算无遗策
	武将：贾诩
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：完杀（锁定技）
	描述：你的回合内，除濒死角色外的其他角色不能使用【桃】。
]]--
--[[
	技能：乱武（限定技）
	描述：出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。
]]--
--[[
	技能：帷幕（锁定技）
	描述：你不能被选择为黑色锦囊牌的目标。
]]--
--武将信息：贾诩
JiaXu = sgs.CreateLuaGeneral{
	name = "sp_jiaxu",
	real_name = "jiaxu",
	translation = "SP·贾诩",
	show_name = "贾诩",
	title = "算无遗策",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	illustrator = "",
	skills = {"wansha", "LuanWu", "WeiMu"},
	resource = "jiaxu",
}
--[[****************************************************************
	称号：福将
	武将：曹洪
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：援护
	描述：结束阶段开始时，你可以将一张装备牌置于一名角色装备区内：若此牌为武器牌，你弃置该角色距离1的一名角色区域内的一张牌；若此牌为防具牌，该角色摸一张牌；若此牌为坐骑牌，该角色回复1点体力。
]]--
YuanHu = sgs.CreateLuaSkill{
	name = "spYuanHu",
	translation = "援护",
	description = "结束阶段开始时，你可以将一张装备牌置于一名角色装备区内：若此牌为武器牌，你弃置该角色距离1的一名角色区域内的一张牌；若此牌为防具牌，该角色摸一张牌；若此牌为坐骑牌，该角色回复1点体力。",
	audio = {},
}
--武将信息：曹洪
CaoHong = sgs.CreateLuaGeneral{
	name = "sp_caohong",
	real_name = "caohong",
	translation = "曹洪",
	title = "福将",
	kingdom = "wei",
	maxhp = 4,
	order = 1,
	cv = "喵小林",
	illustrator = "LiuHeng",
	skills = YuanHu,
	last_word = "主公已安，洪纵死……亦何惜……",
	resource = "caohong",
}
--[[****************************************************************
	称号：武姬
	武将：关银屏
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：血祭（阶段技）
	描述：你可以弃置一张红色牌并选择你攻击范围内的至多X名角色：若如此做，你对这些角色各造成1点伤害，然后这些角色各摸一张牌。（X为你已损失的体力值）
]]--
XueJi = sgs.CreateLuaSkill{
	name = "spXueJi",
	translation = "血祭",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置一张红色牌并选择你攻击范围内的至多X名角色：若如此做，你对这些角色各造成1点伤害，然后这些角色各摸一张牌。（X为你已损失的体力值）",
	audio = {},
}
--[[
	技能：虎啸（锁定技）
	描述：每当你于出牌阶段使用【杀】被【闪】抵消后，本阶段你可以额外使用一张【杀】。
]]--
HuXiao = sgs.CreateLuaSkill{
	name = "spHuXiao",
	translation = "虎啸",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你于出牌阶段使用【杀】被【闪】抵消后，本阶段你可以额外使用一张【杀】。",
	audio = {},
}
--[[
	技能：武继（觉醒技）
	描述：结束阶段开始时，若你于本回合造成了至少3点伤害，你增加1点体力上限，回复1点体力，然后失去“虎啸”。
]]--
WuJi = sgs.CreateLuaSkill{
	name = "spWuJi",
	translation = "武继",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，结束阶段开始时，若你于本回合造成了至少3点伤害，你增加1点体力上限，回复1点体力，然后失去“虎啸”。",
	audio = {},
}
--武将信息：关银屏
GuanYinPing = sgs.CreateLuaGeneral{
	name = "sp_guanyinping",
	real_name = "guanyinping",
	translation = "关银屏",
	title = "武姬",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 2,
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {XueJi, HuXiao, WuJi},
	last_word = "父亲……",
	resource = "guanyinping",
}
--[[****************************************************************
	称号：薄幸的美人（隐藏武将）
	武将：甄姬
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：倾国
	描述：你可以将一张黑色手牌当【闪】使用或打出。
]]--
--[[
	技能：洛神
	描述：准备阶段开始时，你可以进行判定：若结果为黑色，判定牌生效后你获得之，然后你可以再次发动“洛神”。
]]--
--武将信息：甄姬
ZhenJi = sgs.CreateLuaGeneral{
	name = "sp_zhenji",
	real_name = "zhenji",
	translation = "SP·甄姬",
	show_name = "甄姬",
	title = "薄幸的美人",
	kingdom = "wei",
	maxhp = 3,
	female = true,
	hidden = true,
	order = 8,
	illustrator = "",
	skills = {"qingguo", "luoshen"},
	last_word = "悼良会之永绝兮，哀一逝而异乡……",
	resource = "zhenji",
}
--[[****************************************************************
	称号：受困天子
	武将：刘协
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天命
	描述：每当你被指定为【杀】的目标时，你可以弃置两张牌，然后摸两张牌。若全场唯一的体力值最多的角色不是你，该角色也可以弃置两张牌，然后摸两张牌。
]]--
TianMing = sgs.CreateLuaSkill{
	name = "spTianMing",
	translation = "天命",
	description = "每当你被指定为【杀】的目标时，你可以弃置两张牌，然后摸两张牌。若全场唯一的体力值最多的角色不是你，该角色也可以弃置两张牌，然后摸两张牌。",
	audio = {},
}
--[[
	技能：密诏（阶段技）
	描述：你可以将所有手牌（至少一张）交给一名其他角色：若如此做，你令该角色与另一名由你指定的有手牌的角色拼点：若一名角色赢，视为该角色对没赢的角色使用一张【杀】。
]]--
MiZhao = sgs.CreateLuaSkill{
	name = "spMiZhao",
	translation = "密诏",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将所有手牌（至少一张）交给一名其他角色：若如此做，你令该角色与另一名由你指定的有手牌的角色拼点：若一名角色赢，视为该角色对没赢的角色使用一张【杀】。",
	audio = {},
}
--武将信息：刘协
LiuXie = sgs.CreateLuaGeneral{
	name = "sp_liuxie",
	real_name = "liuxie",
	translation = "刘协",
	title = "受困天子",
	kingdom = "qun",
	maxhp = 3,
	order = 3,
	illustrator = "",
	skills = {TianMing, MiZhao},
	resource = "liuxie",
}
--[[****************************************************************
	称号：情随梦逝
	武将：灵雎
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：竭缘
	描述：每当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可以弃置一张黑色手牌：若如此做，此伤害+1。每当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可以弃置一张红色手牌：若如此做，此伤害-1。
]]--
JieYuan = sgs.CreateLuaSkill{
	name = "spJieYuan",
	translation = "竭缘",
	description = "每当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可以弃置一张黑色手牌：若如此做，此伤害+1。每当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可以弃置一张红色手牌：若如此做，此伤害-1。",
	audio = {},
}
--[[
	技能：焚心（限定技）[空壳技能]
	描述：若你不是主公，你杀死一名非主公其他角色检验胜利条件之前，你可以与该角色交换身份牌。
]]--
FenXin = sgs.CreateLuaSkill{
	name = "spFenXin",
	translation = "焚心",
	description = "<font color=\"red\"><b>限定技</b></font>，若你不是主公，你杀死一名非主公其他角色检验胜利条件之前，你可以与该角色交换身份牌。",
	audio = {},
}
--武将信息：灵雎
LingJu = sgs.CreateLuaGeneral{
	name = "sp_lingju",
	real_name = "lingju",
	translation = "灵雎",
	title = "情随梦逝",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 3,
	illustrator = "",
	skills = {JieYuan, FenXin},
	resource = "lingju",
}
--[[****************************************************************
	称号：沉毅的国丈
	武将：伏完
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：谋溃
	描述：每当你指定【杀】的目标后，你可以选择一项：摸一张牌，或弃置目标角色一张牌：若如此做，此【杀】被目标角色的【闪】抵消后，该角色弃置你的一张牌。
]]--
MouKui = sgs.CreateLuaSkill{
	name = "spMouKui",
	translation = "谋溃",
	description = "每当你指定【杀】的目标后，你可以选择一项：摸一张牌，或弃置目标角色一张牌：若如此做，此【杀】被目标角色的【闪】抵消后，该角色弃置你的一张牌。",
	audio = {},
}
--武将信息：伏完
FuWan = sgs.CreateLuaGeneral{
	name = "sp_fuwan",
	real_name = "fuwan",
	translation = "伏完",
	title = "沉毅的国丈",
	kingdom = "qun",
	maxhp = 4,
	order = 4,
	illustrator = "",
	skills = MouKui,
	resource = "fuwan",
}
--[[****************************************************************
	称号：荆途壮志
	武将：夏侯霸
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：豹变（锁定技）
	描述：若你的体力值为：3或更低，你拥有“挑衅”；2或更低，你拥有“咆哮”；1或更低，你拥有“神速”。
]]--
BaoBian = sgs.CreateLuaSkill{
	name = "spBaoBian",
	translation = "豹变",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的体力值为：3或更低，你拥有“挑衅”；2或更低，你拥有“咆哮”；1或更低，你拥有“神速”。",
	audio = {},
}
--[[
	技能：挑衅（阶段技）
	描述：你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。
]]--
TiaoXin = sgs.CreateLuaSkill{
	name = "spTiaoXin",
	translation = "挑衅",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。",
	audio = {},
}
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
PaoXiao = sgs.CreateLuaSkill{
	name = "spPaoXiao",
	translation = "咆哮",
	description = "出牌阶段，你使用【杀】无次数限制。",
	audio = {},
}
--[[
	技能：神速
	描述：你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。
]]--
ShenSu = sgs.CreateLuaSkill{
	name = "spShenSu",
	translation = "神速",
	description = "你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。",
	audio = {},
}
--武将信息：夏侯霸
XiaHouBa = sgs.CreateLuaGeneral{
	name = "sp_xiahouba",
	real_name = "xiahouba",
	translation = "夏侯霸",
	title = "荆途壮志",
	kingdom = "shu",
	maxhp = 4,
	order = 4,
	illustrator = "熊猫探员",
	skills = BaoBian,
	related_skills = {TiaoXin, PaoXiao, ShenSu},
	last_word = "弃魏投蜀，死而无憾……",
	resource = "xiahouba",
}
--[[****************************************************************
	称号：破竹之咒
	武将：陈琳
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：笔伐
	描述：结束阶段开始时，你可以将一张手牌扣置于一名无“笔伐牌”的其他角色旁：若如此做，该角色的回合开始时，其观看此牌，然后选择一项：1.交给你一张与此牌类型相同的牌并获得此牌；2.将此牌置入弃牌堆，然后失去1点体力。
]]--
BiFa = sgs.CreateLuaSkill{
	name = "spBiFa",
	translation = "笔伐",
	description = "结束阶段开始时，你可以将一张手牌扣置于一名无“笔伐牌”的其他角色旁：若如此做，该角色的回合开始时，其观看此牌，然后选择一项：1.交给你一张与此牌类型相同的牌并获得此牌；2.将此牌置入弃牌堆，然后失去1点体力。",
	audio = {},
}
--[[
	技能：颂词
	描述：出牌阶段，你可以令一名手牌数大于体力值的角色弃置两张牌，或令一名手牌数小于体力值的角色摸两张牌。对每名角色限一次。
]]--
SongCi = sgs.CreateLuaSkill{
	name = "spSongCi",
	translation = "颂词",
	description = "出牌阶段，你可以令一名手牌数大于体力值的角色弃置两张牌，或令一名手牌数小于体力值的角色摸两张牌。对每名角色限一次。",
	audio = {},
}
--武将信息：陈琳
ChenLin = sgs.CreateLuaGeneral{
	name = "sp_chenlin",
	real_name = "chenlin",
	translation = "陈琳",
	title = "破竹之咒",
	kingdom = "wei",
	maxhp = 3,
	order = 6,
	illustrator = "木美人",
	skills = {BiFa, SongCi},
	last_word = "来人！我的笔呢？！",
	resource = "chenlin",
}
--[[****************************************************************
	称号：江东之花
	武将：大乔小乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：星舞
	描述：弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上：若你有至少三张“星舞牌”，你将之置入弃牌堆并选择一名男性角色，该角色受到2点伤害并弃置其装备区的所有牌。
]]--
XingWu = sgs.CreateLuaSkill{
	name = "spXingWu",
	translation = "星舞",
	description = "弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上：若你有至少三张“星舞牌”，你将之置入弃牌堆并选择一名男性角色，该角色受到2点伤害并弃置其装备区的所有牌。",
	audio = {},
}
--[[
	技能：落雁（锁定技）
	描述：若你的武将牌上有“星舞牌”，你拥有“天香”和“流离”。
]]--
LuoYan = sgs.CreateLuaSkill{
	name = "spLuoYan",
	translation = "落雁",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的武将牌上有“星舞牌”，你拥有“天香”和“流离”。",
	audio = {},
}
--[[
	技能：天香
	描述：每当你受到伤害时，你可以弃置一张红桃手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。
]]--
TianXiang = sgs.CreateLuaSkill{
	name = "spTianXiang",
	translation = "天香",
	description = "每当你受到伤害时，你可以弃置一张红桃手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。",
	audio = {},
}
--[[
	技能：流离[空壳技能]
	描述：每当你成为【杀】的目标时，你可以弃置一张牌并选择你攻击范围内为此【杀】合法目标（无距离限制）的一名角色：若如此做，该角色代替你成为此【杀】的目标。
]]--
--武将信息：大乔小乔
DaQiaoXiaoQiao = sgs.CreateLuaGeneral{
	name = "sp_daqiaoxiaoqiao",
	real_name = "daqiaoxiaoqiao",
	translation = "大乔小乔",
	title = "江东之花",
	kingdom = "wu",
	maxhp = 3,
	female = true,
	order = 5,
	crowded = true,
	illustrator = "木美人",
	skills = {XingWu, LuoYan},
	related_skills = {TianXiang, "LiuLi"},
	last_word = "伯符、公瑾，请一定守护住我们的江东哦……",
	resource = "daqiaoxiaoqiao",
}
--[[****************************************************************
	称号：修罗之道
	武将：吕布
	势力：神
	性别：男
	体力上限：5勾玉
]]--****************************************************************
--[[
	技能：狂暴（锁定技）
	描述：游戏开始时，你获得两枚“暴怒”标记。每当你造成或受到1点伤害后，你获得一枚“暴怒”标记。
]]--
--[[
	技能：无谋（锁定技）
	描述：每当你使用一张非延时锦囊牌时，你须选择一项：失去1点体力，或弃一枚“暴怒”标记。
]]--
--[[
	技能：无前
	描述：出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。
]]--
--[[
	技能：神愤（阶段技）
	描述：你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。
]]--
--[[
	技能：无双（锁定技）
	描述：每当你指定【杀】的目标后，目标角色须使用两张【闪】抵消此【杀】。你指定或成为【决斗】的目标后，与你【决斗】的角色每次须连续打出两张【杀】。
]]--
--武将信息：吕布
LvBu = sgs.CreateLuaGeneral{
	name = "sp_lvbu",
	real_name = "lvbu",
	translation = "SP·神吕布",
	show_name = "神吕布",
	title = "修罗之道",
	kingdom = "god",
	maxhp = 5,
	order = 6,
	illustrator = "",
	skills = {"KuangBao", "WuMou", "WuQian", "ShenFen"},
	related_skills = "WuShuang",
	resource = "lvbu",
}
--[[****************************************************************
	称号：疾冲之恋
	武将：夏侯氏
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：燕语
	描述：一名角色的出牌阶段开始时，你可以弃置一张牌：若如此做，本回合的出牌阶段内限三次，一张与此牌类型相同的牌置入弃牌堆时，你可以令一名角色获得之。
]]--
YanYu = sgs.CreateLuaSkill{
	name = "spYanYu",
	translation = "燕语",
	description = "一名角色的出牌阶段开始时，你可以弃置一张牌：若如此做，本回合的出牌阶段内限三次，一张与此牌类型相同的牌置入弃牌堆时，你可以令一名角色获得之。",
	audio = {},
}
--[[
	技能：孝德
	描述：每当一名其他角色死亡结算后，你可以拥有该角色武将牌上的一项技能（除主公技与觉醒技），且“孝德”无效，直到你的回合结束时。每当你失去“孝德”后，你失去以此法获得的技能。
]]--
XiaoDe = sgs.CreateLuaSkill{
	name = "spXiaoDe",
	translation = "孝德",
	description = "每当一名其他角色死亡结算后，你可以拥有该角色武将牌上的一项技能（除主公技与觉醒技），且“孝德”无效，直到你的回合结束时。每当你失去“孝德”后，你失去以此法获得的技能。",
	audio = {},
}
--武将信息：夏侯氏
XiaHouJuan = sgs.CreateLuaGeneral{
	name = "sp_xiahoushi",
	real_name = "xiahoujuan",
	translation = "SP·夏侯氏",
	show_name = "夏侯氏",
	title = "疾冲之恋",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 10,
	illustrator = "牧童的短笛",
	skills = {YanYu, XiaoDe},
	resource = "xiahoujuan",
}
--[[****************************************************************
	称号：奋强突固
	武将：乐进
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：骁果
	描述：其他角色的结束阶段开始时，你可以弃置一张基本牌：若如此做，该角色选择一项：1.弃置一张装备牌，然后令你摸一张牌；2.受到1点伤害。
]]--
XiaoGuo = sgs.CreateLuaSkill{
	name = "spXiaoGuo",
	translation = "骁果",
	description = "其他角色的结束阶段开始时，你可以弃置一张基本牌：若如此做，该角色选择一项：1.弃置一张装备牌，然后令你摸一张牌；2.受到1点伤害。",
	audio = {},
}
--武将信息：乐进
YueJin = sgs.CreateLuaGeneral{
	name = "sp_yuejin",
	real_name = "yuejin",
	translation = "乐进",
	title = "奋强突固",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	illustrator = "",
	skills = {XiaoGuo},
	resource = "yuejin",
}
--[[****************************************************************
	称号：地公将军
	武将：张宝
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：咒缚（阶段技）
	描述：你可以将一张手牌置于一名无“咒缚牌”的其他角色旁：若如此做，该角色进行判定时，以“咒缚牌”作为判定牌。一名角色的回合结束后，若该角色有“咒缚牌”，你获得此牌。
]]--
ZhouFu = sgs.CreateLuaSkill{
	name = "spZhouFu",
	translation = "咒缚",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张手牌置于一名无“咒缚牌”的其他角色旁：若如此做，该角色进行判定时，以“咒缚牌”作为判定牌。一名角色的回合结束后，若该角色有“咒缚牌”，你获得此牌。",
	audio = {},
}
--[[
	技能：影兵
	描述：每当一张“咒缚牌”成为判定牌后，你可以摸两张牌。
]]--
YingBing = sgs.CreateLuaSkill{
	name = "spYingBing",
	translation = "影兵",
	description = "每当一张“咒缚牌”成为判定牌后，你可以摸两张牌。",
	audio = {},
}
--武将信息：张宝
ZhangBao = sgs.CreateLuaGeneral{
	name = "sp_zhangbao",
	real_name = "zhangbao",
	translation = "张宝",
	title = "地公将军",
	kingdom = "qun",
	maxhp = 3,
	order = 1,
	illustrator = "大佬荣",
	skills = {ZhouFu, YingBing},
	last_word = "黄天！为何？……",
	resource = "zhangbao",
}
--[[****************************************************************
	称号：取义成仁
	武将：曹昂
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：慷忾
	描述：每当一名距离1以内的角色成为【杀】的目标后，你可以摸一张牌，然后正面朝上交给该角色一张牌：若此牌为装备牌，该角色可以使用之。
]]--
KangKai = sgs.CreateLuaSkill{
	name = "spKangKai",
	translation = "慷忾",
	description = "每当一名距离1以内的角色成为【杀】的目标后，你可以摸一张牌，然后正面朝上交给该角色一张牌：若此牌为装备牌，该角色可以使用之。",
	audio = {},
}
--武将信息：曹昂
CaoAng = sgs.CreateLuaGeneral{
	name = "sp_caoang",
	real_name = "caoang",
	translation = "曹昂",
	title = "取义成仁",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	illustrator = "MSNZero",
	skills = KangKai,
	last_word = "典将军，还是……你赢了，诶……",
	resource = "caoang",
}
--[[****************************************************************
	称号：联盟的维系者
	武将：诸葛瑾
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：弘援
	描述：摸牌阶段，你可以少摸一张牌：若如此做，令至多两名其他角色各摸一张牌。
]]--
HongYuan = sgs.CreateLuaSkill{
	name = "spHongYuan",
	translation = "弘援",
	description = "摸牌阶段，你可以少摸一张牌：若如此做，令至多两名其他角色各摸一张牌。",
	audio = {},
}
--[[
	技能：缓释
	描述：每当一名角色的判定牌生效前，你可以令该角色观看你的手牌，然后该角色选择你的一张牌，你打出此牌代替之。
]]--
HuanShi = sgs.CreateLuaSkill{
	name = "spHuanShi",
	translation = "缓释",
	description = "每当一名角色的判定牌生效前，你可以令该角色观看你的手牌，然后该角色选择你的一张牌，你打出此牌代替之。",
	audio = {},
}
--[[
	技能：明哲
	描述：你的回合外，每当你使用或打出一张红色牌时，或因弃置而失去一张红色牌后，你可以摸一张牌。
]]--
MingZhe = sgs.CreateLuaSkill{
	name = "spMingZhe",
	translation = "明哲",
	description = "你的回合外，每当你使用或打出一张红色牌时，或因弃置而失去一张红色牌后，你可以摸一张牌。",
	audio = {},
}
--武将信息：诸葛瑾
ZhuGeJin = sgs.CreateLuaGeneral{
	name = "sp_zhugejin",
	real_name = "zhugejin",
	translation = "诸葛瑾",
	title = "联盟的维系者",
	kingdom = "wu",
	maxhp = 3,
	order = 4,
	illustrator = "",
	skills = {HongYuan, HuanShi, MingZhe},
	resource = "zhugejin",
}
--[[****************************************************************
	称号：敬哀皇后
	武将：星彩
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：甚贤
	描述：你的回合外，每当一名其他角色因弃置而失去牌后，若其中有基本牌，你可以摸一张牌。
]]--
ShenXian = sgs.CreateLuaSkill{
	name = "spShenXian",
	translation = "甚贤",
	description = "你的回合外，每当一名其他角色因弃置而失去牌后，若其中有基本牌，你可以摸一张牌。",
	audio = {},
}
--[[
	技能：枪舞（阶段技）
	描述：你可以进行判定：若如此做，本回合，你使用点数小于判定牌点数的【杀】无距离限制，你使用点数大于判定牌点数的【杀】无次数限制且不计入次数限制。
]]--
QiangWu = sgs.CreateLuaSkill{
	name = "spQiangWu",
	translation = "枪舞",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以进行判定：若如此做，本回合，你使用点数小于判定牌点数的【杀】无距离限制，你使用点数大于判定牌点数的【杀】无次数限制且不计入次数限制。",
	audio = {},
}
--武将信息：星彩
XingCai = sgs.CreateLuaGeneral{
	name = "sp_xingcai",
	real_name = "zhangxingcai",
	translation = "星彩",
	title = "敬哀皇后",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 4,
	illustrator = "depp",
	skills = {ShenXian, QiangWu},
	last_word = "复兴汉室之路，臣妾再也不能陪伴左右……",
	resource = "xingcai",
}
--[[****************************************************************
	称号：联军上将
	武将：潘凤
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：狂斧
	描述：每当你使用的【杀】对目标角色造成伤害后，你可以将其装备区里的一张牌弃置或置入你的装备区。
]]--
KuangFu = sgs.CreateLuaSkill{
	name = "spKuangFu",
	translation = "狂斧",
	description = "每当你使用的【杀】对目标角色造成伤害后，你可以将其装备区里的一张牌弃置或置入你的装备区。",
	audio = {},
}
--武将信息：潘凤
PanFeng = sgs.CreateLuaGeneral{
	name = "sp_panfeng",
	real_name = "panfeng",
	translation = "潘凤",
	title = "联军上将",
	kingdom = "qun",
	maxhp = 4,
	order = 3,
	illustrator = "",
	skills = KuangFu,
	resource = "panfeng",
}
--[[****************************************************************
	称号：碧血染赤帻
	武将：祖茂
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：引兵
	描述：结束阶段开始时，你可以将至少一张非基本牌置于武将牌上。每当你受到【杀】或【决斗】的伤害后，你将一张“引兵牌”置入弃牌堆。
]]--
YinBing = sgs.CreateLuaSkill{
	name = "spYinBing",
	translation = "引兵",
	description = "结束阶段开始时，你可以将至少一张非基本牌置于武将牌上。每当你受到【杀】或【决斗】的伤害后，你将一张“引兵牌”置入弃牌堆。",
	audio = {},
}
--[[
	技能：绝地
	描述：准备阶段开始时，若你有“引兵牌”，你可以选择一项：1.将这些牌置入弃牌堆并摸等量的牌；2.令一名体力值不大于你的其他角色回复1点体力并获得这些牌。
]]--
JueDi = sgs.CreateLuaSkill{
	name = "spJueDi",
	translation = "绝地",
	description = "准备阶段开始时，若你有“引兵牌”，你可以选择一项：1.将这些牌置入弃牌堆并摸等量的牌；2.令一名体力值不大于你的其他角色回复1点体力并获得这些牌。",
	audio = {},
}
--武将信息：祖茂
ZuMao = sgs.CreateLuaGeneral{
	name = "sp_zumao",
	real_name = "zumao",
	translation = "祖茂",
	title = "碧血染赤帻",
	kingdom = "wu",
	maxhp = 4,
	order = 2,
	illustrator = "DH",
	skills = {YinBing, JueDi},
	last_word = "孙将军，已经安全了吧……",
	resource = "zumao",
}
--[[****************************************************************
	称号：清侧重臣
	武将：丁奉
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：短兵
	描述：你使用【杀】可以额外选择一名距离1的目标。
]]--
DuanBing = sgs.CreateLuaSkill{
	name = "spDuanBing",
	translation = "短兵",
	description = "你使用【杀】可以额外选择一名距离1的目标。",
	audio = {},
}
--[[
	技能：奋迅（阶段技）
	描述：你可以弃置一张牌并选择一名其他角色：若如此做，本回合你无视与该角色的距离。
]]--
FenXun = sgs.CreateLuaSkill{
	name = "spFenXun",
	translation = "奋迅",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置一张牌并选择一名其他角色：若如此做，本回合你无视与该角色的距离。",
	audio = {},
}
--武将信息：丁奉
DingFeng = sgs.CreateLuaGeneral{
	name = "sp_dingfeng",
	real_name = "dingfeng",
	translation = "丁奉",
	title = "清侧重臣",
	kingdom = "wu",
	maxhp = 4,
	order = 1,
	illustrator = "",
	skills = {DuanBing, FenXun},
	resource = "dingfeng",
}
--[[****************************************************************
	称号：薤露蒿里
	武将：诸葛诞
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：功獒
	描述：每当一名其他角色死亡时，你增加1点体力上限，回复1点体力。
]]--
GongAo = sgs.CreateLuaSkill{
	name = "spGongAo",
	translation = "功獒",
	description = "每当一名其他角色死亡时，你增加1点体力上限，回复1点体力。",
	audio = {},
}
--[[
	技能：举义（觉醒技）
	描述：准备阶段开始时，若你已受伤且体力上限大于角色数，你将手牌补至体力上限，然后获得“崩坏”和“威重”（锁定技。每当你的体力上限改变后，你摸一张牌）。
]]--
JuYi = sgs.CreateLuaSkill{
	name = "spJuYi",
	translation = "举义",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你已受伤且体力上限大于角色数，你将手牌补至体力上限，然后获得“崩坏”和“威重”（锁定技。每当你的体力上限改变后，你摸一张牌）。",
	audio = {},
}
--[[
	技能：崩坏（锁定技）
	描述：结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。
]]--
BengHuai = sgs.CreateLuaSkill{
	name = "spBengHuai",
	translation = "崩坏",
	description = "<font color=\"blue\"><b>锁定技</b></font>，结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。",
	audio = {},
}
--[[
	技能：威重（锁定技）
	描述：每当你的体力上限改变后，你摸一张牌。
]]--
WeiZhong = sgs.CreateLuaSkill{
	name = "spWeiZhong",
	translation = "威重",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你的体力上限改变后，你摸一张牌。",
	audio = {},
}
--武将信息：诸葛诞
ZhuGeDan = sgs.CreateLuaGeneral{
	name = "sp_zhugedan",
	real_name = "zhugedan",
	translation = "诸葛诞",
	title = "薤露蒿里",
	kingdom = "wei",
	maxhp = 4,
	order = 1,
	illustrator = "雪君S",
	skills = {GongAo, JuYi},
	related_skills = {BengHuai, WeiZhong},
	last_word = "诸葛一氏定会为我复仇！",
	resource = "zhugedan",
}
--[[****************************************************************
	称号：弄权之蛇蝎
	武将：何太后
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：鸩毒
	描述：每当一名其他角色的出牌阶段开始时，你可以弃置一张手牌：若如此做，视为该角色使用一张【酒】（计入次数限制），然后你对该角色造成1点伤害。
]]--
ZhenDu = sgs.CreateLuaSkill{
	name = "spZhenDu",
	translation = "鸩毒",
	description = "每当一名其他角色的出牌阶段开始时，你可以弃置一张手牌：若如此做，视为该角色使用一张【酒】（计入次数限制），然后你对该角色造成1点伤害。",
	audio = {},
}
--[[
	技能：戚乱
	描述：每当一名角色的回合结束时，你每于本回合杀死一名角色，你可以摸三张牌。
]]--
QiLuan = sgs.CreateLuaSkill{
	name = "spQiLuan",
	translation = "戚乱",
	description = "每当一名角色的回合结束时，你每于本回合杀死一名角色，你可以摸三张牌。",
	audio = {},
}
--武将信息：何太后
HeTaiHou = sgs.CreateLuaGeneral{
	name = "sp_hetaihou",
	real_name = "hetaihou",
	translation = "何太后",
	title = "弄权之蛇蝎",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 4,
	cv = "郁望梦始",
	illustrator = "",
	skills = {ZhenDu, QiLuan},
	last_word = "昨昔后兄诛董后，今朝董贼戮何家……",
	resource = "hetaihou",
}
--[[****************************************************************
	称号：舍身饲虎
	武将：孙鲁育
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：魅步
	描述：一名其他角色的出牌阶段开始时，若你不在其攻击范围内，你可以令该角色的锦囊牌均视为【杀】,直到回合结束：若如此做，本回合你在其攻击范围内。
]]--
MeiBu = sgs.CreateLuaSkill{
	name = "spMeiBu",
	translation = "魅步",
	description = "一名其他角色的出牌阶段开始时，若你不在其攻击范围内，你可以令该角色的锦囊牌均视为【杀】,直到回合结束：若如此做，本回合你在其攻击范围内。",
	audio = {},
}
--[[
	技能：穆穆
	描述：结束阶段开始时，若你未于本回合出牌阶段内造成伤害，你可以选择一项：弃置一名角色装备区的武器牌，然后摸一张牌；或将一名其他角色装备区的防具牌移动至你的装备区（替换原装备）。
]]--
MuMu = sgs.CreateLuaSkill{
	name = "spMuMu",
	translation = "穆穆",
	description = "结束阶段开始时，若你未于本回合出牌阶段内造成伤害，你可以选择一项：弃置一名角色装备区的武器牌，然后摸一张牌；或将一名其他角色装备区的防具牌移动至你的装备区（替换原装备）。",
	audio = {},
}
--武将信息：孙鲁育
SunLuYu = sgs.CreateLuaGeneral{
	name = "sp_sunluyu",
	real_name = "sunluyu",
	translation = "孙鲁育",
	title = "舍身饲虎",
	kingdom = "wu",
	maxhp = 3,
	female = true,
	order = 3,
	illustrator = "depp",
	skills = {MeiBu, MuMu},
	last_word = "姐姐……你且好自为之……",
	resource = "sunluyu",
}
--[[****************************************************************
	称号：白眉智士
	武将：马良
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：协穆
	描述：你可以弃置一张【杀】并选择一个势力：若如此做，直到你的回合开始时，每当你成为该势力的角色的黑色牌的目标后，你摸两张牌。
]]--
XieMu = sgs.CreateLuaSkill{
	name = "spXieMu",
	translation = "协穆",
	description = "你可以弃置一张【杀】并选择一个势力：若如此做，直到你的回合开始时，每当你成为该势力的角色的黑色牌的目标后，你摸两张牌。",
	audio = {},
}
--[[
	技能：纳蛮
	描述：每当其他角色打出的【杀】因打出而置入弃牌堆时，你可以获得之。
]]--
NaMan = sgs.CreateLuaSkill{
	name = "spNaMan",
	translation = "纳蛮",
	description = "每当其他角色打出的【杀】因打出而置入弃牌堆时，你可以获得之。",
	audio = {},
}
--武将信息：马良
MaLiang = sgs.CreateLuaGeneral{
	name = "sp_maliang",
	real_name = "maliang",
	translation = "马良",
	title = "白眉智士",
	kingdom = "shu",
	maxhp = 3,
	order = 3,
	illustrator = "LiuHeng",
	skills = {XieMu, NaMan},
	last_word = "皇叔为何不听我之言！……",
	resource = "maliang",
}
--[[****************************************************************
	称号：泰山捧日
	武将：程昱
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：设伏
	描述：结束阶段开始时，你可以将一张手牌扣置于武将牌旁，称为“伏兵”，并为该牌记录一种基本牌或锦囊牌的牌名（与其他“伏兵”均不相同）。你的回合外，每当一名角色使用基本牌或锦囊牌时，若此牌的牌名与一张“伏兵”的记录相同，你可以将此“伏兵”置入弃牌堆：若如此做，此牌无效。
]]--
SheFu = sgs.CreateLuaSkill{
	name = "spSheFu",
	translation = "设伏",
	description = "结束阶段开始时，你可以将一张手牌扣置于武将牌旁，称为“伏兵”，并为该牌记录一种基本牌或锦囊牌的牌名（与其他“伏兵”均不相同）。你的回合外，每当一名角色使用基本牌或锦囊牌时，若此牌的牌名与一张“伏兵”的记录相同，你可以将此“伏兵”置入弃牌堆：若如此做，此牌无效。",
	audio = {},
}
--[[
	技能：贲育
	描述：每当你受到有来源的伤害后，若伤害来源存活，若你的手牌数：小于X，你可以将手牌补至X（至多为5）张；大于X，你可以弃置至少X+1张手牌，然后对伤害来源造成1点伤害。（X为伤害来源的手牌数）
]]--
BenYu = sgs.CreateLuaSkill{
	name = "spBenYu",
	translation = "贲育",
	description = "每当你受到有来源的伤害后，若伤害来源存活，若你的手牌数：小于X，你可以将手牌补至X（至多为5）张；大于X，你可以弃置至少X+1张手牌，然后对伤害来源造成1点伤害。（X为伤害来源的手牌数）",
	audio = {},
}
--武将信息：程昱
ChengYu = sgs.CreateLuaGeneral{
	name = "sp_chengyu",
	real_name = "chengyu",
	translation = "程昱",
	title = "泰山捧日",
	kingdom = "wei",
	maxhp = 3,
	order = 8,
	illustrator = "GH",
	skills = {SheFu, BenYu},
	last_word = "此诚报效国家之时，吾却休矣！……",
	resource = "chengyu",
}
--[[****************************************************************
	称号：昭烈皇后
	武将：甘夫人
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：淑慎
	描述：每当你回复1点体力后，你可以令一名其他角色回复1点体力或摸两张牌。
]]--
ShuShen = sgs.CreateLuaSkill{
	name = "spShuShen",
	translation = "淑慎",
	description = "每当你回复1点体力后，你可以令一名其他角色回复1点体力或摸两张牌。",
	audio = {},
}
--[[
	技能：神智
	描述：准备阶段开始时，你可以弃置所有手牌：若你以此法弃置的牌不少于X张，你回复1点体力。（X为你的体力值）
]]--
ShenZhi = sgs.CreateLuaSkill{
	name = "spShenZhi",
	translation = "神智",
	description = "准备阶段开始时，你可以弃置所有手牌：若你以此法弃置的牌不少于X张，你回复1点体力。（X为你的体力值）",
	audio = {},
}
--武将信息：甘夫人
GanFuRen = sgs.CreateLuaGeneral{
	name = "sp_ganfuren",
	real_name = "ganfuren",
	translation = "甘夫人",
	title = "昭烈皇后",
	kingdom = "shu",
	maxhp = 3,
	female = true,
	order = 2,
	illustrator = "ShuShen, ShenZhi",
	skills = {ShuShen, ShenZhi},
	resource = "ganfuren",
}
--[[****************************************************************
	称号：雷祭之姝
	武将：黄巾雷使
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：符箓
	描述：你可以将一张普通【杀】当雷【杀】使用。
]]--
FuLu = sgs.CreateLuaSkill{
	name = "spFuLu",
	translation = "符箓",
	description = "你可以将一张普通【杀】当雷【杀】使用。",
	audio = {},
}
--[[
	技能：助祭
	描述：每当一名角色造成雷电伤害时，你可以令其进行判定：若结果为黑色，此伤害+1；红色，其获得判定牌。
]]--
ZhuJi = sgs.CreateLuaSkill{
	name = "spZhuJi",
	translation = "助祭",
	description = "每当一名角色造成雷电伤害时，你可以令其进行判定：若结果为黑色，此伤害+1；红色，其获得判定牌。",
	audio = {},
}
--武将信息：黄巾雷使
HuangJinLeiShi = sgs.CreateLuaGeneral{
	name = "sp_huangjinleishi",
	real_name = "huangjinleishi",
	translation = "黄巾雷使",
	title = "雷祭之姝",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 2,
	crowded = true,
	illustrator = "depp",
	skills = {FuLu, ZhuJi},
	resource = "huangjinleishi",
}
--[[****************************************************************
	称号：坚城宿将
	武将：文聘
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：镇卫
	描述：每当一名体力值小于你的角色成为【杀】或黑色锦囊牌的目标时，若目标数为1，你可以弃置一张牌，选择一项：1.你摸一张牌，若如此做，将此牌转移给你；2.此牌无效，然后将此牌置于使用者的武将牌旁，称为“兵”，一名角色的回合结束时，一名角色获得其所有的“兵”。
]]--
ZhenWei = sgs.CreateLuaSkill{
	name = "spZhenWei",
	translation = "镇卫",
	description = "每当一名体力值小于你的角色成为【杀】或黑色锦囊牌的目标时，若目标数为1，你可以弃置一张牌，选择一项：1.你摸一张牌，若如此做，将此牌转移给你；2.此牌无效，然后将此牌置于使用者的武将牌旁，称为“兵”，一名角色的回合结束时，一名角色获得其所有的“兵”。",
	audio = {},
}
--武将信息：文聘
WenPin = sgs.CreateLuaGeneral{
	name = "sp_wenpin",
	real_name = "wenpin",
	translation = "文聘",
	title = "坚城宿将",
	kingdom = "wei",
	maxhp = 4,
	order = 1,
	illustrator = "G.G.G.",
	skills = ZhenWei,
	last_word = "终于……也守不住了……",
	resource = "wenpin",
}
--[[****************************************************************
	称号：再世神农
	武将：司马朗
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：去疾（阶段技）
	描述：你可以弃置X张牌（X为你已损失的体力值）。然后令至多X名已受伤的角色各回复1点体力。若你以此法弃置的牌中有黑色牌，你失去1点体力。
]]--
QuJi = sgs.CreateLuaSkill{
	name = "spQuJi",
	translation = "去疾",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置X张牌（X为你已损失的体力值）。然后令至多X名已受伤的角色各回复1点体力。若你以此法弃置的牌中有黑色牌，你失去1点体力。",
	audio = {},
}
--[[
	技能：郡兵
	描述：一名角色的结束阶段开始时，若其手牌数小于等于1，其可以摸一张牌。若如此做，该角色须将所有手牌交给你，然后你交给其等量的牌。
]]--
JunBing = sgs.CreateLuaSkill{
	name = "spJunBing",
	translation = "郡兵",
	description = "一名角色的结束阶段开始时，若其手牌数小于等于1，其可以摸一张牌。若如此做，该角色须将所有手牌交给你，然后你交给其等量的牌。",
	audio = {},
}
--武将信息：司马朗
SiMaLang = sgs.CreateLuaGeneral{
	name = "sp_simalang",
	real_name = "simalang",
	translation = "司马朗",
	title = "再世神农",
	kingdom = "wei",
	maxhp = 3,
	order = 6,
	illustrator = "Sky",
	skills = {QuJi, JunBing},
	resource = "simalang",
}
--[[****************************************************************
	称号：时日曷丧
	武将：孙皓
	势力：吴
	性别：男
	体力上限：5勾玉
]]--****************************************************************
--[[
	技能：残蚀
	描述：摸牌阶段开始时，你可以放弃摸牌，摸X张牌（X为已受伤的角色数），若如此做，当你于此回合内使用基本牌或锦囊牌时，你弃置一张牌。
]]--
CanShi = sgs.CreateLuaSkill{
	name = "spCanShi",
	translation = "残蚀",
	description = "摸牌阶段开始时，你可以放弃摸牌，摸X张牌（X为已受伤的角色数），若如此做，当你于此回合内使用基本牌或锦囊牌时，你弃置一张牌。",
	audio = {},
}
--[[
	技能：仇海（锁定技）
	描述：当你受到伤害时，若你没有手牌，你令此伤害+1。
]]--
ChouHai = sgs.CreateLuaSkill{
	name = "spChouHai",
	translation = "仇海",
	description = "<font color=\"blue\"><b>锁定技</b></font>，当你受到伤害时，若你没有手牌，你令此伤害+1。",
	audio = {},
}
--[[
	技能：归命（主公技、锁定技）[空壳技能]
	描述：其他吴势力角色于你的回合内视为已受伤的角色。
]]--
GuiMing = sgs.CreateLuaSkill{
	name = "spGuiMing",
	translation = "归命",
	description = "<font color=\"yellow\"><b>主公技</b></font>，<font color=\"blue\"><b>锁定技</b></font>，其他吴势力角色于你的回合内视为已受伤的角色。",
	audio = {},
}
--武将信息：孙皓
SunHao = sgs.CreateLuaGeneral{
	name = "sp_sunhao",
	real_name = "sunhao",
	translation = "孙皓",
	title = "时日曷丧",
	kingdom = "shu",
	maxhp = 5,
	order = 2,
	illustrator = "Liuheng",
	skills = {CanShi, ChouHai, GuiMing},
	last_word = "命啊……命！",
	resource = "sunhao",
}
--[[****************************************************************
	SP武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "sp",
	translation = "SP包",
	generals = {
		YangXiu, DiaoChan, GongSunZan, YuanShu, SunShangXiang,
		PangDe, GuanYu, CaiYan, MaChao, JiaXu,
		CaoHong, GuanYinPing, ZhenJi, LiuXie, LingJu,
		FuWan, XiaHouBa, ChenLin, DaQiaoXiaoQiao, LvBu,
		XiaHouJuan, YueJin, ZhangBao, CaoAng, ZhuGeJin,
		XingCai, PanFeng, ZuMao, DingFeng, ZhuGeDan,
		HeTaiHou, SunLuYu, MaLiang, ChengYu, GanFuRen,
		HuangJinLeiShi, WenPin, SiMaLang, SunHao,
	},
}