-- this script to store the basic configuration for game program itself
-- and it is a little different from config.ini

config = {
	big_font = 56,
	small_font = 27,
	tiny_font = 18,
	kingdoms = { "wei", "shu", "wu", "qun", "god", "die" },
	kingdom_colors = {
		wei = "#547998",
		shu = "#D0796C",
		wu = "#4DB873",
		qun = "#8A807A",
		god = "#96943D",
		die = "#700B0B",
	},

	skill_type_colors = {
		compulsoryskill = "#0000FF",
		limitedskill = "#FF0000",
		wakeskill = "#800080",
		lordskill = "#FFA500",
		oppphskill = "#008000",
	},

	package_names = {
		"StandardCard",
		"StandardExCard",
		"Maneuvering",
		"LimitationBroken",
		"SPCard",
		"Nostalgia",
		"New3v3Card",
		"New3v3_2013Card",
		"New1v1Card",
        "YitianCard" ,
        "Disaster" ,
        "JoyEquip" ,

		"Standard",
		"Test",
	},

	easy_text = {
		"太慢了，做两个俯卧撑吧！",
		"快点吧，我等的花儿都谢了！",
		"高，实在是高！",
		"好手段，可真不一般啊！",
		"哦，太菜了。水平有待提高。",
		"嘿，一般人，我不使这招。",
		"杀！神挡杀神！佛挡杀佛！",
		"你也忒坏了吧？！"
	},

	roles_ban = {
	},

	kof_ban = {
		"cryuji", "gaodayihao",
	},

	pairs_ban = {
		"cryuji", "gaodayihao",
	},

	removed_hidden_generals = {
	},

	extra_hidden_generals = {
	},
	
	kof_classical_generals = {
		--标准版武将
		"caocao", "simayi", "xiahoudun", "zhangliao", "xuchu", "guojia", "zhenji",
		"liubei", "guanyu", "zhangfei", "zhugeliang", "zhaoyun", "machao", "huangyueying",
		"sunquan", "ganning", "lvmeng", "huanggai", "zhouyu", "daqiao", "luxun", "sunshangxiang",
		"huatuo", "lvbu", "diaochan",
		--风包武将
		"xiahouyuan", "caoren",	
		"huangzhong", "weiyan",
		"xiaoqiao", "zhoutai", 
		"zhangjiao", "yuji",
	},
	
	kof_2013_generals = {
		"caocao", "simayi", "xiahoudun", "kof_zhangliao", "kof_xuchu", 
		"guojia", "kof_zhenji", "kof_xiahouyuan", "caoren", "dianwei", 
		"kof_guanyu", "zhangfei", "zhugeliang", "zhaoyun", "machao", 
		"kof_huangyueying", "kof_huangzhong", "kof_jiangwei", "kof_menghuo", "kof_zhurong", 
		"sunquan", "ganning", "huanggai", "zhouyu", "luxun", 
		"kof_sunshangxiang", "sunjian", "xiaoqiao", 
		"lvbu", "kof_diaochan", "yanliangwenchou", "hejin",
	},
	
	kof_wzzz_generals = {
		"caocao", "simayi", "xiahoudun", "kof_zhangliao", "kof_xuchu", 
		"guojia", "kof_zhenji", "kof_xiahouyuan", "caoren", "dianwei", 
		"niujin", 
		"kof_liubei", "kof_guanyu", "zhangfei", "zhugeliang", "zhaoyun", 
		"machao", "kof_huangyueying", "kof_huangzhong", "kof_weiyan", "kof_jiangwei", 
		"kof_menghuo", "kof_zhurong", 
		"sunquan", "ganning", "kof_lvmeng", "huanggai", "zhouyu", 
		"kof_daqiao", "luxun", "kof_sunshangxiang", "zhoutai", "sunjian", 
		"xiaoqiao", 
		"kof_huatuo", "lvbu", "kof_diaochan", "zhangjiao", "pangde", 
		"yanliangwenchou", "hejin", "hansui",
	},
}
