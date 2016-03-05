--[[
	太阳神三国杀武将单挑对战平台·格斗之王模式·关卡设置文件
]]--
return {
	team_levels = {
		"LevelFormal", 
		"LevelSpecial", 
		"LevelTinyBoss", 
		"LevelBoss", 
		"LevelSuperBoss", 
		"LevelFinalBoss", 
	},
	stages = {
		"LevelFormal", -- Stage - 01
		"LevelFormal", -- Stage - 02
		"LevelFormal", -- Stage - 03
		"LevelFormal+LevelSpecial", -- Stage - 04
		"LevelFormal+LevelSpecial", -- Stage - 05
		"LevelFormal+LevelSpecial", -- Stage - 06
		"LevelFormal+LevelSpecial", -- Stage - 07
		"LevelFormal+LevelSpecial", -- Stage - 08
		"LevelFormal+LevelSpecial", -- Stage - 09
		"LevelFormal+LevelSpecial", -- Stage - 10
		"LevelSpecial", -- Stage - 11
		"LevelTinyBoss", -- Stage - 12
		"LevelBoss", -- Stage - 13
		"LevelSuperBoss", -- Stage - 14
		"LevelFinalBoss", -- Stage - 15
	},
	special_stage = 11, --第11关采取3v4模式，即对手将依次上场4名武将。
	LevelFormal = {
		name = "正式参赛队",
		boss = false,
	},
	LevelSpecial = {
		name = "特邀参赛队",
		boss = false,
	},
	LevelTinyBoss = {
		name = "小BOSS队",
		boss = true,
	},
	LevelBoss = {
		name = "中BOSS队",
		boss = true,
	},
	LevelSuperBoss = {
		name = "大BOSS队",
		boss = true,
	},
	LevelFinialBoss = {
		name = "最终BOSS队",
		boss = true,
	},
}