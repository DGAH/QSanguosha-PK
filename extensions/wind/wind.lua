--[[
	太阳神三国杀武将单挑对战平台·风武将包
	武将总数：8
	武将一览：
		1、夏侯渊（神速）
		2、曹仁（据守）
		3、黄忠（烈弓）
		4、魏延（狂骨）
		5、小乔（天香、红颜）
		6、周泰（不屈）
		7、张角（雷击、鬼道、黄天）
		8、于吉（蛊惑）
]]--
--[[****************************************************************
	称号：疾行的猎豹
	武将：夏侯渊
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：神速
	描述：你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。
]]--
ShenSu = sgs.CreateLuaSkill{
	name = "ShenSu",
	translation = "神速",
	description = "你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。",
	audio = {
		"吾善于千里袭人！",
		"取汝首级，犹如探囊取物！",
	},
}
--武将信息：夏侯渊
XiaHouYuan = sgs.CreateLuaGeneral{
	name = "xiahouyuan",
	translation = "夏侯渊",
	title = "疾行的猎豹",
	kingdom = "wei",
	order = 4,
	skills = ShenSu,
	last_word = "竟然……比我还……快……",
	resource = "xiahouyuan",
}
--[[****************************************************************
	称号：大将军
	武将：曹仁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：据守
	描述：结束阶段开始时，你可以摸三张牌，然后将武将牌翻面。
]]--
JuShou = sgs.CreateLuaSkill{
	name = "JuShou",
	translation = "据守",
	description = "结束阶段开始时，你可以摸三张牌，然后将武将牌翻面。",
	audio = {
		"我先休息一会儿！",
		"尽管来吧！",
	},
}
--武将信息：曹仁
CaoRen = sgs.CreateLuaGeneral{
	name = "caoren",
	translation = "曹仁",
	title = "大将军",
	kingdom = "wei",
	order = 6,
	skills = JuShou,
	last_word = "实在是……守不住了……",
	resource = "caoren",
}
--[[****************************************************************
	称号：老当益壮
	武将：黄忠
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：烈弓
	描述：每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，或目标角色的手牌数小于或等于你的攻击范围，你可以令该角色不能使用【闪】响应此【杀】。
]]--
LieGong = sgs.CreateLuaSkill{
	name = "LieGong",
	translation = "烈弓",
	description = "每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，或目标角色的手牌数小于或等于你的攻击范围，你可以令该角色不能使用【闪】响应此【杀】。",
	audio = {
		"百步穿杨！",
		"中！",
	},
}
--武将信息：黄忠
HuangZhong = sgs.CreateLuaGeneral{
	name = "huangzhong",
	translation = "黄忠",
	title = "老当益壮",
	kingdom = "shu",
	order = 7,
	skills = LieGong,
	last_word = "不得不服老了……",
	resource = "huangzhong",
}
--[[****************************************************************
	称号：嗜血的独狼
	武将：魏延
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：狂骨（锁定技）
	描述：每当你对一名距离1以内角色造成1点伤害后，你回复1点体力。
]]--
KuangGu = sgs.CreateLuaSkill{
	name = "KuangGu",
	translation = "狂骨",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你对一名距离1以内角色造成1点伤害后，你回复1点体力。",
	audio = "哈哈！",
}
--武将信息：魏延
WeiYan = sgs.CreateLuaGeneral{
	name = "weiyan",
	translation = "魏延",
	title = "嗜血的独狼",
	kingdom = "shu",
	order = 5,
	illustrator = "Sonia Tang",
	skills = KuangGu,
	last_word = "谁敢杀我？啊！",
	resource = "weiyan",
}
--[[****************************************************************
	称号：矫情之花
	武将：小乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天香
	描述：每当你受到伤害时，你可以弃置一张♥手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。
]]--
TianXiang = sgs.CreateLuaSkill{
	name = "TianXiang",
	translation = "天香",
	description = "每当你受到伤害时，你可以弃置一张红心手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。",
	audio = {
		"替我挡着~",
		"接着哦~",
	},
}
--[[
	技能：红颜（锁定技）
	描述：你的♠牌视为♥牌。
]]--
HongYan = sgs.CreateLuaSkill{
	name = "HongYan",
	translation = "红颜",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的黑桃牌视为红心牌。",
	audio = "（魔法特效）",
}
--武将信息：小乔
XiaoQiao = sgs.CreateLuaGeneral{
	name = "xiaoqiao",
	translation = "小乔",
	title = "矫情之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 2,
	skills = {TianXiang, HongYan},
	last_word = "公瑾，我先走一步……",
	resource = "xiaoqiao",
}
--[[****************************************************************
	称号：历战之躯
	武将：周泰
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：不屈
	描述：每当你扣减1点体力后，若你的体力值为0或更低，你可以将牌堆顶的一张牌置于你的武将牌上，然后若无同点数的“不屈牌”，你不进入濒死状态。每当你回复1点体力后，你将一张“不屈牌”置入弃牌堆。
]]--
BuQu = sgs.CreateLuaSkill{
	name = "BuQu",
	translation = "不屈",
	description = "每当你扣减1点体力后，若你的体力值为0或更低，你可以将牌堆顶的一张牌置于你的武将牌上，然后若无同点数的“不屈牌”，你不进入濒死状态。每当你回复1点体力后，你将一张“不屈牌”置入弃牌堆。",
	audio = {
		"还不够！",
		"我绝不会倒下！",
	},
}
--武将信息：周泰
ZhouTai = sgs.CreateLuaGeneral{
	name = "zhoutai",
	translation = "周泰",
	title = "历战之躯",
	kingdom = "wu",
	order = 2,
	skills = BuQu,
	last_word = "已经……尽力了……",
	resource = "zhoutai",
}
--[[****************************************************************
	称号：天公将军
	武将：张角
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：雷击
	描述：每当你使用或打出一张【闪】时，你可以令一名角色进行判定：若结果为♠，你对该角色造成2点雷电伤害。
]]--
LeiJi = sgs.CreateLuaSkill{
	name = "LeiJi",
	translation = "雷击",
	description = "每当你使用或打出一张【闪】时，你可以令一名角色进行判定：若结果为黑桃，你对该角色造成2点雷电伤害。",
	audio = {
		"以我之真气，合天地之造化！",
		"雷公助我！",
	},
}
--[[
	技能：鬼道
	描述：每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。
]]--
GuiDao = sgs.CreateLuaSkill{
	name = "GuiDao",
	translation = "鬼道",
	description = "每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。",
	audio = {
		"天下大势，为我所控！",
		"哼哼哼哼哼……",
	},
}
--[[
	技能：黄天（主公技、阶段技）[空壳技能]
	描述：其他群雄角色的出牌阶段，该角色可以交给你一张【闪】或【闪电】。
]]--
HuangTian = sgs.CreateLuaSkill{
	name = "HuangTian",
	translation = "黄天",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"green\"><b>阶段技</b></font>，其他群雄角色的出牌阶段，该角色可以交给你一张【闪】或【闪电】。",
}
--武将信息：张角
ZhangJiao = sgs.CreateLuaGeneral{
	name = "zhangjiao",
	translation = "张角",
	title = "天公将军",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	skills = {LeiJi, GuiDao, HuangTian},
	last_word = "黄天……也死了……",
	resource = "zhangjiao",
}
--[[****************************************************************
	称号：太平道人
	武将：于吉
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：蛊惑
	描述：你可以扣置一张手牌当做一张基本牌或非延时锦囊牌使用或打出，体力值大于0的其他角色选择是否质疑，然后你展示此牌：若无角色质疑，此牌按你所述继续结算；若有角色质疑：若此牌为真，质疑角色各失去1点体力，否则质疑角色各摸一张牌；且若此牌为♥且为真，则按你所述继续结算，否则将之置入弃牌堆。
]]--
GuHuo = sgs.CreateLuaSkill{
	name = "GuHuo",
	translation = "蛊惑",
	description = "你可以扣置一张手牌当做一张基本牌或非延时锦囊牌使用或打出，体力值大于0的其他角色选择是否质疑，然后你展示此牌：若无角色质疑，此牌按你所述继续结算；若有角色质疑：若此牌为真，质疑角色各失去1点体力，否则质疑角色各摸一张牌；且若此牌为红心且为真，则按你所述继续结算，否则将之置入弃牌堆。",
	audio = {
		"猜猜看哪~",
		"你信吗？",
	},
}
--武将信息：于吉
YuJi = sgs.CreateLuaGeneral{
	name = "yuji",
	translation = "于吉",
	title = "太平道人",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	skills = GuHuo,
	last_word = "竟然……被猜到了……",
	resource = "yuji",
}
--[[****************************************************************
	风武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "wind",
	translation = "风包",
	generals = {
		XiaHouYuan, CaoRen, HuangZhong, WeiYan, XiaoQiao, ZhouTai, ZhangJiao, YuJi,
	},
}