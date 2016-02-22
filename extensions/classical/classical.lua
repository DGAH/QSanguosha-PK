--[[
	太阳神三国杀武将单挑对战平台·经典标准版武将包
	武将总数：25
	武将一览：
		1、曹操（奸雄、护驾）
		2、司马懿（反馈、鬼才）
		3、夏侯惇（刚烈）
		4、张辽（突袭）
		5、许褚（裸衣）
		6、郭嘉（天妒、遗计）
		7、甄姬（倾国、洛神）
		8、刘备（仁德、激将）
		9、关羽（武圣）
		10、张飞（咆哮）
		11、诸葛亮（观星、空城）
		12、赵云（龙胆）
		13、马超（马术、铁骑）
		14、黄月英（集智、奇才）
		15、孙权（制衡、救援）
		16、甘宁（奇袭）
		17、吕蒙（克己）
		18、黄盖（苦肉）
		19、周瑜（英姿、反间）
		20、大乔（国色、流离）
		21、陆逊（谦逊、连营）
		22、孙尚香（结姻、枭姬）
		23、华佗（急救、青囊）
		24、吕布（无双）
		25、貂蝉（离间、闭月）
]]--
--[[****************************************************************
	称号：魏武帝
	武将：曹操
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：奸雄
	描述：
]]--
--[[
	技能：护驾
	描述：
]]--
--武将信息：曹操
CaoCao = sgs.CreateLuaGeneral{
	name = "caocao",
	translation = "曹操",
	title = "魏武帝",
	kingdom = "wei",
	order = 4,
	last_word = "霸业未成、未成啊！",
	death_audio = "caocao/caocao.ogg",
}
--[[****************************************************************
	称号：狼顾之鬼
	武将：司马懿
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：反馈
	描述：
]]--
--[[
	技能：鬼才
	描述：
]]--
--武将信息：司马懿
SiMaYi = sgs.CreateLuaGeneral{
	name = "simayi",
	translation = "司马懿",
	title = "狼顾之鬼",
	kingdom = "wei",
	maxhp = 3,
	order = 3,
	last_word = "难道真的是天命难违？",
	death_audio = "simayi/simayi.ogg",
}
--[[****************************************************************
	称号：独眼的罗刹
	武将：夏侯惇
	势力：魏
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：刚烈
	描述：
]]--
--武将信息：夏侯惇
XiaHouDun = sgs.CreateLuaGeneral{
	name = "xiahoudun",
	translation = "夏侯惇",
	title = "独眼的罗刹",
	kingdom = "wei",
	order = 3,
	last_word = "两、两边都看不见啦……",
	death_audio = "xiahoudun/xiahoudun.ogg",
}
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
	name = "zhangliao",
	translation = "张辽",
	title = "前将军",
	kingdom = "wei",
	order = 1,
	last_word = "真没想到……",
	death_audio = "zhangliao/zhangliao.ogg",
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
--武将信息：许褚
XuChu = sgs.CreateLuaGeneral{
	name = "xuchu",
	translation = "许褚",
	title = "虎痴",
	kingdom = "wei",
	order = 1,
	last_word = "冷……好冷啊！",
	death_audio = "xuchu/xuchu.ogg",
}
--[[****************************************************************
	称号：早终的先知
	武将：郭嘉
	势力：魏
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：天妒
	描述：
]]--
--[[
	技能：遗计
	描述：
]]--
--武将信息：郭嘉
GuoJia = sgs.CreateLuaGeneral{
	name = "guojia",
	translation = "郭嘉",
	title = "早终的先知",
	kingdom = "wei",
	maxhp = 3,
	order = 4,
	last_word = "咳咳咳、呃咳咳咳……",
	death_audio = "guojia/guojia.ogg",
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
	name = "classical_zhenji",
	real_name = "zhenji",
	translation = "甄姬",
	title = "薄幸的美人",
	kingdom = "wei",
	female = true,
	maxhp = 3,
	order = 8,
	hidden = true,
	skills = {"qingguo", "luoshen"},
	last_word = "悼良会之永绝兮，哀一逝而异乡……",
}
--[[****************************************************************
	称号：乱世的枭雄
	武将：刘备
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：仁德
	描述：
]]--
--[[
	技能：激将
	描述：
]]--
--武将信息：刘备
LiuBei = sgs.CreateLuaGeneral{
	name = "liubei",
	translation = "刘备",
	title = "乱世的枭雄",
	kingdom = "shu",
	order = 2,
	last_word = "这就是桃园么？",
	death_audio = "liubei/liubei.ogg",
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
--武将信息：关羽
GuanYu = sgs.CreateLuaGeneral{
	name = "guanyu",
	translation = "关羽",
	title = "美髯公",
	kingdom = "shu",
	order = 4,
	last_word = "什么？此地叫麦城？",
	death_audio = "guanyu/guanyu.ogg",
}
--[[****************************************************************
	称号：万夫不当
	武将：张飞
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：咆哮
	描述：
]]--
--武将信息：张飞
ZhangFei = sgs.CreateLuaGeneral{
	name = "zhangfei",
	translation = "张飞",
	title = "万夫不当",
	kingdom = "shu",
	order = 2,
	skills = "paoxiao",
	last_word = "实在是杀不动啦！",
	death_audio = "zhangfei/zhangfei.ogg",
}
--[[****************************************************************
	称号：迟暮的丞相
	武将：诸葛亮
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：观星
	描述：
]]--
--[[
	技能：空城
	描述：
]]--
--武将信息：诸葛亮
ZhuGeLiang = sgs.CreateLuaGeneral{
	name = "classical_zhugeliang",
	real_name = "zhugeliang",
	translation = "诸葛亮",
	title = "迟暮的丞相",
	kingdom = "shu",
	maxhp = 3,
	order = 5,
	hidden = true,
	skills = {"guanxing", "kongcheng"},
	last_word = "将星陨落，天命难违……",
}
--[[****************************************************************
	称号：少年将军
	武将：赵云
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：龙胆
	描述：
]]--
--武将信息：赵云
ZhaoYun = sgs.CreateLuaGeneral{
	name = "classical_zhaoyun",
	real_name = "zhaoyun",
	translation = "赵云",
	title = "少年将军",
	kingdom = "shu",
	order = 3,
	hidden = true,
	skills = "longdan",
	last_word = "这就是失败的滋味吗？",
}
--[[****************************************************************
	称号：一骑当千
	武将：马超
	势力：蜀
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：马术
	描述：
]]--
--[[
	技能：铁骑
	描述：
]]--
--武将信息：马超
MaChao = sgs.CreateLuaGeneral{
	name = "machao",
	translation = "马超",
	title = "一骑当千",
	kingdom = "shu",
	order = 7,
	last_word = "（马蹄声）",
	death_audio = "machao/machao.ogg",
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
	技能：奇才
	描述：
]]--
--武将信息：黄月英
HuangYueYing = sgs.CreateLuaGeneral{
	name = "huangyueying",
	translation = "黄月英",
	title = "归隐的杰女",
	kingdom = "shu",
	female = true,
	maxhp = 3,
	order = 5,
	last_word = "亮！",
	death_audio = "huangyueying/huangyueying.ogg",
}
--[[****************************************************************
	称号：年轻的贤君
	武将：孙权
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：制衡
	描述：
]]--
--[[
	技能：救援
	描述：
]]--
--武将信息：孙权
SunQuan = sgs.CreateLuaGeneral{
	name = "classical_sunquan",
	real_name = "sunquan",
	translation = "孙权",
	title = "年轻的贤君",
	kingdom = "wu",
	order = 10,
	hidden = true,
	skills = "zhiheng+jiuyuan",
	last_word = "父亲、大哥，仲谋愧矣……",
}
--[[****************************************************************
	称号：锦帆游侠
	武将：甘宁
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：奇袭
	描述：
]]--
--武将信息：甘宁
GanNing = sgs.CreateLuaGeneral{
	name = "ganning",
	translation = "甘宁",
	title = "锦帆游侠",
	kingdom = "wu",
	order = 6,
	last_word = "二十年后，又是一条好汉！",
	death_audio = "ganning/ganning.ogg",
}
--[[****************************************************************
	称号：白衣渡江
	武将：吕蒙
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：克己
	描述：
]]--
--武将信息：吕蒙
LvMeng = sgs.CreateLuaGeneral{
	name = "lvmeng",
	translation = "吕蒙",
	title = "白衣渡江",
	kingdom = "wu",
	order = 5,
	last_word = "呃……被看穿了吗？",
	death_audio = "lvmeng/lvmeng.ogg",
}
--[[****************************************************************
	称号：轻身为国
	武将：黄盖
	势力：吴
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：苦肉
	描述：
]]--
--武将信息：黄盖
HuangGai = sgs.CreateLuaGeneral{
	name = "huanggai",
	translation = "黄盖",
	title = "轻身为国",
	kingdom = "wu",
	order = 3,
	last_word = "失血过多了……",
	death_audio = "huanggai/huanggai.ogg",
}
--[[****************************************************************
	称号：大都督
	武将：周瑜
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：英姿
	描述：
]]--
--[[
	技能：反间
	描述：
]]--
--武将信息：周瑜
ZhouYu = sgs.CreateLuaGeneral{
	name = "zhouyu",
	translation = "周瑜",
	title = "大都督",
	kingdom = "wu",
	maxhp = 3,
	order = 7,
	last_word = "既生瑜，何生……",
	death_audio = "zhouyu/zhouyu.ogg",
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
	技能：流离
	描述：
]]--
--武将信息：大乔
DaQiao = sgs.CreateLuaGeneral{
	name = "daqiao",
	translation = "大乔",
	title = "矜持之花",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 1,
	last_word = "伯符……我去了……",
	death_audio = "daqiao/daqiao.ogg",
}
--[[****************************************************************
	称号：儒生雄才
	武将：陆逊
	势力：吴
	性别：男
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：谦逊
	描述：
]]--
--[[
	技能：连营
	描述：
]]--
--武将信息：陆逊
LuXun = sgs.CreateLuaGeneral{
	name = "luxun",
	translation = "陆逊",
	title = "儒生雄才",
	kingdom = "wu",
	maxhp = 3,
	order = 2,
	last_word = "我还是太年轻了……",
	death_audio = "luxun/luxun.ogg",
}
--[[****************************************************************
	称号：弓腰姬
	武将：孙尚香
	势力：吴
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：结姻
	描述：
]]--
--[[
	技能：枭姬
	描述：
]]--
--武将信息：孙尚香
SunShangXiang = sgs.CreateLuaGeneral{
	name = "sunshangxiang",
	translation = "孙尚香",
	title = "弓腰姬",
	kingdom = "wu",
	female = true,
	maxhp = 3,
	order = 4,
	last_word = "不……还不可以死……",
	death_audio = "sunshangxiang/sunshangxiang.ogg",
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
	技能：青囊
	描述：
]]--
--武将信息：华佗
HuaTuo = sgs.CreateLuaGeneral{
	name = "huatuo",
	translation = "华佗",
	title = "神医",
	kingdom = "qun",
	maxhp = 3,
	order = 5,
	last_word = "医者不能自医啊……",
	death_audio = "huatuo/huatuo.ogg",
}
--[[****************************************************************
	称号：武的化身
	武将：吕布
	势力：群
	性别：男
	体力上限：4勾玉
]]--****************************************************************
--[[
	技能：无双
	描述：
]]--
--武将信息：吕布
LvBu = sgs.CreateLuaGeneral{
	name = "lvbu",
	translation = "吕布",
	title = "武的化身",
	kingdom = "qun",
	order = 7,
	skills = "wushuang",
	last_word = "不可能！",
	death_audio = "lvbu/lvbu.ogg",
}
--[[****************************************************************
	称号：绝世的舞姬
	武将：貂蝉
	势力：群
	性别：女
	体力上限：3勾玉
]]--****************************************************************
--[[
	技能：离间
	描述：
]]--
--[[
	技能：闭月
	描述：
]]--
--武将信息：貂蝉
DiaoChan = sgs.CreateLuaGeneral{
	name = "diaochan",
	translation = "貂蝉",
	title = "绝世的舞姬",
	kingdom = "qun",
	female = true,
	maxhp = 3,
	order = 7,
	last_word = "父亲大人……对不起……",
	death_audio = "diaochan/diaochan.ogg",
}
--[[****************************************************************
	经典标准版武将包
]]--****************************************************************
return sgs.CreateLuaPackage{
	name = "classical",
	translation = "标准版",
	generals = {
		CaoCao, SiMaYi, XiaHouDun, ZhangLiao, XuChu, GuoJia, ZhenJi,
		LiuBei, GuanYu, ZhangFei, ZhuGeLiang, ZhaoYun, MaChao, HuangYueYing,
		SunQuan, GanNing, LvMeng, HuangGai, ZhouYu, DaQiao, LuXun, SunShangXiang,
		HuaTuo, LvBu, DiaoChan,
	},
}