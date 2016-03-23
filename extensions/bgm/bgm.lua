--[[
	太阳神三国杀武将单挑对战平台·☆SP武将包
	武将总数：10
	武将一览：
		1、赵云（龙胆、冲阵）
		2、貂蝉（离魂、闭月）
		3、曹仁（溃围、严整）
		4、庞统（漫卷、醉乡）
		5、张飞（嫉恶、大喝）
		6、吕蒙（驱虎、谋断）+（谦逊、激昂、英姿、克己）
		7、刘备（昭烈、誓仇）
		8、大乔（言笑、安娴）F
		9、甘宁（银铃、军威）
		10、夏侯惇（愤勇、雪恨）
]]--
--[[****************************************************************
	称号：白马先锋
	武将：赵云
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：龙胆
	描述：你可以将一张【杀】当【闪】使用或打出，或将一张【闪】当【杀】使用或打出。
]]--
--[[
	技能：冲阵
	描述：每当你发动“龙胆”使用或打出一张手牌时，你可以获得对方的一张手牌。
]]--
ChongZhen = sgs.CreateLuaSkill{
	name = "bgmChongZhen",
	translation = "冲阵",
	description = "每当你发动“龙胆”使用或打出一张手牌时，你可以获得对方的一张手牌。",
	audio = {
		"赤胆平乱世，龙枪定江山！",
		"我等化身为龙，贯穿敌阵！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardResponded, sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardResponded then
			local response = data:toCardResponse()
			if response.m_card:getSkillName() == "longdan" then
				local target = response.m_who
				if target and not target:isKongcheng() then
					local ai_data = sgs.QVariant()
					ai_data:setValue(target)
					if player:askForSkillInvoke("bgmChongZhen", ai_data) then
						room:broadcastSkillInvoke("bgmChongZhen", 1)
						local card_id = room:askForCardChosen(player, target, "h", "bgmChongZhen")
						if card_id >= 0 then
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							local card = sgs.Sanguosha:getCard(card_id)
							room:obtainCard(player, card, reason, false)
						end
					end
				end
			end
		elseif event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:getSkillName() == "longdan" then
				for _,target in sgs.qlist(use.to) do
					if target:isKongcheng() then
						continue
					end
					local ai_data = sgs.QVariant()
					ai_data:setValue(target)
					if player:askForSkillInvoke("bgmChongZhen", ai_data) then
						room:broadcastSkillInvoke("bgmChongZhen", 2)
						local card_id = room:askForCardChosen(player, target, "h", "bgmChongZhen")
						if card_id >= 0 then
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
							local card = sgs.Sanguosha:getCard(card_id)
							room:obtainCard(player, card, reason, false)
						end
					end
				end
			end
		end
		return false
	end,
}
--武将信息：赵云
ZhaoYun = sgs.CreateLuaGeneral{
	name = "bgm_zhaoyun",
	real_name = "zhaoyun",
	translation = "☆SP·赵云",
	show_name = "赵云",
	title = "白马先锋",
	kingdom = "qun",
	maxhp = 3,
	order = 7,
	designer = "Danny",
	cv = "墨宣砚韵",
	illustrator = "Vincent",
	skills = {"longdan", ChongZhen},
	last_word = "力量不及，请原谅……",
	resource = "zhaoyun",
}
--[[****************************************************************
	称号：暗黑的傀儡师
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：离魂（阶段技）
	描述：你可以弃置一张牌将武将牌翻面，并选择一名男性角色：若如此做，你获得该角色的所有手牌，且出牌阶段结束时，你交给该角色X张牌。（X为该角色的体力值）
]]--
LiHunCard = sgs.CreateSkillCard{
	name = "bgmLiHunCard",
	skill_name = "bgmLiHun",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:isMale()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("bgmLiHun")
		source:turnOver()
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local target = effect.to
		if target:isKongcheng() then
			return
		end
		local source = effect.from
		local room = source:getRoom()
		room:setPlayerFlag(target, "bgmLiHunTarget")
		local card_ids = target:handCards()
		local dummy = sgs.DummyCard(card_ids)
		local reason = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_TRANSFER, 
			source:objectName(), 
			target:objectName(), 
			"bgmLiHun", 
			""
		)
		room:moveCardTo(dummy, target, source, sgs.Player_PlaceHand, reason, false)
		dummy:deleteLater()
	end,
}
LiHunVS = sgs.CreateLuaSkill{
	name = "bgmLiHun",
	class = "OneCardViewAsSkill",
	filter_pattern = ".!",
	view_as = function(self, card)
		local vs_card = LiHunCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:canDiscard(player, "he") then
			return not player:hasUsed("#bgmLiHunCard")
		end
		return false
	end,
}
LiHun = sgs.CreateLuaSkill{
	name = "bgmLiHun",
	translation = "离魂",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置一张牌将武将牌翻面，并选择一名男性角色：若如此做，你获得该角色的所有手牌，且出牌阶段结束时，你交给该角色X张牌。（X为该角色的体力值）",
	audio = {
		"倾国之舞，离魂天外！",
		"舞炫人眼，暖人心神！",
		"将军~此舞如何？",
		"太师~别看呆了哟~",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	view_as_skill = LiHunVS,
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if phase == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					room:setPlayerFlag(p, "-bgmLiHunTarget")
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if phase == sgs.Player_Play then
				local others = room:getOtherPlayers(player)
				for _,target in sgs.qlist(others) do
					if target:hasFlag("bgmLiHunTarget") then
						room:setPlayerFlag(target, "-bgmLiHunTarget")
						if player:isNude() then
							continue
						end
						local hp = target:getHp()
						if hp > 0 then
							local index = 2
							if target:isGeneral("lvbu", true, false) then
								index = 3
							elseif target:isGeneral("dongzhuo", true, false) then
								index = 4
							elseif target:isGeneral("lvbu", false, true) then
								index = 3
							elseif target:isGeneral("dongzhuo", false, true) then
								index = 4
							end
							room:broadcastSkillInvoke("bgmLiHun", index)
							local to_give
							if player:getCardCount() > hp then
								to_give = player:wholeHandCards() or sgs.DummyCard()
								local equips = player:getEquips()
								for _,equip in sgs.qlist(equips) do
									to_give:addSubcard(equip)
								end
							else
								to_give = room:askForExchange(player, "bgmLiHun", hp, hp, true, "LiHunGoBack")
							end
							local reason = sgs.CardMoveReason(
								sgs.CardMoveReason_S_REASON_GIVE, 
								player:objectName(), 
								target:objectName(), 
								"bgmLiHun", 
								""
							)
							room:moveCardTo(to_give, player, target, sgs.Player_PlaceHand, reason)
							to_give:deleteLater()
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasUsed("#bgmLiHunCard")
	end,
}
--[[
	技能：闭月
	描述：结束阶段开始时，你可以摸一张牌。
]]--
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "bgm_diaochan",
	real_name = "diaochan",
	translation = "☆SP·貂蝉",
	show_name = "貂蝉",
	title = "暗黑的傀儡师",
	kingdom = "qun",
	maxhp = 3,
	order = 9,
	designer = "Danny",
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {LiHun, "BiYue"},
	last_word = "董贼已除，我又当何如……",
	resource = "diaochan",
}
--[[****************************************************************
	称号：险不辞难
	武将：曹仁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：溃围
	描述：结束阶段开始时，你可以摸X+2张牌：若如此做，将武将牌翻面，且你的下个摸牌阶段开始时，你弃置X张牌。（X为场上武器牌的数量）
]]--
local function getWeaponCount(room)
	local count = 0
	local alives = room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:getWeapon() then
			count = count + 1
		end
	end
	return count
