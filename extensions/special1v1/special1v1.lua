--[[
	太阳神三国杀武将单挑对战平台·1v1专属武将包
	武将总数：20
	武将一览：
		1、张辽（突袭）
		2、许褚（裸衣、挟缠）
		3、甄姬（倾国、洛神）
		4、夏侯渊（神速、肃资）
		5、刘备（仁望、激将）
		6、关羽（武圣、虎威）
		7、黄月英（集智、藏机）
		8、黄忠（烈弓）
		9、魏延（狂骨）
		10、姜维（挑衅）
		11、孟获（蛮裔、再起）
		12、祝融（蛮裔、烈刃）
		13、吕蒙（慎拒、博图）
		14、大乔（国色、婉容）
		15、孙尚香（姻礼、枭姬）
		16、华佗（急救、普济）
		17、貂蝉（翩仪、闭月）
		18、何进（谋诛、延祸）
		19、牛金（挫锐、裂围）
		20、韩遂（马术、逆乱）
]]--
--[[****************************************************************
	称号：前将军
	武将：张辽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：突袭
	描述：摸牌阶段，若你的手牌少于对手，你可以少摸一张牌并获得对手的一张手牌。
]]--
TuXi = sgs.CreateLuaSkill{
	name = "kofTuXi",
	translation = "突袭",
	description = "摸牌阶段，若你的手牌少于对手，你可以少摸一张牌并获得对手的一张手牌。",
	audio = "没想到吧？",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local target = player:getNext()
		if player:getHandcardNum() < target:getHandcardNum() then
			if player:askForSkillInvoke("kofTuXi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("kofTuXi")
				local n = data:toInt() - 1
				n = math.max( 0, n )
				data:setValue(n)
				local id = room:askForCardChosen(player, target, "h", "kofTuXi")
				if id >= 0 then
					room:obtainCard(player, id)
				end
			end
		end
		return false
	end,
}
--武将信息：张辽
ZhangLiao = sgs.CreateLuaGeneral{
	name = "kof_zhangliao",
	real_name = "zhangliao",
	translation = "张辽1v1",
	show_name = "张辽",
	title = "前将军",
	kingdom = "wei",
	order = 4,
	skills = TuXi,
	resource = "zhangliao",
}
--[[****************************************************************
	称号：虎痴
	武将：许褚
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：裸衣
	描述：摸牌阶段，你可以少摸一张牌：若如此做，本回合你使用【杀】或【决斗】对目标角色造成伤害时，此伤害+1。
]]--
--[[
	技能：挟缠（限定技）
	描述：出牌阶段，你可以与对手拼点：若你赢，视为你对对手使用一张【决斗】；若你没赢，视为对手对你使用一张【决斗】。
]]--
XieChanCard = sgs.CreateSkillCard{
	name = "kofXieChanCard",
	skill_name = "kofXieChan",
	target_fixed = false,
	will_throw = false,
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
	on_use = function(self, room, source, targets)
		room:doSuperLightbox("kof_xuchu", "kofXieChan")
		source:loseMark("@twine")
		for _,target in ipairs(targets) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local needcard = ( self:subcardsLength() == 0 )
		local source = effect.from
		if needcard and source:isKongcheng() then
			return 
		end
		local target = effect.to
		if target:isKongcheng() then
			return 
		end
		local room = source:getRoom()
		local success = nil
		if needcard then
			success = source:pindian(target, "kofXieChan")
		else
			success = source:pindian(target, "kofXieChan", self)
		end
		local duel = sgs.Sanguosha:cloneCard("duel")
		duel:setSkillName("kofXieChan")
		local use = sgs.CardUseStruct()
		use.card = duel
		if success then
			use.from = source
			use.to:append(target)
		else
			use.from = target
			use.to:append(source)
		end
		room:useCard(use)
	end,
}
XieChanVS = sgs.CreateLuaSkill{
	name = "kofXieChan",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local card = XieChanCard:clone()
		if #cards == 1 then
			card:addSubcard(cards[1])
		end
		return card
	end,
	enabled_at_play = function(self, player)
		if player:getMark("@twine") == 0 then
			return false
		elseif player:isKongcheng() then
			return false
		end
		return true
	end,
}
XieChan = sgs.CreateLuaSkill{
	name = "kofXieChan",
	translation = "挟缠",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以与对手拼点：若你赢，视为你对对手使用一张【决斗】；若你没赢，视为对手对你使用一张【决斗】。",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	limit_mark = "@twine",
	view_as_skill = XieChanVS,
	translations = {
		["@twine"] = "挟缠",
	},
}
--武将信息：许褚
XuChu = sgs.CreateLuaGeneral{
	name = "kof_xuchu",
	real_name = "xuchu",
	translation = "许褚1v1",
	show_name = "许褚",
	title = "虎痴",
	kingdom = "wei",
	order = 4,
	skills = {"LuoYi", XieChan},
	resource = "xuchu",
	marks = {"@twine"},
}
--[[****************************************************************
	称号：薄幸的美人
	武将：甄姬
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：倾国
	描述：你可以将一张装备区的牌当【闪】使用或打出。
]]--
QingGuo = sgs.CreateLuaSkill{
	name = "kofQingGuo",
	translation = "倾国",
	description = "你可以将一张装备区的牌当【闪】使用或打出。",
	audio = {
		"凌波微步，罗袜生尘。",
		"体迅飞凫，飘忽若神。",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local jink = sgs.Sanguosha:cloneCard("jink", suit, point)
			jink:addSubcard(card)
			jink:setSkillName("kofQingGuo")
			return jink
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "jink"
	end,
}
--[[
	技能：洛神
	描述：准备阶段开始时，你可以进行判定：若结果为黑色，判定牌生效后你获得之，然后你可以再次发动“洛神”。
]]--
--武将信息：甄姬
ZhenJi = sgs.CreateLuaGeneral{
	name = "kof_zhenji",
	real_name = "zhenji",
	translation = "甄姬1v1",
	show_name = "甄姬",
	title = "薄幸的美人",
	kingdom = "wei",
	order = 6,
	skills = {QingGuo, "luoshen"},
	resource = "zhenji",
}
--[[****************************************************************
	称号：疾行的猎豹
	武将：夏侯渊
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：神速
	描述：你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。
]]--
--[[
	技能：肃资
	描述：已死亡的对手的牌因弃置而置入弃牌堆前，你可以获得之。
]]--
SuZi = sgs.CreateLuaSkill{
	name = "kofSuZi",
	translation = "肃资",
	description = "已死亡的对手的牌因弃置而置入弃牌堆前，你可以获得之。",
	class = "TriggerSkill",
	events = {sgs.BuryVictim},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("kofSuZi") then
					if source:askForSkillInvoke("kofSuZi", data) then
						room:broadcastSkillInvoke("kofSuZi")
						room:notifySkillInvoked(source, "kofSuZi")
						local handcard_ids = player:handCards()
						local dummy = sgs.DummyCard(handcard_ids)
						if player:hasEquip() then
							local equips = player:getEquips()
							for _,equip in sgs.qlist(equips) do
								dummy:addSubcard(equip)
							end
						end
						if dummy:subcardsLength() > 0 then
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, source:objectName())
							room:obtainCard(source, dummy, reason, false)
						end
						dummy:deleteLater()
						return false
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and not target:isNude()
	end,
}
--武将信息：夏侯渊
XiaHouYuan = sgs.CreateLuaGeneral{
	name = "kof_xiahouyuan",
	real_name = "xiahouyuan",
	translation = "夏侯渊1v1",
	show_name = "夏侯渊",
	title = "疾行的猎豹",
	kingdom = "wei",
	order = 4,
	skills = {"ShenSu", SuZi},
	resource = "xiahouyuan",
}
--[[****************************************************************
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：仁望
	描述：对手于其出牌阶段内对包括你的角色使用第二张及以上【杀】或非延时锦囊牌时，你可以弃置其一张牌。
]]--
RenWang = sgs.CreateLuaSkill{
	name = "kofRenWang",
	translation = "仁望",
	description = "对手于其出牌阶段内对包括你的角色使用第二张及以上【杀】或非延时锦囊牌时，你可以弃置其一张牌。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			if player:getPhase() == sgs.Player_Play then
				local use = data:toCardUse()
				local card = use.card
				if card:isKindOf("Slash") or card:isNDTrick() then
					local first = sgs.SPlayerList()
					for _,to in sgs.qlist(use.to) do
						if to:objectName() == player:objectName() then
						elseif to:hasFlag("RenWangEffect") then
						else
							first:append(to)
							to:setFlags("RenWangEffect")
						end
					end
					local others = room:getOtherPlayers(player)
					for _,source in sgs.qlist(others) do
						if source:isAlive() and source:hasSkill("kofRenWang") then
							if use.to:contains(source) and not first:contains(source) then
								if source:canDiscard(player, "he") and source:hasFlag("RenWangEffect") then
									if source:askForSkillInvoke("kofRenWang", data) then
										local id = room:askForCardChosen(
											source, player, "he", "kofRenWang", false, sgs.Card_MethodDiscard
										)
										if id >= 0 then
											room:throwCard(id, player, source)
										end
									end
								end
							end
						end
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					if p:hasFlag("RenWangEffect") then
						p:setFlags("-RenWangEffect")
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
--[[
	技能：激将（主公技）[空壳技能]
	描述：每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。
]]--
--武将信息：刘备
LiuBei = sgs.CreateLuaGeneral{
	name = "kof_liubei",
	real_name = "liubei",
	translation = "刘备1v1",
	show_name = "刘备",
	title = "乱世的枭雄",
	kingdom = "shu",
	order = 5,
	skills = {RenWang, "JiJiang"},
	resource = "liubei",
}
--[[****************************************************************
	称号：美髯公
	武将：关羽
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：虎威
	描述：你登场时，你可以视为使用一张【水淹七军】。
]]--
HuWei = sgs.CreateLuaSkill{
	name = "kofHuWei",
	translation = "虎威",
	description = "你登场时，你可以视为使用一张【水淹七军】。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local opponent = player:getNext()
		if opponent:isAlive() then
			local trick = sgs.Sanguosha:cloneCard("drowning", sgs.Card_NoSuit, 0)
			trick:setSkillName("_kofHuWei")
			if player:isProhibited(opponent, drowning) then
			elseif trick:isAvailable(player) then
				if player:askForSkillInvoke("kofHuWei", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("kofHuWei")
					local use = sgs.CardUseStruct()
					use.from = player
					use.to:append(opponent)
					use.card = trick
					room:useCard(use)
					return false
				end
			end
			trick:deleteLater()
		end
		return false
	end,
}
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "kof_guanyu",
	real_name = "guanyu",
	translation = "关羽1v1",
	show_name = "关羽",
	title = "美髯公",
	kingdom = "shu",
	order = 5,
	skills = {"WuSheng", HuWei},
	resource = "guanyu",
}
--[[****************************************************************
	称号：归隐的杰女
	武将：黄月英
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：集智
	描述：每当你使用一张非延时锦囊牌时，你可以摸一张牌。
]]--
--[[
	技能：藏机
	描述：你死亡时，你可以将装备区的所有牌移出游戏：若如此做，你的下个武将登场时，将这些牌置于装备区。
]]--
CangJiInstall = sgs.CreateLuaSkill{
	name = "#kofCangJiInstall",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local ids = player:getTag("kofCangJi"):toIntList()
		player:removeTag("kofCangJi")
		local card_ids = sgs.QList2Table(ids)
		local msg = sgs.LogMessage()
		msg.type = "$Install"
		msg.card_str = table.concat(card_ids, "+")
		room:sendLog(msg)
		local move = sgs.CardsMoveStruct(ids, player, sgs.Player_PlaceEquip, sgs.CardMoveReason())
		room:moveCardsAtomic(move, true)
		return false
	end,
	can_trigger = function(self, target)
		if target then
			local ids = target:getTag("kofCangJi"):toIntList()
			return not ids:isEmpty()
		end
		return false
	end,
	priority = 5,
}
CangJi = sgs.CreateLuaSkill{
	name = "kofCangJi",
	translation = "藏机",
	description = "你死亡时，你可以将装备区的所有牌移出游戏：若如此做，你的下个武将登场时，将这些牌置于装备区。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			if player:askForSkillInvoke("kofCangJi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("kofCangJi")
				local card_ids = sgs.IntList()
				local equips = player:getEquips()
				for _,equip in sgs.qlist(equips) do
					local id = equip:getEffectiveId()
					card_ids:append(id)
				end
				local tag = sgs.QVariant()
				tag:setValue(card_ids)
				player:setTag("kofCangJi", tag)
				local move = sgs.CardsMoveStruct()
				move.card_ids = card_ids
				move.from = player
				move.to = nil
				move.to_place = sgs.Player_PlaceTable
				room:moveCardsAtomic(move, true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("kofCangJi") and target:hasEquip()
	end,
	related_skills = CangJiInstall,
}
--武将信息：黄月英
HuangYueYing = sgs.CreateLuaGeneral{
	name = "kof_huangyueying",
	real_name = "huangyueying",
	translation = "黄月英1v1",
	show_name = "黄月英",
	title = "归隐的杰女",
	kingdom = "shu",
	female = true,
	maxhp = 3,
	order = 5,
	skills = {"JiZhi", CangJi},
	resource = "huangyueying",
}
--[[****************************************************************
	称号：老当益壮
	武将：黄忠
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：烈弓
	描述：每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，你可以令该角色不能使用【闪】响应此【杀】。
]]--
LieGong = sgs.CreateLuaSkill{
	name = "kofLieGong",
	translation = "烈弓",
	description = "每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，你可以令该角色不能使用【闪】响应此【杀】。",
	audio = {
		"百步穿杨！",
		"中！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecified},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") then
				local key = "Jink_"..slash:toString()
				local jinkList = player:getTag(key):toIntList()
				local newJinkList = sgs.IntList()
				local hp = player:getHp()
				local room = player:getRoom()
				for index, target in sgs.qlist(use.to) do
					local jink = jinkList:at(index)
					if target:getHandcardNum() >= hp then
						local ai_data = sgs.QVariant()
						ai_data:setValue(target)
						if player:askForSkillInvoke("kofLieGong", ai_data) then
							room:broadcastSkillInvoke("kofLieGong")
							local msg = sgs.LogMessage()
							msg.type = "#NoJink"
							msg.from = target
							room:sendLog(msg)
							jink = 0
						end
					end
					newJinkList:append(jink)
				end
				local tag = sgs.QVariant()
				tag:setValue(newJinkList)
				player:setTag(key, tag)
			end
		end
		return false
	end,
}
--武将信息：黄忠
HuangZhong = sgs.CreateLuaGeneral{
	name = "kof_huangzhong",
	real_name = "huangzhong",
	translation = "黄忠1v1",
	show_name = "黄忠",
	title = "老当益壮",
	kingdom = "shu",
	order = 5,
	skills = LieGong,
	resource = "huangzhong",
}
--[[****************************************************************
	称号：嗜血的独狼
	武将：魏延
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：狂骨
	描述：每当你造成伤害后，你可以进行判定：若结果为黑色，你回复1点体力。
]]--
KuangGu = sgs.CreateLuaSkill{
	name = "kofKuangGu",
	translation = "狂骨",
	description = "每当你造成伤害后，你可以进行判定：若结果为黑色，你回复1点体力。",
	audio = "哈哈！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("kofKuangGu", data) then
			local room = player:getRoom()
			local judge = sgs.JudgeStruct()
			judge.who = player
			judge.reason = "kofKuangGu"
			judge.pattern = ".|black"
			judge.good = true
			room:judge(judge)
			if judge:isGood() then
				room:broadcastSkillInvoke("kofKuangGu")
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(player, recover)
			end
		end
		return false
	end,
}
--武将信息：魏延
WeiYan = sgs.CreateLuaGeneral{
	name = "kof_weiyan",
	real_name = "weiyan",
	translation = "魏延1v1",
	show_name = "魏延",
	title = "嗜血的独狼",
	kingdom = "shu",
	order = 5,
	skills = KuangGu,
	resource = "weiyan",
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
--武将信息：姜维
JiangWei = sgs.CreateLuaGeneral{
	name = "kof_jiangwei",
	real_name = "jiangwei",
	translation = "姜维1v1",
	show_name = "姜维",
	title = "龙的衣钵",
	kingdom = "shu",
	order = 7,
	skills = "TiaoXin",
	resource = "jiangwei",
}
--[[****************************************************************
	称号：南蛮王
	武将：孟获
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：蛮裔
	描述：你登场时，你可以视为使用一张【南蛮入侵】。【南蛮入侵】对你无效。
]]--
ManYiAvoid = sgs.CreateLuaSkill{
	name = "#kofManYiAvoid",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if effect.card:isKindOf("SavageAssault") then
			local room = player:getRoom()
			if player:isMale() then
				room:broadcastSkillInvoke("kofManYi", 1)
			else
				room:broadcastSkillInvoke("kofManYi", 2)
			end
			local msg = sgs.LogMessage()
			msg.type = "#SkillNullify"
			msg.from = player
			msg.arg = "kofManYi"
			msg.arg2 = "savage_assault"
			room:sendLog(msg)
			return true
		end
		return false
	end,
}
ManYi = sgs.CreateLuaSkill{
	name = "kofManYi",
	translation = "蛮裔",
	description = "你登场时，你可以视为使用一张【南蛮入侵】。【南蛮入侵】对你无效。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local opponent = player:getNext()
		if opponent:isAlive() then
			local trick = sgs.Sanguosha:cloneCard("savage_assault", sgs.Card_NoSuit, 0)
			trick:setSkillName("_kofManYi")
			if trick:isAvailable(player) then
				if player:askForSkillInvoke("kofManYi", data) then
					local use = sgs.CardUseStruct()
					use.from = player
					use.to:append(opponent)
					use.card = trick
					room:useCard(use)
					return false
				end
			end
			trick:deleteLater()
		end
		return false
	end,
	related_skills = ManYiAvoid,
}
--[[
	技能：再起
	描述：摸牌阶段开始时，若你已受伤，你可以放弃摸牌并亮出牌堆顶的X张牌：每有一张♥牌，你回复1点体力，然后将所有♥牌置入弃牌堆并获得其余的牌。（X为你已损失的体力值）
]]--
--武将信息：孟获
MengHuo = sgs.CreateLuaGeneral{
	name = "kof_menghuo",
	real_name = "menghuo",
	translation = "孟获1v1",
	show_name = "孟获",
	title = "南蛮王",
	kingdom = "shu",
	order = 7,
	skills = {ManYi, "ZaiQi"},
	resource = "menghuo",
}
--[[****************************************************************
	称号：野性的女王
	武将：祝融
	势力：蜀
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：蛮裔
	描述：你登场时，你可以视为使用一张【南蛮入侵】。【南蛮入侵】对你无效。
]]--
--[[
	技能：烈刃
	描述：每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。
]]--
--武将信息：祝融
ZhuRong = sgs.CreateLuaGeneral{
	name = "kof_zhurong",
	real_name = "zhurong",
	translation = "祝融1v1",
	show_name = "祝融",
	title = "野性的女王",
	kingdom = "shu",
	female = true,
	order = 4,
	skills = "kofManYi+LieRen",
	resource = "zhurong",
}
--[[****************************************************************
	称号：士别三日
	武将：吕蒙
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：慎拒（锁定技）
	描述：你的手牌上限+X。（X为对手的体力值且至少为0）
]]--
ShenJu = sgs.CreateLuaSkill{
	name = "kofShenJu",
	translation = "慎拒",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的手牌上限+X。（X为对手的体力值且至少为0）",
	class = "MaxCardsSkill",
	extra_func = function(self, player)
		if player:hasSkill("kofShenJu") then
			local opponent = player:getSiblings():first()
			local hp = opponent:getHp()
			return math.max( 0, hp )
		end
		return 0
	end,
}
--[[
	技能：博图
	描述：你的回合结束后，若你于本回合出牌阶段使用了四种花色的牌，你可以进行一个额外的回合。
]]--
BoTuCount = sgs.CreateLuaSkill{
	name = "#kofBoTuCount",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.TurnStart},
	global = true,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart then
			room:setPlayerMark(player, "kofBoTu", 0)
		elseif player:getPhase() == sgs.Player_Play then
			local card = nil
			if event == sgs.PreCardUsed then
				local use = data:toCardUse()
				card = use.card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				card = response.m_card
			end
			if card then
				local suit = card:getSuit()
				if tonumber(suit) <= 3 then
					local mark = player:getMark("kofBoTu")
					local extra = bit32.lshift(1, tonumber(suit))
					mark = bit32.bor(mark, extra)
					room:setPlayerMark(player, "kofBoTu", mark)
				end
			end
		end
		return false
	end,
}
BoTu = sgs.CreateLuaSkill{
	name = "kofBoTu",
	translation = "博图",
	description = "你的回合结束后，若你于本回合出牌阶段使用了四种花色的牌，你可以进行一个额外的回合。",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			if player:getMark("kofBoTu") == 0xF then
				if player:askForSkillInvoke("kofBoTu", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("kofBoTu")
					player:gainAnExtraTurn()
				end
			end
		end
		return false
	end,
	priority = 1,
	related_skills = BoTuCount,
}
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "kof_lvmeng",
	real_name = "lvmeng",
	translation = "吕蒙1v1",
	show_name = "吕蒙",
	title = "士别三日",
	kingdom = "wu",
	order = 6,
	skills = {ShenJu, BoTu},
	resource = "lvmeng",
}
--[[****************************************************************
	称号：矜持之花
	武将：大乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：国色
	描述：你可以将一张♦牌当【乐不思蜀】使用。
]]--
--[[
	技能：婉容
	描述：每当你成为【杀】的目标后，你可以摸一张牌。
]]--
WanRong = sgs.CreateLuaSkill{
	name = "kofWanRong",
	translation = "婉容",
	description = "每当你成为【杀】的目标后，你可以摸一张牌。",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			if use.to:contains(player) then
				if player:askForSkillInvoke("kofWanRong", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("kofWanRong")
					room:drawCards(player, 1, "kofWanRong")
				end
			end
		end
		return false
	end,
}
--武将信息：大乔
DaQiao = sgs.CreateLuaGeneral{
	name = "kof_daqiao",
	real_name = "daqiao",
	translation = "大乔1v1",
	show_name = "大乔",
	title = "矜持之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 4,
	skills = {"GuoSe", WanRong},
	resource = "daqiao",
}
--[[****************************************************************
	称号：弓腰姬
	武将：孙尚香
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：姻礼
	描述：对手的回合内，其装备牌置入弃牌堆时，你可以获得之。
]]--
YinLi = sgs.CreateLuaSkill{
	name = "kofYinLi",
	translation = "姻礼",
	description = "对手的回合内，其装备牌置入弃牌堆时，你可以获得之。",
	audio = {},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local from = move.from
		if from and from:objectName() == player:objectName() then
			if player:getPhase() == sgs.Player_NotActive then
				return false
			elseif move.to_place == sgs.Player_DiscardPile then
				local card_ids = sgs.IntList()
				local room = player:getRoom()
				for _,id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:isKindOf("EquipCard") then
						local owner = room:getCardOwner(id)
						if owner and owner:objectName() == player:objectName() then
							local place = room:getCardPlace(id)
							if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
								card_ids:append(id)
							end
						end
					end
				end
				if card_ids:isEmpty() then
					return false
				end
				local others = room:getOtherPlayers(player)
				for _,source in sgs.qlist(others) do
					if source:isAlive() and source:hasSkill("kofYinLi") then
						if source:askForSkillInvoke("kofYinLi", data) then
							while not card_ids:isEmpty() do
								room:fillAG(card_ids, source)
								local id = room:askForAG(source, card_ids, true, "kofYinLi")
								room:clearAG(source)
								if id == -1 then
									break
								end
								card_ids:removeOne(id)
							end
							if not card_ids:isEmpty() then
								room:broadcastSkillInvoke("kofYinLi")
								move:removeCardIds(card_ids)
								local dummy = sgs.DummyCard(card_ids)
								room:moveCardTo(dummy, source, sgs.Player_PlaceHand, move.reason, true)
								dummy:deleteLater()
								if move.card_ids:isEmpty() then
									return false
								end
							end
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
}
--[[
	技能：枭姬
	描述：每当你失去一张装备区的牌后，你可以选择一项：摸两张牌，或回复1点体力。
]]--
XiaoJi = sgs.CreateLuaSkill{
	name = "kofXiaoJi",
	translation = "枭姬",
	description = "每当你失去一张装备区的牌后，你可以选择一项：摸两张牌，或回复1点体力。",
	audio = {},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local source = move.from
		if source and source:objectName() == player:objectName() then
			local room = player:getRoom()
			for _,place in sgs.qlist(move.from_places) do
				if player:isDead() then
					return false
				elseif place == sgs.Player_PlaceEquip then
					local choices = {}
					table.insert(choices, "draw")
					if player:isWounded() then
						table.insert(choices, "recover")
					end
					table.insert(choices, "cancel")
					choices = table.concat(choices, "+")
					local choice = room:askForChoice(player, "kofXiaoJi", choices, data)
					if choice == "cancel" then
						return false
					end
					room:broadcastSkillInvoke("kofXiaoJi")
					room:notifySkillInvoked(player, "kofXiaoJi")
					local msg = sgs.LogMessage()
					msg.type = "#InvokeSkill"
					msg.from = player
					msg.arg = "kofXiaoJi"
					room:sendLog(msg)
					if choice == "draw" then
						room:drawCards(player, 2, "kofXiaoJi")
					elseif choice == "recover" then
						local recover = sgs.RecoverStruct()
						recover.who = player
						recover.recover = 1
						room:recover(player, recover)
					end
				end
			end
		end
		return false
	end,
}
--武将信息：孙尚香
SunShangXiang = sgs.CreateLuaGeneral{
	name = "kof_sunshangxiang",
	real_name = "sunshangxiang",
	translation = "孙尚香1v1",
	show_name = "孙尚香",
	title = "弓腰姬",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 7,
	skills = {YinLi, XiaoJi},
	resource = "sunshangxiang",
}
--[[****************************************************************
	称号：神医
	武将：华佗
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：急救
	描述：你的回合外，你可以将一张红色牌当【桃】使用。
]]--
--[[
	技能：普济（阶段技）
	描述：若你与对手均有牌，你可以弃置你与其各一张牌，然后以此法弃置♠牌的角色摸一张牌。
]]--
PuJiCard = sgs.CreateSkillCard{
	name = "kofPuJiCard",
	skill_name = "kofPuJi",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:isNude() then
				return false
			elseif to_select:objectName() == sgs.Self:objectName() then
				return false
			elseif sgs.Self:canDiscard(to_select, "he") then
				return true
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local to_draw = {}
		for _,target in ipairs(targets) do
			if target:isNude() then
			elseif source:canDiscard(target, "he") then
				local id = room:askForCardChosen(source, target, "he", "kofPuJi", false, sgs.Card_MethodDiscard)
				if id >= 0 then
					room:throwCard(id, target, source)
					local spade = sgs.Sanguosha:getCard(id)
					if spade:getSuit() == sgs.Card_Spade then
						table.insert(to_draw, target)
					end
				end
			end
		end
		if self:subcardsLength() > 0 then
			local id = self:getSubcards():first()
			local spade = sgs.Sanguosha:getCard(id)
			if spade:getSuit() == sgs.Card_Spade then
				room:drawCards(source, 1, "kofPuJi")
			end
		end
		for _,target in ipairs(to_draw) do
			room:drawCards(target, 1, "kofPuJi")
		end
	end,
}
PuJi = sgs.CreateLuaSkill{
	name = "kofPuJi",
	translation = "普济",
	description = "<font color=\"green\"><b>阶段技</b></font>，若你与对手均有牌，你可以弃置你与其各一张牌，然后以此法弃置黑桃牌的角色摸一张牌。",
	audio = {},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return sgs.Self:canDiscard(sgs.Self, to_select:getEffectiveId())
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = PuJiCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:isNude() then
			return false
		elseif player:hasUsed("#kofPuJiCard") then
			return false
		end
		return true
	end,
}
--武将信息：华佗
HuaTuo = sgs.CreateLuaGeneral{
	name = "kof_huatuo",
	real_name = "huatuo",
	translation = "华佗1v1",
	show_name = "华佗",
	title = "神医",
	kingdom = "qun",
	maxhp = 3,
	order = 5,
	skills = {"JiJiu", PuJi},
	resource = "huatuo",
}
--[[****************************************************************
	称号：绝世的舞姬
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：翩仪（锁定技）
	描述：你登场时，若处于对手的回合，则结束当前回合并结束一切结算。
]]--
PianYi = sgs.CreateLuaSkill{
	name = "kofPianYi",
	translation = "翩仪",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你登场时，若处于对手的回合，则结束当前回合并结束一切结算。",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local opponent = player:getNext()
		if opponent:getPhase() ~= sgs.Player_NotActive then
			local room = player:getRoom()
			room:broadcastSkillInvoke("kofPianYi")
			room:sendCompulsoryTriggerLog(player, "kofPianYi")
			local msg = sgs.LogMessage()
			msg.type = "#TurnBroken"
			msg.from = opponent
			room:sendLog(msg)
			room:throwEvent(sgs.TurnBroken)
		end
		return false
	end,
}
--[[
	技能：闭月
	描述：结束阶段开始时，你可以摸一张牌。
]]--
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "kof_diaochan",
	real_name = "diaochan",
	translation = "貂蝉1v1",
	show_name = "貂蝉",
	title = "绝世的舞姬",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 7,
	skills = {PianYi, "BiYue"},
	resource = "diaochan",
}
--[[****************************************************************
	称号：色厉内荏
	武将：何进
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：谋诛（阶段技）
	描述：你可以令对手交给你一张手牌：若你的手牌多于对手，对手选择一项：视为对你使用一张无距离限制的【杀】，或视为对你使用一张【决斗】。
]]--
MouZhuCard = sgs.CreateSkillCard{
	name = "kofMouZhuCard",
	skill_name = "kofMouZhu",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() ~= sgs.Self:objectName() then
				return not to_select:isKongcheng()
			end
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
		local card = nil
		if target:getHandcardNum() > 1 then
			local prompt = string.format("@kofMouZhu-give:%s", source:objectName())
			card = room:askForCard(target, ".!", prompt, sgs.QVariant(), sgs.Card_MethodNone)
			card = card or target:getRandomHandCard()
		else
			card = target:getHandcards():first()
		end
		if card and source:isAlive() and target:isAlive() then
			local reason = sgs.CardMoveReason(
				sgs.CardMoveReason_S_REASON_GIVE, 
				target:objectName(), 
				source:objectName(), 
				"kofMouZhu", 
				""
			)
			room:obtainCard(source, card, reason, false)
			if source:isAlive() and target:isAlive() then
				if source:getHandcardNum() > target:getHandcardNum() then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName("_kofMouZhu")
					local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
					duel:setSkillName("_kofMouZhu")
					local choices = {}
					if target:isLocked(slash) then
					elseif target:canSlash(source, slash, false) then
						table.insert(choices, "slash")
					end
					if target:isLocked(duel) then
					elseif target:isProhibited(source, duel) then
					else
						table.insert(choices, "duel")
					end
					if #choices == 0 then
						slash:deleteLater()
						duel:deleteLater()
						return
					end
					choices = table.concat(choices, "+")
					local choice = room:askForChoice(target, "kofMouZhu", choices)
					local use = sgs.CardUseStruct()
					use.from = target
					use.to:append(source)
					if choice == "slash" then
						use.card = slash
						duel:deleteLater()
					else
						use.card = duel
						slash:deleteLater()
					end
					room:useCard(use)
				end
			end
		end
	end,
}
MouZhu = sgs.CreateLuaSkill{
	name = "kofMouZhu",
	translation = "谋诛",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令对手交给你一张手牌：若你的手牌多于对手，对手选择一项：视为对你使用一张无距离限制的【杀】，或视为对你使用一张【决斗】。",
	audio = {},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return MouZhuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#kofMouZhuCard")
	end,
	effect_index = function(self, player, card)
		if card:isKindOf("kofMouZhuCard") then
			return -1
		end
		return -2
	end,
}
--[[
	技能：延祸
	描述：你死亡时，你可以依次弃置对手的X张牌。（X为你死亡时的牌数）
]]--
YanHuo = sgs.CreateLuaSkill{
	name = "kofYanHuo",
	translation = "延祸",
	description = "你死亡时，你可以依次弃置对手的X张牌。（X为你死亡时的牌数）",
	audio = {},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeGameOverJudge, sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			if event == sgs.BeforeGameOverJudge then
				local count = player:getCardCount()
				room:setPlayerMark(player, "kofYanHuoCount", count)
			elseif event == sgs.Death then
				local count = player:getMark("kofYanHuoCount")
				if count == 0 then
					return false
				end
				local alives = room:getAlivePlayers()
				if alives:isEmpty() then
					return false
				end
				local opponent = alives:first()
				if opponent:isNude() or not player:canDiscard(opponent, "he") then
					return false
				elseif player:askForSkillInvoke("kofYanHuo", data) then
					for i=1, count, 1 do
						if opponent:isNude() then
							return false
						elseif opponent:canDiscard(opponent, "he") then
							local id = room:askForCardChosen(player, opponent, "he", "kofYanHuo")
							if id == -1 then
								return false
							end
							local card = sgs.Sanguosha:getCard(id)
							room:throwCard(card, opponent, player)
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("kofYanHuo")
	end,
}
--武将信息：何进
HeJin = sgs.CreateLuaGeneral{
	name = "hejin",
	translation = "何进",
	title = "色厉内荏",
	kingdom = "qun",
	order = 7,
	skills = {MouZhu, YanHuo},
	resource = "hejin",
}
--[[****************************************************************
	称号：独进的兵胆
	武将：牛金
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：挫锐（锁定技）
	描述：你的起始手牌为X+2张。你跳过你的第一个判定阶段。（X为你的备选武将数）
]]--
CuoRui = sgs.CreateLuaSkill{
	name = "kofCuoRui",
	translation = "挫锐",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的起始手牌为X+2张。你跳过你的第一个判定阶段。（X为你的备选武将数）",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawInitialCards, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			local x = 3
			local mode = room:getMode()
			if string.find(mode, "kof") then
				local arrange = player:getTag("1v1Arrange"):toStringList()
				local maxhp = player:getMaxHp()
				local original, extra = 0, 0
				if mode == "03_kof" then
					original, extra = 4, #arrange
				elseif mode == "04_kof_2013" then
					original, extra = maxhp, #arrange + 3
				elseif mode == "05_kof_wzzz" then
					original, extra = maxhp, #arrange
				end
				x = extra + 2 - original
			end
			room:broadcastSkillInvoke("kofCuoRui")
			room:sendCompulsoryTriggerLog(player, "kofCuoRui")
			local n = data:toInt() + x
			data:setValue(n)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Judge then
				if player:getMark("kofCuoRuiSkipJudge") == 0 then
					room:broadcastSkillInvoke("kofCuoRui")
					room:sendCompulsoryTriggerLog(player, "kofCuoRui")
					player:skip(sgs.Player_Judge)
					room:setPlayerMark(player, "kofCuoRuiSkipJudge", 1)
				end
			end
		end
		return false
	end,
}
--[[
	技能：裂围
	描述：对手死亡时，你可以摸三张牌。
]]--
LieWei = sgs.CreateLuaSkill{
	name = "kofLieWei",
	translation = "裂围",
	description = "对手死亡时，你可以摸三张牌。",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("kofLieWei") then
					if source:askForSkillInvoke("kofLieWei", data) then
						room:broadcastSkillInvoke("kofLieWei")
						room:drawCards(source, 3, "kofLieWei")
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
--武将信息：牛金
NiuJin = sgs.CreateLuaGeneral{
	name = "niujin",
	translation = "牛金",
	title = "独进的兵胆",
	kingdom = "wei",
	order = 4,
	skills = {CuoRui, LieWei},
	resource = "niujin",
}
--[[****************************************************************
	称号：蹯踞西疆
	武将：韩遂
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：逆乱
	描述：对手的结束阶段开始时，若其体力值大于你的体力值，或其于出牌阶段内对你使用过【杀】，你可以将一张黑色牌当【杀】对其使用。
]]--
NiLuanRecord = sgs.CreateLuaSkill{
	name = "#kofNiLuanRecord",
	class = "TriggerSkill",
	events = {sgs.TargetSpecified, sgs.EventPhaseStart},
	global = true,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				for _,target in sgs.qlist(use.to) do
					if not target:hasFlag("kofNiLuanSlashTarget") then
						room:setPlayerFlag(target, "kofNiLuanSlashTarget")
					end
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					room:setPlayerFlag(p, "-kofNiLuanSlashTarget")
				end
			end
		end
		return false
	end,
	priority = 4,
}
NiLuanVS = sgs.CreateLuaSkill{
	name = "kofNiLuan",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isBlack()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
			slash:addSubcard(card)
			slash:setSkillName("kofNiLuan")
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@kofNiLuan"
	end,
}
NiLuan = sgs.CreateLuaSkill{
	name = "kofNiLuan",
	translation = "逆乱",
	description = "对手的结束阶段开始时，若其体力值大于你的体力值，或其于出牌阶段内对你使用过【杀】，你可以将一张黑色牌当【杀】对其使用。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = NiLuanVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local source = player:getNextAlive()
			if source and source:hasSkill("kofNiLuan") and source:canSlash(player, false) then
				local can_invoke = false
				if source:hasFlag("kofNiLuanSlashTarget") then
					can_invoke = true
				elseif player:getHp() > source:getHp() then
					can_invoke = true
				end
				if can_invoke then
					if source:isKongcheng() then
						can_invoke = false
						local equips = source:getEquips()
						for _,equip in sgs.qlist(equips) do
							if equip:isBlack() then
								can_invoke = true
								break
							end
						end
					end
				end
				if can_invoke then
					local room = player:getRoom()
					room:setPlayerFlag(source, "slashTargetFix")
					room:setPlayerFlag(source, "slashNoDistanceLimit")
					room:setPlayerFlag(source, "slashTargetFixToOne")
					room:setPlayerFlag(player, "SlashAssignee")
					local prompt = string.format("@kofNiLuan:%s", player:objectName())
					local slash = room:askForUseCard(source, "@@kofNiLuan", prompt)
					if not slash then
						room:setPlayerFlag(source, "-slashTargetFix")
						room:setPlayerFlag(source, "-slashNoDistanceLimit")
						room:setPlayerFlag(source, "-slashTargetFixToOne")
						room:setPlayerFlag(player, "-SlashAssignee")
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
	related_skills = NiLuanRecord,
}
--武将信息：韩遂
HanSui = sgs.CreateLuaGeneral{
	name = "hansui",
	translation = "韩遂",
	title = "蹯踞西疆",
	kingdom = "qun",
	order = 5,
	skills = {"mashu", NiLuan},
	resource = "hansui",
}
--[[****************************************************************
	1v1专属武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "special1v1",
	translation = "1v1专属",
	generals = {
		ZhangLiao, XuChu, ZhenJi, XiaHouYuan,
		LiuBei, GuanYu, HuangYueYing, HuangZhong, WeiYan, JiangWei, MengHuo, ZhuRong,
		LvMeng, DaQiao, SunShangXiang,
		HuaTuo, DiaoChan,
		HeJin, NiuJin, HanSui,
	},
}