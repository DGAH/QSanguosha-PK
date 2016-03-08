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
WuShenMod = sgs.CreateLuaSkill{
	name = "#WuShenMod",
	class = "TargetModSkill",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("WuShen") and card:getSuit() == sgs.Card_Heart then
			return 1000
		end
		return 0
	end,
}
WuShen = sgs.CreateLuaSkill{
	name = "WuShen",
	translation = "武神",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的红心手牌视为普通【杀】。你使用红心【杀】无距离限制。",
	audio = {
		"武神现世，天下莫敌！",
		"战意，化为青龙翱翔吧！",
	},
	class = "FilterSkill",
	view_filter = function(self, to_select)
		if to_select:getSuit() == sgs.Card_Heart then
			local room = sgs.Sanguosha:currentRoom()
			local id = to_select:getEffectiveId()
			local place = room:getCardPlace(id)
			return place == sgs.Player_PlaceHand
		end
		return false
	end,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
		slash:setSkillName("WuShen")
		local id = card:getEffectiveId()
		local wrapped = sgs.Sanguosha:getWrappedCard(id)
		wrapped:takeOver(slash)
		return wrapped
	end,
	related_skills = WuShenMod,
}
--[[
	技能：武魂（锁定技）
	描述：每当你受到伤害扣减体力前，伤害来源获得等于伤害点数的“梦魇”标记。你死亡时，你选择一名存活的“梦魇”标记数最多（不为0）的角色，该角色进行判定：若结果不为【桃】或【桃园结义】，该角色死亡。
]]--
WuHunRevenge = sgs.CreateLuaSkill{
	name = "#WuHunRevenge",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			local targets = sgs.SPlayerList()
			local max_marks = 0
			for _,p in sgs.qlist(targets) do
				local num = p:getMark("@nightmare")
				if num > max_marks then
					targets = sgs.SPlayerList()
					targets:append(target)
				elseif num == max_marks then
					targets:append(p)
				end
			end
			if max_marks == 0 or targets:isEmpty() then
				return false
			end
			local target
			if targets:length() == 1 then
				target = targets:first()
			else
				target = room:askForPlayerChosen(player, targets, "WuHun", "@WuHun")
			end
			if target then
				room:notifySkillInvoked(player, "WuHun")
				local judge = sgs.JudgeStruct()
				judge.who = target
				judge.reason = "WuHun"
				judge.pattern = "Peach,GodSalvation"
				judge.good = true
				judge.negative = true
				room:judge(judge)
				if judge:isBad() then
					room:broadcastSkillInvoke("WuHun", 2)
					room:doSuperLightbox("shenguanyu", "WuHun")
					local msg = sgs.LogMessage()
					msg.type = "#WuhunRevenge"
					msg.from = player
					msg.to:append(target)
					msg.arg = max_marks
					msg.arg2 = "WuHun"
					room:sendLog(msg)
					room:killPlayer(target)
				else
					room:broadcastSkillInvoke("WuHun", 3)
					local source = room:findPlayerBySkillName("WuHun")
					if not source then
						local alives = room:getAlivePlayers()
						for _,p in sgs.qlist(alives) do
							p:loseAllMarks("@nightmare")
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("WuHun")
	end,
	translations = {
		["@WuHun"] = "请选择“梦魇”标记最多的一名其他角色",
		["#WuhunRevenge"] = "%from 的“%arg2”被触发，拥有最多“梦魇”标记的角色 %to（%arg个）死亡",
	},
}
WuHun = sgs.CreateLuaSkill{
	name = "WuHun",
	translation = "武魂",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到伤害扣减体力前，伤害来源获得等于伤害点数的“梦魇”标记。你死亡时，你选择一名存活的“梦魇”标记数最多（不为0）的角色，该角色进行判定：若结果不为【桃】或【桃园结义】，该角色死亡。",
	audio = {
		"关某记下了。",
		"我生不能啖汝之肉，死当追汝之魂！",
		"桃园之梦，再也不会回来了……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreDamageDone},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and source:objectName() ~= player:objectName() then
			local room = player:getRoom()
			room:broadcastSkillInvoke("WuHun", 1)
			room:notifySkillInvoked(player, "WuHun")
			source:gainMark("@nightmare", damage.damage)
		end
		return false
	end,
	translations = {
		["@nightmare"] = "梦魇",
	},
	related_skills = WuHunRevenge,
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
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			if player:askForSkillInvoke("SheLie", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("SheLie")
				local card_ids = room:getNCards(5)
				local suit_ids = {}
				for _,id in sgs.qlist(card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					local suit = card:getSuit()
					if not suit_ids[suit] then
						suit_ids[suit] = {}
					end
					table.insert(suit_ids[suit], id)
				end
				card_ids = sgs.IntList()
				for suit, ids in pairs(suit_ids) do
					if type(ids) == "table" then
						for _,id in ipairs(ids) do
							card_ids:append(id)
						end
					end
				end
				assert( card_ids:length() == 5 )
				local to_get = sgs.IntList()
				local to_throw = sgs.IntList()
				room:fillAG(card_ids)
				while not card_ids:isEmpty() do
					local card_id = room:askForAG(player, card_ids, false, "SheLie")
					assert( card_id >= 0 )
					local card = sgs.Sanguosha:getCard(card_id)
					local suit = card:getSuit()
					room:takeAG(player, card_id, false)
					to_get:append(card_id)
					for _,id in ipairs(suit_ids[suit]) do
						card_ids:removeOne(id)
						if id ~= card_id then
							room:takeAG(nil, id, false)
							to_throw:append(id)
						end
					end
				end
				if not to_get:isEmpty() then
					local dummy = sgs.DummyCard(to_get)
					room:obtainCard(player, dummy)
					dummy:deleteLater()
				end
				if not to_throw:isEmpty() then
					local dummy = sgs.DummyCard(to_throw)
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "SheLie", "")
					room:throwCard(dummy, reason, nil)
					dummy:deleteLater()
				end
				room:clearAG()
				return true
			end
		end
		return false
	end,
}
--[[
	技能：攻心（阶段技）
	描述：你可以观看一名其他角色的手牌，然后选择其中一张♥牌并选择一项：弃置之，或将之置于牌堆顶。
]]--
GongXinCard = sgs.CreateSkillCard{
	name = "GongXinCard",
	skill_name = "GongXin",
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
		local target = effect.to
		if target:isKongcheng() then
			return
		end
		local source = effect.from
		local room = source:getRoom()
		local heart_ids = sgs.IntList()
		local handcards = target:getHandcards()
		for _,card in sgs.qlist(handcards) do
			if card:getSuit() == sgs.Card_Heart then
				local id = card:getEffectiveId()
				heart_ids:append(id)
			end
		end
		local card_id = room:doGongxin(source, target, heart_ids)
		if card_id == -1 then
			return
		end
		local choice = room:askForChoice(source, "GongXin", "discard+put", sgs.QVariant(card_id))
		local card = sgs.Sanguosha:getCard(card_id)
		if choice == "discard" then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, source:objectName(), "", "GongXin", "")
			room:throwCard(card, reason, target, source)
		elseif choice == "put" then
			room:setPlayerFlag(source, "Global_GongxinOperator")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), "", "GongXin", "")
			room:moveCardTo(card, target, nil, sgs.Player_DrawPile, reason, true)
			room:setPlayerFlag(source, "-Global_GongxinOperator")
		end
	end,
}
GongXin = sgs.CreateLuaSkill{
	name = "GongXin",
	translation = "攻心",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以观看一名其他角色的手牌，然后选择其中一张红心牌并选择一项：弃置之，或将之置于牌堆顶。",
	audio = {
		"用兵之道，攻心为上，攻城为下",
		"心战为上，兵战为下。",
	},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return GongXinCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#GongXinCard")
	end,
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
local perform = function(room, player)
	local choices = {}
	local alives = room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		if p:isWounded() then
			table.insert(choices, "up")
			break
		end
	end
	table.insert(choices, "down")
	table.insert(choices, "cancel")
	choices = table.concat(choices, "+")
	local choice = room:askForChoice(player, "QinYin", choices)
	if choice == "cancel" then
		return
	end
	room:notifySkillInvoked(player, "QinYin")
	if choice == "up" then
		room:broadcastSkillInvoke("QinYin", 2)
		for _,p in sgs.qlist(alives) do
			if p:getLostHp() > 0 then
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(p, recover)
			end
		end
	elseif choice == "down" then
		local index = 1
		for _,p in sgs.qlist(alives) do
			if p:isGeneral("caocao", true, true) then
				index = 3
				break
			end
		end
		room:broadcastSkillInvoke("QinYin", index)
		for _,p in sgs.qlist(alives) do
			room:loseHp(p)
		end
	end
end
QinYin = sgs.CreateLuaSkill{
	name = "QinYin",
	translation = "琴音",
	description = "弃牌阶段结束时，若你于本阶段内弃置了至少两张你的牌，你可以选择一项：令所有角色各回复1点体力，或令所有角色各失去1点体力。",
	audio = {
		"捻指勾弦，气破万军！",
		"如梦似幻，拨弄乾坤！",
		"聆听吧，孟德：这首献给你的镇魂曲！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			if player:getPhase() == sgs.Player_Discard then
				local move = data:toMoveOneTime()
				local source = move.from
				if source and source:objectName() == player:objectName() then
					local basic = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
					if basic == sgs.CardMoveReason_S_REASON_DISCARD then
						room:addPlayerMark(player, "QinYinCount", move.card_ids:length())
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard then
				if player:isAlive() and player:hasSkill("QinYin") then
					if player:getMark("QinYinCount") >= 2 then
						perform(room, player)
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			room:setPlayerMark(player, "QinYinCount", 0)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	translations = {
		["QinYin:up"] = "所有角色各回复1点体力",
		["QinYin:down"] = "所有角色各失去1点体力",
		["QinYin:cancel"] = "不发动“琴音”",
	},
}
--[[
	技能：业炎（限定技）
	描述：出牌阶段，你可以对一至三名角色各造成1点火焰伤害；或你可以弃置四种花色的手牌各一张，失去3点体力并选择一至两名角色：若如此做，你对这些角色造成共计至多3点火焰伤害且对其中一名角色造成至少2点火焰伤害。
]]--
GreatYeYanCard = sgs.CreateSkillCard{
	name = "GreatYeYanCard",
	skill_name = "YeYan",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select, maxVotes)
		local vote = 0
		for _,p in ipairs(targets) do
			if to_select:objectName() == p:objectName() then
				vote = vote + 1
			end
		end
		maxVotes = math.max( 0, 3 - #targets ) + vote
		return maxVotes > 0, maxVotes
	end,
	feasible = function(self, targets)
		local set = {}
		local count = 0
		for _,p in ipairs(targets) do
			if not set[p:objectName()] then
				set[p:objectName()] = true
				count = count + 1
			end
		end
		if count == 1 then
			return true
		elseif count == 2 then
			return #targets == 3
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local map = {}
		local victims = sgs.SPlayerList()
		for _,target in ipairs(targets) do
			local point = map[target:objectName()]
			if point then
				map[target:objectName()] = point + 1
			else
				map[target:objectName()] = 1
				victims:append(target)
			end
		end
		if victims:length() == 1 then
			map[targets[1]:objectName()] = 3
			room:broadcastSkillInvoke("YeYan", 3)
		else
			room:sortByActionOrder(victims)
			room:broadcastSkillInvoke("YeYan", 2)
		end
		room:doSuperLightbox("shenzhouyu", "YeYan")
		source:loseMark("@flame")
		room:loseHp(source, 3)
		for _,victim in sgs.qlist(victims) do
			local damage = sgs.DamageStruct()
			damage.from = source
			damage.to = victim
			damage.damage = map[victim:objectName()] or 0
			damage.nature = sgs.DamageStruct_Fire
			room:damage(damage)
		end
	end,
}
SmallYeYanCard = sgs.CreateSkillCard{
	name = "SmallYeYanCard",
	skill_name = "YeYan",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets < 3
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("YeYan", 1)
		room:doSuperLightbox("shenzhouyu", "YeYan")
		source:loseMark("@flame")
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = effect.to
		damage.damage = 1
		damage.nature = sgs.DamageStruct_Fire
		room:damage(damage)
	end,
}
YeYanVS = sgs.CreateLuaSkill{
	name = "YeYan",
	class = "ViewAsSkill",
	n = 4,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		elseif sgs.Self:isJilei(to_select) then
			return false
		end
		local suit = to_select:getSuit()
		for _,card in ipairs(selected) do
			if card:getSuit() == suit then
				return false
			end
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return SmallYeYanCard:clone()
		elseif #cards == 4 then
			local card = GreatYeYanCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@flame") > 0
	end,
}
YeYan = sgs.CreateLuaSkill{
	name = "YeYan",
	translation = "业炎",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以对一至三名角色各造成1点火焰伤害；或你可以弃置四种花色的手牌各一张，失去3点体力并选择一至两名角色：若如此做，你对这些角色造成共计至多3点火焰伤害且对其中一名角色造成至少2点火焰伤害。",
	audio = {
		"血色火海，葬敌万千！",
		"浮生罪孽，皆归灰烬！",
		"红莲业火，焚尽世间万物！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	limit_mark = "@flame",
	view_as_skill = YeYanVS,
	translations = {
		["@flame"] = "业炎",
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
QiXingClear = sgs.CreateLuaSkill{
	name = "#QiXingClear",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		if data:toString() == "QiXing" then
			player:clearOnePrivatePile("stars")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
QiXingStart = sgs.CreateLuaSkill{
	name = "#QiXingStart",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawInitialCards, sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			room:sendCompulsoryTriggerLog(player, "QiXing")
			local n = data:toInt() + 7
			data:setValue(n)
		elseif event == sgs.AfterDrawInitialCards then
			room:broadcastSkillInvoke("QiXing")
			local dummy = room:askForExchange(player, "QiXing", 7, 7)
			if dummy then
				local subcards = dummy:getSubcards()
				player:addToPile("stars", subcards, false)
				dummy:deleteLater()
			end
		end
		return false
	end,
}
QiXingCard = sgs.CreateSkillCard{
	name = "QiXingCard",
	skill_name = "QiXing",
	target_fixed = true,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	about_to_use = function(self, room, use)
		local source = use.from
		local pile = source:getPile("stars")
		local subcards = self:getSubcards()
		local to_handcard = sgs.IntList()
		local to_pile = sgs.IntList()
		for _,id in sgs.qlist(subcards) do
			if not pile:contains(id) then
				to_pile:append(id)
			end
		end
		for _,id in sgs.qlist(pile) do
			if not subcards:contains(id) then
				to_handcard:append(id)
			end
		end
		if to_pile:isEmpty() or to_handcard:length() ~= to_pile:length() then
			return
		end
		room:broadcastSkillInvoke("QiXing")
		room:notifySkillInvoked(source, "QiXing")
		source:addToPile("stars", to_pile, false)
		local dummy = sgs.DummyCard(to_handcard)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, source:objectName())
		room:obtainCard(source, dummy, reason, false)
		local msg = sgs.LogMessage()
		msg.type = "#QixingExchange"
		msg.from = source
		msg.arg = to_pile:length()
		msg.arg2 = "QiXing"
		room:sendLog(msg)
	end,
}
QiXingVS = sgs.CreateLuaSkill{
	name = "QiXing",
	class = "ViewAsSkill",
	n = 999,
	expand_pile = "stars",
	response_pattern = "@@QiXing",
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		elseif #selected < sgs.Self:getPile("stars"):length() then
			return true
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == sgs.Self:getPile("stars"):length() then
			local card = QiXingCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
}
QiXing = sgs.CreateLuaSkill{
	name = "QiXing",
	translation = "七星",
	description = "你的起始手牌数+7。分发起始手牌后，你将其中七张扣置于武将牌旁，称为“星”。摸牌阶段结束时，你可以将至少一张手牌与等量的“星”交换。",
	audio = "伏望天慈，延我之寿。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	view_as_skill = QiXingVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			if player:getPile("stars"):length() > 0 then
				local room = player:getRoom()
				room:askForUseCard(player, "@@QiXing", "@QiXing", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
	translations = {
		["stars"] = "星",
		["@QiXing"] = "请选择牌用于交换",
		["~QiXing"] = "选择的牌将成为“星”",
		["#QixingExchange"] = "%from 发动了“%arg2”，交换了 %arg 张手牌",
	},
	related_skills = {QiXingStart, QiXingClear},
}
--[[
	技能：狂风
	描述：结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色：若如此做，直到你的回合开始时，火焰伤害结算开始时，此伤害+1。
]]--
KuangFengClear = sgs.CreateSkillCard{
	name = "#KuangFengClear",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local invoke = false
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				invoke = true
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				invoke = true
			end
		end
		if invoke and player:getTag("KuangFengSource"):toBool() then
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				p:loseAllMarks("@gale")
			end
			player:removeTag("KuangFengSource")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
KuangFengAsk = sgs.CreateLuaSkill{
	name = "#KuangFengAsk",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:getPile("stars"):length() > 0 then
				local room = player:getRoom()
				room:askForUseCard(player, "@@KuangFeng", "@KuangFeng", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
	translations = {
		["@KuangFeng"] = "你可以发动“狂风”",
		["~KuangFeng"] = "选择一名角色→点击确定→然后在窗口中选择一张牌",
	},
}
KuangFengCard = sgs.CreateSkillCard{
	name = "KuangFengCard",
	skill_name = "KuangFeng",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "KuangFeng", "")
		room:throwCard(self, reason, nil)
		source:setTag("KuangFengSource", sgs.QVariant(true))
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		effect.to:gainMark("@gale")
	end,
}
KuangFengVS = sgs.CreateLuaSkill{
	name = "KuangFeng",
	class = "OneCardViewAsSkill",
	response_pattern = "@@KuangFeng",
	filter_pattern = ".|.|.|stars",
	expand_pile = "stars",
	view_as = function(self, card)
		local skillcard = KuangFengCard:clone()
		skillcard:addSubcard(card)
		return skillcard
	end,
}
KuangFeng = sgs.CreateLuaSkill{
	name = "KuangFeng",
	translation = "狂风",
	description = "结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色：若如此做，直到你的回合开始时，火焰伤害结算开始时，此伤害+1。",
	audio = "万事俱备，只欠东风。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageForseen},
	view_as_skill = KuangFengVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire then
			local msg = sgs.LogMessage()
			msg.type = "#GalePower"
			msg.from = player
			local count = damage.damage
			msg.arg = count
			count = count + 1
			msg.arg2 = count
			local room = player:getRoom()
			room:sendLog(msg)
			damage.damage = count
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:getMark("@gale") > 0
	end,
	translations = {
		["@gale"] = "狂风",
		["#GalePower"] = "“<font color=\"yellow\"><b>狂风</b></font>”效果被触发，%from 的火焰伤害从 %arg 点增加至 %arg2 点",
	},
	related_skills = {KuangFengAsk, KuangFengClear},
}
--[[
	技能：大雾
	描述：结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色：若如此做，直到你的回合开始时，伤害结算开始时，防止这些角色受到的非雷电属性的伤害。
]]--
DaWuClear = sgs.CreateSkillCard{
	name = "#DaWuClear",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local invoke = false
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				invoke = true
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				invoke = true
			end
		end
		if invoke and player:getTag("DaWuSource"):toBool() then
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				p:loseAllMarks("@fog")
			end
			player:removeTag("DaWuSource")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
DaWuAsk = sgs.CreateLuaSkill{
	name = "#DaWuAsk",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:getPile("stars"):length() > 0 then
				local room = player:getRoom()
				room:askForUseCard(player, "@@DaWu", "@DaWu", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
	translations = {
		["@DaWu"] = "你可以发动“大雾”",
		["~DaWu"] = "选择若干名角色→点击确定→然后在窗口中选择相应数量的牌",
	},
}
DaWuCard = sgs.CreateSkillCard{
	name = "DaWuCard",
	skill_name = "DaWu",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets < self:subcardsLength()
	end,
	feasible = function(self, targets)
		return #targets == self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "DaWu", "")
		room:throwCard(self, reason, nil)
		source:setTag("DaWuSource", sgs.QVariant(true))
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		effect.to:gainMark("@fog")
	end,
}
DaWuVS = sgs.CreateLuaSkill{
	name = "DaWu",
	class = "ViewAsSkill",
	response_pattern = "@@DaWu",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		local pile = sgs.Self:getPile("stars")
		local card_id = to_select:getEffectiveId()
		return pile:contains(card_id)
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = DaWuCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
}
DaWu = sgs.CreateLuaSkill{
	name = "DaWu",
	translation = "大雾",
	description = "结束阶段开始时，你可以将至少一张“星”置入弃牌堆并选择等量的角色：若如此做，直到你的回合开始时，伤害结算开始时，防止这些角色受到的非雷电属性的伤害。",
	audio = {
		"一天浓雾满长江，远近难分水渺茫。",
		"返元气于洪荒，混天地为大块。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageForseen},
	view_as_skill = DaWuVS,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local nature = damage.nature
		if nature ~= sgs.DamageStruct_Thunder then
			local msg = sgs.LogMessage()
			msg.type = "#FogProtect"
			msg.from = player
			msg.arg = damage.damage
			if nature == sgs.DamageStruct_Normal then
				msg.arg2 = "normal_nature"
			elseif nature == sgs.DamageStruct_Fire then
				msg.arg2 = "fire_nature"
			end
			room:sendLog(msg)
			return true
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:getMark("@fog") > 0
	end,
	translations = {
		["@fog"] = "大雾",
		["#FogProtect"] = "%from 的“<font color=\"yellow\"><b>大雾</b></font>”效果被触发，防止了 %arg 点伤害[%arg2]",
	},
	related_skills = {DaWuAsk, DaWuClear},
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
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		local others = room:getOtherPlayers(player)
		for i=1, damage.damage, 1 do
			if player:askForSkillInvoke("GuiXin", data) then
				room:broadcastSkillInvoke("GuiXin")
				room:doSuperLightbox("shencaocao", "GuiXin")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
				for _,p in sgs.qlist(others) do
					if not p:isAllNude() then
						local id = room:askForCardChosen(player, p, "hej", "GuiXin")
						if id >= 0 then
							local card = sgs.Sanguosha:getCard(id)
							local place = room:getCardPlace(id)
							room:obtainCard(player, card, reason, place ~= sgs.Player_PlaceHand)
							if player:isDead() then
								return false
							end
						end
					end
				end
				player:turnOver()
			else
				return false
			end
		end
	end,
}
--[[
	技能：飞影（锁定技）
	描述：其他角色与你的距离+1。
]]--
FeiYing = sgs.CreateLuaSkill{
	name = "FeiYing",
	translation = "飞影",
	description = "<font color=\"blue\"><b>锁定技</b></font>，其他角色与你的距离+1。",
	class = "DistanceSkill",
	correct_func = function(self, from, to)
		if to:hasSkill("FeiYing") then
			return 1
		end
		return 0
	end,
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
KuangBaoStart = sgs.CreateMarkAssignSkill{
	name = "#KuangBaoStart",
	mark = "@wrath",
	n = 2,
}
KuangBao = sgs.CreateLuaSkill{
	name = "KuangBao",
	translation = "狂暴",
	description = "<font color=\"blue\"><b>锁定技</b></font>，游戏开始时，你获得两枚“暴怒”标记。每当你造成或受到1点伤害后，你获得一枚“暴怒”标记。",
	audio = "（嚎叫声）",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("KuangBao")
		room:notifySkillInvoked(player, "KuangBao")
		local damage = data:toDamage()
		local msg = sgs.LogMessage()
		if event == sgs.Damage then
			msg.type = "#KuangbaoDamage"
		elseif event == sgs.Damaged then
			msg.type = "#KuangbaoDamaged"
		end
		msg.from = player
		local count = damage.damage
		msg.arg = count
		msg.arg2 = "KuangBao"
		room:sendLog(msg)
		player:gainMark("@wrath", count)
		return false
	end,
	translations = {
		["@wrath"] = "暴怒",
		["#KuangbaoDamage"] = "%from 的“%arg2”被触发，造成 %arg 点伤害获得 %arg 枚“暴怒”标记",
		["#KuangbaoDamaged"] = "%from 的“%arg2”被触发，受到 %arg 点伤害获得 %arg 枚“暴怒”标记",
	},
	related_skills = KuangBaoStart,
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
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isNDTrick() then
			local room = player:getRoom()
			room:broadcastSkillInvoke("WuMou")
			room:sendCompulsoryTriggerLog(player, "WuMou")
			local mark = player:getMark("@wrath")
			local choice = "losehp"
			if mark > 0 then
				choice = room:askForChoice(player, "WuMou", "losehp+discard")
			end
			if choice == "losehp" then
				room:loseHp(player)
			elseif choice == "discard" then
				player:loseMark("@wrath")
			end
		end
		return false
	end,
}
--[[
	技能：无前
	描述：出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。
]]--
WuQianCard = sgs.CreateSkillCard{
	name = "WuQianCard",
	skill_name = "WuQian",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		source:loseMark("@wrath", 2)
		room:acquireSkill(source, "wushuang")
		room:setPlayerFlag(source, "WuQianSource")
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		room:setPlayerFlag(target, "WuQianTarget")
		room:setPlayerMark(target, "Armor_Nullified", 1)
	end,
}
WuQianVS = sgs.CreateLuaSkill{
	name = "WuQian",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return WuQianCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@wrath") >= 2
	end,
}
WuQian = sgs.CreateLuaSkill{
	name = "WuQian",
	translation = "无前",
	description = "出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。",
	audio = {
		"战神一出，天下无双！",
		"顺我者生，逆我者死！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging, sgs.Death},
	view_as_skill = WuQianVS,
	on_trigger = function(self, event, player, data)
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
		end
		if clear then
			local room = player:getRoom()
			local allplayers = room:getAllPlayers()
			for _,p in sgs.qlist(allplayers) do
				if p:hasFlag("WuQianTarget") then
					room:setPlayerFlag(p, "-WuQianTarget")
					if p:getMark("Armor_Nullified") > 0 then
						room:setPlayerMark(p, "Armor_Nullified", 0)
					end
				end
			end
			room:detachSkillFromPlayer(player, "wushuang", false, true)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasFlag("WuQianSource")
	end,
}
--[[
	技能：神愤（阶段技）
	描述：你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。
]]--
ShenFenCard = sgs.CreateSkillCard{
	name = "ShenFenCard",
	skill_name = "ShenFen",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:doSuperLightbox("shenlvbu", "ShenFen")
		source:loseMark("@wrath", 6)
		local others = room:getOtherPlayers(source)
		local thread = room:getThread()
		for _,p in sgs.qlist(others) do
			local damage = sgs.DamageStruct()
			damage.from = source
			damage.to = p
			damage.damage = 1
			room:damage(damage)
			thread:delay()
		end
		for _,p in sgs.qlist(others) do
			if p:hasEquip() then
				p:throwAllEquips()
				thread:delay()
			end
		end
		for _,p in sgs.qlist(others) do
			if not p:isKongcheng() then
				room:askForDiscard(p, "ShenFen", 4, 4)
				thread:delay()
			end
		end
		if source:isAlive() then
			source:turnOver()
		end
	end,
}
ShenFen = sgs.CreateLuaSkill{
	name = "ShenFen",
	translation = "神愤",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。",
	audio = {
		"颤抖着滚开吧杂鱼们！这天下，还有谁能满足我？",
		"战神之怒，神挡杀神，佛挡杀佛！",
	},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return ShenFenCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:getMark("@wrath") >= 6 then
			return not player:hasUsed("#ShenFenCard")
		end
		return false
	end,
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
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged, sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local count = 0
		if event == sgs.Damaged then
			local damage = data:toDamage()
			count = damage.damage
		elseif event == sgs.CardsMoveOneTime then
			if player:getPhase() == sgs.Player_Discard then
				local move = data:toMoveOneTime()
				local source = move.from
				if source and source:objectName() == player:objectName() then
					local basic = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
					if basic == sgs.CardMoveReason_S_REASON_DISCARD then
						count = move.card_ids:length()
					end
				end
			end
		end
		if count > 0 then
			room:broadcastSkillInvoke("RenJie")
			room:notifySkillInvoked(player, "RenJie")
			player:gainMark("@bear", count)
		end
		return false
	end,
	translations = {
		["@bear"] = "忍",
	},
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
	class = "TriggerSkill",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("BaiYin")
		room:notifySkillInvoked(player, "BaiYin")
		room:doSuperLightbox("shensimayi", "BaiYin")
		local msg = sgs.LogMessage()
		msg.type = "#BaiyinWake"
		msg.from = player
		msg.arg = player:getMark("@bear")
		room:sendLog(msg)
		room:setPlayerMark(player, "BaiYinWaked", 1)
		room:loseMaxHp(player)
		if player:isAlive() then
			room:acquireSkill(player, "JiLve")
			player:gainMark("@waked")
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("BaiYin") then
			if target:getMark("BaiYinWaked") == 0 then
				if target:getPhase() == sgs.Player_Start then
					return target:getMark("@bear") >= 4
				end
			end
		end
		return false
	end,
	translations = {
		["#BaiyinWake"] = "%from 的“忍”为 %arg 个，触发“<font color=\"yellow\"><b>拜印</b></font>”觉醒",
	},
}
--[[
	技能：连破
	描述：每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以进行一个额外的回合。
]]--
LianPoCount = sgs.CreateLuaSkill{
	name = "#LianPoCount",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death, sgs.TurnStart},
	global = true,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
				local current = room:getCurrent()
				if current and current:getPhase() ~= sgs.Player_NotActive then
					local reason = death.damage
					if reason then
						local killer = reason.from
						if killer then
							if current:isAlive() or victim:objectName() == current:objectName() then
								room:addPlayerMark(killer, "LianPoCount", 1)
								if killer:isAlive() and killer:hasSkill("LianPo") then
									local msg = sgs.LogMessage()
									msg.type = "#LianpoRecord"
									msg.from = killer
									msg.to:append(victim)
									msg.arg = current:getGeneralName()
									room:sendLog(msg)
								end
							end
						end
					end
				end
			end
		elseif event == sgs.TurnStart then
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				room:setPlayerMark(p, "LianPoCount", 0)
			end
		end
		return false
	end,
	translations = {
		["#LianpoRecord"] = "%from 杀死了 %to，可在 %arg 回合结束后进行一个额外的回合",
	},
}
LianPo = sgs.CreateLuaSkill{
	name = "LianPo",
	translation = "连破",
	description = "每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以进行一个额外的回合。",
	audio = "敌军已乱，乘胜追击！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,p in sgs.qlist(alives) do
				if p:hasSkill("LianPo") then
					local count = p:getMark("LianPoCount")
					if count > 0 then
						if p:askForSkillInvoke("LianPo", data) then
							local msg = sgs.LogMessage()
							msg.type = "#LianpoCanInvoke"
							msg.from = p
							msg.arg = count
							msg.arg2 = "LianPo"
							room:sendLog(msg)
							room:broadcastSkillInvoke("LianPo")
							p:gainAnExtraTurn()
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
	priority = 1,
	translations = {
		["#LianpoCanInvoke"] = "%from 在本回合内杀死了 %arg 名角色，满足“%arg2”的发动条件",
	},
	related_skills = LianPoCount,
}
--[[
	技能：极略
	描述：你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”。
]]--
JiLveCard = sgs.CreateSkillCard{
	name = "JiLveCard",
	skill_name = "JiLve_ZhiHeng",
	target_fixed = true,
	will_throw = true,
	mute = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("JiLve", 4)
		source:loseMark("@bear")
		if source:isAlive() then
			room:drawCards(source, self:subcardsLength(), "JiLve")
		end
	end,
}
JiLveVS = sgs.CreateLuaSkill{
	name = "JiLve",
	class = "ViewAsSkill",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = JiLveCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:getMark("@bear") == 0 then
			return false
		elseif player:hasUsed("#JiLveCard") then
			return false
		elseif player:canDiscard(player, "he") then
			return true
		end
		return false
	end,
}
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
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial, sgs.Damaged, sgs.CardUsed},
	view_as_skill = JiLveVS,
	on_trigger = function(self, event, player, data)
		if player:getMark("@bear") == 0 then
			return false
		end
		local room = player:getRoom()
		if event == sgs.AskForRetrial then
			local judge = data:toJudge()
			local prompt = string.format("@JiLve_GuiCai:%s::%s", judge.who:objectName(), judge.reason)
			local card = room:askForCard(player, ".", prompt, data, sgs.Card_MethodResponse, judge.who, true, "JiLve_GuiCai")
			if card then
				room:broadcastSkillInvoke("JiLve", 1)
				room:notifySkillInvoked(player, "JiLve")
				player:loseMark("@bear")
				room:retrial(card, player, judge, "JiLve", false)
			end
		elseif event == sgs.Damaged then
			local others = room:getOtherPlayers(player)
			local target = room:askForPlayerChosen(player, others, "JiLve_FangZhu", "@JiLve_FangZhu", true, true)
			if target then
				room:broadcastSkillInvoke("JiLve", 2)
				room:notifySkillInvoked(player, "JiLve")
				player:loseMark("@bear")
				local x = player:getLostHp()
				room:drawCards(target, x, "JiLve")
				target:turnOver()
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isNDTrick() then
				if player:askForSkillInvoke("JiLve_JiZhi", data) then
					room:broadcastSkillInvoke("JiLve", 5)
					room:notifySkillInvoked(player, "JiLve")
					player:loseMark("@bear")
					room:drawCards(player, 1, "JiLve")
				end
			end
		end
		return false
	end,
	translations = {
		["JiLve_GuiCai"] = "极略·鬼才",
		["@JiLve_GuiCai"] = "您可以发动“极略·鬼才”来修改 %src 的 %arg 判定",
		["JiLve_FangZhu"] = "极略·放逐",
		["@JiLve_FangZhu"] = "您可以选择一名其他角色，对其发动“极略·放逐”",
		["JiLve_JiZhi"] = "极略·集智",
		["JiLve_ZhiHeng"] = "极略·制衡",
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