end
KuiWei = sgs.CreateLuaSkill{
	name = "bgmKuiWei",
	translation = "溃围",
	description = "结束阶段开始时，你可以摸X+2张牌：若如此做，将武将牌翻面，且你的下个摸牌阶段开始时，你弃置X张牌。（X为场上武器牌的数量）",
	audio = "熬过此战，可见胜机！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local phase = player:getPhase()
		local room = player:getRoom()
		if phase == sgs.Player_Finish then
			if player:hasSkill("bgmKuiWei") then
				if player:askForSkillInvoke("bgmKuiWei", data) then
					room:broadcastSkillInvoke("bgmKuiWei")
					local x = getWeaponCount(room)
					room:drawCards(player, x+2, "bgmKuiWei")
					player:gainMark("@bgmKuiWeiMark")
				end
			end
		elseif phase == sgs.Player_Draw then
			if player:getMark("@bgmKuiWeiMark") > 0 then
				player:loseAllMarks("@bgmKuiWeiMark")
				local x = getWeaponCount(room)
				if x > 0 then
					local msg = sgs.LogMessage()
					msg.type = "#bgmKuiweiDiscard"
					msg.from = player
					msg.arg = x
					msg.arg2 = "bgmKuiWei"
					room:sendLog(msg)
					room:askForDiscard(player, "bgmKuiWei", x, x, false, true)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() then
			if target:hasSkill("bgmKuiWei") then	
				return true
			elseif target:getMark("@bgmKuiWeiMark") > 0 then
				return true
			end
		end
		return false
	end,
	translations = {
		["@bgmKuiWeiMark"] = "溃围",
		["#bgmKuiweiDiscard"] = "%from 的“%arg2”效果被触发，须弃置 %arg 张牌",
	},
}
--[[
	技能：严整
	描述：若你的手牌数大于你的体力值，你可以将一张装备区的牌当【无懈可击】使用。
]]--
YanZheng = sgs.CreateLuaSkill{
	name = "bgmYanZheng",
	translation = "严整",
	description = "若你的手牌数大于你的体力值，你可以将一张装备区的牌当【无懈可击】使用。",
	audio = "整装列阵，不留破绽！",
	class = "OneCardViewAsSkill",
	filter_pattern = ".|.|.|equipped",
	response_or_use = true,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local trick = sgs.Sanguosha:cloneCard("nullification", suit, point)
		trick:addSubcard(card)
		trick:setSkillName("bgmYanZheng")
		return trick
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "nullification" and player:getHandcardNum() > player:getHp()
	end,
	enabled_at_nullification = function(self, player)
		return player:hasEquip() and player:getHandcardNum() > player:getHp()
	end,
}
--武将信息：曹仁
CaoRen = sgs.CreateLuaGeneral{
	name = "bgm_caoren",
	real_name = "caoren",
	translation = "☆SP·曹仁",
	show_name = "曹仁",
	title = "险不辞难",
	kingdom = "wei",
	maxhp = 4,
	order = 6,
	designer = "Danny",
	cv = "喵小林",
	illustrator = "张帅",
	skills = {KuiWei, YanZheng},
	last_word = "城在……人在，城破……人……亡……",
	resource = "caoren",
	marks = {"@bgmKuiWeiMark"},
}
--[[****************************************************************
	称号：荆楚之高俊
	武将：庞统
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：漫卷
	描述：每当你将获得一张手牌时，你将之置入弃牌堆。若你的回合内你发动“漫卷”，你可以获得弃牌堆中一张与此牌同点数的牌（不能发动“漫卷”）。
]]--
local function doManJuan(room, player, card_id)
	player:setFlags("bgmManJuanInvoke")
	local discard_pile = room:getDiscardPile()
	local to_gain = sgs.IntList()
	local card = sgs.Sanguosha:getCard(card_id)
	local point = card:getNumber()
	for _,id in sgs.qlist(discard_pile) do
		local c = sgs.Sanguosha:getCard(id)
		if c:getNumber() == point then
			to_gain:append(id)
		end
	end
	if not to_gain:isEmpty() then
		room:fillAG(to_gain, player)
		local id = room:askForAG(player, to_gain, true, "bgmManJuan")
		room:clearAG(player)
		if id >= 0 then
			local card = sgs.Sanguosha:getCard(id)
			room:moveCardTo(card, player, sgs.Player_PlaceHand, true)
		end
	end
end
ManJuan = sgs.CreateLuaSkill{
	name = "bgmManJuan",
	translation = "漫卷",
	description = "每当你将获得一张手牌时，你将之置入弃牌堆。若你的回合内你发动“漫卷”，你可以获得弃牌堆中一张与此牌同点数的牌（不能发动“漫卷”）。",
	audio = "漫卷纵酒，白首狂歌！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		if player:hasFlag("bgmManJuanInvoke") then
			player:setFlags("-bgmManJuanInvoke")
			return false
		end
		local room = player:getRoom()
		if room:getTag("FirstRound"):toBool() then
			return false
		end
		local move = data:toMoveOneTime()
		if move.to_place ~= sgs.Player_PlaceHand then
			return false
		end
		local target = move.to
		if target and target:objectName() == player:objectName() then
			room:broadcastSkillInvoke("bgmManJuan")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "bgmManJuan", "")
			local ids = move.card_ids
			for _,id in sgs.qlist(ids) do
				local card = sgs.Sanguosha:getCard(id)
				room:moveCardTo(card, nil, nil, sgs.Player_DiscardPile, reason)
			end
			move.card_ids = sgs.IntList()
			data:setValue(move)
			local msg = sgs.LogMessage()
			msg.type = "$bgmManjuanGot"
			msg.from = player
			msg.card_str = table.concat(sgs.QList2Table(ids), "+")
			room:sendLog(msg)
			if player:getPhase() == sgs.Player_NotActive then
				return false
			elseif player:askForSkillInvoke("bgmManJuan", data) then
				for _,id in sgs.qlist(ids) do
					doManJuan(room, player, id)
					if player:isDead() then
						return false
					end
				end
			end
		end
		return false
	end,
	translations = {
		["$bgmManjuanGot"] = "%from 即将获得 %card 并将此牌置入弃牌堆",
	},
}
--[[
	技能：醉乡（限定技）
	描述：准备阶段开始时，你可以将牌堆顶的三张牌置于你的武将牌上。此后每个准备阶段开始时，你重复此流程，直到你的武将牌上出现同点数的“醉乡牌”，然后你获得所有“醉乡牌”（不能发动“漫卷”）。你不能使用或打出“醉乡牌”中存在的类别的牌，且这些类别的牌对你无效。
]]--
local function doZuiXiang(room, player)
	room:broadcastSkillInvoke("bgmZuiXiang")
	local pile = player:getPile("dream")
	if pile:isEmpty() then
		room:doSuperLightbox("bgm_pangtong", "bgmZuiXiang")
	end
	local types = {
		[sgs.Card_TypeBasic] = "BasicCard",
		[sgs.Card_TypeTrick] = "TrickCard",
		[sgs.Card_TypeEquip] = "EquipCard",
	}
	local dream_types = {}
	for _,id in sgs.qlist(pile) do
		local card = sgs.Sanguosha:getCard(id)
		dream_types[card:getTypeId()] = true
	end
	local ids = room:getNCards(3, false)
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "bgmZuiXiang", "")
	local move = sgs.CardsMoveStruct(ids, player, sgs.Player_PlaceTable, reason)
	room:moveCardsAtomic(move, true)
	local thread = room:getThread()
	thread:delay()
	thread:delay()
	player:addToPile("dream", ids, true)
	for _,id in sgs.qlist(ids) do
		local card = sgs.Sanguosha:getCard(id)
		local typeId = card:getTypeId()
		if typeId == sgs.Card_TypeEquip then
			room:setPlayerMark(player, "Equips_Nullified_to_Yourself", 1)
			room:setPlayerMark(player, "Equips_of_Others_Nullified_to_You", 1)
		end
		if not dream_types[typeId] then
			dream_types[typeId] = true
			room:setPlayerCardLimitation(player, "use,response", types[typeId], false)
		end
	end
	pile = player:getPile("dream")
	local numbers = {}
	local doneFlag = false
	for _,id in sgs.qlist(pile) do
		local card = sgs.Sanguosha:getCard(id)
		local point = card:getNumber()
		if numbers[point] then
			doneFlag = true
			break
		else
			numbers[point] = true
		end
	end
	if doneFlag then
		room:setPlayerMark(player, "bgmZuiXiangHasTrigger", 1)
		room:setPlayerMark(player, "Equips_Nullified_to_Yourself", 0)
		room:setPlayerMark(player, "Equips_of_Others_Nullified_to_You", 0)
		room:removePlayerCardLimitation(player, "use,response", "BasicCard$0")
		room:removePlayerCardLimitation(player, "use,response", "TrickCard$0")
		room:removePlayerCardLimitation(player, "use,response", "EquipCard$0")
		local msg = sgs.LogMessage()
		msg.type = "$bgmZuixiangGot"
		msg.from = player
		msg.card_str = table.concat(sgs.QList2Table(pile), "+")
		room:sendLog(msg)
		if player:hasSkill("bgmManJuan") then
			player:setFlags("bgmManJuanInvoke")
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), "", "bgmZuiXiang", "")
		local move = sgs.CardsMoveStruct(pile, player, sgs.Player_PlaceHand, reason)
		room:moveCardsAtomic(move, true)
	end
