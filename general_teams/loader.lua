--[[
	太阳神三国杀武将单挑对战平台·格斗之王模式加载引导文件
]]--
global_kofgame_levels = {}
global_kofgame_stages = {}
global_kofgame_teams = {}
local boss_level = {}

function loadTeamLevels(info)
	for _,name in ipairs(info["team_levels"]) do
		local details = info[name]
		local level = sgs.KOFGameTeamLevel(name, details["boss"])
		table.insert(global_kofgame_levels, level)
		boss_level[name] = details["boss"]
		sgs.AddTranslationEntry(name, details["name"])
		sgs.GameEX:addTeamLevel(level)
	end
end

function loadStrikers(info, options)
	for general, skill in pairs(info) do
		if sgs.Sanguosha:getGeneral(general) and sgs.Sanguosha:getSkill(skill) then
			sgs.GameEX:addStrikerSkill(general, skill)
		end
	end
	sgs.GameEX:setStrikerMode(options["striker_mode"])
	sgs.GameEX:setStrikerCount(options["striker_count"])
	sgs.GameEX:setStrikerSkill(options["striker_skill"])
end

function loadCriticalSettings(info, options)
	for general, rate in pairs(info) do
		if sgs.Sanguosha:getGeneral(general) then
			if rate > 100 then rate = 100 end
			if rate < 0 then rate = 0 end
			sgs.GameEX:addCriticalRate(general, rate)
		end
	end
	sgs.GameEX:setCriticalMode(options["critical_mode"])
	sgs.GameEX:setDefaultCriticalRate(options["critical_rate"])
	sgs.GameEX:setFightBossEnabled(options["fight_boss"])
end

function loadEvolutionSettings(info, options)
	sgs.GameEX:setEvolutionMode(options["evolution_rule"])
	sgs.GameEX:setSendServerLog(options["server_log"])
end

function loadStages(info, options)
	local special_levels = info["special_stage"]
	if type(special_levels) == "number" then
		special_levels = {special_levels}
	elseif type(special_levels) ~= "table" then
		special_levels = {}
	end
	for index, levels in ipairs(info["stages"]) do
		local lvs = levels:split("+")
		local boss, special = false, false
		for _,lv in ipairs(lvs) do
			if boss_level[lv] then
				boss = true
				break
			end
		end
		for _,sp in ipairs(special_levels) do
			if sp == index then
				special = true
				break
			end
		end
		local stage = sgs.KOFGameStage(index, boss, special)
		for _,lv in ipairs(lvs) do
			stage:addTeamLevel(lv)
		end
		table.insert(global_kofgame_stages, stage)
		sgs.GameEX:addStage(stage)
	end
	sgs.GameEX:setStartStage(options["start_stage"])
	sgs.GameEX:setFinalStage(options["final_stage"])
end

function loadTeams(teams, options)
	if #teams == 0 then
		return
	end
	local exist_packages = {}
	local ban_packages = {}
	for _,pack in ipairs(sgs.Sanguosha:getBanPackages()) do
		ban_packages[pack] = true
	end
	for _,name in ipairs(teams) do
		local file = string.format("general_teams/%s/%s.lua", name, name)
		local details = dofile (file)
		local can_load = true
		for _,pack in ipairs(details["needpack"]) do
			if ban_packages[pack] then
				can_load = false
			elseif type(exist_packages[pack]) == "nil" then
				if sgs.Sanguosha:hasPackage(pack) then
					exist_packages[pack] = true
				else
					exist_packages[pack] = false
					can_load = false
					break
				end
			elseif not exist_packages[pack] then
				can_load = false
				break
			end
		end
		if can_load then
			local team = sgs.KOFGameTeam(name, details["category"])
			for _,general in ipairs(details["generals"]) do
				team:addGeneral(general)
			end
			table.insert(global_kofgame_teams, team)
			sgs.AddTranslationEntry(name, details["translation"])
			sgs.GameEX:addTeam(team)
		end
	end
	sgs.GameEX:setBossTeamEnabled(options["boss_enabled"])
	sgs.GameEX:setRecordChooseResult(options["free_choose_record"])
end

function executeLoader()
	local config = dofile "general_teams/config.lua"
	if type(config) ~= "table" then
		error("Cannot load the file 'general_teams/config.lua' !")
		return false
	end
	
	local options = config["options"]
	local teams = config["list"]
	if type(options) ~= "table" or type(teams) ~= "table" then
		error("The file 'general_teams/config.lua' is invalid !")
		return false
	end
	
	local stage_file = "general_teams/"..options["stage_settings"]
	local stage_info = dofile (stage_file)
	if type(stage_info) ~= "table" then
		error("Load stage data error!")
		return false
	end
	loadTeamLevels(stage_info)
	
	local striker_file = "general_teams/"..options["striker_settings"]
	local striker_info = dofile(striker_file)
	if type(striker_info) ~= "table" then
		error("Load striker data error!")
		return false
	end
	loadStrikers(striker_info, options)
	
	local critical_file = "general_teams/"..options["critical_settings"]
	local critical_info = dofile(critical_file)
	if type(critical_info) ~= "table" then
		error("Load critical rate data error!")
		return false
	end
	loadCriticalSettings(critical_info, options)
	
	local evolution_file = "general_teams/"..options["evolution_settings"]
	local evolution_info = dofile(evolution_file)
	if type(evolution_info) ~= "table" then
		error("Load evolution data error!")
		return false
	end
	loadEvolutionSettings(evolution_info, options)
	
	loadStages(stage_info, options)
	
	loadTeams(teams, options)
	
	sgs.GameEX:setTimeLimit(options["time_limit"])
	return true
end

return executeLoader()