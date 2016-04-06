--[[
	太阳神三国杀武将单挑对战平台·一将成名2012武将包
	武将总数：15
	武将一览：
		1、步练师（安恤、追忆）
		2、曹彰（将驰）
		3、程普（疠火、醇酪）
		4、关兴张苞（父魂）+（武圣、咆哮）
		5、韩当（弓骑、解烦）
		6、华雄（恃勇）
		7、廖化（当先、伏枥）
		8、刘表（自守、宗室）
		9、马岱（马术、潜袭）
		10、王异（贞烈、秘计）
		11、荀攸（奇策、智愚）
		12、关兴张苞·改（父魂）+（武圣、咆哮）
		13、韩当·改（弓骑、解烦）
		14、马岱·改（马术、潜袭）
		15、王异·改（贞烈、秘计）
]]--
--[[****************************************************************
	版本控制
]]--****************************************************************
local old_version = true --原版武将开关，开启后将出现 关兴张苞、韩当、马岱、王异 四位武将
local new_version = true --新版武将开关，开启后将出现 关兴张苞·改、韩当·改、马岱·改、王异·改 四位武将
local yjcm2012 = {}
--[[****************************************************************
	称号：无冕之后
	武将：步练师
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：安恤（阶段技）[空壳技能]
	描述：你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为黑桃，你摸一张牌。
]]--
AnXu = sgs.CreateLuaSkill{
	name = "yj2AnXu",
	translation = "安恤",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为黑桃，你摸一张牌。",
}
--[[
	技能：追忆
	描述：你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。
]]--
ZhuiYi = sgs.CreateLuaSkill{
	name = "yj2ZhuiYi",
	translation = "追忆",
	description = "你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。",
	audio = {
		"此情常在，追思不忘。",
		"吾若有灵，长待君侧。",
	},
	class = "TriggerSkill",
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local victim = death.who
		if victim and victim:objectName() == player:objectName() then
			local killer = nil
			if death.reason then
				killer = death.reason.from
			end
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			if killer then
				others:removeOne(killer)
			end
			if others:isEmpty() then
				return false
			end
			local target = room:askForPlayerChosen(player, others, "yjiiZhuiYi", "@yjiiZhuiYi", true)
			if target then
				if target:isGeneral("sunquan", true, true) then
					room:broadcastSkillInvoke("yjiiZhuiYi", 2)
				else
					room:broadcastSkillInvoke("yjiiZhuiYi", 1)
				end
				room:drawCards(target, 3, "yjiiZhuiYi")
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = 1
				room:recover(target, recover, true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("yjiiZhuiYi")
	end,
}
--武将信息：步练师
BuLianShi = sgs.CreateLuaGeneral{
	name = "yj_ii_bulianshi",
	real_name = "bulianshi",
	translation = "步练师",
	title = "无冕之后",
	kingdom = "wu",
	maxhp = 3,
	order = 1,
	designer = "Anais",
	cv = "蒲小猫",
	illustrator = "勺子妞",
	skills = {AnXu, ZhuiYi},
	last_word = "陛下，今生情未了，来世再侍君。",
	resource = "bulianshi",
}
table.insert(yjcm2012, BuLianShi)
--[[****************************************************************
	称号：黄须儿
	武将：曹彰
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：将驰
	描述：摸牌阶段，你可以选择一项：1.少摸一张牌，然后本回合，你使用【杀】无距离限制，你可以额外使用一张【杀】；2.额外摸一张牌，且你不能使用或打出【杀】，直到回合结束。
]]--
JiangChiMod = sgs.CreateLuaSkill{
	name = "#yj2JiangChiMod",
	class = "TargetModSkill",
	residue_func = function(self, player, card)
		if player:hasFlag("yj2JiangChiInvoked") then
			return 1
		end
		return 0
	end,
	distance_limit_func = function(self, player, card)
		if player:hasFlag("yj2JiangChiInvoked") then
			return 1000
		end
		return 0
	end,
}
JiangChi = sgs.CreateLuaSkill{
	name = "yj2JiangChi",
	translation = "将驰",
	description = "摸牌阶段，你可以选择一项：1.少摸一张牌，然后本回合，你使用【杀】无距离限制，你可以额外使用一张【杀】；2.额外摸一张牌，且你不能使用或打出【杀】，直到回合结束。",
	audio = {
		"吾有美妾，可换骏马！",
		"披荆执锐，临难不顾！",
	},
	class = "DrawCardsSkill",
	frequency = sgs.Skill_NotFrequent,
	draw_num_func = function(self, player, n)
		local choices = n > 0 and "jiang+chi+cancel" or "jiang+cancel"
		local room = player:getRoom()
		local choice = room:askForChoice(player, "yj2JiangChi", choices)
		if choice == "jiang" then
			room:broadcastSkillInvoke("yj2JiangChi", 1)
			room:notifySkillInvoked(player, "yj2JiangChi")
			local msg = sgs.LogMessage()
			msg.type = "#yj2JiangChiMore"
			msg.from = player
			msg.arg = "yj2JiangChi"
			room:sendLog(msg)
			room:setPlayerCardLimitation(player, "use,response", "Slash", true)
			return n + 1
		elseif choice == "chi" then
			room:broadcastSkillInvoke("yj2JiangChi", 2)
			room:notifySkillInvoked(player, "yj2JiangChi")
			local msg = sgs.LogMessage()
			msg.type = "#yj2JiangChiLess"
			msg.from = player
			msg.arg = "yj2JiangChi"
			room:sendLog(msg)
			room:setPlayerFlag(player, "yj2JiangChiInvoked")
			return n - 1
		end
		return n
	end,
	translations = {
		["yj2JiangChi:jiang"] = "多摸一张牌，本回合不能使用或打出杀",
		["yj2JiangChi:chi"] = "少摸一张牌，本回合杀无限距离且可额外使用一张杀",
		["yj2JiangChi:cancel"] = "不发动“将驰”",
		["#yj2JiangChiMore"] = "%from 发动了“%arg”，将额外摸一张牌",
		["#yj2JiangChiLess"] = "%from 发动了“%arg”，将少摸一张牌",
	},
	related_skills = JiangChiMod,
}
--武将信息：曹彰
CaoZhang = sgs.CreateLuaGeneral{
	name = "yj_ii_caozhang",
	real_name = "caozhang",
	translation = "曹彰",
	title = "黄须儿",
	kingdom = "wei",
	maxhp = 4,
	order = 4,
	designer = "潜龙勿用",
	cv = "墨宣砚韵",
	illustrator = "Yi章",
	skills = JiangChi,
	last_word = "难成卫霍之功，恨矣悲哉！",
	resource = "caozhang",
}
table.insert(yjcm2012, CaoZhang)
--[[****************************************************************
	称号：三朝虎臣
	武将：程普
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：疠火
	描述：你可以将一张普通【杀】当火【杀】使用。你以此法使用【杀】结算后，若此【杀】造成了伤害，你失去1点体力。你使用火【杀】可以额外选择一名目标。
]]--
LiHuoMod = sgs.CreateLuaSkill{
	name = "#yj2LiHuoMod",
	class = "TargetModSkill",
	extra_target_func = function(self, player, card)
		if player:hasSkill("yj2LiHuo") and card:isKindOf("FireSlash") then
			return 1
		end
		return 0
	end,
}
LiHuoVS = sgs.CreateLuaSkill{
	name = "yj2LiHuo",
	class = "OneCardViewAsSkill",
	filter_pattern = "%slash",
	response_or_use = true,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local slash = sgs.Sanguosha:cloneCard("fire_slash", suit, point)
		slash:addSubcard(card)
		slash:setSkillName("yj2LiHuo")
		return slash
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		if pattern == "slash" then
			local reason = sgs.Sanguosha:getCurrentCardUseReason()
			return reason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		end
		return false
	end,
	effect_index = function(self, player, card)
		return 1
	end,
}
LiHuo = sgs.CreateLuaSkill{
	name = "yj2LiHuo",
	translation = "疠火",
	description = "你可以将一张普通【杀】当火【杀】使用。你以此法使用【杀】结算后，若此【杀】造成了伤害，你失去1点体力。你使用火【杀】可以额外选择一名目标。",
	audio = {
		"叛者何辜，投尸火焚！",
		"疠气侵身……呃！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.PreDamageDone, sgs.CardFinished},
	view_as_skill = LiHuoVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreDamageDone then
			local damage = data:toDamage()
			local slash = damage.card
			if slash and slash:isKindOf("Slash") and slash:getSkillName() == "yj2LiHuo" then
				room:setCardFlag(slash, "yj2LiHuoDamage")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") and slash:hasFlag("yj2LiHuoDamage") then
				room:setCardFlag(slash, "-yj2LiHuoDamage")
				local source = use.from
				if source and source:isAlive() then
					room:broadcastSkillInvoke("yj2LiHuo", 2)
					room:sendCompulsoryTriggerLog(source, "yj2LiHuo")
					room:loseHp(source)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	related_skills = LiHuoMod,
}
--[[
	技能：醇酪
	描述：结束阶段开始时，若你的武将牌上没有“醇”，你可以将至少一张【杀】置于武将牌上，称为“醇”。每当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。
]]--
ChunLaoCard = sgs.CreateSkillCard{
	name = "yj2ChunLaoCard",
	skill_name = "yj2ChunLao",
	target_fixed = true,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	on_use = function(self, room, source, targets)
		source:addToPile("wine", self)
	end,
}
ChunLaoWineCard = sgs.CreateSkillCard{
	name = "yj2ChunLaoWineCard",
	skill_name = "yj2ChunLao",
	target_fixed = true,
	will_throw = false,
	mute = true,
	on_use = function(self, room, source, targets)
		local target = room:getCurrentDyingPlayer()
		if target then
			local subcards = self:getSubcards()
			if subcards:isEmpty() then
				return
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "yj2ChunLao", "")
			local dummy = sgs.DummyCard(subcards)
			room:throwCard(dummy, reason)
			dummy:deleteLater()
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
			analeptic:setSkillName("_yj2ChunLao")
			local use = sgs.CardUseStruct()
			use.from = target
			use.to:append(target)
			use.card = analeptic
			room:useCard(use, false)
		end
	end,
}
ChunLaoVS = sgs.CreateLuaSkill{
	name = "yj2ChunLao",
	class = "ViewAsSkill",
	expand_pile = "wine",
	ask = "",
	n = 999,
	view_filter = function(self, selected, to_select)
		if ask == "@@yj2ChunLao" then
			return to_select:isKindOf("Slash")
		elseif #selected == 0 then
			local pile = sgs.Self:getPile("wine")
			local card_id = to_select:getEffectiveId()
			for _,id in sgs.qlist(pile) do
				if id == card_id then
					return true
				end
			end
		end
		return false
	end,
	view_as = function(self, cards)
		if ask == "@@yj2ChunLao" then
			if #cards > 0 then
				local card = ChunLaoCard:clone()
				for _,c in ipairs(cards) do
					card:addSubcard(c)
				end
				return card
			end
		else
			if #cards == 1 then
				local card = ChunLaoWineCard:clone()
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
		if pattern == "@@yj2ChunLao" then
			return true
		elseif player:getPile("wine"):isEmpty() then
			return false
		end
		return string.find(pattern, "peach")
	end,
	effect_index = function(self, player, card)
		if card:isKindOf("Analeptic") then
			if player:isGeneral("zhouyu", true, true) then
				return 3
			end
			return 2
		end
		return 1
	end,
}
ChunLao = sgs.CreateLuaSkill{
	name = "yj2ChunLao",
	translation = "醇酪",
	description = "结束阶段开始时，若你的武将牌上没有“醇”，你可以将至少一张【杀】置于武将牌上，称为“醇”。每当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。",
	audio = {
		"美酒当藏之，来日与众享！",
		"吾有美酒，与众饮之！",
		"与公瑾相交，不饮自醉！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = ChunLaoVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:isKongcheng() then
				return false
			elseif player:getPile("wine"):isEmpty() then
				local room = player:getRoom()
				room:askForUseCard(player, "@@yj2ChunLao", "@yj2ChunLao", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
	translations = {
		["wine"] = "醇",
		["@yj2ChunLao"] = "您可以发动“醇酪”",
		["~yj2ChunLao"] = "选择至少一张【杀】→点击“确定”",
	},
}
--武将信息：程普
ChengPu = sgs.CreateLuaGeneral{
	name = "yj_ii_chengpu",
	real_name = "chengpu",
	translation = "程普",
	title = "三朝虎臣",
	kingdom = "wu",
	maxhp = 4,
	order = 3,
	designer = "Michael_Lee",
	cv = "风叹息",
	illustrator = "G.G.G.",
	skills = {LiHuo, ChunLao},
	last_word = "不曾枉杀人，为何……折我寿！",
	resource = "chengpu",
}
table.insert(yjcm2012, ChengPu)
if old_version then
--[[****************************************************************
	称号：将门虎子
	武将：关兴张苞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：父魂
	描述：摸牌阶段开始时，你可以放弃摸牌，亮出牌堆顶的两张牌并获得之：若亮出的牌不为同一颜色，你拥有“武圣”、“咆哮”，直到回合结束。
]]--
FuHun = sgs.CreateLuaSkill{
	name = "yj2FuHun",
	translation = "父魂",
	description = "摸牌阶段开始时，你可以放弃摸牌，亮出牌堆顶的两张牌并获得之：若亮出的牌不为同一颜色，你拥有“武圣”、“咆哮”，直到回合结束。",
	audio = {
		"吾父武名，声震海内！",
		"父魂佑我！",
		"父辈功勋，望尘莫及……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Draw then
				if player:isAlive() and player:hasSkill("yj2FuHun") then
					if player:askForSkillInvoke("yj2FuHun", data) then
						room:broadcastSkillInvoke("yj2FuHun", 1)
						local idA = room:drawCard()
						local idB = room:drawCard()
						local cardA = sgs.Sanguosha:getCard(idA)
						local cardB = sgs.Sanguosha:getCard(idB)
						local diff = ( cardA:getColor() ~= cardB:getColor() )
						local move = sgs.CardMoveStruct()
						move.card_ids:append(idA)
						move.card_ids:append(idB)
						local dummy = sgs.DummyCard(move.card_ids)
						move.reason = sgs.CardMoveReason(
							sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "yj2FuHun", ""
						)
						move.to_place = sgs.Player_PlaceTable
						room:moveCardsAtomic(move, true)
						room:getThread():delay()
						room:obtainCard(player, dummy)
						dummy:deleteLater()
						if diff then
							room:broadcastSkillInvoke("yj2FuHun", 2)
							room:handleAcquireDetachSkills(player, "WuSheng|paoxiao")
							room:setPlayerFlag(player, "yj2FuHunInvoked")
						else
							room:broadcastSkillInvoke("yj2FuHun", 3)
						end
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				if player:hasFlag("yj2FuHunInvoked") then
					room:handleAcquireDetachSkills(player, "-WuSheng|-paoxiao", true)
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
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
--武将信息：关兴张苞
GuanXingZhangBao = sgs.CreateLuaGeneral{
	name = "yj_ii_guanxingzhangbao",
	real_name = "guanxingzhangbao",
	translation = "关兴张苞",
	title = "将门虎子",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	cv = "喵小林，风叹息",
	illustrator = "HOOO",
	skills = FuHun,
	related_skills = {"WuSheng", "paoxiao"},
	last_word = "东吴未灭、父仇未报！可恨……可恨！",
	resource = "guanxingzhangbao_v1",
}
table.insert(yjcm2012, GuanXingZhangBao)
--[[****************************************************************
	称号：石城侯
	武将：韩当
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：弓骑
	描述：你可以将一张装备牌当【杀】使用或打出。你以此法使用的【杀】无距离限制。
]]--
GongQiMod = sgs.CreateLuaSkill{
	name = "#yj2GongQi",
	class = "TargetModSkill",
	distance_limit_func = function(self, player, card)
		if card:getSkillName() == "yj2GongQi" then
			return 1000
		end
		return 0
	end,
}
GongQi = sgs.CreateLuaSkill{
	name = "yj2GongQi",
	translation = "弓骑",
	description = "你可以将一张装备牌当【杀】使用或打出。你以此法使用的【杀】无距离限制。",
	audio = "弓马齐备，远射近突！",
	class = "OneCardViewAsSkill",
	view_filter = function(self, to_select)
		if to_select:isKindOf("EquipCard") then
			local reason = sgs.Sanguosha:getCurrentCardUseReason()
			if reason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
				slash:addSubcard(to_select)
				slash:deleteLater()
				return slash:isAvailable(sgs.Self)
			end
			return true
		end
		return false
	end,
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
		slash:addSubcard(card)
		slash:setSkillName("yj2GongQi")
		return slash
	end,
	enabled_at_play = function(self, player)
		if player:isNude() then
			return false
		end
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
	releted_skills = GongQiMod,
}
--[[
	技能：解烦
	描述：你的回合外，每当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】：若此【杀】造成伤害，造成伤害时防止此伤害，视为对该濒死角色使用了一张【桃】。
]]--
JieFanCard = sgs.CreateSkillCard{
	name = "yj2JieFanCard",
	skill_name = "yj2JieFan",
	target_fixed = true,
	will_throw = true,
	mute = true,
	on_use = function(self, room, source, targets)
		local current = room:getCurrent()
		if current and current:isAlive() and current:getPhase() ~= sgs.Player_NotActive then
			local target = room:getCurrentDyingPlayer()
			if target then
				room:setPlayerFlag(source, "yj2JieFanUseSlash")
				local tag = sgs.QVariant()
				tag:setValue(target)
				source:setTag("yj2JieFanTarget", tag)
				local prompt = string.format("@yj2JieFan:%s:%s:", current:objectName(), target:objectName())
				local slash = room:askForUseSlashTo(source, current, prompt, false)
				room:setPlayerFlag(source, "-yj2JieFanUseSlash")
				source:removeTag("yj2JieFanTarget")
				if not slash then
					room:setPlayerFlag(source, "Global_yj2JieFanFailed")
				end
			end
		end
	end,
}
JieFanVS = sgs.CreateLuaSkill{
	name = "yj2JieFan",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return JieFanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if string.find(pattern, "peach") then
			if player:hasFlag("Global_yj2JieFanFailed") then
				return false
			end
			local others = player:getAliveSiblings()
			for _,p in sgs.qlist(others) do
				if p:getPhase() ~= sgs.Player_NotActive then
					return true
				end
			end
		end
		return false
	end,
	effect_index = function(self, player, card)
		if card:hasFlag("yj2JieFanToLord") then
			return 2
		end
		return 1
	end,
}
JieFan = sgs.CreateLuaSkill{
	name = "yj2JieFan",
	translation = "解烦",
	description = "你的回合外，每当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】：若此【杀】造成伤害，造成伤害时防止此伤害，视为对该濒死角色使用了一张【桃】。",
	audio = {
		"解烦军至，此危自解！",
		"吾主莫慌！韩义公在此！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardFinished, sgs.DamageCaused, sgs.PreCardUsed},
	view_as_skill = JieFanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			if player:hasFlag("yj2JieFanUseSlash") then
				local use = data:toCardUse()
				local slash = use.card
				if slash and slash:isKindOf("Slash") then
					room:setPlayerFlag(player, "-yj2JieFanUseSlash")
					room:setCardFlag(slash, "yj2JieFanSlash")
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			local slash = damage.card
			if slash and slash:isKindOf("Slash") and slash:hasFlag("yj2JieFanSlash") then
				local msg = sgs.LogMessage()
				msg.type = "#yj2JieFanPrevent"
				msg.from = player
				msg.to:append(damage.to)
				room:sendLog(msg)
				local target = player:getTag("yj2JieFanTarget"):toPlayer()
				if target and target:getHp() > 0 then
					msg = sgs.LogMessage()
					msg.type = "#yj2JieFanNullCase1"
					msg.from = target
					room:sendLog(msg)
				elseif target and target:isDead() then
					msg = sgs.LogMessage()
					msg.type = "#yj2JieFanNullCase2"
					msg.from = target
					msg.to:append(player)
					room:sendLog(msg)
				elseif player:hasFlag("Global_PreventPeach") then
					msg = sgs.LogMessage()
					msg.type = "#yj2JieFanNullCase3"
					msg.from = room:getCurrent()
					room:sendLog(msg)
				else
					local peach = sgs.Sanguosha:cloneCard("peach", sgs.Card_NoSuit, 0)
					peach:setSkillName("_yj2JieFan")
					room:setCardFlag(slash, "yj2JieFanSuccess")
					local toLord = false
					if target then
						if target:isGeneral("sunquan", true, true) then
							toLord = true
						elseif target:isGeneral("sunce", true, true) then
							toLord = true
						elseif target:isGeneral("sunjian", true, true) then
							toLord = true
						end
					end
					if toLord then
						room:setCardFlag(slash, "yj2JieFanToLord")
					end
					local use = sgs.CardUseStruct()
					use.from = player
					use.to:append(target)
					use.card = peach
					room:useCard(use)
					if toLord then
						room:setCardFlag(slash, "-yj2JieFanToLord")
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local slash = use.card
			if slash and slash:isKindOf("Slash") and slash:hasFlag("yj2JieFanSlash") then
				local target = player:getTag("yj2JieFanTarget"):toPlayer()
				player:removeTag("yj2JieFanTarget")
				if target and not slash:hasFlag("yj2JieFanSuccess") then
					room:setPlayerFlag(player, "Global_yj2JieFanFailed")
				end
			end
		end
		return false
	end,
	translations = {
		["#yj2JieFanPrevent"] = "%from 的“<font color=\"yellow\"><b>解烦</b></font>”效果被触发，防止了对 %to 的伤害",
		["#yj2JieFanNullCase1"] = "%from 已经脱离濒死状态，“<font color=\"yellow\"><b>解烦</b></font>”第二项效果无法执行",
		["#yj2JieFanNullCase2"] = "%from 已经死亡，“<font color=\"yellow\"><b>解烦</b></font>”第二项效果无法执行",
		["#yj2JieFanNullCase3"] = "受当前回合角色 %from 影响，%to 不处于濒死状态，“<font color=\"yellow\"><b>解烦</b></font>”第二项效果无法执行",
	},
}
--武将信息：韩当
HanDang = sgs.CreateLuaGeneral{
	name = "yj_ii_handang",
	real_name = "handang",
	translation = "韩当",
	title = "石城侯",
	kingdom = "wu",
	maxhp = 4,
	order = 5,
	cv = "风叹息",
	illustrator = "DH",
	skills = {GongQi, JieFan},
	last_word = "我主堪忧，我主堪忧啊……",
	resource = "handang_v1",
}
table.insert(yjcm2012, HanDang)
end
--[[****************************************************************
	称号：魔将
	武将：华雄
	势力：群
	性别：男
	体力上限：6勾玉
]]--****************************************************************
--[[
	技能：恃勇（锁定技）
	描述：每当你受到一次红色【杀】或【酒】【杀】的伤害后，你失去1点体力上限。
]]--
ShiYong = sgs.CreateLuaSkill{
	name = "yj2ShiYong",
	translation = "恃勇",
	description = "<font color=\"blue\"><b>锁定技</b></font>，每当你受到一次红色【杀】或【酒】【杀】的伤害后，你失去1点体力上限。",
	audio = {
		"都是小伤，不必理会！",
		"这厮……好大的力气！",
		"唉！这厮，不易对付……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:isKindOf("Slash") then
			local index = 1
			if slash:hasFlag("drank") then
				index = 2
			elseif not slash:isRed() then
				return false
			end
			local source = damage.from
			if source and source:isGeneral("guanyu", true, true) then
				index = 3
			end
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj2ShiYong", index)
			room:sendCompulsoryTriggerLog(player, "yj2ShiYong")
			room:loseMaxHp(player)
		end
		return false
	end,
}
--武将信息：华雄
HuaXiong = sgs.CreateLuaGeneral{
	name = "yj_ii_huaxiong",
	real_name = "huaxiong",
	translation = "华雄",
	title = "魔将",
	kingdom = "qun",
	maxhp = 6,
	order = 5,
	designer = "小立",
	cv = "玉皇贰弟",
	illustrator = "地狱许",
	skills = ShiYong,
	last_word = "太自负了么……",
	resource = "huaxiong",
}
table.insert(yjcm2012, HuaXiong)
--[[****************************************************************
	称号：历尽沧桑
	武将：廖化
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：当先（锁定技）
	描述：回合开始时，你执行一个额外的出牌阶段。
]]--
DangXian = sgs.CreateLuaSkill{
	name = "yj2DangXian",
	translation = "当先",
	description = "<font color=\"blue\"><b>锁定技</b></font>，回合开始时，你执行一个额外的出牌阶段。",
	audio = "先锋一职，老夫责无旁贷！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_RoundStart then
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj2DangXian")
			room:sendCompulsoryTriggerLog(player, "yj2DangXian")
			player:setPhase(sgs.Player_Play)
			room:broadcastProperty(player, "phase")
			local thread = room:getThread()
			if not thread:trigger(sgs.EventPhaseStart, room, player) then
				thread:trigger(sgs.EventPhaseProceeding, room, player)
			end
			thread:trigger(sgs.EventPhaseEnd, room, player)
			player:setPhase(sgs.Player_RoundStart)
			room:broadcastProperty(player, "phase")
		end
		return false
	end,
}
--[[
	技能：伏枥（限定技）
	描述：每当你处于濒死状态时，你可以将回复至X点体力，然后将武将牌翻面。（X为现存势力数）
]]--
FuLi = sgs.CreateLuaSkill{
	name = "yj2FuLi",
	translation = "伏枥",
	description = "<font color=\"red\"><b>限定技</b></font>，每当你处于濒死状态时，你可以将回复至X点体力，然后将武将牌翻面。（X为现存势力数）",
	audio = "心系蜀汉，虽死必归！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	events = {sgs.AskForPeaches},
	limit_mark = "@laoji",
	on_trigger = function(self, event, player, data)
		local dying = data:toDying()
		local source = dying.who
		if source and source:objectName() == player:objectName() then
			if player:askForSkillInvoke("yj2FuLi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("yj2FuLi")
				room:doSuperLightbox("yj_ii_liaohua", "yj2FuLi")
				player:loseMark("@laoji")
				local kingdoms = {}
				local alives = room:getAlivePlayers()
				local x = player:getGameKingdomsCount()
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = x - player:getHp()
				room:recover(player, recover)
				player:turnOver()
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target and target:isAlive() and target:hasSkill("yj2FuLi") then
			return target:getMark("@laoji") > 0
		end
		return false
	end,
	translations = {
		["@laoji"] = "老骥",
	},
}
--武将信息：廖化
LiaoHua = sgs.CreateLuaGeneral{
	name = "yj_ii_liaohua",
	real_name = "liaohua",
	translation = "廖化",
	title = "历尽沧桑",
	kingdom = "shu",
	maxhp = 4,
	order = 3,
	designer = "桃花僧",
	cv = "风叹息",
	illustrator = "天空之城",
	skills = {DangXian, FuLi},
	last_word = "阅尽兴亡，此生无憾矣……",
	resource = "liaohua",
	marks = {"@laoji"},
}
table.insert(yjcm2012, LiaoHua)
--[[****************************************************************
	称号：跨蹈汉南
	武将：刘表
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：自守
	描述：摸牌阶段，若你已受伤，你可以额外摸X张牌，然后跳过出牌阶段。（X为你已损失的体力值）
]]--
ZiShou = sgs.CreateLuaSkill{
	name = "yj2ZiShou",
	translation = "自守",
	description = "摸牌阶段，若你已受伤，你可以额外摸X张牌，然后跳过出牌阶段。（X为你已损失的体力值）",
	audio = {
		"退以自保，静观时变。",
		"荆州沃土，自守足矣！",
		"余粮甚厚，不急出兵。",
	},
	class = "DrawCardsSkill",
	draw_num_func = function(self, player, n)
		if player:isWounded() then
			if player:askForSkillInvoke("yj2ZiShou", sgs.QVariant(n)) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("yj2ZiShou")
				local x = player:getLostHp()
				player:clearHistory()
				if not player:isSkipped(sgs.Player_Play) then
					player:skip(sgs.Player_Play)
				end
				return n + x
			end
		end
		return n
	end,
}
--[[
	技能：宗室（锁定技）
	描述：你的手牌上限+X。（X为现存势力数）
]]--
ZongShi = sgs.CreateLuaSkill{
	name = "yj2ZongShi",
	translation = "宗室",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的手牌上限+X。（X为现存势力数）",
	audio = {},
	class = "MaxCardsSkill",
	extra_func = function(self, player)
		if player:hasSkill("yj2ZongShi") then
			return player:getGameKingdomsCount()
		end
		return 0
	end,
}
--武将信息：刘表
LiuBiao = sgs.CreateLuaGeneral{
	name = "yj_ii_liubiao",
	real_name = "liubiao",
	translation = "刘表",
	title = "跨蹈汉南",
	kingdom = "qun",
	maxhp = 4,
	order = 6,
	designer = "管乐",
	cv = "喵小林",
	illustrator = "关东煮",
	skills = {ZiShou, ZongShi},
	last_word = "不欲争天下，奈何……",
	resource = "liubiao",
}
table.insert(yjcm2012, LiuBiao)
if old_version then
--[[****************************************************************
	称号：临危受命
	武将：马岱
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：潜袭
	描述：每当你使用【杀】对距离1的目标角色造成伤害时，你可以进行判定：若结果不为红桃，防止此伤害，该角色失去1点体力上限。
]]--
QianXi = sgs.CreateLuaSkill{
	name = "yj2QianXi",
	translation = "潜袭",
	description = "每当你使用【杀】对距离1的目标角色造成伤害时，你可以进行判定：若结果不为红桃，防止此伤害，该角色失去1点体力上限。",
	audio = {
		"（拔剑声）",
		"我敢杀你！",
		"竟然有防备？！只能力战搏杀之。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.chain or damage.transfer then
			return false
		elseif damage.by_user then
			local slash = damage.card
			if slash and slash:isKindOf("Slash") then
				local target = damage.to
				if player:distanceTo(target) == 1 then
					if player:askForSkillInvoke("yj2QianXi", data) then
						local room = player:getRoom()
						room:broadcastSkillInvoke("yj2QianXi", 1)
						local judge = sgs.JudgeStruct()
						judge.who = player
						judge.reason = "yj2QianXi"
						judge.pattern = ".|heart"
						judge.good = false
						room:judge(judge)
						if judge:isGood() then
							room:broadcastSkillInvoke("yj2QianXi", 2)
							room:loseMaxHp(target, 1)
							return true
						else
							room:broadcastSkillInvoke("yj2QianXi", 3)
						end
					end
				end
			end
		end
		return false
	end,
}
--武将信息：马岱
MaDai = sgs.CreateLuaGeneral{
	name = "yj_ii_madai",
	real_name = "madai",
	translation = "马岱",
	title = "临危受命",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "凌天翼",
	cv = "风叹息",
	illustrator = "大佬荣",
	skills = {"mashu", QianXi},
	last_word = "未能完成丞相遗命，辱没了我马家的威名啊……",
	resource = "madai_v1",
}
table.insert(yjcm2012, MaDai)
--[[****************************************************************
	称号：决意的巾帼
	武将：王异
	势力：魏
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：贞烈
	描述：每当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。
]]--
ZhenLie = sgs.CreateLuaSkill{
	name = "yj2ZhenLie",
	translation = "贞烈",
	description = "每当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。",
	audio = {
		"血君父之大耻，虽丧身亦不惜！",
		"顾子而不行，不如先死矣！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		local who = judge.who
		if who and who:objectName() == player:objectName() then
			if player:askForSkillInvoke("yj2ZhenLie", data) then
				local room = player:getRoom()
				local id = room:drawCard()
				local current = room:getCurrent()
				if current and current:objectName() == player:objectName() then
					room:broadcastSkillInvoke("yj2ZhenLie", 2)
				else
					room:broadcastSkillInvoke("yj2ZhenLie", 1)
				end
				room:getThread():delay()
				local card = sgs.Sanguosha:getCard(id)
				room:retrial(card, player, judge, "yj2ZhenLie")
			end
		end
		return false
	end,
}
--[[
	技能：秘计
	描述：回合开始或结束阶段开始时，若你已受伤，你可以进行判定：若结果为黑色，你观看牌堆顶的X张牌然后将之交给一名角色。（X为你已损失的体力值）
]]--
MiJi = sgs.CreateLuaSkill{
	name = "yj2MiJi",
	translation = "秘计",
	description = "回合开始或结束阶段开始时，若你已受伤，你可以进行判定：若结果为黑色，你观看牌堆顶的X张牌然后将之交给一名角色。（X为你已损失的体力值）",
	audio = {
		"有此九奇，可逐羌敌！",
		"屯兵逐超，得保冀城！",
		"救兵已到，乃解城围！",
		"暂与汝和，仇必后报！",
	},
	class = "PhaseChangeSkill",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player)
		if player:isWounded() then
			local phase = player:getPhase()
			if phase == sgs.Player_Start or phase == sgs.Player_Finish then
				if player:askForSkillInvoke("yj2MiJi") then
					local room = player:getRoom()
					room:broadcastSkillInvoke("yj2MiJi", 1)
					local judge = sgs.JudgeStruct()
					judge.who = player
					judge.reason = "yj2MiJi"
					judge.pattern = ".|black"
					judge.good = true
					room:judge()
					if judge:isGood() and player:isAlive() then
						local x = player:getLostHp()
						if x == 0 then
							return false
						end
						local card_ids = room:getNCards(x, false)
						room:fillAG(card_ids, player)
						local alives = room:getAlivePlayers()
						local target = room:askForPlayerChosen(player, alives, "yj2MiJi") or player
						room:clearAG(player)
						if target:objectName() == player:objectName() then
							room:broadcastSkillInvoke("yj2MiJi", 2)
						elseif target:isGeneral("machao", true, true) then
							room:broadcastSkillInvoke("yj2MiJi", 4)
						else
							room:broadcastSkillInvoke("yj2MiJi", 3)
						end
						local dummy = sgs.DummyCard(card_ids)
						room:setPlayerFlag(player, "Global_GongxinOperator")
						room:obtainCard(target, dummy, false)
						room:setPlayerFlag(player, "-Global_GongxinOperator")
						dummy:deleteLater()
					end
				end
			end
		end
		return false
	end,
}
--武将信息：王异
WangYi = sgs.CreateLuaGeneral{
	name = "yj_ii_wangyi",
	real_name = "wangyi",
	translation = "王异",
	title = "决意的巾帼",
	kingdom = "wei",
	maxhp = 3,
	order = 7,
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {ZhenLie, MiJi},
	last_word = "吾之家仇，何日得报？……",
	resource = "wangyi_v1",
}
table.insert(yjcm2012, WangYi)
end
--[[****************************************************************
	称号：曹魏的谋主
	武将：荀攸
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：奇策（阶段技）
	描述：你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。
]]--
QiCeCard = sgs.CreateSkillCard{
	name = "yj2QiCeCard",
	skill_name = "yj2QiCe",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	fixed = function(self)
		local card = sgs.Self:getTag("yj2QiCe"):toCard()
		local cardx = sgs.Sanguosha:cloneCard(card)
		if cardx then
			local subcards = self:getSubcards()
			for _,id in sgs.qlist(subcards) do
				cardx:addSubcard(id)
			end
			cardx:deleteLater()
			return cardx:targetFixed()
		end
		return false
	end,
	filter = function(self, targets, to_select)
		local card = sgs.Self:getTag("yj2QiCe"):toCard()
		local cardx = sgs.Sanguosha:cloneCard(card)
		if cardx then
			local subcards = self:getSubcards()
			for _,id in sgs.qlist(subcards) do
				cardx:addSubcard(id)
			end
			cardx:deleteLater()
			local selected = sgs.PlayerList()
			for _,p in ipairs(targets) do
				selected:append(p)
			end
			return cardx:targetFilter(selected, to_select, sgs.Self)
		end
		return false
	end,
	feasible = function(self, targets)
		local card = sgs.Self:getTag("yj2QiCe"):toCard()
		local cardx = sgs.Sanguosha:cloneCard(card)
		if cardx then
			local subcards = self:getSubcards()
			for _,id in sgs.qlist(subcards) do
				cardx:addSubcard(id)
			end
			cardx:deleteLater()
			local selected = sgs.PlayerList()
			for _,p in ipairs(targets) do
				selected:append(p)
			end
			return cardx:targetsFeasible(selected, sgs.Self)
		end
		return false
	end,
	on_validate = function(self, use)
		local name = self:getUserString()
		local card = sgs.Sanguosha:cloneCard(name)
		card:setSkillName("yj2QiCe")
		local subcards = self:getSubcards()
		for _,id in sgs.qlist(subcards) do
			card:addSubcard(id)
		end
		local source = use.from
		local available = card:isAvailable(source)
		if available then
			for _,p in sgs.qlist(use.to) do
				if source:isProhibited(p, card) then
					available = false
					break
				end
			end
		end
		if available then
			return card
		end
		card:deleteLater()
		return nil
	end,
}
QiCe = sgs.CreateLuaSkill{
	name = "yj2QiCe",
	translation = "奇策",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。",
	audio = {
		"臣有一计，定能一攻而破！",
		"方今天下大乱，智士劳心之时也！",
	},
	class = "ViewAsSkill",
	n = 999,
	guhuo_type = "r",
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == sgs.Self:getHandcardNum() then
			local card = sgs.Self:getTag("yj2QiCe"):toCard()
			if card then
				local vs_card = QiCeCard:clone()
				vs_card:setUserString(card:objectName())
				for _,c in ipairs(cards) do
					vs_card:addSubcard(c)
				end
				return vs_card
			end
		end
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#yj2QiCeCard") then
			return false
		end
		return true
	end,
}
--[[
	技能：智愚
	描述：每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。
]]--
ZhiYu = sgs.CreateLuaSkill{
	name = "yj2ZhiYu",
	translation = "智愚",
	description = "每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。",
	audio = {
		"将军苦苦追逼，是为何故？",
		"智可及，愚不可及！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("yj2ZhiYu", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("yj2ZhiXu")
			room:drawCards(player, 1, "yj2ZhiYu")
			if player:isKongcheng() then
				return false
			end
			room:showAllCards(player)
			local damage = data:toDamage()
			local source = damage.from
			if source and source:canDiscard(source, "h") then
				local handcards = player:getHandcards()
				local color = nil
				for _,card in sgs.qlist(handcards) do
					local c = card:getColor()
					if not color then
						color = c
					elseif color ~= c then
						return false
					end
				end
				room:askForDiscard(source, "yj2ZhiYu", 1, 1)
			end
		end
		return false
	end,
}
--武将信息：荀攸
XunYou = sgs.CreateLuaGeneral{
	name = "yj_ii_xunyou",
	real_name = "xunyou",
	translation = "荀攸",
	title = "曹魏的谋主",
	kingdom = "wei",
	maxhp = 3,
	order = 8,
	designer = "淬毒",
	cv = "烨子",
	illustrator = "魔鬼鱼",
	skills = {QiCe, ZhiYu},
	last_word = "主公何日再得无忧……",
	resource = "xunyou",
}
table.insert(yjcm2012, XunYou)
if new_version then
--[[****************************************************************
	称号：将门虎子
	武将：关兴张苞·改
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：父魂
	描述：你可以将两张手牌当普通【杀】使用或打出。每当你于出牌阶段内以此法使用【杀】造成伤害后，你拥有“武圣”、“咆哮”，直到回合结束。
]]--
FuHunVS = sgs.CreateLuaSkill{
	name = "yj2xFuHun",
	class = "ViewAsSkill",
	n = 2,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:addSubcard(cards[1])
			slash:addSubcard(cards[2])
			slash:setSkillName("yj2xFuHun")
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		if sgs.Slash_IsAvailable(player) then
			return player:getHandcardNum() >= 2
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if pattern == "slash" then
			return player:getHandcardNum() >= 2
		end
		return false
	end,
	effect_index = function(self, player, card)
		return 1
	end,
}
FuHun = sgs.CreateLuaSkill{
	name = "yj2xFuHun",
	translation = "父魂",
	description = "你可以将两张手牌当普通【杀】使用或打出。每当你于出牌阶段内以此法使用【杀】造成伤害后，你拥有“武圣”、“咆哮”，直到回合结束。",
	audio = {
		"吾父武名，声震海内！",
		"父魂佑我！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.EventPhaseChanging},
	view_as_skill = FuHunVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damage then
			if player:isAlive() and player:hasSkill("yj2xFuHun") then
				local damage = data:toDamage()
				local slash = damage.card
				if slash and slash:isKindOf("Slash") and slash:getSkillName() == "yj2xFuHun" then
					if player:getPhase() == sgs.Player_Play then
						room:broadcastSkillInvoke("yj2xFuHun")
						room:handleAcquireDetachSkills(player, "WuSheng|paoxiao")
						room:setPlayerFlag(player, "yj2xFuHunInvoked")
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive and player:hasFlag("yj2xFuHunInvoked") then
				room:setPlayerFlag(player, "-yj2xFuHunInvoked")
				room:handleAcquireDetachSkills(player, "-WuSheng|-paoxiao", true)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能：武圣
	描述：你可以将一张红色牌当普通【杀】使用或打出。
]]--
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
--武将信息：关兴张苞·改
GuanXingZhangBao = sgs.CreateLuaGeneral{
	name = "yj_ii_new_guanxingzhangbao",
	real_name = "guanxingzhangbao",
	translation = "关兴张苞·改",
	show_name = "关兴张苞",
	title = "将门虎子",
	kingdom = "shu",
	maxhp = 4,
	order = 5,
	crowded = true,
	cv = "喵小林，风叹息",
	illustrator = "HOOO",
	skills = FuHun,
	related_skills = {"WuSheng", "paoxiao"},
	last_word = "东吴未灭、父仇未报！可恨……可恨！",
	resource = "guanxingzhangbao_v2",
}
table.insert(yjcm2012, GuanXingZhangBao)
--[[****************************************************************
	称号：石城侯
	武将：韩当·改
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：弓骑（阶段技）
	描述：你可以弃置一张牌：若如此做，本回合你的攻击范围无限；若此牌为装备牌，你可以弃置一名其他角色的一张牌。
]]--
GongQiCard = sgs.CreateSkillCard{
	name = "yj2xGongQiCard",
	skill_name = "yj2xGongQi",
	target_fixed = true,
	will_throw = true,
	mute = true,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source, "InfinityAttackRange")
		local id = self:getSubcards():first()
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("EquipCard") then
			room:broadcastSkillInvoke("yj2xGongQi", 2)
			local victims = sgs.SPlayerList()
			local others = room:getOtherPlayers(source)
			for _,p in sgs.qlist(others) do
				if source:canDiscard(p, "he") then
					victims:append(p)
				end
			end
			if victims:isEmpty() then
				return
			end
			local victim = room:askForPlayerChosen(source, victims, "yj2xGongQi", "@yj2xGongQi", true)
			if victim then
				local id = room:askForCardChosen(source, victim, "he", "yj2xGongQi", false, sgs.Card_MethodDiscard)
				if id >= 0 then
					room:throwCard(id, victim, source)
				end
			end
		else
			room:broadcastSkillInvoke("yj2xGongQi", 1)
		end
	end,
}
GongQi = sgs.CreateLuaSkill{
	name = "yj2xGongQi",
	translation = "弓骑",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置一张牌：若如此做，本回合你的攻击范围无限；若此牌为装备牌，你可以弃置一名其他角色的一张牌。",
	audio = "弓马齐备，远射近突！",
	class = "OneCardViewAsSkill",
	filter_pattern = ".!",
	view_as = function(self, card)
		local vs_card = GongQiCard:clone()
		vs_card:addSubcard(card)
		return vs_card
	end,
	enabled_at_play = function(self, player)
		if player:isNude() then
			return false
		elseif player:hasUsed("#yj2xGongQiCard") then
			return false
		end
		return true
	end,
}
--[[
	技能：解烦（限定技）
	描述：出牌阶段，你可以选择一名角色，然后攻击范围内包含该角色的所有角色选择一项：弃置一张武器牌，或令该角色摸一张牌。
]]--
JieFanCard = sgs.CreateSkillCard{
	name = "yj2xJieFanCard",
	skill_name = "yj2xJieFan",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_use = function(self, room, source, targets)
		source:loseMark("@rescure")
		room:doSuperLightbox("yj_ii_new_handang", "yj2xJieFan")
		for _,target in ipairs(targets) do
			room:cardEffect(source, target, self)
		end
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		local index = 1
		if target:isGeneral("sunquan", true, true) then
			index = 2
		elseif target:isGeneral("sunce", true, true) then
			index = 2
		elseif target:isGeneral("sunjian", true, true) then
			index = 2
		end
		room:broadcastSkillInvoke("yj2xJieFan", index)
		local alives = room:getAlivePlayers()
		local prompt = string.format("@yj2xJieFan:%s:", target:objectName())
		local ai_data = sgs.QVariant()
		ai_data:setValue(target)
		for _,p in sgs.qlist(alives) do
			if p:inMyAttackRange(target) then
				if not room:askForCard(p, ".Weapon", prompt, ai_data) then
					room:drawCards(target, 1, "yj2xJieFan")
				end
			end
		end
	end,
}
JieFanVS = sgs.CreateLuaSkill{
	name = "yj2xJieFan",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return JieFanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@rescure") > 0
	end,
}
JieFan = sgs.CreateLuaSkill{
	name = "yj2xJieFan",
	translation = "解烦",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以选择一名角色，然后攻击范围内包含该角色的所有角色选择一项：弃置一张武器牌，或令该角色摸一张牌。",
	audio = {
		"解烦军至，此危自解！",
		"吾主莫慌！韩义公在此！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Limited,
	limit_mark = "@rescure",
	view_as_skill = JieFanVS,
}
--武将信息：韩当·改
HanDang = sgs.CreateLuaGeneral{
	name = "yj_ii_new_handang",
	real_name = "handang",
	translation = "韩当·改",
	show_name = "韩当",
	title = "石城侯",
	kingdom = "wu",
	maxhp = 4,
	order = 4,
	cv = "风叹息",
	illustrator = "DH",
	skills = {GongQi, JieFan},
	last_word = "我主堪忧，我主堪忧啊……",
	resource = "handang_v2",
	marks = {"@rescure"},
}
table.insert(yjcm2012, HanDang)
--[[****************************************************************
	称号：临危受命
	武将：马岱·改
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：潜袭
	描述：准备阶段开始时，你可以进行判定：若如此做，你令一名距离1的角色不能使用或打出与判定牌颜色相同的手牌，直到回合结束。
]]--
QianXiClear = sgs.CreateLuaSkill{
	name = "#yj2xQianXiClear",
	class = "TriggerSkill",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseChanging, sgs.Death},
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			local victim = death.who
			if victim and victim:objectName() == player:objectName() then
			else
				return false
			end
		end
		local room = player:getRoom()
		local alives = room:getAlivePlayers()
		for _,p in sgs.qlist(alives) do
			if p:getMark("yj2xQianXiTarget") > 0 then
				room:setPlayerMark(p, "yj2xQianXiTarget", 0)
				local pattern = p:getTag("yj2xQianXiPattern"):toString() or ""
				room:removePlayerCardLimitation(p, "use,response", pattern)
				p:removeTag("yj2xQianXiPattern")
				local mark = p:getTag("yj2xQianXiMark"):toString() or ""
				p:loseAllMarks(mark)
				p:removeTag("yj2xQianXiMark")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
QianXi = sgs.CreateLuaSkill{
	name = "yj2xQianXi",
	translation = "潜袭",
	description = "准备阶段开始时，你可以进行判定：若如此做，你令一名距离1的角色不能使用或打出与判定牌颜色相同的手牌，直到回合结束。",
	audio = "我敢杀你！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			if player:askForSkillInvoke("yj2xQianXi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("yj2xQianXi")
				room:notifySkillInvoked(player, "yj2xQianXi")
				local judge = sgs.JudgeStruct()
				judge.who = player
				judge.reason = "yj2xQianXi"
				judge.play_animation = false
				room:judge(judge)
				if player:isDead() then
					return false
				end
				local pattern, mark, color = nil, nil, nil
				local card = judge.card
				if card:isRed() then
					pattern = ".|red|.|hand$0"
					mark = "@yj2xQianXiRedMark"
					color = "no_suit_red"
				elseif card:isBlack() then
					pattern = ".|black|.|hand$0"
					mark = "@yj2xQianXiBlackMark"
					color = "no_suit_black"
				else
					return false
				end
				local alives = room:getAlivePlayers()
				local targets = sgs.SPlayerList()
				for _,p in sgs.qlist(alives) do
					if player:distanceTo(p) == 1 then
						targets:append(p)
					end
				end
				if targets:isEmpty() then
					return false
				end
				local victim = room:askForPlayerChosen(player, targets, "yj2xQianXi")
				if victim then
					room:setPlayerMark(victim, "yj2xQianXiTarget", 1)
					room:setPlayerCardLimitation(victim, "use,response", pattern, false)
					victim:gainMark(mark)
					victim:setTag("yj2xQianXiPattern", sgs.QVariant(pattern))
					victim:setTag("yj2xQianXiMark", sgs.QVariant(mark))
					local msg = sgs.LogMessage()
					msg.type = "#yj2xQianXi"
					msg.from = victim
					msg.arg = color
					msg.arg2 = "yj2xQianXi"
					room:sendLog(msg)
				end
			end
		end
		return false
	end,
	translations = {
		["@yj2xQianXiRedMark"] = "潜袭·红色",
		["@yj2xQianXiBlackMark"] = "潜袭·黑色",
		["#yj2xQianXi"] = "受技能“%arg2”影响，%from 本回合内不能使用或打出 %arg 手牌",
	},
	related_skills = QianXiClear,
}
--武将信息：马岱·改
MaDai = sgs.CreateLuaGeneral{
	name = "yj_ii_new_madai",
	real_name = "madai",
	translation = "马岱·改",
	show_name = "马岱",
	title = "临危受命",
	kingdom = "shu",
	maxhp = 4,
	order = 6,
	designer = "凌天翼",
	cv = "风叹息",
	illustrator = "大佬荣",
	skills = {"mashu", QianXi},
	last_word = "未能完成丞相遗命，辱没了我马家的威名啊……",
	resource = "madai_v2",
}
table.insert(yjcm2012, MaDai)
--[[****************************************************************
	称号：决意的巾帼
	武将：王异·改
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：贞烈
	描述：每当你成为其他角色的【杀】或非延时锦囊牌的目标后，你可以失去1点体力：若如此做，你弃置该角色的一张牌，此牌对你无效。
]]--
ZhenLie = sgs.CreateLuaSkill{
	name = "yj2xZhenLie",
	translation = "贞烈",
	description = "每当你成为其他角色的【杀】或非延时锦囊牌的目标后，你可以失去1点体力：若如此做，你弃置该角色的一张牌，此牌对你无效。",
	audio = {
		"血君父之大耻，虽丧身亦不惜！",
		"顾子而不行，不如先死矣！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUseStruct()
		local card = use.card
		if card:isKindOf("Slash") or card:isNDTrick() then
			local source = use.from
			if source and source:objectName() ~= player:objectName() and use.to:contains(player) then
				if player:askForSkillInvoke("yj2xZhenLie", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("yj2xZhenLie")
					room:loseHp(player)
					if player:isDead() then
						return false
					end
					table.insert(use.nullified_list, player:objectName())
					data:setValue(use)
					if player:canDiscard(source, "he") then
						local id = room:askForCardChosen(player, source, "he", "yj2xZhenLie", false, sgs.Card_MethodDiscard)
						if id >= 0 then
							room:throwCard(id, source, player)
						end
					end
				end
			end
		end
		return false
	end,
}
--[[
	技能：秘计
	描述：结束阶段开始时，若你已受伤，你可以摸至多X张牌，然后将等量的手牌任意分配给其他角色。（X为你已损失的体力值）
]]--
MiJi = sgs.CreateLuaSkill{
	name = "yj2xMiJi",
	translation = "秘计",
	description = "结束阶段开始时，若你已受伤，你可以摸至多X张牌，然后将等量的手牌任意分配给其他角色。（X为你已损失的体力值）",
	audio = {
		"有此九奇，可逐羌敌！",
		"屯兵逐超，得保冀城！",
		"救兵已到，乃解城围。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.ChoiceMade},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.ChoiceMade then
			local msg = data:toString()
			if string.find(msg, "Yiji:yj2xMiJi") then
				local items = msg:split(":")
				local ids = items[#items]
				local count = ids:split("+"):length()
				room:addPlayerMark(player, "yj2xMiJiCount", count)
			end
		elseif event == sgs.EventPhaseStart then
			if player:isAlive() and player:hasSkill("yj2xMiJi") then
				if player:getPhase() == sgs.Player_Finish and player:isWounded() then
					if player:askForSkillInvoke("yj2xMiJi", data) then
						local x = player:getLostHp()
						local choices = {}
						for i=1, x, 1 do
							table.insert(choices, tostring(i))
						end
						table.concat(choices, "+")
						local choice = room:askForChoice(player, "yj2xMiJi", choices)
						if player:isDead() then
							return false
						end
						room:broadcastSkillInvoke("yj2xMiJi")
						local num = tonumber(choice)
						room:drawCards(player, num, "yj2xMiJi")
						room:setPlayerMark(player, "yj2xMiJiCount", 0)
						while true do
							if player:isKongcheng() then
								return false
							end
							local n = player:getMark("yj2xMiJiCount")
							if n < num then
								local handcards = player:handCards()
								if not room:askForYiji(player, handcards, "yj2xMiJi", false, false, false, num - n) then
									break
								end
							else
								break
							end
						end
						local rest = num - player:getMark("yj2xMiJiCount")
						while true do
							if player:isKongcheng() then
								return false
							elseif rest <= 0 then
								return false
							end
							local others = room:getOtherPlayers(player)
							local count = others:length()
							local index = math.random(0, count - 1)
							local receiver = others:at(index)
							local handcards = player:handCards()
							local give = math.random(1, rest)
							rest = rest - give
							local dummy = sgs.DummyCard()
							for i=1, give, 1 do
								count = handcards:length()
								if count == 0 then
									break
								end
								index = math.random(0, count - 1)
								local id = handcards:at(index)
								dummy:addSubcard(id)
								handcards:removeOne(id)
							end
							if dummy:subcardsLength() > 0 then
								room:obtainCard(receiver, dummy, false)
								dummy:deleteLater()
							else
								dummy:deleteLater()
								return false
							end
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--武将信息：王异·改
WangYi = sgs.CreateLuaGeneral{
	name = "yj_ii_new_wangyi",
	real_name = "wangyi",
	translation = "王异·改",
	show_name = "王异",
	title = "决意的巾帼",
	kingdom = "wei",
	maxhp = 3,
	female = true,
	order = 2,
	cv = "蒲小猫",
	illustrator = "木美人",
	skills = {ZhenLie, MiJi},
	last_word = "吾之家仇，何日得报？……",
	resource = "wangyi_v2",
}
table.insert(yjcm2012, WangYi)
end
--[[****************************************************************
	一将成名2012武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "yjcm2012",
	translation = "二将成名",
	generals = yjcm2012,
}