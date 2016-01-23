sgs.ai_skill_cardask["@renxin-card"] = function(self, data, pattern)
	local dmg = data:toDamage()
	local invoke
	if self:isFriend(dmg.to) then
		if self:damageIsEffective_(dmg) and not self:getDamagedEffects(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash"))
			and not self:needToLoseHp(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash")) then
			invoke = true
		elseif not self:toTurnOver(self.player) then
			invoke = true
		end
	elseif self:objectiveLevel(dmg.to) == 0 and not self:toTurnOver(self.player) then
		invoke = true
	end
	if invoke then
		local equipCards = {}
		for _, c in sgs.qlist(self.player:getCards("he")) do
			if c:isKindOf("EquipCard") and self.player:canDiscard(self.player, c:getEffectiveId()) then
				table.insert(equipCards, c)
			end
		end
		if #equipCards > 0 then
			self:sortByKeepValue(equipCards)
			return equipCards[1]:getEffectiveId()
		end
	end
	return "."
end

sgs.ai_skill_invoke.jingce = function(self, data)
	return not self:needKongcheng(self.player, true)
end

local junxing_skill = {}
junxing_skill.name = "junxing"
table.insert(sgs.ai_skills, junxing_skill)
junxing_skill.getTurnUseCard = function(self)
	if self.player:isKongcheng() or self.player:hasUsed("JunxingCard") then return nil end
	return sgs.Card_Parse("@JunxingCard=.")
end

sgs.ai_skill_use_func.JunxingCard = function(card, use, self)
	-- find enough cards
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())
	local use_slash_num = 0
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:isKindOf("Slash") then
			local will_use = false
			if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
				local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
					will_use = true
					use_slash_num = use_slash_num + 1
				end
			end
			if not will_use then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local num = self:getCardsNum("Jink") - 1
	if self.player:getArmor() then num = num + 1 end
	if num > 0 then
		for _, card in ipairs(cards) do
			if card:isKindOf("Jink") and num > 0 then
				table.insert(unpreferedCards, card:getId())
				num = num - 1
			end
		end
	end
	for _, card in ipairs(cards) do
		if card:isKindOf("EquipCard") then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	for _, card in ipairs(cards) do
		if card:isNDTrick() or card:isKindOf("Lightning") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end
	if #use_cards == 0 then return end

	-- to friends
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if not self:toTurnOver(friend, #use_cards) then
			use.card = sgs.Card_Parse("@JunxingCard=" .. table.concat(use_cards, "+"))
			if use.to then use.to:append(friend) end
			return
		end
	end
	if #use_cards >= 3 then
		for _, friend in ipairs(self.friends_noself) do
			if friend:getHandcardNum() <= 1 and not self:needKongcheng(friend) then
				use.card = sgs.Card_Parse("@JunxingCard=" .. table.concat(use_cards, "+"))
				if use.to then use.to:append(friend) end
				return
			end
		end
	end

	-- to enemies
	local basic, trick, equip
	for _, id in ipairs(use_cards) do
		local typeid = sgs.Sanguosha:getEngineCard(id):getTypeId()
		if not basic and typeid == sgs.Card_TypeBasic then basic = id
		elseif not trick and typeid == sgs.Card_TypeTrick then trick = id
		elseif not equip and typeid == sgs.Card_TypeEquip then equip = id
		end
		if basic and trick and equip then break end
	end
	self:sort(self.enemies, "handcard")
	local other_enemy
	for _, enemy in ipairs(self.enemies) do
		local id = nil
		if self:toTurnOver(enemy, 1) then
			if getKnownCard(enemy, self.player, "BasicCard") == 0 then id = equip or trick end
			if not id and getKnownCard(enemy, self.player, "TrickCard") == 0 then id = equip or basic end
			if not id and getKnownCard(enemy, self.player, "EquipCard") == 0 then id = trick or basic end
			if id then
				use.card = sgs.Card_Parse("@JunxingCard=" .. id)
				if use.to then use.to:append(enemy) end
				return
			elseif not other_enemy then
				other_enemy = enemy
			end
		end
	end
	if other_enemy then
		use.card = sgs.Card_Parse("@JunxingCard=" .. use_cards[1])
		if use.to then use.to:append(other_enemy) end
		return
	end
end

sgs.ai_use_priority.JunxingCard = 1.2
sgs.ai_card_intention.JunxingCard = function(self, card, from, tos)
	local to = tos[1]
	if not to:faceUp() then
		sgs.updateIntention(from, to, -80)
	else
		if to:getHandcardNum() <= 1 and card:subcardsLength() >= 3 then
			sgs.updateIntention(from, to, -40)
		else
			sgs.updateIntention(from, to, 80)
		end
	end
end

sgs.ai_skill_cardask["@junxing-discard"] = function(self, data, pattern)
	local manchong = self.room:findPlayerBySkillName("junxing")
	if manchong and self:isFriend(manchong) then return "." end

	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end

sgs.ai_skill_cardask["@yuce-show"] = function(self, data)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if not damage.from or damage.from:isDead() then return "." end
	if self:isFriend(damage.from) then return "$" .. self.player:handCards():first() end
	local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), damage.from:objectName())
	local types = { sgs.Card_TypeBasic, sgs.Card_TypeEquip, sgs.Card_TypeTrick }
	for _, card in sgs.qlist(damage.from:getHandcards()) do
		if card:hasFlag("visible") or card:hasFlag(flag) then
			table.removeOne(types, card:getTypeId())
		end
		if #types == 0 then break end
	end
	if #types == 0 then types = { sgs.Card_TypeBasic } end
	for _, card in sgs.qlist(self.player:getHandcards()) do
		for _, cardtype in ipairs(types) do
			if card:getTypeId() == cardtype then return "$" .. card:getEffectiveId() end
		end
	end
	return "$" .. self.player:handCards():first()
