--[[
	太阳神三国杀武将单挑对战平台·Lua扩展入口文件
]]--
ex = {}
ex_packages = {}
ex_generals = {}
ex_skills = {}
ex_cards = {}
ex_levels = {}
--[[****************************************************************
	添加翻译
]]--****************************************************************
function sgs.LoadTranslationTable(t)
	for key, value in pairs(t) do
		sgs.AddTranslationEntry(key, value)
	end
end
--[[****************************************************************
	缺省函数
]]--****************************************************************
function TriggerSkill_OnTrigger(skill, event, player, data)
	return false
end
function LuaDelayedTrick_AboutToUse(trick, room, use)
	local id = trick:getEffectiveId()
	local wrapped = sgs.Sanguosha:getWrappedCard(id)
	local new_use = use
	new_use.card = wrapped
	local data = sgs.QVariant()
	data:setValue(new_use)
	local user = use.from
	local targets = use.to
	local target = targets:first()
	local thread = room:getThread()
	thread:trigger(sgs.PreCardUsed, room, user, data)
	new_use = data:toCardUse()
	local msg = sgs.LogMessage()
	msg.type = "#UseCard"
	msg.from = user
	msg.to = targets
	msg.card_str = trick:toString()
	room:sendLog(msg)
	local reason = sgs.CardMoveReason(
		sgs.CardMoveReason_S_REASON_USE, 
		user:objectName(), 
		target:objectName(), 
		trick:getSkillName(), 
		""
	)
	room:moveCardTo(trick, user, target, sgs.Player_PlaceDelayedTrick, reason, true)
	thread:trigger(sgs.CardUsed, room, user, data)
	new_use = data:toCardUse()
	thread:trigger(sgs.CardFinished, room, user, data)
end
function LuaDelayedTrick_OnUse(trick, room, user, targets)
	if #targets == 0 then
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, user:objectName(), "", self:getSkillName(), "")
		local id = trick:getEffectiveId()
		local owner = room:getCardOwner(id)
		room:moveCardTo(self, owner, nil, sgs.Player_DiscardPile, reason, true)
	end
end
function LuaDelayedTrick_OnNullified_Movable(trick, target)
	local room = target:getRoom()
	local thread = room:getThread()
	local alives = room:getOtherPlayers(target)
	alives:append(target)
	local p = nil
	for _, player in sgs.qlist(alives) do
		if player:containsTrick(trick:objectName()) then
			continue
		end
		local skill = room:isProhibited(target, player, trick)
		if skill then
			room:broadcastSkillInvoke(skill:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#SkillAvoid"
			msg.from = player
			msg.arg = skill:objectName()
			msg.arg2 = trick:objectName()
			room:sendLog(msg)
			continue
		end
		local reason = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_TRANSFER, 
			target:objectName(), 
			"", 
			trick:getSkillName(), 
			""
		)
		room:moveCardTo(trick, target, player, sgs.Player_PlaceDelayedTrick, reason, true)
		if target:objectName() == player:objectName() then 
			break 
		end
		local use = sgs.CardUseStruct()
		use.from = nil
		use.to:append(player)
		use.card = trick
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
	if p then 
		trick:on_nullified(p) 
	end
end
function LuaDelayedTrick_OnNullified_Unmovable(trick, target)
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, target:objectName())
	local room = target:getRoom()
	room:throwCard(trick, reason, nil)
end
function LuaAOE_Available(aoe, user)
	local avail = false
	local others = user:getSiblings()
	for _,p in sgs.qlist(others) do
		if p:isDead() or user:isProhibited(p, aoe) then
		else
			avail = true
			break
		end
	end
	return avail and aoe:cardIsAvailable(user)
