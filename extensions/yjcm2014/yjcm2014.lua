--[[
	太阳神三国杀武将单挑对战平台·一将成名2014武将包
	武将总数：11
	武将一览：
		1、蔡夫人（窃听、献州）
		2、曹真（司敌）
		3、陈群（定品、法恩）
		4、顾雍（慎行、秉壹）
		5、韩浩史涣（慎断、勇略）
		6、沮授（渐营、矢北）
		7、孙鲁班（谮毁、骄矜）
		8、吴懿（奔袭）
		9、张松（强识、献图）
		10、周仓（忠勇）
		11、朱桓（诱敌）
]]--
--[[****************************************************************
	称号：襄江的蒲苇
	武将：蔡夫人
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：窃听
	描述：一名其他角色的回合结束时，若其未于此回合内使用过以除其外的角色为目标的牌，你可以选择一项：将其装备区的一张牌置入自己的装备区，或摸一张牌。
]]--
QieTing = sgs.CreateLuaSkill{
	name = "yj4QieTing",
	translation = "窃听",
	description = "一名其他角色的回合结束时，若其未于此回合内使用过以除其外的角色为目标的牌，你可以选择一项：将其装备区的一张牌置入自己的装备区，或摸一张牌。",
	audio = {},
}
--[[
	技能：献州（限定技）
	描述：出牌阶段，你可以将装备区的所有牌交给一名其他角色，然后该角色选择一项：令你回复X点体力，或对其攻击范围内的X名角色各造成1点伤害。（X为你以此法给出的牌数）
]]--
XianZhou = sgs.CreateLuaSkill{
	name = "yj4XianZhou",
	translation = "献州",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以将装备区的所有牌交给一名其他角色，然后该角色选择一项：令你回复X点体力，或对其攻击范围内的X名角色各造成1点伤害。（X为你以此法给出的牌数）",
	audio = {},
}
--武将信息：蔡夫人
CaiFuRen = sgs.CreateLuaGeneral{
	name = "yj_iv_caifuren",
	real_name = "caifuren",
	translation = "蔡夫人",
	title = "襄江的蒲苇",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 3,
	designer = "B.LEE",
	cv = "",
	illustrator = "Dream彼端",
	skills = {QieTing, XianZhou},
	last_word = "孤儿寡母的……何必赶尽杀绝呢……",
	resource = "caifuren",
}
--[[****************************************************************
	称号：荷国天督
	武将：曹真
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：司敌
	描述：每当你使用或其他角色在你的回合内使用【闪】时，你可以将牌堆顶的一张牌置于武将牌上。一名其他角色的出牌阶段开始时，你可以将一张“司敌牌”置入弃牌堆，然后该角色本回合使用【杀】的次数上限-1。
]]--
SiDi = sgs.CreateLuaSkill{
	name = "yj4SiDi",
	translation = "司敌",
	description = "每当你使用或其他角色在你的回合内使用【闪】时，你可以将牌堆顶的一张牌置于武将牌上。一名其他角色的出牌阶段开始时，你可以将一张“司敌牌”置入弃牌堆，然后该角色本回合使用【杀】的次数上限-1。",
	audio = {},
}
--武将信息：曹真
CaoZhen = sgs.CreateLuaGeneral{
	name = "yj_iv_caozhen",
	real_name = "caozhen",
	translation = "曹真",
	title = "荷国天督",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "世外高v狼",
	cv = "",
	illustrator = "Thinking",
	skills = SiDi,
	last_word = "秋雨凄迷，军心易乱……",
	resource = "caozhen",
}
--[[****************************************************************
	称号：万世臣表
	武将：陈群
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：定品
	描述：出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行判定：若结果为黑色，该角色摸X张牌，且你本阶段不能对该角色发动“定品”；红色，你将武将牌翻面。（X为该角色已损失的体力值）
]]--
DingPin = sgs.CreateLuaSkill{
	name = "yj4DingPin",
	translation = "定品",
	description = "出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行判定：若结果为黑色，该角色摸X张牌，且你本阶段不能对该角色发动“定品”；红色，你将武将牌翻面。（X为该角色已损失的体力值）",
	audio = {},
}
--[[
	技能：法恩
	描述：每当一名角色的武将牌翻面或横置时，你可以令其摸一张牌。
]]--
FaEn = sgs.CreateLuaSkill{
	name = "yj4FaEn",
	translation = "法恩",
	description = "每当一名角色的武将牌翻面或横置时，你可以令其摸一张牌。",
	audio = {},
}
--武将信息：陈群
ChenQun = sgs.CreateLuaGeneral{
	name = "yj_iv_chenqun",
	real_name = "chenqun",
	translation = "陈群",
	title = "万世臣表",
	kingdom = "wei",
	maxhp = 3,
	order = 4,
	designer = "To Joanna",
	cv = "",
	illustrator = "DH",
	skills = {DingPin, FaEn},
	last_word = "吾身虽殒，典律昭昭。",
	resource = "chenqun",
}
--[[****************************************************************
	称号：庙堂的玉磬
	武将：顾雍
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：慎行
	描述：出牌阶段，你可以弃置两张牌：若如此做，你摸一张牌。
]]--
ShenXing = sgs.CreateLuaSkill{
	name = "yj4ShenXing",
	translation = "慎行",
	description = "出牌阶段，你可以弃置两张牌：若如此做，你摸一张牌。",
	audio = {},
}
--[[
	技能：秉壹
	描述：结束阶段开始时，若你有手牌，你可以展示所有手牌：若均为同一颜色，你可以令至多X名角色各摸一张牌。（X为你的手牌数）
]]--
BingYi = sgs.CreateLuaSkill{
	name = "yj4BingYi",
	translation = "秉壹",
	description = "结束阶段开始时，若你有手牌，你可以展示所有手牌：若均为同一颜色，你可以令至多X名角色各摸一张牌。（X为你的手牌数）",
	audio = {},
}
--武将信息：顾雍
GuYong = sgs.CreateLuaGeneral{
	name = "yj_iv_guyong",
	real_name = "guyong",
	translation = "顾雍",
	title = "庙堂的玉磬",
	kingdom = "wu",
	maxhp = 3,
	order = 4,
	designer = "睿笛终落",
	cv = "",
	illustrator = "大佬荣",
	skills = {ShenXing, BingYi},
	last_word = "病躯渐重，国事难安。",
	resource = "guyong",
}
--[[****************************************************************
	称号：中军之主
	武将：韩浩史涣
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：慎断
	描述：每当你的黑色基本牌因弃置而置入弃牌堆时，你可以将之当【兵粮寸断】使用（无距离限制）。
]]--
ShenDuan = sgs.CreateLuaSkill{
	name = "yj4ShenDuan",
	translation = "慎断",
	description = "每当你的黑色基本牌因弃置而置入弃牌堆时，你可以将之当【兵粮寸断】使用（无距离限制）。",
	audio = {},
}
--[[
	技能：勇略
	描述：每当你攻击范围内的一名角色的判定阶段开始时，你可以弃置其判定区的一张牌：若如此做，视为对该角色使用一张【杀】（无距离限制）：若此【杀】未造成伤害，此【杀】结算后你摸一张牌。
]]--
YongLve = sgs.CreateLuaSkill{
	name = "yj4YongLve",
	translation = "勇略",
	description = "每当你攻击范围内的一名角色的判定阶段开始时，你可以弃置其判定区的一张牌：若如此做，视为对该角色使用一张【杀】（无距离限制）：若此【杀】未造成伤害，此【杀】结算后你摸一张牌。",
	audio = {},
}
--武将信息：韩浩史涣
HanHaoShiHuan = sgs.CreateLuaGeneral{
	name = "yj_iv_hanhaoshihuan",
	real_name = "hanhaoshihuan",
	translation = "韩浩史涣",
	title = "中军之主",
	kingdom = "wei",
	maxhp = 4,
	order = 6,
	crowded = true,
	designer = "浪人兵法家",
	cv = "",
	illustrator = "L",
	skills = {ShenDuan, YongLve},
	last_word = "那拈弓搭箭的将军……是何人？",
	resource = "hanhaoshihuan",
}
--[[****************************************************************
	称号：监军谋国
	武将：沮授
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：渐营
	描述：每当你于出牌阶段内使用一张牌时，若此牌与你本阶段使用的上一张牌花色或点数相同，你可以摸一张牌。
]]--
JianYing = sgs.CreateLuaSkill{
	name = "yj4JianYing",
	translation = "渐营",
	description = "每当你于出牌阶段内使用一张牌时，若此牌与你本阶段使用的上一张牌花色或点数相同，你可以摸一张牌。",
	audio = {},
}
--[[
	技能：矢北（锁定技）
	描述：每当你于一名角色的回合内受到伤害后，若为你本回合第一次受到伤害，你回复1点体力，否则你失去1点体力。
]]--
ShiBei = sgs.CreateLuaSkill{
	name = "yj4ShiBei",
	translation = "矢北",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你于一名角色的回合内受到伤害后，若为你本回合第一次受到伤害，你回复1点体力，否则你失去1点体力。",
	audio = {},
}
--武将信息：沮授
JvShou = sgs.CreateLuaGeneral{
	name = "yj_iv_jvshou",
	real_name = "jvshou",
	translation = "沮授",
	title = "监军谋国",
	kingdom = "qun",
	maxhp = 3,
	order = 7,
	designer = "精精神神",
	cv = "",
	illustrator = "酱油之神",
	skills = {JianYing, ShiBei},
	last_word = "志士凋亡，河北哀矣……",
	resource = "jvshou",
}
--[[****************************************************************
	称号：为虎作伥
	武将：孙鲁班
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：谮毁（阶段技）
	描述：每当你于出牌阶段内使用【杀】或黑色非延时类锦囊牌指定唯一目标时，你可以令为此牌合法目标的另一名其他角色选择一项：交给你一张牌并成为此牌的使用者，或成为此牌的目标。
]]--
ZenHui = sgs.CreateLuaSkill{
	name = "yj4ZenHui",
	translation = "谮毁",
	description = "<font color=\"green\"><b>阶段技</b></font>，每当你于出牌阶段内使用【杀】或黑色非延时类锦囊牌指定唯一目标时，你可以令为此牌合法目标的另一名其他角色选择一项：交给你一张牌并成为此牌的使用者，或成为此牌的目标。",
	audio = {},
}
--[[
	技能：骄矜
	描述：每当你受到男性角色的伤害时，你可以弃置一张装备牌：若如此做，此伤害-1。
]]--
JiaoJin = sgs.CreateLuaSkill{
	name = "yj4JiaoJin",
	translation = "骄矜",
	description = "每当你受到男性角色的伤害时，你可以弃置一张装备牌：若如此做，此伤害-1。",
	audio = {},
}
--武将信息：孙鲁班
SunLuBan = sgs.CreateLuaGeneral{
	name = "yj_iv_sunluban",
	real_name = "sunluban",
	translation = "孙鲁班",
	title = "为虎作伥",
	kingdom = "wu",
	maxhp = 3,
	female = true,
	order = 2,
	designer = "CatCat44",
	cv = "",
	illustrator = "FOOLTOWN",
	skills = {ZenHui, JiaoJin},
	last_word = "本公主……何罪之有？",
	resource = "sunluban",
}
--[[****************************************************************
	称号：建兴鞍辔
	武将：吴懿
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：奔袭（锁定技）
	描述：你的回合内，你与其他角色的距离-X。你的回合内，若你与所有其他角色距离均为1，其他角色的防具无效，你使用【杀】可以额外选择一个目标。（X为本回合你已使用结算完毕的牌数）
]]--
BenXi = sgs.CreateLuaSkill{
	name = "yj4BenXi",
	translation = "奔袭",
	description = "<fonr color=\"blue\"><b>锁定技</b></font>，你的回合内，你与其他角色的距离-X。你的回合内，若你与所有其他角色距离均为1，其他角色的防具无效，你使用【杀】可以额外选择一个目标。（X为本回合你已使用结算完毕的牌数）",
	audio = {},
}
--武将信息：吴懿
WuYi = sgs.CreateLuaGeneral{
	name = "yj_iv_wuyi",
	real_name = "wuyi",
	translation = "吴懿",
	title = "建兴鞍辔",
	kingdom = "shu",
	maxhp = 4,
	order = 4,
	designer = "沸治克里夫",
	cv = "",
	illustrator = "蚂蚁君",
	skills = BenXi,
	last_word = "奔波已疲，难以……再……战……",
	resource = "wuyi",
}
--[[****************************************************************
	称号：怀璧待凤仪
	武将：张松
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：强识
	描述：出牌阶段开始时，你可以展示一名其他角色的一张手牌：若如此做，每当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。
]]--
QiangZhi = sgs.CreateLuaSkill{
	name = "yj4QiangZhi",
	translation = "强识",
	description = "出牌阶段开始时，你可以展示一名其他角色的一张手牌：若如此做，每当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。",
	audio = {},
}
--[[
	技能：献图
	描述：一名其他角色的出牌阶段开始时，你可以摸两张牌：若如此做，你交给其两张牌；且本阶段结束后，若该角色未于本阶段杀死过一名角色，你失去1点体力。
]]--
XianTu = sgs.CreateLuaSkill{
	name = "yj4XianTu",
	translation = "献图",
	description = "一名其他角色的出牌阶段开始时，你可以摸两张牌：若如此做，你交给其两张牌；且本阶段结束后，若该角色未于本阶段杀死过一名角色，你失去1点体力。",
	audio = {},
}
--武将信息：张松
ZhangSong = sgs.CreateLuaGeneral{
	name = "yj_iv_zhangsong",
	real_name = "zhangsong",
	translation = "张松",
	title = "怀璧待凤仪",
	kingdom = "shu",
	maxhp = 3,
	order = 6,
	designer = "铁血冥剑",
	cv = "",
	illustrator = "尼乐小丑",
	skills = {QiangZhi, XianTu},
	last_word = "皇叔不听吾谏言，悔时晚矣！",
	resource = "zhangsong",
}
--[[****************************************************************
	称号：披肝沥胆
	武将：周仓
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：忠勇
	描述：每当你于出牌阶段内使用【杀】被【闪】抵消后，你可以令除目标角色外的一名角色获得弃牌堆中的此次使用的【闪】：若该角色不为你，你可以对同一目标角色再使用一张【杀】（无距离限制且不能选择额外目标）。
]]--
ZhongYong = sgs.CreateLuaSkill{
	name = "yj4ZhongYong",
	translation = "忠勇",
	description = "每当你于出牌阶段内使用【杀】被【闪】抵消后，你可以令除目标角色外的一名角色获得弃牌堆中的此次使用的【闪】：若该角色不为你，你可以对同一目标角色再使用一张【杀】（无距离限制且不能选择额外目标）。",
	audio = {},
}
--武将信息：周仓
ZhouCang = sgs.CreateLuaGeneral{
	name = "yj_iv_zhoucang",
	real_name = "zhoucang",
	translation = "周仓",
	title = "披肝沥胆",
	kingdom = "shu",
	maxhp = 4,
	order = 3,
	designer = "WOLVES29",
	cv = "",
	illustrator = "Sky",
	skills = ZhongYong,
	last_word = "为将军操刀牵马，此生无憾！",
	resource = "zhoucang",
}
--[[****************************************************************
	称号：中洲拒天人
	武将：朱桓
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：诱敌
	描述：结束阶段开始时，你可以令一名其他角色弃置你一张牌：若此牌不为【杀】，你获得其一张牌。
]]--
YouDi = sgs.CreateLuaSkill{
	name = "yj4YouDi",
	translation = "诱敌",
	description = "结束阶段开始时，你可以令一名其他角色弃置你一张牌：若此牌不为【杀】，你获得其一张牌。",
	audio = {},
}
--武将信息：朱桓
ZhuHuan = sgs.CreateLuaGeneral{
	name = "yj_iv_zhuhuan",
	real_name = "zhuhuan",
	translation = "朱桓",
	title = "中洲拒天人",
	kingdom = "wu",
	maxhp = 4,
	order = 6,
	designer = "半缘修道",
	cv = "",
	illustrator = "XXX",
	skills = YouDi,
	last_word = "这巍巍巨城……吾竟无力撼动……",
	resource = "zhuhuan",
}
--[[****************************************************************
	一将成名2014武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2014",
	translation = "四将成名",
	generals = {
		CaiFuRen, CaoZhen, ChenQun, GuYong, HanHaoShiHuan,
		JvShou, SunLuBan, WuYi, ZhangSong, ZhouCang, ZhuHuan,
	},
}