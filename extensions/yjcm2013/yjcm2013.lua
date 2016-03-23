--[[
	太阳神三国杀武将单挑对战平台·一将成名2013武将包
	武将总数：15
	武将一览：
		1、曹冲（称象、仁心）
		2、伏皇后（惴恐、求援）
		3、郭淮（精策）
		4、关平（龙吟）
		5、简雍（巧说、纵适）
		6、李儒（绝策、灭计、焚城）
		7、刘封（陷嗣）
		8、满宠（峻刑、御策）
		9、潘璋马忠（夺刀、暗箭）
		10、虞翻（纵玄、直言）
		11、朱然（胆守）
		12、曹冲·改（称象、仁心）
		13、伏皇后·改（惴恐、求援）
		14、李儒·改（绝策、灭计、焚城）
		15、朱然·改（胆守）
]]--
--[[****************************************************************
	版本控制
]]--****************************************************************
local old_version = true --原版武将开关，开启后将出现 曹冲、伏皇后、李儒、朱然 四位武将
local new_version = true --新版武将开关，开启后将出现 曹冲·改、伏皇后·改、李儒·改、朱然·改 四位武将
local yjcm2013 = {}
if old_version then
--[[****************************************************************
	称号：仁爱的神童
	武将：曹冲
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：称象
	描述：每当你受到伤害后，你可以亮出牌堆顶的四张牌，然后获得其中至少一张点数之和小于13的牌，并将其余的牌置入弃牌堆。
]]--
ChengXiang = sgs.CreateLuaSkill{
	name = "yj3ChengXiang",
	translation = "称象",
	description = "每当你受到伤害后，你可以亮出牌堆顶的四张牌，然后获得其中至少一张点数之和小于13的牌，并将其余的牌置入弃牌堆。",
	audio = {},
}
--[[
	技能：仁心
	描述：每当一名其他角色处于濒死状态时，若你有手牌，你可以将武将牌翻面并将所有手牌交给该角色：若如此做，该角色回复1点体力。
]]--
RenXin = sgs.CreateLuaSkill{
	name = "yj3RenXin",
	translation = "仁心",
	description = "每当一名其他角色处于濒死状态时，若你有手牌，你可以将武将牌翻面并将所有手牌交给该角色：若如此做，该角色回复1点体力。",
	audio = {},
}
--武将信息：曹冲
CaoChong = sgs.CreateLuaGeneral{
	name = "yj_iii_caochong",
	real_name = "caochong",
	translation = "曹冲",
	title = "仁爱的神童",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	illustrator = "Amo",
	skills = {ChengXiang, RenXin},
	last_word = "子桓哥哥……",
	resource = "caochong_v1",
}
table.insert(yjcm2013, CaoChong)
--[[****************************************************************
	称号：孤注一掷
	武将：伏皇后
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：惴恐
	描述：一名其他角色的回合开始时，若你已受伤，你可以与其拼点：若你赢，该角色跳过出牌阶段；若你没赢，该角色无视与你的距离，直到回合结束。
]]--
ZhuiKong = sgs.CreateLuaSkill{
	name = "yj3ZhuiKong",
	translation = "惴恐",
	description = "一名其他角色的回合开始时，若你已受伤，你可以与其拼点：若你赢，该角色跳过出牌阶段；若你没赢，该角色无视与你的距离，直到回合结束。",
	audio = {},
}
--[[
	技能：求援
	描述：每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的有手牌的其他角色正面朝上交给你一张手牌：若此牌不为【闪】，该角色也成为此【杀】的目标。
]]--
QiuYuan = sgs.CreateLuaSkill{
	name = "yj3QiuYuan",
	translation = "求援",
	description = "每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的有手牌的其他角色正面朝上交给你一张手牌：若此牌不为【闪】，该角色也成为此【杀】的目标。",
	audio = {},
}
--武将信息：伏皇后
FuShou = sgs.CreateLuaGeneral{
	name = "yj_iii_fuhuanghou",
	real_name = "fushou",
	translation = "伏皇后",
	title = "孤注一掷",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 2,
	illustrator = "小莘",
	skills = {ZhuiKong, QiuYuan},
	last_word = "陛下为何不救……臣妾……",
	resource = "fuhuanghou_v1",
}
table.insert(yjcm2013, FuShou)
end
--[[****************************************************************
	称号：垂问秦雍
	武将：郭淮
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：精策
	描述：出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。
]]--
JingCe = sgs.CreateLuaSkill{
	name = "yj3JingCe",
	translation = "精策",
	description = "出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。",
	audio = {},
}
--武将信息：郭淮
GuoHuai = sgs.CreateLuaGeneral{
	name = "yj_iii_guohuai",
	real_name = "guohuai",
	translation = "郭淮",
	title = "垂问秦雍",
	kingdom = "wei",
	maxhp = 4,
	order = 5,
	designer = "雪•五月",
	illustrator = "DH",
	skills = JingCe,
	last_word = "姜维小儿，竟然……",
	resource = "guohuai",
}
table.insert(yjcm2013, GuoHuai)
--[[****************************************************************
	称号：忠臣孝子
	武将：关平
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：龙吟
	描述：每当一名角色于出牌阶段内使用【杀】时，你可以弃置一张牌：若如此做，此【杀】不计入次数限制，若此【杀】为红色，你摸一张牌。
]]--
LongYin = sgs.CreateLuaSkill{
	name = "yj3LongYin",
	translation = "龙吟",
	description = "每当一名角色于出牌阶段内使用【杀】时，你可以弃置一张牌：若如此做，此【杀】不计入次数限制，若此【杀】为红色，你摸一张牌。",
	audio = {},
}
--武将信息：关平
GuanPing = sgs.CreateLuaGeneral{
	name = "yj_iii_guanping",
	real_name = "guanping",
	translation = "关平",
	title = "忠臣孝子",
	kingdom = "shu",
	maxhp = 4,
	order = 2,
	designer = "昂翼天使",
	illustrator = "樱花闪乱",
	skills = LongYin,
	last_word = "父亲快走！孩儿……断后……",
	resource = "guanping",
}
table.insert(yjcm2013, GuanPing)
--[[****************************************************************
	称号：优游风议
	武将：简雍
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：巧说
	描述：出牌阶段开始时，你可以与一名其他角色拼点：若你赢，本回合你使用的下一张基本牌或非延时锦囊牌可以增加一个额外目标（无距离限制）或减少一名目标（若原有至少两名目标）；若你没赢，你不能使用锦囊牌，直到回合结束。
]]--
QiaoShui = sgs.CreateLuaSkill{
	name = "yj3QiaoShui",
	translation = "巧说",
	description = "出牌阶段开始时，你可以与一名其他角色拼点：若你赢，本回合你使用的下一张基本牌或非延时锦囊牌可以增加一个额外目标（无距离限制）或减少一名目标（若原有至少两名目标）；若你没赢，你不能使用锦囊牌，直到回合结束。",
	audio = {},
}
--[[
	技能：纵适
	描述：每当你拼点赢，你可以获得对方的拼点牌。每当你拼点没赢，你可以获得你的拼点牌。
]]--
ZongShi = sgs.CreateLuaSkill{
	name = "yj3ZongShi",
	translation = "纵适",
	description = "每当你拼点赢，你可以获得对方的拼点牌。每当你拼点没赢，你可以获得你的拼点牌。",
	audio = {},
}
--武将信息：简雍
JianYong = sgs.CreateLuaGeneral{
	name = "yj_iii_jianyong",
	real_name = "jianyong",
	translation = "简雍",
	title = "优游风议",
	kingdom = "shu",
	maxhp = 3,
	order = 4,
	designer = "Nocihoo",
	illustrator = "Thinking",
	skills = {QiaoShui, ZongShi},
	last_word = "诶诶……两国交战，不斩……",
	resource = "jianyong",
}
table.insert(yjcm2013, JianYong)
if old_version then
--[[****************************************************************
	称号：魔仕
	武将：李儒
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝策
	描述：你的回合内，一名体力值大于0的角色失去最后的手牌后，你可以对其造成1点伤害。
]]--
JueCe = sgs.CreateLuaSkill{
	name = "yj3JueCe",
	translation = "绝策",
	description = "你的回合内，一名体力值大于0的角色失去最后的手牌后，你可以对其造成1点伤害。",
	audio = {},
}
--[[
	技能：灭计（锁定技）
	描述：你使用黑色非延时锦囊牌的目标数上限至少为二。
]]--
MieJi = sgs.CreateLuaSkill{
	name = "yj3MieJi",
	translation = "灭计",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你使用黑色非延时锦囊牌的目标数上限至少为二。",
	audio = {},
}
--[[
	技能：焚城（限定技）
	描述：出牌阶段，你可以令所有其他角色弃置X张牌，否则你对该角色造成1点火焰伤害。（X为该角色装备区牌的数量且至少为1）
]]--
FenCheng = sgs.CreateLuaSkill{
	name = "yj3FenCheng",
	translation = "焚城",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以令所有其他角色弃置X张牌，否则你对该角色造成1点火焰伤害。（X为该角色装备区牌的数量且至少为1）",
	audio = {},
}
--武将信息：李儒
LiRu = sgs.CreateLuaGeneral{
	name = "yj_iii_liru",
	real_name = "liru",
	translation = "李儒",
	title = "魔仕",
	kingdom = "qun",
	maxhp = 3,
	order = 3,
	illustrator = "MSNZero",
	skills = {JueCe, MieJi, FenCheng},
	last_word = "如遇明主，大业必成……",
	resource = "liru_v1",
}
table.insert(yjcm2013, LiRu)
end
--[[****************************************************************
	称号：骑虎之殇
	武将：刘封
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：陷嗣
	描述：准备阶段开始时，你可以将一至两名角色的各一张牌置于你的武将牌上，称为“逆”。其他角色可以将两张“逆”置入弃牌堆，视为对你使用一张【杀】（计入次数限制）。
]]--
XianSi = sgs.CreateLuaSkill{
	name = "yj3XianSi",
	translation = "陷嗣",
	description = "准备阶段开始时，你可以将一至两名角色的各一张牌置于你的武将牌上，称为“逆”。其他角色可以将两张“逆”置入弃牌堆，视为对你使用一张【杀】（计入次数限制）。",
	audio = {},
}
--武将信息：刘封
LiuFeng = sgs.CreateLuaGeneral{
	name = "yj_iii_liufeng",
	real_name = "liufeng",
	translation = "刘封",
	title = "骑虎之殇",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "香蒲神殇",
	illustrator = "Thinking",
	skills = XianSi,
	last_word = "父亲！为什么？！……",
	resource = "liufeng",
}
table.insert(yjcm2013, LiuFeng)
--[[****************************************************************
	称号：政法兵谋
	武将：满宠
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：峻刑（阶段技）
	描述：你可以弃置任意数量的手牌并选择一名其他角色：若如此做，该角色须弃置一张与你弃置的牌类型均不同的手牌，否则将武将牌翻面并摸X张牌。（X为你弃置的牌的数量）
]]--
JunXing = sgs.CreateLuaSkill{
	name = "yj3JunXing",
	translation = "峻刑",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置任意数量的手牌并选择一名其他角色：若如此做，该角色须弃置一张与你弃置的牌类型均不同的手牌，否则将武将牌翻面并摸X张牌。（X为你弃置的牌的数量）",
	audio = {},
}
--[[
	技能：御策
	描述：每当你受到伤害后，你可以展示一张手牌：若如此做且此伤害有来源，伤害来源须弃置一张与此牌类型不同的手牌，否则你回复1点体力。
]]--
YuCe = sgs.CreateLuaSkill{
	name = "yj3YuCe",
	translation = "御策",
	description = "每当你受到伤害后，你可以展示一张手牌：若如此做且此伤害有来源，伤害来源须弃置一张与此牌类型不同的手牌，否则你回复1点体力。",
	audio = {},
}
--武将信息：满宠
ManChong = sgs.CreateLuaGeneral{
	name = "yj_iii_manchong",
	real_name = "manchong",
	translation = "满宠",
	title = "政法兵谋",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "SamRosen",
	illustrator = "Aimer彩三",
	skills = {JunXing, YuCe},
	last_word = "援军……为何迟迟未到？！……",
	resource = "manchong",
}
table.insert(yjcm2013, ManChong)
--[[****************************************************************
	称号：擒龙伏虎
	武将：潘璋马忠
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：夺刀
	描述：每当你受到【杀】的伤害后，你可以弃置一张牌：若如此做，你获得伤害来源装备区的武器牌。
]]--
DuoDao = sgs.CreateLuaSkill{
	name = "yj3DuoDao",
	translation = "夺刀",
	description = "每当你受到【杀】的伤害后，你可以弃置一张牌：若如此做，你获得伤害来源装备区的武器牌。",
	audio = {},
}
--[[
	技能：暗箭
	描述：每当你使用【杀】对目标角色造成伤害时，若你不在其攻击范围内，此伤害+1。
]]--
AnJian = sgs.CreateLuaSkill{
	name = "yj3AnJian",
	translation = "暗箭",
	description = "每当你使用【杀】对目标角色造成伤害时，若你不在其攻击范围内，此伤害+1。",
	audio = {},
}
--武将信息：潘璋马忠
PanZhangMaZhong = sgs.CreateLuaGeneral{
	name = "yj_iii_panzhangmazhong",
	real_name = "panzhangmazhong",
	translation = "潘璋马忠",
	title = "擒龙伏虎",
	kingdom = "wu",
	maxhp = 4,
	order = 3,
	crowded = true,
	designer = "風残葉落",
	illustrator = "zzyzzyy",
	skills = {DuoDao, AnJian},
	last_word = "怎么可能，我明明亲手将你……",
	resource = "panzhangmazhong",
}
table.insert(yjcm2013, PanZhangMaZhong)
--[[****************************************************************
	称号：狂直之士
	武将：虞翻
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：纵玄
	描述：当你的牌因弃置而置入弃牌堆时，你可以将其中至少一张牌依次置于牌堆顶。
]]--
ZongXuan = sgs.CreateLuaSkill{
	name = "yj3ZongXuan",
	translation = "纵玄",
	description = "当你的牌因弃置而置入弃牌堆时，你可以将其中至少一张牌依次置于牌堆顶。",
	audio = {},
}
--[[
	技能：直言
	描述：结束阶段开始时，你可以令一名角色摸一张牌并展示之：若此牌为装备牌，该角色回复1点体力，然后使用之。
]]--
ZhiYan = sgs.CreateLuaSkill{
	name = "yj3ZhiYan",
	translation = "直言",
	description = "结束阶段开始时，你可以令一名角色摸一张牌并展示之：若此牌为装备牌，该角色回复1点体力，然后使用之。",
	audio = {},
}
--武将信息：虞翻
YuFan = sgs.CreateLuaGeneral{
	name = "yj_iii_yufan",
	real_name = "yufan",
	translation = "虞翻",
	title = "狂直之士",
	kingdom = "wu",
	maxhp = 3,
	order = 7,
	designer = "幻岛",
	illustrator = "L",
	skills = {ZongXuan, ZhiYan},
	last_word = "我枉称……东方朔再世……",
	resource = "yufan",
}
table.insert(yjcm2013, YuFan)
if old_version then
--[[****************************************************************
	称号：不动之督
	武将：朱然
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：胆守
	描述：每当你造成伤害后，你可以摸一张牌，然后结束当前回合并结束一切结算。
]]--
DanShou = sgs.CreateLuaSkill{
	name = "yj3DanShou",
	translation = "胆守",
	description = "每当你造成伤害后，你可以摸一张牌，然后结束当前回合并结束一切结算。",
	audio = {},
}
--武将信息：朱然
ZhuRan = sgs.CreateLuaGeneral{
	name = "yj_iii_zhuran",
	real_name = "zhuran",
	translation = "朱然",
	title = "不动之督",
	kingdom = "wu",
	maxhp = 4,
	order = 5,
	illustrator = "Ccat",
	skills = DanShou,
	last_word = "何人……竟有如此之胆？！……",
	resource = "zhuran_v1",
}
table.insert(yjcm2013, ZhuRan)
end
if new_version then
--[[****************************************************************
	称号：仁爱的神童
	武将：曹冲·改
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：称象
	描述：每当你受到伤害后，你可以亮出牌堆顶的四张牌，然后获得其中至少一张点数之和小于或等于13的牌，并将其余的牌置入弃牌堆。
]]--
ChengXiang = sgs.CreateLuaSkill{
	name = "yj3xChengXiang",
	translation = "称象",
	description = "每当你受到伤害后，你可以亮出牌堆顶的四张牌，然后获得其中至少一张点数之和小于或等于13的牌，并将其余的牌置入弃牌堆。",
	audio = {},
}
--[[
	技能：仁心
	描述：每当一名体力值为1的其他角色受到伤害时，你可以将武将牌翻面并弃置一张装备牌：若如此做，防止此伤害。
]]--
RenXin = sgs.CreateLuaSkill{
	name = "yj3xRenXin",
	translation = "仁心",
	description = "每当一名体力值为1的其他角色受到伤害时，你可以将武将牌翻面并弃置一张装备牌：若如此做，防止此伤害。",
	audio = {},
}
--武将信息：曹冲·改
CaoChong = sgs.CreateLuaGeneral{
	name = "yj_iii_new_caochong",
	real_name = "caochong",
	translation = "曹冲·改",
	show_name = "曹冲",
	title = "仁爱的神童",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	illustrator = "Amo",
	skills = {ChengXiang, RenXin},
	last_word = "子桓哥哥……",
	resource = "caochong_v2",
}
table.insert(yjcm2013, CaoChong)
--[[****************************************************************
	称号：孤注一掷
	武将：伏皇后·改
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：惴恐
	描述：一名其他角色的回合开始时，若你已受伤，你可以与其拼点：若你赢，本回合该角色使用牌不能选择除该角色外的角色为目标；若你没赢，该角色无视与你的距离，直到回合结束。
]]--
ZhuiKong = sgs.CreateLuaSkill{
	name = "yj3xZhuiKong",
	translation = "惴恐",
	description = "一名其他角色的回合开始时，若你已受伤，你可以与其拼点：若你赢，本回合该角色使用牌不能选择除该角色外的角色为目标；若你没赢，该角色无视与你的距离，直到回合结束。",
	audio = {},
}
--[[
	技能：求援
	描述：每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的的其他角色交给你一张【闪】，否则该角色也成为此【杀】的目标。
]]--
QiuYuan = sgs.CreateLuaSkill{
	name = "yj3xQiuYuan",
	translation = "求援",
	description = "每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的的其他角色交给你一张【闪】，否则该角色也成为此【杀】的目标。",
	audio = {},
}
--武将信息：伏皇后·改
FuShou = sgs.CreateLuaGeneral{
	name = "yj_iii_new_fuhuanghou",
	real_name = "fushou",
	translation = "伏皇后·改",
	show_name = "伏皇后",
	title = "孤注一掷",
	kingdom = "qun",
	maxhp = 3,
	female = true,
	order = 2,
	illustrator = "小莘",
	skills = {ZhuiKong, QiuYuan},
	last_word = "陛下为何不救……臣妾……",
	resource = "fuhuanghou_v2",
}
table.insert(yjcm2013, FuShou)
--[[****************************************************************
	称号：魔仕
	武将：李儒·改
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝策
	描述：结束阶段开始时，你可以对一名没有手牌的角色造成1点伤害。
]]--
JueCe = sgs.CreateLuaSkill{
	name = "yj3xJueCe",
	translation = "绝策",
	description = "结束阶段开始时，你可以对一名没有手牌的角色造成1点伤害。",
	audio = {},
}
--[[
	技能：灭计（阶段技）
	描述：你可以将一张黑色锦囊牌置于牌堆顶并选择一名有手牌的其他角色，该角色弃置一张锦囊牌，否则弃置两张非锦囊牌。
]]--
MieJi = sgs.CreateLuaSkill{
	name = "yj3xMieJi",
	translation = "灭计",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张黑色锦囊牌置于牌堆顶并选择一名有手牌的其他角色，该角色弃置一张锦囊牌，否则弃置两张非锦囊牌。",
	audio = {},
}
--[[
	技能：焚城（限定技）
	描述：出牌阶段，你可以令所有其他角色：弃置至少X张牌，否则受到2点火焰伤害。（X为上一名进行选择的角色以此法弃置的牌数+1）
]]--
FenCheng = sgs.CreateLuaSkill{
	name = "yj3xFenCheng",
	translation = "焚城",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以令所有其他角色：弃置至少X张牌，否则受到2点火焰伤害。（X为上一名进行选择的角色以此法弃置的牌数+1）",
	audio = {},
}
--武将信息：李儒·改
LiRu = sgs.CreateLuaGeneral{
	name = "yj_iii_new_liru",
	real_name = "liru",
	translation = "李儒·改",
	show_name = "李儒",
	title = "魔仕",
	kingdom = "qun",
	maxhp = 3,
	order = 3,
	illustrator = "MSNZero",
	skills = {JueCe, MieJi, FenCheng},
	last_word = "如遇明主，大业必成……",
	resource = "liru_v2",
}
table.insert(yjcm2013, LiRu)
--[[****************************************************************
	称号：不动之督
	武将：朱然·改
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：胆守
	描述：出牌阶段，你可以弃置X张牌并选择攻击范围内的一名角色：若X为1，你弃置该角色的一张牌；若X为2，你令该角色交给你一张牌；若X为3，你对该角色造成一点伤害；若X大于或等于4，你与该角色各摸两张牌。（X为本阶段你已发动“胆守”的次数+1）
]]--
DanShou = sgs.CreateLuaSkill{
	name = "yj3xDanShou",
	translation = "胆守",
	description = "出牌阶段，你可以弃置X张牌并选择攻击范围内的一名角色：若X为1，你弃置该角色的一张牌；若X为2，你令该角色交给你一张牌；若X为3，你对该角色造成一点伤害；若X大于或等于4，你与该角色各摸两张牌。（X为本阶段你已发动“胆守”的次数+1）",
	audio = {},
}
--武将信息：朱然·改
ZhuRan = sgs.CreateLuaGeneral{
	name = "yj_iii_new_zhuran",
	real_name = "zhuran",
	translation = "朱然·改",
	show_name = "朱然",
	title = "不动之督",
	kingdom = "wu",
	maxhp = 4,
	order = 6,
	illustrator = "Ccat",
	skills = DanShou,
	last_word = "何人……竟有如此之胆？！……",
	resource = "zhuran_v2",
}
table.insert(yjcm2013, ZhuRan)
end
--[[****************************************************************
	一将成名2013武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2013",
	translation = "三将成名",
	generals = yjcm2013,
}