-- this script file defines all functions written by Lua

on_trigger_default = function(self, event, player, data)
	return false
end

-- trigger skills
function sgs.CreateTriggerSkill(spec)
	assert(type(spec.name) == "string")
	if spec.frequency then assert(type(spec.frequency) == "number") end
	if spec.limit_mark then assert(type(spec.limit_mark) == "string") end
	
	local frequency = spec.frequency or sgs.Skill_NotFrequent
	local limit_mark = spec.limit_mark or ""
	local skill = sgs.LuaTriggerSkill(spec.name, frequency, limit_mark)
	
	if type(spec.guhuo_type) == "string" and spec.guhuo_type ~= "" then skill:setGuhuoDialog(guhuo_type) end

	if type(spec.events) == "number" then
		skill:addEvent(spec.events)
	elseif type(spec.events) == "table" then
		for _, event in ipairs(spec.events) do
			skill:addEvent(event)
		end
	end

	if type(spec.global) == "boolean" then skill:setGlobal(spec.global) end

	if type(spec.on_trigger) == "function" then
		skill.on_trigger = spec.on_trigger
	else
		skill.on_trigger = on_trigger_default
	end

	if spec.can_trigger then
		skill.can_trigger = spec.can_trigger
	end
	if spec.view_as_skill then
		skill:setViewAsSkill(spec.view_as_skill)
	end
	if type(spec.priority) == "number" then
		skill.priority = spec.priority
	elseif type(spec.priority) == "table" then
		for triggerEvent, priority in pairs(spec.priority) do
			skill:insertPriorityTable(triggerEvent, priority)
		end
	end
    if type(dynamic_frequency) == "function" then
        skill.dynamic_frequency = spec.dynamic_frequency
    end
	return skill
end

function sgs.CreateDummySkill(spec)
	assert(type(spec.name) == "string")
	return sgs.LuaDummySkill(spec.name, spec.frequency or sgs.Skill_Compulsory)
end

function sgs.CreateProhibitSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.is_prohibited) == "function")

	local skill = sgs.LuaProhibitSkill(spec.name)
	skill.is_prohibited = spec.is_prohibited

	return skill
end

function sgs.CreateFilterSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.view_filter) == "function")
	assert(type(spec.view_as) == "function")

	local skill = sgs.LuaFilterSkill(spec.name)
	skill.view_filter = spec.view_filter
	skill.view_as = spec.view_as

	return skill
end

function sgs.CreateDistanceSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.correct_func) == "function")

	local skill = sgs.LuaDistanceSkill(spec.name)
	skill.correct_func = spec.correct_func

	return skill
end

function sgs.CreateMaxCardsSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.extra_func) == "function" or type(spec.fixed_func) == "function")

	local skill = sgs.LuaMaxCardsSkill(spec.name)
	if spec.extra_func then
		skill.extra_func = spec.extra_func
	else
		skill.fixed_func = spec.fixed_func
	end

	return skill
end

function sgs.CreateTargetModSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.residue_func) == "function" or type(spec.distance_limit_func) == "function" or type(spec.extra_target_func) == "function")
	if spec.pattern then assert(type(spec.pattern) == "string") end

	local skill = sgs.LuaTargetModSkill(spec.name, spec.pattern or "Slash")
	if spec.residue_func then
		skill.residue_func = spec.residue_func
	end
	if spec.distance_limit_func then
		skill.distance_limit_func = spec.distance_limit_func
	end
	if spec.extra_target_func then
		skill.extra_target_func = spec.extra_target_func
	end

	return skill
end

function sgs.CreateInvaliditySkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.skill_valid) == "function")

	local skill = sgs.LuaInvaliditySkill(spec.name)
	skill.skill_valid = spec.skill_valid

	return skill
end

function sgs.CreateAttackRangeSkill(spec)
	assert(type(spec.name) == "string")
	assert(type(spec.extra_func) == "function" or type(spec.fixed.func) == "function")

	local skill = sgs.LuaAttackRangeSkill(spec.name)

	if spec.extra_func then
		skill.extra_func = spec.extra_func or 0
	end
	if spec.fixed_func then
		skill.fixed_func = spec.fixed_func or -1
	end

	return skill
