--[[
	太阳神三国杀武将单挑对战平台·一将成名2012武将包
	武将总数：15
	武将一览：
		1、步练师（安恤、追忆）
		2、曹彰（将驰）
		3、程普（疠火、醇酪）
		4、关兴张苞（父魂）+（武圣、咆哮）
		5、韩当（弓骑、解烦）
		6、华雄（恃勇）
		7、廖化（当先、伏枥）
		8、刘表（自守、宗室）
		9、马岱（马术、潜袭）
		10、王异（贞烈、秘计）
		11、荀攸（奇策、智愚）
		12、关兴张苞·改（父魂）+（武圣、咆哮）
		13、韩当·改（弓骑、解烦）
		14、马岱·改（马术、潜袭）
		15、王异·改（贞烈、秘计）
]]--
--[[****************************************************************
	版本控制
]]--****************************************************************
local old_version = true --原版武将开关，开启后将出现 关兴张苞、韩当、马岱、王异 四位武将
local new_version = true --新版武将开关，开启后将出现 关兴张苞·改、韩当·改、马岱·改、王异·改 四位武将
local yjcm2012 = {}
--[[****************************************************************
	称号：无冕之后
	武将：步练师
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：安恤（阶段技）[空壳技能]
	描述：你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为黑桃，你摸一张牌。
]]--
AnXu = sgs.CreateLuaSkill{
	name = "yjiiAnXu",
	translation = "安恤",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为黑桃，你摸一张牌。",
}
--[[
	技能：追忆
	描述：你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。
]]--
ZhuiYi = sgs.CreateLuaSkill{
	name = "yjiiZhuiYi",
	translation = "追忆",
	description = "你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。",
	class = "TriggerSkill",
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local killer = nil
			if death.reason then
				killer = death.reason.from
			end
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			if killer then
				others:removeOne(killer)
			end
			if others:isEmpty() then
				return false
			end
			local target = room:askForPlayerChosen(player, others, "yjiiZhuiYi", "@yjiiZhuiYi", true)
			if target then
				if target:isGeneral("sunquan", true, true) then
					room:broadcastSkillInvoke("yjiiZhuiYi", 2)
				else
					room:broadcastSkillInvoke("yjiiZhuiYi", 1)
				end
				room:drawCards(target, 3, "yjiiZhuiYi")
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(target, recover, true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("yjiiZhuiYi")
	end,
}
--武将信息：步练师
BuLianShi = sgs.CreateLuaGeneral{
	name = "yj_ii_bulianshi",
	real_name = "bulianshi",
	translation = "步练师",
	title = "无冕之后",
	kingdom = "wu",
	maxhp = 3,
	order = 1,
	designer = "Anais",
	cv = "蒲小猫",
	illustrator = "勺子妞",
	skills = {AnXu, ZhuiYi},
	last_word = "陛下，今生情未了，来世再侍君。",
	resource = "bulianshi",
}
table.insert(yjcm2012, BuLianShi)
--[[****************************************************************
	称号：黄须儿
	武将：曹彰
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：将驰
	描述：摸牌阶段，你可以选择一项：1.少摸一张牌，然后本回合，你使用【杀】无距离限制，你可以额外使用一张【杀】；2.额外摸一张牌，且你不能使用或打出【杀】，直到回合结束。
]]--
JiangChi = sgs.CreateLuaSkill{
	name = "yj2JiangChi",
	translation = "将驰",
	description = "摸牌阶段，你可以选择一项：1.少摸一张牌，然后本回合，你使用【杀】无距离限制，你可以额外使用一张【杀】；2.额外摸一张牌，且你不能使用或打出【杀】，直到回合结束。",
	audio = {},
}
--武将信息：曹彰
CaoZhang = sgs.CreateLuaGeneral{
	name = "yj_ii_caozhang",
	real_name = "caozhang",
	translation = "曹彰",
	title = "黄须儿",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "潜龙勿用",
	cv = "墨宣砚韵",
	illustrator = "Yi章",
	skills = JiangChi,
	last_word = "难成卫霍之功，恨矣悲哉！",
	resource = "caozhang",
}
table.insert(yjcm2012, CaoZhang)
--[[****************************************************************
	称号：三朝虎臣
	武将：程普
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：疠火
	描述：你可以将一张普通【杀】当火【杀】使用。你以此法使用【杀】结算后，若此【杀】造成了伤害，你失去1点体力。你使用火【杀】可以额外选择一名目标。
]]--
LiHuo = sgs.CreateLuaSkill{
	name = "yj2LiHuo",
	translation = "疠火",
	description = "你可以将一张普通【杀】当火【杀】使用。你以此法使用【杀】结算后，若此【杀】造成了伤害，你失去1点体力。你使用火【杀】可以额外选择一名目标。",
	audio = {},
}
--[[
	技能：醇酪
	描述：结束阶段开始时，若你的武将牌上没有“醇”，你可以将至少一张【杀】置于武将牌上，称为“醇”。每当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。
]]--
ChunLao = sgs.CreateLuaSkill{
	name = "yj2ChunLao",
	translation = "醇酪",
	description = "结束阶段开始时，若你的武将牌上没有“醇”，你可以将至少一张【杀】置于武将牌上，称为“醇”。每当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。",
	audio = {},
}
--武将信息：程普
ChengPu = sgs.CreateLuaGeneral{
	name = "yj_ii_chengpu",
	real_name = "chengpu",
	translation = "程普",
	title = "三朝虎臣",
	kingdom = "wu",
	maxhp = 4,
	order = 3,
	designer = "Michael_Lee",
	cv = "风叹息",
	illustrator = "G.G.G.",
	skills = {LiHuo, ChunLao},
	last_word = "不曾枉杀人，为何……折我寿！",
	resource = "chengpu",
}
table.insert(yjcm2012, ChengPu)
if old_version then
--[[****************************************************************
	称号：将门虎子
	武将：关兴张苞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：父魂
	描述：摸牌阶段开始时，你可以放弃摸牌，亮出牌堆顶的两张牌并获得之：若亮出的牌不为同一颜色，你拥有“武圣”、“咆哮”，直到回合结束。
]]--
FuHun = sgs.CreateLuaSkill{
	name = "yj2FuHun",
	translation = "父魂",
	description = "摸牌阶段开始时，你可以放弃摸牌，亮出牌堆顶的两张牌并获得之：若亮出的牌不为同一颜色，你拥有“武圣”、“咆哮”，直到回合结束。",
	audio = {},
}
--[[
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
--武将信息：关兴张苞
GuanXingZhangBao = sgs.CreateLuaGeneral{
	name = "yj_ii_guanxingzhangbao",
	real_name = "guanxingzhangbao",
	translation = "关兴张苞",
	title = "将门虎子",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	cv = "喵小林，风叹息",
	illustrator = "HOOO",
	skills = FuHun,
	related_skills = {"WuSheng", "paoxiao"},
	last_word = "东吴未灭、父仇未报！可恨……可恨！",
	resource = "guanxingzhangbao_v1",
}
table.insert(yjcm2012, GuanXingZhangBao)
--[[****************************************************************
	称号：石城侯
	武将：韩当
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：弓骑
	描述：你可以将一张装备牌当【杀】使用或打出。你以此法使用的【杀】无距离限制。
]]--
GongQi = sgs.CreateLuaSkill{
	name = "yj2GongQi",
	translation = "弓骑",
	description = "你可以将一张装备牌当【杀】使用或打出。你以此法使用的【杀】无距离限制。",
	audio = {},
}
--[[
	技能：解烦
	描述：你的回合外，每当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】：若此【杀】造成伤害，造成伤害时防止此伤害，视为对该濒死角色使用了一张【桃】。
]]--
JieFan = sgs.CreateLuaSkill{
	name = "yj2JieFan",
	translation = "解烦",
	description = "你的回合外，每当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】：若此【杀】造成伤害，造成伤害时防止此伤害，视为对该濒死角色使用了一张【桃】。",
	audio = {},
}
--武将信息：韩当
HanDang = sgs.CreateLuaGeneral{
	name = "yj_ii_handang",
	real_name = "handang",
	translation = "韩当",
	title = "石城侯",
	kingdom = "wu",
	maxhp = 4,
	order = 5,
	cv = "风叹息",
	illustrator = "DH",
	skills = {GongQi, JieFan},
	last_word = "我主堪忧，我主堪忧啊……",
	resource = "handang_v1",
}
table.insert(yjcm2012, HanDang)
end
--[[****************************************************************
	称号：魔将
	武将：华雄
	势力：群
	性别：男
	体力上限：6勾玉
]]--****************************************************************
--[[
	技能：恃勇（锁定技）
	描述：每当你受到一次红色【杀】或【酒】【杀】的伤害后，你失去1点体力上限。
]]--
ShiYong = sgs.CreateLuaSkill{
	name = "yj2ShiYong",
	translation = "恃勇",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到一次红色【杀】或【酒】【杀】的伤害后，你失去1点体力上限。",
	audio = {},
}
--武将信息：华雄
HuaXiong = sgs.CreateLuaGeneral{
	name = "yj_ii_huaxiong",
	real_name = "huaxiong",
	translation = "华雄",
	title = "魔将",
	kingdom = "qun",
	maxhp = 6,
	order = 5,
	designer = "小立",
	cv = "玉皇贰弟",
	illustrator = "地狱许",
	skills = ShiYong,
	last_word = "太自负了么……",
	resource = "huaxiong",
}
table.insert(yjcm2012, HuaXiong)
--[[****************************************************************
	称号：历尽沧桑
	武将：廖化
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：当先（锁定技）
	描述：回合开始时，你执行一个额外的出牌阶段。
]]--
DangXian = sgs.CreateLuaSkill{
	name = "yj2DangXian",
	translation = "当先",
	description = "<font color=\"blue\"><b>锁定技</b></font>，回合开始时，你执行一个额外的出牌阶段。",
	audio = {},
}
--[[
	技能：伏枥（限定技）
	描述：每当你处于濒死状态时，你可以将回复至X点体力，然后将武将牌翻面。（X为现存势力数）
]]--
FuLi = sgs.CreateLuaSkill{
	name = "yj2FuLi",
	translation = "伏枥",
	description = "<font color=\"red\"><b>限定技</b></font>，每当你处于濒死状态时，你可以将回复至X点体力，然后将武将牌翻面。（X为现存势力数）",
	audio = {},
}
--武将信息：廖化
LiaoHua = sgs.CreateLuaGeneral{
	name = "yj_ii_liaohua",
	real_name = "liaohua",
	translation = "廖化",
	title = "历尽沧桑",
	kingdom = "shu",
	maxhp = 4,
	order = 3,
	designer = "桃花僧",
	cv = "风叹息",
	illustrator = "天空之城",
	skills = {DangXian, FuLi},
	last_word = "阅尽兴亡，此生无憾矣……",
	resource = "liaohua",
}
table.insert(yjcm2012, LiaoHua)
--[[****************************************************************
	称号：跨蹈汉南
	武将：刘表
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：自守
	描述：摸牌阶段，若你已受伤，你可以额外摸X张牌，然后跳过出牌阶段。（X为你已损失的体力值）
]]--
ZiShou = sgs.CreateLuaSkill{
	name = "yj2ZiShou",
	translation = "自守",
	description = "摸牌阶段，若你已受伤，你可以额外摸X张牌，然后跳过出牌阶段。（X为你已损失的体力值）",
	audio = {},
}
--[[
	技能：宗室（锁定技）
	描述：你的手牌上限+X。（X为现存势力数）
]]--
ZongShi = sgs.CreateLuaSkill{
	name = "yj2ZongShi",
	translation = "宗室",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的手牌上限+X。（X为现存势力数）",
	audio = {},
}
--武将信息：刘表
LiuBiao = sgs.CreateLuaGeneral{
	name = "yj_ii_liubiao",
	real_name = "liubiao",
	translation = "刘表",
	title = "跨蹈汉南",
	kingdom = "qun",
	maxhp = 4,
	order = 6,
	designer = "管乐",
	cv = "喵小林",
	illustrator = "关东煮",
	skills = {ZiShou, ZongShi},
	last_word = "不欲争天下，奈何……",
	resource = "liubiao",
}
table.insert(yjcm2012, LiuBiao)
if old_version then
--[[****************************************************************
	称号：临危受命
	武将：马岱
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：潜袭
	描述：每当你使用【杀】对距离1的目标角色造成伤害时，你可以进行判定：若结果不为红桃，防止此伤害，该角色失去1点体力上限。
]]--
QianXi = sgs.CreateLuaSkill{
	name = "yj2QianXi",
	translation = "潜袭",
	description = "每当你使用【杀】对距离1的目标角色造成伤害时，你可以进行判定：若结果不为红桃，防止此伤害，该角色失去1点体力上限。",
	audio = {},
}
--武将信息：马岱
MaDai = sgs.CreateLuaGeneral{
	name = "yj_ii_madai",
	real_name = "madai",
	translation = "马岱",
	title = "临危受命",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "凌天翼",
	cv = "风叹息",
	illustrator = "大佬荣",
	skills = {"mashu", QianXi},
	last_word = "未能完成丞相遗命，辱没了我马家的威名啊……",
	resource = "madai_v1",
}
table.insert(yjcm2012, MaDai)
--[[****************************************************************
	称号：决意的巾帼
	武将：王异
	势力：魏
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：贞烈
	描述：每当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。
]]--
ZhenLie = sgs.CreateLuaSkill{
	name = "yj2ZhenLie",
	translation = "贞烈",
	description = "每当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。",
	audio = {},
}
--[[
	技能：秘计
	描述：回合开始或结束阶段开始时，若你已受伤，你可以进行判定：若结果为黑色，你观看牌堆顶的X张牌然后将之交给一名角色。（X为你已损失的体力值）
]]--
MiJi = sgs.CreateLuaSkill{
	name = "yj2MiJi",
	translation = "秘计",
	description = "回合开始或结束阶段开始时，若你已受伤，你可以进行判定：若结果为黑色，你观看牌堆顶的X张牌然后将之交给一名角色。（X为你已损失的体力值）",
	audio = {},
}
--武将信息：王异
WangYi = sgs.CreateLuaGeneral{
	name = "yj_ii_wangyi",
	real_name = "wangyi",
	translation = "王异",
	title = "决意的巾帼",
	kingdom = "wei",
	maxhp = 3,
	order = 7,
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {ZhenLie, MiJi},
	last_word = "吾之家仇，何日得报？……",
	resource = "wangyi_v1",
}
table.insert(yjcm2012, WangYi)
end
--[[****************************************************************
	称号：曹魏的谋主
	武将：荀攸
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：奇策（阶段技）
	描述：你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。
]]--
QiCe = sgs.CreateLuaSkill{
	name = "yj2QiCe",
	translation = "奇策",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。",
	audio = {},
}
--[[
	技能：智愚
	描述：每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。
]]--
ZhiYu = sgs.CreateLuaSkill{
	name = "yj2ZhiYu",
	translation = "智愚",
	description = "每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。",
	audio = {},
}
--武将信息：荀攸
XunYou = sgs.CreateLuaGeneral{
	name = "yj_ii_xunyou",
	real_name = "xunyou",
	translation = "荀攸",
	title = "曹魏的谋主",
	kingdom = "wei",
	maxhp = 3,
	order = 8,
	designer = "淬毒",
	cv = "烨子",
	illustrator = "魔鬼鱼",
	skills = {QiCe, ZhiYu},
	last_word = "主公何日再得无忧……",
	resource = "xunyou",
}
table.insert(yjcm2012, XunYou)
if new_version then
--[[****************************************************************
	称号：将门虎子
	武将：关兴张苞·改
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：父魂
	描述：你可以将两张手牌当普通【杀】使用或打出。每当你于出牌阶段内以此法使用【杀】造成伤害后，你拥有“武圣”、“咆哮”，直到回合结束。
]]--
FuHun = sgs.CreateLuaSkill{
	name = "yj2xFuHun",
	translation = "父魂",
	description = "你可以将两张手牌当普通【杀】使用或打出。每当你于出牌阶段内以此法使用【杀】造成伤害后，你拥有“武圣”、“咆哮”，直到回合结束。",
	audio = {},
}
--[[
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
--武将信息：关兴张苞·改
GuanXingZhangBao = sgs.CreateLuaGeneral{
	name = "yj_ii_new_guanxingzhangbao",
	real_name = "guanxingzhangbao",
	translation = "关兴张苞·改",
	show_name = "关兴张苞",
	title = "将门虎子",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	crowded = true,
	cv = "喵小林，风叹息",
	illustrator = "HOOO",
	skills = FuHun,
	related_skills = {"WuSheng", "paoxiao"},
	last_word = "东吴未灭、父仇未报！可恨……可恨！",
	resource = "guanxingzhangbao_v2",
}
table.insert(yjcm2012, GuanXingZhangBao)
--[[****************************************************************
	称号：石城侯
	武将：韩当·改
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：弓骑（阶段技）
	描述：你可以弃置一张牌：若如此做，本回合你的攻击范围无限；若此牌为装备牌，你可以弃置一名其他角色的一张牌。
]]--
GongQi = sgs.CreateLuaSkill{
	name = "yj2xGongQi",
	translation = "弓骑",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置一张牌：若如此做，本回合你的攻击范围无限；若此牌为装备牌，你可以弃置一名其他角色的一张牌。",
	audio = {},
}
--[[
	技能：解烦（限定技）
	描述：出牌阶段，你可以选择一名角色，然后攻击范围内包含该角色的所有角色选择一项：弃置一张武器牌，或令该角色摸一张牌。
]]--
JieFan = sgs.CreateLuaSkill{
	name = "yj2xJieFan",
	translation = "解烦",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以选择一名角色，然后攻击范围内包含该角色的所有角色选择一项：弃置一张武器牌，或令该角色摸一张牌。",
	audio = {},
}
--武将信息：韩当·改
HanDang = sgs.CreateLuaGeneral{
	name = "yj_ii_new_handang",
	real_name = "handang",
	translation = "韩当·改",
	show_name = "韩当",
	title = "石城侯",
	kingdom = "wu",
	maxhp = 4,
	order = 4,
	cv = "风叹息",
	illustrator = "DH",
	skills = {GongQi, JieFan},
	last_word = "我主堪忧，我主堪忧啊……",
	resource = "handang_v2",
}
table.insert(yjcm2012, HanDang)
--[[****************************************************************
	称号：临危受命
	武将：马岱·改
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：潜袭
	描述：准备阶段开始时，你可以进行判定：若如此做，你令一名距离1的角色不能使用或打出与判定牌颜色相同的手牌，直到回合结束。
]]--
QianXi = sgs.CreateLuaSkill{
	name = "yj2xQianXi",
	translation = "潜袭",
	description = "准备阶段开始时，你可以进行判定：若如此做，你令一名距离1的角色不能使用或打出与判定牌颜色相同的手牌，直到回合结束。",
	audio = {},
}
--武将信息：马岱·改
MaDai = sgs.CreateLuaGeneral{
	name = "yj_ii_new_madai",
	real_name = "madai",
	translation = "马岱·改",
	show_name = "马岱",
	title = "临危受命",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "凌天翼",
	cv = "风叹息",
	illustrator = "大佬荣",
	skills = {"mashu", QianXi},
	last_word = "未能完成丞相遗命，辱没了我马家的威名啊……",
	resource = "madai_v2",
}
table.insert(yjcm2012, MaDai)
--[[****************************************************************
	称号：决意的巾帼
	武将：王异·改
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：贞烈
	描述：每当你成为其他角色的【杀】或非延时锦囊牌的目标后，你可以失去1点体力：若如此做，你弃置该角色的一张牌，此牌对你无效。
]]--
ZhenLie = sgs.CreateLuaSkill{
	name = "yj2xZhenLie",
	translation = "贞烈",
	description = "每当你成为其他角色的【杀】或非延时锦囊牌的目标后，你可以失去1点体力：若如此做，你弃置该角色的一张牌，此牌对你无效。",
	audio = {},
}
--[[
	技能：秘计
	描述：结束阶段开始时，若你已受伤，你可以摸至多X张牌，然后将等量的手牌任意分配给其他角色。（X为你已损失的体力值）
]]--
MiJi = sgs.CreateLuaSkill{
	name = "yj2xMiJi",
	translation = "秘计",
	description = "结束阶段开始时，若你已受伤，你可以摸至多X张牌，然后将等量的手牌任意分配给其他角色。（X为你已损失的体力值）",
	audio = {},
}
--武将信息：王异·改
WangYi = sgs.CreateLuaGeneral{
	name = "yj_ii_new_wangyi",
	real_name = "wangyi",
	translation = "王异·改",
	show_name = "王异",
	title = "决意的巾帼",
	kingdom = "wei",
	maxhp = 3,
	female = true,
	order = 2,
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {ZhenLie, MiJi},
	last_word = "吾之家仇，何日得报？……",
	resource = "wangyi_v2",
}
table.insert(yjcm2012, WangYi)
end
--[[****************************************************************
	一将成名2012武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2012",
	translation = "二将成名",
	generals = yjcm2012,
}