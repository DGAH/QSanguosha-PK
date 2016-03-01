--[[
	太阳神三国杀武将单挑对战平台·经典标准版武将包
	武将总数：25
	武将一览：
		1、曹操（奸雄、护驾）
		2、司马懿（反馈、鬼才）
		3、夏侯惇（刚烈）
		4、张辽（突袭）
		5、许褚（裸衣）
		6、郭嘉（天妒、遗计）
		7、甄姬（倾国、洛神）
		8、刘备（仁德、激将）
		9、关羽（武圣）
		10、张飞（咆哮）
		11、诸葛亮（观星、空城）
		12、赵云（龙胆）
		13、马超（马术、铁骑）
		14、黄月英（集智、奇才）
		15、孙权（制衡、救援）
		16、甘宁（奇袭）
		17、吕蒙（克己）
		18、黄盖（苦肉）
		19、周瑜（英姿、反间）
		20、大乔（国色、流离）
		21、陆逊（谦逊、连营）
		22、孙尚香（结姻、枭姬）
		23、华佗（急救、青囊）
		24、吕布（无双）
		25、貂蝉（离间、闭月）
]]--
--[[****************************************************************
	称号：魏武帝
	武将：曹操
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：奸雄
	描述：每当你受到伤害后，你可以获得对你造成伤害的牌。
]]--
JianXiong = sgs.CreateLuaSkill{
	name = "JianXiong",
	translation = "奸雄",
	description = "每当你受到伤害后，你可以获得对你造成伤害的牌。",
	audio = "宁教我负天下人，休教天下人负我！",
	class = "TriggerSkill",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card and player:askForSkillInvoke("JianXiong", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("JianXiong")
			room:obtainCard(player, damage.card)
		end
		return false
	end,
}
--[[
	技能：护驾（主公技）[空壳技能]
	描述：每当你需要使用或打出一张【闪】时，你可以令其他魏势力角色打出一张【闪】，视为你使用或打出之。
]]--
HuJia = sgs.CreateLuaSkill{
	name = "HuJia",
	translation = "护驾",
	description = "<font color=\"yellow\"><b>主公技</b></font>，每当你需要使用或打出一张【闪】时，你可以令其他魏势力角色打出一张【闪】，视为你使用或打出之。",
}
--武将信息：曹操
CaoCao = sgs.CreateLuaGeneral{
	name = "caocao",
	translation = "曹操",
	title = "魏武帝",
	kingdom = "wei",
	order = 4,
	skills = {JianXiong, HuJia},
	last_word = "霸业未成、未成啊！",
	resource = "caocao",
}
--[[****************************************************************
	称号：狼顾之鬼
	武将：司马懿
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：反馈
	描述：每当你受到伤害后，你可以获得伤害来源的一张牌。
]]--
FanKui = sgs.CreateLuaSkill{
	name = "FanKui",
	translation = "反馈",
	description = "每当你受到伤害后，你可以获得伤害来源的一张牌。",
	audio = "下次注意点~",
	class = "TriggerSkill",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local source = damage.from
		if source and not source:isNude() then
			if player:askForSkillInvoke("FanKui", data) then
				local room = player:getRoom()
				local id = room:askForCardChosen(player, source, "he", "FanKui")
				if id >= 0 then
					room:obtainCard(player, id)
				end
			end
		end
		return false
	end,
}
--[[
	技能：鬼才
	描述：每当一名角色的判定牌生效前，你可以打出一张手牌代替之。
]]--
GuiCai = sgs.CreateLuaSkill{
	name = "GuiCai",
	translation = "鬼才",
	description = "每当一名角色的判定牌生效前，你可以打出一张手牌代替之。",
	audio = "天命？哈哈哈哈哈哈哈……",
	class = "TriggerSkill",
	events = {sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		local room = player:getRoom()
		local prompt = string.format("@@GuiCai:%s::%s", judge.who:objectName(), judge.reason)
		local card = room:askForCard(player, ".", prompt, data, sgs.Card_MethodResponse, judge.who, true, "GuiCai")
		if card then
			room:broadcastSkillInvoke("GuiCai")
			room:notifySkillInvoked(player, "GuiCai")
			room:retrial(card, player, judge, "GuiCai", false)
		end
		return false
	end,
}
--武将信息：司马懿
SiMaYi = sgs.CreateLuaGeneral{
	name = "simayi",
	translation = "司马懿",
	title = "狼顾之鬼",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	skills = {FanKui, GuiCai},
	last_word = "难道真的是天命难违？",
	resource = "simayi",
}
--[[****************************************************************
	称号：独眼的罗刹
	武将：夏侯惇
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：刚烈
	描述：每当你受到伤害后，你可以进行判定：若结果不为♥，则伤害来源选择一项：弃置两张手牌，或受到1点伤害。
]]--
GangLie = sgs.CreateLuaSkill{
	name = "GangLie",
	translation = "刚烈",
	description = "每当你受到伤害后，你可以进行判定：若结果不为红心，则伤害来源选择一项：弃置两张手牌，或受到1点伤害。",
	audio = "鼠辈，竟敢伤我？！",
	class = "TriggerSkill",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("GangLie", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("GangLie")
			local judge = sgs.JudgeStruct()
			judge.who = player
			judge.reason = "GangLie"
			judge.pattern = ".|heart"
			judge.good = false
			room:judge(judge)
			if judge:isGood() then
				local damage = data:toDamage()
				local source = damage.from
				if source and not room:askForDiscard(source, "GangLie", 2, 2, true, false, "@GangLie") then
					local ganglie = sgs.DamageStruct()
					ganglie.from = player
					ganglie.to = source
					ganglie.damage = 1
					ganglie.reason = "GangLie"
					room:damage(ganglie)
				end
			end
		end
		return false
	end,
}
--武将信息：夏侯惇
XiaHouDun = sgs.CreateLuaGeneral{
	name = "xiahoudun",
	translation = "夏侯惇",
	title = "独眼的罗刹",
	kingdom = "wei",
	order = 3,
	skills = GangLie,
	last_word = "两、两边都看不见啦……",
	resource = "xiahoudun",
}
--[[****************************************************************
	称号：前将军
	武将：张辽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：突袭
	描述：摸牌阶段开始时，你可以放弃摸牌并选择一至两名有手牌的其他角色：若如此做，你依次获得这些角色各一张手牌。
]]--
TuXiCard = sgs.CreateSkillCard{
	name = "TuXiCard",
	skill_name = "TuXi",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets < 2 then
			return not to_select:isKongcheng()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		local id = room:askForCardChosen(source, effect.to, "h", "TuXi")
		if id >= 0 then
			room:obtainCard(source, id)
		end
	end,
}
TuXiVS = sgs.CreateLuaSkill{
	name = "TuXi",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return TuXiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@TuXi"
	end,
}
TuXi = sgs.CreateLuaSkill{
	name = "TuXi",
	translation = "突袭",
	description = "摸牌阶段开始时，你可以放弃摸牌并选择一至两名有手牌的其他角色：若如此做，你依次获得这些角色各一张手牌。",
	audio = "没想到吧？",
	class = "TriggerSkill",
	events = {sgs.EventPhaseStart},
	view_as_skill = TuXiVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			local room = player:getRoom()
			if room:askForUseCard(player, "@@TuXi", "@TuXi") then
				room:broadcastSkillInvoke("TuXi")
				return true
			end
		end
		return false
	end,
}
--武将信息：张辽
ZhangLiao = sgs.CreateLuaGeneral{
	name = "zhangliao",
	translation = "张辽",
	title = "前将军",
	kingdom = "wei",
	order = 1,
	skills = TuXi,
	last_word = "真没想到……",
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
LuoYiBuff = sgs.CreateLuaSkill{
	name = "#LuoYiBuff",
	class = "TriggerSkill",
	global = true,
	events = {sgs.DamageCaused, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			local card = damage.card
			if card and player:getMark("LuoYiInvoked") > 0 then
				if card:isKindOf("Slash") or card:isKindOf("Duel") then
					room:notifySkillInvoked(player, "LuoYi")
					local msg = sgs.LogMessage()
					msg.type = "#LuoYiEffect"
					msg.from = player
					local count = damage.damage
					msg.arg = count
					count = count + 1
					msg.arg2 = count
					room:sendLog(msg)
					damage.damage = count
					data:setValue(damage)
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_NotActive then
				local alives = room:getAlivePlayers()
				for _,p in sgs.qlist(alives) do
					room:setPlayerMark(p, "LuoYiInvoked", 0)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
LuoYi = sgs.CreateLuaSkill{
	name = "LuoYi",
	translation = "裸衣",
	description = "摸牌阶段，你可以少摸一张牌：若如此做，本回合你使用【杀】或【决斗】对目标角色造成伤害时，此伤害+1。",
	audio = {
		"谁来与我大战三百回合？！",
		"呸！",
	},
	class = "TriggerSkill",
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("LuoYi", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("LuoYi")
			room:setPlayerMark(player, "LuoYiInvoked", 1)
			local n = data:toInt() - 1
			data:setValue(n)
		end
		return false
	end,
}
--武将信息：许褚
XuChu = sgs.CreateLuaGeneral{
	name = "xuchu",
	translation = "许褚",
	title = "虎痴",
	kingdom = "wei",
	order = 1,
	skills = LuoYi,
	last_word = "冷……好冷啊！",
	resource = "xuchu",
}
--[[****************************************************************
	称号：早终的先知
	武将：郭嘉
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天妒
	描述：每当你的判定牌生效后，你可以获得之。
]]--
TianDu = sgs.CreateLuaSkill{
	name = "TianDu",
	translation = "天妒",
	description = "每当你的判定牌生效后，你可以获得之。",
	audio = "就这样吧……",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.FinishRetrial},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("TianDu", data) then
			local judge = data:toJudge()
			local room = player:getRoom()
			room:broadcastSkillInvoke("TianDu")
			room:obtainCard(player, judge.card)
		end
		return false
	end,
}
--[[
	技能：遗计
	描述：每当你受到1点伤害后，你可以观看牌堆顶的两张牌，然后将这两张牌任意分配。
]]--
YiJi = sgs.CreateLuaSkill{
	name = "YiJi",
	translation = "遗计",
	description = "每当你受到1点伤害后，你可以观看牌堆顶的两张牌，然后将这两张牌任意分配。",
	audio = "也好……",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		for i=1, damage.damage, 1 do
			if player:askForSkillInvoke("YiJi", data) then
				room:broadcastSkillInvoke("YiJi")
				local guojia = sgs.SPlayerList()
				guojia:append(player)
				local yiji_cards = room:getNCards(2, false)
				local move = sgs.CardsMoveStruct(
					yiji_cards,
					nil,
					player,
					sgs.Player_PlaceTable,
					sgs.Player_PlaceHand,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), "YiJi", "")
				)
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true, moves, false, guojia)
				room:notifyMoveCards(false, moves, false, guojia)
				local origin_yiji = sgs.IntList()
				for _,id in sgs.qlist(yiji_cards) do
					origin_yiji:append(id)
				end
				while true do
					local alives = room:getAlivePlayers()
					if room:askForYiji(player, yiji_cards, "YiJi", true, false, true, -1, alives) then
						move = sgs.CardsMoveStruct(
							sgs.IntList(),
							player,
							nil,
							sgs.Player_PlaceHand,
							sgs.Player_PlaceTable,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), "YiJi", "")
						)
						for _,id in sgs.qlist(origin_yiji) do
							if room:getCardPlace(id) ~= sgs.Player_DrawPile then
								move.card_ids:append(id)
								yiji_cards:removeOne(id)
							end
						end
						origin_yiji = sgs.IntList()
						for _,id in sgs.qlist(yiji_cards) do
							origin_yiji:append(id)
						end
						moves = sgs.CardsMoveList()
						moves:append(move)
						room:notifyMoveCards(true, moves, false, guojia)
						room:notifyMoveCards(false, moves, false, guojia)
						if not player:isAlive() then
							return false
						end
					else
						break
					end
				end
				if not yiji_cards:isEmpty() then
					move = sgs.CardsMoveStruct(
						yiji_cards,
						player,
						nil,
						sgs.Player_PlaceHand,
						sgs.Player_PlaceTable,
						sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), "YiJi", "")
					)
					moves = sgs.CardsMoveList()
					moves:append(move)
					room:notifyMoveCards(true, moves, false, guojia)
					room:notifyMoveCards(false, moves, false, guojia)
					local dummy = sgs.DummyCard(yiji_cards)
					player:obtainCard(dummy, false)
					dummy:deleteLater()
				end
			else
				break
			end
		end
		return false
	end,
}
--武将信息：郭嘉
GuoJia = sgs.CreateLuaGeneral{
	name = "guojia",
	translation = "郭嘉",
	title = "早终的先知",
	kingdom = "wei",
	maxhp = 3,
	order = 4,
	skills = {TianDu, YiJi},
	last_word = "咳咳咳、呃咳咳咳……",
	resource = "guojia",
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
	描述：你可以将一张黑色手牌当【闪】使用或打出。
]]--
--[[
	技能：洛神
	描述：准备阶段开始时，你可以进行判定：若结果为黑色，判定牌生效后你获得之，然后你可以再次发动“洛神”。
]]--
--武将信息：甄姬
ZhenJi = sgs.CreateLuaGeneral{
	name = "classical_zhenji",
	real_name = "zhenji",
	translation = "甄姬",
	title = "薄幸的美人",
	kingdom = "wei",
	female = true,
	maxhp = 3,
	order = 8,
	hidden = true,
	skills = {"qingguo", "luoshen"},
	last_word = "悼良会之永绝兮，哀一逝而异乡……",
	resource = "zhenji",
}
--[[****************************************************************
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：仁德
	描述：出牌阶段，你可以将至少一张手牌任意分配给其他角色。你于本阶段内以此法给出的手牌首次达到两张或更多后，你回复1点体力。
]]--
RenDeCard = sgs.CreateSkillCard{
	name = "RenDeCard",
	skill_name = "RenDe",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local mark = source:getMark("RenDeCount")
		room:addPlayerMark(source, "RenDeCount", self:subcardsLength())
		room:obtainCard(target, self)
		if mark < 2 and source:getMark("RenDeCount") >= 2 then
			local recover = sgs.RecoverStruct()
			recover.who = source
			recover.recover = 1
			room:recover(source, recover)
		end
	end,
}
RenDeVS = sgs.CreateLuaSkill{
	name = "RenDe",
	class = "ViewAsSkill",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local card = RenDeCard:clone()
			for _,c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end,
}
RenDe = sgs.CreateLuaSkill{
	name = "RenDe",
	translation = "仁德",
	description = "出牌阶段，你可以将至少一张手牌任意分配给其他角色。你于本阶段内以此法给出的手牌首次达到两张或更多后，你回复1点体力。",
	audio = {
		"惟贤惟德，能服于人。",
		"以德服人。",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = RenDeVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			room:setPlayerMark(player, "RenDeCount", 0)
		end
		return false
	end,
}
--[[
	技能：激将（主公技）[空壳技能]
	描述：每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。
]]--
JiJiang = sgs.CreateLuaSkill{
	name = "JiJiang",
	translation = "激将",
	description = "<font color=\"yellow\"><b>主公技</b></font>，每当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】，视为你使用或打出之。",
}
--武将信息：刘备
LiuBei = sgs.CreateLuaGeneral{
	name = "liubei",
	translation = "刘备",
	title = "乱世的枭雄",
	kingdom = "shu",
	order = 2,
	skills = {RenDe, JiJiang},
	last_word = "这就是桃园么？",
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
WuSheng = sgs.CreateLuaSkill{
	name = "WuSheng",
	translation = "武圣",
	description = "你可以将一张红色牌当普通【杀】使用或打出。",
	audio = {
		"关羽在此，尔等受死！",
		"看尔乃插标卖首。",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isRed() then
			return true
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local slash = sgs.Sanguosha:cloneCard("slash", suit, point)
			slash:addSubcard(card)
			slash:setSkillName("WuSheng")
			return slash
		end
	end,
	enabled_at_play = function(self, player)
		if player:isNude() then
			return false
		elseif sgs.Slash_IsAvailable(player) then
			return true
		end
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end,
}
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "guanyu",
	translation = "关羽",
	title = "美髯公",
	kingdom = "shu",
	order = 4,
	skills = WuSheng,
	last_word = "什么？此地叫麦城？",
	resource = "guanyu",
}
--[[****************************************************************
	称号：万夫不当
	武将：张飞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：咆哮
	描述：出牌阶段，你使用【杀】无次数限制。
]]--
--武将信息：张飞
ZhangFei = sgs.CreateLuaGeneral{
	name = "zhangfei",
	translation = "张飞",
	title = "万夫不当",
	kingdom = "shu",
	order = 2,
	skills = "paoxiao",
	last_word = "实在是杀不动啦！",
	resource = "zhangfei",
}
--[[****************************************************************
	称号：迟暮的丞相
	武将：诸葛亮
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：观星
	描述：准备阶段开始时，你可以观看牌堆顶的X张牌，然后将任意数量的牌置于牌堆顶，将其余的牌置于牌堆底。（X为存活角色数且至多为5）
]]--
--[[
	技能：空城（锁定技）
	描述：若你没有手牌，你不能被选择为【杀】或【决斗】的目标。
]]--
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "classical_zhugeliang",
	real_name = "zhugeliang",
	translation = "诸葛亮",
	title = "迟暮的丞相",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	hidden = true,
	skills = {"guanxing", "kongcheng"},
	last_word = "将星陨落，天命难违……",
	resource = "zhugeliang",
}
--[[****************************************************************
	称号：少年将军
	武将：赵云
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：龙胆
	描述：你可以将一张【杀】当【闪】使用或打出，或将一张【闪】当普通【杀】使用或打出。
]]--
--武将信息：赵云
ZhaoYun = sgs.CreateLuaGeneral{
	name = "classical_zhaoyun",
	real_name = "zhaoyun",
	translation = "赵云",
	title = "少年将军",
	kingdom = "shu",
	order = 3,
	hidden = true,
	skills = "longdan",
	last_word = "这就是失败的滋味吗？",
	resource = "zhaoyun",
}
--[[****************************************************************
	称号：一骑当千
	武将：马超
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术（锁定技）
	描述：你与其他角色的距离-1。
]]--
--[[
	技能：铁骑
	描述：每当你指定【杀】的目标后，你可以进行判定：若结果为红色，该角色不能使用【闪】响应此【杀】。
]]--
TieJi = sgs.CreateLuaSkill{
	name = "TieJi",
	translation = "铁骑",
	description = "每当你指定【杀】的目标后，你可以进行判定：若结果为红色，该角色不能使用【闪】响应此【杀】。",
	audio = "全军突击！",
	class = "TriggerSkill",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetSpecifying},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local slash = use.card
		if slash and slash:isKindOf("Slash") then
			local room = player:getRoom()
			local key = "Jink_"..slash:toString()
			local jinkList = player:getTag(key):toIntList()
			local newJinkList = sgs.IntList()
			for index, target in sgs.qlist(use.to) do
				local jink = jinkList:at(index)
				local prompt = string.format("invoke:%s", target:objectName())
				if player:askForSkillInvoke("TieJi", sgs.QVariant(prompt)) then
					room:broadcastSkillInvoke("TieJi")
					local judge = sgs.JudgeStruct()
					judge.who = player
					judge.reason = "TieJi"
					judge.pattern = ".|red"
					judge.good = true
					room:judge(judge)
					if judge:isGood() then
						jink = 0
					end
				end
				newJinkList:append(jink)
			end
			local tag = sgs.QVariant()
			tag:setValue(newJinkList)
			player:setTag(key, tag)
		end
		return false
	end,
}
--武将信息：马超
MaChao = sgs.CreateLuaGeneral{
	name = "machao",
	translation = "马超",
	title = "一骑当千",
	kingdom = "shu",
	order = 7,
	skills = {"mashu", TieJi},
	last_word = "（马蹄声）",
	resource = "machao",
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
JiZhi = sgs.CreateLuaSkill{
	name = "JiZhi",
	translation = "集智",
	description = "每当你使用一张非延时锦囊牌时，你可以摸一张牌。",
	audio = "哼~",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isNDTrick() then
			if player:askForSkillInvoke("JiZhi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("JiZhi")
				room:drawCards(player, 1, "JiZhi")
			end
		end
		return false
	end,
}
--[[
	技能：奇才（锁定技）
	描述：你使用锦囊牌无距离限制。
]]--
QiCai = sgs.CreateLuaSkill{
	name = "QiCai",
	translation = "奇才",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你使用锦囊牌无距离限制。",
	class = "TargetModSkill",
	distance_limit_func = function(self, player, card)
		if card:isKindOf("TrickCard") and player:hasSkill("QiCai") then
			return 1000
		end
		return 0
	end,
}
--武将信息：黄月英
HuangYueYing = sgs.CreateLuaGeneral{
	name = "huangyueying",
	translation = "黄月英",
	title = "归隐的杰女",
	kingdom = "shu",
	female = true,
	maxhp = 3,
	order = 5,
	skills = {JiZhi, QiCai},
	last_word = "亮！",
	resource = "huangyueying",
}
--[[****************************************************************
	称号：年轻的贤君
	武将：孙权
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：制衡（阶段技）
	描述：你可以弃置至少一张牌：若如此做，你摸等量的牌。
]]--
--[[
	技能：救援（主公技、锁定技）[空壳技能]
	描述：若你处于濒死状态，其他吴势力角色对你使用【桃】时，你回复的体力+1。
]]--
--武将信息：孙权
SunQuan = sgs.CreateLuaGeneral{
	name = "classical_sunquan",
	real_name = "sunquan",
	translation = "孙权",
	title = "年轻的贤君",
	kingdom = "wu",
	order = 10,
	hidden = true,
	skills = "zhiheng+jiuyuan",
	last_word = "父亲、大哥，仲谋愧矣……",
	resource = "sunquan"
}
--[[****************************************************************
	称号：锦帆游侠
	武将：甘宁
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：奇袭
	描述：你可以将一张黑色牌当【过河拆桥】使用。
]]--
QiXi = sgs.CreateLuaSkill{
	name = "QiXi",
	translation = "奇袭",
	description = "你可以将一张黑色牌当【过河拆桥】使用。",
	audio = {
		"接招吧！",
		"你的牌太多了！",
	},
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
			local trick = sgs.Sanguosha:cloneCard("dismantlement", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("QiXi")
			return trick
		end
	end,
}
--武将信息：甘宁
GanNing = sgs.CreateLuaGeneral{
	name = "ganning",
	translation = "甘宁",
	title = "锦帆游侠",
	kingdom = "wu",
	order = 6,
	skills = QiXi,
	last_word = "二十年后，又是一条好汉！",
	resource = "ganning",
}
--[[****************************************************************
	称号：白衣渡江
	武将：吕蒙
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：克己
	描述：若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。
]]--
KeJiRecord = sgs.CreateLuaSkill{
	name = "#KeJiRecord",
	class = "TriggerSkill",
	global = true,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			if event == sgs.EventPhaseStart then
				room:setPlayerMark(player, "KeJiSlash", 0)
				return false
			end
			local slash = nil
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				slash = use.card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				slash = response.m_card
			end
			if slash and slash:isKindOf("Slash") then
				room:setPlayerMark(player, "KeJiSlash", 1)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive()
	end,
}
KeJi = sgs.CreateLuaSkill{
	name = "KeJi",
	translation = "克己",
	description = "若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。",
	audio = {
		"我忍！",
		"君子藏器于身，待时而动！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Discard then
			if player:isSkipped(sgs.Player_Discard) then
				return false
			elseif player:getMark("KeJiSlash") > 0 then
				return false
			elseif player:askForSkillInvoke("KeJi", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("KeJi")
				player:skip(sgs.Player_Discard)
			end
		end
		return false
	end,
	related_skills = KeJiRecord,
}
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "lvmeng",
	translation = "吕蒙",
	title = "白衣渡江",
	kingdom = "wu",
	order = 5,
	skills = KeJi,
	last_word = "呃……被看穿了吗？",
	resource = "lvmeng",
}
--[[****************************************************************
	称号：轻身为国
	武将：黄盖
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：苦肉
	描述：出牌阶段，你可以失去1点体力：若如此做，你摸两张牌。
]]--
KuRouCard = sgs.CreateSkillCard{
	name = "KuRouCard",
	skill_name = "KuRou",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		room:loseHp(source)
		if source:isAlive() then
			room:drawCards(source, 2, "KuRou")
		end
	end,
}
KuRou = sgs.CreateLuaSkill{
	name = "KuRou",
	translation = "苦肉",
	description = "出牌阶段，你可以失去1点体力：若如此做，你摸两张牌。",
	audio = "请鞭挞我吧！公瑾……",
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return KuRouCard:clone()
	end,
}
--武将信息：黄盖
HuangGai = sgs.CreateLuaGeneral{
	name = "huanggai",
	translation = "黄盖",
	title = "轻身为国",
	kingdom = "wu",
	order = 3,
	skills = KuRou,
	last_word = "失血过多了……",
	resource = "huanggai",
}
--[[****************************************************************
	称号：大都督
	武将：周瑜
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：英姿
	描述：摸牌阶段，你可以额外摸一张牌。
]]--
YingZi = sgs.CreateLuaSkill{
	name = "YingZi",
	translation = "英姿",
	description = "摸牌阶段，你可以额外摸一张牌。",
	audio = {
		"喝哈哈哈哈……",
		"汝等看好了……",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke("YingZi", data) then
			local room = player:getRoom()
			room:broadcastSkillInvoke("YingZi")
			local n = data:toInt() + 1
			data:setValue(n)
		end
		return false
	end,
}
--[[
	技能：反间（阶段技）
	描述：你可以令一名其他角色选择一种花色，然后正面朝上获得你的一张手牌。若此牌花色与该角色所选花色不同，该角色受到1点伤害。
]]--
FanJianCard = sgs.CreateSkillCard{
	name = "FanJianCard",
	skill_name = "FanJian",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local suit = room:askForSuit(target, "FanJian")
		local id = room:askForCardChosen(target, source, "h", "FanJian")
		if id >= 0 then
			room:obtainCard(target, id)
			local card = sgs.Sanguosha:getCard(id)
			if card:getSuit() ~= suit then
				local damage = sgs.DamageStruct()
				damage.from = source
				damage.to = target
				damage.damage = 1
				damage.reason = "FanJian"
				room:damage(damage)
			end
		end
	end,
}
FanJian = sgs.CreateLuaSkill{
	name = "FanJian",
	translation = "反间",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令一名其他角色选择一种花色，然后正面朝上获得你的一张手牌。若此牌花色与该角色所选花色不同，该角色受到1点伤害。",
	audio = {
		"挣扎吧，在血和暗的深渊里！",
		"痛苦吧，在仇与恨的地狱中！",
	},
	class = "ZeroCardViewAsSkill",
	view_as = function(self)
		return FanJianCard:clone()
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#FanJianCard") then
			return false
		end
		return true
	end,
}
--武将信息：周瑜
ZhouYu = sgs.CreateLuaGeneral{
	name = "zhouyu",
	translation = "周瑜",
	title = "大都督",
	kingdom = "wu",
	maxhp = 3,
	order = 7,
	skills = {YingZi, FanJian},
	last_word = "既生瑜，何生……",
	resource = "zhouyu",
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
GuoSe = sgs.CreateLuaSkill{
	name = "GuoSe",
	translation = "国色",
	description = "你可以将一张方块牌当【乐不思蜀】使用。",
	audio = {
		"请休息吧！",
		"你累了~",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:getSuit() == sgs.Card_Diamond
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local trick = sgs.Sanguosha:cloneCard("indulgence", suit, point)
			trick:addSubcard(card)
			trick:setSkillName("GuoSe")
			return trick
		end
	end,
}
--[[
	技能：流离[空壳技能]
	描述：每当你成为【杀】的目标时，你可以弃置一张牌并选择你攻击范围内为此【杀】合法目标（无距离限制）的一名角色：若如此做，该角色代替你成为此【杀】的目标。
]]--
LiuLi = sgs.CreateLuaSkill{
	name = "LiuLi",
	translation = "流离",
	description = "每当你成为【杀】的目标时，你可以弃置一张牌并选择你攻击范围内为此【杀】合法目标（无距离限制）的一名角色：若如此做，该角色代替你成为此【杀】的目标。",
}
--武将信息：大乔
DaQiao = sgs.CreateLuaGeneral{
	name = "daqiao",
	translation = "大乔",
	title = "矜持之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 1,
	skills = {GuoSe, LiuLi},
	last_word = "伯符……我去了……",
	resource = "daqiao",
}
--[[****************************************************************
	称号：儒生雄才
	武将：陆逊
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：谦逊（锁定技）
	描述：你不能被选择为【顺手牵羊】与【乐不思蜀】的目标。
]]--
QianXun = sgs.CreateLuaSkill{
	name = "QianXun",
	translation = "谦逊",
	description = "你不能被选择为【顺手牵羊】与【乐不思蜀】的目标。",
	class = "ProhibitSkill",
	is_prohibited = function(self, from, to, card)
		if to:hasSkill("QianXun") then
			return card:isKindOf("Snatch") or card:isKindOf("Indulgence")
		end
		return false
	end,
}
--[[
	技能：连营
	描述：每当你失去最后的手牌后，你可以摸一张牌。
]]--
LianYing = sgs.CreateLuaSkill{
	name = "LianYing",
	translation = "连营",
	description = "每当你失去最后的手牌后，你可以摸一张牌。",
	audio = "牌不是万能的，但是没牌是万万不能的！",
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.is_last_handcard then
			local source = move.from
			if source and source:objectName() == player:objectName() then
				if player:askForSkillInvoke("LianYing", data) then
					local room = player:getRoom()
					room:broadcastSkillInvoke("LianYing")
					room:drawCards(player, 1, "LianYing")
				end
			end
		end
		return false
	end,
}
--武将信息：陆逊
LuXun = sgs.CreateLuaGeneral{
	name = "luxun",
	translation = "陆逊",
	title = "儒生雄才",
	kingdom = "wu",
	maxhp = 3,
	order = 2,
	skills = {QianXun, LianYing},
	last_word = "我还是太年轻了……",
	resource = "luxun",
}
--[[****************************************************************
	称号：弓腰姬
	武将：孙尚香
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：结姻（阶段技）
	描述：你可以弃置两张手牌并选择一名已受伤的男性角色：若如此做，你和该角色各回复1点体力。
]]--
JieYinCard = sgs.CreateSkillCard{
	name = "JieYinCard",
	skill_name = "JieYin",
	target_fixed = false,
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:isWounded() and to_select:isMale()
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		if source:isFemale() then
			if target:getGeneral():getRealName() == "liubei" then
				room:broadcastSkillInvoke("JieYin", 1)
			else
				room:broadcastSkillInvoke("JieYin", 2)
			end
		else
			if target:objectName() == source:objectName() then
				room:broadcastSkillInvoke("JieYin", 5)
			elseif target:getHp() > source:objectName() then
				room:broadcastSkillInvoke("JieYin", 4)
			else
				room:broadcastSkillInvoke("JieYin", 3)
			end
		end
		local recover = sgs.RecoverStruct()
		recover.who = source
		recover.recover = 1
		room:recover(source, recover, true)
		room:recover(target, recover, true)
	end,
}
JieYin = sgs.CreateLuaSkill{
	name = "JieYin",
	translation = "结姻",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以弃置两张手牌并选择一名已受伤的男性角色：若如此做，你和该角色各回复1点体力。",
	audio = {
		"夫君，身体要紧！",
		"他好，我也好~",
		"贤弟脸似花含露，玉树流光照后庭。",
		"愿为西南风，长逝入君怀。",
		"我有嘉宾，鼓瑟吹箫。",
	},
	class = "ViewAsSkill",
	n = 2,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local card = JieYinCard:clone()
			card:addSubcard(cards[1])
			card:addSubcard(cards[2])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#JieYinCard") then
			return false
		elseif player:getHandcardNum() < 2 then
			return false
		end
		return true
	end,
}
--[[
	技能：枭姬
	描述：每当你失去一张装备区的装备牌后，你可以摸两张牌。
]]--
XiaoJi = sgs.CreateLuaSkill{
	name = "XiaoJi",
	translation = "枭姬",
	description = "每当你失去一张装备区的装备牌后，你可以摸两张牌。",
	audio = {
		"哼！",
		"看我的厉害！",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local source = move.from
		if source and source:objectName() == player:objectName() then
			local count = 0
			for index, place in sgs.qlist(move.from_places) do
				if place == sgs.Player_PlaceEquip then
					count = count + 1
				end
			end
			if count == 0 then
				return false
			end
			local room = player:getRoom()
			for i=1, count, 1 do
				if player:askForSkillInvoke("XiaoJi", data) then
					room:broadcastSkillInvoke("XiaoJi")
					room:drawCards(player, 2, "XiaoJi")
				else
					break
				end
			end
		end
		return false
	end,
}
--武将信息：孙尚香
SunShangXiang = sgs.CreateLuaGeneral{
	name = "sunshangxiang",
	translation = "孙尚香",
	title = "弓腰姬",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 4,
	skills = {JieYin, XiaoJi},
	last_word = "不……还不可以死……",
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
JiJiu = sgs.CreateLuaSkill{
	name = "JiJiu",
	translation = "急救",
	description = "你的回合外，你可以将一张红色牌当【桃】使用。",
	audio = {
		"别紧张！有老夫呢！",
		"救人一命，胜造七级浮屠。",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isRed()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local peach = sgs.Sanguosha:cloneCard("peach", suit, point)
			peach:addSubcard(card)
			peach:setSkillName("JiJiu")
			return peach
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		if player:getPhase() == sgs.Player_NotActive then
			if player:hasFlag("Global_PreventPeach") then
				return false
			elseif string.find(pattern, "peach") then
				return true
			end
		end
		return false
	end,
}
--[[
	技能：青囊（阶段技）
	描述：你可以弃置一张手牌并选择一名已受伤的角色：若如此做，该角色回复1点体力。
]]--
QingNangCard = sgs.CreateSkillCard{
	name = "QingNangCard",
	skill_name = "QingNang",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:isWounded()
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		local recover = sgs.RecoverStruct()
		recover.who = effect.from
		recover.recover = 1
		recover.card = self
		room:recover(target, recover)
	end,
}
QingNang = sgs.CreateLuaSkill{
	name = "QingNang",
	translation = "青囊",
	description = "<font color=\" green\"><b>阶段技</b></font>，你可以弃置一张手牌并选择一名已受伤的角色：若如此做，该角色回复1点体力。",
	audio = {
		"早睡早起，方能养生！",
		"越老越要补啊！",
	},
	class = "ViewAsSkill",
	n = 1,
	view_filter = function(self, targets, to_select)
		if not to_select:isEquipped() then
			return sgs.Self:canDiscard(sgs.Self, to_select:getEffectiveId())
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = QingNangCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:isKongcheng() then
			return false
		elseif player:hasUsed("#QingNangCard") then
			return false
		end
		return true
	end,
}
--武将信息：华佗
HuaTuo = sgs.CreateLuaGeneral{
	name = "huatuo",
	translation = "华佗",
	title = "神医",
	kingdom = "qun",
	maxhp = 3,
	order = 5,
	skills = {JiJiu, QingNang},
	last_word = "医者不能自医啊……",
	resource = "huatuo",
}
--[[****************************************************************
	称号：武的化身
	武将：吕布
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：无双（锁定技）
	描述：每当你指定【杀】的目标后，目标角色须使用两张【闪】抵消此【杀】。你指定或成为【决斗】的目标后，与你【决斗】的角色每次须连续打出两张【杀】。
]]--
--武将信息：吕布
LvBu = sgs.CreateLuaGeneral{
	name = "lvbu",
	translation = "吕布",
	title = "武的化身",
	kingdom = "qun",
	order = 7,
	skills = "wushuang",
	last_word = "不可能！",
	resource = "lvbu",
}
--[[****************************************************************
	称号：绝世的舞姬
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：离间（阶段技）[空壳技能]
	描述：你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】，此【决斗】不能被【无懈可击】响应。
]]--
LiJian = sgs.CreateLuaSkill{
	name = "LiJian",
	translation = "离间",
	description = "你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】，此【决斗】不能被【无懈可击】响应。",
}
--[[
	技能：闭月
	描述：结束阶段开始时，你可以摸一张牌。
]]--
BiYue = sgs.CreateLuaSkill{
	name = "BiYue",
	translation = "闭月",
	description = "结束阶段开始时，你可以摸一张牌。",
	audio = {
		"失礼啦~",
		"羡慕吧？",
	},
	class = "TriggerSkill",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:askForSkillInvoke("BiYue", data) then
				local room = player:getRoom()
				room:broadcastSkillInvoke("BiYue")
				room:drawCards(player, 1, "BiYue")
			end
		end
		return false
	end,
}
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "diaochan",
	translation = "貂蝉",
	title = "绝世的舞姬",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 7,
	skills = {LiJian, BiYue},
	last_word = "父亲大人……对不起……",
	resource = "diaochan",
}
--[[****************************************************************
	经典标准版武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "classical",
	translation = "标准版",
	generals = {
		CaoCao, SiMaYi, XiaHouDun, ZhangLiao, XuChu, GuoJia, ZhenJi,
		LiuBei, GuanYu, ZhangFei, ZhuGeLiang, ZhaoYun, MaChao, HuangYueYing,
		SunQuan, GanNing, LvMeng, HuangGai, ZhouYu, DaQiao, LuXun, SunShangXiang,
		HuaTuo, LvBu, DiaoChan,
	},
}