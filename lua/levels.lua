--[[
	太阳神三国杀武将单挑对战平台·武将分级制度
]]--
--纸级
LevelA = sgs.CreateGeneralLevel{
	name = "LevelA",
	translation = "纸级",
	description = "不能通过弱级审核，视为纸级。",
	gatekeepers = {},
	next_level = "LevelB",
	share_gatekeepers = "LevelB",
}
--弱级
LevelB = sgs.CreateGeneralLevel{
	name = "LevelB",
	translation = "弱级",
	description = "有至少50%比率对审核之一保持不败，同时不能通过并级审核，视为弱级。",
	gatekeepers = {"scarecrow_ii"},
	last_level = "LevelA",
	next_level = "LevelC",
}
--并级
LevelC = sgs.CreateGeneralLevel{
	name = "LevelC",
	translation = "并级",
	description = "有至少50%比率对审核之一保持不败，同时不能通过强级审核，视为并级。",
	gatekeepers = {"scarecrow_v", "zhaoyun"},
	last_level = "LevelB",
	next_level = "LevelD",
}
--强级
LevelD = sgs.CreateGeneralLevel{
	name = "LevelD",
	translation = "强级",
	description = "有至少50%比率击败审核之一，同时不能通过凶级审核，视为强级。",
	gatekeepers = {"zhugeliang"},
	last_level = "LevelC",
	sub_levels = {"LevelD_A", "LevelD_B"},
	next_level = "LevelE",
}
--强下位
LevelDA = sgs.CreateGeneralLevel{
	name = "LevelD_A",
	translation = "强下位",
	description = "在通过强级审核的基础上，不能通过强上位审核，视为强下位。",
	gatekeepers = {},
	parent_level = "LevelD",
	next_level = "LevelD_B",
	share_gatekeepers = "LevelD_B",
}
--强上位
LevelDB = sgs.CreateGeneralLevel{
	name = "LevelD_B",
	translation = "强上位",
	description = "在通过强级审核的基础上，有至少50%比率对审核之一保持不败，同时不能通过凶级审核，视为强上位。",
	gatekeepers = {"zhenji", "shenzhaoyun"},
	parent_level = "LevelD",
	last_level = "LevelD_A",
}
--凶级
LevelE = sgs.CreateGeneralLevel{
	name = "LevelE",
	translation = "凶级",
	description = "有至少50%比率击败审核之一，同时不能通过狂级审核，视为凶级。",
	gatekeepers = {"sunquan"},
	last_level = "LevelD",
	next_level = "LevelF",
}
--狂级
LevelF = sgs.CreateGeneralLevel{
	name = "LevelF",
	translation = "狂级",
	description = "有至少50%比率击败审核之一，同时不能通过神级审核，视为狂级。",
	gatekeepers = {"wuxingzhuge"},
	last_level = "LevelE",
	sub_levels = {"LevelF_A", "LevelF_B"},
	next_level = "LevelG",
}
--狂下位
LevelFA = sgs.CreateGeneralLevel{
	name = "LevelF_A",
	translation = "狂下位",
	description = "在通过狂级审核的基础上，不能通过狂上位审核，视为狂下位。",
	gatekeepers = {},
	parent_level = "LevelF",
	next_level = "LevelF_B",
	share_gatekeepers = "LevelF_B",
}
--狂上位
LevelFB = sgs.CreateGeneralLevel{
	name = "LevelF_B",
	translation = "狂上位",
	description = "在通过狂级审核的基础上，有至少50%比率对审核之一保持不败，同时不能通过神级审核，视为狂上位。",
	gatekeepers = {"gaodayihao"},
	parent_level = "LevelF",
	last_level = "LevelF_A",
}
--神级
LevelG = sgs.CreateGeneralLevel{
	name = "LevelG",
	translation = "神级",
	description = "有至少50%比率击败审核之一，视为神级。",
	gatekeepers = {"cryuji"},
	last_level = "LevelF",
}
--[[示例级别
DemoLevel = sgs.CreateGeneralLevel{
	name = "DemoLevel", --级别名称
	translation = "示例级别", --级别名称的翻译
	description = "", --级别描述
	gatekeepers = {}, --审核员
	share_gatekeepers = nil, --审核员共享级别（在本级别无审核员时，启用共享级别中的审核员作为本级别审核员）
	last_level = nil, --上一个级别
	next_level = nil, --下一个级别
	parent_level = nil, --所属父级别
	sub_levels = {}, --所含子级别
}
]]--