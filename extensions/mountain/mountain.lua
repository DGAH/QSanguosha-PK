--[[
	太阳神三国杀武将单挑对战平台·山武将包
	武将总数：8
	武将一览：
		1、张郃（巧变）
		2、邓艾（屯田、凿险）+（急袭）
		3、姜维（挑衅、志继）+（观星）
		4、刘禅（享乐、放权、若愚）+（激将）
		5、孙策（激昂、魂姿、制霸）+（英姿、英魂）
		6、张昭张纮（直谏、固政）
		7、左慈（化身、新生）
		8、蔡文姬（悲歌、断肠）
]]--
--[[****************************************************************
	称号：料敌机先
	武将：张郃
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：巧变
	描述：除准备阶段和结束阶段的阶段开始前，你可以弃置一张手牌：若如此做，你跳过该阶段。若以此法跳过摸牌阶段，你可以依次获得一至两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌置于另一名角色相应的区域内。
]]--
QiaoBianDrawCard = sgs.CreateSkillCard{
	name = "QiaoBianDrawCard",
	skill_name = "QiaoBian",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets < 2 then
			if to_select:objectName() == sgs.Self:objectName() then
			elseif to_select:isKongcheng() then
			else
				return true
			end
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets <= 2 and #targets > 0
	end,
	on_use = function(self, room, source, targets)
		for _,target in ipairs(targets) do
			if source:isAlive() and target:isAlive() then
				if not target:isKongcheng() then
					room:cardEffect(self, source, target)
				end
			end
		end
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local id = room:askForCardChosen(source, target, "h", "QiaoBian")
		if id >= 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName())
			local card = sgs.Sanguosha:getCard(id)
			room:obtainCard(source, card, reason, false)
		end
	end,
}
QiaoBianPlayCard = sgs.CreateSkillCard{
	name = "QiaoBianPlayCard",
	skill_name = "QiaoBian",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:hasEquip() then
				return true
			elseif not to_select:getJudgingArea():isEmpty() then
				return true
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local card_id = room:askForCardChosen(source, target, "ej", "QiaoBian")
		if card_id < 0 then
			return
		end
		local card = sgs.Sanguosha:getCard(card_id)
		local place = room:getCardPlace(card_id)
		local index = -1
		if place == sgs.Player_PlaceEquip then
			local equip = card:getRealCard():toEquipCard()
			index = equip:location()
		end
		local others = room:getOtherPlayers(target)
		local to_select = sgs.SPlayerList()
		for _,p in sgs.qlist(others) do
			if index == -1 then
				if source:isProhibited(p, card) then
				elseif p:containsTrick(card:objectName()) then
				else
					to_select:append(p)
				end
			elseif not p:getEquip(index) then
				to_select:append(p)
			end
		end
		if to_select:isEmpty() then
			return
		end
		local prompt = string.format("@QiaoBianTo:::%s", card:objectName())
		room:setPlayerFlag(target, "QiaoBianTarget")
		local dest = room:askForPlayerChosen(source, to_select, "QiaoBian", prompt)
		room:setPlayerFlag(target, "-QiaoBianTarget")
		if dest then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), "QiaoBian", "")
			room:moveCardTo(card, target, dest, place, reason)
		end
	end,
}
QiaoBianVS = sgs.CreateLuaSkill{
	name = "QiaoBian",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		local phase = sgs.Self:getMark("QiaoBianPhase")
		if phase == tonumber(sgs.Player_Draw) then
			return QiaoBianDrawCard:clone()
		elseif phase == tonumber(sgs.Player_Play) then
			return QiaoBianPlayCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@QiaoBian"
	end,
}
QiaoBian = sgs.CreateLuaSkill{
	name = "QiaoBian",
	translation = "巧变",
	description = "除准备阶段和结束阶段的阶段开始前，你可以弃置一张手牌：若如此做，你跳过该阶段。若以此法跳过摸牌阶段，你可以依次获得一至两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌置于另一名角色相应的区域内。",
	audio = {
		"虚招令旗，以之惑敌。",
		"绝其汲道，困其刍粮。",
		"以守为攻，后发制人。",
		"停止前进，扎营御敌！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	view_as_skill = QiaoBianVS,
	on_trigger = function(self, event, player, data)
		if player:canDiscard(player, "h") then
			local change = data:toPhaseChange()
			local phase = change.to
			local index = 0
			if phase == sgs.Player_Judge then
				index = 1
			elseif phase == sgs.Player_Draw then
				index = 2
			elseif phase == sgs.Player_Play then
				index = 3
			elseif phase == sgs.Player_Discard then
				index = 4
			else
				return false
			end
			local prompt = string.format("@QiaoBianInvoke-%d", index)
			local room = player:getRoom()
			if room:askForDiscard(player, "QiaoBian", 1, 1, true, false, prompt) then
				room:broadcastSkillInvoke("QiaoBian", index)
				if player:isDead() or player:isSkipped(phase) then
					return false
				elseif index == 2 or index == 3 then
					room:setPlayerMark(player, "QiaoBianPhase", tonumber(phase))
					prompt = string.format("@QiaoBian-%d", index)
					room:askForUseCard(player, "@@QiaoBian", prompt, index)
				end
				player:skip(phase)
			end
		end
		return false
	end,
	translations = {
		["@QiaoBianInvoke-1"] = "你可以弃置 1 张手牌跳过判定阶段",
		["@QiaoBianInvoke-2"] = "你可以弃置 1 张手牌跳过摸牌阶段",
		["@QiaoBianInvoke-3"] = "你可以弃置 1 张手牌跳过出牌阶段",
		["@QiaoBianInvoke-4"] = "你可以弃置 1 张手牌跳过弃牌阶段",
		["@QiaoBian-2"] = "你可以依次获得一至两名其他角色的各一张手牌",
		["@QiaoBian-3"] = "你可以将场上的一张牌移动至另一名角色相应的区域内",
		["~QiaoBian2"] = "选择 1-2 名其他角色→点击“确定”",
		["~QiaoBian3"] = "选择一名角色→点击“确定”",
	},
}
--武将信息：张郃
ZhangHe = sgs.CreateLuaGeneral{
	name = "zhanghe",
	translation = "张郃",
	title = "料敌机先",
	kingdom = "wei",
	order = 5,
	cv = "爪子",
	illustrator = "张帅",
	skills = QiaoBian,
	last_word = "归兵勿追，追兵难归啊……",
	resource = "zhanghe",
}
--[[****************************************************************
	称号：矫然的壮士
	武将：邓艾
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：屯田
	描述：你的回合外，每当你失去一次牌后，你可以进行判定：若结果不为♥，将判定牌置于武将牌上，称为“田”。你与其他角色的距离-X。（X为“田”的数量） 
]]--
TunTianDist = sgs.CreateLuaSkill{
	name = "#TunTianDist",
	translation = "屯田",
	class = "DistanceSkill",
	correct_func = function(self, from, to)
		if from:hasSkill("TunTian") then
			return - from:getPile("field"):length()
		end
		return 0
	end,
}
TunTian = sgs.CreateLuaSkill{
	name = "TunTian",
	translation = "屯田",
	description = "你的回合外，每当你失去一次牌后，你可以进行判定：若结果不为红心，将判定牌置于武将牌上，称为“田”。你与其他角色的距离-X。（X为“田”的数量）",
	audio = {
		"食者，兵之所系；农者，胜之所依。",
		"积军资之粮，通漕运之道。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			if event == sgs.CardsMoveOneTime then
				local move = data:toMoveOneTime()
				local source = move.from
				local can_invoke = false
				if source and source:objectName() == player:objectName() then
					local from = move.from_places
					if from:contains(sgs.Player_PlaceHand) or from:contains(sgs.Player_PlaceEquip) then
						local target = move.to
						if target and target:objectName() == player:objectName() then
							local to = move.to_place
							if to == sgs.Player_PlaceHand or to == sgs.Player_PlaceEquip then
							else
								can_invoke = true
							end
						else
							can_invoke = true
						end
					end
				end
				if can_invoke then
					if player:askForSkillInvoke("TunTian", data) then
						room:broadcastSkillInvoke("TunTian")
						local judge = sgs.JudgeStruct()
						judge.who = player
						judge.reason = "TunTian"
						judge.pattern = ".|heart"
						judge.good = false
						room:judge(judge)
					end
				end
			elseif event == sgs.FinishJudge then
				local judge = data:toJudge()
				if judge.reason == "TunTian" and judge.who:objectName() == player:objectName() then
					if judge:isGood() then
						local id = judge.card:getEffectiveId()
						local place = room:getCardPlace(id)
						if place == sgs.Player_PlaceJudge then
							player:addToPile("field", id)
						end
					end
				end
			end
		end
		return false
	end,
	related_skills = TunTianDist,
	translations = {
		["field"] = "田",
	},
}
--[[
	技能：凿险（觉醒技）
	描述：准备阶段开始时，若你的“田”大于或等于三张，你失去1点体力上限，然后获得“急袭”（你可以将一张“田”当【顺手牵羊】使用）。
]]--
ZaoXian = sgs.CreateLuaSkill{
	name = "ZaoXian",
	translation = "凿险",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的“田”大于或等于三张，你失去1点体力上限，然后获得“急袭”。\
\
☆<b>急袭</b>：你可以将一张“田”当【顺手牵羊】使用。",
	audio = "孤注一掷，胜败在此一举！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local fields = player:getPile("field")
		local n = fields:length()
		if n >= 3 then
			local room = player:getRoom()
			room:broadcastSkillInvoke("ZaoXian")
			room:notifySkillInvoked(player, "ZaoXian")
			room:doSuperLightbox("dengai", "ZaoXian")
			local msg = sgs.LogMessage()
			msg.type = "#ZaoXianWake"
			msg.from = player
			msg.arg = n
			msg.arg2 = "ZaoXian"
			room:sendLog(msg)
			room:setPlayerMark(player, "ZaoXianWaked", 1)
			room:loseMaxHp(player)
			if player:isAlive() then
				room:acquireSkill(player, "JiXi")
				player:gainMark("@waked")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("ZaoXian") then
			if target:getMark("ZaoXianWaked") == 0 then
				return target:getPhase() == sgs.Player_Start
			end
		end
		return false
	end,
}
--[[
	技能：急袭
	描述：你可以将一张“田”当【顺手牵羊】使用。
]]--
JiXi = sgs.CreateLuaSkill{
	name = "JiXi",
	translation = "急袭",
	description = "你可以将一张“田”当【顺手牵羊】使用。",
	audio = {
		"给我一张，又何妨？",
		"明修栈道，暗度陈仓！",
	},
	class = "OneCardViewAsSkill",
	filter_pattern = ".|.|.|field",
	expand_pile = "field",
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local trick = sgs.Sanguosha:cloneCard("snatch", suit, point)
		trick:addSubcard(card)
		trick:setSkillName("JiXi")
		return trick
	end,
	enabled_at_play = function(self, player)
		return not player:getPile("field"):isEmpty()
	end,
}
--武将信息：邓艾
DengAi = sgs.CreateLuaGeneral{
	name = "dengai",
	translation = "邓艾",
	title = "矫然的壮士",
	kingdom = "wei",
	order = 7,
	cv = "烨子",
	skills = {TunTian, ZaoXian},
	related_skills = JiXi,
	last_word = "吾破蜀克敌，竟葬于奸贼之手！",
	resource = "dengai",
}
--[[****************************************************************
	称号：龙的衣钵
	武将：姜维
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：挑衅（阶段技）
	描述：你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。
]]--
TiaoXinCard = sgs.CreateSkillCard{
	name = "TiaoXinCard",
	skill_name = "TiaoXin",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:inMyAttackRange(sgs.Self)
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		if target:canSlash(source, false) then
			local prompt = string.format("@TiaoXin:%s", source:objectName())
			if room:askForUseSlashTo(target, source, prompt) then
				return
			end
		end
		if source:canDiscard(target, "he") then
			local id = room:askForCardChosen(source, target, "he", "TiaoXin", false, sgs.Card_MethodDiscard)
			if id >= 0 then
				room:throwCard(id, target, source)
			end
		end
	end,
}
TiaoXin = sgs.CreateLuaSkill{
	name = "TiaoXin",
	translation = "挑衅",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令攻击范围内包含你的一名角色对你使用一张【杀】，否则你弃置其一张牌。",
	audio = {
		"贼将早降，可免一死！",
		"哼，贼将莫不是怕了？",
		"敌将可破得我八阵？",
	},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return TiaoXinCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#TiaoXinCard")
	end,
	effect_index = function(self, player, card)
		if player:hasArmorEffect("eight_diagram") then
			return 3
		end
		return math.random(1, 2)
	end,
}
--[[
	技能：志继（觉醒技）
	描述：准备阶段开始时，若你没有手牌，你失去1点体力上限，然后回复1点体力或摸两张牌，并获得“观星”。
]]--
ZhiJi = sgs.CreateLuaSkill{
	name = "ZhiJi",
	translation = "志继",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你没有手牌，你失去1点体力上限，然后回复1点体力或摸两张牌，并获得“观星”。",
	audio = "今虽穷极，然先帝之志、丞相之托，维岂敢忘？！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("ZhiJi")
		room:notifySkillInvoked(player, "ZhiJi")
		room:doSuperLightbox("jiangwei", "ZhiJi")
		local msg = sgs.LogMessage()
		msg.type = "#ZhiJiWake"
		msg.from = player
		msg.arg = "ZhiJi"
		room:sendLog(msg)
		room:setPlayerMark(player, "ZhiJiWaked", 1)
		room:loseMaxHp(player)
		if player:isAlive() then
			local choices = {}
			if player:getLostHp() > 0 then
				table.insert(choices, "recover")
			end
			table.insert(choices, "draw")
			choices = table.concat(choices, "+")
			local choice = room:askForChoice(player, "ZhiJi", choices)
			if choice == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(player, recover)
			elseif choice == "draw" then
				room:drawCards(player, 2, "ZhiJi")
			end
			room:acquireSkill(player, "guanxing")
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("ZhiJi") then
			if target:getMark("ZhiJiWaked") == 0 then
				if target:getPhase() == sgs.Player_Start then
					return target:isKongcheng()
				end
			end
		end
		return false
	end,
	translations = {
		["#ZhiJiWake"] = "%from 没有手牌，触发“%arg”觉醒",
		["ZhiJi:recover"] = "回复1点体力",
		["ZhiJi:draw"] = "摸两张牌",
	},
}
--[[
	技能：观星
	描述：准备阶段开始时，你可以观看牌堆顶的两张牌，然后将任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。
]]--
GuanXing = sgs.CreateLuaSkill{
	name = "mountainGuanXing",
	translation = "观星",
	description = "准备阶段开始时，你可以观看牌堆顶的两张牌，然后将任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。",
	audio = {
		"北伐兴蜀汉，继志越祁山！",
		"系从尚父出，术奉武侯来！",
	},
	class = "TriggerSkill",
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			if player:askForSkillInvoke("mountainGuanXing", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("mountainGuanXing")
				local ids = room:getNCards(2)
				local msg = sgs.LogMessage()
				msg.type = "$ViewDrawPile"
				msg.from = player
				msg.card_str = string.format("%d+%d", ids:first(), ids:at(1))
				room:sendLog(msg)
				room:askForGuanxing(player, ids)
			end
		end
		return false
	end,
}
--武将信息：姜维
JiangWei = sgs.CreateLuaGeneral{
	name = "jiangwei",
	translation = "姜维",
	title = "龙的衣钵",
	kingdom = "shu",
	order = 8,
	cv = "Jr. Wakaran，LeleK",
	skills = {TiaoXin, ZhiJi},
	related_skills = GuanXing,
	last_word = "臣等正欲死战，陛下何故先降？",
	resource = "jiangwei",
}
--[[****************************************************************
	称号：无为的真命主
	武将：刘禅
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：享乐（锁定技）
	描述：每当你成为【杀】的目标时，【杀】的使用者须弃置一张基本牌，否则此【杀】对你无效。
]]--
XiangLe = sgs.CreateLuaSkill{
	name = "XiangLe",
	translation = "享乐",
	description = "<font color=\"blue\"><b>享乐</b></font>，每当你成为【杀】的目标时，【杀】的使用者须弃置一张基本牌，否则此【杀】对你无效。",
	audio = {
		"此间乐，不思蜀。呵呵呵……",
		"如此甚好，哈哈，甚好！",
	},
	--class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") then
			local room = player:getRoom()
			room:broadcastSkillInvoke("XiangLe")
			room:sendCompulsoryTriggerLog(player, "XiangLe")
			if room:askForCard(use.from, ".Basic", "@XiangLe", data) then
				return false
			end
			table.insert(use.nullified_list, player:objectName()) --失效，原因待查
			data:setValue(use)
		end
		return false
	end,
	translations = {
		["@XiangLe"] = "你须再弃置一张基本牌使此【杀】生效",
	},
}
--[[
	技能：放权
	描述：你可以跳过你的出牌阶段。若以此法跳过出牌阶段，结束阶段开始时你可以弃置一张手牌并选择一名其他角色：若如此做，该角色进行一个额外的回合。
]]--
FangQuanEffect = sgs.CreateLuaSkill{
	name = "#FangQuanEffect",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			local room = player:getRoom()
			local target = room:getTag("FangQuanTarget"):toPlayer()
			if target then
				room:removeTag("FangQuanTarget")
				if target:isAlive() then
					target:gainAnExtraTurn()
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	priority = 1,
}
FangQuanCard = sgs.CreateSkillCard{
	name = "FangQuanCard",
	skill_name = "FangQuan",
	target_fixed = false,
	will_throw = true,
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
		local msg = sgs.LogMessage()
		msg.type = "#FangQuan"
		msg.from = source
		msg.to:append(target)
		room:sendLog(msg)
		local tag = sgs.QVariant()
		tag:setValue(target)
		room:setTag("FangQuanTarget", tag)
	end,
}
FangQuanVS = sgs.CreateLuaSkill{
	name = "FangQuan",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		elseif sgs.Self:canDiscard(sgs.Self, to_select:getEffectiveId()) then
			return true
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = FangQuanCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@FangQuan"
	end,
}
FangQuan = sgs.CreateLuaSkill{
	name = "FangQuan",
	translation = "放权",
	description = "你可以跳过你的出牌阶段。若以此法跳过出牌阶段，结束阶段开始时你可以弃置一张手牌并选择一名其他角色：若如此做，该角色进行一个额外的回合。",
	audio = {
		"一切但凭相父作主。",
		"孩儿……愚钝。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	view_as_skill = FangQuanVS,
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		local phase = change.to
		local room = player:getRoom()
		if phase == sgs.Player_Play then
			if player:isSkipped(sgs.Player_Play) then
				return false
			elseif player:askForSkillInvoke("FangQuan", data) then
				room:setPlayerFlag(player, "FangQuanInvoked")
				player:skip(sgs.Player_Play, true)
			end
		elseif phase == sgs.Player_NotActive then
			if player:hasFlag("FangQuanInvoked") then
				if player:canDiscard(player, "h") then
					room:askForUseCard(player, "@@FangQuan", "@FangQuan", -1, sgs.Card_MethodDiscard)
				end
			end
		end
		return false
	end,
	translations = {
		["@FangQuan"] = "你可以弃置一张手牌令一名其他角色进行一个额外的回合",
		["~FangQuan"] = "选择一张手牌→选择一名其他角色→点击确定",
		["#FangQuan"] = "%from 发动了“放权”，%to 将进行一个额外的回合",
	},
	related_skills = FangQuanEffect,
}
--[[
	技能：若愚（主公技、觉醒技）[空壳技能]
	描述：准备阶段开始时，若你的体力值为场上最少（或之一），你增加1点体力上限，回复1点体力，然后获得“激将”。
]]--
RuoYu = sgs.CreateLuaSkill{
	name = "RuoYu",
	translation = "若愚",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的体力值为场上最少（或之一），你增加1点体力上限，回复1点体力，然后获得“激将”。",
}
--[[
	技能：激将
	描述：每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。
]]--
--武将信息：刘禅
LiuShan = sgs.CreateLuaGeneral{
	name = "liushan",
	translation = "刘禅",
	title = "无为的真命主",
	kingdom = "shu",
	maxhp = 3,
	order = 6,
	cv = "V7",
	illustrator = "LiuHeng",
	skills = {XiangLe, FangQuan, RuoYu},
	related_skills = "jijiang",
	last_word = "吾降！吾降矣……",
	resource = "liushan",
}
--[[****************************************************************
	称号：江东的小霸王
	武将：孙策
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：激昂
	描述：每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。
]]--
JiAng = sgs.CreateLuaSkill{
	name = "JiAng",
	translation = "激昂",
	description = "每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。",
	audio = {
		"所向皆破，敌莫敢当！",
		"众将听令，直讨敌酋！",
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
		if player:askForSkillInvoke("JiAng", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("JiAng", index)
			room:drawCards(player, 1, "JiAng")
		end
		return false
	end,
}
--[[
	技能：魂姿（觉醒技）
	描述：准备阶段开始时，若你的体力值为1，你失去1点体力上限，然后获得“英姿”和“英魂”。
]]--
HunZi = sgs.CreateLuaSkill{
	name = "HunZi",
	translation = "魂姿",
	description = "<font color=\"purple\"><b>觉醒技</b></font>，准备阶段开始时，若你的体力值为1，你失去1点体力上限，然后获得“英姿”和“英魂”。",
	audio = "父亲在上，魂佑江东；公瑾在旁，智定天下！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:broadcastSkillInvoke("HunZi")
		room:notifySkillInvoked(player, "HunZi")
		room:doSuperLightbox("sunce", "HunZi")
		local msg = sgs.LogMessage()
		msg.type = "#HunziWake"
		msg.from = player
		msg.arg = "HunZi"
		room:sendLog(msg)
		room:setPlayerMark(player, "HunZiWaked", 1)
		room:loseMaxHp(player)
		if player:isAlive() then
			room:acquireSkill(player, "mountainYingZi")
			room:acquireSkill(player, "mountainYingHun")
			player:gainMark("@waked")
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("HunZi") then
			if target:getPhase() == sgs.Player_Start then
				if target:getHp() == 1 and target:getMark("HunZiWaked") == 0 then
					return true
				end
			end
		end
		return false
	end,
	translations = {
		["#HunziWake"] = "%from 的体力值为 <font color=\"yellow\"><b>1</b></font>，触发“%arg”觉醒",
	},
}
--[[
	技能：制霸（主公技、阶段技）[空壳技能]
	描述：其他吴势力角色的出牌阶段，该角色可以与你拼点：若该角色没赢，你可以获得你与该角色的拼点牌。若你已发动“魂姿”，你可以拒绝此拼点。
]]--
ZhiBa = sgs.CreateLuaSkill{
	name = "ZhiBa",
	translation = "制霸",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"green\"><b>阶段技</b></font>，其他吴势力角色的出牌阶段，该角色可以与你拼点：若该角色没赢，你可以获得你与该角色的拼点牌。若你已发动“魂姿”，你可以拒绝此拼点。",
}
--[[
	技能：英姿
	描述：摸牌阶段，你可以额外摸一张牌。
]]--
YingZi = sgs.CreateLuaSkill{
	name = "mountainYingZi",
	translation = "英姿",
	description = "摸牌阶段，你可以额外摸一张牌。",
	audio = "雄武江东，威行天下！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("mountainYingZi", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("mountainYingZi")
			local n = data:toInt() + 1
			data:setValue(n)
		end
		return false
	end,
}
--[[
	技能：英魂
	描述：准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）
]]--
YingHun = sgs.CreateLuaSkill{
	name = "mountainYingHun",
	translation = "英魂",
	description = "准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）",
	audio = {
		"继吾父英魂，成江东大业！",
		"小霸王在此，匹夫受死！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			if player:isWounded() then
				local room = player:getRoom()
				local others = room:getOtherPlayers(player)
				local target = room:askForPlayerChosen(player, others, "mountainYingHun", "@mountainYingHun", true, true)
				if target then
					local x = player:getLostHp()
					local choice = "draw"
					if x ~= 1 then
						choice = room:askForChoice(player, "mountainYingHun", "discard+draw")
					end
					if choice == "discard" then
						room:broadcastSkillInvoke("mountainYingHun", 2)
						room:drawCards(target, 1, "mountainYingHun")
						room:askForDiscard(target, "mountainYingHun", x, x, false, true)
					elseif choice == "draw" then
						room:broadcastSkillInvoke("mountainYingHun", 1)
						room:drawCards(target, x, "mountainYingHun")
						room:askForDiscard(target, "mountainYingHun", 1, 1, false, true)
					end
				end
			end
		end
		return false
	end,
	translations = {
		["@mountainYingHun"] = "您可以选择一名角色发动技能“英魂”",
		["mountainYingHun:discard"] = "令其摸一张牌，然后弃X张牌",
		["mountainYingHun:draw"] = "令其摸X张牌，然后弃一张牌",
	},
}
--武将信息：孙策
SunCe = sgs.CreateLuaGeneral{
	name = "sunce",
	translation = "孙策",
	title = "江东的小霸王",
	kingdom = "wu",
	order = 6,
	cv = "猎狐",
	skills = {JiAng, HunZi, ZhiBa},
	related_skills = {YingZi, YingHun},
	last_word = "内事不决问张昭，外事不决问周瑜……",
	resource = "sunce",
}
--[[****************************************************************
	称号：经天纬地
	武将：张昭张纮
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：直谏
	描述：出牌阶段，你可以将你手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。
]]--
ZhiJianCard = sgs.CreateSkillCard{
	name = "ZhiJianCard",
	skill_name = "ZhiJian",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() == sgs.Self:objectName() then
				return false
			end
			local id = self:getSubcards():first()
			local equip = sgs.Sanguosha:getCard(id)
			equip = equip:getRealCard():toEquipCard()
			local index = equip:location()
			return not to_select:getEquip(index)
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), "ZhiJian", "")
		room:moveCardTo(self, source, target, sgs.Player_PlaceEquip, reason)
		local msg = sgs.LogMessage()
		msg.type = "$ZhijianEquip"
		msg.from = target
		msg.card_str = self:getEffectiveId()
		room:sendLog(msg)
		if source:isAlive() then
			room:drawCards(source, 1, "ZhiJian")
		end
	end,
}
ZhiJian = sgs.CreateLuaSkill{
	name = "ZhiJian",
	translation = "直谏",
	description = "出牌阶段，你可以将你手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。",
	audio = "忠謇方直，动不为己。",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isKindOf("EquipCard") then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = ZhiJianCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
--[[
	技能：固政
	描述：其他角色的弃牌阶段结束时，你可以令其获得一张弃牌堆中此阶段中因弃置而置入弃牌堆的该角色的手牌：若如此做，你获得弃牌堆中其余此阶段因弃置而置入弃牌堆的牌。
]]--
GuZheng = sgs.CreateLuaSkill{
	name = "GuZheng",
	translation = "固政",
	description = "其他角色的弃牌阶段结束时，你可以令其获得一张弃牌堆中此阶段中因弃置而置入弃牌堆的该角色的手牌：若如此做，你获得弃牌堆中其余此阶段因弃置而置入弃牌堆的牌。",
	audio = {
		"隐息师徒，广开播殖。",
		"任贤使能，务崇宽惠。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			if player:isAlive() and player:hasSkill("GuZheng") then
				local current = room:getCurrent()
				if current then
					if current:objectName() == player:objectName() then
						return false
					elseif current:getPhase() ~= sgs.Player_Discard then
						return false
					end
					local move = data:toMoveOneTime()
					local basic = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
					if basic == sgs.CardMoveReason_S_REASON_DISCARD then
						local to_get = player:getTag("GuZhengToGet"):toIntList()
						local to_other = player:getTag("GuZhengToOther"):toIntList()
						local source = move.from
						local flag = source and source:objectName() == current:objectName() or false
						for index, id in sgs.qlist(move.card_ids) do
							local place = move.from_places:at(index)
							if flag and place == sgs.Player_PlaceHand then
								to_get:append(id)
							elseif not to_get:contains(id) then
								to_other:append(id)
							end
						end
						local tag = sgs.QVariant()
						tag:setValue(to_get)
						player:setTag("GuZhengToGet", tag)
						tag = sgs.QVariant()
						tag:setValue(to_other)
						player:setTag("GuZhengToOther", tag)
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard then
				local others = room:getOtherPlayers(player)
				for _,source in sgs.qlist(others) do
					if source:hasSkill("GuZheng") then
						local to_get = source:getTag("GuZhengToGet"):toIntList()
						local to_other = source:getTag("GuZhengToOther"):toIntList()
						source:removeTag("GuZhengToGet")
						source:removeTag("GuZhengToOther")
						if source:isDead() then
							continue
						end
						local card_ids = sgs.IntList()
						local get_ids = sgs.IntList()
						for _,id in sgs.qlist(to_get) do
							if room:getCardPlace(id) == sgs.Player_DiscardPile then
								get_ids:append(id)
								card_ids:append(id)
							end
						end
						if get_ids:isEmpty() then
							continue
						end
						local other_ids = sgs.IntList()
						for _,id in sgs.qlist(to_other) do
							if room:getCardPlace(id) == sgs.Player_DiscardPile then
								other_ids:append(id)
								card_ids:append(id)
							end
						end
						local ai_data = sgs.QVariant()
						ai_data:setValue(card_ids)
						if source:askForSkillInvoke("GuZheng", ai_data) then
							room:broadcastSkillInvoke("GuZheng")
							room:fillAG(card_ids, source, other_ids)
							local to_back = room:askForAG(source, get_ids, false, "GuZheng")
							room:clearAG(source)
							if to_back >= 0 then
								card_ids:removeOne(to_back)
								local card = sgs.Sanguosha:getCard(to_back)
								room:obtainCard(player, card)
							end
							local dummy = sgs.DummyCard(card_ids)
							room:obtainCard(source, dummy)
							dummy:deleteLater()
						end
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Discard then
				local others = room:getOtherPlayers(player)
				for _,p in sgs.qlist(others) do
					p:removeTag("GuZhengToGet")
					p:removeTag("GuZhengToOther")
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--武将信息：张昭张纮
ZhangZhaoZhangHong = sgs.CreateLuaGeneral{
	name = "zhangzhaozhanghong",
	translation = "张昭张纮",
	title = "经天纬地",
	kingdom = "wu",
	maxhp = 3,
	crowded = true,
	order = 1,
	cv = "喵小林，风叹息",
	illustrator = "废柴男",
	skills = {ZhiJian, GuZheng},
	last_word = "此生智谋，已为江东尽……",
	resource = "zhangzhaozhanghong",
}
--[[****************************************************************
	称号：迷之仙人
	武将：左慈
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：化身
	描述：游戏开始前，你获得两张未加入游戏的武将牌，称为“化身牌”，然后选择一张“化身牌”的一项技能（除主公技、限定技与觉醒技）。回合开始时和回合结束后，你可以更换“化身牌”，然后你可以为当前“化身牌”重新选择一项技能。你拥有你以此法选择的技能且性别与势力改为与“化身牌”相同。
]]--
HuaShen = sgs.CreateLuaSkill{
	name = "HuaShen",
	translation = "化身",
	description = "游戏开始前，你获得两张未加入游戏的武将牌，称为“化身牌”，然后选择一张“化身牌”的一项技能（除主公技、限定技与觉醒技）。回合开始时和回合结束后，你可以更换“化身牌”，然后你可以为当前“化身牌”重新选择一项技能。你拥有你以此法选择的技能且性别与势力改为与“化身牌”相同。",
	audio = {
		"藏形变身，自在吾心。（男声）",
		"遁形幻千，随意所欲。（男声）",
		"藏形变身，自在吾心。（女声）",
		"遁形幻千，随意所欲。（女声）",
	},
}
--[[
	技能：新生
	描述：每当你受到1点伤害后，你可以获得一张“化身牌”。
]]--
XinSheng = sgs.CreateLuaSkill{
	name = "XinSheng",
	translation = "新生",
	description = "每当你受到1点伤害后，你可以获得一张“化身牌”。",
	audio = {
		"吐故纳新，师法天地。（男声）",
		"灵根不灭，连绵不绝。（男声）",
		"吐故纳新，师法天地。（女声）",
		"灵根不灭，连绵不绝。（女声）",
	},
}
--武将信息：左慈
ZuoCi = sgs.CreateLuaGeneral{
	name = "zuoci",
	translation = "左慈",
	title = "迷之仙人",
	kingdom = "qun",
	maxhp = 3,
	order = 8,
	cv = "东方胤弘，眠眠",
	illustrator = "废柴男",
	skills = {HuaShen, XinSheng},
	last_word = "释知遗形，神灭形消……",
	resource = "zuoci",
	marks = {"@huashen"},
}
--[[****************************************************************
	称号：异乡的孤女
	武将：蔡文姬
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：悲歌
	描述：每当一名角色受到一次【杀】的伤害后，你可以弃置一张牌令该角色进行判定：若结果为♥，该角色回复1点体力；♦，该角色摸两张牌；♠，伤害来源将其武将牌翻面；♣，伤害来源弃置两张牌。
]]--
BeiGe = sgs.CreateLuaSkill{
	name = "BeiGe",
	translation = "悲歌",
	description = "每当一名角色受到一次【杀】的伤害后，你可以弃置一张牌令该角色进行判定：若结果为红心，该角色回复1点体力；方块，该角色摸两张牌；黑桃，伤害来源将其武将牌翻面；草花，伤害来源弃置两张牌。",
	audio = {
		"欲死不能得，欲生无一可。",
		"此行远兮，君尚珍重。",
		"翩翩吹我衣，肃肃入我耳。",
		"岂偕老之可期，庶尽欢于余年。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:isKindOf("Slash") then
			local target = damage.to
			if target and target:objectName() == player:objectName() then
				local room = player:getRoom()
				local alives = room:getAlivePlayers()
				for _,source in sgs.qlist(alives) do
					if source:hasSkill("BeiGe") and source:canDiscard(source, "he") then
						if room:askForCard(source, "..", "@BeiGe", data, "BeiGe") then
							local judge = sgs.JudgeStruct()
							judge.who = target
							judge.reason = "BeiGe"
							judge.pattern = "."
							judge.good = true
							judge.play_animation = false
							room:judge(judge)
							local suit = judge.card:getSuit()
							if suit == sgs.Card_Spade then
								room:broadcastSkillInvoke("BeiGe", 2)
								local from = damage.from
								if from and from:isAlive() then
									from:turnOver()
								end
							elseif suit == sgs.Card_Heart then
								room:broadcastSkillInvoke("BeiGe", 4)
								local recover = sgs.RecoverStruct()
								recover.who = source
								recover.recover = 1
								room:recover(target, recover)
							elseif suit == sgs.Card_Club then
								room:broadcastSkillInvoke("BeiGe", 1)
								local from = damage.from
								if from and from:isAlive() then
									room:askForDiscard(from, "BeiGe", 2, 2, false, true)
								end
							elseif suit == sgs.Card_Diamond then
								room:broadcastSkillInvoke("BeiGe", 3)
								room:drawCards(target, 2, "BeiGe")
							end
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
	translations = {
		["@BeiGe"] = "你可以弃置一张牌发动“悲歌”",
	},
}
--[[
	技能：断肠（锁定技）
	描述：杀死你的角色失去所有武将技能。
]]--
DuanChang = sgs.CreateLuaSkill{
	name = "DuanChang",
	translation = "断肠",
	description = "<font color=\"blue\"><b>锁定技</b></font>，杀死你的角色失去所有武将技能。",
	audio = {
		"雁飞高兮邈难寻，空断肠兮思喑喑。",
		"胡人落泪沾边草，汉使断肠对归客。",
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
				if killer and killer:isAlive() then
					local room = player:getRoom()
					room:broadcastSkillInvoke("DuanChang")
					room:notifySkillInvoked(victim, "DuanChang")
					local msg = sgs.LogMessage()
					msg.type = "#DuanchangLoseSkills"
					msg.from = victim
					msg.to:append(killer)
					msg.arg = "DuanChang"
					room:sendLog(msg)
					local skills = killer:getVisibleSkillList()
					local command = {}
					for _,skill in sgs.qlist(skills) do
						if not skill:isAttachedLordSkill() then
							table.insert(command, "-"..skill:objectName())
						end
					end
					command = table.concat(command, "|")
					room:handleAcquireDetachSkills(killer, command)
					if killer:isAlive() then
						killer:gainMark("@duanchang")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("DuanChang")
	end,
	translations = {
		["#DuanchangLoseSkills"] = "%from 的“%arg”被触发， %to 失去所有武将技能",
		["@duanchang"] = "断肠",
	},
}
--武将信息：蔡文姬
CaiWenJi = sgs.CreateLuaGeneral{
	name = "caiwenji",
	real_name = "caiyan",
	translation = "蔡文姬",
	title = "异乡的孤女",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 5,
	cv = "呼呼",
	illustrator = "Sonia Tang",
	skills = {BeiGe, DuanChang},
	resource = "caiyan",
	marks = {"@duanchang"},
}
--[[****************************************************************
	山武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "mountain",
	translation = "山包",
	generals = {
		ZhangHe, DengAi, JiangWei, LiuShan, SunCe, ZhangZhaoZhangHong, ZuoCi, CaiWenJi,
	},
}