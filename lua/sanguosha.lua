-- This is the start script of QSanguosha

package.path = package.path .. ";./lua/lib/?.lua"

dofile "lua/utilities.lua"
dofile "lua/sgs_ex.lua"
dofile "lua/levels.lua"

global_path = "lua"

function load_translation(file)
	local t = dofile(file)
	if type(t) ~= "table" then
		error(("file %s is should return a table!"):format(file))
	end

	sgs.LoadTranslationTable(t)
end

function load_translations()
	local lang = sgs.GetConfig("Language", "zh_CN")
	local subdir = { "", "Audio", "Package" }
	for _, dir in ipairs(subdir) do
		local lang_dir = "lang/" .. lang .. "/" .. dir
		local lang_files = sgs.GetFileNames(lang_dir)
		for _, file in ipairs(lang_files) do
			load_translation(("%s/%s"):format(lang_dir, file))
		end
	end
end

function load_extensions()
	local list = dofile("extensions/list.lua")
	if type(list) ~= "table" then
		error("file extensions/list.lua should return a table!")
		return false
	end
	global_path = "extensions"
	local names = {}
	for _,name in pairs(list) do
		global_path = "extensions/"..name
		local pack = dofile(string.format("extensions/%s/%s.lua", name, name))
		if type(pack) == "table" then
			pack = sgs.CreateLuaPackage(pack)
		end
		if type(pack) == "userdata" and pack:inherits("Package") then
			table.insert(names, pack:objectName())
			sgs.Sanguosha:addPackage(pack)
		elseif type(pack) == "table" then
			for k, v in pairs(pack) do
				if type(k) == "userdata" and k:inherits("Package") then
					if type(v) == "boolean" and v then
						table.insert(names, k:objectName())
						sgs.Sanguosha:addPackage(k)
					end
				elseif type(k) == "number" and type(v) == "userdata" and v:inherits("Package") then
					table.insert(names, v:objectName())
					sgs.Sanguosha:addPackage(v)
				end
			end
		end
	end
	global_path = "extensions"
	sgs.SetConfig("LuaPackages", table.concat(names, "+"))
	return true
end

function load_generals()
	local list = dofile("generals/list.lua")
	if type(list) ~= "table" then
		error("file generals/list.lua should return a table!")
		return false
	end
	global_path = "generals"
	for _,name in pairs(list) do
		global_path = "generals/"..name
		local general = dofile(string.format("generals/%s/%s.lua", name, name))
		if type(general) == "table" then
			general = sgs.CreateLuaGeneral(general)
		end
		if type(general) == "userdata" and general:inherits("General") then
			sgs.Sanguosha:addGeneral(general)
		elseif type(general) == "table" then
			for k, v in pairs(general) do
				if type(k) == "userdata" and k:inherits("General") then
					if type(v) == "boolean" and v then
						sgs.Sanguosha:addGeneral(k)
					end
				elseif type(k) == "number" and type(v) == "userdata" and v:inherits("General") then
					sgs.Sanguosha:addGeneral(v)
				end
			end
		end
	end
	global_path = "generals"
	return true
end

if not sgs.GetConfig("DisableLua", false) then
	load_extensions()
	load_generals()
end

local success = dofile "general_teams/loader.lua"
sgs.Sanguosha:setProperty("GeneralTeamsLoadSuccess", sgs.QVariant(success))

local done_loading = sgs.Sanguosha:property("DoneLoading"):toBool()
if not done_loading then
	load_translations()
	done_loading = sgs.QVariant(true)
	sgs.Sanguosha:setProperty("DoneLoading", done_loading)
end
