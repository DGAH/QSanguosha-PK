#include "standard.h"
#include "engine.h"
#include "kofgame-engine.h"
#include "client.h"
#include "standard-skillcards.h"
#include "auxpack.h"
#include "maneuvering.h"
/*
 * 弱级审核：审核员·二限稻草人
 * 并级审核：审核员·五限稻草人 ；原标准版·赵云
 * 强级审核：原标准版·诸葛亮
 *     分界：原标准版·甄姬     ；神·赵云
 * 凶级审核：原标准版·孙权
 * 狂级审核：测试·五星诸葛
 *     分界：测试·高达一号
 * 神级审核：经典再临·掀桌于吉
 */
/*
 * 原标准版·赵云
 */
class Longdan : public OneCardViewAsSkill
{
public:
	Longdan() : OneCardViewAsSkill("longdan")
	{
		response_or_use = true;
	}

	virtual bool viewFilter(const Card *to_select) const
	{
		const Card *card = to_select;

		switch (Sanguosha->currentRoomState()->getCurrentCardUseReason()) {
		case CardUseStruct::CARD_USE_REASON_PLAY: {
													  return card->isKindOf("Jink");
		}
		case CardUseStruct::CARD_USE_REASON_RESPONSE:
		case CardUseStruct::CARD_USE_REASON_RESPONSE_USE: {
			QString pattern = Sanguosha->currentRoomState()->getCurrentCardUsePattern();
			if (pattern == "slash")
				return card->isKindOf("Jink");
			else if (pattern == "jink")
				return card->isKindOf("Slash");
		}
		default:
			return false;
		}
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		return Slash::IsAvailable(player);
	}

	virtual bool isEnabledAtResponse(const Player *, const QString &pattern) const
	{
		return pattern == "jink" || pattern == "slash";
	}

	virtual const Card *viewAs(const Card *originalCard) const
	{
		if (originalCard->isKindOf("Slash")) {
			Jink *jink = new Jink(originalCard->getSuit(), originalCard->getNumber());
			jink->addSubcard(originalCard);
			jink->setSkillName(objectName());
			return jink;
		}
		else if (originalCard->isKindOf("Jink")) {
			Slash *slash = new Slash(originalCard->getSuit(), originalCard->getNumber());
			slash->addSubcard(originalCard);
			slash->setSkillName(objectName());
			return slash;
		}
		else
			return NULL;
	}
};
/*
 * 原标准版·诸葛亮
 */
class Guanxing : public PhaseChangeSkill
{
public:
	Guanxing() : PhaseChangeSkill("guanxing")
	{
		frequency = Frequent;
	}

	virtual int getPriority(TriggerEvent) const
	{
		return 1;
	}

	virtual bool onPhaseChange(ServerPlayer *zhuge) const
	{
		if (zhuge->getPhase() == Player::Start && zhuge->askForSkillInvoke(this)) {
			Room *room = zhuge->getRoom();
			int index = qrand() % 2 + 1;
			room->broadcastSkillInvoke(objectName(), index);
			QList<int> guanxing = room->getNCards(getGuanxingNum(room));

			LogMessage log;
			log.type = "$ViewDrawPile";
			log.from = zhuge;
			log.card_str = IntList2StringList(guanxing).join("+");
			room->sendLog(log, zhuge);

			room->askForGuanxing(zhuge, guanxing);
		}

		return false;
	}

	virtual int getGuanxingNum(Room *room) const
	{
		return qMin(5, room->alivePlayerCount());
	}
};

class Kongcheng : public ProhibitSkill
{
public:
	Kongcheng() : ProhibitSkill("kongcheng")
	{
	}

	virtual bool isProhibited(const Player *, const Player *to, const Card *card, const QList<const Player *> &) const
	{
		return to->hasSkill(this) && (card->isKindOf("Slash") || card->isKindOf("Duel")) && to->isKongcheng();
	}
};

class KongchengEffect : public TriggerSkill
{
public:
	KongchengEffect() :TriggerSkill("#kongcheng-effect")
	{
		events << CardsMoveOneTime;
	}

	virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		if (player->isKongcheng()) {
			CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
			if (move.from == player && move.from_places.contains(Player::PlaceHand))
				room->broadcastSkillInvoke("kongcheng");
		}

		return false;
	}
};
/*
 * 原标准版·甄姬
 */
class Luoshen : public TriggerSkill
{
public:
    Luoshen() : TriggerSkill("luoshen")
    {
        events << EventPhaseStart << FinishJudge;
        frequency = Frequent;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *zhenji, QVariant &data) const
    {
        if (triggerEvent == EventPhaseStart && zhenji->getPhase() == Player::Start) {
            bool first = true;
            while (zhenji->askForSkillInvoke("luoshen")) {
                if (first) {
                    room->broadcastSkillInvoke(objectName());
                    first = false;
                }

                JudgeStruct judge;
                judge.pattern = ".|black";
                judge.good = true;
                judge.reason = objectName();
                judge.play_animation = false;
                judge.who = zhenji;
                judge.time_consuming = true;

                    room->judge(judge);

                if (judge.isBad())
                    break;
            }
        } else if (triggerEvent == FinishJudge) {
            JudgeStruct *judge = data.value<JudgeStruct *>();
            if (judge->reason == objectName()) {
                if (judge->card->isBlack()) {
                    if (room->getCardPlace(judge->card->getEffectiveId()) == Player::PlaceJudge) {
                        zhenji->obtainCard(judge->card);
                    }
                }
            }
        }

        return false;
    }
};

class Qingguo : public OneCardViewAsSkill
{
public:
    Qingguo() : OneCardViewAsSkill("qingguo")
    {
        filter_pattern = ".|black|.|hand";
        response_pattern = "jink";
        response_or_use = true;
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        Jink *jink = new Jink(originalCard->getSuit(), originalCard->getNumber());
        jink->setSkillName(objectName());
        jink->addSubcard(originalCard->getId());
        return jink;
    }
};
/*
 * 神·赵云
 */
class Juejing : public DrawCardsSkill
{
public:
	Juejing() : DrawCardsSkill("#juejing-draw")
	{
		frequency = Compulsory;
	}

	virtual int getDrawNum(ServerPlayer *player, int n) const
	{
		if (player->isWounded()) {
			Room *room = player->getRoom();
			room->notifySkillInvoked(player, "juejing");
			room->broadcastSkillInvoke("juejing");

			LogMessage log;
			log.type = "#YongsiGood";
			log.from = player;
			log.arg = QString::number(player->getLostHp());
			log.arg2 = "juejing";
			room->sendLog(log);
		}
		return n + player->getLostHp();
	}
};

class JuejingKeep : public MaxCardsSkill
{
public:
	JuejingKeep() : MaxCardsSkill("juejing")
	{
	}

	virtual int getExtra(const Player *target) const
	{
		if (target->hasSkill(this))
			return 2;
		else
			return 0;
	}
};

Longhun::Longhun() : ViewAsSkill("longhun")
{
	response_or_use = true;
}

bool Longhun::isEnabledAtResponse(const Player *player, const QString &pattern) const
{
	return pattern == "slash"
		|| pattern == "jink"
		|| (pattern.contains("peach") && player->getMark("Global_PreventPeach") == 0)
		|| pattern == "nullification";
}

bool Longhun::isEnabledAtPlay(const Player *player) const
{
	return player->isWounded() || Slash::IsAvailable(player);
}

