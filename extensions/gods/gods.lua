--[[
	太阳神三国杀武将单挑对战平台·神武将包
	武将总数：8
	武将一览：
		1、关羽（武神、武魂）
		2、吕蒙（涉猎、攻心）
		3、周瑜（琴音、业炎）
		4、诸葛亮（七星、狂风、大雾）
		5、曹操（归心、飞影）
		6、吕布（狂暴、无谋、无前、无谋）+（无双）
		7、司马懿（忍戒、拜印、连破）+（极略）
		8、赵云（绝境、龙魂）
]]--
--[[****************************************************************
	称号：鬼神再临
	武将：关羽
	势力：神
	性别：男
	体力上限：勾玉
]]--****************************************************************
--[[
	技能：武神（锁定技）
	描述：你的♥手牌视为普通【杀】。你使用♥【杀】无距离限制。
]]--
WuShen = sgs.CreateLuaSkill{
	name = "WuShen",
	translation = "武神",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的红心手牌视为普通【杀】。你使用红心【杀】无距离限制。",
	audio = {
		"武神现世，天下莫敌！",
		"战意，化为青龙翱翔吧！",
	},
}
--[[
	技能：武魂（锁定技）
	描述：每当你受到伤害扣减体力前，伤害来源获得等于伤害点数的“梦魇”标记。你死亡时，你选择一名存活的“梦魇”标记数最多（不为0）的角色，该角色进行判定：若结果不为【桃】或【桃园结义】，该角色死亡。
]]--
WuHun = sgs.CreateLuaSkill{
	name = "WuHun",
	translation = "武魂",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到伤害扣减体力前，伤害来源获得等于伤害点数的“梦魇”标记。你死亡时，你选择一名存活的“梦魇”标记数最多（不为0）的角色，该角色进行判定：若结果不为【桃】或【桃园结义】，该角色死亡。",
	audio = {
		"关某记下了。",
		"我生不能啖汝之肉，死当追汝之魂！",
		"桃园之梦，再也不会回来了……",
	},
}
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "shenguanyu",
	real_name = "guanyu",
	translation = "神关羽",
	show_name = "关羽",
	title = "鬼神再临",
	kingdom = "god",
	maxhp = 5,
	order = 2,
	cv = "奈何",
	skills = {WuShen, WuHun},
	last_word = "吾一世英明，竟葬于小人之手！",
	resource = "guanyu",
	marks = {"@nightmare"},
}
--[[****************************************************************
	称号：圣光之国士
	武将：吕蒙
	势力：神
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：涉猎
	描述：摸牌阶段开始时，你可以放弃摸牌并亮出牌堆顶的五张牌：若如此做，你获得其中每种花色的牌各一张，然后将其余的牌置入弃牌堆。
]]--
SheLie = sgs.CreateLuaSkill{
	name = "SheLie",
	translation = "涉猎",
	description = "摸牌阶段开始时，你可以放弃摸牌并亮出牌堆顶的五张牌：若如此做，你获得其中每种花色的牌各一张，然后将其余的牌置入弃牌堆。",
	audio = {
		"但当涉猎，见往事耳。",
		"涉猎阅旧闻，暂使心魂澄。",
	},
}
--[[
	技能：攻心（阶段技）
	描述：你可以观看一名其他角色的手牌，然后选择其中一张♥牌并选择一项：弃置之，或将之置于牌堆顶。
]]--
GongXin = sgs.CreateLuaSkill{
	name = "GongXin",
	translation = "攻心",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以观看一名其他角色的手牌，然后选择其中一张红心牌并选择一项：弃置之，或将之置于牌堆顶。",
	audio = {
		"用兵之道，攻心为上，攻城为下",
		"心战为上，兵战为下。",
	},
}
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "shenlvmeng",
	real_name = "lvmeng",
	translation = "神吕蒙",
	show_name = "吕蒙",
	title = "圣光之国士",
	kingdom = "god",
	maxhp = 3,
	order = 10,
	cv = "宇文天启",
	skills = {SheLie, GongXin},
	last_word = "死去方知万事空……",
	resource = "lvmeng",
}
--[[****************************************************************
	称号：赤壁的火神
	武将：周瑜
	势力：神
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：琴音
	描述：弃牌阶段结束时，若你于本阶段内弃置了至少两张你的牌，你可以选择一项：令所有角色各回复1点体力，或令所有角色各失去1点体力。
]]--
QinYin = sgs.CreateLuaSkill{
	name = "QinYin",
	translation = "琴音",
	description = "弃牌阶段结束时，若你于本阶段内弃置了至少两张你的牌，你可以选择一项：令所有角色各回复1点体力，或令所有角色各失去1点体力。",
	audio = {
		"捻指勾弦，气破万军！",
		"如梦似幻，拨弄乾坤！",
		"聆听吧，孟德：这首献给你的镇魂曲！",
	},
}
--[[
	技能：业炎（限定技）
	描述：出牌阶段，你可以对一至三名角色各造成1点火焰伤害；或你可以弃置四种花色的手牌各一张，失去3点体力并选择一至两名角色：若如此做，你对这些角色造成共计至多3点火焰伤害且对其中一名角色造成至少2点火焰伤害。
]]--
YeYan = sgs.CreateLuaSkill{
	name = "YeYan",
	translation = "业炎",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以对一至三名角色各造成1点火焰伤害；或你可以弃置四种花色的手牌各一张，失去3点体力并选择一至两名角色：若如此做，你对这些角色造成共计至多3点火焰伤害且对其中一名角色造成至少2点火焰伤害。",
	audio = {
		"血色火海，葬敌万千！",
		"浮生罪孽，皆归灰烬！",
		"红莲业火，焚尽世间万物！",
	},
}
--武将信息：周瑜
ZhouYu = sgs.CreateLuaGeneral{
	name = "shenzhouyu",
	real_name = "zhouyu",
	translation = "神周瑜",
	show_name = "周瑜",
	title = "赤壁的火神",
	kingdom = "god",
	order = 6,
	cv = "血桜の涙",
	skills = {QinYin, YeYan},
	last_word = "残炎黯然，弦歌不复……",
	resource = "zhouyu",
	marks = {"@flame"},
}
--[[****************************************************************
	称号：赤壁的妖术师
	武将：诸葛亮
	势力：神
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：七星
	描述：你的起始手牌数+7。分发起始手牌后，你将其中七张扣置于武将牌旁，称为“星”。摸牌阶段结束时，你可以将至少一张手牌与等量的“星”交换。
]]--
QiXing = sgs.CreateLuaSkill{
	name = "QiXing",
	translation = "七星",
	description = "你的起始手牌数+7。分发起始手牌后，你将其中七张扣置于武将牌旁，称为“星”。摸牌阶段结束时，你可以将至少一张手牌与等量的“星”交换。",
	audio = "伏望天慈，延我之寿。",
}
--[[
	技能：狂风
	描述：结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色：若如此做，直到你的回合开始时，火焰伤害结算开始时，此伤害+1。
]]--
KuangFeng = sgs.CreateLuaSkill{
	name = "KuangFeng",
	translation = "狂风",
	description = "结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色：若如此做，直到你的回合开始时，火焰伤害结算开始时，此伤害+1。",
	audio = "万事俱备，只欠东风。",
}
--[[
	技能：大雾
	描述：结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色：若如此做，直到你的回合开始时，伤害结算开始时，防止这些角色受到的非雷电属性的伤害。
]]--
DaWu = sgs.CreateLuaSkill{
	name = "DaWu",
	translation = "大雾",
	description = "结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色：若如此做，直到你的回合开始时，伤害结算开始时，防止这些角色受到的非雷电属性的伤害。",
	audio = {
		"一天浓雾满长江，远近难分水渺茫。",
		"返元气于洪荒，混天地为大块。",
	},
}
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "shenzhugeliang",
	real_name = "zhugeliang",
	translation = "神诸葛亮",
	show_name = "诸葛亮",
	title = "赤壁的妖术师",
	kingdom = "god",
	maxhp = 3,
	order = 9,
	cv = "背后灵",
	skills = {QiXing, KuangFeng, DaWu},
	last_word = "吾命将至，再不能临阵讨贼矣……",
	resource = "zhugeliang",
	marks = {"@gale", "@fog"},
}
--[[****************************************************************
	称号：超世之英杰
	武将：曹操
	势力：神
	性别：男
	体力上限：勾玉
]]--****************************************************************
--[[
	技能：归心
	描述：每当你受到1点伤害后，你可以依次获得所有其他角色区域内的一张牌，然后将武将牌翻面。
]]--
GuiXin = sgs.CreateLuaSkill{
	name = "GuiXin",
	translation = "归心",
	description = "每当你受到1点伤害后，你可以依次获得所有其他角色区域内的一张牌，然后将武将牌翻面。",
	audio = "山不厌高，海不厌深。周公吐哺，天下归心！",
}
--[[
	技能：飞影（锁定技）
	描述：其他角色与你的距离+1。
]]--
FeiYing = sgs.CreateLuaSkill{
	name = "FeiYing",
	translation = "飞影",
	description = "<font color=\"blue\"><b>锁定技</b></font>，其他角色与你的距离+1。",
}
--武将信息：曹操
CaoCao = sgs.CreateLuaGeneral{
	name = "shencaocao",
	real_name = "caocao",
	translation = "神曹操",
	show_name = "曹操",
	title = "超世之英杰",
	kingdom = "god",
	maxhp = 3,
	order = 2,
	cv = "倚天の剑",
	skills = {GuiXin, FeiYing},
	last_word = "神龟虽寿，犹有竟时；腾蛇乘雾，终为土灰……",
	resource = "caocao",
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
KuangBao = sgs.CreateLuaSkill{
	name = "KuangBao",
	translation = "狂暴",
	description = "<font color=\"blue\"><b>锁定技</b></font>，游戏开始时，你获得两枚“暴怒”标记。每当你造成或受到1点伤害后，你获得一枚“暴怒”标记。",
	audio = "（嚎叫声）",
}
--[[
	技能：无谋（锁定技）
	描述：每当你使用一张非延时锦囊牌时，你须选择一项：失去1点体力，或弃一枚“暴怒”标记。
]]--
WuMou = sgs.CreateLuaSkill{
	name = "WuMou",
	translation = "无谋",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你使用一张非延时锦囊牌时，你须选择一项：失去1点体力，或弃一枚“暴怒”标记。",
	audio = "武可定天下，计谋何足道？",
}
--[[
	技能：无前
	描述：出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。
]]--
WuQian = sgs.CreateLuaSkill{
	name = "WuQian",
	translation = "无前",
	description = "出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。",
	audio = {
		"战神一出，天下无双！",
		"顺我者生，逆我者死！",
	},
}
--[[
	技能：神愤（阶段技）
	描述：你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。
]]--
ShenFen = sgs.CreateLuaSkill{
	name = "ShenFen",
	translation = "神愤",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。",
	audio = {
		"颤抖着滚开吧杂鱼们！这天下，还有谁能满足我？",
		"战神之怒，神挡杀神，佛挡杀佛！",
	},
}
--[[
	技能：无双（锁定技）
	描述：
]]--
--武将信息：
LvBu = sgs.CreateLuaGeneral{
	name = "shenlvbu",
	real_name = "lvbu",
	translation = "神吕布",
	show_name = "吕布",
	title = "修罗之道",
	kingdom = "god",
	maxhp = 5,
	order = 6,
	cv = "笑傲糨糊",
	skills = {KuangBao, WuMou, WuQian, ShenFen},
	related_skills = "wushuang",
	last_word = "大耳贼最叵信！啊……",
	resource = "lvbu",
	marks = {"@wrath"},
}
--[[****************************************************************
	称号：晋国之祖
	武将：司马懿
	势力：神
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：忍戒（锁定技）
	描述：每当你受到1点伤害后或于弃牌阶段因你的弃置而失去一张牌后，你获得一枚“忍”。
]]--
RenJie = sgs.CreateLuaSkill{
	name = "RenJie",
	translation = "忍戒",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到1点伤害后或于弃牌阶段因你的弃置而失去一张牌后，你获得一枚“忍”。",
	audio = "韬光养晦，静待时机。",
}
--[[
	技能：拜印（觉醒技）
	描述：准备阶段开始时，若你拥有四枚或更多的“忍”，你失去1点体力上限，然后获得“极略”（你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”）。
]]--
BaiYin = sgs.CreateLuaSkill{
	name = "BaiYin",
	translation = "拜印",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你拥有四枚或更多的“忍”，你失去1点体力上限，然后获得“极略”。\
\
☆<b>极略</b>：你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”。",
	audio = "是可忍，孰不可忍！",
}
--[[
	技能：连破
	描述：每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以进行一个额外的回合。
]]--
LianPo = sgs.CreateLuaSkill{
	name = "LianPo",
	translation = "连破",
	description = "每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以进行一个额外的回合。",
	audio = "敌军已乱，乘胜追击！",
}
--[[
	技能：极略
	描述：你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”。
]]--
JiLve = sgs.CreateLuaSkill{
	name = "JiLve",
	translation = "极略",
	description = "你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”。",
	audio = {
		"天意如何，我命由我！",
		"忍逐敌雠，拔除异己。",
		"心狠手毒，方能成事。",
		"暂且思量，再做打算。",
		"此计既成，彼计亦得。",
	},
}
--武将信息：司马懿
SiMaYi = sgs.CreateLuaGeneral{
	name = "shensimayi",
	real_name = "simayi",
	translation = "神司马懿",
	show_name = "司马懿",
	title = "晋国之祖",
	kingdom = "god",
	order = 9,
	cv = "泥马",
	skills = {RenJie, BaiYin, LianPo},
	related_skills = JiLve,
	last_word = "我已谋划至此，奈何……",
	resource = "simayi",
	marks = {"@bear"},
}
--[[****************************************************************
	称号：神威如龙
	武将：赵云
	势力：神
	性别：男
	体力上限：2勾玉
]]--****************************************************************
--[[
	技能：绝境（锁定技）
	描述：摸牌阶段，你额外摸X张牌。你的手牌上限+2。（X为你已损失的体力值）
]]--
--[[
	技能：龙魂
	描述：你可以将X张同花色的牌按以下规则使用或打出：♥当【桃】；♦当火【杀】；♠当【无懈可击】；♣当【闪】。（X为你的体力值且至少为1）
]]--
--武将信息：赵云
ZhaoYun = sgs.CreateLuaGeneral{
	name = "gods_zhaoyun",
	real_name = "zhaoyun",
	translation = "神赵云",
	show_name = "赵云",
	title = "神威如龙",
	kingdom = "god",
	maxhp = 2,
	order = 8,
	hidden = true,
	cv = "猎狐",
	skills = {"juejing", "longhun"},
	last_word = "血染麟甲，龙坠九天……",
	resource = "zhaoyun",
}
--[[****************************************************************
	神武将包
]]--****************************************************************
return sgs.CreateLuaGeneral{
	name = "gods",
	translation = "神包",
	generals = {
		GuanYu, LvMeng, ZhuGeLiang, ZhouYu, CaoCao, LvBu, SiMaYi, ZhaoYun,
	},
}