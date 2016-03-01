--[[
	太阳神三国杀武将单挑对战平台·示例扩展包文件
]]--
--[[****************************************************************
	名称：示例扩展包
	类型：武将包
	武将总数：0个
	卡牌总数：0个
	技能总数：0个
]]--****************************************************************
--[[兼容写法
extension = sgs.Package("demo", sgs.Package_GeneralPack)
--翻译信息
sgs.LoadTranslationTable{
	["demo"] = "示例扩展包",
}
--创建完成
return extension
]]--
--推荐写法
return {
	name = "demo", --扩展包名称
	category = sgs.Package_GeneralPack, --扩展包类型
	translation = "示例扩展包", --扩展包名称的翻译
	generals = {}, --扩展包中包含的武将
	cards = {}, --扩展包中包含的卡牌
	skills = {}, --扩展包中包含的自由技能
}