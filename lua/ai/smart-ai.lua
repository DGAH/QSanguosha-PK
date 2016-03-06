--[[
	太阳神三国杀武将单挑对战平台·AI核心文件
]]--
-- "middleclass" is the Lua OOP library written by kikito
-- more information see: https://github.com/kikito/middleclass
require "middleclass"
-- initialize the random seed for later use
math.randomseed(os.time())
-- SmartAI is the base class for all other specialized AI classes
SmartAI = (require "middleclass").class("SmartAI")
version = "QSanguosha-PK Dummy AI"
--- this function is only function that exposed to the host program
--- and it clones an AI instance by general name
-- @param player The ServerPlayer object that want to create the AI object
-- @return The AI object
function CloneAI(player)
	return SmartAI(player).lua_ai
end
dofile "lua/ai/tables.lua"
function SmartAI:initialize(player)
	self.player = player
	self.room = player:getRoom()
	self.role = player:getRole()
	self.lua_ai = sgs.LuaAI(player)
	self.lua_ai.callback = function(full_method_name, ...)
		--The __FUNCTION__ macro is defined as CLASS_NAME::SUBCLASS_NAME::FUNCTION_NAME
		--in MSVC, while in gcc only FUNCTION_NAME is in place.
		local method_name_start = 1
		while true do
			local found = string.find(full_method_name, "::", method_name_start)
			if found ~= nil then
				method_name_start = found + 2
			else
				break
			end
		end
		local method_name = string.sub(full_method_name, method_name_start)
		local method = self[method_name]
		if method then
			local success, result1, result2
			success, result1, result2 = pcall(method, self, ...)
			if not success then
				self.room:writeToConsole(result1)
				self.room:writeToConsole(method_name)
				self.room:writeToConsole(debug.traceback())
				self.room:outputEventStack()
			else
				return result1, result2
			end
		end
	end
	if not sgs.initialized then
		sgs.initialized = true
		sgs.ais = {}
		sgs.turncount = 0
		sgs.debugmode = false
		global_room = self.room
		global_room:writeToConsole(version .. ", Powered by " .. _VERSION)
	end
	sgs.ais[player:objectName()] = self
end
function SmartAI:filterEvent(event, player, data)
	if not sgs.recorder then
		sgs.recorder = self
		self.player:speak(version)
	end
end
function SmartAI:askForSuit(reason)
	local callback = sgs.askForSuitAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self)
	elseif type(callback) == "number" then
		result = callback
	end
	if type(result) == "number" then
		if result >= 0 and result <= 3 then
			return result
		end
	end
	return math.random(0, 3)
end
function SmartAI:askForSkillInvoke(skill_name, data)
	local callback = sgs.askForSkillInvokeAI[skill_name]
	local result
	if type(callback) == "function" then
		result = callback(self, data)
	elseif type(callback) == "boolean" then
		result = callback
	end
	if type(result) == "boolean" then
		return result
	end
	return math.random(0, 100) < 50