end

function sgs.CreateMasochismSkill(spec)
	assert(type(spec.on_damaged) == "function")

	spec.events = sgs.Damaged

	function spec.on_trigger(skill, event, player, data)
		local damage = data:toDamage()
		spec.on_damaged(skill, player, damage)
		return false
	end
	
	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreatePhaseChangeSkill(spec)
	assert(type(spec.on_phasechange) == "function")

	spec.events = sgs.EventPhaseStart

	function spec.on_trigger(skill, event, player, data)
		return spec.on_phasechange(skill, player)
	end

	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreateDrawCardsSkill(spec)
	assert(type(spec.draw_num_func) == "function")

	if spec.is_initial then spec.events = sgs.DrawNCards else spec.events = sgs.DrawInitialCards end

	function spec.on_trigger(skill, event, player, data)
		local n = data:toInt()
		local nn = spec.draw_num_func(skill, player, n)
		data:setValue(nn)
		return false
	end

	return sgs.CreateTriggerSkill(spec)
end

function sgs.CreateGameStartSkill(spec)
	assert(type(spec.on_gamestart) == "function")

	spec.events = sgs.GameStart

	function spec.on_trigger(skill, event, player, data)
		spec.on_gamestart(skill, player)
		return false
	end

	return sgs.CreateTriggerSkill(spec)
end

--------------------------------------------

-- skill cards

function sgs.CreateSkillCard(spec)
	assert(spec.name)
	if spec.skill_name then assert(type(spec.skill_name) == "string") end

	local card = sgs.LuaSkillCard(spec.name, spec.skill_name)

	if type(spec.target_fixed) == "boolean" then
		card:setTargetFixed(spec.target_fixed)
	end

	if type(spec.will_throw) == "boolean" then
		card:setWillThrow(spec.will_throw)
	end

	if type(spec.can_recast) == "boolean" then
		card:setCanRecast(spec.can_recast)
	end
		
	if type(spec.handling_method) == "number" then
		card:setHandlingMethod(spec.handling_method)
	end

	if type(spec.mute) == "boolean" then
		card:setMute(spec.mute)
	end

	if type(spec.filter) == "function" then
		function card:filter(...)
			local result,vote = spec.filter(self,...)
			if type(result) == "boolean" and type(vote) == "number" then
				return result,vote
			elseif type(result) == "boolean" and vote == nil then
				if result then vote = 1 else vote = 0 end
				return result,vote
			elseif type(result) == "number" then
				return result > 0,result
			else
				return false,0
			end
		end
	end
	card.feasible = spec.feasible
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect
	card.on_validate = spec.on_validate
	card.on_validate_in_response = spec.on_validate_in_response

	return card
end

function sgs.CreateBasicCard(spec)
	assert(type(spec.name) == "string" or type(spec.class_name) == "string")
	if not spec.name then spec.name = spec.class_name
	elseif not spec.class_name then spec.class_name = spec.name end
	if spec.suit then assert(type(spec.suit) == "number") end
	if spec.number then assert(type(spec.number) == "number") end
	if spec.subtype then assert(type(spec.subtype) == "string") end
	local card = sgs.LuaBasicCard(spec.suit or sgs.Card_NoSuit, spec.number or 0, spec.name, spec.class_name, spec.subtype or "BasicCard")

	if type(spec.target_fixed) == "boolean" then
		card:setTargetFixed(spec.target_fixed)
	end

	if type(spec.can_recast) == "boolean" then
		card:setCanRecast(spec.can_recast)
	end

	card.filter = spec.filter
	card.feasible = spec.feasible
	card.available = spec.available
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect

	return card
end

-- ============================================
-- default functions for Trick cards