end

sgs.ai_skill_cardask["@yuce-discard"] = function(self, data, pattern, target)
	if target and self:isFriend(target) then return "." end
	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end

sgs.ai_skill_use["@@xiansi"] = function(self, prompt)
	local crossbow_effect
	if not self.player:getTag("HuashenSkill"):toString() == "xiansi" then
		for _, enemy in ipairs(self.enemies) do
			if enemy:inMyAttackRange(self.player) and (self:hasCrossbowEffect(enemy) or getKnownCard(enemy, self.player, "Crossbow") > 0) then
				crossbow_effect = true
				break
			end
		end
	end
	local max_num = 999
	if crossbow_effect then max_num = 3
	elseif self:getCardsNum("Jink") < 1 or self:isWeak() then max_num = 5 end
	if self.player:getPile("counter"):length() >= max_num then return "." end
	local rest_num = math.min(2, max_num - self.player:getPile("counter"):length())
	local targets = {}

	local add_player = function(player, isfriend)
		if player:getHandcardNum() == 0 or player:objectName() == self.player:objectName() then return #targets end
		if self:objectiveLevel(player) == 0 and player:isLord() and sgs.current_mode_players["rebel"] > 1 then return #targets end
		if #targets == 0 then
			table.insert(targets, player:objectName())
		elseif #targets == 1 then
			if player:objectName() ~= targets[1] then
				table.insert(targets, player:objectName())
			end
		end
		if isfriend and isfriend == 1 then
			self.player:setFlags("AI_XiansiToFriend_" .. player:objectName())
		end
		return #targets
	end

	local player = self:findPlayerToDiscard("he", true, false)
	if player then
		if rest_num == 1 then return "@XiansiCard=.->" .. player:objectName() end
		add_player(player, self:isFriend(player) and 1 or nil)
		local another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(player))
		if another then
			add_player(another, self:isFriend(another) and 1 or nil)
			return "@XiansiCard=.->" .. table.concat(targets, "+")
		end
	end

	local lord = self.room:getLord()
	if lord and self:isEnemy(lord) and sgs.turncount <= 1 and not lord:isNude() then
		if add_player(lord) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
	end

	local zhugeliang = self.room:findPlayerBySkillName("kongcheng")
	local luxun = self.room:findPlayerBySkillName("lianying")
	local dengai = self.room:findPlayerBySkillName("tuntian")
	local jiangwei = self.room:findPlayerBySkillName("zhiji")

	if jiangwei and self:isFriend(jiangwei) and jiangwei:getMark("zhiji") == 0 and jiangwei:getHandcardNum()== 1
		and self:getEnemyNumBySeat(self.player, jiangwei) <= (jiangwei:getHp() >= 3 and 1 or 0) then
		if add_player(jiangwei, 1) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
	end
	if dengai and dengai:hasSkill("zaoxian") and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0)
		and dengai:getMark("zaoxian") == 0 and dengai:getPile("field"):length() == 2 and add_player(dengai, 1) == rest_num then
		return "@XiansiCard=.->" .. table.concat(targets, "+")
	end

	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, zhugeliang) > 0 then
		if zhugeliang:getHp() <= 2 then
			if add_player(zhugeliang, 1) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
		else
			local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), zhugeliang:objectName())
			local cards = sgs.QList2Table(zhugeliang:getHandcards())
			if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
				if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
					if add_player(zhugeliang, 1) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
				end
			end
		end
	end

	if luxun and self:isFriend(luxun) and luxun:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, luxun) > 0 then
		local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), luxun:objectName())
		local cards = sgs.QList2Table(luxun:getHandcards())
		if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
			if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
				if add_player(luxun, 1) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
			end
		end
	end

	if luxun and add_player(luxun, (self:isFriend(luxun) and 1 or nil)) == rest_num then
		return "@XiansiCard=.->" .. table.concat(targets, "+")
	end

	if dengai and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0) and add_player(dengai, 1) == rest_num then
		return "@XiansiCard=.->" .. table.concat(targets, "+")
	end

	if #targets == 1 then
		local target = findPlayerByObjectName(self.room, targets[1])
		if target then
			local another
			if rest_num > 1 then another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(target)) end
			if another then
				add_player(another, self:isFriend(another) and 1 or nil)
				return "@XiansiCard=.->" .. table.concat(targets, "+")
			else
				return "@XiansiCard=.->" .. targets[1]
			end
		end
	end
	return "."
