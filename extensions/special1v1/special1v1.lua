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
XieChan = sgs.CreateLuaSkill{
	name = "kofXieChan",
	translation = "挟缠",
	description = "<font color=\"red\"><b>限定技</b></font>，出牌阶段，你可以与对手拼点：若你赢，视为你对对手使用一张【决斗】；若你没赢，视为对手对你使用一张【决斗】。",
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
CangJi = sgs.CreateLuaSkill{
	name = "kofCangJi",
	translation = "藏机",
	description = "你死亡时，你可以将装备区的所有牌移出游戏：若如此做，你的下个武将登场时，将这些牌置于装备区。",
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
ManYi = sgs.CreateLuaSkill{
	name = "kofManYi",
	translation = "蛮裔",
	description = "你登场时，你可以视为使用一张【南蛮入侵】。【南蛮入侵】对你无效。",
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
}
--[[
	技能：博图
	描述：你的回合结束后，若你于本回合出牌阶段使用了四种花色的牌，你可以进行一个额外的回合。
]]--
BoTu = sgs.CreateLuaSkill{
	name = "kofBoTu",
	translation = "博图",
	description = "你的回合结束后，若你于本回合出牌阶段使用了四种花色的牌，你可以进行一个额外的回合。",
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
}
--[[
	技能：枭姬
	描述：每当你失去一张装备区的牌后，你可以选择一项：摸两张牌，或回复1点体力。
]]--
XiaoJi = sgs.CreateLuaSkill{
	name = "kofXiaoJi",
	translation = "枭姬",
	description = "每当你失去一张装备区的牌后，你可以选择一项：摸两张牌，或回复1点体力。",
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
PuJi = sgs.CreateLuaSkill{
	name = "kofPuJi",
	translation = "普济",
	description = "<font color=\"green\"><b>阶段技</b></font>，若你与对手均有牌，你可以弃置你与其各一张牌，然后以此法弃置黑桃牌的角色摸一张牌。",
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
MouZhu = sgs.CreateLuaSkill{
	name = "kofMouZhu",
	translation = "谋诛",
	description = "<font color=\"green\"><b>阶段技</b></font>，你可以令对手交给你一张手牌：若你的手牌多于对手，对手选择一项：视为对你使用一张无距离限制的【杀】，或视为对你使用一张【决斗】。",
}
--[[
	技能：延祸
	描述：你死亡时，你可以依次弃置对手的X张牌。（X为你死亡时的牌数）
]]--
YanHuo = sgs.CreateLuaSkill{
	name = "kofYanHuo",
	translation = "延祸",
	description = "你死亡时，你可以依次弃置对手的X张牌。（X为你死亡时的牌数）",
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
	name = "kof",
	translation = "挫锐",
	description = "<font color=\"blue\"><b>锁定技</b></font>，你的起始手牌为X+2张。你跳过你的第一个判定阶段。（X为你的备选武将数）",
}
--[[
	技能：裂围
	描述：对手死亡时，你可以摸三张牌。
]]--
LieWei = sgs.CreateLuaSkill{
	name = "kofLieWei",
	translation = "裂围",
	description = "对手死亡时，你可以摸三张牌。",
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
NiLuan = sgs.CreateLuaSkill{
	name = "kofNiLuan",
	translation = "逆乱",
	description = "对手的结束阶段开始时，若其体力值大于你的体力值，或其于出牌阶段内对你使用过【杀】，你可以将一张黑色牌当【杀】对其使用。",
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