function isAvailable_AOE(self, player)
	local canUse = false
	local players = player:getSiblings()
	for _, p in sgs.qlist(players) do
		if p:isDead() or player:isProhibited(p, self) then continue end
		canUse = true
		break
	end
	return canUse and self:cardIsAvailable(player)
end

function onUse_AOE(self, room, card_use)
	local source = card_use.from
	local targets = sgs.SPlayerList()
	local other_players = room:getOtherPlayers(source)
	for _, player in sgs.qlist(other_players) do
		local skill = room:isProhibited(source, player, self)
		if skill ~= nil then
			local log_message = sgs.LogMessage()
			log_message.type = "#SkillAvoid"
			log_message.from = player
			log_message.arg = skill:objectName()
			log_message.arg2 = self:objectName()
			room:broadcastSkillInvoke(skill:objectName())
		else
			targets:append(player)
		end
	end

	local use = card_use
	use.to = targets
	self:cardOnUse(room, use)
end

function isAvailable_GlobalEffect(self, player)
	local canUse = false
	local players = player:getSiblings()
	players:append(player)
	for _, p in sgs.qlist(players) do
		if p:isDead() or player:isProhibited(p, self) then continue end
		canUse = true
		break
	end
	return canUse and self:cardIsAvailable(player)
end

function onUse_GlobalEffect(self, room, card_use)
	local source = card_use.from
	local targets = sgs.SPlayerList()
	local all_players = room:getAllPlayers()
	for _, player in sgs.qlist(all_players) do
		local skill = room:isProhibited(source, player, self)
		if skill ~= nil then
			local log_message = sgs.LogMessage()
			log_message.type = "#SkillAvoid"
			log_message.from = player
			log_message.arg = skill:objectName()
			log_message.arg2 = self:objectName()
			room:broadcastSkillInvoke(skill:objectName())
		else
			targets:append(player)
		end
	end

	local use = card_use
	use.to = targets
	self:cardOnUse(room, use)
end

function onUse_DelayedTrick(self, room, card_use)
	local use = card_use
	local wrapped = sgs.Sanguosha:getWrappedCard(self:getEffectiveId())
	use.card = wrapped

	local data = sgs.QVariant()
	data:setValue(use)
	local thread = room:getThread()
	thread:trigger(sgs.PreCardUsed, room, use.from, data)
	use = data:toCardUse()

	local logm = sgs.LogMessage()
	logm.from = use.from
	logm.to = use.to
	logm.type = "#UseCard"
	logm.card_str = self:toString()
	room:sendLog(logm)

	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, use.from:objectName(), use.to:first():objectName(), self:getSkillName(), "")
	room:moveCardTo(self, use.from, use.to:first(), sgs.Player_PlaceDelayedTrick, reason, true)

	thread:trigger(sgs.CardUsed, room, use.from, data)
	use = data:toCardUse()
	thread:trigger(sgs.CardFinished, room, use.from, data)
end

function use_DelayedTrick(self, room, source, targets)
	if #targets == 0 then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, source:objectName(), "", self:getSkillName(), "")
		room:moveCardTo(self, room:getCardOwner(self:getEffectiveId()), nil, sgs.Player_DiscardPile, reason, true)
	end
end

function onNullified_DelayedTrick_movable(self, target)
	local room = target:getRoom()
	local thread = room:getThread()
	local players = room:getOtherPlayers(target)
	players:append(target)
	local p = nil

	for _, player in sgs.qlist(players) do
		if player:containsTrick(self:objectName()) then continue end

		local skill = room:isProhibited(target, player, self)
		if skill then
			local logm = sgs.LogMessage()
			logm.type = "#SkillAvoid"
			logm.from = player
			logm.arg = skill:objectName()
			logm.arg2 = self:objectName()
			room:sendLog(logm)

			room:broadcastSkillInvoke(skill:objectName())
			continue
		end

		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, target:objectName(), "", self:getSkillName(), "")
		room:moveCardTo(self, target, player, sgs.Player_PlaceDelayedTrick, reason, true)
		if target:objectName() == player:objectName() then break end

		local use = sgs.CardUseStruct()
		use.from = nil
		use.to:append(player)
		use.card = self
		local data = sgs.QVariant()
		data:setValue(use)
		thread:trigger(sgs.TargetConfirming, room, player, data)
		local new_use = data:toCardUse()
		if new_use.to:isEmpty() then
			p = player
			break
		end
		for _, ps in sgs.qlist(room:getAllPlayers()) do
			thread:trigger(sgs.TargetConfirmed, room, ps, data)
		end
		break
	end
	if p then self:on_nullified(p) end
