--[[
	太阳神三国杀武将单挑对战平台·风武将包
	武将总数：8
	武将一览：
		1、夏侯渊（神速）
		2、曹仁（据守）
		3、黄忠（烈弓）
		4、魏延（狂骨）
		5、小乔（天香、红颜）
		6、周泰（不屈）
		7、张角（雷击、鬼道、黄天）
		8、于吉（蛊惑）
]]--
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
ShenSuCard = sgs.CreateSkillCard{
	name = "ShenSuCard",
	skill_name = "ShenSu",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:setSkillName("_ShenSu")
		slash:deleteLater()
		local selected = sgs.PlayerList()
		for _,p in ipairs(targets) do
			selected:append(p)
		end
		return slash:targetFilter(selected, to_select, sgs.Self)
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("_ShenSu")
		local use = sgs.CardUseStruct()
		use.from = source
		use.card = slash
		for _,target in ipairs(targets) do
			if source:canSlash(target, slash, false) then
				use.to:append(target)
			end
		end
		if use.to:isEmpty() then
			slash:deleteLater()
		else
			room:useCard(use)
		end
	end,
}
ShenSuVS = sgs.CreateLuaSkill{
	name = "ShenSu",
	class = "ViewAsSkill",
	n = 1,
	ask = "",
	view_filter = function(self, selected, to_select)
		if ask == "@@ShenSu1" then
			return false
		elseif ask == "@@ShenSu2" then
			if to_select:isKindOf("EquipCard") then
				return not sgs.Self:isJilei(to_select)
			end
		end
		return false
	end,
	view_as = function(self, cards)
		if ask == "@@ShenSu1" then
			return ShenSuCard:clone()
		elseif ask == "@@ShenSu2" then
			if #cards == 1 then
				local card = ShenSuCard:clone()
				card:addSubcard(cards[1])
				return card
			end
		end
	end,
	enabled_at_play = function(self, player)
		ask = ""
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		ask = pattern
		return pattern == "@@ShenSu1" or pattern == "@@ShenSu2"
	end,
}
ShenSu = sgs.CreateLuaSkill{
	name = "ShenSu",
	translation = "神速",
	description = "你可以选择一至两项：跳过判定阶段和摸牌阶段，或跳过出牌阶段并弃置一张装备牌：你每选择上述一项，视为你使用一张无距离限制的【杀】。",
	audio = {
		"吾善于千里袭人！",
		"取汝首级，犹如探囊取物！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	view_as_skill = ShenSuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		local phase = change.to
		if phase == sgs.Player_Judge then
			if player:isSkipped(sgs.Player_Judge) or player:isSkipped(sgs.Player_Draw) then
				return false
			elseif sgs.Slash_IsAvailable(player) then
				if room:askForUseCard(player, "@@ShenSu1", "@ShenSu1", 1) then
					player:skip(sgs.Player_Judge, true)
					player:skip(sgs.Player_Draw, true)
				end
			end
		elseif phase == sgs.Player_Play then
			if player:isSkipped(sgs.Player_Play) then
				return false
			elseif sgs.Slash_IsAvailable(player) and player:canDiscard(player, "he") then
				if room:askForUseCard(player, "@@ShenSu2", "@ShenSu2", 2, sgs.Card_MethodDiscard) then
					player:skip(sgs.Player_Play, true)
				end
			end
		end
		return false
	end,
	translations = {
		["@ShenSu1"] = "您可以跳过判定阶段和摸牌阶段发动“神速”",
		["~ShenSu1"] = "选择【杀】的目标角色→点击“确定”",
		["@ShenSu2"] = "您可以跳过出牌阶段并弃置一张装备牌发动“神速”",
		["~ShenSu2"] = "选择一张装备牌→选择【杀】的目标角色→点击“确定”",
	},
}
--武将信息：夏侯渊
XiaHouYuan = sgs.CreateLuaGeneral{
	name = "xiahouyuan",
	translation = "夏侯渊",
	title = "疾行的猎豹",
	kingdom = "wei",
	order = 4,
	skills = ShenSu,
	last_word = "竟然……比我还……快……",
	resource = "xiahouyuan",
}
--[[****************************************************************
	称号：大将军
	武将：曹仁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：据守
	描述：结束阶段开始时，你可以摸三张牌，然后将武将牌翻面。
]]--
JuShou = sgs.CreateLuaSkill{
	name = "JuShou",
	translation = "据守",
	description = "结束阶段开始时，你可以摸三张牌，然后将武将牌翻面。",
	audio = {
		"我先休息一会儿！",
		"尽管来吧！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:askForSkillInvoke("JuShou", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("JuShou")
				room:drawCards(player, 3, "JuShou")
				player:turnOver()
			end
		end
		return false
	end,
}
--武将信息：曹仁
CaoRen = sgs.CreateLuaGeneral{
	name = "caoren",
	translation = "曹仁",
	title = "大将军",
	kingdom = "wei",
	order = 6,
	skills = JuShou,
	last_word = "实在是……守不住了……",
	resource = "caoren",
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
	描述：每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，或目标角色的手牌数小于或等于你的攻击范围，你可以令该角色不能使用【闪】响应此【杀】。
]]--
LieGong = sgs.CreateLuaSkill{
	name = "LieGong",
	translation = "烈弓",
	description = "每当你于出牌阶段内指定【杀】的目标后，若目标角色的手牌数大于或等于你的体力值，或目标角色的手牌数小于或等于你的攻击范围，你可以令该角色不能使用【闪】响应此【杀】。",
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
				local range = player:getAttackRange()
				local room = player:getRoom()
				for index, target in sgs.qlist(use.to) do
					local jink = jinkList:at(index)
					local num = target:getHandcardNum()
					if num >= hp or num <= range then
						local ai_data = sgs.QVariant()
						ai_data:setValue(target)
						if player:askForSkillInvoke("LieGong", ai_data) then
							room:broadcastSkillInvoke("LieGong")
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
	name = "huangzhong",
	translation = "黄忠",
	title = "老当益壮",
	kingdom = "shu",
	order = 7,
	skills = LieGong,
	last_word = "不得不服老了……",
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
	技能：狂骨（锁定技）
	描述：每当你对一名距离1以内角色造成1点伤害后，你回复1点体力。
]]--
KuangGuRecord = sgs.CreateLuaSkill{
	name = "#KuangGuRecord",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.PreDamageDone},
	global = true,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source then
			local distance = source:distanceTo(damage.to)
			local invoke = ( distance <= 1 )
			source:setTag("InvokeKuangGu", sgs.QVariant(invoke))
		end
		return false
	end,
}
KuangGu = sgs.CreateLuaSkill{
	name = "KuangGu",
	translation = "狂骨",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你对一名距离1以内角色造成1点伤害后，你回复1点体力。",
	audio = "哈哈！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local invoke = player:getTag("InvokeKuangGu"):toBool()
		player:removeTag("InvokeKuangGu")
		if invoke and player:isWounded() then
			local room = player:getRoom()
			room:broadcastSkillInvoke("KuangGu")
			room:sendCompulsoryTriggerLog(player, "KuangGu")
			local damage = data:toDamage()
			local recover = sgs.RecoverStruct()
			recover.who = player
			recover.recover = damage.damage
			room:recover(player, recover)
		end
		return false
	end,
	related_skills = KuangGuRecord,
}
--武将信息：魏延
WeiYan = sgs.CreateLuaGeneral{
	name = "weiyan",
	translation = "魏延",
	title = "嗜血的独狼",
	kingdom = "shu",
	order = 5,
	illustrator = "Sonia Tang",
	skills = KuangGu,
	last_word = "谁敢杀我？啊！",
	resource = "weiyan",
}
--[[****************************************************************
	称号：矫情之花
	武将：小乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天香
	描述：每当你受到伤害时，你可以弃置一张♥手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。
]]--
TianXiangDraw = sgs.CreateLuaSkill{
	name = "#TianXiangDraw",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageComplete},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.transfer and damage.transfer_reason == "TianXiang" then
			local lost = player:getLostHp()
			if lost > 0 then
				local room = player:getRoom()
				room:drawCards(player, lost, "TianXiang")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
