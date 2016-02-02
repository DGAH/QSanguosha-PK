--[[
	太阳神三国杀武将单挑对战平台·武将分级制度
]]--
--纸级
LevelA = sgs.CreateGeneralLevel{
	name = "LevelA",
	translation = "纸级",
	gatekeepers = {},
	next_level = "LevelB",
	share_gatekeepers = "LevelB",
}
--弱级
LevelB = sgs.CreateGeneralLevel{
	name = "LevelB",
	translation = "弱级",
	gatekeepers = {"scarecrow_ii"},
	last_level = "LevelA",
	next_level = "LevelC",
}
--并级
LevelC = sgs.CreateGeneralLevel{
	name = "LevelC",
	translation = "并级",
	gatekeepers = {"scarecrow_v", "zhaoyun"},
	last_level = "LevelB",
	next_level = "LevelD",
}
--强级
LevelD = sgs.CreateGeneralLevel{
	name = "LevelD",
	translation = "强级",
	gatekeepers = {"zhugeliang"},
	last_level = "LevelC",
	sub_levels = {"LevelD_A", "LevelD_B"},
	next_level = "LevelE",
}
--强下位
LevelDA = sgs.CreateGeneralLevel{
	name = "LevelD_A",
	translation = "强下位",
	gatekeepers = {},
	parent_level = "LevelD",
	next_level = "LevelD_B",
	share_gatekeepers = "LevelD_B",
}
--强上位
LevelDB = sgs.CreateGeneralLevel{
	name = "LevelD_B",
	translation = "强上位",
	gatekeepers = {"zhenji", "shenzhaoyun"},
	parent_level = "LevelD",
	last_level = "LevelD_A",
}
--凶级
LevelE = sgs.CreateGeneralLevel{
	name = "LevelE",
	translation = "凶级",
	gatekeepers = {"sunquan"},
	last_level = "LevelD",
	next_level = "LevelF",
}
--狂级
LevelF = sgs.CreateGeneralLevel{
	name = "LevelF",
	translation = "狂级",
	gatekeepers = {"wuxingzhuge"},
	last_level = "LevelE",
	sub_levels = {"LevelF_A", "LevelF_B"},
	next_level = "LevelG",
}
--狂下位
LevelFA = sgs.CreateGeneralLevel{
	name = "LevelF_A",
	translation = "狂下位",
	gatekeepers = {},
	parent_level = "LevelF",
	next_level = "LevelF_B",
	share_gatekeepers = "LevelF_B",
}
--狂上位
LevelFB = sgs.CreateGeneralLevel{
	name = "LevelF_B",
	translation = "狂上位",
	gatekeepers = {"gaodayihao"},
	parent_level = "LevelF",
	last_level = "LevelF_A",
}
--神级
LevelG = sgs.CreateGeneralLevel{
	name = "LevelG",
	translation = "神级",
	gatekeepers = {"cryuji"},
	last_level = "LevelF",
}