end

function onNullified_DelayedTrick_unmovable(self, target)
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, target:objectName())
	target:getRoom():throwCard(self, reason, nil)
end

-- ============================================

function sgs.CreateTrickCard(spec)
	assert(type(spec.name) == "string" or type(spec.class_name) == "string")
	if not spec.name then spec.name = spec.class_name
	elseif not spec.class_name then spec.class_name = spec.name end
	if spec.suit then assert(type(spec.suit) == "number") end
	if spec.number then assert(type(spec.number) == "number") end

	if spec.subtype then
		assert(type(spec.subtype) == "string")
	else
		local subtype_table = { "TrickCard", "single_target_trick", "delayed_trick", "aoe", "global_effect" }
		spec.subtype = subtype_table[(spec.subclass or 0) + 1]
	end

	local card = sgs.LuaTrickCard(spec.suit or sgs.Card_NoSuit, spec.number or 0, spec.name, spec.class_name, spec.subtype)

	if type(spec.target_fixed) == "boolean" then
		card:setTargetFixed(spec.target_fixed)
	end

	if type(spec.can_recast) == "boolean" then
		card:setCanRecast(spec.can_recast)
	end

	if type(spec.subclass) == "number" then
		card:setSubClass(spec.subclass)
	else
		card:setSubClass(sgs.LuaTrickCard_TypeNormal)
	end

	if spec.subclass then
		if spec.subclass == sgs.LuaTrickCard_TypeDelayedTrick then
			if not spec.about_to_use then spec.about_to_use = onUse_DelayedTrick end
			if not spec.on_use then spec.on_use = use_DelayedTrick end
			if not spec.on_nullified then
				if spec.movable then spec.on_nullified = onNullified_DelayedTrick_movable
				else spec.on_nullified = onNullified_DelayedTrick_unmovable
				end
			end
		elseif spec.subclass == sgs.LuaTrickCard_TypeAOE then
			if not spec.available then spec.available = isAvailable_AOE end
			if not spec.about_to_use then spec.about_to_use = onUse_AOE end
			if not spec.target_fixed then card:setTargetFixed(true) end
		elseif spec.subclass == sgs.LuaTrickCard_TypeGlobalEffect then
			if not spec.available then spec.available = isAvailable_GlobalEffect end
			if not spec.about_to_use then spec.about_to_use = onUse_GlobalEffect end
			if not spec.target_fixed then card:setTargetFixed(true) end
		end
	end

	card.filter = spec.filter
	card.feasible = spec.feasible
	card.available = spec.available
	card.is_cancelable = spec.is_cancelable
	card.on_nullified = spec.on_nullified
	card.about_to_use = spec.about_to_use
	card.on_use = spec.on_use
	card.on_effect = spec.on_effect

	return card
end

