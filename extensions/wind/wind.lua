--[[
	太阳神三国杀武将单挑对战平台·风武将包
	武将总数：8
	武将一览：
		1、夏侯渊（神速）
		2、曹仁（据守）
		3、黄忠（烈弓）
		4、魏延（狂骨）
		5、小乔（天香、红颜）
		6、周泰（不屈）
		7、张角（雷击、鬼道、黄天）
		8、于吉（蛊惑）
]]--
--[[****************************************************************
	称号：疾行的猎豹
	武将：夏侯渊
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：神速
	描述：
]]--
--武将信息：夏侯渊
XiaHouYuan = sgs.CreateLuaGeneral{
	name = "xiahouyuan",
	translation = "夏侯渊",
	title = "疾行的猎豹",
	kingdom = "wei",
	order = 4,
	last_word = "竟然……比我还……快……",
	death_audio = "xiahouyuan/xiahouyuan.ogg",
}
--[[****************************************************************
	称号：大将军
	武将：曹仁
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：据守
	描述：
]]--
--武将信息：曹仁
CaoRen = sgs.CreateLuaGeneral{
	name = "caoren",
	translation = "曹仁",
	title = "大将军",
	kingdom = "wei",
	order = 6,
	last_word = "实在是……守不住了……",
	death_audio = "caoren/caoren.ogg",
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
	描述：
]]--
--武将信息：黄忠
HuangZhong = sgs.CreateLuaGeneral{
	name = "huangzhong",
	translation = "黄忠",
	title = "老当益壮",
	kingdom = "shu",
	order = 7,
	last_word = "不得不服老了……",
	death_audio = "huangzhong/huangzhong.ogg",
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
	描述：
]]--
--武将信息：魏延
WeiYan = sgs.CreateLuaGeneral{
	name = "weiyan",
	translation = "魏延",
	title = "嗜血的独狼",
	kingdom = "shu",
	order = 5,
	illustrator = "Sonia Tang",
	last_word = "谁敢杀我？啊！",
	death_audio = "weiyan/weiyan.ogg",
}
--[[****************************************************************
	称号：矫情之花
	武将：小乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天香
	描述：
]]--
--[[
	技能：红颜
	描述：
]]--
--武将信息：小乔
XiaoQiao = sgs.CreateLuaGeneral{
	name = "xiaoqiao",
	translation = "小乔",
	title = "矫情之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 2,
	last_word = "公瑾，我先走一步……",
	death_audio = "xiaoqiao/xiaoqiao.ogg",
}
--[[****************************************************************
	称号：历战之躯
	武将：周泰
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：不屈
	描述：
]]--
--武将信息：周泰
ZhouTai = sgs.CreateLuaGeneral{
	name = "zhoutai",
	translation = "周泰",
	title = "历战之躯",
	kingdom = "wu",
	order = 2,
	last_word = "已经……尽力了……",
	death_audio = "zhoutai/zhoutai.ogg",
}
--[[****************************************************************
	称号：天公将军
	武将：张角
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：雷击
	描述：
]]--
--[[
	技能：鬼道
	描述：
]]--
--[[
	技能：黄天
	描述：
]]--
--武将信息：张角
ZhangJiao = sgs.CreateLuaGeneral{
	name = "zhangjiao",
	translation = "张角",
	title = "天公将军",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	last_word = "黄天……也死了……",
	death_audio = "zhangjiao/zhangjiao.ogg",
}
--[[****************************************************************
	称号：太平道人
	武将：于吉
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：蛊惑
	描述：
]]--
--武将信息：于吉
YuJi = sgs.CreateLuaGeneral{
	name = "yuji",
	translation = "于吉",
	title = "太平道人",
	kingdom = "qun",
	maxhp = 3,
	order = 4,
	illustrator = "LiuHeng",
	last_word = "竟然……被猜到了……",
	death_audio = "yuji/yuji.ogg",
}
--[[****************************************************************
	风武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "wind",
	translation = "风包",
	generals = {
		XiaHouYuan, CaoRen, HuangZhong, WeiYan, XiaoQiao, ZhouTai, ZhangJiao, YuJi,
	},
}