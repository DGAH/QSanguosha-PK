--[[
	太阳神三国杀武将单挑对战平台·火武将包
	武将总数：8
	武将一览：
		1、典韦（强袭）
		2、荀彧（驱虎、节命）
		3、庞统（连环、涅槃）
		4、诸葛亮（八阵、火计、看破）
		5、太史慈（天义）
		6、袁绍（乱击、血裔）
		7、颜良文丑（双雄）
		8、庞德（马术、猛进）
]]--
--[[****************************************************************
	称号：古之恶来
	武将：典韦
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：强袭
	描述：
]]--
--武将信息：典韦
DianWei = sgs.CreateLuaGeneral{
	name = "dianwei",
	translation = "典韦",
	title = "古之恶来",
	kingdom = "wei",
	order = 6,
	cv = "褪色",
	illustrator = "小冷",
	last_word = "主公……我就到……这儿了……",
	resource = "dianwei",
}
--[[****************************************************************
	称号：王佐之才
	武将：荀彧
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：
	描述：
]]--
--[[
	技能：
	描述：
]]--
--武将信息：荀彧
XunYu = sgs.CreateLuaGeneral{
	name = "xunyu",
	translation = "荀彧",
	title = "王佐之才",
	kingdom = "wei",
	maxhp = 3,
	order = 2,
	cv = "听雨",
	illustrator = "LiuHeng",
	last_word = "身为汉臣，至死不渝。",
	resource = "xunyu",
}
--[[****************************************************************
	称号：凤雏
	武将：庞统
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：连环
	描述：
]]--
--[[
	技能：涅槃
	描述：
]]--
--武将信息：庞统
PangTong = sgs.CreateLuaGeneral{
	name = "pangtong",
	translation = "庞统",
	title = "凤雏",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "无花有酒",
	last_word = "落凤坡？此地不利于吾。",
	resource = "pangtong",
}
--[[****************************************************************
	称号：卧龙
	武将：诸葛亮
	势力：蜀
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：八阵
	描述：
]]--
--[[
	技能：火计
	描述：
]]--
--[[
	技能：看破
	描述：
]]--
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "wolong",
	real_name = "zhugeliang",
	translation = "卧龙诸葛亮",
	title = "卧龙",
	show_name = "诸葛亮",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	cv = "彗星",
	illustrator = "北",
	last_word = "悠悠苍天，曷此其极……",
	resource = "zhugeliang",
}
--[[****************************************************************
	称号：笃烈之士
	武将：太史慈
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：天义
	描述：
]]--
--武将信息：太史慈
TaiShiCi = sgs.CreateLuaGeneral{
	name = "taishici",
	translation = "太史慈",
	title = "笃烈之士",
	kingdom = "wu",
	order = 4,
	cv = "口渴口樂",
	illustrator = "Tuu.",
	last_word = "今所志未遂，奈何死乎？",
	resource = "taishici",
}
--[[****************************************************************
	称号：高贵的名门
	武将：袁绍
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：乱击
	描述：
]]--
--[[
	技能：血裔
	描述：
]]--
--武将信息：袁绍
YuanShao = sgs.CreateLuaGeneral{
	name = "yuanshao",
	translation = "袁绍",
	title = "高贵的名门",
	kingdom = "qun",
	order = 1,
	cv = "耗子王",
	illustrator = "Sonia Tang",
	last_word = "天不助袁哪！",
	resource = "yuanshao",
}
--[[****************************************************************
	称号：虎狼兄弟
	武将：颜良文丑
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：双雄
	描述：
]]--
--武将信息：颜良文丑
YanLiangWenChou = sgs.CreateLuaGeneral{
	name = "yanliangwenchou",
	translation = "颜良文丑",
	title = "虎狼兄弟",
	kingdom = "qun",
	crowded = true,
	order = 6,
	cv = "墨染の飞猫，霸气爷们",
	last_word = "生不逢时啊！",
	resource = "yanliangwenchou",
}
--[[****************************************************************
	称号：人马一体
	武将：庞德
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术
	描述：
]]--
--[[
	技能：猛进
	描述：
]]--
--武将信息：庞德
PangDe = sgs.CreateLuaGeneral{
	name = "pangde",
	translation = "庞德",
	title = "人马一体",
	kingdom = "qun",
	order = 5,
	cv = "Glory",
	illustrator = "LiuHeng",
	last_word = "宁做国家鬼，不为贼将也！",
	resource = "pangde",
}
--[[****************************************************************
	火武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "fire",
	translation = "火包",
	generals = {
		DianWei, XunYu, PangTong, ZhuGeLiang, TaiShiCi, YuanShao, YanLiangWenChou, PangDe,
	},
}