end
function SmartAI:askForChoice(skill_name, choices, data)
	local callback = sgs.askForChoiceAI[skill_name]
	local result
	if type(callback) == "function" then
		result = callback(self, choices, data)
	elseif type(callback) == "string" then
		result = callback
	end
	if type(callback) == "string" then
		if string.find(choices, result) then
			return result
		end
	end
	local items = choices:split("+")
	return items[math.random(1, #items)]
end
function SmartAI:askForDiscard(reason, discard_num, min_num, optional, include_equip)
	local callback = sgs.askForDiscardAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, discard_num, min_num, optional, include_equip)
	end
	if type(result) == "table" then
		return result
	end
	if optional then
		return {}
	end
	local flags = include_equip and "he" or "h"
	local cards = self.player:getCards(flags)
	local can_discard = {}
	for _,c in sgs.qlist(cards) do
		if self.player:canDiscard(self.player, c:getEffectiveId()) then
			table.insert(can_discard, c)
		end
	end
	local to_discard = {}
	for i=1, min_num, 1 do
		if #can_discard == 0 then
			return to_discard
		end
		local index = math.random(1, #can_discard)
		table.insert(to_discard, can_discard[index]:getEffectiveId())
		table.remove(can_discard, index)
	end
	return to_discard
end
function SmartAI:askForNullification(trick, from, to, positive)
	for _,callback in ipairs(sgs.askForNullificationAI) do
		if type(callback) == "function" then
			local result = callback(self, trick, from, to, positive)
			if type(result) == "string" then
				return result
			end
		end
	end
end
function SmartAI:askForCardChosen(who, flags, reason, method)
	local callback = sgs.askForCardChosenAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, who, flags, method)
	end
	if type(result) == "number" then
		return result
	end
	local cards = who:getCards(flags)
	if method == sgs.Card_MethodDiscard then
		local can_discard = {}
		for _,c in sgs.qlist(cards) do
			if self.player:canDiscard(who, c:getEffectiveId()) then
				table.insert(can_discard, c)
			end
		end
		return can_discard[math.random(1, #can_discard)]:getEffectiveId()
	else
		return cards:at(math.random(0, cards:length()-1)):getEffectiveId()
	end
end
function SmartAI:askForCard(pattern, prompt, data)
	local promptlist = prompt:split(":")
	local reason, src, dest, arg, arg2 = promptlist[1], promptlist[2], promptlist[3], promptlist[4], promptlist[5]
	reason = reason or "dummy"
	local callback = sgs.askForCardAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, pattern, data, src, dest, arg, arg2)
	end
	if type(result) == "string" then
		return result
	end
	local cards = self.player:getCards("he")
	local can_response = {}
	for _,c in sgs.qlist(cards) do
		if c:match(pattern) then
			table.insert(can_response, c)
		end
	end
	if #can_response == 0 then
		return "."
	end
	return can_response[math.random(1, #can_response)]:getEffectiveId()
end
function SmartAI:askForUseCard(pattern, prompt, method)
	local callback = sgs.askForUseCardAI[pattern]
	local result
	if type(callback) == "function" then
		result = callback(self, prompt, method)
	end
	if type(result) == "string" then
		return result
	end
	return "."
end
function SmartAI:askForAG(card_ids, refusable, reason)
	local callback = sgs.askForAGAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, card_ids, refusable)
	end
	if type(result) == "number" then
		return number
	end
	if refusable then
		return -1
	end
	return card_ids[math.random(1, #card_ids)]
end
function SmartAI:askForCardShow(requestor, reason)
	local callback = sgs.askForCardShowAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, requestor)
	end
	if type(result) == "userdata" and result:inherits("Card") then
		return result
	end
	return self.player:getRandomHandCard()
end
function SmartAI:askForYiji(card_ids, reason)
	local callback = sgs.askForYijiAI[reason]
	local target, id
	if type(callback) == "function" then
		target, id = callback(self, card_ids)
	end
	if type(id) == "number" then
		return target, id
	end
	return nil, -1
end
function SmartAI:askForPindian(requestor, reason)
	local callback = sgs.askForPindianAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, requestor)
	end
	if type(result) == "userdata" and result:inherits("Card") then
		return result
	end
	return self.player:getRandomHandCard()
end
function SmartAI:askForPlayerChosen(targets, reason)
	local callback = sgs.askForPlayerChosenAI[reason]
	local result
	if type(callback) == "function" then
		result = callback(self, targets)
	end
	if type(result) == "userdata" and result:inherits("ServerPlayer") then
		return result
	end
	return targets:at(math.random(0, targets:length()-1))
end
function SmartAI:askForSinglePeach(dying)
	for _,callback in ipairs(sgs.askForSinglePeachAI) do
		if type(callback) == "function" then
			local result = callback(self, dying)
			if type(result) == "string" then
				return result
			end
		end
	end
	return "."
end
function SmartAI:askForGuanxing(cards, guanxing_type)
	local reason = "dummy"
	local callback = sgs.askForGuanxingAI[reason]
	local up, down
	if type(callback) == "function" then
		up, down = callback(self, cards, guanxing_type)
	end
	if type(up) == "table" and type(down) == "table" then
		return up, down
	end
	if guanxing_type == sgs.Room_GuanxingBothSides then
		return cards, {}
	elseif guanxing_type == sgs.Room_GuanxingUpOnly then
		return cards, {}
	elseif guanxing_type == sgs.Room_GuanxingDownOnly then
		return {}, cards
	end
	return cards, {}
end
function SmartAI:activate(use)
	for _,callback in ipairs(sgs.activateAI) do
		if type(callback) == "function" then
			callback(self, use)
			if use:isValid() then
				return
			end
		end
	end
end