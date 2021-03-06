--[[
	太阳神三国杀武将单挑对战平台·倚天武将包
	武将总数：16
	武将一览：
		1、魏武帝（归心、飞影）
		2、曹冲（称象、聪慧、早夭）
		3、张儁乂（绝汲）
		4、陆抗（围堰、克构）+（连营）
		5、晋宣帝（五灵）
		6、夏侯涓（连理、同心、离迁）
		7、蔡昭姬（归汉、胡笳）
		8、陆伯言（神君、烧营、纵火）
		9、钟士季（共谋）
		10、姜伯约（乐学、殉志）
		11、贾文和（洞察、毒士）+（崩坏）
		12、古之恶来（死战、神力）
		13、邓士载（争功、偷渡）
		14、张公祺（义舍、惜粮）
		15、倚天剑（争锋、镇威、倚天）
		16、庞令明（抬榇）
]]--
--[[****************************************************************
	称号：超世之英杰
	武将：魏武帝
	势力：神
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：归心
	描述：结束阶段开始时，你可以选择一项：
		1. 改变一名其他角色的势力；
		2. 获得一个未加入游戏的武将牌上的主公技。
]]--
GuiXin = sgs.CreateLuaSkill{
	name = "ytGuiXin",
	translation = "归心",
	description = "结束阶段开始时，你可以选择一项：\
1. 改变一名其他角色的势力；\
2. 获得一个未加入游戏的武将牌上的主公技。",
}
--[[
	技能：飞影（锁定技）
	描述：其他角色与你的距离+1。
]]--
--武将信息：魏武帝
CaoCao = sgs.CreateLuaGeneral{
	name = "yt_weiwudi",
	real_name = "caocao",
	translation = "魏武帝",
	title = "超世之英杰",
	kingdom = "god",
	maxhp = 3,
	order = 2,
	cv = "",
	illustrator = "",
	skills = {GuiXin, "FeiYing"},
	last_word = "",
	resource = "weiwudi",
}
--[[****************************************************************
	称号：早夭的神童
	武将：曹冲
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：称象
	描述：每当你受到一次伤害后，你可以弃置X张点数之和与造成伤害的牌的点数相等的牌并选择至多X名角色，这些角色：已受伤，回复1点体力；未受伤，摸两张牌。
]]--
ChengXiang = sgs.CreateLuaSkill{
	name = "ytChengXiang",
	translation = "称象",
	description = "每当你受到一次伤害后，你可以弃置X张点数之和与造成伤害的牌的点数相等的牌并选择至多X名角色，这些角色：已受伤，回复1点体力；未受伤，摸两张牌。",
}
--[[
	技能：早夭（锁定技）
	描述：结束阶段开始时，若你的手牌数大于13，你须弃置所有手牌并失去1点体力。
]]--
ZaoYao = sgs.CreateLuaSkill{
	name = "ytZaoYao",
	translation = "早夭",
	description = "<font color=\"blue\"><b>锁定技</b></font>，结束阶段开始时，若你的手牌数大于13，你须弃置所有手牌并失去1点体力。",
}
--[[
	技能：聪慧（锁定技）
	描述：你跳过弃牌阶段。
]]--
CongHui = sgs.CreateLuaSkill{
	name = "ytCongHui",
	translation = "聪慧",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你跳过弃牌阶段。",
}
--武将信息：曹冲
CaoChong = sgs.CreateLuaGeneral{
	name = "yt_caochong",
	real_name = "caochong",
	translation = "曹冲",
	title = "早夭的神童",
	kingdom = "wei",
	maxhp = 3,
	order = 5,
	cv = "",
	illustrator = "",
	skills = {ChengXiang, ZaoYao, CongHui},
	last_word = "",
	resource = "caochong",
}
--[[****************************************************************
	称号：计谋巧变
	武将：张儁乂
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：绝汲（阶段技）
	描述：你可以与一名角色拼点：当你赢后，你获得对方的拼点牌。你可以重复此流程，直到你拼点没赢为止。
]]--
JueJi = sgs.CreateLuaSkill{
	name = "ytJueJi",
	translation = "绝汲",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名角色拼点：当你赢后，你获得对方的拼点牌。你可以重复此流程，直到你拼点没赢为止。",
}
--武将信息：张儁乂
ZhangHe = sgs.CreateLuaGeneral{
	name = "yt_zhangjunyi",
	real_name = "zhanghe",
	translation = "张儁乂",
	title = "计谋巧变",
	kingdom = "qun",
	maxhp = 4,
	order = 6,
	cv = "",
	illustrator = "",
	skills = JueJi,
	last_word = "",
	resource = "zhangjunyi",
}
--[[****************************************************************
	称号：最后的良将
	武将：陆抗
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：围堰
	描述：你可以将摸牌阶段视为出牌阶段，将出牌阶段视为摸牌阶段。
]]--
WeiYan = sgs.CreateLuaSkill{
	name = "ytWeiYan",
	translation = "围堰",
	description = "你可以将摸牌阶段视为出牌阶段，将出牌阶段视为摸牌阶段。",
}
--[[
	技能：克构（觉醒技）
	描述：准备阶段开始时，若你是除主公外唯一的吴势力角色，你减少1点体力上限，获得技能“连营”。
]]--
KeGou = sgs.CreateLuaSkill{
	name = "ytKeGou",
	translation = "克构",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你是除主公外唯一的吴势力角色，你减少1点体力上限，获得技能“连营”。",
}
--[[
	技能：连营
	描述：每当你失去最后的手牌后，你可以摸一张牌。
]]--
--武将信息：陆抗
LuKang = sgs.CreateLuaGeneral{
	name = "yt_lukang",
	real_name = "lukang",
	translation = "陆抗",
	title = "最后的良将",
	kingdom = "wu",
	maxhp = 4,
	order = 7,
	cv = "",
	illustrator = "",
	skills = {WeiYan, KeGou},
	related_skills = "LianYing",
	last_word = "",
	resource = "lukang",
}
--[[****************************************************************
	称号：祁山里的术士
	武将：晋宣帝
	势力：神
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：五灵
	描述：准备阶段开始时，你可选择一种五灵效果，该效果对场上所有角色生效。该效果直到你的下回合开始为止，你选择的五灵效果不可与上回合重复。
		[风]一名角色受到火属性伤害时，此伤害+1。
		[雷]一名角色受到雷属性伤害时，此伤害+1。
		[水]一名角色受【桃】效果影响回复的体力+1。
		[火]一名角色受到的伤害均视为火焰伤害。
		[土]一名角色受到的属性伤害大于1时，防止多余的伤害。
]]--
WuLing = sgs.CreateLuaSkill{
	name = "ytWuLing",
	translation = "五灵",
	description = "准备阶段开始时，你可选择一种五灵效果，该效果对场上所有角色生效。该效果直到你的下回合开始为止，你选择的五灵效果不可与上回合重复。\
[风]一名角色受到火属性伤害时，此伤害+1。\
[雷]一名角色受到雷属性伤害时，此伤害+1。\
[水]一名角色受【桃】效果影响回复的体力+1。\
[火]一名角色受到的伤害均视为火焰伤害。\
[土]一名角色受到的属性伤害大于1时，防止多余的伤害。",
}
--武将信息：晋宣帝
SiMaYi = sgs.CreateLuaGeneral{
	name = "yt_jinxuandi",
	real_name = "simayi",
	translation = "晋宣帝",
	title = "祁山里的术士",
	kingdom = "god",
	maxhp = 4,
	order = 2,
	cv = "",
	illustrator = "",
	skills = WuLing,
	last_word = "",
	resource = "jinxuandi",
}
--[[****************************************************************
	称号：樵采的美人
	武将：夏侯涓
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：连理
	描述：准备阶段开始时，你可以选择一名男性角色，你与其进入连理状态直到你的下回合开始：其可以替你使用或打出【闪】，你可以替其使用或打出【杀】。
]]--
LianLi = sgs.CreateLuaSkill{
	name = "ytLianLi",
	translation = "连理",
	description = "准备阶段开始时，你可以选择一名男性角色，你与其进入连理状态直到你的下回合开始：其可以替你使用或打出【闪】，你可以替其使用或打出【杀】。",
}
--[[
	技能：同心
	描述：每当一名处于连理状态的角色受到1点伤害后，你可以令处于连理状态的角色各摸一张牌。
]]--
TongXin = sgs.CreateLuaSkill{
	name = "ytTongXin",
	translation = "同心",
	description = "每当一名处于连理状态的角色受到1点伤害后，你可以令处于连理状态的角色各摸一张牌。",
}
--[[
	技能：离迁（锁定技）
	描述：若你处于连理状态，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏。
]]--
LiQian = sgs.CreateLuaSkill{
	name = "ytLiQian",
	translation = "离迁",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你处于连理状态，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏。",
}
--武将信息：夏侯涓
XiaHouJuan = sgs.CreateLuaGeneral{
	name = "yt_xiahoujuan",
	real_name = "xiahoujuan",
	translation = "夏侯涓",
	title = "樵采的美人",
	kingdom = "wei",
	maxhp = 3,
	order = 1,
	cv = "",
	illustrator = "",
	skills = {LianLi, TongXin, LiQian},
	last_word = "",
	resource = "xiahoujuan",
}
--[[****************************************************************
	称号：乱世才女
	武将：蔡昭姬
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：归汉（阶段技）
	描述：你可以弃置两张花色相同的红色手牌并选择一名其他角色，与其交换位置。
]]--
GuiHan = sgs.CreateLuaSkill{
	name = "ytGuiHan",
	translation = "归汉",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置两张花色相同的红色手牌并选择一名其他角色，与其交换位置。",
}
--[[
	技能：胡笳
	描述：结束阶段开始时，你可以进行一次判定：若结果为红色，你获得此判定牌，若如此做，你可以重复此流程。若你在一个阶段内发动“胡笳”判定过至少三次，你将武将牌翻面。
]]--
HuJia = sgs.CreateLuaSkill{
	name = "ytHuJia",
	translation = "胡笳",
	description = "结束阶段开始时，你可以进行一次判定：若结果为红色，你获得此判定牌，若如此做，你可以重复此流程。若你在一个阶段内发动“胡笳”判定过至少三次，你将武将牌翻面。",
}
--武将信息：蔡昭姬
CaiYan = sgs.CreateLuaGeneral{
	name = "yt_caizhaoji",
	real_name = "caiyan",
	translation = "蔡昭姬",
	title = "乱世才女",
	kingdom = "qun",
	maxhp = 3,
	order = 7,
	cv = "",
	illustrator = "",
	skills = {GuiHan, HuJia},
	last_word = "",
	resource = "caizhaoji",
}
--[[****************************************************************
	称号：玩火的少年
	武将：陆伯言
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：神君（锁定技）
	描述：游戏开始时，你选择自己的性别；准备阶段开始时，你须改变性别；每当你受到异性角色造成的非雷属性伤害时，你防止之。
]]--
ShenJun = sgs.CreateLuaSkill{
	name = "ytShenJun",
	translation = "神君",
	description = "<font color=\"blue\"><b>锁定技</b></font>，游戏开始时，你选择自己的性别；准备阶段开始时，你须改变性别；每当你受到异性角色造成的非雷属性伤害时，你防止之。",
}
--[[
	技能：烧营
	描述：每当你对一名不处于连环状态的角色造成一次火焰伤害扣减体力前，你可选择一名其距离为1的一名角色，若如此做，此伤害结算完毕后，你进行一次判定：若结果为红色，你对其造成1点火属性伤害。
]]--
ShaoYing = sgs.CreateLuaSkill{
	name = "ytShaoYing",
	translation = "烧营",
	description = "每当你对一名不处于连环状态的角色造成一次火焰伤害扣减体力前，你可选择一名其距离为1的一名角色，若如此做，此伤害结算完毕后，你进行一次判定：若结果为红色，你对其造成1点火属性伤害。",
}
--[[
	技能：纵火（锁定技）
	描述：你使用的【杀】视为火【杀】。
]]--
ZongHuo = sgs.CreateLuaSkill{
	name = "ytZongHuo",
	translation = "纵火",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你使用的【杀】视为火【杀】。",
}
--武将信息：陆伯言
LuXun = sgs.CreateLuaGeneral{
	name = "yt_luboyan",
	real_name = "luxun",
	translation = "陆伯言",
	title = "玩火的少年",
	kingdom = "wu",
	maxhp = 3,
	order = 4,
	cv = "",
	illustrator = "",
	skills = {ShenJun, ZongHuo, ShaoYing},
	last_word = "",
	resource = "luboyan",
}
--[[****************************************************************
	称号：狠毒的野心家
	武将：钟士季
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：共谋
	描述：结束阶段开始时，你可以选择一名其他角色，若如此做，其于其下个摸牌阶段摸牌后，将X张手牌交给你（X为你手牌数与对方手牌数的较小值），然后你将X张手牌交给其。
]]--
GongMou = sgs.CreateLuaSkill{
	name = "ytGongMou",
	translation = "共谋",
	description = "结束阶段开始时，你可以选择一名其他角色，若如此做，其于其下个摸牌阶段摸牌后，将X张手牌交给你（X为你手牌数与对方手牌数的较小值），然后你将X张手牌交给其。",
}
--武将信息：钟士季
ZhongHui = sgs.CreateLuaGeneral{
	name = "yt_zhongshiji",
	real_name = "zhonghui",
	translation = "钟士季",
	title = "狠毒的野心家",
	kingdom = "wei",
	maxhp = 4,
	order = 6,
	cv = "",
	illustrator = "",
	skills = GongMou,
	last_word = "",
	resource = "zhongshiji",
}
--[[****************************************************************
	称号：赤胆的贤将
	武将：姜伯约
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：乐学（阶段技）
	描述：你可以令一名其他角色展示一张手牌：若此牌为基本牌或非延时类锦囊牌，你于当前回合内可以将与此牌同花色的牌当作该牌使用或打出；否则，你获得之。
]]--
LeXue = sgs.CreateLuaSkill{
	name = "ytLeXue",
	translation = "乐学",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令一名其他角色展示一张手牌：若此牌为基本牌或非延时类锦囊牌，你于当前回合内可以将与此牌同花色的牌当作该牌使用或打出；否则，你获得之。",
}
--[[
	技能：殉志
	描述：出牌阶段，你可以摸三张牌，然后变身为游戏外的一名蜀势力武将，若如此做，回合结束后，你死亡。
]]--
XunZhi = sgs.CreateLuaSkill{
	name = "ytXunZhi",
	translation = "殉志",
	description = "出牌阶段，你可以摸三张牌，然后变身为游戏外的一名蜀势力武将，若如此做，回合结束后，你死亡。",
}
--武将信息：姜伯约
JiangWei = sgs.CreateLuaGeneral{
	name = "yt_jiangboyue",
	real_name = "jiangwei",
	translation = "姜伯约",
	title = "赤胆的贤将",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	cv = "",
	illustrator = "",
	skills = {LeXue, XunZhi},
	last_word = "",
	resource = "jiangboyue",
}
--[[****************************************************************
	称号：明哲保身
	武将：贾文和
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：洞察
	描述：准备阶段开始时，你可以选择一名其他角色：其所有手牌于当前回合内对你可见。
		注：你以此法选择的角色的操作不公开，换言之，只有你知道洞察的目标。
]]--
DongCha = sgs.CreateLuaSkill{
	name = "ytDongCha",
	translation = "洞察",
	description = "准备阶段开始时，你可以选择一名其他角色：其所有手牌于当前回合内对你可见。\
注：你以此法选择的角色的操作不公开，换言之，只有你知道洞察的目标。",
}
--[[
	技能：毒士（锁定技）
	描述：当你死亡时，杀死你的角色获得技能“崩坏”。
]]--
DuShi = sgs.CreateLuaSkill{
	name = "ytDuShi",
	translation = "毒士",
	description = "<font color=\"blue\"><b>锁定技</b></font>，当你死亡时，杀死你的角色获得技能“崩坏”。",
}
--[[
	技能：崩坏（锁定技）
	描述：结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。
]]--
--武将信息：贾文和
JiaXu = sgs.CreateLuaGeneral{
	name = "yt_jiawenhe",
	real_name = "jiaxu",
	translation = "贾文和",
	title = "明哲保身",
	kingdom = "qun",
	maxhp = 4,
	order = 4,
	cv = "",
	illustrator = "",
	skills = {DongCha, DuShi},
	related_skills = "BengHuai",
	last_word = "",
	resource = "jiawenhe",
}
--[[****************************************************************
	称号：不坠悍将
	武将：古之恶来
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：死战（锁定技）
	描述：每当你受到一次伤害时，你防止此伤害并获得等同于伤害点数的“死战”标记；结束阶段开始时，你失去等量于你拥有的“死战”标记数的体力并弃所有的“死战”标记。
]]--
SiZhan = sgs.CreateLuaSkill{
	name = "ytSiZhan",
	translation = "死战",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到一次伤害时，你防止此伤害并获得等同于伤害点数的“死战”标记；结束阶段开始时，你失去等量于你拥有的“死战”标记数的体力并弃所有的“死战”标记。",
}
--[[
	技能：神力（锁定技）
	描述：你于出牌阶段内第一次使用【杀】造成伤害时，此伤害+X（X为当前死战标记数且最大为3）。
]]--
ShenLi = sgs.CreateLuaSkill{
	name = "ytShenLi",
	translation = "神力",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你于出牌阶段内第一次使用【杀】造成伤害时，此伤害+X（X为当前死战标记数且最大为3）。",
}
--武将信息：古之恶来
DianWei = sgs.CreateLuaGeneral{
	name = "yt_guzhielai",
	real_name = "dianwei",
	translation = "古之恶来",
	title = "不坠悍将",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	cv = "",
	illustrator = "",
	skills = {SiZhan, ShenLi},
	last_word = "",
	resource = "guzhielai",
}
--[[****************************************************************
	称号：破蜀首功
	武将：邓士载
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：争功
	描述：其他角色的回合开始前，若你的武将牌正面朝上，你可以获得一个额外的回合，此回合结束后，你将武将牌翻面。
]]--
ZhengGong = sgs.CreateLuaSkill{
	name = "ytZhengGong",
	translation = "争功",
	description = "其他角色的回合开始前，若你的武将牌正面朝上，你可以获得一个额外的回合，此回合结束后，你将武将牌翻面。",
}
--[[
	技能：偷渡
	描述：每当你受到一次伤害后，若你的武将牌背面朝上，你可以弃置一张手牌，将你的武将牌翻面，然后视为使用一张【杀】。
]]--
TouDu = sgs.CreateLuaSkill{
	name = "ytTouDu",
	translation = "偷渡",
	description = "每当你受到一次伤害后，若你的武将牌背面朝上，你可以弃置一张手牌，将你的武将牌翻面，然后视为使用一张【杀】。",
}
--武将信息：邓士载
DengAi = sgs.CreateLuaGeneral{
	name = "yt_dengshizai",
	real_name = "dengai",
	translation = "邓士载",
	title = "破蜀首功",
	kingdom = "wei",
	maxhp = 3,
	order = 6,
	cv = "",
	illustrator = "",
	skills = {ZhengGong, TouDu},
	last_word = "",
	resource = "dengshizai",
}
--[[****************************************************************
	称号：五斗米道
	武将：张公祺
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：义舍
	描述：出牌阶段，你可以将至少一张手牌置于你的武将牌上称为“米”（“米”不能多于五张）或获得至少一张“米”；
		其他角色的出牌阶段限两次，其可选择一张“米”，你可以将之交给其。
]]--
YiShe = sgs.CreateLuaSkill{
	name = "ytYiShe",
	translation = "义舍",
	description = "出牌阶段，你可以将至少一张手牌置于你的武将牌上称为“米”（“米”不能多于五张）或获得至少一张“米”；\
其他角色的出牌阶段限两次，其可选择一张“米”，你可以将之交给其。",
}
--[[
	技能：惜粮
	描述：每当其他角色于其弃牌阶段因弃置失去一张红色牌后，你可以选择一项：1.将之置于你的武将牌上，称为“米”；2.获得之。
]]--
XiLiang = sgs.CreateLuaSkill{
	name = "ytXiLiang",
	translation = "惜粮",
	description = "每当其他角色于其弃牌阶段因弃置失去一张红色牌后，你可以选择一项：1.将之置于你的武将牌上，称为“米”；2.获得之。",
}
--武将信息：张公祺
ZhangLu = sgs.CreateLuaGeneral{
	name = "yt_zhanggongqi",
	real_name = "zhanglu",
	translation = "张公祺",
	title = "五斗米道",
	kingdom = "qun",
	maxhp = 3,
	order = 7,
	cv = "",
	illustrator = "",
	skills = {YiShe, XiLiang},
	last_word = "",
	resource = "zhanggongqi",
}
--[[****************************************************************
	称号：跨海斩长鲸
	武将：倚天剑
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：争锋（锁定技）
	描述：若你的装备区没有武器牌，你的攻击范围为X（X为你的体力值）。
]]--
ZhengFeng = sgs.CreateLuaSkill{
	name = "ytZhengFeng",
	translation = "争锋",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的装备区没有武器牌，你的攻击范围为X（X为你的体力值）。",
}
--[[
	技能：镇威
	描述：每当你使用的【杀】被【闪】抵消时，你可以获得处理区里的此【闪】。
]]--
ZhenWei = sgs.CreateLuaSkill{
	name = "ytZhenWei",
	translation = "镇威",
	description = "每当你使用的【杀】被【闪】抵消时，你可以获得处理区里的此【闪】。",
}
--[[
	技能：倚天（联动技）
	描述：每当你对曹操造成伤害时，你可以令该伤害-1。
]]--
YiTian = sgs.CreateLuaSkill{
	name = "ytYiTian",
	translation = "倚天",
	description = "<font color=\"pink\"><b>联动技</b></font>，每当你对曹操造成伤害时，你可以令该伤害-1。",
}
--武将信息：倚天剑
YiTianJian = sgs.CreateLuaGeneral{
	name = "yt_yitianjian",
	real_name = "yitianjian",
	translation = "倚天剑",
	title = "跨海斩长鲸",
	kingdom = "wei",
	maxhp = 4,
	order = 0,
	cv = "",
	illustrator = "",
	skills = {ZhengFeng, ZhenWei, YiTian},
	last_word = "",
	resource = "yitianjian",
}
--[[****************************************************************
	称号：抬榇之悟
	武将：庞令明
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：抬榇
	描述：出牌阶段，你可以失去1点体力或弃置一张武器牌，依次弃置你攻击范围内的一名角色区域内的两张牌。
]]--
TaiChen = sgs.CreateLuaSkill{
	name = "ytTaiChen",
	translation = "抬榇",
	description = "出牌阶段，你可以失去1点体力或弃置一张武器牌，依次弃置你攻击范围内的一名角色区域内的两张牌。",
}
--武将信息：庞令明
PangDe = sgs.CreateLuaGeneral{
	name = "yt_panglingming",
	real_name = "pangde",
	translation = "庞令明",
	title = "抬榇之悟",
	kingdom = "wei",
	maxhp = 4,
	order = 8,
	cv = "",
	illustrator = "",
	skills = TaiChen,
	last_word = "",
	resource = "panglingming",
}
--[[****************************************************************
	倚天武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yitian",
	translation = "倚天包",
	generals = {
		CaoCao, CaoChong, ZhangHe, LuKang,
		SiMaYi, XiaHouJuan, CaiYan, LuXun,
		ZhongHui, JiangWei, JiaXu, DianWei,
		DengAi, ZhangLu, YiTianJian, PangDe,
	},
}