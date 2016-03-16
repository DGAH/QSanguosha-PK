--[[
	太阳神三国杀武将单挑对战平台·格斗之王模式配置文件
]]--
--[[************************************************
	参数设定
]]--************************************************
options = {
	start_stage = 1, --起始关卡（取值范围：1~15）
	final_stage = 15, --最终关卡（取值范围：1~15，且不能小于起始关卡）
	stage_settings = "stages.lua", --关卡设置文件
	
	boss_enabled = true, --是否可选择BOSS队（取值范围：true/false）
	free_choose_record = true, --是否记录自由选将的结果（取值范围：true/false）
	
	time_limit = true, --是否启用计时胜负裁定原则（取值范围：true/false）
	
	striker_mode = true, --是否启用援护模式（取值范围：true/false）
	striker_count = 5, --初始援护次数（取值范围0+，仅在启用援护模式时有效）
	striker_skill = "gedang", --默认援护技能（格挡）
	striker_settings = "strikers.lua", --武将援护技能设定文件
	
	critical_mode = true, --是否启用暴击规则（取值范围：true/false）
	critical_rate = 20, --武将默认暴击率（取值范围：0~100，仅在启用暴击规则时有效）
	critical_settings = "critical_rate.lua", --武将暴击率设定文件
	fight_boss = true, --非BOSS武将对阵BOSS武将时是否获得额外的暴击率（取值范围：true/false，仅在启用暴击规则时有效）
	
	evolution_rule = true, --是否启用暴走进化规则（取值范围：true/false，仅在启用暴击规则时有效）
	evolution_settings = "evolution_rule.lua", --武将暴走进化规则设定文件
	server_log = false, --是否显示服务器测试信息（取值范围：true/false）
}
--[[************************************************
	参赛队登记
]]--************************************************
list = {
	--正式参赛队
	"DiWangDui", --帝王队
	"BaoLiNvWangDui", --暴力女王队
	"QunXiongWangZheDui", --群雄王者队
	"DaWeiMingXingDui", --大魏明星队
	"WuZiLiangJiangDui", --五子良将队
	"ShuHanMingXingDui", --蜀汉明星队
	"WuHuShangJiangDui", --五虎上将队
	"DongWuMingXingDui", --东吴明星队
	"JiangDongWuHuDui", --江东五虎队
	"QunXiongMingXingDui", --群雄明星队
	"GeJuQunXiongDui", --割据群雄队
	"CaoJiaXiongDiDui", --曹家兄弟队
	--特殊参赛队
	"DanTiaoMingXingDui", --单挑明星队
	"LianNuBieDongDui", --连弩别动队
	"DongWuZhiHuaDui", --东吴之花队
	"ChuanTongWuHeDui", --传统五核队
	"YinShiQianShenDui", --隐士前身队
	"ChengShenZhiLuDui", --成神之路队
	"TaoYuanSanYingDui", --桃园三英队
	"TuoLianDangDui", --托脸党队
	"CangSangSuiYueDui", --沧桑岁月队
	"ShuangShengZiDui", --双生子队
	"MaiXieDangDui", --卖血党队
	"ShenJiaoXinYangDui", --神教信仰队
	"HuoShaoChiBiDui", --火烧赤壁队
	"XiTianQuJingDui", --西天取经队
	"ShuErDaiDui", --蜀二代队
	"ShiTuDui", --师徒队
	"JiaQiTongRenDui", --佳期同人队
	"SiWangZhiWuDui", --死亡之舞队
	--小BOSS队
	"ShenJiangDui", --神将队
	"XinShenJiangDui", --新神将队
	--中BOSS队
	"YinShiDui", --隐士队
	--大BOSS队
	"HuLaoGuanDui", --虎牢关队
	--最终BOSS队
	"FinalBoss", --单挑之王
}
--[[************************************************
	保存设置
]]--************************************************
return {
	["options"] = options,
	["list"] = list,
}