bool Longhun::viewFilter(const QList<const Card *> &selected, const Card *card) const
{
	int n = qMax(1, Self->getHp());

	if (selected.length() >= n || card->hasFlag("using"))
		return false;

	if (n > 1 && !selected.isEmpty()) {
		Card::Suit suit = selected.first()->getSuit();
		return card->getSuit() == suit;
	}

	switch (Sanguosha->currentRoomState()->getCurrentCardUseReason()) {
	case CardUseStruct::CARD_USE_REASON_PLAY: {
		if (Self->isWounded() && card->getSuit() == Card::Heart)
			return true;
		else if (card->getSuit() == Card::Diamond) {
			FireSlash *slash = new FireSlash(Card::SuitToBeDecided, -1);
			slash->addSubcards(selected);
			slash->addSubcard(card->getEffectiveId());
			slash->deleteLater();
			return slash->isAvailable(Self);
		}
		else
			return false;
	}
	case CardUseStruct::CARD_USE_REASON_RESPONSE:
	case CardUseStruct::CARD_USE_REASON_RESPONSE_USE: {
		QString pattern = Sanguosha->currentRoomState()->getCurrentCardUsePattern();
			if (pattern == "jink")
				return card->getSuit() == Card::Club;
			else if (pattern == "nullification")
				return card->getSuit() == Card::Spade;
			else if (pattern == "peach" || pattern == "peach+analeptic")
				return card->getSuit() == Card::Heart;
			else if (pattern == "slash")
				return card->getSuit() == Card::Diamond;
	}
	default:
		break;
	}

	return false;
}

const Card *Longhun::viewAs(const QList<const Card *> &cards) const
{
	int n = getEffHp(Self);

	if (cards.length() != n)
		return NULL;

	const Card *card = cards.first();
	Card *new_card = NULL;

	switch (card->getSuit()) {
	case Card::Spade: {
		new_card = new Nullification(Card::SuitToBeDecided, 0);
		break;
	}
	case Card::Heart: {
		new_card = new Peach(Card::SuitToBeDecided, 0);
		break;
	}
	case Card::Club: {
		new_card = new Jink(Card::SuitToBeDecided, 0);
		break;
	}
	case Card::Diamond: {
		new_card = new FireSlash(Card::SuitToBeDecided, 0);
		break;
	}
	default:
		break;
	}

	if (new_card) {
		new_card->setSkillName(objectName());
		new_card->addSubcards(cards);
	}

	return new_card;
}

int Longhun::getEffectIndex(const ServerPlayer *player, const Card *card) const
{
	return static_cast<int>(player->getRoom()->getCard(card->getSubcards().first())->getSuit()) + 1;
}

bool Longhun::isEnabledAtNullification(const ServerPlayer *player) const
{
	int n = getEffHp(player), count = 0;
	foreach(const Card *card, player->getHandcards() + player->getEquips()) {
		if (card->getSuit() == Card::Spade) count++;
		if (count >= n) return true;
	}
	return false;
}

int Longhun::getEffHp(const Player *zhaoyun) const
{
	return qMax(1, zhaoyun->getHp());
}
/*
 * 原标准版·孙权
 */
class Zhiheng : public ViewAsSkill
{
public:
	Zhiheng() : ViewAsSkill("zhiheng")
	{
	}

	virtual bool viewFilter(const QList<const Card *> &selected, const Card *to_select) const
	{
		if (ServerInfo.GameMode.contains("kof") && ServerInfo.GameMode != "03_kof" && selected.length() >= 2) return false;
		return !Self->isJilei(to_select);
	}

	virtual const Card *viewAs(const QList<const Card *> &cards) const
	{
		if (cards.isEmpty())
			return NULL;

		ZhihengCard *zhiheng_card = new ZhihengCard;
		zhiheng_card->addSubcards(cards);
		zhiheng_card->setSkillName(objectName());
		return zhiheng_card;
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		return player->canDiscard(player, "he") && !player->hasUsed("ZhihengCard");
	}

	virtual bool isEnabledAtResponse(const Player *, const QString &pattern) const
	{
		return pattern == "@zhiheng";
	}
};
/*
 * 测试·五星诸葛
 */
class SuperGuanxing : public Guanxing
{
public:
	SuperGuanxing() : Guanxing()
	{
		setObjectName("super_guanxing");
	}

	virtual int getGuanxingNum(Room *) const
	{
		return 5;
	}
};
/*
 * 测试·高达一号
 */