end
function LuaAOE_AboutToUse(aoe, room, use)
	local user = use.from
	local targets = sgs.SPlayerList()
	local others = room:getOtherPlayers(user)
	for _,p in sgs.qlist(others) do
		local skill = room:isProhibited(user, p, aoe)
		if skill then
			room:broadcastSkillInvoke(skill:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#SkillAvoid"
			msg.from = p
			msg.arg = skill:objectName()
			msg.arg2 = aoe:objectName()
		else
			targets:append(p)
		end
	end
	local new_use = use
	new_use.to = targets
	aoe:cardOnUse(room, new_use)
end
function LuaGlobalEffect_Available(trick, user)
	local avail = false
	local targets = user:getSiblings()
	targets:append(user)
	for _,p in sgs.qlist(targets) do
		if p:isDead() or user:isProhibited(p, trick) then
		else
			avail = true
			break
		end
	end
	return avail and trick:cardIsAvailable(user)
end
function LuaGlobalEffect_AboutToUse(trick, room, use)
	local user = use.from
	local targets = sgs.SPlayerList()
	local alives = room:getAlivePlayers()
	for _,p in sgs.qlist(alives) do
		local skill = room:isProhibited(user, p, trick)
		if skill then
			room:broadcastSkillInvoke(skill:objectName())
			local msg = sgs.LogMessage()
			msg.type = "#SkillAvoid"
			msg.from = p
			msg.arg = skill:objectName()
			msg.arg2 = trick:objectName()
		else
			targets:append(p)
		end
	end
	local new_use = use
	new_use.to = targets
	trick:cardOnUse(room, new_use)
end
--[[****************************************************************
	创建扩展包
]]--****************************************************************
function sgs.CreateLuaPackage(info)
	if type(info.name) == "string" then
		local category = sgs.Package_GeneralPack
		if type(info.category) == "number" then
			category = info.category
		elseif info.GeneralPack and type(info.GeneralPack) == "boolean" then
			category = sgs.Package_GeneralPack
		elseif info.CardPack and type(info.CardPack) == "boolean" then
			category = sgs.Package_CardPack
		elseif info.infoialPack and type(info.infoialPack) == "boolean" then
			category = sgs.Package_infoialPack
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
				end
			end
		end
		if type(info.cards) == "table" then
			for _,card in ipairs(info.cards) do
				if type(card) == "userdata" and card:inherits("Card") then
					pack:addCard(card)
				end
			end
		end
		if type(info.skills) == "table" then
			for _,skill in ipairs(info.skills) do
				if type(skill) == "userdata" and skill:inherits("Skill") then
					pack:addSkill(skill)
				end
			end
		end
		table.insert(ex_packages, pack)
		return pack
	end
	return info
end
--[[****************************************************************
	创建武将
]]--****************************************************************
--辅助函数：
function addSkillToGeneral(general, skill)
	general:addSkill(skill)
	local related_skills = sgs.Sanguosha:getRelatedSkills(skill:objectName())
	for _,rsk in sgs.qlist(related_skills) do
		general:addSkill(rsk:objectName())
	end
end
--辅助函数：
function addSkillToGeneralByName(general, skname)
	general:addSkill(skname)
	local related_skills = sgs.Sanguosha:getRelatedSkills(skname)
	for _,rsk in sgs.qlist(related_skills) do
		general:addSkill(rsk:objectName())
	end
end
--辅助函数：
function addGeneralSkills(general, skills, resource)
	if type(skills) == "table" then
		for _,skill in ipairs(skills) do
			if type(skill) == "string" then
				addSkillToGeneralByName(general, skill)
			elseif type(skill) == "userdata" and skill:inherits("Skill") then
				if resource and skill:getAudioPath() == "" then
					skill:setAudioPath(resource)
				end
				local skname = skill:objectName()
				if sgs.Sanguosha:getSkill(skname) then
					addSkillToGeneralByName(general, skname)
				else
					addSkillToGeneral(general, skill)
				end
			end
		end
	elseif type(skills) == "userdata" and skills:inherits("Skill") then
		if resource and skills:getAudioPath() == "" then
			skills:setAudioPath(resource)
		end
		local skname = skills:objectName()
		if sgs.Sanguosha:getSkill(skname) then
			addSkillToGeneralByName(general, skname)
		else
			addSkillToGeneral(general, skills)
		end
	elseif type(skills) == "string" then
		local sknames = skills:split("+")
		for _,skill in ipairs(sknames) do
			addSkillToGeneralByName(general, skill)
		end
	end
end
--辅助函数：
function addGeneralRelatedSkills(general, skills, resource, pack)
	if type(skills) == "string" then
		local sknames = skills:split("+")
		for _,skill in ipairs(sknames) do
			general:addRelateSkill(skill)
		end
	elseif type(skills) == "userdata" and skills:inherits("Skill") then
		local skname = skills:objectName()
		if resource and skills:getAudioPath() == "" then
			skills:setAudioPath(resource)
		end
		if not sgs.Sanguosha:getSkill(skname) then
			if pack then
				pack:addSkill(skills)
			else
				sgs.Sanguosha:addSkill(skills)
			end
		end
		general:addRelateSkill(skname)
	elseif type(skills) == "table" then
		for _,skill in ipairs(skills) do
			if type(skill) == "string" then
				general:addRelateSkill(skill)
			elseif type(skill) == "userdata" and skill:inherits("Skill") then
				if resource and skill:getAudioPath() == "" then
					skill:setAudioPath(resource)
				end
				local skname = skill:objectName()
				if not sgs.Sanguosha:getSkill(skname) then
					if pack then
						pack:addSkill(skill)
					else
						sgs.Sanguosha:addSkill(skill)
					end
				end
				general:addRelateSkill(skname)
			end
		end
	end
end
--主函数：
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
		addGeneralSkills(general, info.skills, resource)
		addGeneralRelatedSkills(general, info.related_skills, resource, pack)
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
		table.insert(ex_generals, general)
		return general
	end
	return info
end
--[[****************************************************************
	创建卡牌
]]--****************************************************************
--辅助函数：创建基本牌
function ex.CreateBasicCard(info)
	local subtype = type(info.subtype) == "string" and info.subtype or "BasicCard"
	local card = sgs.LuaBasicCard(info.suit, info.point, info.name, info.class_name, subtype)
	if type(info.target_fixed) == "boolean" then
		card:setTargetFixed(info.target_fixed)
	end
	if type(info.can_recast) == "boolean" then
		card:setCanRecast(info.can_recast)
	end
	card.filter = info.filter
	card.feasible = info.feasible
	card.available = info.available
	card.about_to_use = info.about_to_use
	card.on_use = info.on_use
	card.on_effect = info.on_effect
	return card
end
--辅助函数：创建锦囊牌
local submatch = {"TrickCard", "single_target_trick", "delayed_trick", "aoe", "global_effect"}
function ex.CreateTrickCard(info)
	local subclass = type(info.subclass) == "number" and info.subclass or sgs.LuaTrickCard_TypeNormal
	local subtype = info.subtype
	if type(subtype) ~= "string" then
		subtype = submatch[subclass] or "TrickCard"
	end
	local card = sgs.LuaTrickCard(info.suit, info.point, info.name, info.class_name, subtype)
	card:setSubClass(subclass)
	if type(info.target_fixed) == "boolean" then
		card:setTargetFixed(info.target_fixed)
	end
	if type(info.can_recast) == "boolean" then
		card:setCanRecast(info.can_recast)
	end
	if subclass == sgs.LuaTrickCard_TypeDelayedTrick then
		info.about_to_use = info.about_to_use or LuaDelayedTrick_AboutToUse
		info.on_use = info.on_use or LuaDelayedTrick_OnUse
		if info.movable then
			info.on_nullified = info.on_nullified or LuaDelayedTrick_OnNullified_Movable
		else
			info.on_nullified = info.on_nullified or LuaDelayedTrick_OnNullified_Unmovable
		end
	elseif subclass == sgs.LuaTrickCard_TypeAOE then
		info.available = info.available or LuaAOE_Available
		info.about_to_use = info.about_to_use or LuaAOE_AboutToUse
		if not info.target_fixed then
			card:setTargetFixed(true)
		end
	elseif subclass == sgs.LuaTrickCard_TypeGlobalEffect then
		info.available = info.available or LuaGlobalEffect_Available
		info.about_to_use = info.about_to_use or LuaGlobalEffect_AboutToUse
		if not info.target_fixed then
			card:setTargetFixed(true)
		end
	end
	card.filter = info.filter
	card.feasible = info.feasible
	card.available = info.available
	card.is_cancelable = info.is_cancelable
	card.on_nullified = info.on_nullified
	card.about_to_use = info.about_to_use
	card.on_use = info.on_use
	card.on_effect = info.on_effect
	return card
end
--辅助函数：创建武器牌
function ex.CreateWeapon(info)
	assert(type(info.range) == "number")
	local card = sgs.LuaWeapon(info.suit, info.point, info.range, info.name, info.class_name)
	card.on_install = info.on_install
	card.on_uninstall = info.on_uninstall
	return card
end
--辅助函数：创建防具牌
function ex.CreateArmor(info)
	local card = sgs.LuaArmor(info.suit, info.point, info.name, info.class_name)
	card.on_install = info.on_install
	card.on_uninstall = info.on_uninstall
	return card
end
--辅助函数：创建宝物牌
function ex.CreateTreasure(info)
	local card = sgs.LuaTreasure(info.suit, info.point, info.name, info.class_name)
	card.on_install = info.on_install
	card.on_uninstall = info.on_uninstall
	return card
end
--辅助函数：创建装备牌
function ex.CreateEquipCard(info)
	local location = info.location
	assert(type(location) == "number")
	if location == sgs.EquipCard_WeaponLocation then
		return ex.CreateWeapon(info)
	elseif location == sgs.EquipCard_ArmorLocation then
		return ex.CreateArmor(info)
	elseif location == sgs.EquipCard_TreasureLocation then
		return ex.CreateTreasure(info)
	end
	assert(false)
end
--主函数
function sgs.CreateLuaCard(info)
	assert(type(info.class) == "string")
	local method = ex[string.format("Create%s", info.class)]
	assert(type(method) == "function")
	local name, class = info.name, info.class_name
	info.name = name or class
	info.class_name = class or name
	assert(type(info.name) == "string")
	info.suit = type(info.suit) == "number" and info.suit or sgs.Card_NoSuit
	info.point = type(info.point) == "number" and info.point or 0
	local card = method(info)
	table.insert(ex_cards, card)
	if type(info.translation) == "string" then
		sgs.AddTranslationEntry(info.name, info.translation)
	end
	if type(info.description) == "string" then
		sgs.AddTranslationEntry(":"..info.name, info.description)
	end
	if type(info.translations) == "table" then
		for key, value in pairs(info.translations) do
			sgs.AddTranslationEntry(key, value)
		end
	end
	table.insert(ex_cards, card)
	return card
end
--[[****************************************************************
	创建技能卡
]]--****************************************************************
function sgs.CreateSkillCard(info)
	assert(info.name)
	local skname = type(info.skill_name) == "string" and info.skill_name or ""
	local card = sgs.LuaSkillCard(info.name, skname)
	assert(type(card) == "userdata" and card:inherits("SkillCard"))
	if type(info.target_fixed) == "boolean" then
		card:setTargetFixed(info.target_fixed)
	end
	if type(info.will_throw) == "boolean" then
		card:setWillThrow(info.will_throw)
	end
	if type(info.can_recast) == "boolean" then
		card:setCanRecast(info.can_recast)
	end
	if type(info.handling_method) == "number" then
		card:setHandlingMethod(info.handling_method)
	end
	if type(info.mute) == "boolean" then
		card:setMute(info.mute)
	end
	if type(info.filter) == "function" then
		function card:filter(...)
			local result, vote = info.filter(self, ...)
			if type(result) == "boolean" and type(vote) == "number" then
				return result, vote
			elseif type(result) == "boolean" and type(vote) == "nil" then
				return result, result and 1 or 0
			elseif type(result) == "number" then
				return result > 0, result
			end
			return false, 0
		end
	end
	card.feasible = info.feasible
	card.about_to_use = info.about_to_use
	card.on_use = info.on_use
	card.on_effect = info.on_effect
	card.on_validate = info.on_validate
	card.on_validate_in_response = info.on_validate_in_response
	table.insert(ex_cards, card)
	return card
end
--[[****************************************************************
	创建技能
]]--****************************************************************
--辅助函数：创建空壳技能
function ex.CreateDummySkill(info)
	local frequency = type(info.frequency) == "number" and info.frequency or sgs.Skill_Compulsory
	return sgs.LuaDummySkill(info.name, frequency)
end
--辅助函数：创建触发技
function ex.CreateTriggerSkill(info)
	local frequency = type(info.frequency) == "number" and info.frequency or sgs.Skill_NotFrequent
	local limit_mark = type(info.limit_mark) == "string" and info.limit_mark or ""
	local skill = sgs.LuaTriggerSkill(info.name, frequency, limit_mark)
	local guhuo_type = info.guhuo_type
	if type(guhuo_type) == "string" and guhuo_type ~= "" then
		skill:setGuhuoDialog(guhuo_type)
	end
	local events = info.events
	if type(events) == "number" then
		skill:addEvent(events)
	elseif type(events) == "table" then
		for _,event in ipairs(events) do
			skill:addEvent(event)
		end
	end
	if type(info.global) == "boolean" then
		skill:setGlobal(info.global)
	end
	skill.on_trigger = type(info.on_trigger) == "function" and info.on_trigger or TriggerSkill_OnTrigger
	if type(info.can_trigger) == "function" then
		skill.can_trigger = info.can_trigger
	end
	local vs_skill = info.view_as_skill
	if type(vs_skill) == "userdata" and vs_skill:inherits("ViewAsSkill") then
		skill:setViewAsSkill(vs_skill)
	end
	if type(info.priority) == "number" then
		skill.priority = info.priority
	elseif type(info.priority) == "table" then
		for event, priority in pairs(info.priority) do
			skill:insertPriorityTable(event, priority)
		end
	end
    if type(info.dynamic_frequency) == "function" then
        skill.dynamic_frequency = info.dynamic_frequency
    end
	return skill
end
--辅助函数：创建视为技
function ex.CreateViewAsSkill(info)
	local response_pattern = type(info.response_pattern) == "string" and info.response_pattern or ""
	local response_or_use = type(info.response_or_use) == "boolean" and info.response_or_use or false
	local expand_pile = type(info.expand_pile) == "string" and info.expand_pile or ""
	local skill = sgs.LuaViewAsSkill(info.name, response_pattern, response_or_use, expand_pile)
	local n = type(info.n) == "number" and info.n or 0
	function skill:view_as(cards)
		return info.view_as(self, cards)
	end
	function skill:view_filter(selected, to_select)
		if #selected < n then
			return info.view_filter(self, selected, to_select)
		end
		return false
	end
	local guhuo_type = info.guhuo_type
	if type(guhuo_type) == "string" and guhuo_type ~= "" then
		skill:setGuhuoDialog(guhuo_type)
	end
	skill.should_be_visible = info.should_be_visible
	skill.effect_index = info.effect_index
	skill.enabled_at_play = info.enabled_at_play
	skill.enabled_at_response = info.enabled_at_response
	skill.enabled_at_nullification = info.enabled_at_nullification
	return skill
end
--辅助函数：创建禁止技
function ex.CreateProhibitSkill(info)
	assert(type(info.is_prohibited) == "function")
	local skill = sgs.LuaProhibitSkill(info.name)
	skill.is_prohibited = info.is_prohibited
	return skill
end
--辅助函数：创建距离修正技
function ex.CreateDistanceSkill(info)
	assert(type(info.correct_func) == "function")
	local skill = sgs.LuaDistanceSkill(info.name)
	skill.correct_func = info.correct_func
	return skill
end
--辅助函数：创建手牌上限技
function ex.CreateMaxCardsSkill(info)
	local skill = sgs.LuaMaxCardsSkill(info.name)
	local check = false
	if type(info.extra_func) == "function" then
		skill.extra_func = info.extra_func
		check = true
	end
	if type(info.fixed_func) == "function" then
		skill.fixed_func = info.fixed_func
		check = true
	end
	assert(check)
	return skill
end
--辅助函数：创建目标增强技
function ex.CreateTargetModSkill(info)
	local pattern = type(info.pattern) == "string" and info.pattern or "Slash"
	local skill = sgs.LuaTargetModSkill(info.name, pattern)
	local check = false
	if type(info.residue_func) == "function" then
		skill.residue_func = info.residue_func
		check = true
	end
	if type(info.distance_limit_func) == "function" then
		skill.distance_limit_func = info.distance_limit_func
		check = true
	end
	if type(info.extra_target_func) == "function" then
		skill.extra_target_func = info.extra_target_func
		check = true
	end
	assert(check)
	return skill
end
--辅助函数：创建攻击范围技
function ex.CreateAttackRangeSkill(info)
	local skill = sgs.LuaAttackRangeSkill(info.name)
	local check = false
	if type(info.extra_func) == "function" then
		skill.extra_func = info.extra_func or 0
		check = true
	end
	if type(info.fixed_func) == "function" then
		skill.fixed_func = info.fixed_func or -1
		check = true
	end
	assert(check)
	return skill
end
--辅助函数：创建技能失效技
function ex.CreateInvaliditySkill(info)
	assert(type(info.skill_valid) == "function")
	local skill = sgs.LuaInvaliditySkill(info.name)
	skill.skill_valid = info.skill_valid
	return skill
end
--辅助函数：创建零卡牌视为技
function ex.CreateZeroCardViewAsSkill(info)
	local response_pattern = type(info.response_pattern) == "string" and info.response_pattern or ""
	local response_or_use = type(info.response_or_use) == "boolean" and info.response_or_use or false
	local skill = sgs.LuaViewAsSkill(info.name, response_pattern, response_or_use, "")
	function skill:view_as(cards)
		if #cards == 0 then
			return info.view_as(self)
		end
	end
	function skill:view_filter(selected, to_select)
		return false
	end
	local guhuo_type = info.guhuo_type
	if type(guhuo_type) == "string" and guhuo_type ~= "" then
		skill:setGuhuoDialog(guhuo_type)
	end
	skill.should_be_visible = info.should_be_visible
	skill.effect_index = info.effect_index
	skill.enabled_at_play = info.enabled_at_play
	skill.enabled_at_response = info.enabled_at_response
	skill.enabled_at_nullification = info.enabled_at_nullification
	return skill
end
--辅助函数：创建单卡牌视为技
function ex.CreateOneCardViewAsSkill(info)
	local response_pattern = type(info.response_pattern) == "string" and info.response_pattern or ""
	local response_or_use = type(info.response_or_use) == "boolean" and info.response_or_use or false
	local expand_pile = type(info.expand_pile) == "string" and info.expand_pile or ""
	local filter_pattern = info.filter_pattern
	local must_response = false
	if filter_pattern then
		assert(type(filter_pattern) == "string")
		if string.sub(filter_pattern, -1, 1) == "!" then
			filter_pattern = string.sub(filter_pattern, 1, -2)
			must_response = true
		end
	end
	if info.view_filter then
		assert(type(info.view_filter) == "function")
	end
	local skill = sgs.LuaViewAsSkill(info.name, response_pattern, response_or_use, expand_pile)
	function skill:view_as(cards)
		if #cards == 1 then
			return info.view_as(self, cards[1])
		end
	end
	function skill:view_filter(selected, to_select)
		if to_select:hasFlag("using") then
			return false
		elseif #selected == 0 then
			if info.view_filter then
				return info.view_filter(self, to_select)
			elseif filter_pattern then
				if must_response and sgs.Self:isJilei(to_select) then 
					return false 
				end
				return sgs.Sanguosha:matchExpPattern(filter_pattern, sgs.Self, to_select)
			end
		end
		return false
	end
	local guhuo_type = info.guhuo_type
	if type(guhuo_type) == "string" and guhuo_type ~= "" then
		skill:setGuhuoDialog(guhuo_type)
	end
	skill.should_be_visible = info.should_be_visible
	skill.effect_index = info.effect_index
	skill.enabled_at_play = info.enabled_at_play
	skill.enabled_at_response = info.enabled_at_response
	skill.enabled_at_nullification = info.enabled_at_nullification
	return skill
end
--辅助函数：创建锁定视为技
function ex.CreateFilterSkill(info)
	assert(type(info.view_filter) == "function")
	assert(type(info.view_as) == "function")
	local skill = sgs.LuaFilterSkill(info.name)
	skill.view_filter = info.view_filter
	skill.view_as = info.view_as
	return skill
end
--辅助函数：创建卖血触发技
function ex.CreateMasochismSkill(info)
	assert(type(info.on_damaged) == "function")
	info.events = sgs.Damaged
	function info.on_trigger(skill, event, player, data)
		local damage = data:toDamage()
		info.on_damaged(skill, player, damage)
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建阶段触发技
function ex.CreatePhaseChangeSkill(info)
	assert(type(info.on_phasechange) == "function")
	info.events = sgs.EventPhaseStart
	function info.on_trigger(skill, event, player, data)
		return info.on_phasechange(skill, player)
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建摸牌触发技
function ex.CreateDrawCardsSkill(info)
	assert(type(info.draw_num_func) == "function")
	info.events = info.is_initial and sgs.DrawInitialCards or sgs.DrawNCards
	function info.on_trigger(skill, event, player, data)
		local x = data:toInt()
		local n = info.draw_num_func(skill, player, x)
		data:setValue(n)
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建游戏启动触发技
function ex.CreateGameStartSkill(info)
	assert(type(info.on_gamestart) == "function")
	info.events = sgs.GameStart
	function info.on_trigger(skill, event, player, data)
		info.on_gamestart(skill, player)
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建虚拟移动触发技
function ex.CreateFakeMoveSkill(info)
	info.events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime}
	info.priority = 10
	info.flag = string.format("%s_InTempMoving", info.name)
	info.on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:hasFlag(info.flag) then
				return true
			end
		end
		return false
	end
	info.can_trigger = function(self, target)
		return target ~= nil
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建技能解除触发技
function ex.CreateDetachEffectSkill(info)
	assert(type(info.on_skill_detached) == "function")
	info.events = sgs.EventLoseSkill
	if type(info.skill) ~= "string" then
		info.skill = info.name
		info.name = string.format("#%s-clear", info.skill)
	end
	function info.on_trigger(skill, event, player, data)
		if data:toString() == info.skill then
			local room = player:getRoom()
			info.on_skill_detached(skill, room, player)
		end
		return false
	end
	function info.can_trigger(skill, target)
		return target ~= nil
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建标记分配技
function ex.CreateMarkAssignSkill(info)
	local n = type(info.n) and info.n or 1
	if type(info.mark) ~= "string" then
		info.mark = info.name
		info.name = string.format("#%s-%d", info.mark, n)
	end
	info.events = sgs.GameStart
	info.on_trigger = function(skill, event, player, data)
		player:gainMark(info.mark, info.n)
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建杀无限距离技
function ex.CreateSlashNoDistanceLimitSkill(info)
	local pattern = type(info.pattern) == "string" and info.pattern or "Slash"
	local skill = sgs.LuaTargetModSkill(info.name, pattern)
	skill.distance_limit_func = function(self, from, card)
		if from:hasSkill(info.name) and card:getSkillName() == info.name then
			return 1000
		end
		return 0
	end
	return skill