TianXiangCard = sgs.CreateSkillCard{
	name = "TianXiangCard",
	skill_name = "TianXiang",
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
		local damage = source:getTag("TianXiangDamage"):toDamage()
		damage.to = effect.to
		damage.transfer = true
		damage.transfer_reason = "TianXiang"
		local tag = sgs.QVariant()
		tag:setValue(damage)
		source:setTag("TransferDamage", tag)
	end,
}
TianXiangVS = sgs.CreateLuaSkill{
	name = "TianXiang",
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:getSuit() == sgs.Card_Heart then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = TianXiangCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@TianXiang"
	end,
}
TianXiang = sgs.CreateLuaSkill{
	name = "TianXiang",
	translation = "天香",
	description = "每当你受到伤害时，你可以弃置一张红心手牌并选择一名其他角色：若如此做，你将此伤害转移给该角色，此伤害结算后该角色摸X张牌（X为该角色已损失的体力值）。",
	audio = {
		"替我挡着~",
		"接着哦~",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	view_as_skill = TianXiangVS,
	on_trigger = function(self, event, player, data)
		if player:isKongcheng() then
			return false
		elseif player:canDiscard(player, "h") then
			player:setTag("TianXiangDamage", data)
			local room = player:getRoom()
			if room:askForUseCard(player, "@@TianXiang", "@TianXiang", -1, sgs.Card_MethodDiscard) then
				return true
			end
		end
		return false
	end,
	related_skills = TianXiangDraw,
	translations = {
		["@TianXiang"] = "请选择“天香”的目标",
		["~TianXiang"] = "选择一张<font color=\"red\">♥</font>手牌→选择一名其他角色→点击确定",
	},
}
--[[
	技能：红颜（锁定技）
	描述：你的♠牌视为♥牌。
]]--
HongYan = sgs.CreateLuaSkill{
	name = "HongYan",
	translation = "红颜",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的黑桃牌视为红心牌。",
	audio = "（魔法特效）",
	class = "FilterSkill",
	view_filter = function(self, to_select)
		return to_select:getSuit() == sgs.Card_Spade
	end,
	view_as = function(self, card)
		local id = card:getEffectiveId()
		local wrapped = sgs.Sanguosha:getWrappedCard(id)
		wrapped:setSkillName("HongYan")
		wrapped:setSuit(sgs.Card_Heart)
		wrapped:setModified(true)
		return wrapped
	end,
}
--武将信息：小乔
XiaoQiao = sgs.CreateLuaGeneral{
	name = "xiaoqiao",
	translation = "小乔",
	title = "矫情之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 2,
	skills = {TianXiang, HongYan},
	last_word = "公瑾，我先走一步……",
	resource = "xiaoqiao",
}
--[[****************************************************************
	称号：历战之躯
	武将：周泰
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：不屈
	描述：每当你扣减1点体力后，若你的体力值为0或更低，你可以将牌堆顶的一张牌置于你的武将牌上，然后若无同点数的“不屈牌”，你不进入濒死状态。每当你回复1点体力后，你将一张“不屈牌”置入弃牌堆。
]]--
BuQuClear = sgs.CreateLuaSkill{
	name = "#BuQuClear",
	class = "DetachEffectSkill",
	on_skill_detached = function(self, room, player)
		if player:getHp() <= 0 then
			room:enterDying(player, nil)
		end
	end,
}
BuQuRemove = sgs.CreateLuaSkill{
	name = "#BuQuRemove",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpRecover},
	on_trigger = function(self, event, player, data)
		local pile = player:getPile("BuQuPile")
		if pile:isEmpty() then
			return false
		end
		local room = player:getRoom()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "BuQu", "")
		local need = 1 - player:getHp()
		if need > 0 then
			local count = pile:length() - need
			for i=1, count, 1 do
				room:fillAG(pile)
				local id = room:askForAG(player, pile, false, "BuQu")
				room:clearAG()
				if id >= 0 then
					local card = sgs.Sanguosha:getCard(id)
					pile:removeOne(id)
					local msg = sgs.LogMessage()
					msg.type = "$BuquRemove"
					msg.from = player
					msg.card_str = card:toString()
					room:sendLog(msg)
					room:throwCard(card, reason, nil)
				end
			end
		else
			for _,id in sgs.qlist(pile) do
				local card = sgs.Sanguosha:getCard(id)
				local msg = sgs.LogMessage()
				msg.type = "$BuquRemove"
				msg.from = player
				msg.card_str = card:toString()
				room:sendLog(msg)
				room:throwCard(card, reason, nil)
			end
		end
		return false
	end,
	translations = {
		["$BuquRemove"] = "%from 移除了“不屈牌”：%card",
	},
}
BuQuEffect = sgs.CreateLuaSkill{
	name = "#BuQuEffect",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForPeachesDone},
	on_trigger = function(self, event, player, data)
		if player:getHp() > 0 then
			return false
		end
		local room = player:getRoom()
		if room:getTag("BuQuTarget"):toString() ~= player:objectName() then
			return false
		end
		room:removeTag("BuQuTarget")
		local pile = player:getPile("BuQuPile")
		local duplicate = {
			points = {},
		}
		local numbers = {}
		for _,id in sgs.qlist(pile) do
			local card = sgs.Sanguosha:getCard(id)
			local point = card:getNumber()
			if numbers[point] then
				if #duplicate[point] == 1 then
					table.insert(duplicate["points"], point)
				end
				table.insert(duplicate[point], id)
			else
				numbers[point] = true
				duplicate[point] = {id}
			end
		end
		local count = #duplicate["points"]
		if count == 0 then
			room:broadcastSkillInvoke("BuQu")
			room:setPlayerFlag(player, "-Global_Dying")
			return true
		end
		local msg = sgs.LogMessage()
		msg.type = "#BuquDuplicate"
		msg.from = player
		msg.arg = count
		room:sendLog(msg)
		for i=1, count, 1 do
			local point = duplicate["points"][i]
			msg = sgs.LogMessage()
			msg.type = "#BuquDuplicateGroup"
			msg.from = player
			msg.arg = i
			if point <= 10 then
				msg.arg2 = point
			elseif point == 11 then
				msg.arg2 = "J"
			elseif point == 12 then
				msg.arg2 = "Q"
			elseif point == 13 then
				msg.arg2 = "K"
			end
			room:sendLog(msg)
			for _,id in ipairs(duplicate[point]) do
				local card = sgs.Sanguosha:getCard(id)
				msg = sgs.LogMessage()
				msg.type = "$BuquDuplicateItem"
				msg.card_str = id
				room:sendLog(msg)
			end
		end
		return false
	end,
	translations = {
		["#BuquDuplicate"] = "%from 发动“<font color=\"yellow\"><b>不屈</b></font>”失败，其“不屈牌”中有 %arg 组重复点数",
		["#BuquDuplicateGroup"] = "第 %arg 组重复点数为 %arg2",
		["$BuquDuplicateItem"] = "重复“不屈牌”: %card",
	},
}
BuQu = sgs.CreateLuaSkill{
	name = "BuQu",
	translation = "不屈",
	description = "每当你扣减1点体力后，若你的体力值为0或更低，你可以将牌堆顶的一张牌置于你的武将牌上，然后若无同点数的“不屈牌”，你不进入濒死状态。每当你回复1点体力后，你将一张“不屈牌”置入弃牌堆。",
	audio = {
		"还不够！",
		"我绝不会倒下！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.HpChanged},
	on_trigger = function(self, event, player, data)
		local invoke = false
		if data then
			local recover = data:toRecover()
			if recover and recover.recover then
				if player:getHp() <= 0 then
					invoke = player:askForSkillInvoke("BuQu", data)
				end
			end
		end
		if invoke then
			local room = player:getRoom()
			room:broadcastSkillInvoke("BuQu")
			room:setTag("BuQuTarget", sgs.QVariant(player:objectName()))
			local pile = player:getPile("BuQuPile")
			local need = 1 - player:getHp()
			local n = need - pile:length()
			if n > 0 then
				local card_ids = room:getNCards(n, false)
				player:addToPile("BuQuPile", card_ids)
			end
			local new_pile = player:getPile("BuQuPile")
			local duplicate = false
			local numbers = {}
			for _,id in sgs.qlist(new_pile) do
				local card = sgs.Sanguosha:getCard(id)
				local point = card:getNumber()
				if numbers[point] then
					duplicate = true
					break
				else
					numbers[point] = true
				end
			end
			if not duplicate then
				room:removeTag("BuQuTarget")
				return true
			end
		end
		return false
	end,
	priority = 1,
	translations = {
		["BuQuPile"] = "不屈",
	},
	related_skills = {BuQuEffect, BuQuRemove, BuQuClear},
}
--武将信息：周泰
ZhouTai = sgs.CreateLuaGeneral{
	name = "zhoutai",
	translation = "周泰",
	title = "历战之躯",
	kingdom = "wu",
	order = 2,
	skills = BuQu,
	last_word = "已经……尽力了……",
	resource = "zhoutai",
}
--[[****************************************************************
	称号：天公将军
	武将：张角
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：雷击
	描述：每当你使用或打出一张【闪】时，你可以令一名角色进行判定：若结果为♠，你对该角色造成2点雷电伤害。
]]--
LeiJi = sgs.CreateLuaSkill{
	name = "LeiJi",
	translation = "雷击",
	description = "每当你使用或打出一张【闪】时，你可以令一名角色进行判定：若结果为黑桃，你对该角色造成2点雷电伤害。",
	audio = {
		"以我之真气，合天地之造化！",
		"雷公助我！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardResponded},
	on_trigger = function(self, event, player, data)
		local response = data:toCardResponse()
		local jink = response.m_card
		if jink and jink:isKindOf("Jink") then
			local room = player:getRoom()
			local alives = room:getAlivePlayers()
			local target = room:askForPlayerChosen(player, alives, "LeiJi", "@LeiJi", true, true)
			if target then
				room:broadcastSkillInvoke("LeiJi")
				local judge = sgs.JudgeStruct()
				judge.who = target
				judge.reason = "LeiJi"
				judge.pattern = ".|spade"
				judge.good = false
				judge.negative = true
				room:judge(judge)
				if judge:isBad() then
					local damage = sgs.DamageStruct()
					damage.from = player
					damage.to = target
					damage.damage = 2
					damage.nature = sgs.DamageStruct_Thunder
					damage.reason = "LeiJi"
					room:damage(damage)
				end
			end
		end
		return false
	end,
	translations = {
		["@LeiJi"] = "您可以对一名角色发动技能“雷击”",
		["~LeiJi"] = "选择一名角色→点击“确定”",
	},
}
--[[
	技能：鬼道
	描述：每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。
]]--
GuiDao = sgs.CreateLuaSkill{
	name = "GuiDao",
	translation = "鬼道",
	description = "每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。",
	audio = {
		"天下大势，为我所控！",
		"哼哼哼哼哼……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		local can_invoke = true
		if player:isKongcheng() then
			can_invoke = false
			local equips = player:getEquips()
			for _,equip in sgs.qlist(equips) do
				if equip:isBlack() then
					can_invoke = true
					break
				end
			end
		end
		if can_invoke then
			local judge = data:toJudge()
			local target = judge.who
			local prompt = string.format(
				"@askforretrial:%s:%s:%s:%d", 
				target:objectName(), 
				"GuiDao", 
				judge.reason, 
				judge.card:getEffectiveId()
			)
			local room = player:getRoom()
			local black = room:askForCard(player, ".|black", prompt, data, sgs.Card_MethodResponse, target, true)
			if black then
				room:broadcastSkillInvoke("GuiDao")
				room:retrial(black, player, judge, "GuiDao", true)
			end
		end
		return false
	end,
}
--[[
	技能：黄天（主公技、阶段技）[空壳技能]
	描述：其他群雄角色的出牌阶段，该角色可以交给你一张【闪】或【闪电】。
]]--
HuangTian = sgs.CreateLuaSkill{
	name = "HuangTian",
	translation = "黄天",
	description = "<font color=\"yellow\"><b>主公技</b></font>、<font color=\"green\"><b>阶段技</b></font>，其他群雄角色的出牌阶段，该角色可以交给你一张【闪】或【闪电】。",
}
--武将信息：张角
ZhangJiao = sgs.CreateLuaGeneral{
	name = "zhangjiao",
	translation = "张角",
	title = "天公将军",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	skills = {LeiJi, GuiDao, HuangTian},
	last_word = "黄天……也死了……",
	resource = "zhangjiao",
}
--[[****************************************************************
	称号：太平道人
	武将：于吉
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：蛊惑
	描述：你可以扣置一张手牌当做一张基本牌或非延时锦囊牌使用或打出，体力值大于0的其他角色选择是否质疑，然后你展示此牌：若无角色质疑，此牌按你所述继续结算；若有角色质疑：若此牌为真，质疑角色各失去1点体力，否则质疑角色各摸一张牌；且若此牌为♥且为真，则按你所述继续结算，否则将之置入弃牌堆。
]]--
GuHuo = sgs.CreateLuaSkill{
	name = "GuHuo",
	translation = "蛊惑",
	description = "你可以扣置一张手牌当做一张基本牌或非延时锦囊牌使用或打出，体力值大于0的其他角色选择是否质疑，然后你展示此牌：若无角色质疑，此牌按你所述继续结算；若有角色质疑：若此牌为真，质疑角色各失去1点体力，否则质疑角色各摸一张牌；且若此牌为红心且为真，则按你所述继续结算，否则将之置入弃牌堆。",
	audio = {
		"猜猜看哪~",
		"你信吗？",
	},
}
--武将信息：于吉
YuJi = sgs.CreateLuaGeneral{
	name = "yuji",
	translation = "于吉",
	title = "太平道人",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	skills = GuHuo,
	last_word = "竟然……被猜到了……",
	resource = "yuji",
}
--[[****************************************************************
	风武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "wind",
	translation = "风包",
	generals = {
		XiaHouYuan, CaoRen, HuangZhong, WeiYan, XiaoQiao, ZhouTai, ZhangJiao, YuJi,
	},
}