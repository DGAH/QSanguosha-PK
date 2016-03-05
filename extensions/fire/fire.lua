--[[
	太阳神三国杀武将单挑对战平台·火武将包
	武将总数：8
	武将一览：
		1、典韦（强袭）
		2、荀彧（驱虎、节命）
		3、庞统（连环、涅槃）
		4、诸葛亮（八阵、火计、看破）
		5、太史慈（天义）
		6、袁绍（乱击、血裔）
		7、颜良文丑（双雄）
		8、庞德（马术、猛进）
]]--
--[[****************************************************************
	称号：古之恶来
	武将：典韦
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：强袭（阶段技）
	描述：你可以失去1点体力或弃置一张武器牌，并选择攻击范围内的一名角色：若如此做，你对该角色造成1点伤害。
]]--
QiangXiCard = sgs.CreateSkillCard{
	name = "QiangXiCard",
	skill_name = "QiangXi",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			local rangefix = 0
			local subcards = self:getSubcards()
			if subcards:length() == 1 then
				local weapon = sgs.Self:getWeapon()
				local card_id = subcards:first()
				if weapon and weapon:getEffectiveId() == card_id then
					weapon = weapon:getRealCard():toWeapon()
					rangefix = weapon:getRange() - sgs.Self:getAttackRange(false)
				end
			end
			return sgs.Self:inMyAttackRange(to_select, rangefix)
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		if self:subcardsLength() == 0 then
			room:loseHp(source)
		end
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = effect.to
		damage.damage = 1
		damage.reason = "QiangXi"
		room:damage(damage)
	end,
}
QiangXi = sgs.CreateLuaSkill{
	name = "QiangXi",
	translation = "强袭",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以失去1点体力或弃置一张武器牌，并选择攻击范围内的一名角色：若如此做，你对该角色造成1点伤害。",
	audio = "五步之内，汝命休矣！",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isKindOf("Weapon") then
			return not sgs.Self:isJilei(to_select)
		end
		return false
	end,
	view_as = function(self, cards)
		local card = QiangXiCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#QiangXiCard")
	end,
}
--武将信息：典韦
DianWei = sgs.CreateLuaGeneral{
	name = "dianwei",
	translation = "典韦",
	title = "古之恶来",
	kingdom = "wei",
	order = 6,
	cv = "褪色",
	illustrator = "小冷",
	skills = QiangXi,
	last_word = "主公……我就到……这儿了……",
	resource = "dianwei",
}
--[[****************************************************************
	称号：王佐之才
	武将：荀彧
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：驱虎（阶段技）
	描述：你可以与一名体力值大于你的角色拼点：若你赢，该角色对其攻击范围内的一名由你选择的角色造成1点伤害；若你没赢，该角色对你造成1点伤害。
]]--
QuHuCard = sgs.CreateSkillCard{
	name = "QuHuCard",
	skill_name = "QuHu",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:getHp() > sgs.Self:getHp() then
				return not to_select:isKongcheng()
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		room:broadcastSkillInvoke("QuHu", 1)
		local success = false
		if self:subcardsLength() == 0 then
			success = source:pindian(target, "QuHu")
		else
			success = source:pindian(target, "QuHu", self)
		end
		if success then
			local alives = room:getAlivePlayers()
			local victims = sgs.SPlayerList()
			for _,p in sgs.qlist(alives) do
				if target:inMyAttackRange(p) then
					victims:append(p)
				end
			end
			if victims:isEmpty() then
				local msg = sgs.LogMessage()
				msg.type = "#QuHuNoWolf"
				msg.from = source
				msg.to:append(target)
				room:sendLog(msg)
				return
			end
			local prompt = string.format("@QuHuDamage:%s", target:objectName())
			local victim = room:askForPlayerChosen(source, victims, "QuHu", prompt)
			if victim then
				room:broadcastSkillInvoke("QuHu", 2)
				local damage = sgs.DamageStruct()
				damage.from = target
				damage.to = victim
				damage.damage = 1
				room:damage(damage)
			end
		else
			local damage = sgs.DamageStruct()
			damage.from = target
			damage.to = source
			damage.damage = 1
			room:damage(damage)
		end
	end,
}
QuHu = sgs.CreateLuaSkill{
	name = "QuHu",
	translation = "驱虎",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名体力值大于你的角色拼点：若你赢，该角色对其攻击范围内的一名由你选择的角色造成1点伤害；若你没赢，该角色对你造成1点伤害。",
	audio = {
		"主公莫忧，吾有一计。",
		"驱虎吞狼，坐收渔利。",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local card = QuHuCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#QuHuCard") then
			return false
		end
		return true
	end,
	translations = {
		["#QuHuNoWolf"] = "%from “<font color=\"yellow\"><b>驱虎</b></font>”拼点赢，但由于 %to 攻击范围内没有角色，结算中止",
		["@QuHuDamage"] = "请选择 %src 攻击范围内的一名角色",
	},
}
--[[
	技能：节命
	描述：每当你受到1点伤害后，你可以令一名角色将手牌补至X张。（X为该角色体力上限且至多为5）
]]--
JieMing = sgs.CreateLuaSkill{
	name = "JieMing",
	translation = "节命",
	description = "每当你受到1点伤害后，你可以令一名角色将手牌补至X张。（X为该角色体力上限且至多为5）",
	audio = {
		"为守汉节，不惜吾命！",
		"秉忠贞之志，守谦退之节。",
	},
	class = "MasochismSkill",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		for i=1, damage.damage, 1 do
			local alives = room:getAlivePlayers()
			local target = room:askForPlayerChosen(player, alives, "JieMing", "@JieMing", true, true)
			if target then
				local maxhp = target:getMaxHp()
				local n = math.min( 5, maxhp )
				local x = n - target:getHandcardNum()
				if x > 0 then
					room:broadcastSkillInvoke("JieMing")
					room:drawCards(target, x, "JieMing")
					if player:isDead() then
						return
					end
				end
			else
				return
			end
		end
	end,
}
--武将信息：荀彧
XunYu = sgs.CreateLuaGeneral{
	name = "xunyu",
	translation = "荀彧",
	title = "王佐之才",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	cv = "听雨",
	illustrator = "LiuHeng",
	skills = {QuHu, JieMing},
	last_word = "身为汉臣，至死不渝。",
	resource = "xunyu",
}
--[[****************************************************************
	称号：凤雏
	武将：庞统
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：连环
	描述：你可以将一张♣手牌当【铁索连环】使用或重铸。
]]--
LianHuan = sgs.CreateLuaSkill{
	name = "LianHuan",
	translation = "连环",
	description = "你可以将一张草花手牌当【铁索连环】使用或重铸。",
	audio = "舟船成排，潮水何惧？",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:getSuit() == sgs.Card_Club then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("iron_chain", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("LianHuan")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
--[[
	技能：涅槃（限定技）
	描述：每当你处于濒死状态时，你可以弃置你区域内的牌，将武将牌恢复至初始状态，然后摸三张牌并回复至3点体力。
]]--
NiePan = sgs.CreateLuaSkill{
	name = "NiePan",
	translation = "涅槃",
	description = "<font color=\"red\"><b>限定技</b></font>，每当你处于濒死状态时，你可以弃置你区域内的牌，将武将牌恢复至初始状态，然后摸三张牌并回复至3点体力。",
	audio = "凤凰涅槃，浴火重生！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	events = {sgs.AskForPeaches},
	limit_mark = "@nirvana",
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and victim:objectName() == player:objectName() then
			if player:askForSkillInvoke("NiePan", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("NiePan")
				room:notifySkillInvoked(player, "NiePan")
				room:doSuperLightbox("pangtong", "NiePan")
				player:loseMark("@nirvana")
				player:throwAllHandCardsAndEquips()
				local tricks = player:getJudgingArea()
				if tricks:isEmpty() then
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName())
					for _,trick in sgs.qlist(tricks) do
						room:throwCard(trick, reason, nil)
					end
				end
				if player:isChained() then
					room:setPlayerProperty(player, "chained", sgs.QVariant(false))
				end
				if not player:faceUp() then
					player:turnOver()
				end
				room:drawCards(player, 3, "NiePan")
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 3 - player:getHp()
				room:recover(player, recover)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:hasSkill("NiePan") and target:getMark("@nirvana") > 0 then
				return true
			end
		end
		return false
	end,
	translations = {
		["@nirvana"] = "涅槃",
	},
}
--武将信息：庞统
PangTong = sgs.CreateLuaGeneral{
	name = "pangtong",
	translation = "庞统",
	title = "凤雏",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "无花有酒",
	skills = {LianHuan, NiePan},
	last_word = "落凤坡？此地不利于吾。",
	resource = "pangtong",
	marks = {"@nirvana"},
}
--[[****************************************************************
	称号：卧龙
	武将：诸葛亮
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：八阵（锁定技）
	描述：若你的装备区没有防具牌，视为你装备【八卦阵】。
]]--
BaZhen = sgs.CreateLuaSkill{
	name = "BaZhen",
	translation = "八阵",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的装备区没有防具牌，视为你装备【八卦阵】。",
	audio = "此阵可挡精兵十万！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			if not player:getArmor() then
				room:setPlayerMark(player, "View_As_eight_diagram", 1)
				local tag = player:getTag("eight_digram_ViewAsSkill"):toString()
				local skills = tag:split("+")
				for _,skill in ipairs(skills) do
					if skill == "BaZhen" then
						return false
					end
				end
				table.insert(skills, "BaZhen")
				skills = table.concat(skills, "+")
				player:setTag("eight_diagram_ViewAsSkill", sgs.QVariant(skills))
				return false
			end
		elseif event == sgs.CardsMoveOneTime then
		local move = data:toMoveOneTime()
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceEquip) then
					if not player:getArmor() then
						room:setPlayerMark(player, "View_As_eight_diagram", 1)
						local tag = player:getTag("eight_digram_ViewAsSkill"):toString()
						local skills = tag:split("+")
						for _,skill in ipairs(skills) do
							if skill == "BaZhen" then
								return false
							end
						end
						table.insert(skills, "BaZhen")
						skills = table.concat(skills, "+")
						player:setTag("eight_diagram_ViewAsSkill", sgs.QVariant(skills))
						return false
					end
				end
			end
			local target = move.to
			if target and target:objectName() == player:objectName() then
				if move.to_place == sgs.Player_PlaceEquip then
					if player:getArmor() then
						room:setPlayerMark(player, "View_As_eight_diagram", 0)
						local tag = player:getTag("eight_digram_ViewAsSkill"):toString()
						local skills = tag:split("+")
						local new_skills = {}
						for _,skill in ipairs(skills) do
							if skill ~= "BaZhen" then
								table.insert(new_skills, "BaZhen")
							end
						end
						new_skills = table.concat(new_skills, "+")
						player:setTag("eight_diagram_ViewAsSkill", sgs.QVariant(new_skills))
						return false
					end
				end
			end
		end
		return false
	end,
}
--[[
	技能：火计
	描述：你可以将一张红色手牌当【火攻】使用。
]]--
HuoJi = sgs.CreateLuaSkill{
	name = "HuoJi",
	translation = "火计",
	description = "你可以将一张红色手牌当【火攻】使用。",
	audio = {
		"欲破敌军，宜用火攻。",
		"且备硫磺焰硝，待命引火！",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed() and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("fire_attack", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("HuoJi")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
--[[
	技能：看破
	描述：你可以将一张黑色手牌当【无懈可击】使用。
]]--
KanPo = sgs.CreateLuaSkill{
	name = "KanPo",
	translation = "看破",
	description = "你可以将一张黑色手牌当【无懈可击】使用。",
	audio = "哼！此小计尔。",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack() and not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("nullification", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("KanPo")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "nullification"
	end,
	enabled_at_nullification = function(self, player)
		return not player:isKongcheng()
	end,
}
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "wolong",
	real_name = "zhugeliang",
	translation = "卧龙诸葛亮",
	title = "卧龙",
	show_name = "诸葛亮",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "彗星",
	illustrator = "北",
	skills = {BaZhen, HuoJi, KanPo},
	last_word = "悠悠苍天，曷此其极……",
	resource = "zhugeliang",
}
--[[****************************************************************
	称号：笃烈之士
	武将：太史慈
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：天义（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，本回合，你可以额外使用一张【杀】，你使用【杀】可以额外选择一名目标且无距离限制；若你没赢，你不能使用【杀】，直到回合结束。
]]--
TianYiMod = sgs.CreateLuaSkill{
	name = "#TianYiMod",
	class = "TargetModSkill",
	pattern = "Slash",
	residue_func = function(self, player, card)
		if player:hasFlag("TianYiSuccess") then
			return 1
		end
		return 0
	end,
	distance_limit_func = function(self, player, card)
		if player:hasFlag("TianYiSuccess") then
			return 1000
		end
		return 0
	end,
	extra_target_func = function(self, player, card)
		if player:hasFlag("TianYiSuccess") then
			return 1
		end
		return 0
	end,
}
TianYiCard = sgs.CreateSkillCard{
	name = "TianYiCard",
	skill_name = "TianYi",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() == sgs.Self:objectName() then
				return false
			elseif to_select:isKongcheng() then
				return false
			end
			return true
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local success = false
		if self:subcardsLength() == 0 then
			success = source:pindian(target, "TianYi")
		else
			success = source:pindian(target, "TianYi", self)
		end
		if success then
			room:setPlayerFlag(source, "TianYiSuccess")
		else
			room:setPlayerCardLimitation(source, "use", "Slash", true)
		end
	end,
}
TianYi = sgs.CreateLuaSkill{
	name = "TianYi",
	translation = "天义",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，本回合，你可以额外使用一张【杀】，你使用【杀】可以额外选择一名目标且无距离限制；若你没赢，你不能使用【杀】，直到回合结束。",
	audio = "大丈夫生于乱世，当立不世之功！",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local card = TianYiCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#TianYiCard") then
			return false
		end
		return true
	end,
	related_skills = TianYiMod,
}
--武将信息：太史慈
TaiShiCi = sgs.CreateLuaGeneral{
	name = "taishici",
	translation = "太史慈",
	title = "笃烈之士",
	kingdom = "wu",
	order = 4,
	cv = "口渴口樂",
	illustrator = "Tuu.",
	skills = TianYi,
	last_word = "今所志未遂，奈何死乎？",
	resource = "taishici",
}
--[[****************************************************************
	称号：高贵的名门
	武将：袁绍
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：乱击
	描述：你可以将两张相同花色的手牌当【万箭齐发】使用。
]]--
LuanJi = sgs.CreateLuaSkill{
	name = "LuanJi",
	translation = "乱击",
	description = "你可以将两张相同花色的手牌当【万箭齐发】使用。",
	audio = {
		"弓箭手出列！",
		"放箭！",
	},
	class = "ViewAsSkill",
	n = 2,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		elseif #selected == 0 then
			return true
		elseif #selected == 1 then
			return to_select:getSuit() == selected[1]:getSuit()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local trick = sgs.Sanguosha:cloneCard("archery_attack", sgs.Card_SuitToBeDecided, 0)
			trick:addSubcard(cards[1])
			trick:addSubcard(cards[2])
			trick:setSkillName("LuanJi")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return player:getHandcardNum() >= 2
	end,
}
--[[
	技能：血裔（主公技、锁定技）[空壳技能]
	描述：你的手牌上限+2X。（X为其他群雄角色的数量）
]]--
XueYi = sgs.CreateLuaSkill{
	name = "XueYi",
	translation = "血裔",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"blue\"><b>锁定技</b></font>，你的手牌上限+2X。（X为其他群雄角色的数量）",
}
--武将信息：袁绍
YuanShao = sgs.CreateLuaGeneral{
	name = "yuanshao",
	translation = "袁绍",
	title = "高贵的名门",
	kingdom = "qun",
	order = 1,
	cv = "耗子王",
	illustrator = "Sonia Tang",
	skills = {LuanJi, XueYi},
	last_word = "天不助袁哪！",
	resource = "yuanshao",
}
--[[****************************************************************
	称号：虎狼兄弟
	武将：颜良文丑
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：双雄
	描述：摸牌阶段开始时，你可以放弃摸牌并进行判定：若如此做，判定牌生效后你获得之，本回合你可以将与此牌颜色不同的手牌当【决斗】使用。
]]--
ShuangXiongVS = sgs.CreateLuaSkill{
	name = "ShuangXiong",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		end
		local color = sgs.Self:getMark("ShuangXiongColor")
		if color == 1 then
			return not to_select:isRed()
		elseif color == 2 then
			return not to_select:isBlack()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("duel", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("_ShuangXiong")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:getMark("ShuangXiongColor") == 0 then
			return false
		end
		return true
	end,
}
ShuangXiong = sgs.CreateLuaSkill{
	name = "ShuangXiong",
	translation = "双雄",
	description = "摸牌阶段开始时，你可以放弃摸牌并进行判定：若如此做，判定牌生效后你获得之，本回合你可以将与此牌颜色不同的手牌当【决斗】使用。",
	audio = {
		"虎狼兄弟，无往不利！",
		"兄弟同心，其利断金！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.FinishJudge, sgs.EventPhaseChanging},
	view_as_skill = ShuangXiongVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			local phase = player:getPhase()
			if phase == sgs.Player_Start then
				room:setPlayerMark(player, "ShuangXiongColor", 0)
			elseif phase == sgs.Player_Draw then
				if player:isAlive() and player:hasSkill("ShuangXiong") then
					if player:askForSkillInvoke("ShuangXiong", data) then
						room:broadcastSkillInvoke("ShuangXiong", 1)
						room:setPlayerFlag(player, "ShuangXiong")
						local judge = sgs.JudgeStruct()
						judge.who = player
						judge.reason = "ShuangXiong"
						judge.pattern = "."
						judge.good = true
						judge.play_animation = false
						room:judge(judge)
						if judge.card:isRed() then
							room:setPlayerMark(player, "ShuangXiongColor", 1)
						else
							room:setPlayerMark(player, "ShuangXiongColor", 2)
						end
						room:setPlayerMark(player, "ViewAsSkill_ShuangXiongEffect", 1)
						return true
					end
				end
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == "ShuangXiong" then
				local id = judge.card:getEffectiveId()
				if room:getCardPlace(id) == sgs.Player_PlaceJudge then
					room:obtainCard(player, judge.card, true)
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				room:setPlayerMark(player, "ViewAsSkill_ShuangXiongEffect", 0)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--武将信息：颜良文丑
YanLiangWenChou = sgs.CreateLuaGeneral{
	name = "yanliangwenchou",
	translation = "颜良文丑",
	title = "虎狼兄弟",
	kingdom = "qun",
	crowded = true,
	order = 6,
	cv = "墨染の飞猫，霸气爷们",
	skills = ShuangXiong,
	last_word = "生不逢时啊！",
	resource = "yanliangwenchou",
}
--[[****************************************************************
	称号：人马一体
	武将：庞德
	势力：群
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
MengJin = sgs.CreateLuaSkill{
	name = "MengJin",
	translation = "猛进",
	description = "你使用的【杀】被目标角色的【闪】抵消后，你可以弃置该角色的一张牌。",
	audio = "西凉铁骑，杀汝片甲不留！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local effect = data:toSlashEffect()
		local target = effect.to
		if target:isAlive() and player:canDiscard(target, "he") then
			if player:askForSkillInvoke("MengJin", data) then
				local room = player:getRoom()
				local id = room:askForCardChosen(player, target, "he", "MengJin", false, sgs.Card_MethodDiscard)
				if id >= 0 then
					room:broadcastSkillInvoke("MengJin")
					local card = sgs.Sanguosha:getCard(id)
					room:throwCard(card, target, player)
				end
			end
		end
		return false
	end,
}
--武将信息：庞德
PangDe = sgs.CreateLuaGeneral{
	name = "pangde",
	translation = "庞德",
	title = "人马一体",
	kingdom = "qun",
	order = 5,
	cv = "Glory",
	illustrator = "LiuHeng",
	skills = {"mashu", MengJin},
	last_word = "宁做国家鬼，不为贼将也！",
	resource = "pangde",
}
--[[****************************************************************
	火武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "fire",
	translation = "火包",
	generals = {
		DianWei, XunYu, PangTong, ZhuGeLiang, TaiShiCi, YuanShao, YanLiangWenChou, PangDe,
	},
}