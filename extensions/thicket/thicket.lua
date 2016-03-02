--[[
	太阳神三国杀武将单挑对战平台·林武将包
	武将总数：8
	武将一览：
		1、徐晃（断粮）
		2、曹丕（行殇、放逐、颂威）
		3、孟获（祸首、再起）
		4、祝融（巨象、烈刃）
		5、孙坚（英魂）
		6、鲁肃（好施、缔盟）
		7、董卓（酒池、肉林、崩坏、暴虐）
		8、贾诩（完杀、乱武、帷幕）
]]--
--[[****************************************************************
	称号：周亚夫之风
	武将：徐晃
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：断粮
	描述：你可以将一张黑色的基本牌或黑色的装备牌当【兵粮寸断】使用。你使用【兵粮寸断】的距离限制为2。
]]--
DuanLiang = sgs.CreateLuaSkill{
	name = "DuanLiang",
	translation = "断粮",
	description = "你可以将一张黑色的基本牌或黑色的装备牌当【兵粮寸断】使用。你使用【兵粮寸断】的距离限制为2。",
	audio = {
		"断汝粮草，以绝后路！",
		"焚其辎重，乱其军心！",
	},
}
--武将信息：徐晃
XuHuang = sgs.CreateLuaGeneral{
	name = "xuhuang",
	translation = "徐晃",
	title = "周亚夫之风",
	kingdom = "wei",
	order = 7,
	cv = "木津川",
	illustrator = "Tuu.",
	skills = DuanLiang,
	last_word = "生遇明主，死亦无憾！",
	resource = "xuhuang",
}
--[[****************************************************************
	称号：霸业的继承者
	武将：曹丕
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：行殇
	描述：每当一名其他角色死亡时，你可以获得该角色的牌。
]]--
XingShang = sgs.CreateLuaSkill{
	name = "XingShang",
	translation = "行殇",
	description = "每当一名其他角色死亡时，你可以获得该角色的牌。",
	audio = {
		"汝妻子吾自养之，汝勿虑也！",
		"珠沉玉殁，其香犹存！",
		"痛神曜之幽浅，哀鼎俎之虚置……",
	},
}
--[[
	技能：放逐
	描述：每当你受到伤害后，你可以令一名其他角色摸X张牌，然后将其武将牌翻面。（X为你已损失的体力值）
]]--
FangZhu = sgs.CreateLuaSkill{
	name = "FangZhu",
	translation = "放逐",
	description = "每当你受到伤害后，你可以令一名其他角色摸X张牌，然后将其武将牌翻面。（X为你已损失的体力值）",
	audio = {
		"罪不至死，赦死从流！",
		"特赦天下，奉旨回京！",
		"本自同根生，相煎何太急？……",
	},
}
--[[
	技能：颂威（主公技）[空壳技能]
	描述：其他魏势力角色的黑色判定牌生效后，该角色可以令你摸一张牌。
]]--
SongWei = sgs.CreateLuaSkill{
	name = "SongWei",
	translation = "颂威",
	description = "<font color=\"yellow\"><b>主公技</b></font>，其他魏势力角色的黑色判定牌生效后，该角色可以令你摸一张牌。",
}
--武将信息：曹丕
CaoPi = sgs.CreateLuaGeneral{
	name = "caopi",
	translation = "曹丕",
	title = "霸业的继承者",
	kingdom = "wei",
	maxhp = 3,
	order = 1,
	cv = "V7，殆尘，烨子，蒲小猫",
	illustrator = "Sonia Tang",
	skills = {XingShang, FangZhu, SongWei},
	last_word = "嗟我白发，生一何早；长吟永叹，怀我圣考……",
	resource = "caopi",
}
--[[****************************************************************
	称号：南蛮王
	武将：孟获
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：祸首（锁定技）
	描述：【南蛮入侵】对你无效。每当一名角色指定【南蛮入侵】的目标后，你成为【南蛮入侵】的伤害来源。
]]--
HuoShou = sgs.CreateLuaSkill{
	name = "HuoShou",
	translation = "祸首",
	description = "<font color=\"blue\"><b>锁定技</b></font>，【南蛮入侵】对你无效。每当一名角色指定【南蛮入侵】的目标后，你成为【南蛮入侵】的伤害来源。",
	audio = "南蛮之地，皆我子民！",
}
--[[
	技能：再起
	描述：摸牌阶段开始时，若你已受伤，你可以放弃摸牌并亮出牌堆顶的X张牌：每有一张红桃牌，你回复1点体力，然后将所有红桃牌置入弃牌堆并获得其余的牌。（X为你已损失的体力值）
]]--
ZaiQi = sgs.CreateLuaSkill{
	name = "ZaiQi",
	translation = "再起",
	description = "摸牌阶段开始时，若你已受伤，你可以放弃摸牌并亮出牌堆顶的X张牌：每有一张红桃牌，你回复1点体力，然后将所有红桃牌置入弃牌堆并获得其余的牌。（X为你已损失的体力值）",
	audio = {
		"吾不服也！",
		"孔明！汝技穷也！",
		"敌军势大，吾先退避……",
	},
}
--武将信息：孟获
MengHuo = sgs.CreateLuaGeneral{
	name = "menghuo",
	translation = "孟获",
	title = "南蛮王",
	kingdom = "shu",
	order = 7,
	cv = "墨染の飞猫",
	illustrator = "废柴男",
	skills = {HuoShou, ZaiQi},
	last_word = "荆民之地，再无主矣！",
	resource = "menghuo",
}
--[[****************************************************************
	称号：野性的女王
	武将：祝融
	势力：蜀
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：巨象（锁定技）
	描述：【南蛮入侵】对你无效。其他角色使用的未转化的【南蛮入侵】在结算完毕后置入弃牌堆时，你获得之。
]]--
JuXiang = sgs.CreateLuaSkill{
	name = "JuXiang",
	translation = "巨象",
	description = "<font color=\"blue\"><b>锁定技</b></font>，【南蛮入侵】对你无效。其他角色使用的未转化的【南蛮入侵】在结算完毕后置入弃牌堆时，你获得之。",
	audio = "万象奔腾，随吾心意！",
}
--[[
	技能：烈刃
	描述：每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。
]]--
LieRen = sgs.CreateLuaSkill{
	name = "LieRen",
	translation = "烈刃",
	description = "每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。",
	audio = {
		"火神降世，燃尽汝躯！",
		"呵呵呵呵~~~~",
		"神不佑我，唉……",
	},
}
--武将信息：祝融
ZhuRong = sgs.CreateLuaGeneral{
	name = "zhurong",
	translation = "祝融",
	title = "野性的女王",
	kingdom = "shu",
	female = true,
	order = 4,
	cv = "妙妙",
	illustrator = "废柴男",
	skills = {JuXiang, LieRen},
	last_word = "大王，火神湮世，妾身去矣！",
	resource = "zhurong",
}
--[[****************************************************************
	称号：武烈帝
	武将：孙坚
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：英魂
	描述：准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）
]]--
YingHun = sgs.CreateLuaSkill{
	name = "YingHun",
	translation = "英魂",
	description = "准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）",
	audio = {
		"同举义兵，勠力一心！",
		"孙文台在此，此贼可诛！",
	},
}
--武将信息：孙坚
SunJian = sgs.CreateLuaGeneral{
	name = "sunjian",
	translation = "孙坚",
	title = "武烈帝",
	kingdom = "wu",
	order = 6,
	cv = "木津川",
	illustrator = "LiuHeng",
	skills = YingHun,
	last_word = "死去何愁无勇将，英魂依旧卫江东……",
	resource = "sunjian",
}
--[[****************************************************************
	称号：独断的外交家
	武将：鲁肃
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：好施
	描述：摸牌阶段，你可以额外摸两张牌：若你拥有五张或更多的手牌，你将一半数量（向下取整）的手牌交给除你外场上手牌数最少的一名角色。
]]--
HaoShi = sgs.CreateLuaSkill{
	name = "HaoShi",
	translation = "好施",
	description = "摸牌阶段，你可以额外摸两张牌：若你拥有五张或更多的手牌，你将一半数量（向下取整）的手牌交给除你外场上手牌数最少的一名角色。",
	audio = "公瑾莫忧，吾有余粮。",
}
--[[
	技能：缔盟（阶段技）[空壳技能]
	描述：你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。
]]--
DiMeng = sgs.CreateLuaSkill{
	name = "DiMeng",
	translation = "缔盟",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。",
}
--武将信息：鲁肃
LuSu = sgs.CreateLuaGeneral{
	name = "lusu",
	translation = "鲁肃",
	title = "独断的外交家",
	kingdom = "wu",
	maxhp = 3,
	order = 3,
	cv = "听雨",
	illustrator = "LiuHeng",
	skills = {HaoShi, DiMeng},
	last_word = "荆湘未还，虽死难安……",
	resource = "lusu",
}
--[[****************************************************************
	称号：魔王
	武将：董卓
	势力：群
	性别：男
	体力上限：8勾玉
]]--****************************************************************
--[[
	技能：酒池
	描述：你可以将一张黑桃手牌当【酒】使用。
]]--
--[[
	技能：肉林（锁定技）
	描述：每当你指定女性角色为【杀】的目标后，或成为女性角色的【杀】的目标后，目标角色须连续使用两张【闪】抵消此【杀】。
]]--
--[[
	技能：崩坏（锁定技）
	描述：结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。
]]--
BengHuai = sgs.CreateLuaSkill{
	name = "BengHuai",
	translation = "崩坏",
	description = "<font color=\"blue\"><b>锁定技</b></font>，结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。",
	audio = {
		"不朽之躯，天却亡我！",
		"呃！不！不可以的！……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local hp = player:getHp()
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			local minflag = true
			for _,p in sgs.qlist(others) do
				if p:getHp() < hp then
					minflag = false
					break
				end
			end
			if minflag then
				return false
			end
			local choice = room:askForChoice(player, "BengHuai", "hp+maxhp")
			if player:isFemale() then
				room:broadcastSkillInvoke("BengHuai", 2)
			else
				room:broadcastSkillInvoke("BengHuai", 1)
			end
			if choice == "hp" then
				room:loseHp(player)
			elseif choice == "maxhp" then
				room:loseMaxHp(player)
			end
		end
		return false
	end,
}
--[[
	技能：暴虐（主公技）[空壳技能]
	描述：其他群雄角色造成伤害后，该角色可以进行判定：若结果为黑桃，你回复1点体力。
]]--
--武将信息：董卓
DongZhuo = sgs.CreateLuaGeneral{
	name = "dongzhuo",
	translation = "董卓",
	title = "魔王",
	kingdom = "qun",
	maxhp = 8,
	order = 4,
	cv = "やまもとみ，迷宫女友(肉林2)",
	illustrator = "小冷",
	skills = {"jiuchi", "roulin", BengHuai, "baonue"},
	last_word = "吾儿奉先何在？呃……",
	resource = "dongzhuo",
}
--[[****************************************************************
	称号：冷酷的毒士
	武将：贾诩
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：完杀（锁定技）[空壳技能]
	描述：你的回合内，除濒死角色外的其他角色不能使用【桃】。
]]--
--[[
	技能：乱武（限定技）
	描述：出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。
]]--
LuanWuCard = sgs.CreateSkillCard{
	name = "LuanWuCard",
	skill_name = "LuanWu",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		source:loseMark("@chaos")
		local others = room:getOtherPlayers(source)
		for _,target in sgs.qlist(others) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local minDist = 999
		local me = effect.to
		local room = me:getRoom()
		local others = room:getOtherPlayers(me)
		local targets = {}
		for _,p in sgs.qlist(others) do
			local dist = me:distanceTo(p)
			if dist < minDist then
				minDist = dist
				targets = {p}
			elseif dist == minDist then
				table.insert(targets, p)
			end
		end
		local victims = sgs.SPlayerList()
		for _,victim in ipairs(targets) do
			if me:canSlash(victim) then
				victims:append(victim)
			end
		end
		local losehp = true
		if not victims:isEmpty() then
			local slash = room:askForUseSlashTo(me, victims, "@@LuanWu")
			losehp = slash and false or true
		end
		if losehp then
			room:loseHp(me)
		end
	end,
}
LuanWuVS = sgs.CreateLuaSkill{
	name = "LuanWu",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return LuanWuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@chaos") > 0
	end,
}
LuanWu = sgs.CreateLuaSkill{
	name = "LuanWu",
	translation = "乱武",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。",
	audio = "智乱天下，武逆乾坤",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	limit_mark = "@chaos",
	view_as_skill = LuanWuVS,
	translations = {
		["@chaos"] = "乱武",
	},
}
--[[
	技能：帷幕（锁定技）
	描述：你不能被选择为黑色锦囊牌的目标。
]]--
WeiMu = sgs.CreateLuaSkill{
	name = "WeiMu",
	translation = "帷幕",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你不能被选择为黑色锦囊牌的目标。",
	audio = {
		"巧变制敌，谋定而动",
		"算无遗策，不动如山",
	},
	class = "ProhibitSkill",
	is_prohibited = function(self, from, to, card, others)
		if to:hasSkill("WeiMu") then
			return card:isBlack() and card:isKindOf("TrickCard")
		end
		return false
	end,
}
--武将信息：贾诩
JiaXu = sgs.CreateLuaGeneral{
	name = "jiaxu",
	translation = "贾诩",
	title = "冷酷的毒士",
	kingdom = "qun",
	maxhp = 3,
	order = 3,
	cv = "落凤一箭",
	skills = {"wansha", LuanWu, WeiMu},
	last_word = "大势已去，吾不能自保矣……",
	resource = "jiaxu",
	marks = {"@chaos"},
}
--[[****************************************************************
	林武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "thicket",
	translation = "林包",
	generals = {
		XuHuang, CaoPi, MengHuo, ZhuRong, SunJian, LuSu, DongZhuo, JiaXu,
	},
}