function sgs.CreateViewAsSkill(spec)
	assert(type(spec.name) == "string")
	if spec.response_pattern then assert(type(spec.response_pattern) == "string") end
	local response_pattern = spec.response_pattern or ""
	local response_or_use = spec.response_or_use or false
	if spec.expand_pile then assert(type(spec.expand_pile) == "string") end
	local expand_pile = spec.expand_pile or ""

	local skill = sgs.LuaViewAsSkill(spec.name, response_pattern, response_or_use, expand_pile)
	local n = spec.n or 0

	function skill:view_as(cards)
		return spec.view_as(self, cards)
	end

	function skill:view_filter(selected, to_select)
		if #selected >= n then return false end
		return spec.view_filter(self, selected, to_select)
	end
	if type(spec.guhuo_type) == "string" and spec.guhuo_type ~= "" then skill:setGuhuoDialog(guhuo_type) end

	skill.should_be_visible = spec.should_be_visible
	skill.effect_index = spec.effect_index
	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateOneCardViewAsSkill(spec)
	assert(type(spec.name) == "string")
	if spec.response_pattern then assert(type(spec.response_pattern) == "string") end
	local response_pattern = spec.response_pattern or ""
	local response_or_use = spec.response_or_use or false
	if spec.filter_pattern then assert(type(spec.filter_pattern) == "string") end
	if spec.expand_pile then assert(type(spec.expand_pile) == "string") end
	local expand_pile = spec.expand_pile or ""

	local skill = sgs.LuaViewAsSkill(spec.name, response_pattern, response_or_use, expand_pile)
	
	if type(spec.guhuo_type) == "string" and spec.guhuo_type ~= "" then skill:setGuhuoDialog(guhuo_type) end

	function skill:view_as(cards)
		if #cards ~= 1 then return nil end
		return spec.view_as(self, cards[1])
	end

	function skill:view_filter(selected, to_select)
		if #selected >= 1 or to_select:hasFlag("using") then return false end
		if spec.view_filter then return spec.view_filter(self, to_select) end
		if spec.filter_pattern then
			local pat = spec.filter_pattern
			if string.endsWith(pat, "!") then
				if sgs.Self:isJilei(to_select) then return false end
				pat = string.sub(pat, 1, -2)
			end
			return sgs.Sanguosha:matchExpPattern(pat, sgs.Self, to_select)
		end
	end

	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateZeroCardViewAsSkill(spec)
	assert(type(spec.name) == "string")
	if spec.response_pattern then assert(type(spec.response_pattern) == "string") end
	local response_pattern = spec.response_pattern or ""
	local response_or_use = spec.response_or_use or false

	local skill = sgs.LuaViewAsSkill(spec.name, response_pattern, response_or_use, "")

	if type(spec.guhuo_type) == "string" and spec.guhuo_type ~= "" then skill:setGuhuoDialog(guhuo_type) end
	
	function skill:view_as(cards)
		if #cards > 0 then return nil end
		return spec.view_as(self)
	end

	function skill:view_filter(selected, to_select)
		return false
	end

	skill.enabled_at_play = spec.enabled_at_play
	skill.enabled_at_response = spec.enabled_at_response
	skill.enabled_at_nullification = spec.enabled_at_nullification

	return skill
end

function sgs.CreateEquipCard(spec)
	assert(type(spec.location) == "number" and spec.location ~= sgs.EquipCard_DefensiveHorseLocation and spec.location ~= sgs.EquipCard_OffensiveHorseLocation)
	assert(type(spec.name) == "string" or type(spec.class_name) == "string")
	if not spec.name then spec.name = spec.class_name
	elseif not spec.class_name then spec.class_name = spec.name end
	if spec.suit then assert(type(spec.suit) == "number") end
	if spec.number then assert(type(spec.number) == "number") end
	if spec.location == sgs.EquipCard_WeaponLocation then assert(type(spec.range) == "number") end

	local card = nil
	if spec.location == sgs.EquipCard_WeaponLocation then
		card = sgs.LuaWeapon(spec.suit or sgs.Card_NoSuit, spec.number or 0, spec.range, spec.name, spec.class_name)
	elseif spec.location == sgs.EquipCard_ArmorLocation then
		card = sgs.LuaArmor(spec.suit or sgs.Card_NoSuit, spec.number or 0, spec.name, spec.class_name)
	elseif spec.location == sgs.EquipCard_TreasureLocation then
		card = sgs.LuaTreasure(spec.suit or sgs.Card_NoSuit, spec.number or 0, spec.name, spec.class_name)
	end
	assert(card ~= nil)

	card.on_install = spec.on_install
	card.on_uninstall = spec.on_uninstall

	return card
end

