sgs.ai_judgestring = {
	indulgence = "heart",
	diamond = "heart",
	supply_shortage = "club",
	spade = "club",
	club = "club",
	lightning = "spade",
}

local function getIdToCard(self, cards)
	local tocard = {}
	for _, card_id in ipairs(cards) do
		local card = sgs.Sanguosha:getCard(card_id)
		table.insert(tocard, card)
	end
	return tocard
end

local function getBackToId(self, cards)
	local cards_id = {}
	for _, card in ipairs(cards) do
		table.insert(cards_id, card:getEffectiveId())
	end
	return cards_id
end

--for test--
local function ShowGuanxingResult(self, up, bottom)
	self.room:writeToConsole("----GuanxingResult----")
	self.room:writeToConsole(string.format("up:%d", #up))
	if #up > 0 then
		for _,card in pairs(up) do
			self.room:writeToConsole(string.format("(%d)%s[%s%d]", card:getId(), card:getClassName(), card:getSuitString(), card:getNumber()))
		end
	end
	self.room:writeToConsole(string.format("down:%d", #bottom))
	if #bottom > 0 then
		for _,card in pairs(bottom) do
			self.room:writeToConsole(string.format("(%d)%s[%s%d]", card:getId(), card:getClassName(), card:getSuitString(), card:getNumber()))
		end
	end
	self.room:writeToConsole("----GuanxingEnd----")
end
--end--

local function GuanXing(self, cards)
	local up, bottom = {}, {}
	local has_lightning, self_has_judged
	local judged_list = {}
	local willSkipDrawPhase, willSkipPlayPhase

	bottom = getIdToCard(self, cards)
	self:sortByUseValue(bottom, true)

	local judge = sgs.QList2Table(self.player:getJudgingArea())
	judge = sgs.reverse(judge)

	if not self.player:containsTrick("YanxiaoCard") then
		local lightning_index
		for judge_count, need_judge in ipairs(judge) do
			judged_list[judge_count] = 0
			if need_judge:isKindOf("Lightning") then
				lightning_index = judge_count
				has_lightning = need_judge
				continue
			elseif need_judge:isKindOf("Indulgence") then
				willSkipPlayPhase = true
				if self.player:isSkipped(sgs.Player_Play) then continue end
			elseif need_judge:isKindOf("SupplyShortage") then
				willSkipDrawPhase = true
				if self.player:isSkipped(sgs.Player_Draw) then continue end
			end
			local judge_str = sgs.ai_judgestring[need_judge:objectName()]
			if not judge_str then
				self.room:writeToConsole(debug.traceback())
				judge_str = sgs.ai_judgestring[need_judge:getSuitString()]
			end
			for index, for_judge in ipairs(bottom) do
				local suit = for_judge:getSuitString()
				if self.player:hasSkill("hongyan") and suit == "spade" then suit = "heart" end
				if judge_str == suit then
					table.insert(up, for_judge)
					table.remove(bottom, index)
					judged_list[judge_count] = 1
					self_has_judged = true
					if need_judge:isKindOf("SupplyShortage") then willSkipDrawPhase = false
					elseif need_judge:isKindOf("Indulgence") then willSkipPlayPhase = false
					end
					break
				end
			end
		end

		if lightning_index then
			for index, for_judge in ipairs(bottom) do
				local cardNumber = for_judge:getNumber()
				local cardSuit = for_judge:getSuitString()
				if self.player:hasSkill("hongyan") and cardSuit == "spade" then cardSuit = "heart" end
				if not (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade") then
					local i = lightning_index > #up and 1 or lightning_index
					table.insert(up, i , for_judge)
					table.remove(bottom, index)
					judged_list[lightning_index] = 1
					self_has_judged = true
					break
				end
			end
			if judged_list[lightning_index] == 0 then
				if #up >= lightning_index then
					for i = 1, #up - lightning_index + 1 do
						table.insert(bottom, table.remove(up))
					end
				end
				up = getBackToId(self, up)
				bottom = getBackToId(self, bottom)
				return up, bottom
			end
		end

		if not self_has_judged and #judge > 0 then
			return {}, cards
		end

		local index
		if willSkipDrawPhase then
			for i = #judged_list, 1, -1 do
				if judged_list[i] == 0 then index = i
				else break
				end
			end
		end

		for i = 1, #judged_list do
			if judged_list[i] == 0 then
				if i == index then
					up = getBackToId(self, up)
					bottom = getBackToId(self, bottom)
					return up, bottom
				end
				table.insert(up, i, table.remove(bottom, 1))
			end
		end

	end

	local conflict, AI_doNotInvoke_luoshen
	for _, skill in sgs.qlist(self.player:getVisibleSkillList()) do
		local sname = skill:objectName()
		if sname == "guanxing" or sname == "super_guanxing" then conflict = true continue end
		if conflict then
			if sname == "tuqi" then
				if self.player:getPile("retinue"):length() > 0 and self.player:getPile("retinue"):length() <= 2 then
					if #bottom > 0 then
						table.insert(up, 1, table.remove(bottom))
					else
						table.insert(up, 1, table.remove(up))
					end
				end
			elseif sname == "luoshen" then
				if #bottom == 0 then
					self.player:setFlags("AI_doNotInvoke_luoshen")
				else
					local count = 0
					if not self_has_judged then up = {} end
					for i = 1, #bottom do
						if bottom[i - count]:isBlack() then
							table.insert(up, 1, table.remove(bottom, i - count))
							count = count + 1
						end
					end
					if count == 0 then
						AI_doNotInvoke_luoshen = true
					else
						self.player:setFlags("AI_Luoshen_Conflict_With_Guanxing")
						self.player:setMark("AI_loushen_times", count)
					end
				end
			else
				local x = 0
				local reverse
				if sname == "zuixiang" and self.player:getMark("@sleep") > 0 then
					x = 3
				elseif sname == "guixiu" and sgs.ai_skill_invoke.guixiu(self) then
					x = 2
				elseif sname == "qianxi" and sgs.ai_skill_invoke.qianxi(self) then
					x = 1
					reverse = true
				elseif sname == "yinghun" then
					sgs.ai_skill_playerchosen.yinghun(self)
					if self.yinghunchoice == "dxt1" then x = self.player:getLostHp()
					elseif self.yinghunchoice == "d1tx" then x = 1
					end
					reverse = true
				end
				if x > 0 then
					if #bottom < x then
						self.player:setFlags("AI_doNotInvoke_" .. sname)
					else
						for i = 1, x do
							local index = reverse and 1 or #bottom
							table.insert(up, 1, table.remove(bottom, index))
						end
					end
				end
			end
		end
	end

	local drawCards = self:ImitateResult_DrawNCards(self.player, self.player:getVisibleSkillList(true))
	local drawCards_copy = drawCards
	if willSkipDrawPhase then drawCards = 0 end

	if #bottom > 0 and drawCards > 0 then
		if self.player:hasSkill("zhaolie") then
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if self.player:inMyAttackRange(p) then targets:append(p) end
			end
			if target:length() > 0 and sgs.ai_skill_playerchosen.zhaolie(self, targets) then
				local drawCount = drawCards - 1
				local basic = {}
				local peach = {}
				local not_basic = {}
				for _, gcard in ipairs(bottom) do
					if gcard:isKindOf("Peach") then
						table.insert(peach, gcard)
					elseif gcard:isKindOf("BasicCard") then
						table.insert(basic, gcard)
					else
						table.insert(not_basic, gcard)
					end
				end
				if #not_basic > 0 then
					bottom = {}
					for i = 1, drawCount, 1 do
						if self:isWeak() and #peach > 0 then
							table.insert(up, peach[1])
							table.remove(peach, 1)
						elseif #basic > 0 then
							table.insert(up, basic[1])
							table.remove(basic, 1)
						elseif #not_basic > 0 then
							table.insert(up, not_basic[1])
							table.remove(not_basic, 1)
						end
					end
					for index, card in ipairs(not_basic) do
						table.insert(up, card)
					end
					if #peach > 0 then
						for _, peach in ipairs(peach) do
							table.insert(bottom, peach)
						end
					end
					if #basic > 0 then
						for _, card in ipairs(basic) do
							table.insert(bottom, card)
						end
					end
					up = getBackToId(self, up)
					bottom = getBackToId(self, bottom)
					if AI_doNotInvoke_luoshen then self.player:setFlags("AI_doNotInvoke_luoshen") end
					return up, bottom
				else
					self.player:setFlags("AI_doNotInvoke_zhaolie")
				end
			end
		end
	end

	local pos = 1
	local luoshen_flag = false
	local next_judge = {}
	local next_player
	for _, p in sgs.qlist(global_room:getOtherPlayers(self.player)) do
		if p:faceUp() then next_player = p break end
	end
	next_player = next_player or self.player:faceUp() and self.player or self.player:getNextAlive()
	judge = sgs.QList2Table(next_player:getJudgingArea())
	judge = sgs.reverse(judge)
	if has_lightning and not next_player:containsTrick("lightning") then table.insert(judge, 1, has_lightning) end

	local nextplayer_has_judged = false
	judged_list = {}

	while (#bottom > drawCards) do
		if pos > #judge then break end
		local judge_str = sgs.ai_judgestring[judge[pos]:objectName()] or sgs.ai_judgestring[judge[pos]:getSuitString()]

		for index, for_judge in ipairs(bottom) do
			if judge[pos]:isKindOf("Lightning") then lightning_index = pos break end
			if self:isFriend(next_player) then
				if next_player:hasSkill("luoshen") then
					if for_judge:isBlack() then
						table.insert(next_judge, for_judge)
						table.remove(bottom, index)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				else
					local suit = for_judge:getSuitString()
					local number = for_judge:getNumber()
					if next_player:hasSkill("hongyan") and suit == "spade" then suit = "heart" end
					if judge_str == suit then
						table.insert(next_judge, for_judge)
						table.remove(bottom, index)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				end
			else
				if next_player:hasSkill("luoshen") and for_judge:isRed() and not luoshen_flag then
					table.insert(next_judge, for_judge)
					table.remove(bottom, index)
					nextplayer_has_judged = true
					judged_list[pos] = 1
					luoshen_flag = true
					break
				else
					local suit = for_judge:getSuitString()
					local number = for_judge:getNumber()
					if next_player:hasSkill("hongyan") and suit== "spade" then suit = "heart" end
					if judge_str ~= suit then
						table.insert(next_judge, for_judge)
						table.remove(bottom, index)
						nextplayer_has_judged = true
						judged_list[pos] = 1
						break
					end
				end
			end
		end
		if not judged_list[pos] then judged_list[pos] = 0 end
		pos = pos + 1
	end

	if lightning_index then
		for index, for_judge in ipairs(bottom) do
			local cardNumber = for_judge:getNumber()
			local cardSuit = for_judge:getSuitString()
			if next_player:hasSkill("hongyan") and cardSuit == "spade" then cardSuit = "heart" end
			if self:isFriend(next_player) and not (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade")
				or not self:isFriend(next_player) and for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade" then
				local i = lightning_index > #next_judge and 1 or lightning_index
				table.insert(next_judge, i , for_judge)
				table.remove(bottom, index)
				judged_list[lightning_index] = 1
				nextplayer_has_judged = true
				break
			end
		end
	end

	local nextplayer_judge_failed
	if lightning_index and not nextplayer_has_judged then
		nextplayer_judge_failed = true
	elseif nextplayer_has_judged then
		local index
		for i = #judged_list, 1, -1 do
			if judged_list[i] == 0 then index = i
			else break
			end
		end
		for i = 1, #judged_list do
			if i == index then nextplayer_judge_failed = true break end
			if judged_list[i] == 0 then
				table.insert(next_judge, i, table.remove(bottom, 1))
			end
		end
	end

	self:sortByUseValue(bottom)
	if drawCards > 0 and #bottom > 0 then
		local has_slash = self:getCardsNum("Slash") > 0
		local nosfuhun1, nosfuhun2, shuangxiong, has_big
		for index, gcard in ipairs(bottom) do
			local insert = false
			if self.player:hasSkill("nosfuhun") and drawCards >= 2 then
				if not nosfuhun1 and gcard:isRed() then
					insert = true
					nosfuhun1 = true
				end
				if not nosfuhun2 and gcard:isBlack() and isCard("Slash", gcard, self.player) then
					insert = true
					nosfuhun2 = true
				end
				if not nosfuhun2 and gcard:isBlack() and gcard:getTypeId() == sgs.Card_TypeEquip then
					insert = true
					nosfuhun2 = true
				end
				if not nosfuhun2 and gcard:isBlack() then
					insert = true
					nosfuhun2 = true
				end
			elseif self.player:hasSkill("shuangxiong") and self.player:getHandcardNum() >= 3 then
				local rednum, blacknum = 0, 0
				local cards = sgs.QList2Table(self.player:getHandcards())
				for _, card in ipairs(cards) do
					if card:isRed() then rednum = rednum + 1 else blacknum = blacknum + 1 end
				end
				if not shuangxiong and ((rednum > blacknum and gcard:isBlack()) or (blacknum > rednum and gcard:isRed()))
					and (isCard("Slash", gcard, self.player) or isCard("Duel", gcard, self.player)) then
					insert = true
					shuangxiong = true
				end
				if not shuangxiong and ((rednum > blacknum and gcard:isBlack()) or (blacknum > rednum and gcard:isRed())) then
					insert = true
					shuangxiong = true
				end
			elseif self.player:hasSkills("xianzhen|tianyi|dahe|quhu") then
				local maxcard = self:getMaxCard(self.player)
				has_big = maxcard and maxcard:getNumber() > 10
				if not has_big and gcard:getNumber() > 10 then
					insert = true
					has_big = true
				end
				if isCard("Slash", gcard, self.player) then
					insert = true
				end
			elseif isCard("Peach", gcard, self.player) and (self.player:isWounded()  or self:getCardsNum("Peach") == 0) then
				insert = true
			elseif not willSkipPlayPhase and isCard("ExNihilo", gcard, self.player) then
				insert = true
			else
				for _, skill in sgs.qlist(self.player:getVisibleSkillList(true)) do
					local callback = sgs.ai_cardneed[skill:objectName()]
					if type(callback) == "function" and sgs.ai_cardneed[skill:objectName()](self.player, gcard, self) then
						insert = true
					end
				end
				if not insert then
					if has_slash and not gcard:isKindOf("Slash") and not gcard:isKindOf("Jink") and self:getCardsNum("Jink") > 0 then
						insert = true
					elseif not has_slash and isCard("Slash", gcard, self.player) and not willSkipPlayPhase then
						insert = true
						has_slash = true
					end
				end
			end

			if insert then
				drawCards = drawCards - 1
				table.insert(up, gcard)
				table.remove(bottom, index)
				if isCard("ExNihilo", gcard, self.player) then drawCards = drawCards + 2 end
				if drawCards == 0 then break end
			end
		end
		if #bottom > 0 and drawCards > 0 then
			if willSkipPlayPhase then self.player:setFlags("willSkipPlayPhase") end
			for i = 1, #bottom do
				local c = self:getValuableCardForGuanxing(bottom)
				if not c then break end
				for index, card in ipairs(bottom) do
					if card:getEffectiveId() == c:getEffectiveId() then
						table.insert(up, table.remove(bottom, index))
						drawCards = drawCards - 1
						if isCard("ExNihilo", card, self.player) then drawCards = drawCards + 2 end
						break
					end
				end
				if drawCards == 0 then break end
			end
			self.player:setFlags("-willSkipPlayPhase")
		end
	end

	if #bottom > drawCards and #bottom > 0 and not nextplayer_judge_failed then
		local maxCount = #bottom - drawCards
		if self:isFriend(next_player) then
			local i = 0
			for index = 1, #bottom do
				if bottom[index - i]:isKindOf("Peach") and (next_player:isWounded() or getCardsNum("Peach", next_player, self.player) < 1)
					or isCard("ExNihilo", bottom[index - i], next_player) then
					table.insert(next_judge, table.remove(bottom, index - i))
					i = i + 1
					if maxCount == i then break end
				end
			end
			maxCount = maxCount - i
			if maxCount > 0 then
				i = 0
				for _, skill in sgs.qlist(next_player:getVisibleSkillList(true)) do
					local callback = sgs.ai_cardneed[skill:objectName()]
					if type(callback) == "function" then
						for index = 1, #bottom do
							if sgs.ai_cardneed[skill:objectName()](next_player, bottom[index - i], self) then
								table.insert(next_judge, table.remove(bottom, index - i))
								i = i + 1
								if maxCount == i then break end
							end
						end
						if maxCount == i then break end
					end
				end
			end
		else
			local i = 0
			for index = 1, #bottom do
				if bottom[index - i]:isKindOf("Lightning") and not next_player:hasSkills("leiji|nosleiji") or bottom[index - i]:isKindOf("GlobalEffect") then
					table.insert(next_judge, table.remove(bottom, index - i))
					i = i + 1
					if maxCount == i then break end
				end
			end
		end
	end

	if #next_judge > 0 and drawCards > 0 then
		if #bottom >= drawCards then
			for i = 1, #bottom do
				table.insert(up, table.remove(bottom))
				drawCards = drawCards - 1
				if drawCards == 0 then break end
			end
		else
			table.insertTable(bottom, next_judge)
			next_judge = {}
		end
	end

	for _, gcard in ipairs(next_judge) do
		table.insert(up, gcard)
	end

	if not self_has_judged and not nextplayer_has_judged and #next_judge == 0 and #up >= drawCards_copy and drawCards_copy > 1 then
		for i = 1, drawCards_copy - 1 do
			if isCard("ExNihilo", up[i], self.player) then
				table.insert(up, drawCards_copy, table.remove(up, i))
			end
		end
	end

	up = getBackToId(self, up)
	bottom = getBackToId(self, bottom)
	if #up > 0 and AI_doNotInvoke_luoshen then self.player:setFlags("AI_doNotInvoke_luoshen") end
	return up, bottom
end

local function XinZhan(self, cards)
	local up, bottom = {}, {}
	local judged_list = {}
	local hasJudge = false
	local next_player = self.player:getNextAlive()
	local judge = next_player:getCards("j")
	judge = sgs.QList2Table(judge)
	judge = sgs.reverse(judge)

	bottom = getIdToCard(self, cards)
	for judge_count, need_judge in ipairs(judge) do
		local index = 1
		local lightning_flag = false
		local judge_str = sgs.ai_judgestring[need_judge:objectName()] or sgs.ai_judgestring[need_judge:getSuitString()]

		for _, for_judge in ipairs(bottom) do
			if judge_str == "spade" and not lightning_flag then
				has_lightning = need_judge
				if for_judge:getNumber() >= 2 and for_judge:getNumber() <= 9 then lightning_flag = true end
			end
			if self:isFriend(next_player) then
				if judge_str == for_judge:getSuitString() then
					if not lightning_flag then
						table.insert(up, for_judge)
						table.remove(bottom, index)
						judged_list[judge_count] = 1
						has_judged = true
						break
					end
				end
			else
				if judge_str ~= for_judge:getSuitString() or
					(judge_str == for_judge:getSuitString() and judge_str == "spade" and lightning_flag) then
					table.insert(up, for_judge)
					table.remove(bottom, index)
					judged_list[judge_count] = 1
					has_judged = true
				end
			end
			index = index + 1
		end
		if not judged_list[judge_count] then judged_list[judge_count] = 0 end
	end

	if has_judged then
		for index = 1, #judged_list do
			if judged_list[index] == 0 then
				table.insert(up, index, table.remove(bottom))
			end
		end
	end

	while #bottom ~= 0 do
		table.insert(up, table.remove(bottom))
	end

	up = getBackToId(self, up)
	return up, {}
end

function SmartAI:askForGuanxing(cards, guanxing_type)
	--KOF模式--
	if guanxing_type ~= sgs.Room_GuanxingDownOnly then
		local func = Tactic("guanxing", self, guanxing_type == sgs.Room_GuanxingUpOnly)
		if func then return func(self, cards) end
	end
	--身份局--
	if guanxing_type == sgs.Room_GuanxingBothSides then return GuanXing(self, cards)
	elseif guanxing_type == sgs.Room_GuanxingUpOnly then return XinZhan(self, cards)
	elseif guanxing_type == sgs.Room_GuanxingDownOnly then return {}, cards
	end
	return cards, {}
end

function SmartAI:getValuableCardForGuanxing(cards)
	local needbuyi
	for _, friend in ipairs(self.friends) do
		if friend:hasSkill("buyi") and self.player:getHp() == 1 then
			needbuyi = true
		end
	end
	if needbuyi then
		local maxvaluecard
		local maxvalue = -100
		for _, bycard in ipairs(cards) do
			if not bycard:isKindOf("BasicCard") then
				local value = self:getUseValue(bycard)
				if value > maxvalue then
					maxvalue = value
					maxvaluecard = bycard
				end
			end
		end
		if maxvaluecard then return maxvaluecard end
	end

	local peach, exnihilo, jink, analeptic, nullification, snatch, dismantlement, indulgence
	for _, card in ipairs(cards) do
		if isCard("Peach", card, self.player) then
			peach = card
			if self.player:isWounded() or self:getCardsNum("Peach") == 0 then
				return peach
			end
		elseif isCard("ExNihilo", card, self.player) then
			exnihilo = card
		elseif isCard("Jink", card, self.player) then
			jink = card
		elseif isCard("Analeptic", card, self.player) then
			analeptic = card
		elseif isCard("Nullification", card, self.player) then
			nullification = card
		elseif isCard("Snatch", card, self.player) then
			snatch = card
		elseif isCard("Dismantlement", card, self.player) then
			dismantlement = card
		elseif isCard("Indulgence", card, self.player) then
			indulgence = card
		end
	end

	for _, target in sgs.qlist(self.room:getAlivePlayers()) do
		if self:willSkipPlayPhase(target) or self:willSkipDrawPhase(target) then
			if nullification then return nullification
			elseif self:isFriend(target) and snatch and self:hasTrickEffective(snatch, target, self.player) and
				not self:willSkipPlayPhase() and self.player:distanceTo(target) == 1 then
				return snatch
			elseif self:isFriend(target) and dismantlement and self:hasTrickEffective(dismantlement, target, self.player) and
				not self:willSkipPlayPhase() and self.player:objectName() ~= target:objectName() then
				return dismantlement
			end
		end
	end

	if self.player:hasFlag("willSkipPlayPhase") and peach then return peach end
	if not self.player:hasFlag("willSkipPlayPhase") and (exnihilo or peach) then return exnihilo or peach end
	if (jink or analeptic) and (self:getCardsNum("Jink") == 0 or (self:isWeak() and self:getOverflow() <= 0)) then
		return jink or analeptic
	end
	if indulgence then return indulgence end

	if nullification and self:getCardsNum("Nullification") < 2 then return nullification end

	local eightdiagram, silverlion, vine, renwang, DefHorse, OffHorse
	local weapon, crossbow, halberd, double, qinggang, axe, gudingdao
	for _, card in ipairs(cards) do
		if card:isKindOf("EightDiagram") then eightdiagram = card
		elseif card:isKindOf("SilverLion") then silverlion = card
		elseif card:isKindOf("Vine") then vine = card
		elseif card:isKindOf("RenwangShield") then renwang = card

		elseif card:isKindOf("DefensiveHorse") and not self:getSameEquip(card) then DefHorse = card
		elseif card:isKindOf("OffensiveHorse") and not self:getSameEquip(card) then OffHorse = card

		elseif card:isKindOf("Crossbow") then crossbow = card
		elseif card:isKindOf("DoubleSword") then double = card
		elseif card:isKindOf("QinggangSword") then qinggang = card
		elseif card:isKindOf("Halberd") then halberd = card
		elseif card:isKindOf("GudingBlade") then gudingdao = card
		elseif card:isKindOf("Axe") then axe = card end

		if card:isKindOf("Weapon") then weapon = card end
	end

	if eightdiagram then
		local lord = getLord(self.player)
		if not self.player:hasSkills("yizhong|bazhen") and self.player:hasSkills("tiandu|leiji|nosleiji|noszhenlie|gushou|hongyan") then
			return eightdiagram
		end
		if self.role == "loyalist" and self.player:getKingdom() == "wei" and not self.player:hasSkill("bazhen") and lord and lord:hasLordSkill("hujia") then
			return eightdiagram
		end
		if sgs.ai_armor_value.EightDiagram(self.player, self) >= 5 then return eightdiagram end
	end

	if silverlion then
		local lightning, canRetrial
		for _, aplayer in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if aplayer:hasSkill("nosleiji") and self:isEnemy(aplayer) then
				return silverlion
			end
			if aplayer:containsTrick("lightning") then
				lightning = true
			end
			if aplayer:hasSkills("guicai|guidao") and self:isEnemy(aplayer) then
				canRetrial = true
			end
		end
		if lightning and canRetrial then return silverlion end
		if self.player:isChained() then
			for _, friend in ipairs(self.friends) do
				if friend:hasArmorEffect("vine") and friend:isChained() then
					return silverlion
				end
			end
		end
		if self.player:isWounded() then return silverlion end
	end

	if vine then
		if sgs.ai_armor_value.Vine(self.player, self) > 0 and self.room:alivePlayerCount() <= 3 then
			return vine
		end
	end

	if renwang then
		if sgs.ai_armor_value.RenwangShield(self.player, self) > 0 and self:getCardsNum("Jink") == 0 then return renwang end
	end

	if DefHorse and (not self.player:hasSkills("leiji|nosleiji") or self:getCardsNum("Jink") == 0) then
		local before_num, after_num = 0, 0
		for _, enemy in ipairs(self.enemies) do
			if enemy:canSlash(self.player, nil, true) then
				before_num = before_num + 1
			end
			if enemy:canSlash(self.player, nil, true, 1) then
				after_num = after_num + 1
			end
		end
		if before_num > after_num and (self:isWeak() or self:getCardsNum("Jink") == 0) then return DefHorse end
	end

	if analeptic then
		local slashs = self:getCards("Slash")
		for _, enemy in ipairs(self.enemies) do
			local hit_num = 0
			for _, slash in ipairs(slashs) do
				if self:slashIsEffective(slash, enemy) and self.player:canSlash(enemy, slash) and self:slashIsAvailable() then
					hit_num = hit_num + 1
					if getCardsNum("Jink", enemy, self.player) < 1
						or enemy:isKongcheng()
						or self:canLiegong(enemy, self.player)
						or self.player:hasSkills("tieji|wushuang|dahe|qianxi")
						or self.player:hasSkill("roulin") and enemy:isFemale()
						or (self.player:hasWeapon("axe") or self:getCardsNum("Axe") > 0) and self.player:getCards("he"):length() > 4
						then
						return analeptic
					end
				end
			end
			if (self.player:hasWeapon("blade") or self:getCardsNum("Blade") > 0) and getCardsNum("Jink", enemy, self.player) <= hit_num then return analeptic end
			if self:hasCrossbowEffect(self.player) and hit_num >= 2 then return analeptic end
		end
	end

	if weapon and self:getCardsNum("Slash") > 0 and self:slashIsAvailable() then

		local current_range = self.player:getAttackRange()
		local nosuit_slash = sgs.Sanguosha:cloneCard("slash")
		local slash = self:getCard("Slash")

		self:sort(self.enemies, "defense")

		if crossbow then
			if self:getCardsNum("Slash") > 1 or self.player:hasSkills("kurou|keji") then
				return crossbow
			end
			if self.player:hasSkill("guixin") and self.room:alivePlayerCount() >= 6 and (self.player:getHp() > 1 or self:getCardsNum("Peach") > 0) then
				return crossbow
			end
			if self.player:hasSkill("nosrende|rende") then
				for _, friend in ipairs(self.friends_noself) do
					if getCardsNum("Slash", friend, self.player) > 1 then
						return crossbow
					end
				end
			end
		end

		if halberd then
			if self.player:hasSkills("nosrende|rende") and self:findFriendsByType(sgs.Friend_Draw) then return halberd end
			if self:getCardsNum("Slash") == 1 and self.player:getHandcardNum() == 1 then return halberd end
		end

		if gudingdao then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, slash, true, range_fix) and not enemy:hasSkills("tianming|kongcheng")
					and (enemy:isKongcheng() or enemy:getHandcardNum() == 1 and	((self:getCardsNum("Dismantlement") > 0 or (self:getCardsNum("Snatch") > 0 and self.player:distanceTo(enemy) == 1)))) then
					return gudingdao
				end
			end
		end

		if double then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:getGender() ~= enemy:getGender() and self.player:canSlash(enemy, nil, true, range_fix) then
					return double
				end
			end
		end

		if axe then
			local range_fix = current_range - 3
			local FFFslash = self:getCard("FireSlash")
			for _, enemy in ipairs(self.enemies) do
				if enemy:hasArmorEffect("vine") and FFFslash and self:slashIsEffective(FFFslash, enemy) and
					self.player:getCardCount() >= 3 and self.player:canSlash(enemy, FFFslash, true, range_fix) then
					return axe
				elseif self:getCardsNum("Analeptic") > 0 and self.player:getCardCount() >= 4 and
					self:slashIsEffective(slash, enemy) and self.player:canSlash(enemy, slash, true, range_fix) then
					return axe
				end
			end
		end

		if qinggang then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, slash, true, range_fix) and self:slashIsEffective(slash, enemy, self.player, true) and enemy:getArmor() then
					return qinggang
				end
			end
		end

	end

	local snatch, dismantlement, indulgence, supplyshortage, collateral, duel, aoe, godsalvation, fireattack, lightning
	local new_enemies = {}
	if #self.enemies > 0 then new_enemies = self.enemies
	else
		for _, aplayer in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if sgs.evaluatePlayerRole(aplayer) == "neutral" then
				table.insert(new_enemies, aplayer)
			end
		end
	end
	local hasTrick = false
	for _, card in ipairs(cards) do
		for _, enemy in ipairs(new_enemies) do
			if not enemy:isNude() and isCard("Snatch", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("snatch", card:getSuit(), card:getNumber()), enemy) and self.player:distanceTo(enemy) == 1 then
				snatch = card
				hasTrick = true
			elseif not enemy:isNude() and ((isCard("Dismantlement", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber()), enemy))
											or (card:isBlack() and self.player:hasSkill("yinling") and self.player:getPile("brocade"):length() < 4)) then
				dismantlement = card
				hasTrick = true
			elseif isCard("Indulgence", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("indulgence", card:getSuit(), card:getNumber()), enemy)
				and not enemy:containsTrick("indulgence") and not self:willSkipPlayPhase(enemy) then
				indulgence = card
				hasTrick = true
			elseif isCard("SupplyShortage", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("supply_shortage", card:getSuit(), card:getNumber()), enemy)
				and not enemy:containsTrick("supply_shortage") and not self:willSkipDrawPhase(enemy) then
				supplyshortage = card
				hasTrick = true
			elseif isCard("Collateral", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("collateral", card:getSuit(), card:getNumber()), enemy) and enemy:getWeapon() then
				collateral = card
				hasTrick = true
			elseif isCard("Duel", card, self.player) and (self:getCardsNum("Slash") >= getCardsNum("Slash", enemy, self.player) or self.player:getHandcardNum() > 4)
				and self:hasTrickEffective(sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber()), enemy) then
				duel = card
				hasTrick = true
			elseif card:isKindOf("AOE") then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then
					aoe = card
					hasTrick = true
				end
			elseif isCard("FireAttack", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("fire_attack", card:getSuit(), card:getNumber()), enemy)
				and self:damageIsEffective(enemy, sgs.DamageStruct_Fire, self.player) then

				local FFF
				local jinxuandi = self.room:findPlayerBySkillName("wuling")
				if jinxuandi and jinxuandi:getMark("@fire") > 0 then FFF = true end
				if self.player:hasSkill("shaoying") then FFF = true end
				if enemy:getHp() == 1 or enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 then FFF = true end
				if FFF then
					local suits = {}
					local suitnum = 0
					for _, hcard in sgs.qlist(self.player:getHandcards()) do
						if hcard:getSuit() == sgs.Card_Spade then
							suits.spade = true
						elseif hcard:getSuit() == sgs.Card_Heart then
							suits.heart = true
						elseif hcard:getSuit() == sgs.Card_Club then
							suits.club = true
						elseif hcard:getSuit() == sgs.Card_Diamond then
							suits.diamond = true
						end
					end
					for k, hassuit in pairs(suits) do
						if hassuit then suitnum = suitnum + 1 end
					end
					if suitnum >= 3 or (suitnum >= 2 and enemy:getHandcardNum() == 1) then
						fireattack = card
						hasTrick = true
					end
				end
			elseif isCard("GodSalvation", card, self.player) and self:willUseGodSalvation(sgs.Sanguosha:cloneCard("god_salvation", card:getSuit(), card:getNumber())) then
				godsalvation = card
				hasTrick = true
			elseif card:isKindOf("Lightning") and self:willUseLightning(card) and self:getFinalRetrial() == 1 then
				lightning = card
				hasTrick = true
			end
		end
	end
	for _, card in ipairs(cards) do
		for _, friend in ipairs(self.friends_noself) do
			if self:willSkipPlayPhase(friend, true) or self:willSkipDrawPhase(friend, true) or self:needToThrowArmor(friend) then
				if self:hasTrickEffective(sgs.Sanguosha:cloneCard("snatch", card:getSuit(), card:getNumber()), enemy) and isCard("Snatch", card, self.player) and self.player:distanceTo(friend) == 1 then
					snatch = card
					hasTrick = true
				elseif (isCard("Dismantlement", card, self.player) and self:hasTrickEffective(sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber()), enemy))
						or (card:isBlack() and self.player:hasSkill("yinling") and self.player:getPile("brocade"):length() < 4) then
					dismantlement = card
					hasTrick = true
				end
			end
		end
	end

	if hasTrick and not self.player:hasFlag("willSkipPlayPhase") then
		return snatch or dismantlement or indulgence or supplyshortage or collateral or duel or aoe or godsalvation or fireattack or lightning
	end

	if weapon and not self.player:getWeapon() and self:getCardsNum("Slash") > 0 and self:slashIsAvailable() then
		local inAttackRange
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) then
				inAttackRange = true
				break
			end
		end
		if not inAttackRange then return weapon end
	end

	return
end