class GdJuejing : public TriggerSkill
{
public:
	GdJuejing() : TriggerSkill("gdjuejing")
	{
		events << CardsMoveOneTime;
		frequency = Compulsory;
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *gaodayihao, QVariant &data) const
	{
		if (triggerEvent == CardsMoveOneTime) {
			CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
			if (move.from != gaodayihao && move.to != gaodayihao)
				return false;
			if (move.to_place != Player::PlaceHand && !move.from_places.contains(Player::PlaceHand))
				return false;
		}
		if (gaodayihao->getHandcardNum() == 4)
			return false;
		int diff = abs(gaodayihao->getHandcardNum() - 4);
		if (gaodayihao->getHandcardNum() < 4) {
			room->sendCompulsoryTriggerLog(gaodayihao, objectName());
			gaodayihao->drawCards(diff, objectName());
		}
		else if (gaodayihao->getHandcardNum() > 4) {
			room->sendCompulsoryTriggerLog(gaodayihao, objectName());
			room->askForDiscard(gaodayihao, objectName(), diff, diff);
		}

		return false;
	}
};

class GdJuejingSkipDraw : public DrawCardsSkill
{
public:
	GdJuejingSkipDraw() : DrawCardsSkill("#gdjuejing")
	{
	}

	virtual int getPriority(TriggerEvent) const
	{
		return 1;
	}

	virtual int getDrawNum(ServerPlayer *gaodayihao, int) const
	{
		LogMessage log;
		log.type = "#GdJuejing";
		log.from = gaodayihao;
		log.arg = "gdjuejing";
		gaodayihao->getRoom()->sendLog(log);

		return 0;
	}
};

class GdLonghun : public Longhun
{
public:
	GdLonghun() : Longhun()
	{
		setObjectName("gdlonghun");
	}

	virtual int getEffHp(const Player *) const
	{
		return 1;
	}
};

class GdLonghunDuojian : public TriggerSkill
{
public:
	GdLonghunDuojian() : TriggerSkill("#gdlonghun-duojian")
	{
		events << EventPhaseStart;
	}

	virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *gaodayihao, QVariant &) const
	{
		if (gaodayihao->getPhase() == Player::Start) {
			foreach(ServerPlayer *p, room->getOtherPlayers(gaodayihao)) {
				if (p->getWeapon() && p->getWeapon()->isKindOf("QinggangSword")) {
					if (room->askForSkillInvoke(gaodayihao, "gdlonghun")) {
						room->broadcastSkillInvoke("gdlonghun", 5);
						gaodayihao->obtainCard(p->getWeapon());
					}
					break;
				}
			}
		}

		return false;
	}
};
/*
 * 经典再临·掀桌于吉
 */
class Huanhuo : public ZeroCardViewAsSkill
{
public:
	Huanhuo() : ZeroCardViewAsSkill("crhuanhuo")
	{
		response_or_use = true;
	}

	virtual bool isEnabledAtResponse(const Player *player, const QString &pattern) const
	{
		bool current = false;
		QList<const Player *> players = player->getAliveSiblings();
		players.append(player);
		foreach(const Player *p, players) {
			if (p->getPhase() != Player::NotActive) {
				current = true;
				break;
			}
		}
		if (!current) return false;

		if (pattern.startsWith(".") || pattern.startsWith("@"))
			return false;
		if (pattern == "peach" && player->getMark("Global_PreventPeach") > 0) return false;
		for (int i = 0; i < pattern.length(); i++) {
			QChar ch = pattern[i];
			if (ch.isUpper() || ch.isDigit()) return false; // This is an extremely dirty hack!! For we need to prevent patterns like 'BasicCard'
		}
		return true;
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		bool current = false;
		QList<const Player *> players = player->getAliveSiblings();
		players.append(player);
		foreach(const Player *p, players) {
			if (p->getPhase() != Player::NotActive) {
				current = true;
				break;
			}
		}
		if (!current) return false;
		return true;
	}

	virtual const Card *viewAs() const
	{
		if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE
			|| Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE_USE) {
			HuanhuoCard *card = new HuanhuoCard;
			card->setUserString(Sanguosha->currentRoomState()->getCurrentCardUsePattern());
			return card;
		}