end

sgs.ai_card_intention.XiansiCard = function(self, card, from, tos)
	local lord = self.room:getLord()
	if sgs.evaluatePlayerRole(from) == "neutral" and sgs.evaluatePlayerRole(tos[1]) == "neutral"
		and (not tos[2] or sgs.evaluatePlayerRole(tos[2]) == "neutral") and lord and not lord:isNude()
		and self:doNotDiscard(lord, "he", true) and from:aliveCount() >= 4 then
		sgs.updateIntention(from, lord, -35)
		return
	end
	if from:getState() == "online" then
		for _, to in ipairs(tos) do
			if (self:hasSkills("kongcheng|zhiji|lianying", to) and to:getHandcardNum() == 1) or to:hasSkills("tuntian+zaoxian") then
			else
				sgs.updateIntention(from, to, 80)
			end
		end
	else
		for _, to in ipairs(tos) do
			local intention = from:hasFlag("AI_XiansiToFriend_" .. to:objectName()) and -5 or 80
			sgs.updateIntention(from, to, intention)
		end
	end
end

local getXiansiCard = function(pile)
	if #pile > 1 then return pile[1], pile[2] end
	return nil
end

local xiansi_slash_skill = {}
xiansi_slash_skill.name = "xiansi_slash"
table.insert(sgs.ai_skills, xiansi_slash_skill)
xiansi_slash_skill.getTurnUseCard = function(self)
	if not self:slashIsAvailable() then return end
	local liufeng = self.room:findPlayerBySkillName("xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return end
	local ints = sgs.QList2Table(liufeng:getPile("counter"))
	local a, b = getXiansiCard(ints)
	if a and b then
		return sgs.Card_Parse("@XiansiSlashCard=" .. tostring(a) .. "+" .. tostring(b))
	end
end

sgs.ai_skill_use_func.XiansiSlashCard = function(card, use, self)
	local liufeng = self.room:findPlayerBySkillName("xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return "." end
	local slash = sgs.Sanguosha:cloneCard("slash")

	if self:slashIsAvailable() and not self:slashIsEffective(slash, liufeng, self.player) and self:isFriend(liufeng) then
		sgs.ai_use_priority.XiansiSlashCard = 0.1
		use.card = card
		if use.to then use.to:append(liufeng) end
	else
		sgs.ai_use_priority.XiansiSlashCard = 2.6
		local dummy_use = { to = sgs.SPlayerList() }
		self:useCardSlash(slash, dummy_use)
		if dummy_use.card then
			if (dummy_use.card:isKindOf("GodSalvation") or dummy_use.card:isKindOf("Analeptic") or dummy_use.card:isKindOf("Weapon"))
				and self:getCardsNum("Slash") > 0 then
				use.card = dummy_use.card
				if use.to then use.to:append(liufeng) end
			else
				if dummy_use.card:isKindOf("Slash") and dummy_use.to:length() > 0 then
					local lf
					for _, p in sgs.qlist(dummy_use.to) do
						if p:objectName() == liufeng:objectName() then
							lf = true
							break
						end
					end
					if lf then 
						use.card = card
						if use.to then use.to:append(liufeng) end
					end
				end
			end
		end
	end
	if not use.card then
		sgs.ai_use_priority.XiansiSlashCard = 2.0
		if self:slashIsAvailable() and self:isEnemy(liufeng)
			and not self:slashProhibit(slash, liufeng) and self:slashIsEffective(slash, liufeng) and sgs.isGoodTarget(liufeng, self.enemies, self) then
			use.card = card
			if use.to then use.to:append(liufeng) end
		end
	end
end

sgs.ai_card_intention.XiansiSlashCard = function(self, card, from, tos)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if not self:slashIsEffective(slash, tos[1], from) then
		sgs.updateIntention(from, tos[1], -30)
	else
		return sgs.ai_card_intention.Slash(self, slash, from, tos)
	end
end

sgs.ai_skill_cardask["@longyin"] = function(self, data)
	local function getLeastValueCard(isRed)
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		if self.player:getPhase() > sgs.Player_Play then
			local cards = sgs.QList2Table(self.player:getHandcards())
			self:sortByKeepValue(cards)
			for _, c in ipairs(cards) do
				if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
			end
			if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
			if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < 5 then return "$" .. self.player:getWeapon():getEffectiveId() end
		else
			local slashc
			local cards = sgs.QList2Table(self.player:getHandcards())
			self:sortByUseValue(cards)
			for _, c in ipairs(cards) do
				if self:getUseValue(c) < 6 and not self:isValuableCard(c) and not self.player:isJilei(c) then
					if isCard("Slash", c, self.player) then
						if not slashc then slashc = c end
					else
						return "$" .. c:getEffectiveId()
					end
				end
			end
			if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
			if isRed and slashc then return "$" .. slashc:getEffectiveId() end
		end
	end
	local use = data:toCardUse()
	local slash = use.card
	local slash_num = 0
	if use.from:objectName() == self.player:objectName() then slash_num = self:getCardsNum("Slash") else slash_num = getCardsNum("Slash", use.from, self.player) end
	if self:isEnemy(use.from) and use.m_addHistory and not self:hasCrossbowEffect(use.from) and slash_num > 0 then return "." end
	if (slash:isRed() and not hasManjuanEffect(self.player))
		or (use.m_reason == sgs.CardUseStruct_CARD_USE_REASON_PLAY and use.m_addHistory and self:isFriend(use.from) and slash_num >= 1
			and (not self:hasCrossbowEffect(use.from) or slash:isRed())) then
		local str = getLeastValueCard(slash:isRed())
		if str then return str end
	end
	return "."
end

sgs.ai_skill_use["@@qiaoshui"] = function(self, prompt)
	local trick_num = 0
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isNDTrick() and not card:isKindOf("Nullification") then trick_num = trick_num + 1 end
	end
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()

	for _, enemy in ipairs(self.enemies) do
		if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
			local enemy_max_card = self:getMaxCard(enemy)
			local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
			if max_point > enemy_max_point then
				self.qiaoshui_card = max_card:getEffectiveId()
				return "@QiaoshuiCard=.->" .. enemy:objectName()
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
			if max_point >= 10 then
				self.qiaoshui_card = max_card:getEffectiveId()
				return "@QiaoshuiCard=.->" .. enemy:objectName()
			end
		end
	end

	self:sort(self.friends_noself, "handcard")
	for index = #self.friends_noself, 1, -1 do
		local friend = self.friends_noself[index]
		if not friend:isKongcheng() then
			local friend_min_card = self:getMinCard(friend)
			local friend_min_point = friend_min_card and friend_min_card:getNumber() or 100
			if max_point > friend_min_point then
				self.qiaoshui_card = max_card:getEffectiveId()
				return "@QiaoshuiCard=.->" .. friend:objectName()
			end
		end
	end

	local zhugeliang = self.room:findPlayerBySkillName("kongcheng")
	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and zhugeliang:objectName() ~= self.player:objectName() then
		if max_point >= 7 then
			self.qiaoshui_card = max_card:getEffectiveId()
			return "@QiaoshuiCard=.->" .. zhugeliang:objectName()
		end
	end

	for index = #self.friends_noself, 1, -1 do
		local friend = self.friends_noself[index]
		if not friend:isKongcheng() then
			if max_point >= 7 then
				self.qiaoshui_card = max_card:getEffectiveId()
				return "@QiaoshuiCard=.->" .. friend:objectName()
			end
		end
	end

	if trick_num == 0 or (trick_num <= 2 and self.player:hasSkill("zongshih")) and not self:isValuableCard(max_card) then
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() and self:hasLoseHandcardEffective(enemy) then
				self.qiaoshui_card = max_card:getEffectiveId()
				return "@QiaoshuiCard=.->" .. enemy:objectName()
			end
		end
	end
	return "."
end

sgs.ai_card_intention.QiaoshuiCard = 0

sgs.ai_skill_choice.qiaoshui = function(self, choices, data)
	local use = data:toCardUse()
	if use.card:isKindOf("Collateral") then
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardCollateral(use.card, dummy_use)
		if dummy_use.card and dummy_use.to:length() == 2 then
			local first = dummy_use.to:at(0):objectName()
			local second = dummy_use.to:at(1):objectName()
			self.qiaoshui_collateral = { first, second }
			return "add"
		else
			self.qiaoshui_collateral = nil
		end
	elseif use.card:isKindOf("Analeptic") then
	elseif use.card:isKindOf("Peach") then
		self:sort(self.friends_noself, "hp")
		for _, friend in ipairs(self.friends_noself) do
			if friend:isWounded() and friend:getHp() < getBestHp(friend) then
				self.qiaoshui_extra_target = friend
				return "add"
			end
		end
	elseif use.card:isKindOf("ExNihilo") then
		local friend = self:findPlayerToDraw(false, 2)
		if friend then
			self.qiaoshui_extra_target = friend
			return "add"
		end
	elseif use.card:isKindOf("GodSalvation") then
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if enemy:isWounded() and self:hasTrickEffective(use.card, enemy, self.player) then
				self.qiaoshui_remove_target = enemy
				return "remove"
			end
		end
	elseif use.card:isKindOf("AmazingGrace") then
		self:sort(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:hasTrickEffective(use.card, enemy, self.player) and not hasManjuanEffect(enemy)
				and not self:needKongcheng(enemy, true) then
				self.qiaoshui_remove_target = enemy
				return "remove"
			end
		end
	elseif use.card:isKindOf("AOE") then
		self:sort(self.friends_noself)
		local lord = self.room:getLord()
		if lord and lord:objectName() ~= self.player:objectName() and self:isFriend(lord) and self:isWeak(lord) then
			self.qiaoshui_remove_target = lord
			return "remove"
		end
		for _, friend in ipairs(self.friends_noself) do
			if self:hasTrickEffective(use.card, friend, self.player) then
				self.qiaoshui_remove_target = friend
				return "remove"
			end
		end
	elseif use.card:isKindOf("Snatch") or use.card:isKindOf("Dismantlement") then
		local trick = sgs.Sanguosha:cloneCard(use.card:objectName(), use.card:getSuit(), use.card:getNumber())
		trick:setSkillName("qiaoshui")
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardSnatchOrDismantlement(trick, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	elseif use.card:isKindOf("Slash") then
		local slash = sgs.Sanguosha:cloneCard(use.card:objectName(), use.card:getSuit(), use.card:getNumber())
		slash:setSkillName("qiaoshui")
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardSlash(slash, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	else
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardByClassName(use.card, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	end
	self.qiaoshui_extra_target = nil
	self.qiaoshui_remove_target = nil
	return "cancel"
end

sgs.ai_skill_playerchosen.qiaoshui = function(self, targets)
	if not self.qiaoshui_extra_target and not self.qiaoshui_remove_target then self.room:writeToConsole("Qiaoshui player chosen error!!") end
	return self.qiaoshui_extra_target or self.qiaoshui_remove_target
end

sgs.ai_skill_use["@@qiaoshui!"] = function(self, prompt) -- extra target for Collateral
	if not self.qiaoshui_collateral then self.room:writeToConsole("Qiaoshui player chosen error!!") end
	return "@ExtraCollateralCard=.->" .. self.qiaoshui_collateral[1] .. "+" .. self.qiaoshui_collateral[2]
end

sgs.ai_skill_invoke.zongshih = function(self, data)
	return not self:needKongcheng(self.player, true)
end

sgs.ai_skill_cardask["@duodao-get"] = function(self, data)
	local function getLeastValueCard(from)
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		for _, c in ipairs(cards) do
			if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
		end
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
		if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < self:evaluateWeapon(from:getWeapon()) then
			return "$" .. self.player:getWeapon():getEffectiveId()
		end
	end
	local damage = data:toDamage()
	if not damage.from or not damage.from:getWeapon() then
		if self:needToThrowArmor() then
			return "$" .. self.player:getArmor():getEffectiveId()
		elseif self.player:getHandcardNum() == 1 and (self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0)) then
			return "$" .. self.player:handCards():first()
		end
	else
		if self:isFriend(damage.from) then
			if damage.from:hasSkills("kofxiaoji|xiaoji") and self:isWeak(damage.from) then
				local str = getLeastValueCard(damage.from)
				if str then return str end
			else
				if self:getCardsNum("Slash") == 0 or self:willSkipPlayPhase() then return "." end
				local invoke = false
				local range = sgs.weapon_range[damage.from:getWeapon():getClassName()] or 0
				if self.player:hasSkill("anjian") then
					for _, enemy in ipairs(self.enemies) do
						if not enemy:inMyAttackRange(self.player) and not self.player:inMyAttackRange(enemy) and self.player:distanceTo(enemy) <= range then
							invoke = true
							break
						end
					end
				end
				if not invoke and self:evaluateWeapon(damage.from:getWeapon()) > 8 then invoke = true end
				if invoke then
					local str = getLeastValueCard(damage.from)
					if str then return str end
				end
			end
		else
			if damage.from:hasSkill("nosxuanfeng") then
				for _, friend in ipairs(self.friends) do
					if self:isWeak(friend) then return "." end
				end
			else
				if hasManjuanEffect(self.player) then
					if self:needToThrowArmor() and not self.player:isJilei(self.player:getArmor()) then
						return "$" .. self.player:getArmor():getEffectiveId()
					elseif self.player:getHandcardNum() == 1
							and (self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0))
							and not self.player:isJilei(self.player:getHandcards():first()) then
						return "$" .. self.player:handCards():first()
					end
				else
					local str = getLeastValueCard(damage.from)
					if str then return str end
				end
			end
		end
	end
	return "."
end

local danshou_skill = {}
danshou_skill.name = "danshou"
table.insert(sgs.ai_skills, danshou_skill)
danshou_skill.getTurnUseCard = function(self)
	local times = self.player:getMark("danshou") + 1
	if times > self.player:getCardCount(true) then return false end
	local cards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
		cards:append(sgs.Sanguosha:getCard(id))
	end
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	if times == 1 then
		local has_weapon = false

		for _, card in ipairs(cards) do
			if card:isKindOf("Weapon") and card:isBlack() then has_weapon = true end
		end

		for _, card in ipairs(cards) do
			if self.player:canDiscard(self.player, card:getEffectiveId()) and ((self:getUseValue(card) < sgs.ai_use_value.Dismantlement + 1) or self:getOverflow() > 0) then
				local shouldUse = true

				if card:isKindOf("Armor") then
					if not self.player:getArmor() then shouldUse = false
					elseif self.player:hasEquip(card) and not (card:isKindOf("SilverLion") and self.player:isWounded()) then shouldUse = false
					end
				end

				if card:isKindOf("Weapon") then
					if not self.player:getWeapon() then shouldUse = false
					elseif self.player:hasEquip(card) and not has_weapon then shouldUse = false
					end
				end

				if card:isKindOf("Slash") then
					local dummy_use = { isDummy = true }
					if self:getCardsNum("Slash") == 1 then
						self:useBasicCard(card, dummy_use)
						if dummy_use.card then shouldUse = false end
					end
				end

				if self:getUseValue(card) > sgs.ai_use_value.Dismantlement + 1 and card:isKindOf("TrickCard") then
					local dummy_use = { isDummy = true }
					self:useTrickCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end

				if shouldUse then
					local card_id = card:getEffectiveId()
					local card_str = ("@DanshouCard=" .. card_id)
					local danshou = sgs.Card_Parse(card_str)
					assert(danshou)
					return danshou
				end
			end
		end
	elseif times == 3 then
		return sgs.Card_Parse("@DanshouCard=.")
	elseif times == 4 or times == 2 then
		local to_discard = {}
		local jink_num = self:getCardsNum("Jink")
		for _, c in ipairs(cards) do
			if not isCard("Peach", c, self.player) and self.player:canDiscard(self.player, c:getEffectiveId()) then
				if isCard("Jink", c, self.player) then
					if jink_num <= 1 then continue end
					jink_num = jink_num - 1
				end
				table.insert(to_discard, c:getEffectiveId())
				if #to_discard == times then break end
			end
		end
		if #to_discard == times then
			return sgs.Card_Parse("@DanshouCard=" .. table.concat(to_discard, "+"))
		end
	end
	return false
end

sgs.ai_skill_use_func.DanshouCard = function(card, use, self)
	local times = self.player:getMark("danshou") + 1
	if times == 1 then
		self:useCardSnatchOrDismantlement(card, use)
		return
	elseif times == 2 then
		self:sort(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if not self:needToThrowArmor(enemy) then
				use.card = card
				if use.to then use.to:append(enemy) end
				return
			end
		end
	elseif times == 3 then
		local cards = self.player:getCards("he")
		for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
			cards:append(sgs.Sanguosha:getCard(id))
		end
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards, true)
		local to_discard = {}
		local jink_num = self:getCardsNum("Jink")
		for _, c in ipairs(cards) do
			if not isCard("Peach", c, self.player) and self.player:canDiscard(self.player, c:getEffectiveId()) then
				if isCard("Jink", c, self.player) then
					if jink_num <= 1 then continue end
					jink_num = jink_num - 1
				end
				table.insert(to_discard, c:getEffectiveId())
				if #to_discard == 3 then break end
			end
		end
		if #to_discard == 3 then
			self:sort(self.enemies)
			for _, enemy in ipairs(self.enemies) do
				if self:damageIsEffective(enemy, nil, self.player) and not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player)
					and (enemy:getHp() == 1 or self:getOverflow() > 1) then
					use.card = sgs.Card_Parse("@DanshouCard=" .. table.concat(to_discard, "+"))
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	elseif times == 4 then
		local friend = self:findPlayerToDraw(false, 2)
		if friend then
			use.card = card
			if use.to then use.to:append(friend) end
			return
		end
	end
end

sgs.ai_use_priority.DanshouCard = sgs.ai_use_priority.Dismantlement + 1
sgs.ai_use_value.DanshouCard = sgs.ai_use_value.Dismantlement + 1
sgs.ai_card_intention.DanshouCard = function(self, card, from, tos)
	local num = card:subcardsLength()
	if num == 2 or num == 3 then
		sgs.updateIntentions(from, tos, 10)
	elseif num == 4 then
		sgs.updateIntentions(from, tos, -10)
	end
end

sgs.ai_choicemade_filter.cardChosen.danshou = sgs.ai_choicemade_filter.cardChosen.snatch


sgs.ai_skill_use["@@zongxuan"] = function(self, prompt)
	if self.top_draw_pile_id or self.player:getPhase() >= sgs.Player_Finish then return "." end
	local list = self.player:property("zongxuan"):toString():split("+")
	local valuable
	for _, id in ipairs(list) do
		local card_id = tonumber(id)
		local card = sgs.Sanguosha:getCard(card_id)
		if card:isKindOf("EquipCard") then
			for _, friend in ipairs(self.friends) do
				if not (card:isKindOf("Armor") and not friend:getArmor() and friend:hasSkills("bazhen|yizhong"))
					and (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse")
						or (card:isKindOf("Weapon") and self:evaluateWeapon(card) > self:evaluateWeapon(friend:getWeapon()) - 1)) then
					self.top_draw_pile_id = card_id
					return "@ZongxuanCard=" .. card_id
				end
			end
		elseif self:isValuableCard(card) and not valuable then
			valuable = card_id
		end
	end
	if valuable then
		self.top_draw_pile_id = valuable
		return "@ZongxuanCard=" .. valuable
	end
	return "."
end

sgs.ai_skill_playerchosen.zhiyan = function(self, targets)
	if self.top_draw_pile_id then
		local card = sgs.Sanguosha:getCard(self.top_draw_pile_id)
		if card:isKindOf("EquipCard") then
			self:sort(self.friends, "hp")
			for _, friend in ipairs(self.friends) do
				if (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse"))
					and not (card:isKindOf("Armor") and (friend:hasSkills("bazhen|yizhong") or self:evaluateArmor(card, friend) < 0)) then
					return friend
				end
			end
			if not (card:isKindOf("Armor") and (self.player:hasSkills("bazhen|yizhong") or self:evaluateArmor(card) < 0))
				and not (card:isKindOf("Weapon") and self.player:getWeapon() and self:evaluateWeapon(card) < self:evaluateWeapon(self.player:getWeapon()) - 1) then
				return self.player
			end
		else
			local cards = { card }
			local card, player = self:getCardNeedPlayer(cards)
			if player then
				return player
			else
				self:sort(self.friends)
				for _, friend in ipairs(self.friends) do
					if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then return friend end
				end
			end
		end
	else
		self:sort(self.friends)
		for _, friend in ipairs(self.friends) do
			if not self:needKongcheng(friend, true) and not hasManjuanEffect(friend) then return friend end
		end
	end
	return nil
end

sgs.ai_playerchosen_intention.zhiyan = -60



sgs.ai_skill_invoke.zhuikong = function(self, data)
	if self.player:getHandcardNum() <= (self:isWeak() and 3 or 1) then return false end
	local current = self.room:getCurrent()
	if not current or self:isFriend(current) then return false end

	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	if self.player:hasSkill("yingyang") then max_point = math.min(max_point + 3, 13) end
	if not (current:hasSkill("zhiji") and current:getMark("zhiji") == 0 and current:getHandcardNum() == 1) then
		local enemy_max_card = self:getMaxCard(current)
		local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
		if enemy_max_card and current:hasSkill("yingyang") then enemy_max_point = math.min(enemy_max_point + 3, 13) end
		if max_point > enemy_max_point or max_point > 10 then
			self.zhuikong_card = max_card:getEffectiveId()
			return true
		end
	end
	if current:distanceTo(self.player) == 1 and not self:isValuableCard(max_card) then
		self.zhuikong_card = max_card:getEffectiveId()
		return true
	end
	return false
end

sgs.ai_skill_playerchosen.qiuyuan = sgs.ai_skill_playerchosen.nosqiuyuan

sgs.ai_skill_cardask["@qiuyuan-give"] = sgs.ai_skill_cardask["@nosqiuyuan-give"]

function sgs.ai_slash_prohibit.qiuyuan(self, from, to)
	if self:isFriend(to, from) then return false end
	if from:hasFlag("NosJiefanUsed") then return false end
	for _, friend in ipairs(self:getFriendsNoself(from)) do
		if not (to:getHandcardNum() == 1 and (to:hasSkill("kongcheng") or (to:hasSkill("zhiji") and to:getMark("zhiji") == 0))) then return true end
	end
end

function SmartAI:hasQiuyuanEffect(from, to)
	if not from or not to or not to:hasSkill("qiuyuan") then return false end
	if getKnownCard(to, self.player, "Jink", true, "he") >= 1 then
		for _, target in ipairs(self:getEnemies(to)) do
			if target:getHandcardNum() ~= 1 or not self:needKongcheng(target, true) then
				return true
			end
		end
		for _, friend in ipairs(self:getFriends(to)) do
			if friend:getHandcardNum() == 1 and self:needKongcheng(friend, true) and not friend:isKongcheng() then
				return true
			end
		end
	end
end