end
--辅助函数：创建武器技能
function ex.CreateWeaponSkill(info)
	info.global = true
	info.vs_mark = string.format("View_As_%s", info.name)
	info.can_trigger = function(self, target)
		if target and target:getMark("Equips_Nullified_to_Yourself") == 0 then
			if target:getMark(info.vs_mark) > 0 then
				return true
			elseif target:hasWeapon(info.name) then
				return true
			end
		end
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建防具技能
function ex.CreateArmorSkill(info)
	info.global = true
	info.vs_mark = string.format("View_As_%s", info.name)
	info.can_trigger = function(self, target)
		if target and target:getMark("Equips_Nullified_to_Yourself") == 0 then
			if target:getMark(info.vs_mark) > 0 then
				return true
			elseif not target:getArmor() then
				return false
			elseif target:hasArmorEffect(info.name) then
				return true
			end
		end
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--辅助函数：创建宝物技能
function ex.CreateTreasureSkill(info)
	info.global = true
	info.vs_mark = string.format("View_As_%s", info.name)
	info.can_trigger = function(self, target)
		if target and target:getMark("Equips_Nullified_to_Yourself") == 0 then
			if target:getMark(info.vs_mark) > 0 then
				return true
			elseif not target:getTreasure() then
				return false
			elseif target:hasTreasure(info.name) then
				return true
			end
		end
		return false
	end
	return ex.CreateTriggerSkill(info)
