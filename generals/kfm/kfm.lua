--[[
	太阳神三国杀武将单挑对战平台·示例武将文件
]]--
--[[****************************************************************
	称号：示例武将
	武将：功夫人
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[兼容式写法
general = sgs.General("kfm", "qun", 4)
--翻译信息
sgs.LoadTranslationTable{
	["#kfm"] = "示例武将",
	["kfm"] = "功夫人",
	["&kfm"] = "功夫人",
}
--创建完成
return general
]]--
--推荐写法：
return {
	--原有内容
	name = "kfm", --武将名称
	kingdom = "qun", --武将所属势力
	maxhp = 4, --武将体力上限
	hidden = false, --武将是否为隐藏武将
	never_shown = false, --武将是否为完全隐藏武将
	title = "示例武将", --武将称号
	translation = "功夫人", --武将名称的翻译
	show_name = "功夫人", --武将在游戏中显示的名称
	designer = "DGAH", --武将的设计者
	cv = "无", --武将的配音人员
	illustrator = "MUGEN", --武将卡牌的画师或来源
	last_word = "功夫人 的阵亡台词", --武将的阵亡台词
	--新增内容
	real_name = "kfm", --武将真实姓名（用于判断两个武将是否为同一人）
	crowded = false, --武将是否为双人甚至多人武将（双人武将比如：颜良文丑、张昭张纮，等等）
	gender = sgs.General_Male, --武将性别
	order = 2, --武将在“过关斩将”模式中的出场编号（1~10为有效编号，数字越大出场越靠后，10表示Final Boss）
	skills = {}, --武将拥有的技能
	related_skills = {}, --武将相关联的技能（通常为觉醒技中将获得的技能）
	resource = "kfm_resource", --武将资源目录
	use_absolute_path = false, --武将资源目录是否为绝对路径
	translations = {}, --其他需要翻译的内容
}