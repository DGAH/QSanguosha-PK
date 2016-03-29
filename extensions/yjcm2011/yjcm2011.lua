--[[
	太阳神三国杀武将单挑对战平台·一将成名2011武将包
	武将总数：16
	武将一览：
		1、曹植（落英、酒诗）
		2、陈宫（智迟、明策）
		3、法正（恩怨、眩惑）
		4、高顺（陷阵、禁酒）
		5、凌统（旋风）
		6、马谡（心战、挥泪）
		7、吴国太（甘露、补益）
		8、徐盛（破军）
		9、徐庶（无言、举荐）
		10、于禁（毅重）
		11、张春华（绝情、伤逝）
		12、钟会（权计、自立）+（排异）
		13、法正·改（恩怨、眩惑）
		14、凌统·改（旋风）
		15、徐庶·改（无言、举荐）
		16、张春华·改（绝情、伤逝）
]]--
--[[****************************************************************
	版本控制
]]--****************************************************************
local old_version = true --原版武将开关，开启后将出现 法正、凌统、徐庶、张春华 四位武将
local new_version = true --新版武将开关，开启后将出现 法正·改、凌统·改、徐庶·改、张春华·改 四位武将
local yjcm2011 = {}
--[[****************************************************************
	称号：八斗之才
	武将：曹植
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：落英
	描述：其他角色的牌因判定或弃置而置入弃牌堆时，你可以获得其中至少一张梅花牌。
]]--
LuoYing = sgs.CreateLuaSkill{
	name = "yj1LuoYing",
	translation = "落英",
	description = "其他角色的牌因判定或弃置而置入弃牌堆时，你可以获得其中至少一张梅花牌。",
	audio = {
		"骋我径寸翰，流藻垂华芳！",
		"翩若惊鸿，婉若游龙，荣耀秋菊，华茂春松~",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.to_place ~= sgs.Player_DiscardPile then
			return false
		end
		local source = move.from
		if source and source:objectName() ~= player:objectName() then
			local reason = move.reason.m_reason
			local isJudgeDone, isDiscard = false, false
			if reason == sgs.CardMoveReason_S_REASON_JUDGEDONE then
				isJudgeDone = true
			else
				local basic = bit32.band(reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
				if basic == sgs.CardMoveReason_S_REASON_DISCARD then
					isDiscard = true
				end
			end
			if isJudgeDone or isDiscard then
				local card_ids = sgs.IntList()
				for index, id in sgs.qlist(move.card_ids) do
					local club = sgs.Sanguosha:getCard(id)
					if club:getSuit() == sgs.Card_Club then
						local from = move.from_places:at(index)
						if isJudgeDone then
							if from == sgs.Player_PlaceJudge then
								card_ids:append(id)
							end
						elseif isDiscard then
							if from == sgs.Player_PlaceHand or from == sgs.Player_PlaceEquip then
								local owner = room:getCardOwner(id)
								if owner and owner:objectName() == source:objectName() then
									card_ids:append(id)
								end
							end
						end
					end
				end
				if card_ids:isEmpty() then
					return false
				elseif player:askForSkillInvoke("yj1LuoYing", data) then
					while card_ids:length() > 1 do
						room:fillAG(card_ids, player)
						local to_throw = room:askForAG(player, card_ids, true, "yj1LuoYing")
						room:clearAG(player)
						if to_throw == -1 then
							break
						end
						card_ids:removeOne(to_throw)
					end
					if card_ids:isEmpty() then
						return false
					end
					if source:isGeneral("zhenji", true, true) then
						room:broadcastSkillInvoke("yj1LuoYing", 2)
					else
						room:broadcastSkillInvoke("yj1LuoYing", 1)
					end
					move:removeCardIds(card_ids)
					data:setValue(move)
					local dummy = sgs.DummyCard(card_ids)
					room:moveCardTo(dummy, player, sgs.Player_PlaceHand, move.reason, true)
					dummy:deleteLater()
				end
			end
		end
	end,
}
--[[
	技能：酒诗
	描述：若你的武将牌正面朝上，你可以将武将牌翻面，视为你使用了一张【酒】。每当你受到伤害扣减体力前，若武将牌背面朝上，你可以在伤害结算后将武将牌翻至正面朝上。
]]--
JiuShiVS = sgs.CreateLuaSkill{
	name = "yj1JiuShi",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		local anal = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
		anal:setSkillName("yj1JiuShi")
		return anal
	end,
	enabled_at_play = function(self, player)
		if player:faceUp() then
			return sgs.Analeptic_IsAvailable(player)
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:faceUp() then
			return string.find(pattern, "analeptic")
		end
		return false
	end,
	effect_index = function(self, player, card)
		return math.random(1, 2)
	end,
}
JiuShi = sgs.CreateLuaSkill{
	name = "yj1JiuShi",
	translation = "酒诗",
	description = "若你的武将牌正面朝上，你可以将武将牌翻面，视为你使用了一张【酒】。每当你受到伤害扣减体力前，若武将牌背面朝上，你可以在伤害结算后将武将牌翻至正面朝上。",
	audio = {
		"举泰山以为肉，倾东海以为酒~",
		"饮酒并醉，纵横喧哗！",
		"归来宴平乐，美酒斗十千！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.PreCardUsed, sgs.PreDamageDone, sgs.DamageComplete},
	on_trigger = function(self, event, player, data)
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == "yj1JiuShi" then
				player:turnOver()
			end
		elseif event == sgs.PreDamageDone then
			local state = not player:faceUp()
			player:setTag("yj1JiuShiState", sgs.QVariant(state))
		elseif event == sgs.DamageComplete then
			local state = player:getTag("yj1JiuShiState"):toBool()
			player:removeTag("yj1JiuShiState")
			if state and not player:faceUp() then
				if player:askForSkillInvoke("yj1JiuShi", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("yj1JiuShi", 3)
					player:turnOver()
				end
			end
		end
		return false
	end,
}
--武将信息：曹植
CaoZhi = sgs.CreateLuaGeneral{
	name = "yj_i_caozhi",
	real_name = "caozhi",
	translation = "曹植",
	title = "八斗之才",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	designer = "Foxear",
	cv = "殆尘",
	illustrator = "木美人",
	skills = {LuoYing, JiuShi},
	last_word = "捐躯赴国难，视死忽如归呀……",
	resource = "caozhi",
}
table.insert(yjcm2011, CaoZhi)
--[[****************************************************************
	称号：刚直壮烈
	武将：陈宫
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：明策（阶段技）
	描述：你可以将一张装备牌或【杀】交给一名其他角色：若如此做，该角色可以视为对其攻击范围内由你选择的一名角色使用一张【杀】，否则其摸一张牌。
]]--
MingCeCard = sgs.CreateSkillCard{
	name = "yj1MingCeCard",
	skill_name = "yj1MingCe",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local victim = nil
		local choices = {}
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("yj1MingCe")
		if source:isAlive() and sgs.Slash_IsAvailable(target) then
			local victims = sgs.SPlayerList()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if target:canSlash(p, slash) then
					victims:append(p)
				end
			end
			if not victims:isEmpty() then
				local prompt = string.format("@dummy-slash2:%s:", target:objectName())
				victim = room:askForPlayerChosen(source, victims, "yj1MingCe", prompt)
				if victim then
					table.insert(choices, "slash")
					local msg = sgs.LogMessage()
					msg.type = "#CollateralSlash"
					msg.from = source
					msg.to:append(victim)
					room:sendLog(msg)
				end
			end
		end
		table.insert(choices, "draw")
		choices = table.concat(choices, "+")
		local reason = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_GIVE, 
			source:objectName(), 
			target:objectName(), 
			"yj1MingCe", 
			""
		)
		room:obtainCard(target, self, reason)
		local choice = room:askForChoice(target, "yj1MingCe", choices)
		if choice == "slash" and victim then
			local use = sgs.CardUseStruct()
			use.from = target
			use.to:append(victim)
			use.card = slash
			room:useCard(use)
		elseif choice == "draw" then
			room:drawCards(target, 1, "yj1MingCe")
		end
	end,
}
MingCe = sgs.CreateLuaSkill{
	name = "yj1MingCe",
	translation = "明策",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张装备牌或【杀】交给一名其他角色：若如此做，该角色可以视为对其攻击范围内由你选择的一名角色使用一张【杀】，否则其摸一张牌。",
	audio = {
		"如此，霸业可图也！",
		"如此，一击可擒也！",
	},
	class = "OneCardViewAsSkill",
	filter_pattern = "EquipCard,Slash",
	view_as = function(self, card)
		local vs_card = MingCeCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#yj1MingCeCard") then
			return false
		elseif player:isNude() then
			return false
		end
		return true
	end,
	effect_index = function(self, player, card)
		if card:isKindOf("Slash") then
			return -2
		end
		return -1
	end,
}
--[[
	技能：智迟（锁定技）
	描述：你的回合外，每当你受到伤害后，【杀】和非延时锦囊牌对你无效，直到回合结束。
]]--
ZhiChiEffect = sgs.CreateLuaSkill{
	name = "#yj1ZhiChiEffect",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected, sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardEffected then
			local effect = data:toCardEffect()
			local target = effect.to
			if target:getMark("@late") == 0 then
				return false
			end
			local card = effect.card
			if card:isKindOf("Slash") or card:isNDTrick() then
				room:broadcastSkillInvoke("yj1ZhiChi", 2)
				room:notifySkillInvoked(target, "yj1ZhiChi")
				local msg = sgs.LogMessage()
				msg.type = "#yj1ZhiChiAvoid"
				msg.from = target
				msg.arg = "yj1ZhiChi"
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					p:loseAllMarks("@late")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				local current = room:getCurrent()
				if current and current:objectName() == player:objectName() then
					local alives = room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						p:loseAllMarks("@late")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
ZhiChi = sgs.CreateLuaSkill{
	name = "yj1ZhiChi",
	translation = "智迟",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的回合外，每当你受到伤害后，【杀】和非延时锦囊牌对你无效，直到回合结束。",
	audio = {
		"如今之计，唯有退守，再做决断！",
		"若吾早知如此……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj1ZhiChi", 1)
			room:notifySkillInvoked(player, "yj1ZhiChi")
			if player:getMark("@late") == 0 then
				player:gainMark("@late")
			end
			local msg = sgs.LogMessage()
			msg.type = "#yj1ZhiChiDamaged"
			msg.from = player
			room:sendLog(msg)
		end
		return false
	end,
	translations = {
		["@late"] = "智迟",
		["#yj1ZhiChiDamaged"] = "%from 受到了伤害，本回合内所有【杀】和非延时性锦囊对其无效",
	},
	related_skills = ZhiChiEffect,
}
--武将信息：陈宫
ChenGong = sgs.CreateLuaGeneral{
	name = "yj_i_chengong",
	real_name = "chengong",
	translation = "陈宫",
	title = "刚直壮烈",
	kingdom = "qun",
	maxhp = 3,
	order = 1,
	designer = "Kaycent",
	cv = "V7, 官方",
	illustrator = "黑月乱",
	skills = {MingCe, ZhiChi},
	last_word = "请出就戮！",
	resource = "chengong",
}
table.insert(yjcm2011, ChenGong)
if old_version then
--[[****************************************************************
	称号：蜀汉的辅翼
	武将：法正
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：恩怨（锁定技）
	描述：每当你回复1点体力后，令你回复体力的角色摸一张牌；每当你受到伤害后，伤害来源选择一项：交给你一张红桃手牌，或失去1点体力。
]]--
EnYuan = sgs.CreateLuaSkill{
	name = "yj1EnYuan",
	translation = "恩怨",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你回复1点体力后，令你回复体力的角色摸一张牌；每当你受到伤害后，伤害来源选择一项：交给你一张红桃手牌，或失去1点体力。",
	audio = {
		"得人恩果千年记~",
		"滴水之恩，涌泉以报！",
		"谁敢得罪我？！",
		"睚眦之怨，无不报复！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.HpRecover, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.HpRecover then
			local recover = data:toRecover()
			local source = recover.who
			if source and source:isAlive() and source:objectName() ~= player:objectName() then
				room:broadcastSkillInvoke("yj1EnYuan", math.random(1, 2))
				room:notifySkillInvoked(player, "yj1EnYuan")
				room:sendCompulsoryTriggerLog(player, "yj1EnYuan")
				room:drawCards(source, recover.recover, "yj1EnYuan")
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			local source = damage.from
			if source and source:isAlive() and source:objectName() ~= player:objectName() then
				room:broadcastSkillInvoke("yj1EnYuan", math.random(3, 4))
				room:notifySkillInvoked(player, "yj1EnYuan")
				room:sendCompulsoryTriggerLog(player, "yj1EnYuan")
				local prompt = string.format("@yj1EnYuan:%s:", player:objectName())
				local heart = room:askForCard(source, ".|heart|.|hand", prompt, data, sgs.Card_MethodNone)
				if heart then
					room:obtainCard(player, card, true)
				else
					room:loseHp(source)
				end
			end
		end
		return false
	end,
	translations = {
		["@yj1EnYuan"] = "请交给 %src 一张红心手牌，否则你将失去 1 点体力",
	},
}
--[[
	技能：眩惑（阶段技）
	描述：你可以将一张红桃手牌交给一名其他角色：若如此做，你获得该角色的一张牌，然后将此牌交给除该角色外的另一名角色。
]]--
XuanHuoCard = sgs.CreateSkillCard{
	name = "yj1XuanHuoCard",
	skill_name = "yj1XuanHuo",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		room:obtainCard(target, self, true)
		if target:isNude() or source:isDead() then
			return
		end
		local card_id = room:askForCardChosen(source, target, "he", "yj1XuanHuo")
		if card_id >= 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName())
			local card = sgs.Sanguosha:getCard(card_id)
			local place = room:getCardPlace(card_id)
			room:obtainCard(source, card, reason, place ~= sgs.Player_PlaceHand)
			local others = room:getOtherPlayers(target)
			local prompt = string.format("@yj1XuanHuo:%s:", target:objectName())
			local lucky = room:askForPlayerChosen(source, others, "yj1XuanHuo", prompt)
			if lucky and lucky:objectName() ~= source:objectName() then
				reason = sgs.CardMoveReason(
					sgs.CardMoveReason_S_REASON_GIVE, 
					source:objectName(), 
					lucky:objectName(), 
					"yj1XuanHuo", 
					""
				)
				room:obtainCard(lucky, card, reason, false)
			end
		end
	end,
}
XuanHuo = sgs.CreateLuaSkill{
	name = "yj1XuanHuo",
	translation = "眩惑",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张红桃手牌交给一名其他角色：若如此做，你获得该角色的一张牌，然后将此牌交给除该角色外的另一名角色。",
	audio = {
		"给你的，十倍奉还给我！",
		"重用许靖，以眩远近！",
	},
	class = "OneCardViewAsSkill",
	filter_pattern = ".|heart|.|hand",
	view_as = function(self, card)
		local vs_card = XuanHuoCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#yj1XuanHuoCard") then
			return false
		end
		return true
	end,
	translations = {
		["@yj1XuanHuo"] = "你可以将此牌交给除 %src 外的一名角色",
	},
}
--武将信息：法正
FaZheng = sgs.CreateLuaGeneral{
	name = "yj_i_fazheng",
	real_name = "fazheng",
	translation = "法正",
	title = "蜀汉的辅翼",
	kingdom = "shu",
	maxhp = 3,
	order = 4,
	designer = "Michael_Lee",
	illustrator = "雷没才",
	skills = {EnYuan, XuanHuo},
	last_word = "辅翼既折，蜀汉哀矣……",
	resource = "fazheng_v1",
}
table.insert(yjcm2011, FaZheng)
end
--[[****************************************************************
	称号：攻无不克
	武将：高顺
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：陷阵（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，本回合，该角色的防具无效，你无视与该角色的距离，你对该角色使用【杀】无次数限制；若你没赢，你不能使用【杀】，直到回合结束。
]]--
XianZhenCard = sgs.CreateSkillCard{
	name = "yj1XianZhenCard",
	skill_name = "yj1XianZhen",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:isKongcheng() then
				return false
			elseif to_select:objectName() == sgs.Self:objectName() then
				return false
			end
			return true
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local result = source:pindian(target, "yj1XianZhen")
		if result == sgs.Player_PindianWin then
			room:setPlayerFlag(source, "yj1XianZhenSuccess")
			local tag = sgs.QVariant()
			tag:setValue(target)
			source:setTag("yj1XianZhenTarget", tag)
			room:addPlayerMark(target, "Armor_Nullified")
			room:setFixedDistance(source, target, 1)
			local records = source:property("extra_slash_specific_assignee"):toString():split("+")
			table.insert(records, target:objectName())
			room:setPlayerProperty(source, "extra_slash_specific_assignee", sgs.QVariant(table.concat(records, "+")))
		elseif result == sgs.Player_PindianDraw or result == sgs.Player_PindianLose then
			room:setPlayerCardLimitation(source, "use", "Slash", true)
		end
	end,
}
XianZhenVS = sgs.CreateLuaSkill{
	name = "yj1XianZhenVS",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return XianZhenCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#yj1XianZhenCard") then
			return false
		elseif player:isKongcheng() then
			return false
		end
		return true
	end,
}
XianZhen = sgs.CreateLuaSkill{
	name = "yj1XianZhen",
	translation = "陷阵",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，本回合，该角色的防具无效，你无视与该角色的距离，你对该角色使用【杀】无次数限制；若你没赢，你不能使用【杀】，直到回合结束。",
	audio = {
		"攻无不克，战无不胜！",
		"破阵斩将，易如反掌！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging, sgs.Death},
	view_as_skill = XianZhenVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		local target = player:getTag("yj1XianZhenTarget"):toPlayer()
		if target then
			if event == sgs.Death then
				local death = data:toDeath()
				local victim = death.who
				if victim and victim:objectName() ~= player:objectName() then
					if victim:objectName() == target:objectName() then
						room:removeFixedDistance(player, target, 1)
						player:removeTag("yj1XianZhenTarget")
						room:setPlayerFlag(player, "-yj1XianZhenSuccess")
					end
					return false
				end
			end
			local records = player:property("extra_slash_specific_assignee"):toString():split("+")
			local new_records = {}
			for _,record in ipairs(records) do
				if record ~= target:objectName() then
					table.insert(new_records, record)
				end
			end
			room:setPlayerProperty(player, "extra_slash_specific_assignee", sgs.QVariant(table.concat(new_records, "+")))
			room:removeFixedDistance(player, target, 1)
			player:removeTag("yj1XianZhenTarget")
			room:removePlayerMark(target, "Armor_Nullified")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能：禁酒（锁定技）
	描述：你的【酒】视为【杀】。
]]--
JinJiu = sgs.CreateLuaSkill{
	name = "yj1JinJiu",
	translation = "禁酒",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的【酒】视为【杀】。",
	audio = {
		"贬酒阙色，所以无污！",
		"避嫌远疑，所以无误！",
	},
	class = "FilterSkill",
	view_filter = function(self, to_select)
		return to_select:isKindOf("Analeptic")
	end,
	view_as = function(self, card)
		local id = card:getEffectiveId()
		local suit = card:getSuit()
		local point = card:getNumber()
		local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
		slash:setSkillName("yj1JinJiu")
		local wrapped = sgs.Sanguosha:getWrappedCard(id)
		wrapped:takeOver(slash)
		return wrapped
	end,
}
--武将信息：高顺
GaoShun = sgs.CreateLuaGeneral{
	name = "yj_i_gaoshun",
	real_name = "gaoshun",
	translation = "高顺",
	title = "攻无不克",
	kingdom = "qun",
	maxhp = 4,
	order = 3,
	designer = "羽柴文理",
	illustrator = "鄧Sir",
	skills = {XianZhen, JinJiu},
	last_word = "生死……有……命……",
	resource = "gaoshun",
}
table.insert(yjcm2011, GaoShun)
if old_version then
--[[****************************************************************
	称号：豪情胆烈
	武将：凌统
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：旋风
	描述：每当你失去一次装备区的牌后，你可以选择一项：视为使用一张无距离限制的【杀】，或对距离1的一名角色造成1点伤害。
]]--
XuanFeng = sgs.CreateLuaSkill{
	name = "yj1XuanFeng",
	translation = "旋风",
	description = "每当你失去一次装备区的牌后，你可以选择一项：视为使用一张无距离限制的【杀】，或对距离1的一名角色造成1点伤害。",
	audio = {
		"伤敌于千里之外！",
		"索命于须臾之间！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.from_places:contains(sgs.Player_PlaceEquip) then
			local source = move.from
			if source and source:objectName() == player:objectName() then
				local choices = {}
				local room = player:getRoom()
				local alives = room:getAlivePlayers()
				local groupA = sgs.SPlayerList()
				local groupB = sgs.SPlayerList()
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("yj1XuanFeng")
				for _,p in sgs.qlist(alives) do
					if player:canSlash(p, slash, false) then
						groupA:append(p)
					end
					if player:distanceTo(p) == 1 then
						groupB:append(p)
					end
				end
				if groupA:isEmpty() or player:isCardLimited(slash, sgs.Card_MethodUse) then
				else
					table.insert(choices, "slash")
				end
				if not groupB:isEmpty() then
					table.insert(choices, "damage")
				end
				table.insert(choices, "cancel")
				choices = table.concat(choices, "+")
				local choice = room:askForChoice(player, "yj1XuanFeng", choices)
				if choice == "slash" then
					local target = room:askForPlayerChosen(player, groupA, "yj1XuanFengSlash", "@dummy-slash")
					if target then
						room:broadcastSkillInvoke("yj1XuanFeng", 2)
						local use = sgs.CardUseStruct()
						use.from = player
						use.to:append(target)
						use.card = slash
						room:useCard(use)
					end
				elseif choice == "damage" then
					slash:deleteLater()
					local target = room:askForPlayerChosen(player, groupB, "yj1XuanFengDamage", "@yj1XuanFeng")
					if target then
						room:broadcastSkillInvoke("yj1XuanFeng", 1)
						local damage = sgs.DamageStruct()
						damage.from = player
						damage.to = target
						damage.damage = 1
						damage.reason = "yj1XuanFeng"
						room:damage(damage)
					end
				else
					slash:deleteLater()
				end
			end
		end
		return false
	end,
	translations = {
		["yj1XuanFeng:slash"] = "视为使用一张无距离限制的【杀】",
		["yj1XuanFeng:damage"] = "对距离为1的一名角色造成1点伤害",
		["yj1XuanFeng:cancel"] = "不发动“旋风”",
		["yj1XuanFengSlash"] = "旋风·杀",
		["yj1XuanFengDamage"] = "旋风·伤害",
		["@yj1XuanFeng"] = "请选择距离为1的一名角色",
	},
}
--武将信息：凌统
LingTong = sgs.CreateLuaGeneral{
	name = "yj_i_lingtong",
	real_name = "lingtong",
	translation = "凌统",
	title = "豪情胆烈",
	kingdom = "wu",
	maxhp = 4,
	order = 8,
	illustrator = "绵Myan",
	skills = XuanFeng,
	last_word = "大丈夫不惧死亡……",
	resource = "lingtong_v1",
}
table.insert(yjcm2011, LingTong)
end
--[[****************************************************************
	称号：怀才自负
	武将：马谡
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：心战（阶段技）
	描述：若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后你可以展示并获得其中至少一张红桃牌，然后将其余的牌置于牌堆顶。
]]--
XinZhanCard = sgs.CreateSkillCard{
	name = "yj1XinZhanCard",
	skill_name = "yj1XinZhan",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local card_ids = room:getNCards(3)
		local msg = sgs.LogMessage()
		msg.type = "$ViewDrawPile"
		msg.from = source
		msg.card_str = table.concat(sgs.QList2Table(card_ids), "+")
		room:sendLog(msg, source)
		local left = card_ids
		local hearts = sgs.IntList()
		local non_hearts = sgs.IntList()
		for _,id in sgs.qlist(card_ids) do
			local card = sgs.Sanguosha:getCard(id)
			if card:getSuit() == sgs.Card_Heart then
				hearts:append(id)
			else
				non_hearts:append(id)
			end
		end
		if not hearts:isEmpty() then
			local dummy = sgs.DummyCard()
			while true do
				room:fillAG(left, source, non_hearts)
				local id = room:askForAG(source, hearts, true, "yj1XinZhan")
				room:clearAG(source)
				if id == -1 then
					break
				end
				hearts:removeOne(id)
				left:removeOne(id)
				dummy:addSubcard(id)
				if hearts:isEmpty() then
					break
				end
			end
			local subcards = dummy:getSubcards()
			local num = subcards:length()
			if num > 0 then
				local pile = room:getDrawPile()
				local length = pile:length() + num
				room:doBroadcastNotify(sgs.QSanProtocol_S_COMMAND_UPDATE_PILE, sgs.QVariant(length))
				room:obtainCard(source, dummy)
				for _,id in sgs.qlist(subcards) do
					room:showCard(source, id)
				end
			end
			dummy:deleteLater()
		end
		if not left:isEmpty() then
			room:askForGuanxing(source, left, sgs.Room_GuanxingUpOnly)
		end
	end,
}
XinZhan = sgs.CreateLuaSkill{
	name = "yj1XinZhan",
	translation = "心战",
	description = "<font color=\"green\"><b>阶段技</b></font>，若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后你可以展示并获得其中至少一张红桃牌，然后将其余的牌置于牌堆顶。",
	audio = "吾~通晓兵法，世人皆知。",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return XinZhanCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:getHandcardNum() > player:getMaxHp() then
			return not player:hasUsed("#yj1XinZhanCard")
		end
		return false
	end,
}
--[[
	技能：挥泪（锁定技）
	描述：你死亡时，杀死你的其他角色弃置其所有牌。
]]--
HuiLei = sgs.CreateLuaSkill{
	name = "yj1HuiLei",
	translation = "挥泪",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你死亡时，杀死你的其他角色弃置其所有牌。",
	audio = {
		"谡，愿以死安大局！",
		"丞相视某如子，某以丞相为父！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local reason = death.damage
			if reason then
				local killer = reason.from
				if killer and killer:objectName() ~= player:objectName() then
					local room = player:getRoom()
					if killer:isGeneral("zhugeliang", true, true) then
						room:broadcastSkillInvoke("yj1HuiLei", 2)
					else
						room:broadcastSkillInvoke("yj1HuiLei", 1)
					end
					room:notifySkillInvoked(player, "yj1HuiLei")
					local msg = sgs.LogMessage()
					msg.type = "#yj1HuiLeiThrow"
					msg.from = player
					msg.to:append(killer)
					msg.arg = "yj1HuiLei"
					room:sendLog(msg)
					killer:throwAllHandCardsAndEquips()
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("yj1HuiLei")
	end,
}
--武将信息：马谡
MaSu = sgs.CreateLuaGeneral{
	name = "yj_i_masu",
	real_name = "masu",
	translation = "马谡",
	title = "怀才自负",
	kingdom = "shu",
	maxhp = 3,
	order = 4,
	designer = "点点",
	illustrator = "张帅",
	skills = {XinZhan, HuiLei},
	resource = "masu",
}
table.insert(yjcm2011, MaSu)
--[[****************************************************************
	称号：武烈皇后
	武将：吴国太
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：甘露（阶段技）
	描述：你可以令装备区的牌数量差不超过你已损失体力值的两名角色交换他们装备区的装备牌。
]]--
GanLuCard = sgs.CreateSkillCard{
	name = "yj1GanLuCard",
	skill_name = "yj1GanLu",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return true
		elseif #targets == 1 then
			local a = targets[1]:getEquips():length()
			local b = to_select:getEquips():length()
			local lost = sgs.Self:getLostHp()
			return math.abs(a - b) <= lost
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		local targetA, targetB = targets[1], targets[2]
		if targetA:isGeneral("liubei", true, true) or targetB:isGeneral("liubei", true, true) then
			room:broadcastSkillInvoke("yj1GanLu", 2)
		else
			room:broadcastSkillInvoke("yj1GanLu", 1)
		end
		local msg = sgs.LogMessage()
		msg.type = "#yj1GanLuSwap"
		msg.from = source
		msg.to:append(targetA)
		msg.to:append(targetB)
		room:sendLog(msg)
		local equipsA = targetA:getEquips()
		local equipsB = targetB:getEquips()
		local idsA = sgs.IntList()
		local idsB = sgs.IntList()
		for _,equip in sgs.qlist(equipsA) do
			idsA:append(equip:getEffectiveId())
		end
		for _,equip in sgs.qlist(equipsB) do
			idsB:append(equip:getEffectiveId())
		end
		local moves = sgs.CardsMoveList()
		local reasonA = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_SWAP, 
			playerA:objectName(), 
			playerB:objectName(), 
			"yj1GanLu", 
			""
		)
		local moveA = sgs.CardsMoveStruct(idsA, targetB, sgs.Player_PlaceEquip, reasonA)
		moves:append(moveA)
		local reasonB = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_SWAP, 
			playerB:objectName(), 
			playerA:objectName(), 
			"yj1GanLu", 
			""
		)
		local moveB = sgs.CardsMoveStruct(idsA, targetB, sgs.Player_PlaceEquip, reasonB)
		moves:append(moveB)
		room:moveCardsAtomic(moves, false)
	end,
}
GanLu = sgs.CreateLuaSkill{
	name = "yj1GanLu",
	translation = "甘露",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令装备区的牌数量差不超过你已损失体力值的两名角色交换他们装备区的装备牌。",
	audio = {
		"男婚女嫁，须当交换文定之物。",
		"此真乃吾之佳婿也！",
	},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return GanLuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#yj1GanLuCard")
	end,
	translations = {
		["#yj1GanLuSwap"] = "%from 交换了 %to 的装备",
	},
}
--[[
	技能：补益
	描述：每当一名角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌为非基本牌，该角色弃置此牌，然后回复1点体力。
]]--
BuYi = sgs.CreateLuaSkill{
	name = "yj1BuYi",
	translation = "补益",
	description = "每当一名角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌为非基本牌，该角色弃置此牌，然后回复1点体力。",
	audio = {
		"吾乃吴国之母，何人敢造次？！",
		"有老身在，汝等尽可放心。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local victim = dying.who
		if victim and not victim:isKongcheng() then
			if player:askForSkillInvoke("yj1BuYi", data) then
				local room = player:getRoom()
				local card = nil
				if player:objectName() == victim:objectName() then
					card = room:askForCardShow(victim, player, "yj1BuYi")
				else
					local id = room:askForCardChosen(player, victim, "h", "yj1BuYi")
					if id >= 0 then
						card = sgs.Sanguosha:getCard(id)
					end
				end
				if card then
					room:showCard(victim, card:getEffectiveId())
					if not card:isKindOf("BasicCard") then
						room:broadcastSkillInvoke("yj1BuYi")
						if not victim:isJilei(card) then
							room:throwCard(card, victim, victim)
						end
						local recover = sgs.RecoverStruct()
						recover.who = player
						recover.recover = 1
						room:recover(victim, recover)
					end
				end
			end
		end
		return false
	end,
}
--武将信息：吴国太
WuGuoTai = sgs.CreateLuaGeneral{
	name = "yj_i_wuguotai",
	real_name = "wuguotai",
	translation = "吴国太",
	title = "武烈皇后",
	kingdom = "wu",
	maxhp = 3,
	order = 2,
	designer = "章鱼咬你哦",
	illustrator = "zoo",
	skills = {GanLu, BuYi},
	last_word = "卿等……务必用心辅佐……仲谋……",
	resource = "wuguotai",
}
table.insert(yjcm2011, WuGuoTai)
--[[****************************************************************
	称号：江东的铁壁
	武将：徐盛
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：破军
	描述：每当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌，然后将其武将牌翻面。（X为该角色的体力值且至多为5）
]]--
PoJun = sgs.CreateLuaSkill{
	name = "yj1PoJun",
	translation = "破军",
	description = "每当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌，然后将其武将牌翻面。（X为该角色的体力值且至多为5）",
	audio = {
		"大军在此，汝等休想前进一步！",
		"敬请养精蓄锐！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.chain or damage.transfer then
			return false
		end
		local target = damage.to
		if target:isAlive() and not target:hasFlag("Global_DebutFlag") then
			local slash = damage.card
			if slash and slash:isKindOf("Slash") then
				if player:askForSkillInvoke("yj1PoJun", data) then
					local room = player:getRoom()
					local hp = target:getHp()
					if hp < 3 and target:faceUp() then
						room:broadcastSkillInvoke("yj1PoJun", 1)
					else
						room:broadcastSkillInvoke("yj1PoJun", 2)
					end
					room:notifySkillInvoked(player, "yj1PoJun")
					local x = math.min( 5, hp )
					room:drawCards(target, x, "yj1PoJun")
					target:turnOver()
				end
			end
		end
		return false
	end,
}
--武将信息：徐盛
XuSheng = sgs.CreateLuaGeneral{
	name = "yj_i_xusheng",
	real_name = "xusheng",
	translation = "徐盛",
	title = "江东的铁壁",
	kingdom = "wu",
	maxhp = 4,
	order = 3,
	designer = "阿江",
	illustrator = "天空之城",
	skills = PoJun,
	last_word = "盛不能奋身出命，不亦辱乎？……",
	resource = "xusheng",
}
table.insert(yjcm2011, XuSheng)
if old_version then
--[[****************************************************************
	称号：忠孝的侠士
	武将：徐庶
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：无言（锁定技）
	描述：你使用的非延时锦囊牌对其他角色无效。其他角色使用的非延时锦囊牌对你无效。
]]--
WuYan = sgs.CreateLuaSkill{
	name = "yj1WuYan",
	translation = "无言",
	description = "<font color=\"blue\"><b>无言</b></font>，你使用的非延时锦囊牌对其他角色无效。其他角色使用的非延时锦囊牌对你无效。",
	audio = {
		"嘘！言多必失呀~",
		"唉！一切……尽在不言中。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		local source, target, trick = effect.from, effect.to, effect.card
		if source and target and trick and trick:isNDTrick() then
			if source:objectName() == player:objectName() then
				return false
			end
			if source:isAlive() and source:hasSkill("yj1WuYan") then
				room:broadcastSkillInvoke("yj1WuYan")
				room:notifySkillInvoked(source, "yj1WuYan")
				local msg = sgs.LogMessage()
				msg.type = "#yj1WuYanBad"
				msg.from = source
				msg.to:append(target)
				msg.arg = trick:objectName()
				msg.arg2 = "yj1WuYan"
				room:sendLog(msg)
				return true
			elseif target:isAlive() and target:hasSkill("yj1WuYan") then
				room:broadcastSkillInvoke("yj1WuYan")
				room:notifySkillInvoked(target, "yj1WuYan")
				local msg = sgs.LogMessage()
				msg.type = "#yj1WuYanGood"
				msg.from = target
				msg.to:append(source)
				msg.arg = trick:objectName()
				msg.arg2 = "yj1WuYan"
				room:sendLog(msg)
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["#yj1WuYanBad"] = "%from 的“%arg2”被触发，对 %to 的锦囊【%arg】无效",
		["#yj1WuYanGood"] = "%from 的“%arg2”被触发， %to 的锦囊【%arg】对其无效",
	},
}
--[[
	技能：举荐（阶段技）
	描述：你可以弃置至多三张牌并选择一名其他角色：若如此做，该角色摸等量的牌。若你以此法弃置三张同一类别的牌，你回复1点体力。
]]--
JuJianCard = sgs.CreateSkillCard{
	name = "yj1JuJianCard",
	skill_name = "yj1JuJian",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("yj1JuJian")
		for _,target in ipairs(targets) do
			room:cardEffect(source, target, self)
		end
		local subcards = self:getSubcards()
		if subcards:length() == 3 then
			local allType = nil
			for _,id in sgs.qlist(subcards) do
				local card = sgs.Sanguosha:getCard(id)
				local myType = card:getType()
				if not allType then
					allType = myType
				elseif allType ~= myType then
					return
				end
			end
			if allType then
				local msg = sgs.LogMessage()
				msg.type = "#yj1JuJianRecover"
				msg.from = source
				msg.arg = allType
				room:sendLog(msg)
				local recover = sgs.RecoverStruct()
				recover.who = source
				recover.recover = 1
				room:recover(source, recover)
			end
		end
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		room:drawCards(target, self:subcardsLength(), "yj1JuJian")
	end,
}
JuJian = sgs.CreateLuaSkill{
	name = "yj1JuJian",
	translation = "举荐",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置至多三张牌并选择一名其他角色：若如此做，该角色摸等量的牌。若你以此法弃置三张同一类别的牌，你回复1点体力。",
	audio = {
		"将军~岂愿抓牌乎？",
		"我看好你！",
	},
	class = "ViewAsSkill",
	translations = {
		["#yj1JuJianRecover"] = "%from 发动“<font color=\"yellow\"><b>举荐</b></font>”弃置了三张 %arg ，回复1点体力",
	},
}
--武将信息：徐庶
XuShu = sgs.CreateLuaGeneral{
	name = "yj_i_xushu",
	real_name = "xushu",
	translation = "徐庶",
	title = "忠孝的侠士",
	kingdom = "shu",
	maxhp = 3,
	order = 1,
	illustrator = "XINA",
	skills = {WuYan, JuJian},
	resource = "xushu_v1",
}
table.insert(yjcm2011, XuShu)
end
--[[****************************************************************
	称号：魏武之刚
	武将：于禁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：毅重（锁定技）
	描述：若你的装备区没有防具牌，黑色【杀】对你无效。
]]--
YiZhong = sgs.CreateLuaSkill{
	name = "yj1YiZhong",
	translation = "毅重",
	description = "<font color=\"blue\"><b>锁定技</b></font>，若你的装备区没有防具牌，黑色【杀】对你无效。",
	audio = {
		"不先为备，何以待敌？",
		"稳重行军，百战不殆！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toSlashEffect()
		local slash = effect.slash
		if slash and slash:isBlack() then
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj1YiZhong")
			room:notifySkillInvoked(player, "yj1YiZhong")
			local msg = sgs.LogMessage()
			msg.type = "#SkillNullify"
			msg.from = player
			msg.arg = "yj1YiZhong"
			msg.arg2 = slash:objectName()
			room:sendLog(msg)
			return true
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("yj1YiZhong") then
			return not target:getArmor()
		end
		return false
	end,
}
--武将信息：于禁
YuJin = sgs.CreateLuaGeneral{
	name = "yj_i_yujin",
	real_name = "yujin",
	translation = "于禁",
	title = "魏武之刚",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "城管无畏",
	illustrator = "Yi章",
	skills = YiZhong,
	last_word = "我……无颜面对……丞相了……",
	resource = "yujin",
}
table.insert(yjcm2011, YuJin)
--[[****************************************************************
	称号：冷血皇后
	武将：张春华
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝情（锁定技）
	描述：伤害结算开始前，你将要造成的伤害视为失去体力。
]]--
JueQing = sgs.CreateLuaSkill{
	name = "yj1JueQing",
	translation = "绝情",
	description = "<font color=\"blue\"><b>锁定技</b></font>，伤害结算开始前，你将要造成的伤害视为失去体力。",
	audio = {
		"你的死活，与我何干？",
		"无来无去，不悔不怨~",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and source:objectName() == player:objectName() then
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj1JueQing")
			room:notifySkillInvoked(player, "yj1JueQing")
			room:sendCompulsoryTriggerLog(player, "yj1JueQing")
			room:loseHp(damage.to, damage.damage)
			return true
		end
		return false
	end,
}
if old_version then
--[[
	技能：伤逝
	描述：每当你的手牌数、体力值或体力上限改变后，若你的手牌数小于X，你可以将手牌补至X张。（X为你已损失的体力值）
]]--
ShangShi = sgs.CreateLuaSkill{
	name = "yj1ShangShi",
	translation = "伤逝",
	description = "每当你的手牌数、体力值或体力上限改变后，若你的手牌数小于X，你可以将手牌补至X张。（X为你已损失的体力值）",
	audio = {
		"无情者伤人，有情者自伤……",
		"自损八百，可伤敌一千！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.HpChanged, sgs.MaxHpChanged, sgs.CardsMoveOneTime, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local can_invoke = false
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceHand) then
					can_invoke = true
				end
			end
			if not can_invoke then
				local target = move.to
				if target and target:objectName() == player:objectName() then
					if move.to_place == sgs.Player_PlaceHand then
						can_invoke = true
					end
				end
			end
			if can_invoke then
				if player:getPhase() == sgs.Player_Discard then
					room:setPlayerMark(player, "yj1ShangShiDelay", 1)
					return false
				end
			else
				return false
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getMark("yj1ShangShiDelay") == 0 then
				return false
			else
				room:setPlayerMark(player, "yj1ShangShiDelay", 0)
			end
		end
		local x = player:getLostHp()
		local num = player:getHandcardNum()
		if num < x then
			if player:askForSkillInvoke("yj1ShangShi", data) then
				room:broadcastSkillInvoke("yj1ShangShi")
				room:drawCards(player, x - num, "yj1ShangShi")
			end
		end
		return false
	end,
}
--武将信息：张春华
ZhangChunHua = sgs.CreateLuaGeneral{
	name = "yj_i_zhangchunhua",
	real_name = "zhangchunhua",
	translation = "张春华",
	title = "冷血皇后",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	designer = "JZHIEI",
	illustrator = "樱花闪乱",
	skills = {JueQing, ShangShi},
	last_word = "怎能如此对我？……",
	resource = "zhangchunhua_v1",
}
table.insert(yjcm2011, ZhangChunHua)
end
--[[****************************************************************
	称号：桀骜的野心家
	武将：钟会
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：权计
	描述：每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”。每有一张“权”，你的手牌上限+1。
]]--
QuanJiKeep = sgs.CreateLuaSkill{
	name = "#yj1QuanJiKeep",
	class = "MaxCardsSkill",
	extra_func = function(self, player)
		if player:hasSkill("yj1QuanJi") then
			return player:getPile("power"):length()
		end
		return 0
	end,
}
QuanJi = sgs.CreateLuaSkill{
	name = "yj1QuanJi",
	translation = "权计",
	description = "每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”。每有一张“权”，你的手牌上限+1。",
	audio = {
		"终于~轮到我掌权啦！",
		"夺得军权，方能施展一番！",
	},
	class = "MasochismSkill",
	frequency = sgs.Skill_Frequent,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		for i=1, damage.damage, 1 do
			if player:askForSkillInvoke("yj1QuanJi") then
				room:broadcastSkillInvoke("yj1QuanJi")
				room:drawCards(player, 1, "yj1QuanJi")
				if player:isDead() then
					return
				elseif not player:isKongcheng() then
					local card_id = -1
					if player:getHandcardNum() == 1 then
						room:getThread():delay()
						card_id = player:handCards():first()
					else
						local card = room:askForExchange(player, "yj1QuanJi", 1, 1, false, "@yj1QuanJi")
						if card then
							card_id = card:getEffectiveId()
							card:deleteLater()
						end
					end
					if card_id >= 0 then
						player:addToPile("power", card_id)
					end
				end
			end
		end
	end,
	translations = {
		["@yj1QuanJi"] = "请将一张手牌作为“权”置于武将牌上",
		["power"] = "权",
	},
	related_skills = QuanJiKeep,
}
--[[
	技能：自立（觉醒技）
	描述：准备阶段开始时，若“权”大于或等于三张，你失去1点体力上限，摸两张牌或回复1点体力，然后获得“排异”（阶段技。你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害）。
]]--
ZiLi = sgs.CreateLuaSkill{
	name = "yj1ZiLi",
	translation = "自立",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若“权”大于或等于三张，你失去1点体力上限，摸两张牌或回复1点体力，然后获得“排异”（<font color=\"green\"><b>阶段技</b></font>。你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害）。",
	audio = "以我之才，何必屈人之下？",
	class = "PhaseChangeSkill",
	frequency = sgs.Skill_Wake,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:broadcastSkillInvoke("yj1ZiLi")
		room:notifySkillInvoked(player, "yj1ZiLi")
		room:doSuperLightbox("yj_i_zhonghui", "yj1ZiLi")
		local msg = sgs.LogMessage()
		msg.type = "#yj1ZiLiWake"
		msg.from = player
		msg.arg = player:getPile("power"):length()
		msg.arg2 = "yj1ZiLi"
		room:sendLog(msg)
		room:setPlayerMark(player, "yj1ZiLiWaked", 1)
		room:loseMaxHp(player)
		if player:isAlive() then
			local choices = {"draw"}
			if player:getLostHp() > 0 then
				table.insert(choices, "recover")
			end
			choices = table.concat(choices, "+")
			local choice = room:askForChoice(player, "yj1ZiLi", choices)
			if choice == "draw" then
				room:drawCards(player, 2, "yj1ZiLi")
			elseif choice == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(player, recover)
			end
			if player:isAlive() then
				room:acquireSkill(player, "yj1PaiYi")
				player:gainMark("@waked")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("yj1ZiLi") then
			if target:getPhase() == sgs.Player_Start then
				if target:getMark("yj1ZiLiWaked") == 0 then
					return target:getPile("power"):length() >= 3
				end
			end
		end
		return false
	end,
}
--[[
	技能：排异（阶段技）
	描述：你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害。
]]--
PaiYiCard = sgs.CreateSkillCard{
	name = "yj1PaiYiCard",
	skill_name = "yj1PaiYi",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local pile = source:getPile("power")
		if pile:isEmpty() then
			return
		end
		local target = effect.to
		local room = source:getRoom()
		if target:objectName() == source:objectName() then
			room:broadcastSkillInvoke("yj1PaiYi", 1)
		else
			room:broadcastSkillInvoke("yj1PaiYi", 2)
		end
		local card_id = self:getSubcards():first()
		if room:getCardPlace(card_id) ~= sgs.Player_DiscardPile then
			local reason = sgs.CardMoveReason(
				sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, 
				"", 
				target:objectName(), 
				"yj1PaiYi", 
				""
			)
			local card = sgs.Sanguosha:getCard(card_id)
			room:throwCard(card, reason)
		end
		room:drawCards(target, 2, "yj1PaiYi")
		if target:getHandcardNum() > source:getHandcardNum() then
			local damage = sgs.DamageStruct()
			damage.from = source
			damage.to = target
			damage.damage = 1
			damage.reason = "yj1PaiYi"
			room:damage(damage)
		end
	end,
}
PaiYi = sgs.CreateLuaSkill{
	name = "yj1PaiYi",
	translation = "排异",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害。",
	audio = {
		"待我设计……构陷之。",
		"非我族者，其心可诛！",
	},
	class = "OneCardViewAsSkill",
	expand_pile = "power",
	filter_pattern = ".|.|.|power",
	view_as = function(self, card)
		local vs_card = PaiYiCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#yj1PaiYiCard") then
			return false
		elseif player:getPile("power"):isEmpty() then
			return false
		end
		return true
	end,
}
--武将信息：钟会
ZhongHui = sgs.CreateLuaGeneral{
	name = "yj_i_zhonghui",
	real_name = "zhonghui",
	translation = "钟会",
	title = "桀骜的野心家",
	kingdom = "wei",
	maxhp = 4,
	order = 8,
	cv = "风叹息",
	illustrator = "雪君S",
	skills = {QuanJi, ZiLi},
	related_skills = PaiYi,
	last_word = "大权在手竟一夕败亡，时耶？命耶？",
	resource = "zhonghui",
}
table.insert(yjcm2011, ZhongHui)
if new_version then
--[[****************************************************************
	称号：蜀汉的辅翼
	武将：法正·改
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：恩怨
	描述：每当你获得一名其他角色的两张或更多的牌后，你可以令其摸一张牌。每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。
]]--
EnYuan = sgs.CreateLuaSkill{
	name = "yj1xEnYuan",
	translation = "恩怨",
	description = "每当你获得一名其他角色的两张或更多的牌后，你可以令其摸一张牌。每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。",
	audio = {
		"报之以李，还之以桃！",
		"伤了我，休想全身而退！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.reason.m_reason == sgs.CardMoveReason_S_REASON_PREVIEWGIVE then
				return false
			elseif move.card_ids:length() < 2 then
				return false
			end
			local target = move.to
			if target and target:objectName() == player:objectName() then
				local source = move.from
				if source and source:isAlive() and source:objectName() ~= player:objectName() then
					local place = move.to_place
					if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
						if player:askForSkillInvoke("yj1xEnYuan", data) then
							room:broadcastSkillInvoke("yj1xEnYuan", 1)
							local alives = room:getAlivePlayers()
							for _,p in sgs.qlist(alives) do
								if p:objectName() == source:objectName() then
									room:drawCards(p, 1, "yj1xEnYuan")
									return false
								end
							end
						end
					end
				end
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			local source = damage.from
			if source and source:objectName() ~= player:objectName() then
				local prompt = string.format("@yj1xEnYuan:%s:", player:objectName())
				for i=1, damage.damage, 1 do
					if source:isAlive() and player:isAlive() then
						if player:askForSkillInvoke("yj1xEnYuan", data) then
							room:broadcastSkillInvoke("yj1xEnYuan", 2)
							local card = nil
							if not source:isKongcheng() then
								card = room:askForExchange(source, "yj1xEnYuan", 1, 1, false, prompt, true)
							end
							if card then
								local reason = sgs.CardMoveReason(
									sgs.CardMoveReason_S_REASON_GIVE, 
									source:objectName(), 
									player:objectName(), 
									"yj1xEnYuan", 
									""
								)
								reason.m_playerId = player:objectName()
								room:moveCardTo(card, source, player, sgs.Player_PlaceHand, reason)
								card:deleteLater()
							else
								room:loseHp(source)
							end
						end
					end
				end
			end
		end
		return false
	end,
	translations = {
		["@yj1xEnYuan"] = "恩怨：请交给 %src 1 张手牌，否则你将失去 1 点体力",
	},
}
--[[
	技能：眩惑
	描述：摸牌阶段开始时，你可以放弃摸牌并选择一名其他角色：若如此做，该角色摸两张牌，然后该角色可以对其攻击范围内由你选择的一名角色使用一张【杀】，否则令你获得其两张牌。
]]--
XuanHuo = sgs.CreateLuaSkill{
	name = "yj1xXuanHuo",
	translation = "眩惑",
	description = "摸牌阶段开始时，你可以放弃摸牌并选择一名其他角色：若如此做，该角色摸两张牌，然后该角色可以对其攻击范围内由你选择的一名角色使用一张【杀】，否则令你获得其两张牌。",
	audio = {
		"收人钱财，替人消灾~",
		"哼！教你十倍奉还！",
	},
	class = "PhaseChangeSkill",
	frequency = sgs.Skill_NotFrequent,
	on_phasechange = function(self, player)
		if player:getPhase() == sgs.Player_Draw then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			local target = room:askForPlayerChosen(player, others, "yj1xXuanHuo", "@yj1xXuanHuo", true, true)
			if target then
				room:broadcastSkillInvoke("yj1xXuanHuo")
				room:drawCards(target, 2, "yj1xXuanHuo")
				if target:isAlive() and player:isAlive() then
					local victims = sgs.SPlayerList()
					local maybe_targets = room:getOtherPlayers(target)
					for _,p in sgs.qlist(maybe_targets) do
						if target:canSlash(p) then
							victims:append(p)
						end
					end
					local victim = nil
					if not victims:isEmpty() then
						local prompt = string.format("@dummy-slash2:%s:", target:objectName())
						victim = room:askForPlayerChosen(player, victims, "yj1xXuanHuoSlash", prompt)
					end
					local obtain = true
					if victim then
						local msg = sgs.LogMessage()
						msg.type = "#CollateralSlash"
						msg.from = player
						msg.to:append(victim)
						room:sendLog(msg)
						local prompt = string.format("@yj1xXuanHuoSlash:%s:%s:", player:objectName(), victim:objectName())
						if room:askForUseSlashTo(target, victim, prompt) then
							obtain = false
						elseif target:isNude() then
							obtain = false
						end
					end
					if obtain then
						local firstID = room:askForCardChosen(player, target, "he", "yj1xXuanHuo")
						if firstID >= 0 then
							room:setPlayerFlag(target, "yj1xXuanHuo_InTempMoving")
							local original_place = room:getCardPlace(firstID)
							local dummy = sgs.DummyCard()
							dummy:addSubcard(firstID)
							target:addToPile("#yj1xXuanHuo", firstID, false)
							if not target:isNude() then
								local secondID = room:askForCardChosen(player, target, "he", "yj1xXuanHuo")
								if secondID >= 0 then
									dummy:addSubcard(secondID)
								end
							end
							local firstCard = sgs.Sanguosha:getCard(firstID)
							room:moveCardTo(firstCard, target, original_place, false)
							room:setPlayerFlag(target, "-yj1xXuanHuo_InTempMoving")
							room:moveCardTo(dummy, player, sgs.Player_PlaceHand, false)
							dummy:deleteLater()
						end
					end
				end
				return true
			end
		end
		return false
	end,
	translations = {
		["@yj1xXuanHuo"] = "您可以发动“眩惑”令一名其他角色摸两张牌，然后你获得其两张牌",
		["~yj1xXuanHuo"] = "选择一名其他角色→点击“确定”",
		["yj1xXuanHuoSlash"] = "眩惑",
		["@yj1xXuanHuoSlash"] = "请对 %dest 使用一张【杀】，否则 %src 将获得你的两张牌",
	},
}
--武将信息：法正·改
FaZheng = sgs.CreateLuaGeneral{
	name = "yj_i_new_fazheng",
	real_name = "fazheng",
	translation = "法正·改",
	show_name = "法正",
	title = "蜀汉的辅翼",
	kingdom = "shu",
	maxhp = 3,
	order = 2,
	designer = "Michael_Lee",
	illustrator = "雷没才",
	skills = {EnYuan, XuanHuo},
	last_word = "汉室复兴，我……是看不到了……",
	resource = "fazheng_v2",
}
table.insert(yjcm2011, FaZheng)
--[[****************************************************************
	称号：豪情胆烈
	武将：凌统·改
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：旋风
	描述：每当你失去一次装备区的牌后，或弃牌阶段结束时若你于本阶段内弃置了至少两张你的牌，你可以弃置一名其他角色的一张牌，然后弃置一名其他角色的一张牌。
]]--
function doXuanFeng(room, source)
	local others = room:getOtherPlayers(source)
	local targets = sgs.SPlayerList()
	for _,p in sgs.qlist(others) do
		if source:canDiscard(p, "he") then
			targets:append(p)
		end
	end
	if targets:isEmpty() then
		return
	elseif source:askForSkillInvoke("yj1xXuanFeng") then
		room:broadcastSkillInvoke("yj1xXuanFeng")
		local first = room:askForPlayerChosen(source, targets, "yj1xXuanFeng")
		if first then
			local firstID = room:askForCardChosen(source, first, "he", "yj1xXuanFeng", false, sgs.Card_MethodDiscard)
			if firstID < 0 then
				return
			end
			room:throwCard(firstID, first, source)
			if source:isDead() then
				return
			end
			targets = sgs.SPlayerList()
			for _,p in sgs.qlist(others) do
				if source:canDiscard(p, "he") then
					targets:append(p)
				end
			end
			if targets:isEmpty() then
				return
			end
			local second = room:askForPlayerChosen(source, targets, "yj1xXuanFeng")
			if second then
				local secondID = room:askForCardChosen(source, second, "he", "yj1xXuanFeng", false, sgs.Card_MethodDiscard)
				if secondID >= 0 then
					room:throwCard(secondID, second, source)
				end
			end
		end
	end
end
XuanFeng = sgs.CreateLuaSkill{
	name = "yj1xXuanFeng",
	translation = "旋风",
	description = "每当你失去一次装备区的牌后，或弃牌阶段结束时若你于本阶段内弃置了至少两张你的牌，你可以弃置一名其他角色的一张牌，然后弃置一名其他角色的一张牌。",
	audio = {
		"伤敌于千里之外！",
		"索命于须臾之间！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if player:getPhase() == sgs.Player_Discard then
					local basic = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
					if basic == sgs.CardMoveReason_S_REASON_DISCARD then
						room:addPlayerMark(player, "yj1xXuanFengCount", move.card_ids:length())
					end
				end
			end
			if move.from_places:contains(sgs.Player_PlaceEquip) then
				if player:isAlive() and player:hasSkill("yj1xXuanFeng") then
					doXuanFeng(room, player)
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard then
				if player:isAlive() and player:hasSkill("yj1xXuanFeng") then
					if player:getMark("yj1xXuanFengCount") >= 2 then
						doXuanFeng(room, player)
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			room:setPlayerMark(player, "yj1xXuanFengCount", 0)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--武将信息：凌统·改
LingTong = sgs.CreateLuaGeneral{
	name = "yj_i_new_lingtong",
	real_name = "lingtong",
	translation = "凌统·改",
	show_name = "凌统",
	title = "豪情胆烈",
	kingdom = "wu",
	maxhp = 4,
	order = 7,
	illustrator = "绵Myan",
	skills = XuanFeng,
	last_word = "大丈夫不惧死亡……",
	resource = "lingtong_v2",
}
table.insert(yjcm2011, LingTong)
--[[****************************************************************
	称号：忠孝的侠士
	武将：徐庶·改
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：无言（锁定技）
	描述：每当你造成或受到伤害时，防止锦囊牌的伤害。
]]--
WuYan = sgs.CreateLuaSkill{
	name = "yj1xWuYan",
	translation = "无言",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你造成或受到伤害时，防止锦囊牌的伤害。",
	audio = {
		"吾……誓不为汉贼献一策！",
		"汝有良策，何必问我？",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local trick = damage.card
		if trick and trick:isKindOf("TrickCard") then
			local index = -1
			local msg = sgs.LogMessage()
			if event == sgs.DamageCaused then
				index = 1
				msg.type = "#yj1xWuYanBad"
			elseif event == sgs.DamageInflicted then
				index = 2
				msg.type = "#yj1xWuYanGood"
			end
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj1xWuYan", index)
			room:notifySkillInvoked(player, "yj1xWuYan")
			msg.from = player
			msg.arg = trick:objectName()
			msg.arg2 = "yj1xWuYan"
			room:sendLog(msg)
			return true
		end
		return false
	end,
	translations = {
		["#yj1xWuYanBad"] = "%from 的“%arg2”被触发，本次造成的【%arg】的伤害被防止",
		["#yj1xWuYanGood"] = "%from 的“%arg2”被触发，防止了本次受到的【%arg】的伤害",
	},
}
--[[
	技能：举荐
	描述：结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。
]]--
JuJianCard = sgs.CreateSkillCard{
	name = "yj1xJuJianCard",
	skill_name = "yj1xJuJian",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		if target:isGeneral("zhugeliang", true, true) then
			room:broadcastSkillInvoke("yj1xJuJian", 2)
		else
			room:broadcastSkillInvoke("yj1xJuJian", 1)
		end
		local choices = {"draw"}
		if target:getLostHp() > 0 then
			table.insert(choices, "recover")
		end
		if target:isChained() or not target:faceUp() then
			table.insert(choices, "reset")
		end
		choices = table.concat(choices, "+")
		local choice = room:askForChoice(target, "yj1xJuJian", choices)
		if choice == "draw" then
			room:drawCards(target, 2, "yj1xJuJian")
		elseif choice == "recover" then
			local recover = sgs.RecoverStruct()
			recover.who = effect.from
			recover.recover = 1
			room:recover(target, recover)
		elseif choice == "reset" then
			if target:isChained() then
				room:setPlayerProperty(target, "chained", sgs.QVariant(false))
			end
			if not target:faceUp() then
				target:turnOver()
			end
		end
	end,
}
JuJianVS = sgs.CreateLuaSkill{
	name = "yj1xJuJian",
	class = "OneCardViewAsSkill",
	filter_pattern = "^BasicCard!",
	response_pattern = "@@yj1xJuJian",
	view_as = function(self, card)
		local vs_card = JuJianCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
}
JuJian = sgs.CreateLuaSkill{
	name = "yj1xJuJian",
	translation = "举荐",
	description = "结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。",
	audio = {
		"天下大任，望君莫辞！",
		"卧龙之才，远胜于吾。",
	},
	class = "PhaseChangeSkill",
	view_as_skill = JuJianVS,
	on_phasechange = function(self, player)
		if player:getPhase() == sgs.Player_Finish then
			if player:canDiscard(player, "he") then
				local room = player:getRoom()
				room:askForUseCard(player, "@@yj1xJuJian", "@yj1xJuJian", -1, sgs.Card_MethodDiscard)
			end
		end
		return false
	end,
}
--武将信息：徐庶·改
XuShu = sgs.CreateLuaGeneral{
	name = "yj_i_new_xushu",
	real_name = "xushu",
	translation = "徐庶·改",
	show_name = "徐庶",
	title = "忠孝的侠士",
	kingdom = "shu",
	maxhp = 3,
	order = 1,
	illustrator = "XINA",
	skills = {WuYan, JuJian},
	last_word = "忠孝不能两全，孩儿……",
	resource = "xushu_v2",
}
table.insert(yjcm2011, XuShu)
--[[****************************************************************
	称号：冷血皇后
	武将：张春华·改
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：绝情（锁定技）
	描述：伤害结算开始前，你将要造成的伤害视为失去体力。
]]--
--[[
	技能：伤逝
	描述：每当你的手牌数、体力值或体力上限改变后，你可以将手牌补至X张。（X为你已损失的体力值且至多为2）
]]--
ShangShi = sgs.CreateLuaSkill{
	name = "yj1xShangShi",
	translation = "伤逝",
	description = "每当你的手牌数、体力值或体力上限改变后，你可以将手牌补至X张。（X为你已损失的体力值且至多为2）",
	audio = {
		"无情者伤人，有情者自伤……",
		"自损八百，可伤敌一千！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.HpChanged, sgs.MaxHpChanged, sgs.CardsMoveOneTime, sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local can_invoke = false
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceHand) then
					can_invoke = true
				end
			end
			if not can_invoke then
				local target = move.to
				if target and target:objectName() == player:objectName() then
					if move.to_place == sgs.Player_PlaceHand then
						can_invoke = true
					end
				end
			end
			if can_invoke then
				if player:getPhase() == sgs.Player_Discard then
					room:setPlayerMark(player, "yj1xShangShiDelay", 1)
					return false
				end
			else
				return false
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getMark("yj1xShangShiDelay") == 0 then
				return false
			else
				room:setPlayerMark(player, "yj1xShangShiDelay", 0)
			end
		end
		local lost = player:getLostHp()
		local x = math.min( 2 , lost )
		local num = player:getHandcardNum()
		if num < x then
			if player:askForSkillInvoke("yj1xShangShi", data) then
				room:broadcastSkillInvoke("yj1xShangShi")
				room:drawCards(player, x - num, "yj1xShangShi")
			end
		end
		return false
	end,
}
--武将信息：张春华·改
ZhangChunHua = sgs.CreateLuaGeneral{
	name = "yj_i_new_zhangchunhua",
	real_name = "zhangchunhua",
	translation = "张春华·改",
	show_name = "张春华",
	title = "冷血皇后",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	designer = "JZHIEI",
	illustrator = "樱花闪乱",
	skills = {JueQing, ShangShi},
	last_word = "怎能如此对我？……",
	resource = "zhangchunhua_v2",
}
table.insert(yjcm2011, ZhangChunHua)
end
--[[****************************************************************
	一将成名2011武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2011",
	translation = "一将成名",
	generals = yjcm2011,
}