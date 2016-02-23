--[[
	太阳神三国杀武将单挑对战平台·神武将包
	武将总数：8
	武将一览：
		1、关羽（武神、武魂）
		2、吕蒙（涉猎、攻心）
		3、周瑜（琴音、业炎）
		4、诸葛亮（七星、狂风、大雾）
		5、曹操（归心、飞影）
		6、吕布（狂暴、无谋、无前、无谋）+（无双）
		7、司马懿（忍戒、拜印、连破）+（极略）
		8、赵云（绝境、龙魂）
]]--
--[[****************************************************************
	称号：鬼神再临
	武将：关羽
	势力：神
	性别：男
	体力上限：勾玉
]]--****************************************************************
--[[
	技能：武神
	描述：
]]--
--[[
	技能：武魂
	描述：
]]--
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "shenguanyu",
	real_name = "guanyu",
	translation = "神关羽",
	show_name = "关羽",
	title = "鬼神再临",
	kingdom = "god",
	maxhp = 5,
	order = 2,
	cv = "奈何",
	last_word = "吾一世英明，竟葬于小人之手！",
	resource = "guanyu",
}
--[[****************************************************************
	称号：圣光之国士
	武将：吕蒙
	势力：神
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：涉猎
	描述：
]]--
--[[
	技能：攻心
	描述：
]]--
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "shenlvmeng",
	real_name = "lvmeng",
	translation = "神吕蒙",
	show_name = "吕蒙",
	title = "圣光之国士",
	kingdom = "god",
	maxhp = 3,
	order = 10,
	cv = "宇文天启",
	last_word = "死去方知万事空……",
	resource = "lvmeng",
}
--[[****************************************************************
	称号：赤壁的火神
	武将：周瑜
	势力：神
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：琴音
	描述：
]]--
--[[
	技能：业炎
	描述：
]]--
--武将信息：周瑜
ZhouYu = sgs.CreateLuaGeneral{
	name = "shenzhouyu",
	real_name = "zhouyu",
	translation = "神周瑜",
	show_name = "周瑜",
	title = "赤壁的火神",
	kingdom = "god",
	order = 6,
	cv = "血桜の涙",
	last_word = "残炎黯然，弦歌不复……",
	resource = "zhouyu",
}
--[[****************************************************************
	称号：赤壁的妖术师
	武将：诸葛亮
	势力：神
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：七星
	描述：
]]--
--[[
	技能：狂风
	描述：
]]--
--[[
	技能：大雾
	描述：
]]--
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "shenzhugeliang",
	real_name = "zhugeliang",
	translation = "神诸葛亮",
	show_name = "诸葛亮",
	title = "赤壁的妖术师",
	kingdom = "god",
	maxhp = 3,
	order = 9,
	cv = "背后灵",
	last_word = "吾命将至，再不能临阵讨贼矣……",
	resource = "zhugeliang",
}
--[[****************************************************************
	称号：超世之英杰
	武将：曹操
	势力：神
	性别：男
	体力上限：勾玉
]]--****************************************************************
--[[
	技能：归心
	描述：
]]--
--[[
	技能：飞影
	描述：
]]--
--武将信息：曹操
CaoCao = sgs.CreateLuaGeneral{
	name = "shencaocao",
	real_name = "caocao",
	translation = "神曹操",
	show_name = "曹操",
	title = "超世之英杰",
	kingdom = "god",
	maxhp = 3,
	order = 2,
	cv = "倚天の剑",
	last_word = "神龟虽寿，犹有竟时；腾蛇乘雾，终为土灰……",
	resource = "caocao",
}
--[[****************************************************************
	称号：修罗之道
	武将：吕布
	势力：神
	性别：男
	体力上限：5勾玉
]]--****************************************************************
--[[
	技能：狂暴
	描述：
]]--
--[[
	技能：无谋
	描述：
]]--
--[[
	技能：无前
	描述：
]]--
--[[
	技能：神愤
	描述：
]]--
--[[
	技能：无双
	描述：
]]--
--武将信息：
LvBu = sgs.CreateLuaGeneral{
	name = "shenlvbu",
	real_name = "lvbu",
	translation = "神吕布",
	show_name = "吕布",
	title = "修罗之道",
	kingdom = "god",
	maxhp = 5,
	order = 6,
	cv = "笑傲糨糊",
	last_word = "大耳贼最叵信！啊……",
	resource = "lvbu",
}
--[[****************************************************************
	称号：晋国之祖
	武将：司马懿
	势力：神
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：忍戒
	描述：
]]--
--[[
	技能：拜印
	描述：
]]--
--[[
	技能：连破
	描述：
]]--
--[[
	技能：极略
	描述：
]]--
--武将信息：司马懿
SiMaYi = sgs.CreateLuaGeneral{
	name = "shensimayi",
	real_name = "simayi",
	translation = "神司马懿",
	show_name = "司马懿",
	title = "晋国之祖",
	kingdom = "god",
	order = 9,
	cv = "泥马",
	last_word = "我已谋划至此，奈何……",
	resource = "simayi",
}
--[[****************************************************************
	称号：神威如龙
	武将：赵云
	势力：神
	性别：男
	体力上限：2勾玉
]]--****************************************************************
--[[
	技能：绝境
	描述：
]]--
--[[
	技能：龙魂
	描述：
]]--
--武将信息：赵云
ZhaoYun = sgs.CreateLuaGeneral{
	name = "gods_zhaoyun",
	real_name = "zhaoyun",
	translation = "神赵云",
	show_name = "赵云",
	title = "神威如龙",
	kingdom = "god",
	maxhp = 2,
	order = 8,
	hidden = true,
	cv = "猎狐",
	last_word = "血染麟甲，龙坠九天……",
	resource = "zhaoyun",
}
--[[****************************************************************
	神武将包
]]--****************************************************************
return sgs.CreateLuaGeneral{
	name = "gods",
	translation = "神包",
	generals = {
		GuanYu, LvMeng, ZhuGeLiang, ZhouYu, CaoCao, LvBu, SiMaYi, ZhaoYun,
	},
}