end
--主函数：
function sgs.CreateLuaSkill(info)
	assert(type(info.name) == "string")
	local class = type(info.class) == "string" and info.class or "DummySkill"
	local method = ex[string.format("Create%s", class)]
	assert(type(method) == "function")
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
		local rsks = info.related_skills
		if type(rsks) == "userdata" and rsks:inherits("Skill") then
			local rskname = rsks:objectName()
			if not sgs.Sanguosha:getSkill(rskname) then
				sgs.Sanguosha:addSkill(rsks)
			end
			sgs.Sanguosha:addRelatedSkill(info.name, rskname)
		elseif type(rsks) == "table" then
			for _,rsk in ipairs(rsks) do
				if type(rsk) == "userdata" and rsk:inherits("Skill") then
					local rskname = rsk:objectName()
					if not sgs.Sanguosha:getSkill(rskname) then
						sgs.Sanguosha:addSkill(rsk)
					end
					sgs.Sanguosha:addRelatedSkill(info.name, rskname)
				end
			end
		end
	end
	table.insert(ex_skills, skill)
	return skill
end
--[[****************************************************************
	创建武将级别
]]--****************************************************************
function sgs.CreateGeneralLevel(info)
	assert(type(info.name) == "string")
	local level = sgs.GeneralLevel(info.name)
	if type(info.translation) == "string" then
		sgs.AddTranslationEntry(info.name, info.translation)
	end
	if type(info.description) == "string" then
		level:setDescription(info.description)
	end
	if type(info.gatekeepers) == "table" then
		for _,gatekeeper in ipairs(info.gatekeepers) do
			level:addGateKeeper(gatekeeper)
		end
	elseif type(info.gatekeepers) == "string" then
		level:addGateKeeper(info.gatekeepers)
	end
	if type(info.share_gatekeepers) == "string" then
		level:setShareGateKeepersLevel(info.share_gatekeepers)
	end
	if type(info.last_level) == "string" then
		level:setLastLevel(info.last_level)
	end
	if type(info.next_level) == "string" then
		level:setNextLevel(info.next_level)
	end
	if type(info.parent_level) == "string" then
		level:setParentLevel(info.parent_level)
	end
	if type(info.sub_levels) == "table" then
		for _,sublevel in ipairs(info.sub_levels) do
			level:addSubLevel(sublevel)
		end
	end
	table.insert(ex_levels, level)
	sgs.Sanguosha:addGeneralLevel(level)
	return level
end