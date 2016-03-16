--[[
	太阳神三国杀武将单挑对战平台·林武将包
	武将总数：8
	武将一览：
		1、徐晃（断粮）
		2、曹丕（行殇、放逐、颂威）
		3、孟获（祸首、再起）
		4、祝融（巨象、烈刃）
		5、孙坚（英魂）
		6、鲁肃（好施、缔盟）
		7、董卓（酒池、肉林、崩坏、暴虐）
		8、贾诩（完杀、乱武、帷幕）
]]--
--[[****************************************************************
	称号：周亚夫之风
	武将：徐晃
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：断粮
	描述：你可以将一张黑色的基本牌或黑色的装备牌当【兵粮寸断】使用。你使用【兵粮寸断】的距离限制为2。
]]--
DuanLiangMod = sgs.CreateLuaSkill{
	name = "#DuanLiangMod",
	class = "TargetModSkill",
	distance_limit_func = function(self, player, card)
		if card:isKindOf("SupplyShortage") and player:hasSkill("DuanLiang") then
			return 1
		end
		return 0
	end,
}
DuanLiang = sgs.CreateLuaSkill{
	name = "DuanLiang",
	translation = "断粮",
	description = "你可以将一张黑色的基本牌或黑色的装备牌当【兵粮寸断】使用。你使用【兵粮寸断】的距离限制为2。",
	audio = {
		"断汝粮草，以绝后路！",
		"焚其辎重，乱其军心！",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isBlack() then
			return to_select:isKindOf("BasicCard") or to_select:isKindOf("EquipCard")
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("supply_shortage", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("DuanLiang")
			return trick
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isNude()
	end,
	related_skills = DuanLiangMod,
}
--武将信息：徐晃
XuHuang = sgs.CreateLuaGeneral{
	name = "xuhuang",
	translation = "徐晃",
	title = "周亚夫之风",
	kingdom = "wei",
	order = 7,
	cv = "木津川",
	illustrator = "Tuu.",
	skills = DuanLiang,
	last_word = "生遇明主，死亦无憾！",
	resource = "xuhuang",
}
--[[****************************************************************
	称号：霸业的继承者
	武将：曹丕
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：行殇
	描述：每当一名其他角色死亡时，你可以获得该角色的牌。
]]--
XingShang = sgs.CreateLuaSkill{
	name = "XingShang",
	translation = "行殇",
	description = "每当一名其他角色死亡时，你可以获得该角色的牌。",
	audio = {
		"汝妻子吾自养之，汝勿虑也！",
		"珠沉玉殁，其香犹存！",
		"痛神曜之幽浅，哀鼎俎之虚置……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			for _,source in sgs.qlist(alives) do
				if source:hasSkill("XingShang") then
					if source:askForSkillInvoke("XingShang", data) then
						if victim:isGeneral("caocao", true, true) then
							room:broadcastSkillInvoke("XingShang", 3)
						elseif victim:isMale() then
							room:broadcastSkillInvoke("XingShang", 1)
						else
							room:broadcastSkillInvoke("XingShang", 2)
						end
						local dummy = sgs.DummySkill(victim:handCards())
						local equips = victim:getEquips()
						for _,equip in sgs.qlist(equips) do
							dummy:addSubcard(equip)
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
		return target
	end,
}
--[[
	技能：放逐
	描述：每当你受到伤害后，你可以令一名其他角色摸X张牌，然后将其武将牌翻面。（X为你已损失的体力值）
]]--
FangZhu = sgs.CreateLuaSkill{
	name = "FangZhu",
	translation = "放逐",
	description = "每当你受到伤害后，你可以令一名其他角色摸X张牌，然后将其武将牌翻面。（X为你已损失的体力值）",
	audio = {
		"罪不至死，赦死从流！",
		"特赦天下，奉旨回京！",
		"本自同根生，相煎何太急？……",
	},
	class = "MasochismSkill",
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local others = room:getOtherPlayers(player)
		local target = room:askForPlayerChosen(player, others, "FangZhu", "@FangZhu", true, true)
		if target then
			if target:faceUp() then
				if target:isGeneral("caozhi", true, true) then
					room:broadcastSkillInvoke("FangZhu", 3)
				else
					room:broadcastSkillInvoke("FangZhu", 1)
				end
			else
				room:broadcastSkillInvoke("FangZhu", 2)
			end
			local x = player:getLostHp()
			room:drawCards(target, x, "FangZhu")
			target:turnOver()
		end
	end,
}
--[[
	技能：颂威（主公技）[空壳技能]
	描述：其他魏势力角色的黑色判定牌生效后，该角色可以令你摸一张牌。
]]--
SongWei = sgs.CreateLuaSkill{
	name = "SongWei",
	translation = "颂威",
	description = "<font color=\"yellow\"><b>主公技</b></font>，其他魏势力角色的黑色判定牌生效后，该角色可以令你摸一张牌。",
}
--武将信息：曹丕
CaoPi = sgs.CreateLuaGeneral{
	name = "caopi",
	translation = "曹丕",
	title = "霸业的继承者",
	kingdom = "wei",
	maxhp = 3,
	order = 1,
	cv = "V7，殆尘，烨子，蒲小猫",
	illustrator = "Sonia Tang",
	skills = {XingShang, FangZhu, SongWei},
	last_word = "嗟我白发，生一何早；长吟永叹，怀我圣考……",
	resource = "caopi",
}
--[[****************************************************************
	称号：南蛮王
	武将：孟获
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：祸首（锁定技）
	描述：【南蛮入侵】对你无效。每当一名角色指定【南蛮入侵】的目标后，你成为【南蛮入侵】的伤害来源。
]]--
HuoShouAvoid = sgs.CreateLuaSkill{
	name = "#HuoShouAvoid",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		local trick = effect.card
		if trick and trick:isKindOf("SavageAssault") then
			local room = player:getRoom()
			room:broadcastSkillInvoke("HuoShou")
			local msg = sgs.LogMessage()
			msg.type = "#SkillNullify"
			msg.from = player
			msg.arg = "HuoShou"
			msg.arg2 = "savage_assault"
			room:sendLog(msg)
			return true
		end
		return false
	end,
}
HuoShou = sgs.CreateLuaSkill{
	name = "HuoShou",
	translation = "祸首",
	description = "<font color=\"blue\"><b>锁定技</b></font>，【南蛮入侵】对你无效。每当一名角色指定【南蛮入侵】的目标后，你成为【南蛮入侵】的伤害来源。",
	audio = "南蛮之地，皆我子民！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetSpecified, sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.from and use.card:isKindOf("SavageAssault") then
				local source = room:findPlayerBySkillName("HuoShou")
				if source and source:objectName() ~= use.from:objectName() then
					room:broadcastSkillInvoke("HuoShou")
					room:sendCompulsoryTriggerLog(source, "HuoShou")
					use.card:setFlags("HuoShouDamage_"..source:objectName())
				end
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			local trick = damage.card
			if trick and trick:isKindOf("SavageAssault") then
				local allplayers = room:getAllPlayers()
				local source = nil
				for _,p in sgs.qlist(allplayers) do
					if trick:hasFlag("HuoShouDamage_"..p:objectName()) then
						source = p
						break
					end
				end
				if source then
					if source:isAlive() then
						damage.from = source
					else
						damage.from = nil
					end
					data:setValue(damage)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	related_skills = HuoShouAvoid,
}
--[[
	技能：再起
	描述：摸牌阶段开始时，若你已受伤，你可以放弃摸牌并亮出牌堆顶的X张牌：每有一张红桃牌，你回复1点体力，然后将所有红桃牌置入弃牌堆并获得其余的牌。（X为你已损失的体力值）
]]--
ZaiQi = sgs.CreateLuaSkill{
	name = "ZaiQi",
	translation = "再起",
	description = "摸牌阶段开始时，若你已受伤，你可以放弃摸牌并亮出牌堆顶的X张牌：每有一张红桃牌，你回复1点体力，然后将所有红桃牌置入弃牌堆并获得其余的牌。（X为你已损失的体力值）",
	audio = {
		"吾不服也！",
		"孔明！汝技穷也！",
		"敌军势大，吾先退避……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			if player:isWounded() then
				if player:askForSkillInvoke("ZaiQi", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("ZaiQi", 1)
					local has_heart = false
					local x = player:getLostHp()
					if x == 0 then
						return false
					end
					local ids = room:getNCards(x, false)
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "ZaiQi", "")
					local move = sgs.CardsMoveStruct(ids, player, sgs.Player_PlaceTable, reason)
					room:moveCardsAtomic(move, true)
					room:getThread():delay()
					room:getThread():delay()
					local card_to_throw = sgs.IntList()
					local card_to_gotback = sgs.IntList()
					for index, id in sgs.qlist(ids) do
						local card = sgs.Sanguosha:getCard(id)
						if card:getSuit() == sgs.Card_Heart then
							card_to_throw:append(id)
						else
							card_to_gotback:append(id)
						end
					end
					if not card_to_throw:isEmpty() then
						local recover = sgs.RecoverStruct()
						recover.who = player
						recover.recover = card_to_throw:length()
						room:recover(player, recover)
						local dummy = sgs.DummyCard(card_to_throw)
						reason = sgs.CardMoveReason(
							sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), "ZaiQi", ""
						)
						room:throwCard(dummy, reason, nil)
						dummy:deleteLater()
						has_heart = true
					end
					if not card_to_gotback:isEmpty() then
						local dummy = sgs.DummyCard(card_to_gotback)
						room:obtainCard(player, dummy)
						dummy:deleteLater()
					end
					if has_heart then
						room:broadcastSkillInvoke("ZaiQi", 2)
					else
						room:broadcastSkillInvoke("ZaiQi", 3)
					end
					return true
				end
			end
		end
		return false
	end,
}
--武将信息：孟获
MengHuo = sgs.CreateLuaGeneral{
	name = "menghuo",
	translation = "孟获",
	title = "南蛮王",
	kingdom = "shu",
	order = 7,
	cv = "墨染の飞猫",
	illustrator = "废柴男",
	skills = {HuoShou, ZaiQi},
	last_word = "荆民之地，再无主矣！",
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
	技能：巨象（锁定技）
	描述：【南蛮入侵】对你无效。其他角色使用的未转化的【南蛮入侵】在结算完毕后置入弃牌堆时，你获得之。
]]--
JuXiangAvoid = sgs.CreateLuaSkill{
	name = "#JuXiangAvoid",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		local trick = effect.card
		if trick and trick:isKindOf("SavageAssault") then
			local room = player:getRoom()
			room:broadcastSkillInvoke("JuXiang")
			local msg = sgs.LogMessage()
			msg.type = "#SkillNullify"
			msg.from = player
			msg.arg = "JuXiang"
			msg.arg2 = "savage_assault"
			room:sendLog(msg)
			return true
		end
		return false
	end,
}
JuXiang = sgs.CreateLuaSkill{
	name = "JuXiang",
	translation = "巨象",
	description = "<font color=\"blue\"><b>锁定技</b></font>，【南蛮入侵】对你无效。其他角色使用的未转化的【南蛮入侵】在结算完毕后置入弃牌堆时，你获得之。",
	audio = "万象奔腾，随吾心意！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.card_ids:length() == 1 and move.to_place == sgs.Player_DiscardPile then
			if move.from_places:contains(sgs.Player_PlaceTable) then
				if move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE then
					local card = move.reason.m_extraData:toCard()
					if card and card:isKindOf("SavageAssault") then
						if card:isVirtualCard() then
							return false
						end
						local source = move.from
						if source and source:objectName() == player:objectName() then
							return false
						end
						room:broadcastSkillInvoke("JuXiang")
						room:sendCompulsoryTriggerLog(player, "JuXiang")
						room:obtainCard(player, card)
						move:removeCardIds(move.card_ids)
						data:setValue(move)
					end
				end
			end
		end
		return false
	end,
	related_skills = JuXiangAvoid,
}
--[[
	技能：烈刃
	描述：每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。
]]--
LieRen = sgs.CreateLuaSkill{
	name = "LieRen",
	translation = "烈刃",
	description = "每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。",
	audio = {
		"火神降世，燃尽汝躯！",
		"呵呵呵呵~~~~",
		"神不佑我，唉……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:isKindOf("Slash") and not player:isKongcheng() then
			local target = damage.to
			if target:isKongcheng() or target:hasFlag("Global_DebutFlag") then
				return false
			elseif damage.transfer or damage.chain then
				return false
			elseif player:askForSkillInvoke("LieRen", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("LieRen", 1)
				local success = player:pindian(target, "LieRen")
				if success then
					room:broadcastSkillInvoke("LieRen", 2)
					if target:isNude() then
						return false
					end
				else
					room:broadcastSkillInvoke("LieRen", 3)
					return false
				end
				local id = room:askForCardChosen(player, target, "he", "LieRen")
				if id >= 0 then
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
					local card = sgs.Sanguosha:getCard(id)
					local place = room:getCardPlace(id)
					room:obtainCard(player, card, reason, place ~= sgs.Player_PlaceHand)
				end
			end
		end
		return false
	end,
}
--武将信息：祝融
ZhuRong = sgs.CreateLuaGeneral{
	name = "zhurong",
	translation = "祝融",
	title = "野性的女王",
	kingdom = "shu",
	female = true,
	order = 4,
	cv = "妙妙",
	illustrator = "废柴男",
	skills = {JuXiang, LieRen},
	last_word = "大王，火神湮世，妾身去矣！",
	resource = "zhurong",
}
--[[****************************************************************
	称号：武烈帝
	武将：孙坚
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：英魂
	描述：准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）
]]--
YingHun = sgs.CreateLuaSkill{
	name = "YingHun",
	translation = "英魂",
	description = "准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：令其摸一张牌，然后弃置X张牌，或令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）",
	audio = {
		"同举义兵，勠力一心！",
		"孙文台在此，此贼可诛！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			if player:isWounded() then
				local room = player:getRoom()
				local others = room:getOtherPlayers(player)
				local target = room:askForPlayerChosen(player, others, "YingHun", "@YingHun", true, true)
				if target then
					local x = player:getLostHp()
					local choice = "draw"
					if x ~= 1 then
						choice = room:askForChoice(player, "YingHun", "discard+draw")
					end
					if choice == "discard" then
						room:broadcastSkillInvoke("YingHun", 2)
						room:drawCards(target, 1, "YingHun")
						room:askForDiscard(target, "YingHun", x, x, false, true)
					elseif choice == "draw" then
						room:broadcastSkillInvoke("YingHun", 1)
						room:drawCards(target, x, "YingHun")
						room:askForDiscard(target, "YingHun", 1, 1, false, true)
					end
				end
			end
		end
		return false
	end,
	translations = {
		["@YingHun"] = "您可以选择一名角色发动技能“英魂”",
		["YingHun:discard"] = "令其摸一张牌，然后弃X张牌",
		["YingHun:draw"] = "令其摸X张牌，然后弃一张牌",
	},
}
--武将信息：孙坚
SunJian = sgs.CreateLuaGeneral{
	name = "sunjian",
	translation = "孙坚",
	title = "武烈帝",
	kingdom = "wu",
	order = 6,
	cv = "木津川",
	illustrator = "LiuHeng",
	skills = YingHun,
	last_word = "死去何愁无勇将，英魂依旧卫江东……",
	resource = "sunjian",
}
--[[****************************************************************
	称号：独断的外交家
	武将：鲁肃
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：好施
	描述：摸牌阶段，你可以额外摸两张牌：若你拥有五张或更多的手牌，你将一半数量（向下取整）的手牌交给除你外场上手牌数最少的一名角色。
]]--
HaoShiCard = sgs.CreateSkillCard{
	name = "HaoShiCard",
	skill_name = "HaoShi",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() ~= sgs.Self:objectName() then
				return to_select:getHandcardNum() == sgs.Self:getMark("HaoShiNum")
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local reason = sgs.CardMoveReason(
			sgs.CardMoveReason_S_REASON_GIVE, 
			source:objectName(), 
			target:objectName(), 
			"HaoShi", 
			""
		)
		room:moveCardTo(self, target, sgs.Player_PlaceHand, reason)
	end,
}
HaoShiVS = sgs.CreateLuaSkill{
	name = "HaoShi",
	class = "ViewAsSkill",
	n = 999,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
			return false
		elseif #selected >= math.floor( sgs.Self:getHandcardNum() / 2 ) then
			return false
		end
		return true
	end,
	view_as = function(self, cards)
		if #cards == math.floor( sgs.Self:getHandcardNum() / 2 ) then
			local card = HaoShiCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@HaoShi!"
	end,
}
HaoShi = sgs.CreateLuaSkill{
	name = "HaoShi",
	translation = "好施",
	description = "摸牌阶段，你可以额外摸两张牌：若你拥有五张或更多的手牌，你将一半数量（向下取整）的手牌交给除你外场上手牌数最少的一名角色。",
	audio = "公瑾莫忧，吾有余粮。",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards, sgs.AfterDrawNCards},
	view_as_skill = HaoShiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawNCards then
			if player:askForSkillInvoke("HaoShi", data) then
				room:broadcastSkillInvoke("HaoShi")
				room:setPlayerFlag(player, "HaoShiInvoked")
				local n = data:toInt() + 2
				data:setValue(n)
			end
		elseif event == sgs.AfterDrawNCards then
			if player:hasFlag("HaoShiInvoked") then
				room:setPlayerFlag(player, "-HaoShiInvoked")
				local mynum = player:getHandcardNum()
				if mynum > 5 then
					local min_num = 999
					local others = room:getOtherPlayers(player)
					for _,p in sgs.qlist(others) do
						local num = p:getHandcardNum()
						if num < min_num then
							min_num = num
						end
					end
					room:setPlayerMark(player, "HaoShiNum", min_num)
					local success = room:askForUseCard(player, "@@HaoShi!", "@HaoShi", -1, sgs.Card_MethodNone)
					if not success then
						local target = nil
						for _,p in sgs.qlist(others) do
							if p:getHandcardNum() == min_num then
								target = p
								break
							end
						end
						if target then
							local n = math.floor( min_num / 2 )
							local handcards = player:handCards()
							local to_give = sgs.IntList()
							for index, id in sgs.qlist(handcards) do
								if index <= n then
									to_give:append(id)
								else
									break
								end
							end
							local skillcard = HaoShiCard:clone()
							for _,id in sgs.qlist(to_give) do
								skillcard:addSubcard(id)
							end
							local use = sgs.CardUseStruct()
							use.from = player
							use.to:append(target)
							use.card = skillcard
							room:useCard(use)
						end
					end
				end
			end
		end
		return false
	end,
	translations = {
		["@HaoShi"] = "请将一半手牌交给场上手牌最少的一名其他角色",
		["~HaoShi"] = "选择要给出的手牌->选择一名其他角色->点击“确定”",
	},
}
--[[
	技能：缔盟（阶段技）[空壳技能]
	描述：你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。
]]--
DiMeng = sgs.CreateLuaSkill{
	name = "DiMeng",
	translation = "缔盟",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。",
}
--武将信息：鲁肃
LuSu = sgs.CreateLuaGeneral{
	name = "lusu",
	translation = "鲁肃",
	title = "独断的外交家",
	kingdom = "wu",
	maxhp = 3,
	order = 3,
	cv = "听雨",
	illustrator = "LiuHeng",
	skills = {HaoShi, DiMeng},
	last_word = "荆湘未还，虽死难安……",
	resource = "lusu",
}
--[[****************************************************************
	称号：魔王
	武将：董卓
	势力：群
	性别：男
	体力上限：8勾玉
]]--****************************************************************
--[[
	技能：酒池
	描述：你可以将一张黑桃手牌当【酒】使用。
]]--
--[[
	技能：肉林（锁定技）
	描述：每当你指定女性角色为【杀】的目标后，或成为女性角色的【杀】的目标后，目标角色须连续使用两张【闪】抵消此【杀】。
]]--
--[[
	技能：崩坏（锁定技）
	描述：结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。
]]--
BengHuai = sgs.CreateLuaSkill{
	name = "BengHuai",
	translation = "崩坏",
	description = "<font color=\"blue\"><b>锁定技</b></font>，结束阶段开始时，若你的体力值不为场上最少（或之一），你须选择一项：失去1点体力，或失去1点体力上限。",
	audio = {
		"不朽之躯，天却亡我！",
		"呃！不！不可以的！……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local hp = player:getHp()
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			local minflag = true
			for _,p in sgs.qlist(others) do
				if p:getHp() < hp then
					minflag = false
					break
				end
			end
			if minflag then
				return false
			end
			local choice = room:askForChoice(player, "BengHuai", "hp+maxhp")
			if player:isFemale() then
				room:broadcastSkillInvoke("BengHuai", 2)
			else
				room:broadcastSkillInvoke("BengHuai", 1)
			end
			if choice == "hp" then
				room:loseHp(player)
			elseif choice == "maxhp" then
				room:loseMaxHp(player)
			end
		end
		return false
	end,
}
--[[
	技能：暴虐（主公技）[空壳技能]
	描述：其他群雄角色造成伤害后，该角色可以进行判定：若结果为黑桃，你回复1点体力。
]]--
--武将信息：董卓
DongZhuo = sgs.CreateLuaGeneral{
	name = "dongzhuo",
	translation = "董卓",
	title = "魔王",
	kingdom = "qun",
	maxhp = 8,
	order = 4,
	cv = "やまもとみ，迷宫女友(肉林2)",
	illustrator = "小冷",
	skills = {"jiuchi", "roulin", BengHuai, "baonue"},
	last_word = "吾儿奉先何在？呃……",
	resource = "dongzhuo",
}
--[[****************************************************************
	称号：冷酷的毒士
	武将：贾诩
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：完杀（锁定技）[空壳技能]
	描述：你的回合内，除濒死角色外的其他角色不能使用【桃】。
]]--
--[[
	技能：乱武（限定技）
	描述：出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。
]]--
LuanWuCard = sgs.CreateSkillCard{
	name = "LuanWuCard",
	skill_name = "LuanWu",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:doSuperLightbox("jiaxu", "LuanWu")
		source:loseMark("@chaos")
		local others = room:getOtherPlayers(source)
		for _,target in sgs.qlist(others) do
			room:cardEffect(self, source, target)
		end
	end,
	on_effect = function(self, effect)
		local minDist = 999
		local me = effect.to
		local room = me:getRoom()
		local others = room:getOtherPlayers(me)
		local targets = {}
		for _,p in sgs.qlist(others) do
			local dist = me:distanceTo(p)
			if dist < minDist then
				minDist = dist
				targets = {p}
			elseif dist == minDist then
				table.insert(targets, p)
			end
		end
		local victims = sgs.SPlayerList()
		for _,victim in ipairs(targets) do
			if me:canSlash(victim) then
				victims:append(victim)
			end
		end
		local losehp = true
		if not victims:isEmpty() then
			local slash = room:askForUseSlashTo(me, victims, "@@LuanWu")
			losehp = slash and false or true
		end
		if losehp then
			room:loseHp(me)
		end
	end,
}
LuanWuVS = sgs.CreateLuaSkill{
	name = "LuanWu",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return LuanWuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@chaos") > 0
	end,
}
LuanWu = sgs.CreateLuaSkill{
	name = "LuanWu",
	translation = "乱武",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。",
	audio = "智乱天下，武逆乾坤",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	limit_mark = "@chaos",
	view_as_skill = LuanWuVS,
	translations = {
		["@chaos"] = "乱武",
	},
}
--[[
	技能：帷幕（锁定技）
	描述：你不能被选择为黑色锦囊牌的目标。
]]--
WeiMu = sgs.CreateLuaSkill{
	name = "WeiMu",
	translation = "帷幕",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你不能被选择为黑色锦囊牌的目标。",
	audio = {
		"巧变制敌，谋定而动",
		"算无遗策，不动如山",
	},
	class = "ProhibitSkill",
	is_prohibited = function(self, from, to, card, others)
		if to:hasSkill("WeiMu") then
			return card:isBlack() and card:isKindOf("TrickCard")
		end
		return false
	end,
}
--武将信息：贾诩
JiaXu = sgs.CreateLuaGeneral{
	name = "jiaxu",
	translation = "贾诩",
	title = "冷酷的毒士",
	kingdom = "qun",
	maxhp = 3,
	order = 3,
	cv = "落凤一箭",
	skills = {"wansha", LuanWu, WeiMu},
	last_word = "大势已去，吾不能自保矣……",
	resource = "jiaxu",
	marks = {"@chaos"},
}
--[[****************************************************************
	林武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "thicket",
	translation = "林包",
	generals = {
		XuHuang, CaoPi, MengHuo, ZhuRong, SunJian, LuSu, DongZhuo, JiaXu,
	},
}