		const Card *c = Self->tag.value("crhuanhuo").value<const Card *>();
		if (c) {
			HuanhuoCard *card = new HuanhuoCard;
			if (!c->objectName().contains("slash"))
				card->setUserString(c->objectName());
			else
				card->setUserString(Self->tag["crhuanhuoSlash"].toString());
			return card;
		}
		else
			return NULL;
	}

	virtual QDialog *getDialog() const
	{
		return GuhuoDialog::getInstance("crhuanhuo");
	}

	virtual int getEffectIndex(const ServerPlayer *, const Card *card) const
	{
		if (!card->isKindOf("HuanhuoCard"))
			return -2;
		else
			return -1;
	}

	virtual bool isEnabledAtNullification(const ServerPlayer *player) const
	{
		ServerPlayer *current = player->getRoom()->getCurrent();
		if (!current || current->isDead() || current->getPhase() == Player::NotActive) return false;
		return true;
	}
};

class Xianzhuo : public ZeroCardViewAsSkill
{
public:
	Xianzhuo() : ZeroCardViewAsSkill("crxianzhuo")
	{
		limit_mark = "@crXianZhuoMark";
		frequency = Limited;
	}

	virtual const Card *viewAs() const
	{
		return new XianzhuoCard;
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		return player->getMark("@crXianZhuoMark") > 0;
	}
};
/*
 * 特定技能
 */
// 骁袭 ：部分KOF模式中用于替换技能“马术”
class Xiaoxi : public TriggerSkill
{
public:
	Xiaoxi() : TriggerSkill("xiaoxi")
	{
		events << Debut;
	}

	virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &) const
	{
		ServerPlayer *opponent = player->getNext();
		if (!opponent->isAlive())
			return false;
		Slash *slash = new Slash(Card::NoSuit, 0);
		slash->setSkillName("_xiaoxi");
		if (player->isLocked(slash) || !player->canSlash(opponent, slash, false)) {
			delete slash;
			return false;
		}
		if (room->askForSkillInvoke(player, objectName()))
			room->useCard(CardUseStruct(slash, player, opponent));
		return false;
	}
};
// 格挡 ： “格斗之王”模式启用援护规则时提供的默认援护技能
class GeDang : public TriggerSkill
{
public:
	GeDang() :TriggerSkill("gedang")
	{
		events << DamageForseen;
		global = true;
	}

	virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		DamageStruct damage = data.value<DamageStruct>();
		if (damage.from && damage.from != player){
			if (player->askForSkillInvoke(this, data)) {
				player->loseMark("@striker");
				LogMessage msg;
				msg.type = "#striker";
				msg.from = player;
				msg.to.append(damage.from);
				msg.arg = damage.damage;
				room->sendLog(msg);
				return true;
			}
		}
		return false;
	}

	virtual bool triggerable(ServerPlayer *target) const
	{
		return target && target->getMark("@striker") > 0 && target->getMark("GeDangForbidden") == 0;
	}
};
// 援护 ： “格斗之王”模式启用援护技能时的专属技能
class KOFGameYuanHuSkill : public ZeroCardViewAsSkill
{
public:
	KOFGameYuanHuSkill() : ZeroCardViewAsSkill("call_striker")
	{
		attached_lord_skill = true;
	}

	virtual const Card *viewAs() const
	{
		return new KOFGameYuanHuCard;
	}

	virtual bool isEnabledAtPlay(ServerPlayer *player) const
	{
		return player->getMark("@striker") > 0;
	}
};

class KOFGameYuanHuGlobalEffect : public TriggerSkill
{
public:
	KOFGameYuanHuGlobalEffect() : TriggerSkill("striker_manager")
	{
		events << CardUsed << EventPhaseStart;
		global = true;
	}

	virtual bool trigger(TriggerEvent , Room *room, ServerPlayer *player, QVariant &) const
	{
		QString striker_skill = player->tag["StrikerSkill"].toString();
		room->detachSkillFromPlayer(player, striker_skill, false, true);
		player->tag["StrikerSkill"] = "";
		return false;
	}