end
ZuiXiang = sgs.CreateLuaSkill{
	name = "bgmZuiXiang",
	translation = "醉乡",
	description = "<font color=\"red\"><b>限定技</b></font>，准备阶段开始时，你可以将牌堆顶的三张牌置于你的武将牌上。此后每个准备阶段开始时，你重复此流程，直到你的武将牌上出现同点数的“醉乡牌”，然后你获得所有“醉乡牌”（不能发动“漫卷”）。你不能使用或打出“醉乡牌”中存在的类别的牌，且这些类别的牌对你无效。",
	audio = "懵懵醉乡中，天下心中藏！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	events = {sgs.EventPhaseStart, sgs.SlashEffected, sgs.CardEffected, sgs.EventLoseSkill},
	limit_mark = "@sleep",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pile = player:getPile("dream")
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if not pile:isEmpty() then
					doZuiXiang(room, player)
				elseif player:getMark("bgmZuiXiangHasTrigger") == 0 and player:getMark("@sleep") > 0 then
					if player:isAlive() and player:hasSkill("bgmZuiXiang") then
						if player:askForSkillInvoke("bgmZuiXiang", data) then
							player:loseMark("@sleep")
							doZuiXiang(room, player)
						end
					end
				end
			end
		elseif event == sgs.SlashEffected then
			if pile:isEmpty() then
				return false
			elseif player:isAlive() and player:hasSkill("bgmZuiXiang") then
				local effect = data:toSlashEffect()
				local effective = true
				for _,id in sgs.qlist(pile) do
					local c = sgs.Sanguosha:getCard(id)
					if c:getTypeId() == sgs.Card_TypeBasic then
						effective = false
						break
					end
				end
				if effective then
					return false
				end
				room:broadcastSkillInvoke("bgmZuiXiang")
				local msg = sgs.LogMessage()
				local source = effect.from
				if source then
					msg.type = "#bgmZuiXiang1"
					msg.to:append(source)
				else
					msg.type = "#bgmZuiXiang2"
				end
				msg.from = player
				msg.arg = effect.slash:objectName()
				msg.arg2 = "bgmZuiXiang"
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.CardEffected then
			if pile:isEmpty() then
				return false
			elseif player:isAlive() and player:hasSkill("bgmZuiXiang") then
				local effect = data:toCardEffect()
				local card = effect.card
				if card:isKindOf("Slash") then
					return false
				end
				local effective = true
				local typeId = card:getTypeId()
				for _,id in sgs.qlist(pile) do
					local c = sgs.Sanguosha:getCard(id)
					if c:getTypeId() == typeId then
						effective = false
						break
					end
				end
				if effective then
					return false
				end
				room:broadcastSkillInvoke("bgmZuiXiang")
				local msg = sgs.LogMessage()
				local source = effect.from
				if source then
					msg.type = "#bgmZuiXiang1"
					msg.to:append(source)
				else
					msg.type = "#bgmZuiXiang2"
				end
				msg.from = player
				msg.arg = card:objectName()
				msg.arg2 = "bgmZuiXiang"
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "bgmZuiXiang" then
				room:setPlayerMark(player, "Equips_Nullified_to_Yourself", 0)
				room:setPlayerMark(player, "Equips_of_Others_Nullified_to_You", 0)
				room:removePlayerCardLimitation(player, "use,response", "BasicCard$0")
				room:removePlayerCardLimitation(player, "use,response", "TrickCard$0")
				room:removePlayerCardLimitation(player, "use,response", "EquipCard$0")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["dream"] = "醉乡",
		["@sleep"] = "梦",
		["#bgmZuiXiang1"] = "%from 的“%arg2”效果被触发， %to 的卡牌【%arg】对其无效",
		["#bgmZuiXiang2"] = "%from 的“%arg2”效果被触发，【%arg】对其无效",
		["$bgmZuixiangGot"] = "%from “醉乡牌”中有重复点数，获得所有“醉乡牌”：%card",
	},
}
--武将信息：庞统
PangTong = sgs.CreateLuaGeneral{
	name = "bgm_pangtong",
	real_name = "pangtong",
	translation = "☆SP·庞统",
	show_name = "庞统",
	title = "荆楚之高俊",
	kingdom = "qun",
	maxhp = 3,
	order = 10,
	designer = "Danny",
	cv = "墨宣砚韵",
	illustrator = "LiuHeng",
	skills = {ManJuan, ZuiXiang},
	last_word = "纵有治世才，难遇治世主……",
	resource = "pangtong",
	marks = {"@sleep"},
}
--[[****************************************************************
	称号：横矛立马
	武将：张飞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：嫉恶（锁定技）
	描述：你使用红色【杀】对目标角色造成伤害时，此伤害+1。
]]--
JiE = sgs.CreateLuaSkill{
	name = "bgmJiE",
	translation = "嫉恶",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你使用红色【杀】对目标角色造成伤害时，此伤害+1。",
	audio = {
		"杂碎，也敢在爷爷面前叫嚣？！",
		"三姓家奴，吃我一矛！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.chain or damage.transfer or not damage.by_user then
			return false
		end
		local slash = damage.card
		if slash and slash:isKindOf("Slash") and slash:isRed() then
			local room = player:getRoom()
			local target = damage.to
			if target:isGeneral("lvbu", true, true) then
				room:broadcastSkillInvoke("bgmJiE", 2)
			else
				room:broadcastSkillInvoke("bgmJiE", 1)
			end
			room:notifySkillInvoked(player, "bgmJiE")
			local msg = sgs.LogMessage()
			msg.type = "#bgmJiE"
			msg.from = player
			msg.to:append(target)
			local count = damage.damage
			msg.arg = count
			count = count + 1
			msg.arg2 = count
			room:sendLog(msg)
			damage.damage = count
			data:setValue(damage)
		end
		return false
	end,
	translations = {
		["#bgmJiE"] = "%from 的“<font color=\"yellow\"><b>嫉恶</b></font>”效果被触发，对 %to 造成的伤害+1，从 %arg 点上升至 %arg2 点",
	},
}
--[[
	技能：大喝（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，你可以将该角色的拼点牌交给一名体力值不大于你的角色，本回合该角色使用的非红桃【闪】无效；若你没赢，你展示所有手牌，然后弃置一张手牌。
]]--
DaHeCard = sgs.CreateSkillCard{
	name = "bgmDaHeCard",
	skill_name = "bgmDaHe",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() == player:objectName() then
				return false
			elseif to_select:isKongcheng() then
				return false
			end
			return true
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		source:pindian(targets[1], "bgmDaHe")
	end,
}
DaHeVS = sgs.CreateLuaSkill{
	name = "bgmDaHe",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return DaHeCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#bgmDaHeCard") then
			return false
		end
		return true
	end,
}
DaHe = sgs.CreateLuaSkill{
	name = "bgmDaHe",
	translation = "大喝",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，你可以将该角色的拼点牌交给一名体力值不大于你的角色，本回合该角色使用的非红桃【闪】无效；若你没赢，你展示所有手牌，然后弃置一张手牌。",
	audio = "燕人张飞在此！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.JinkEffect, sgs.EventPhaseChanging, sgs.Death, sgs.Pindian},
	view_as_skill = DaHeVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.JinkEffect then
			if player:hasFlag("bgmDaHeTarget") then
				local jink = data:toCard()
				if jink:getSuit() == sgs.Card_Heart then
					return false
				end
				local msg = sgs.LogMessage()
				msg.type = "#bgmDaHeEffect"
				msg.from = player
				msg.arg = jink:getSuitString()
				msg.arg2 = "bgmDaHe"
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					room:setPlayerFlag("-bgmDaHeTarget")
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				if player:hasSkill("bgmDaHe") then
					local alives = room:getAlivePlayers()
					for _,p in sgs.qlist(alives) do
						room:setPlayerFlag("-bgmDaHeTarget")
					end
				end
			end
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason == "bgmDaHe" then
				local source = pindian.from
				if source and source:objectName() == player:objectName() then
					if source:isAlive() and source:hasSkill("bgmPindian") then
						local card = pindian.to_card
						if room:getCardPlace(card:getEffectiveId()) ~= sgs.Player_PlaceTable then
							return false
						end
						if pindian:isSuccess() then
							room:setPlayerFlag(pindian.to, "bgmDaHeTarget")
							local targets = sgs.SPlayerList()
							local alives = room:getAlivePlayers()
							local hp = source:getHp()
							for _,p in sgs.qlist(alives) do
								if p:getHp() <= hp then
									targets:append(p)
								end
							end
							if targets:isEmpty() then
								return false
							end
							local target = room:askForPlayerChosen(source, targets, "bgmDaHe", "@bgmDaHe-give", true)
							if target then
								local reason = sgs.CardMoveReason(
									sgs.CardMoveReason_S_REASON_GIVE, 
									source:objectName(), 
									target:objectName(), 
									"bgmDaHe", 
									""
								)
								room:obtainCard(target, card, reason, true)
							end
						else
							if source:isKongcheng() then
								return false
							end
							room:showAllCards(source)
							room:askForDiscard(source, "bgmDaHe", 1, 1, false, false)
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["@bgmDaHe-give"] = "你可以将拼点牌交给一名体力值不大于你的角色",
		["#bgmDaheEffect"] = "受技能“%arg2”的影响，%from 使用的 %arg 【<font color=\"yellow\"><b>闪</b></font>】无效",
	},
}
--武将信息：张飞
ZhangFei = sgs.CreateLuaGeneral{
	name = "bgm_zhangfei",
	real_name = "zhangfei",
	translation = "☆SP·张飞",
	show_name = "张飞",
	title = "横矛立马",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "Serendipity",
	cv = "喵小林",
	illustrator = "绿豆粥",
	skills = {JiE, DaHe},
	last_word = "大哥……二哥……",
	resource = "zhangfei",
}
--[[****************************************************************
	称号：国士之风
	武将：吕蒙
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：探虎（阶段技）
	描述：你可以与一名其他角色拼点：若你赢，你无视与该角色的距离，你使用的非延时锦囊牌对该角色结算时不能被【无懈可击】响应，直到回合结束。
]]--
TanHuCard = sgs.CreateSkillCard{
	name = "bgmTanHuCard",
	skill_name = "bgmTanHu",
	target_fixed = false,
	will_throw = false,
	mute = true,
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
		room:broadcastSkillInvoke("bgmTanHu", 1)
		local success = source:pindian(target, "bgmTanHu")
		if success then
			room:broadcastSkillInvoke("bgmTanHu", 2)
			local tag = sgs.QVariant(target:objectName())
			source:setTag("bgmTanHuTarget", tag)
			room:setPlayerFlag(target, "bgmTanHuTarget")
			room:setFixedDistance(source, target, 1)
		else
			room:broadcastSkillInvoke("bgmTanHu", 3)
		end
	end,
}
TanHuVS = sgs.CreateLuaSkill{
	name = "bgmTanHu",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return TanHuCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#bgmTanHuCard") then
			return false
		end
		return true
	end,
}
TanHu = sgs.CreateLuaSkill{
	name = "bgmTanHu",
	translation = "探虎",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以与一名其他角色拼点：若你赢，你无视与该角色的距离，你使用的非延时锦囊牌对该角色结算时不能被【无懈可击】响应，直到回合结束。",
	audio = {
		"不入虎穴，焉得虎子？",
		"诈以欺敌，袭其空虚！",
		"反复之人，不可轻信。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging, sgs.Death, sgs.TrickCardCanceling},
	view_as_skill = TanHuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local clear = false
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				clear = true
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				clear = true
			end
		elseif event == sgs.TrickCardCanceling then
			local effect = data:toCardEffect()
			local target = effect.to
			if target and target:hasFlag("bgmTanHuTarget") then
				local source = effect.from
				if source and source:getTag("bgmTanHuTarget"):toString() == target:objectName() then
					return true
				end
			end
			return false
		end
		if clear then
			local name = player:getTag("bgmTanHuTarget"):toString()
			player:removeTag("bgmTanHuTarget")
			local players = room:getAllPlayers()
			for _,p in sgs.qlist(players) do
				if p:objectName() == name then
					room:setPlayerFlag(p, "-bgmTanHuTarget")
					room:removeFixedDistance(player, p, 1)
					return false
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能：谋断
	描述：游戏开始时，你获得一枚“文/武”标记且“武”朝上。若你的手牌数小于或等于2，你的标记为“文”朝上。其他角色的回合开始时，若“文”朝上，你可以弃置一张牌：若如此做，你将标记翻至“武”朝上。若“武”朝上，你拥有“谦逊”和“激昂”；若“文”朝上，你拥有“英姿”和“克己”。
]]--
MouDuanStart = sgs.CreateLuaSkill{
	name = "#bgmMouDuanStart",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart, sgs.EventAcquireSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			player:gainMark("@wu")
			room:handleAcquireDetachSkills(player, "bgmJiAng|QianXun")
		elseif event == sgs.EventAcquireSkill then
			if data:toString() == "bgmMouDuan" then
				if player:getMark("@wu") > 0 then
					room:handleAcquireDetachSkills(player, "bgmJiAng|QianXun")
				elseif player:getMark("@wen") > 0 then
					room:handleAcquireDetachSkills(player, "bgmYingZi|bgmKeJi")
				end
			end
		end
		return false
	end,
}
MouDuanClear = sgs.CreateLuaSkill{
	name = "#bgmMouDuanClear",
	class = "DetachEffectSkill",
	skill = "bgmMouDuan",
	on_skill_detached = function(self, room, player)
		if player:getMark("@wu") > 0 then
			player:loseAllMarks("@wu")
			room:handleAcquireDetachSkills(player, "-bgmJiAng|-QianXun", true)
		end
		if player:getMark("@wen") > 0 then
			player:loseAllMarks("@wen")
			room:handleAcquireDetachSkills(player, "-bgmYingZi|-bgmKeJi", true)
		end
	end,
}
MouDuan = sgs.CreateLuaSkill{
	name = "bgmMouDuan",
	translation = "谋断",
	description = "游戏开始时，你获得一枚“文/武”标记且“武”朝上。若你的手牌数小于或等于2，你的标记为“文”朝上。其他角色的回合开始时，若“文”朝上，你可以弃置一张牌：若如此做，你将标记翻至“武”朝上。若“武”朝上，你拥有“谦逊”和“激昂”；若“文”朝上，你拥有“英姿”和“克己”。",
	audio = "士别三日，当刮目相待。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				local alives = room:getAlivePlayers()
				for _,source in sgs.qlist(alives) do
					if source:hasSkill("bgmMouDuan") and source:getMark("@wen") > 0 then
						if source:canDiscard(source, "he") then
							local invoke = room:askForCard(source, "..", "@bgmMouDuan", data, "bgmMouDuan")
							if invoke and source:getHandcardNum() > 2 then
								room:broadcastSkillInvoke("bgmMouDuan")
								room:sendCompulsoryTriggerLog(source, "bgmMouDuan")
								player:loseMark("@wen")
								player:gainMark("@wu")
								room:handleAcquireDetachSkills(player, "-bgmYingZi|-bgmKeJi|bgmJiAng|QianXun")
							end
						end
					end
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if player:isAlive() and player:hasSkill("bgmMouDuan", true) then
					if player:getMark("@wu") > 0 and player:getHandcardNum() <= 2 then
						room:broadcastSkillInvoke("bgmMouDuan")
						room:sendCompulsoryTriggerLog(player, "bgmMouDuan")
						player:loseMark("@wu")
						player:gainMark("@wen")
						room:handleAcquireDetachSkills(player, "-bgmJiAng|-QianXun|bgmYingZi|bgmKeJi", true)
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["@wen"] = "文",
		["@wu"] = "武",
		["@bgmMouDuan"] = "你可以弃置一张牌将标记翻至“武”朝上（若你的手牌数小于或等于2则无事发生）",
	},
	related_skills = {MouDuanStart, MouDuanClear},
}
--[[
	技能：谦逊（锁定技）
	描述：你不能被选择为【顺手牵羊】与【乐不思蜀】的目标。
]]--
--[[
	技能：激昂
	描述：每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。
]]--
JiAng = sgs.CreateLuaSkill{
	name = "bgmJiAng",
	translation = "激昂",
	description = "每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。",
	audio = {
		"陈列赫然，兵人练习！",
		"攻守兼备，进退自如！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetSpecified, sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local card = use.card
		if card:isKindOf("Duel") then
		elseif card:isKindOf("Slash") and card:isRed() then
		else
			return false
		end
		local index = -1
		if event == sgs.TargetSpecified then
			index = 1
		elseif event == sgs.TargetConfirmed and use.to:contains(player) then
			index = 2
		else
			return false
		end
		if player:askForSkillInvoke("bgmJiAng", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("bgmJiAng", index)
			room:drawCards(player, 1, "bgmJiAng")
		end
		return false
	end,
}
--[[
	技能：英姿
	描述：摸牌阶段，你可以额外摸一张牌。
]]--
YingZi = sgs.CreateLuaSkill{
	name = "bgmYingZi",
	translation = "英姿",
	description = "摸牌阶段，你可以额外摸一张牌。",
	audio = {
		"秉承遗志，树威立信！",
		"明正军纪，路无拾遗。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("bgmYingZi", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("bgmYingZi")
			local n = data:toInt() + 1
			data:setValue(n)
		end
		return false
	end,
}
--[[
	技能：克己
	描述：若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。
]]--
KeJiRecord = sgs.CreateLuaSkill{
	name = "#bgmKeJiRecord",
	class = "TriggerSkill",
	global = true,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			if event == sgs.EventPhaseStart then
				room:setPlayerMark(player, "bgmKeJiSlash", 0)
				return false
			end
			local slash = nil
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				slash = use.card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				slash = response.m_card
			end
			if slash and slash:isKindOf("Slash") then
				room:setPlayerMark(player, "bgmKeJiSlash", 1)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
KeJi = sgs.CreateLuaSkill{
	name = "bgmKeJi",
	translation = "克己",
	description = "若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。",
	audio = {
		"利在不战，长计制之。",
		"容忍于心，深藏不露。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Discard then
			if player:isSkipped(sgs.Player_Discard) then
				return false
			elseif player:getMark("bgmKeJiSlash") > 0 then
				return false
			elseif player:askForSkillInvoke("bgmKeJi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("bgmKeJi")
				player:skip(sgs.Player_Discard)
			end
		end
		return false
	end,
	related_skills = KeJiRecord,
}
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "bgm_lvmeng",
	real_name = "lvmeng",
	translation = "☆SP·吕蒙",
	show_name = "吕蒙",
	title = "国士之风",
	kingdom = "wu",
	maxhp = 3,
	order = 10,
	designer = "如水法师卞程",
	cv = "风叹息",
	illustrator = "YellowKiss",
	skills = {TanHu, MouDuan},
	related_skills = {"QianXun", JiAng, YingZi, KeJi},
	last_word = "未见吴之天下，怎敢轻生……",
	resource = "lvmeng",
	marks = {"@wen", "@wu"},
}
--[[****************************************************************
	称号：汉昭烈帝
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：昭烈
	描述：摸牌阶段，你可以少摸一张牌并选择你攻击范围内的一名角色：若如此做，你亮出牌堆顶的三张牌，将其中的非基本牌和【桃】置入弃牌堆，然后该角色选择一项：1.受到X点伤害，然后获得其余的牌；2.弃置X张牌，然后令你获得其余的牌。（X为其中非基本牌的数量）
]]--
ZhaoLie = sgs.CreateLuaSkill{
	name = "bgmZhaoLie",
	translation = "昭烈",
	description = "摸牌阶段，你可以少摸一张牌并选择你攻击范围内的一名角色：若如此做，你亮出牌堆顶的三张牌，将其中的非基本牌和【桃】置入弃牌堆，然后该角色选择一项：1.受到X点伤害，然后获得其余的牌；2.弃置X张牌，然后令你获得其余的牌。（X为其中非基本牌的数量）",
	audio = {
		"不灭东吴，誓不归蜀！",
		"汝等勿劝，此战，势在必行！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards, sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			local alives = room:getAlivePlayers()
			local targets = sgs.SPlayerList()
			for _,p in sgs.qlist(targets) do
				if player:inMyAttackRange(p) then
					targets:append(p)
				end
			end
			if targets:isEmpty() then
				return false
			end
			local victim = room:askForPlayerChosen(player, targets, "bgmZhaoLie", "@bgmZhaoLie-invoke", true, true)
			if victim then
				room:setPlayerFlag(victim, "bgmZhaoLieTarget")
				room:setPlayerFlag(player, "bgmZhaoLieInvoked")
				local n = data:toInt() - 1
				n = math.max( 0, n )
				data:setValue(n)
			end
		elseif event == sgs.AfterDrawNCards then
			if player:hasFlag("bgmZhaoLieInvoked") then
				room:setPlayerFlag(player, "-bgmZhaoLieInvoked")
				local victim = nil
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if p:hasFlag("bgmZhaoLieTarget") then
						victim = p
						break
					end
				end
				if victim then
					local cards = sgs.CardList()
					local no_basic = 0
					local card_ids = sgs.IntList()
					local reason = sgs.CardMoveReason(
						sgs.CardMoveReason_S_REASON_TURNOVER, 
						player:objectName(), 
						"", 
						"bgmZhaoLie", 
						""
					)
					local thread = room:getThread()
					local dummy = sgs.DummyCard()
					for i=1, 3, 1 do
						local id = room:drawCard()
						card_ids:append(id)
						local card = sgs.Sanguosha:getCard(id)
						if card:isKindOf("Peach") then
							dummy:addSubcard(id)
						elseif card:isKindOf("BasicCard") then
							cards:append(card)
						else
							dummy:addSubcard(id)
							no_basic = no_basic + 1
						end
						local move = sgs.CardsMoveStruct(id, nil, sgs.Player_PlaceTable, reason)
						room:moveCardsAtomic(move, true)
						thread:delay()
					end
					reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, "", "bgmZhaoLie", "")
					if dummy:subcardsLength() > 0 then
						room:throwCard(dummy, reason, nil)
						dummy:clearSubcards()
					end
					dummy:deleteLater()
					if no_basic == 0 and cards:isEmpty() then
						return false
					end
					dummy:addSubcards(cards)
					if no_basic == 0 then
						local ai_data = sgs.QVariant(string.format("obtain:%s", player:objectName()))
						if victim:askForSkillInvoke("bgmZhaoLieObtain", ai_data) then
							room:broadcastSkillInvoke("bgmZhaoLie", 2)
							room:obtainCard(player, dummy)
						else
							room:broadcastSkillInvoke("bgmZhaoLie", 1)
							room:obtainCard(victim, dummy)
						end
						return false
					end
					if victim:getCardCount() >= no_basic then
						local prompt = string.format("@bgmZhaoLie-discard:%s", player:objectName())
						if room:askForDiscard(victim, "bgmZhaoLie", no_basic, no_basic, true, true, prompt) then
							room:broadcastSkillInvoke("bgmZhaoLie", 2)
							if dummy:subcardsLength() > 0 then
								if player:isAlive() then
									room:obtainCard(player, dummy)
								else
									room:throwCard(dummy, reason, nil)
								end
							end
							return false
						end
					end
					room:broadcastSkillInvoke("bgmZhaoLie", 1)
					if no_basic > 0 then
						local damage = sgs.DamageStruct()
						damage.from = player
						damage.to = victim
						damage.damage = no_basic
						damage.reason = "bgmZhaoLie"
						room:damage(damage)
					end
					if dummy:subcardsLength() > 0 then
						if victim:isAlive() then
							room:obtainCard(victim, dummy)
						else
							room:throwCard(dummy, reason, nil)
						end
					end
				end
			end
		end
		return false
	end,
}
--[[
	技能：誓仇（主公技、限定技）[空壳技能]
	描述：准备阶段开始时，你可以选择一名其他蜀势力角色并交给其两张牌。每当你受到伤害时，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌，直到其第一次进入濒死状态时。（X为伤害点数）
]]--
ShiChou = sgs.CreateLuaSkill{
	name = "bgmShiChou",
	translation = "誓仇",
	description = "<font color=\"yellow\"><b>主公技</b></font>，<font color=\"red\"><b>限定技</b></font>，准备阶段开始时，你可以选择一名其他蜀势力角色并交给其两张牌。每当你受到伤害时，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌，直到其第一次进入濒死状态时。（X为伤害点数）",
}
--武将信息：刘备
LiuBei = sgs.CreateLuaGeneral{
	name = "bgm_liubei",
	real_name = "liubei",
	translation = "☆SP·刘备",
	show_name = "刘备",
	title = "汉昭烈帝",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	designer = "妄想线条",
	cv = "喵小林",
	illustrator = "Fool头",
	skills = {ZhaoLie, ShiChou},
	last_word = "一时不仁，毁己功业，吾悔矣……",
	resource = "liubei",
}
--[[****************************************************************
	称号：韶光易逝
	武将：大乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：言笑
	描述：出牌阶段，你可以将一张方块牌置于一名角色的判定区内，称为“言笑牌”。判定区内有“言笑牌”的角色的判定阶段开始时获得其判定区内所有牌。
]]--
YanXiaoCard = sgs.CreateLuaCard{
	name = "bgmYanXiaoCard",
	translation = "言笑牌",
	description = "判定阶段开始时，目标角色获得判定区内所有牌。",
	class = "TrickCard",
	subclass = sgs.LuaTrickCard_TypeDelayedTrick,
	subtype = "delayed_trick",
	target_fixed = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return not to_select:containsTrick("bgmYanXiaoCard")
		end
		return false
	end,
	about_to_use = function(self, room, use)
		local index = 1
		for _,target in sgs.qlist(use.to) do
			if target:isGeneral("sunce", true, true) then
				index = 2
				break
			end
		end
		room:broadcastSkillInvoke("bgmYanXiao", index)
		self:cardOnUse(room, use)
	end,
}
YanXiaoVS = sgs.CreateLuaSkill{
	name = "bgmYanXiao",
	--class = "OneCardViewAsSkill",
	filter_pattern = ".|diamond",
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local vs_card = YanXiaoCard:clone()
		--local vs_card = sgs.Sanguosha:cloneCard("bgmYanXiaoCard", suit, point) --FAILED!
		vs_card:addSubcard(card)
		vs_card:setSkillName("bgmYanXiao")
		return vs_card
	end,
}
YanXiao = sgs.CreateLuaSkill{
	name = "bgmYanXiao",
	translation = "言笑",
	description = "出牌阶段，你可以将一张方块牌置于一名角色的判定区内，称为“言笑牌”。判定区内有“言笑牌”的角色的判定阶段开始时获得其判定区内所有牌。",
	audio = {
		"言笑之间，忧散愁消。",
		"吾夫有忧色，妾当为解之。",
	},
	--class = "PhaseChangeSkill",
	frequency = sgs.Skill_NotFrequent,
	view_as_skill = YanXiaoVS,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		local msg = sgs.LogMessage()
		msg.type = "$bgmYanxiaoGot"
		msg.from = player
		local move = sgs.CardsMoveStruct()
		local judges = player:getJudgingArea()
		for _,judge in sgs.qlist(judges) do
			local id = judge:getEffectiveId()
			move.card_ids:append(id)
		end
		msg.card_str = table.concat(sgs.QList2Table(move.card_ids), "+")
		room:sendLog(msg)
		move.to = target
		move.to_place = sgs.Player_PlaceHand
		room:moveCardsAtomic(move, true)
	end,
	can_trigger = function(self, target)
		if target and target:getPhase() == sgs.Player_Judge then
			return target:containsTrick("bgmYanXiaoCard")
		end
		return false
	end,
	translations = {
		["$bgmYanxiaoGot"] = "%from 判定阶段开始时，获得其判定区内所有牌：%card",
	},
}
--[[
	技能：安娴
	描述：每当你使用【杀】对目标角色造成伤害时，你可以防止此伤害：若如此做，该角色弃置一张手牌，然后你摸一张牌。每当你成为【杀】的目标时，你可以弃置一张手牌：若如此做，此【杀】的使用者摸一张牌，此【杀】对你无效。
]]--
AnXian = sgs.CreateLuaSkill{
	name = "bgmAnXian",
	translation = "安娴",
	description = "每当你使用【杀】对目标角色造成伤害时，你可以防止此伤害：若如此做，该角色弃置一张手牌，然后你摸一张牌。每当你成为【杀】的目标时，你可以弃置一张手牌：若如此做，此【杀】的使用者摸一张牌，此【杀】对你无效。",
	audio = {
		"安淑娴静，岂愿伤人？",
		"岂可如此无礼？",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused, sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			local slash = damage.card
			if damage.chain or damage.transfer then
				return false
			elseif slash and damage.by_user and slash:isKindOf("Slash") then
				if player:askForSkillInvoke("bgmAnXian", data) then
					room:broadcastSkillInvoke("bgmAnXian", 1)
					local msg = sgs.LogMessage()
					msg.type = "#bgmAnXian"
					msg.from = player
					msg.arg = "bgmAnXian"
					room:sendLog(msg)
					local target = damage.to
					if target:canDiscard(target, "h") then
						room:askForDiscard(target, "bgmAnXian", 1, 1)
					end
					room:drawCards(player, 1, "bgmAnXian")
					return true
				end
			end
		elseif event == sgs.TargetConfirming then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") then
				if use.to:contains(player) and player:canDiscard(player, "h") then
					if room:askForCard(player, ".", "@bgmAnXian-discard", data, "bgmAnXian") then
						room:broadcastSkillInvoke("bgmAnXian", 2)
						room:drawCards(use.from, 1, "bgmAnXian")
						if player:isAlive() then
							table.insert(use.nullified_list, player:objectName())
							data:setValue(use)
						end
					end
				end
			end
		end
		return false
	end,
	translations = {
		["#bgmAnXian"] = "%from 发动了“%arg”，防止此伤害",
		["@bgmAnXian-discard"] = "你可以弃置一张手牌令此【杀】对你无效",
	},
}
--武将信息：大乔
DaQiao = sgs.CreateLuaGeneral{
	name = "bgm_daqiao",
	real_name = "daqiao",
	translation = "☆SP·大乔",
	show_name = "大乔",
	title = "韶光易逝",
	kingdom = "wu",
	maxhp = 3,
	female = true,
	order = 5,
	designer = "ECauchy",
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {YanXiao, AnXian},
	last_word = "青灯常伴，了此余生……",
	resource = "daqiao",
}
--[[****************************************************************
	称号：怀铃的乌羽
	武将：甘宁
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：银铃
	描述：出牌阶段，若“锦”的数量少于四张，你可以弃置一张黑色牌并选择一名其他角色：若如此做，你将该角色的一张牌置于你的武将牌上，称为“锦”。
]]--
YinLingCard = sgs.CreateSkillCard{
	name = "bgmYinLingCard",
	skill_name = "bgmYinLing",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local target = effect.to
		if target:isNude() then
			return
		end
		local source = effect.from
		local room = source:getRoom()
		local card_id = room:askForCardChosen(source, target, "he", "bgmYinLing", false, sgs.Card_MethodNone)
		if card_id >= 0 then
			source:addToPile("brocade", card_id)
		end
	end,
}
YinLing = sgs.CreateLuaSkill{
	name = "bgmYinLing",
	translation = "银铃",
	description = "出牌阶段，若“锦”的数量少于四张，你可以弃置一张黑色牌并选择一名其他角色：若如此做，你将该角色的一张牌置于你的武将牌上，称为“锦”。",
	audio = {
		"银铃响，锦帆扬！",
		"老子啊，就是银铃锦帆——甘兴霸！",
	},
	class = "OneCardViewAsSkill",
	filter_pattern = ".|black!",
	view_as = function(self, card)
		local vs_card = YinLingCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:isNude() then
			return false
		end
		return player:getPile("brocade"):length() < 4
	end,
	translations = {
		["brocade"] = "锦",
	},
}
--[[
	技能：军威
	描述：结束阶段开始时，你可以将三张“锦”置入弃牌堆并选择一名角色：若如此做，该角色可以展示一张【闪】并将之交给由你选择的一名角色，否则该角色失去1点体力，你将其装备区的一张牌移出游戏：若如此做，该角色的回合结束后，将这张装备牌移回其装备区（代替原装备）。
]]--
JunWeiGot = sgs.CreateLuaSkill{
	name = "#bgmJunWeiGot",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_NotActive then
			local pile = player:getPile("bgmJunWeiPile")
			if pile:isEmpty() then
				return false
			end
			for _,id in sgs.qlist(pile) do
				local card = sgs.Sanguosha:getCard(id)
				local equip = card:toEquipCard()
				local index = equip:location()
				local moves = sgs.CardsMoveList()
				local original_equip = player:getEquip(index)
				if original_equip then
					local original_id = original_equip:getEffectiveId()
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP, player:objectName())
					local move = sgs.CardsMoveStruct(original_id, nil, sgs.Player_DiscardPile, reason)
					moves:append(move)
				end
				local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName())
				local move2 = sgs.CardsMoveStruct(id, player, sgs.Player_PlaceEquip, reason)
				moves:append(move)
				local msg = sgs.LogMessage()
				msg.type = "$bgmJunWeiGot"
				msg.from = player
				msg.card_str = id
				room:sendLog(msg)
				room:moveCardsAtomic(moves, true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["$bgmJunWeiGot"] = "%from 的装备牌 %card 被移回装备区",
	},
}
JunWeiCard = sgs.CreateSkillCard{
	name = "bgmJunWeiCard",
	skill_name = "bgmJunWei",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "bgmJunWei", "")
		room:throwCard(self, reason, nil)
		local ai_data = sgs.QVariant()
		ai_data:setValue(source)
		local card = room:askForCard(target, "Jink", "@bgmJunWei-show", ai_data, sgs.Card_MethodNone)
		if card then
			room:showCard(target, card:getEffectiveId())
			local alives = room:getAlivePlayers()
			local receiver = room:askForPlayerChosen(source, alives, "bgmJunWei", "@bgmJunWei-give")
			if receiver and receiver:objectName() ~= target:objectName() then
				room:obtainCard(receiver, card)
			end
		else
			room:loseHp(target)
			if target:isAlive() and target:hasEquip() then
				local id = room:askForCardChosen(source, target, "e", "bgmJunWei")
				if id >= 0 then
					target:addToPile("bgmJunWeiPile", id)
				end
			end
		end
	end,
}
JunWeiVS = sgs.CreateLuaSkill{
	name = "bgmJunWei",
	class = "ViewAsSkill",
	expand_pile = "brocade",
	response_pattern = "@@bgmJunWei",
	n = 3,
	view_filter = function(self, selected, to_select)
		local pile = sgs.Self:getPile("brocade")
		local id = to_select:getEffectiveId()
		return pile:contains(id)
	end,
	view_as = function(self, cards)
		local card = JunWeiCard:clone()
		for _,c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
}
JunWei = sgs.CreateLuaSkill{
	name = "bgmJunWei",
	translation = "军威",
	description = "结束阶段开始时，你可以将三张“锦”置入弃牌堆并选择一名角色：若如此做，该角色可以展示一张【闪】并将之交给由你选择的一名角色，否则该角色失去1点体力，你将其装备区的一张牌移出游戏：若如此做，该角色的回合结束后，将这张装备牌移回其装备区（代替原装备）。",
	audio = {
		"别太嚣张了！",
		"这江上，老子说的算！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = JunWeiVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:getPile("brocade"):length() >= 3 then
				local room = player:getRoom()
				room:askForUseCard(player, "@@bgmJunWei", "@bgmJunWei-invoke", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
	related_skills = JunWeiGot,
	translations = {
		["@bgmJunWei-invoke"] = "你可以发动“军威”",
		["~bgmJunWei"] = "选择一名角色→点击确定",
		["@bgmJunWei-show"] = "请展示一张【闪】",
		["@bgmJunWei-give"] = "你可以将该【闪】交给一名角色",
		["bgmJunWeiPile"] = "军威",
	},
}
--武将信息：甘宁
GanNing = sgs.CreateLuaGeneral{
	name = "bgm_ganning",
	real_name = "ganning",
	translation = "☆SP·甘宁",
	show_name = "甘宁",
	title = "怀铃的乌羽",
	kingdom = "qun",
	maxhp = 4,
	order = 9,
	designer = "飞雪",
	cv = "风叹息",
	illustrator = "张帅",
	skills = {YinLing, JunWei},
	last_word = "小的们，点子扎手，扯呼！",
	resource = "ganning",
}
--[[****************************************************************
	称号：啖睛的苍狼
	武将：夏侯惇
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：愤勇
	描述：每当你受到伤害后，你可以竖置体力牌。一名角色的结束阶段开始时，若你的体力牌处于竖置状态，你横置之。每当你受到伤害时，若你的体力牌处于竖置状态，防止此伤害。
]]--
FenYongClear = sgs.CreateLuaSkill{
	name = "#bgmFenYongClear",
	class = "DetachEffectSkill",
	skill = "bgmFenYong",
	on_skill_detached = function(self, room, player)
		player:loseAllMarks("@bgmFenYongMark")
	end,
}
FenYong = sgs.CreateLuaSkill{
	name = "bgmFenYong",
	translation = "愤勇",
	description = "每当你受到伤害后，你可以竖置体力牌。一名角色的结束阶段开始时，若你的体力牌处于竖置状态，你横置之。每当你受到伤害时，若你的体力牌处于竖置状态，防止此伤害。",
	audio = {
		"独目苍狼，虽伤亦勇！",
		"愤勇当先，鬼神难伤！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged, sgs.DamageInflicted, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			if player:isAlive() and player:hasSkill("bgmFenYong") then
				if player:getMark("@bgmFenYongMark") == 0 then
					if player:askForSkillInvoke("bgmFenYong", data) then
						room:broadcastSkillInvoke("bgmFenYong", 1)
						player:gainMark("@bgmFenYongMark")
					end
				end
			end
		elseif event == sgs.DamageInflicted then
			if player:getMark("@bgmFenYongMark") > 0 then
				room:broadcastSkillInvoke("bgmFenYong", 2)
				local msg = sgs.LogMessage()
				msg.type = "#bgmFenYongAvoid"
				msg.from = player
				msg.arg = "bgmFenYong"
				room:sendLog(msg)
				return true
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				local alives = room:getAlivePlayers()
				local thread = room:getThread()
				for _,p in sgs.qlist(alives) do
					if p:getMark("@bgmFenYongMark") > 0 then
						if p:isAlive() and p:hasSkill("bgmFenYong") then
							p:loseAllMarks("@bgmFenYongMark")
							thread:trigger(sgs.NonTrigger, room, p, sgs.QVariant("bgmFenYongReset"))
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["@bgmFenYongMark"] = "愤勇",
		["#bgmFenYongAvoid"] = "%from 的“%arg”被触发，防止了本次伤害",
	},
	related_skills = FenYongClear,
}
--[[
	技能：雪恨（锁定技）
	描述：每当你的体力牌横置时，你选择一项：
		1.弃置当前回合角色X张牌。 
		2.视为你使用一张无距离限制的【杀】。（X为你已损失的体力值）
]]--
XueHen = sgs.CreateLuaSkill{
	name = "bgmXueHen",
	translation = "雪恨",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你的体力牌横置时，你选择一项：\
		1.弃置当前回合角色X张牌。 \
		2.视为你使用一张无距离限制的【杀】。（X为你已损失的体力值）",
	audio = {
		"汝等凶逆！岂欲往生乎？！",
		"夺目之恨犹在，今必斩汝！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.NonTrigger},
	on_trigger = function(self, event, player, data)
		if data:toString() == "bgmFenYongReset" then
			room:sendCompulsoryTriggerLog(player, "bgmXueHen")
			local room = player:getRoom()
			local choices = {}
			local targets = sgs.SPlayerList()
			if sgs.Slash_IsAvailable(player) then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if player:canSlash(p, false) then
						targets:append(p)
					end
				end
			end
			local current = room:getCurrent()
			table.insert(choices, "discard")
			if not targets:isEmpty() then
				table.insert(choices, "slash")
			end
			choices = table.concat(choices, "+")
			local choice = room:askForChoice(player, "bgmXueHen", choices)
			if choice == "discard" then
				room:broadcastSkillInvoke("bgmXueHen", 1)
				room:setPlayerFlag(player, "bgmXueHen_InTempMoving")
				local dummy = sgs.DummyCard()
				local card_ids = sgs.IntList()
				local original_places = sgs.PlaceList()
				local lost = player:getLostHp()
				for i=1, lost, 1 do
					if player:canDiscard(source, "he") then
						local id = room:askForCardChosen(player, current, "he", "bgmXueHen", false, sgs.Card_MethodDiscard)
						card_ids:append(id)
						local place = room:getCardPlace(id)
						original_places:append(place)
						dummy:addSubcard(id)
						current:addToPile("#bgmXueHen", id, false)
					end
				end
				for index, id in sgs.qlist(card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					local place = original_places:at(index)
					room:moveCardTo(card, current, place, false)
				end
				room:setPlayerFlag(player, "-bgmXueHen_InTempMoving")
				if dummy:subcardsLength() > 0 then
					room:throwCard(dummy, current, player)
				end
				dummy:deleteLater()
			elseif choice == "slash" then
				room:broadcastSkillInvoke("bgmXueHen", 2)
				local victim = room:askForPlayerChosen(player, targets, "bgmXueHen", "@dummy-slash")
				if victim then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName("bgmXueHen")
					local use = sgs.CardUseStruct()
					use.from = player
					use.to:append(victim)
					use.card = slash
					room:useCard(use)
				end
			end
		end
		return false
	end,
	effect_index = function(self, player, card)
		return -2
	end,
}
--武将信息：夏侯惇
XiaHouDun = sgs.CreateLuaGeneral{
	name = "bgm_xiahoudun",
	real_name = "xiahoudun",
	translation = "☆SP·夏侯惇",
	show_name = "夏侯惇",
	title = "啖睛的苍狼",
	kingdom = "wei",
	maxhp = 4,
	order = 7,
	designer = "舟亢",
	cv = "喵小林",
	illustrator = "XXX",
	skills = {FenYong, XueHen},
	last_word = "凛然领军出，马革裹尸还……",
	resource = "xiahoudun",
	marks = {"@bgmFenYongMark"},
}
--[[****************************************************************
	☆SP武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "bgm",
	translation = "☆SP包",
	generals = {
		ZhaoYun, DiaoChan, CaoRen, PangTong, ZhangFei,
		LvMeng, LiuBei, DaQiao, GanNing, XiaHouDun,
	},
}