function sgs.CreateWeapon(spec)
	spec.location = sgs.EquipCard_WeaponLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateArmor(spec)
	spec.location = sgs.EquipCard_ArmorLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateTreasure(spec)
	spec.location = sgs.EquipCard_TreasureLocation
	return sgs.CreateEquipCard(spec)
end

function sgs.CreateGeneralLevel(spec)
	assert(type(spec.name) == "string")
	local level = sgs.GeneralLevel(spec.name)
	if type(spec.translation) == "string" then
		sgs.AddTranslationEntry(spec.name, spec.translation)
	end
	if type(spec.description) == "string" then
		level:setDescription(spec.description)
	end
	if type(spec.gatekeepers) == "table" then
		for _,gatekeeper in ipairs(spec.gatekeepers) do
			level:addGateKeeper(gatekeeper)
		end
	elseif type(spec.gatekeepers) == "string" then
		level:addGateKeeper(spec.gatekeepers)
	end
	if type(spec.share_gatekeepers) == "string" then
		level:setShareGateKeepersLevel(spec.share_gatekeepers)
	end
	if type(spec.last_level) == "string" then
		level:setLastLevel(spec.last_level)
	end
	if type(spec.next_level) == "string" then
		level:setNextLevel(spec.next_level)
	end
	if type(spec.parent_level) == "string" then
		level:setParentLevel(spec.parent_level)
	end
	if type(spec.sub_levels) == "table" then
		for _,sublevel in ipairs(spec.sub_levels) do
			level:addSubLevel(sublevel)
		end
	end
	sgs.Sanguosha:addGeneralLevel(level)
	return level
end

lua_skills = {}

function sgs.CreateLuaSkill(info)
	local class = type(info.class) == "string" and info.class or "DummySkill"
	local method = sgs["Create"..class]
	if type(method) == "function" then
		local skill = method(info)
		if type(skill) == "userdata" and skill:inherits("Skill") then
			if type(info.translation) == "string" then
				sgs.AddTranslationEntry(info.name, info.translation)
			end
			if type(info.description) == "string" then
				sgs.AddTranslationEntry(":"..info.name, info.description)
			end
			if type(info.audio) == "table" then
				local onlyone = not info.audio[2]
				for k, v in pairs(info.audio) do
					if type(k) == "number" and type(v) == "string" then
						if onlyone and k == 1 then
							sgs.AddTranslationEntry("$"..info.name, v)
						else
							sgs.AddTranslationEntry("$"..info.name..k, v)
						end
					elseif type(k) == "string" and type(v) == "string" then
						sgs.AddTranslationEntry("$"..k, v)
					end
				end
			elseif type(info.audio) == "string" then
				sgs.AddTranslationEntry("$"..info.name, info.audio)
			end
			if type(info.resource) == "string" then
				skill:setAudioPath(info.resource)
				if type(info.marks) == "table" then
					for _,mark in ipairs(info.marks) do
						if type(mark) == "string" then
							local path = string.format("%s/%s.png", info.resource, mark)
							sgs.Sanguosha:addMarkPath(mark, path)
						end
					end
				end
			end
			if type(info.translations) == "table" then
				for k, v in pairs(info.translations) do
					sgs.AddTranslationEntry(k, v)
				end
			end
			if type(info.related_skills) == "userdata" and info.related_skills:inherits("Skill") then
				if not sgs.Sanguosha:getSkill(info.related_skills:objectName()) then
					sgs.Sanguosha:addSkill(info.related_skills)
				end
				sgs.Sanguosha:addRelatedSkill(info.name, info.related_skills:objectName())
			elseif type(info.related_skills) == "table" then
				for _,skill in ipairs(info.related_skills) do
					if type(skill) == "userdata" and skill:inherits("Skill") then
						if not sgs.Sanguosha:getSkill(skill:objectName()) then
							sgs.Sanguosha:addSkill(skill)
						end
						sgs.Sanguosha:addRelatedSkill(info.name, skill:objectName())
					end
				end
			end
			table.insert(lua_skills, skill)
			return skill
		end
	end
	return sgs.CreateDummySkill(info)