	virtual bool triggerable(ServerPlayer *target) const
	{
		return target && !target->tag["StrikerSkill"].toString().isEmpty();
	}

	virtual int getPriority() const
	{
		return 10;
	}
};
// 非锁定技无效
class NonCompulsoryInvalidity : public InvaliditySkill
{
public:
	NonCompulsoryInvalidity() : InvaliditySkill("#non-compulsory-invalidity")
	{
	}

	virtual bool isSkillValid(const Player *player, const Skill *skill) const
	{
		return player->getMark("@skill_invalidity") == 0 || skill->getFrequency(player) == Skill::Compulsory;
	}
};

void StandardPackage::addGenerals()
{
	//审核员·II限稻草人
	General *scarecrow_ii = new General(this, "scarecrow_ii", "god", 2);
	scarecrow_ii->setRealName("scarecrow");
	scarecrow_ii->setOrder(1);
	//审核员·V限稻草人
	General *scarecrow_v = new General(this, "scarecrow_v", "god", 5);
	scarecrow_v->setRealName("scarecrow");
	scarecrow_v->setOrder(3);
	//原标准版·赵云
	General *zhaoyun = new General(this, "zhaoyun", "shu");
	zhaoyun->addSkill(new Longdan);
	zhaoyun->setOrder(3);
	//原标准版·诸葛亮
	General *zhugeliang = new General(this, "zhugeliang", "shu", 3);
	zhugeliang->addSkill(new Guanxing);
	zhugeliang->addSkill(new Kongcheng);
	zhugeliang->addSkill(new KongchengEffect);
	related_skills.insertMulti("kongcheng", "#kongcheng-effect");
	zhugeliang->setOrder(5);
	//原标准版·甄姬
	General *zhenji = new General(this, "zhenji", "wei", 3, false);
	zhenji->addSkill(new Qingguo);
	zhenji->addSkill(new Luoshen);
	zhenji->setOrder(8);
	//神·赵云
	General *shenzhaoyun = new General(this, "shenzhaoyun", "god", 2);
	shenzhaoyun->addSkill(new Juejing);
	shenzhaoyun->addSkill(new JuejingKeep);
	shenzhaoyun->addSkill(new Longhun);
	related_skills.insertMulti("juejing", "#juejing-draw");
	shenzhaoyun->setOrder(8);
	//原标准版·孙权
	General *sunquan = new General(this, "sunquan", "wu");
	sunquan->addSkill(new Zhiheng);
	sunquan->addSkill(new DummySkill("jiuyuan"));
	sunquan->setOrder(10);
	//测试·五星诸葛
	General *wuxingzhuge = new General(this, "wuxingzhuge", "shu", 3);
	wuxingzhuge->addSkill(new SuperGuanxing);
	wuxingzhuge->addSkill("kongcheng");
	wuxingzhuge->setRealName("zhugeliang");
	//测试·高达一号
	General *gaodayihao = new General(this, "gaodayihao", "god", 1);
	gaodayihao->addSkill(new GdJuejing);
	gaodayihao->addSkill(new GdJuejingSkipDraw);
	gaodayihao->addSkill(new GdLonghun);
	gaodayihao->addSkill(new GdLonghunDuojian);
	related_skills.insertMulti("gdjuejing", "#gdjuejing");
	related_skills.insertMulti("gdlonghun", "#gdlonghun-duojian");
	gaodayihao->setRealName("zhaoyun");

	//经典再临·掀桌于吉
	General *cryuji = new General(this, "cryuji", "god", 3);
	cryuji->addSkill(new Huanhuo);
	cryuji->addSkill(new Xianzhuo);
	cryuji->setRealName("yuji");

    // for skill cards
    addMetaObject<ZhihengCard>();
	addMetaObject<HuanhuoCard>();
	addMetaObject<XianzhuoCard>();
	addMetaObject<KOFGameYuanHuCard>();

    skills << new Xiaoxi << new GeDang << new NonCompulsoryInvalidity << new KOFGameYuanHuSkill << new KOFGameYuanHuGlobalEffect;
}

