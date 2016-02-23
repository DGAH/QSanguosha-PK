--[[
	太阳神三国杀武将单挑对战平台·1v1专属武将包
	武将总数：20
	武将一览：
		1、张辽（突袭）
		2、许褚（裸衣、挟缠）
		3、甄姬（倾国、洛神）
		4、夏侯渊（神速、肃资）
		5、刘备（仁望、激将）
		6、关羽（武圣、虎威）
		7、黄月英（集智、藏机）
		8、黄忠（烈弓）
		9、魏延（狂骨）
		10、姜维（挑衅）
		11、孟获（蛮裔、再起）
		12、祝融（蛮裔、烈刃）
		13、吕蒙（慎拒、博图）
		14、大乔（国色、婉容）
		15、孙尚香（姻礼、枭姬）
		16、华佗（急救、普济）
		17、貂蝉（翩仪、闭月）
		18、何进（谋诛、延祸）
		19、牛金（挫锐、裂围）
		20、韩遂（马术、逆乱）
]]--
--[[****************************************************************
	称号：前将军
	武将：张辽
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：突袭
	描述：
]]--
--武将信息：张辽
ZhangLiao = sgs.CreateLuaGeneral{
	name = "kof_zhangliao",
	real_name = "zhangliao",
	translation = "张辽1v1",
	show_name = "张辽",
	title = "前将军",
	kingdom = "wei",
	order = 4,
	resource = "zhangliao",
}
--[[****************************************************************
	称号：虎痴
	武将：许褚
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：裸衣
	描述：
]]--
--[[
	技能：挟缠
	描述：
]]--
--武将信息：许褚
XuChu = sgs.CreateLuaGeneral{
	name = "kof_xuchu",
	real_name = "xuchu",
	translation = "许褚1v1",
	show_name = "许褚",
	title = "虎痴",
	kingdom = "wei",
	order = 4,
	resource = "xuchu",
}
--[[****************************************************************
	称号：薄幸的美人
	武将：甄姬
	势力：魏
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：倾国
	描述：
]]--
--[[
	技能：洛神
	描述：
]]--
--武将信息：甄姬
ZhenJi = sgs.CreateLuaGeneral{
	name = "kof_zhenji",
	real_name = "zhenji",
	translation = "甄姬1v1",
	show_name = "甄姬",
	title = "薄幸的美人",
	kingdom = "wei",
	order = 6,
	resource = "zhenji",
}
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
--[[
	技能：肃资
	描述：
]]--
--武将信息：夏侯渊
XiaHouYuan = sgs.CreateLuaGeneral{
	name = "kof_xiahouyuan",
	real_name = "xiahouyuan",
	translation = "夏侯渊1v1",
	show_name = "夏侯渊",
	title = "疾行的猎豹",
	kingdom = "wei",
	order = 4,
	resource = "xiahouyuan",
}
--[[****************************************************************
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：仁望
	描述：
]]--
--[[
	技能：激将
	描述：
]]--
--武将信息：刘备
LiuBei = sgs.CreateLuaGeneral{
	name = "kof_liubei",
	real_name = "liubei",
	translation = "刘备1v1",
	show_name = "刘备",
	title = "乱世的枭雄",
	kingdom = "shu",
	order = 5,
	resource = "liubei",
}
--[[****************************************************************
	称号：美髯公
	武将：关羽
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：武圣
	描述：
]]--
--[[
	技能：虎威
	描述：
]]--
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "kof_guanyu",
	real_name = "guanyu",
	translation = "关羽1v1",
	show_name = "关羽",
	title = "美髯公",
	kingdom = "shu",
	order = 5,
	resource = "guanyu",
}
--[[****************************************************************
	称号：归隐的杰女
	武将：黄月英
	势力：蜀
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：集智
	描述：
]]--
--[[
	技能：藏机
	描述：
]]--
--武将信息：黄月英
HuangYueYing = sgs.CreateLuaGeneral{
	name = "kof_huangyueying",
	real_name = "huangyueying",
	translation = "黄月英1v1",
	show_name = "黄月英",
	title = "归隐的杰女",
	kingdom = "shu",
	female = true,
	maxhp = 3,
	order = 5,
	resource = "huangyueying",
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
	name = "kof_huangzhong",
	real_name = "huangzhong",
	translation = "黄忠1v1",
	show_name = "黄忠",
	title = "老当益壮",
	kingdom = "shu",
	order = 5,
	resource = "huangzhong",
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
	name = "kof_weiyan",
	real_name = "weiyan",
	translation = "魏延1v1",
	show_name = "魏延",
	title = "嗜血的独狼",
	kingdom = "shu",
	order = 5,
	resource = "weiyan",
}
--[[****************************************************************
	称号：龙的衣钵
	武将：姜维
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：挑衅
	描述：
]]--
--武将信息：姜维
JiangWei = sgs.CreateLuaGeneral{
	name = "kof_jiangwei",
	real_name = "jiangwei",
	translation = "姜维1v1",
	show_name = "姜维",
	title = "龙的衣钵",
	kingdom = "shu",
	order = 7,
	resource = "jiangwei",
}
--[[****************************************************************
	称号：南蛮王
	武将：孟获
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：蛮裔
	描述：
]]--
--[[
	技能：再起
	描述：
]]--
--武将信息：孟获
MengHuo = sgs.CreateLuaGeneral{
	name = "kof_menghuo",
	real_name = "menghuo",
	translation = "孟获1v1",
	show_name = "孟获",
	title = "南蛮王",
	kingdom = "shu",
	order = 7,
	resource = "menghuo",
}
--[[****************************************************************
	称号：野性的女王
	武将：祝融
	势力：蜀
	性别：女
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：蛮裔
	描述：
]]--
--[[
	技能：烈刃
	描述：
]]--
--武将信息：祝融
ZhuRong = sgs.CreateLuaGeneral{
	name = "kof_zhurong",
	real_name = "zhurong",
	translation = "祝融1v1",
	show_name = "祝融",
	title = "野性的女王",
	kingdom = "shu",
	female = true,
	order = 4,
	resource = "zhurong",
}
--[[****************************************************************
	称号：士别三日
	武将：吕蒙
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：慎拒
	描述：
]]--
--[[
	技能：博图
	描述：
]]--
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "kof_lvmeng",
	real_name = "lvmeng",
	translation = "吕蒙1v1",
	show_name = "吕蒙",
	title = "士别三日",
	kingdom = "wu",
	order = 6,
	resource = "lvmeng",
}
--[[****************************************************************
	称号：矜持之花
	武将：大乔
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：国色
	描述：
]]--
--[[
	技能：婉容
	描述：
]]--
--武将信息：大乔
DaQiao = sgs.CreateLuaGeneral{
	name = "kof_daqiao",
	real_name = "daqiao",
	translation = "大乔1v1",
	show_name = "大乔",
	title = "矜持之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 4,
	resource = "daqiao",
}
--[[****************************************************************
	称号：弓腰姬
	武将：孙尚香
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：姻礼
	描述：
]]--
--[[
	技能：枭姬
	描述：
]]--
--武将信息：孙尚香
SunShangXiang = sgs.CreateLuaGeneral{
	name = "kof_sunshangxiang",
	real_name = "sunshangxiang",
	translation = "孙尚香1v1",
	show_name = "孙尚香",
	title = "弓腰姬",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 7,
	resource = "sunshangxiang",
}
--[[****************************************************************
	称号：神医
	武将：华佗
	势力：群
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：急救
	描述：
]]--
--[[
	技能：普济
	描述：
]]--
--武将信息：华佗
HuaTuo = sgs.CreateLuaGeneral{
	name = "kof_huatuo",
	real_name = "huatuo",
	translation = "华佗1v1",
	show_name = "华佗",
	title = "神医",
	kingdom = "qun",
	maxhp = 3,
	order = 5,
	resource = "huatuo",
}
--[[****************************************************************
	称号：绝世的舞姬
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：翩仪
	描述：
]]--
--[[
	技能：闭月
	描述：
]]--
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "kof_diaochan",
	real_name = "diaochan",
	translation = "貂蝉1v1",
	show_name = "貂蝉",
	title = "绝世的舞姬",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 7,
	resource = "diaochan",
}
--[[****************************************************************
	称号：色厉内荏
	武将：何进
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：谋诛
	描述：
]]--
--[[
	技能：延祸
	描述：
]]--
--武将信息：何进
HeJin = sgs.CreateLuaGeneral{
	name = "hejin",
	translation = "何进",
	title = "色厉内荏",
	kingdom = "qun",
	order = 7,
	resource = "hejin",
}
--[[****************************************************************
	称号：独进的兵胆
	武将：牛金
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：挫锐
	描述：
]]--
--[[
	技能：裂围
	描述：
]]--
--武将信息：牛金
NiuJin = sgs.CreateLuaGeneral{
	name = "niujin",
	translation = "牛金",
	title = "独进的兵胆",
	kingdom = "wei",
	order = 4,
	resource = "niujin",
}
--[[****************************************************************
	称号：蹯踞西疆
	武将：韩遂
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术
	描述：
]]--
--[[
	技能：逆乱
	描述：
]]--
--武将信息：韩遂
HanSui = sgs.CreateLuaGeneral{
	name = "hansui",
	translation = "韩遂",
	title = "蹯踞西疆",
	kingdom = "qun",
	order = 5,
	resource = "hansui",
}
--[[****************************************************************
	1v1专属武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "special1v1",
	translation = "1v1专属",
	generals = {
		ZhangLiao, XuChu, ZhenJi, XiaHouYuan,
		LiuBei, GuanYu, HuangYueYing, HuangZhong, WeiYan, JiangWei, MengHuo, ZhuRong,
		LvMeng, DaQiao, SunShangXiang,
		HuaTuo, DiaoChan,
		HeJin, NiuJin, HanSui,
	},
}