end

local function addSkillToGeneral(general, skill)
	general:addSkill(skill)
	local related_skills = sgs.Sanguosha:getRelatedSkills(skill:objectName())
	for _,rsk in sgs.qlist(related_skills) do
		general:addSkill(rsk:objectName())
	end
end

local function addSkillToGeneralByName(general, skname)
	general:addSkill(skname)
	local related_skills = sgs.Sanguosha:getRelatedSkills(skname)
	for _,rsk in sgs.qlist(related_skills) do
		general:addSkill(rsk:objectName())
	end
end

function sgs.CreateLuaGeneral(info)
	if type(info.name) == "string" and type(info.kingdom) == "string" then
		local pack = nil
		if type(info.package) == "string" then
			pack = sgs.Sanguosha:getPackage(info.package)
		elseif type(info.package) == "userdata" and info.package:inherits("Package") then
			pack = info.package
		end
		local maxhp = 4
		if type(info.maxhp) == "number" then
			maxhp = info.maxhp
		elseif type(info.maxhp) == "string" then
			maxhp = tonumber(info.maxhp)
		end
		local gender = sgs.General_Male
		if type(info.gender) == "number" then
			gender = info.gender
		elseif info.female and type(info.female) == "boolean" then
			gender = sgs.General_Female
		end
		local male = ( gender == sgs.General_Male )
		local hidden = false
		if type(info.hidden) == "boolean" then
			hidden = info.hidden
		end
		local never_shown = false
		if type(info.never_shown) == "boolean" then
			never_shown = info.never_shown
		end
		local general = nil
		if pack then
			general = sgs.General(pack, info.name, info.kingdom, maxhp, male, hidden, never_shown)
		else
			general = sgs.General(info.name, info.kingdom, maxhp, male, hidden, never_shown)
		end
		if not male then
			general:setGender(gender)
		end
		if type(info.real_name) == "string" and info.real_name ~= "" then
			general:setRealName(info.real_name)
		end
		if type(info.crowded) == "boolean" and info.crowded then
			general:setCrowded(info.crowded)
		end
		if type(info.order) == "number" and info.order > 0 and info.order <= 10 then
			general:setOrder(info.order)
		end
		local resource = nil
		if type(info.resource) == "string" then
			if info.use_absolute_path then
				resource = info.resource
			else
				resource = string.format("%s/%s", global_path, info.resource)
			end
			general:setResourcePath(resource)
		end
		if resource and type(info.marks) == "table" then
			for _,mark in ipairs(info.marks) do
				if type(mark) == "string" then
					local path = string.format("%s/%s.png", resource, mark)
					sgs.Sanguosha:addMarkPath(mark, path)
				end
			end
		end
		if type(info.skills) == "table" then
			for _,skill in ipairs(info.skills) do
				if type(skill) == "string" then
					addSkillToGeneralByName(general, skill)
				elseif type(skill) == "userdata" and skill:inherits("Skill") then
					if resource and skill:getAudioPath() == "" then
						skill:setAudioPath(resource)
					end
					if sgs.Sanguosha:getSkill(skill:objectName()) then
						addSkillToGeneralByName(general, skill:objectName())
					else
						addSkillToGeneral(general, skill)
					end
				end
			end
		elseif type(info.skills) == "userdata" and info.skills:inherits("Skill") then
			if resource and info.skills:getAudioPath() == "" then
				info.skills:setAudioPath(resource)
			end
			if sgs.Sanguosha:getSkill(info.skills:objectName()) then
				addSkillToGeneralByName(general, info.skills:objectName())
			else
				addSkillToGeneral(general, info.skills)
			end
		elseif type(info.skills) == "string" then
			local skills = info.skills:split("+")
			for _,skill in ipairs(skills) do
				addSkillToGeneralByName(general, skill)
			end
		end
		if type(info.related_skills) == "string" then
			local skills = info.related_skills:split("+")
			for _,skill in ipairs(skills) do
				general:addRelateSkill(skill)
			end
		elseif type(info.related_skills) == "userdata" and info.related_skills:inherits("Skill") then
			if not sgs.Sanguosha:getSkill(info.related_skills:objectName()) then
				if resource and info.related_skills:getAudioPath() == "" then
					info.related_skills:setAudioPath(resource)
				end
				if pack then
					pack:addSkill(info.related_skills)
				else
					sgs.Sanguosha:addSkill(info.related_skills)
				end
			end
			general:addRelateSkill(info.related_skills:objectName())
		elseif type(info.related_skills) == "table" then
			for _,skill in ipairs(info.related_skills) do
				if type(skill) == "string" then
					general:addRelateSkill(skill)
				elseif type(skill) == "userdata" and skill:inherits("Skill") then
					if resource and skill:getAudioPath() == ""then
						skill:setAudioPath(resource)
					end
					if not sgs.Sanguosha:getSkill(skill:objectName()) then
						if pack then
							pack:addSkill(skill)
						else
							sgs.Sanguosha:addSkill(skill)
						end
					end
					general:addRelateSkill(skill:objectName())
				end
			end
		end
		if type(info.translations) == "table" then
			for key, value in pairs(info.translations) do
				sgs.AddTranslationEntry(key, value)
			end
		end
		if type(info.translation) == "string" then
			sgs.AddTranslationEntry(info.name, info.translation)
		end
		if type(info.title) == "string" then
			sgs.AddTranslationEntry("#"..info.name, info.title)
		end
		if type(info.show_name) == "string" then
			sgs.AddTranslationEntry("&"..info.name, info.show_name)
		end
		if type(info.designer) == "string" then
			sgs.AddTranslationEntry("designer:"..info.name, info.designer)
		end
		if type(info.cv) == "string" then
			sgs.AddTranslationEntry("cv:"..info.name, info.cv)
		end
		if type(info.illustrator) == "string" then
			sgs.AddTranslationEntry("illustrator:"..info.name, info.illustrator)
		end
		if type(info.last_word) == "string" then
			sgs.AddTranslationEntry("~"..info.name, info.last_word)
		end
		return general
	end
	return info
