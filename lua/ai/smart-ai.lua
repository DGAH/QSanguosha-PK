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
sgs.ais = {}
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
	return math.random(0, 3)
end
function SmartAI:askForSkillInvoke(skill_name, data)
	return math.random(0, 100) < 50
end
function SmartAI:askForChoice(skill_name, choices, data)
	local items = choices:split("+")
	return items[math.random(1, #items)]
end
function SmartAI:askForDiscard(reason, discard_num, min_num, optional, include_equip)
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
end
function SmartAI:askForCardChosen(who, flags, reason, method)
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
	return "."
end
function SmartAI:askForAG(card_ids, refusable, reason)
	if refusable then
		return -1
	end
	return card_ids[math.random(1, #card_ids)]
end
function SmartAI:askForCardShow(requestor, reason)
	return self.player:getRandomHandCard()
end
function SmartAI:askForYiji(card_ids, reason)
	return nil, -1
end
function SmartAI:askForPindian(requestor, reason)
	return self.player:getRandomHandCard()
end
function SmartAI:askForPlayerChosen(targets, reason)
	return targets:at(math.random(0, targets:length()-1))
end
function SmartAI:askForSinglePeach(dying)
	return "."
end
function SmartAI:askForGuanxing(cards, guanxing_type)
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
end