end

lua_package_items = {}

function sgs.CreateLuaPackage(info)
	if type(info.name) == "string" then
		local category = sgs.Package_GeneralPack
		if type(info.category) == "number" then
			category = info.category
		elseif info.GeneralPack and type(info.GeneralPack) == "boolean" then
			category = sgs.Package_GeneralPack
		elseif info.CardPack and type(info.CardPack) == "boolean" then
			category = sgs.Package_CardPack
		elseif info.SpecialPack and type(info.SpecialPack) == "boolean" then
			category = sgs.Package_SpecialPack
		end
		local pack = sgs.Package(info.name, category)
		if type(info.translations) == "table" then
			for key, value in pairs(info.translations) do
				sgs.AddTranslationEntry(key, value)
			end
		end
		if type(info.translation) == "string" then
			sgs.AddTranslationEntry(info.name, info.translation)
		end
		if type(info.generals) == "table" then
			for _,general in ipairs(info.generals) do
				if type(general) == "userdata" and general:inherits("General") then
					pack:addGeneral(general)
					table.insert(lua_package_items, general)
				end
			end
		end
		if type(info.cards) == "table" then
			for _,card in ipairs(info.cards) do
				if type(card) == "userdata" and card:inherits("Card") then
					pack:addCard(card)
					table.insert(lua_package_items, card)
				end
			end
		end
		if type(info.skills) == "table" then
			for _,skill in ipairs(info.skills) do
				if type(skill) == "userdata" and skill:inherits("Skill") then
					pack:addSkill(skill)
					table.insert(lua_package_items, skill)
				end
			end
		end
		return pack
	end
	return info
end

function sgs.LoadTranslationTable(t)
	for key, value in pairs(t) do
		sgs.AddTranslationEntry(key, value)
	end
end
