#include "standard.h"
#include "engine.h"
#include "client.h"
#include "standard-skillcards.h"
#include "auxpack.h"
#include "maneuvering.h"
/*
 * 并级审核：审核员·二限稻草人
 * 弱级审核：审核员·五限稻草人 ；原标准版·赵云
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

	virtual int getEffectIndex(const ServerPlayer *player, const Card *) const
	{
		int index = qrand() % 2 + 1;
		if (Player::isNostalGeneral(player, "zhaoyun"))
			index += 2;
		return index;
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
		if (ServerInfo.GameMode == "02_1v1" && ServerInfo.GameRuleMode != "Classical" && selected.length() >= 2) return false;
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

class Jiuyuan : public TriggerSkill
{
public:
	Jiuyuan() : TriggerSkill("jiuyuan$")
	{
		events << TargetConfirmed << PreHpRecover;
		frequency = Compulsory;
	}

	virtual bool triggerable(const ServerPlayer *target) const
	{
		return target != NULL && target->hasLordSkill("jiuyuan");
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *sunquan, QVariant &data) const
	{
		if (triggerEvent == TargetConfirmed) {
			CardUseStruct use = data.value<CardUseStruct>();
			if (use.card->isKindOf("Peach") && use.from && use.from->getKingdom() == "wu"
				&& sunquan != use.from && sunquan->hasFlag("Global_Dying")) {
				room->setCardFlag(use.card, "jiuyuan");
			}
		}
		else if (triggerEvent == PreHpRecover) {
			RecoverStruct rec = data.value<RecoverStruct>();
			if (rec.card && rec.card->hasFlag("jiuyuan")) {
				room->notifySkillInvoked(sunquan, "jiuyuan");
				if (!sunquan->isLord() && sunquan->hasSkill("weidi"))
					room->broadcastSkillInvoke("weidi");
				else
					room->broadcastSkillInvoke("jiuyuan", rec.who->isMale() ? 1 : 2);

				LogMessage log;
				log.type = "#JiuyuanExtraRecover";
				log.from = sunquan;
				log.to << rec.who;
				log.arg = objectName();
				room->sendLog(log);

				rec.recover++;
				data = QVariant::fromValue(rec);
			}
		}

		return false;
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
	//审核员·V限稻草人
	General *scarecrow_v = new General(this, "scarecrow_v", "god", 5);
	//原标准版·赵云
	General *zhaoyun = new General(this, "zhaoyun", "shu");
	zhaoyun->addSkill(new Longdan);
	//原标准版·诸葛亮
	General *zhugeliang = new General(this, "zhugeliang", "shu", 3);
	zhugeliang->addSkill(new Guanxing);
	zhugeliang->addSkill(new Kongcheng);
	zhugeliang->addSkill(new KongchengEffect);
	related_skills.insertMulti("kongcheng", "#kongcheng-effect");
	//原标准版·甄姬
	General *zhenji = new General(this, "zhenji", "wei", 3, false);
	zhenji->addSkill(new Qingguo);
	zhenji->addSkill(new Luoshen);
	//神·赵云
	General *shenzhaoyun = new General(this, "shenzhaoyun", "god", 2);
	shenzhaoyun->addSkill(new Juejing);
	shenzhaoyun->addSkill(new JuejingKeep);
	shenzhaoyun->addSkill(new Longhun);
	related_skills.insertMulti("juejing", "#juejing-draw");
	//原标准版·孙权
	General *sunquan = new General(this, "sunquan$", "wu");
	sunquan->addSkill(new Zhiheng);
	sunquan->addSkill(new Jiuyuan);
	//测试·五星诸葛
	General *wuxingzhuge = new General(this, "wuxingzhuge", "shu", 3);
	wuxingzhuge->addSkill(new SuperGuanxing);
	wuxingzhuge->addSkill("kongcheng");
	//测试·高达一号
	General *gaodayihao = new General(this, "gaodayihao", "god", 1);
	gaodayihao->addSkill(new GdJuejing);
	gaodayihao->addSkill(new GdJuejingSkipDraw);
	gaodayihao->addSkill(new GdLonghun);
	gaodayihao->addSkill(new GdLonghunDuojian);
	related_skills.insertMulti("gdjuejing", "#gdjuejing");
	related_skills.insertMulti("gdlonghun", "#gdlonghun-duojian");

	//经典再临·掀桌于吉
	General *cryuji = new General(this, "cryuji", "god", 3);
	cryuji->addSkill(new Huanhuo);
	cryuji->addSkill(new Xianzhuo);

    // for skill cards
    addMetaObject<ZhihengCard>();
	addMetaObject<HuanhuoCard>();
	addMetaObject<XianzhuoCard>();

    skills << new Xiaoxi << new NonCompulsoryInvalidity;
}

class SuperZhiheng : public Zhiheng
{
public:
    SuperZhiheng() :Zhiheng()
    {
        setObjectName("super_zhiheng");
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return player->canDiscard(player, "he") && player->usedTimes("ZhihengCard") < (player->getLostHp() + 1);
    }
};

class SuperMaxCards : public MaxCardsSkill
{
public:
    SuperMaxCards() : MaxCardsSkill("super_max_cards")
    {
    }

    virtual int getExtra(const Player *target) const
    {
        if (target->hasSkill(this))
            return target->getMark("@max_cards_test");
        return 0;
    }
};

class SuperOffensiveDistance : public DistanceSkill
{
public:
    SuperOffensiveDistance() : DistanceSkill("super_offensive_distance")
    {
    }

    virtual int getCorrect(const Player *from, const Player *) const
    {
        if (from->hasSkill(this))
            return -from->getMark("@offensive_distance_test");
        else
            return 0;
    }
};

class SuperDefensiveDistance : public DistanceSkill
{
public:
    SuperDefensiveDistance() : DistanceSkill("super_defensive_distance")
    {
    }

    virtual int getCorrect(const Player *, const Player *to) const
    {
        if (to->hasSkill(this))
            return to->getMark("@defensive_distance_test");
        else
            return 0;
    }
};

Yongsi::Yongsi() : TriggerSkill("yongsi")
{
	events << DrawNCards << EventPhaseStart;
	frequency = Compulsory;
}

int Yongsi::getKingdoms(ServerPlayer *yuanshu) const
{
	QSet<QString> kingdom_set;
	Room *room = yuanshu->getRoom();
	foreach(ServerPlayer *p, room->getAlivePlayers())
		kingdom_set << p->getKingdom();

	return kingdom_set.size();
}

bool Yongsi::trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *yuanshu, QVariant &data) const
{
	if (triggerEvent == DrawNCards) {
		int x = getKingdoms(yuanshu);
		data = data.toInt() + x;

		Room *room = yuanshu->getRoom();
		LogMessage log;
		log.type = "#YongsiGood";
		log.from = yuanshu;
		log.arg = QString::number(x);
		log.arg2 = objectName();
		room->sendLog(log);
		room->notifySkillInvoked(yuanshu, objectName());

		room->broadcastSkillInvoke("yongsi", x % 2 + 1);
	}
	else if (triggerEvent == EventPhaseStart && yuanshu->getPhase() == Player::Discard) {
		int x = getKingdoms(yuanshu);
		LogMessage log;
		log.type = yuanshu->getCardCount() > x ? "#YongsiBad" : "#YongsiWorst";
		log.from = yuanshu;
		log.arg = QString::number(log.type == "#YongsiBad" ? x : yuanshu->getCardCount());
		log.arg2 = objectName();
		room->sendLog(log);
		room->notifySkillInvoked(yuanshu, objectName());
		if (x > 0)
			room->askForDiscard(yuanshu, "yongsi", x, x, false, true);
	}

	return false;
}

class SuperYongsi : public Yongsi
{
public:
    SuperYongsi() : Yongsi()
    {
        setObjectName("super_yongsi");
    }

    virtual int getKingdoms(ServerPlayer *yuanshu) const
    {
        return yuanshu->getMark("@yongsi_test");
    }
};

class WeidiViewAsSkill : public ViewAsSkill
{
public:
	WeidiViewAsSkill() : ViewAsSkill("weidi")
	{
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		QList<const ViewAsSkill *> vs_skills = WeidiDialog::getLordViewAsSkills(player);
		foreach(const ViewAsSkill *skill, vs_skills) {
			if (skill->isEnabledAtPlay(player))
				return true;
		}
		return false;
	}

	virtual bool isEnabledAtResponse(const Player *player, const QString &pattern) const
	{
		QList<const ViewAsSkill *> vs_skills = WeidiDialog::getLordViewAsSkills(player);
		foreach(const ViewAsSkill *skill, vs_skills) {
			if (skill->isEnabledAtResponse(player, pattern))
				return true;
		}
		return false;
	}

	virtual bool isEnabledAtNullification(const ServerPlayer *player) const
	{
		QList<const ViewAsSkill *> vs_skills = WeidiDialog::getLordViewAsSkills(player);
		foreach(const ViewAsSkill *skill, vs_skills) {
			if (skill->isEnabledAtNullification(player))
				return true;
		}
		return false;
	}

	virtual bool viewFilter(const QList<const Card *> &selected, const Card *to_select) const
	{
		QString skill_name = Self->tag["weidi"].toString();
		if (skill_name.isEmpty()) return false;
		const ViewAsSkill *vs_skill = Sanguosha->getViewAsSkill(skill_name);
		if (vs_skill) return vs_skill->viewFilter(selected, to_select);
		return false;
	}

	virtual const Card *viewAs(const QList<const Card *> &cards) const
	{
		QString skill_name = Self->tag["weidi"].toString();
		if (skill_name.isEmpty()) return NULL;
		const ViewAsSkill *vs_skill = Sanguosha->getViewAsSkill(skill_name);
		if (vs_skill) return vs_skill->viewAs(cards);
		return NULL;
	}
};

class Weidi : public GameStartSkill
{
public:
	Weidi() : GameStartSkill("weidi")
	{
		frequency = Compulsory;
		view_as_skill = new WeidiViewAsSkill;
	}

	virtual void onGameStart(ServerPlayer *) const
	{
		return;
	}

	virtual QDialog *getDialog() const
	{
		return WeidiDialog::getInstance();
	}
};

Jushou::Jushou() : PhaseChangeSkill("jushou")
{
}

int Jushou::getJushouDrawNum(ServerPlayer *) const
{
	return 1;
}

bool Jushou::onPhaseChange(ServerPlayer *target) const
{
	if (target->getPhase() == Player::Finish) {
		Room *room = target->getRoom();
		if (room->askForSkillInvoke(target, objectName())) {
			room->broadcastSkillInvoke(objectName());
			target->drawCards(getJushouDrawNum(target), objectName());
			target->turnOver();
		}
	}

	return false;
}

class SuperJushou : public Jushou
{
public:
    SuperJushou() : Jushou()
    {
        setObjectName("super_jushou");
    }

    virtual int getJushouDrawNum(ServerPlayer *caoren) const
    {
        return caoren->getMark("@jushou_test");
    }
};

class Zaibian : public TriggerSkill
{
public:
	Zaibian() :TriggerSkill("zaibian")
	{
		events << EventPhaseStart;
		frequency = Compulsory;
	}

	int getNumDiff(ServerPlayer *zombie) const
	{
		int human = 0, zombies = 0;
		foreach(ServerPlayer *player, zombie->getRoom()->getAlivePlayers()) {
			switch (player->getRoleEnum()) {
			case Player::Lord:
			case Player::Loyalist: human++; break;
			case Player::Rebel: zombies++; break;
			case Player::Renegade: zombies++; break;
			default:
				break;
			}
		}

		int x = human - zombies + 1;
		if (x < 0)
			return 0;
		else
			return x;
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *, ServerPlayer *zombie, QVariant &) const
	{
		if (triggerEvent == EventPhaseStart && zombie->getPhase() == Player::Play) {
			int x = getNumDiff(zombie);
			if (x > 0) {
				Room *room = zombie->getRoom();
				LogMessage log;
				log.type = "#ZaibianGood";
				log.from = zombie;
				log.arg = QString::number(x);
				log.arg2 = objectName();
				room->sendLog(log);
				zombie->drawCards(x);
			}

		}
		return false;
	}
};

class Xunmeng : public TriggerSkill
{
public:
	Xunmeng() :TriggerSkill("xunmeng")
	{
		events << ConfirmDamage;

		frequency = Compulsory;
	}

	virtual bool trigger(TriggerEvent, Room* room, ServerPlayer *zombie, QVariant &data) const
	{
		DamageStruct damage = data.value<DamageStruct>();

		const Card *reason = damage.card;
		if (reason == NULL)
			return false;

		if (reason->isKindOf("Slash")) {
			LogMessage log;
			log.type = "#Xunmeng";
			log.from = zombie;
			log.to << damage.to;
			log.arg = QString::number(damage.damage);
			log.arg2 = QString::number(++damage.damage);
			room->sendLog(log);

			data = QVariant::fromValue(damage);
			if (zombie->getHp() > 1) room->loseHp(zombie);
		}

		return false;
	}
};

class Paoxiao : public TargetModSkill
{
public:
	Paoxiao() : TargetModSkill("paoxiao")
	{
	}

	virtual int getResidueNum(const Player *from, const Card *) const
	{
		if (from->hasSkill(this))
			return 1000;
		else
			return 0;
	}
};

class Ganran : public FilterSkill
{
public:
	Ganran() :FilterSkill("ganran")
	{
	}

	virtual bool viewFilter(const Card* to_select) const
	{
		Room *room = Sanguosha->currentRoom();
		Player::Place place = room->getCardPlace(to_select->getEffectiveId());
		return place == Player::PlaceHand && to_select->getTypeId() == Card::TypeEquip;
	}

	virtual const Card *viewAs(const Card *originalCard) const
	{
		GanranEquip *ironchain = new GanranEquip(originalCard->getSuit(), originalCard->getNumber());
		ironchain->setSkillName(objectName());
		WrappedCard *card = Sanguosha->getWrappedCard(originalCard->getEffectiveId());
		card->takeOver(ironchain);
		return card;
	}
};

class Wushuang : public TriggerSkill
{
public:
	Wushuang() : TriggerSkill("wushuang")
	{
		events << TargetSpecified << CardFinished;
		frequency = Compulsory;
	}

	virtual bool triggerable(const ServerPlayer *target) const
	{
		return target != NULL;
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		if (triggerEvent == TargetSpecified) {
			int index = qrand() % 2 + 1;
			if (Player::isNostalGeneral(player, "lvbu")) index += 2;
			CardUseStruct use = data.value<CardUseStruct>();
			if (use.card->isKindOf("Slash") && TriggerSkill::triggerable(player)) {
				room->broadcastSkillInvoke(objectName(), index);
				room->sendCompulsoryTriggerLog(player, objectName());

				QVariantList jink_list = player->tag["Jink_" + use.card->toString()].toList();
				for (int i = 0; i < use.to.length(); i++) {
					if (jink_list.at(i).toInt() == 1)
						jink_list.replace(i, QVariant(2));
				}
				player->tag["Jink_" + use.card->toString()] = QVariant::fromValue(jink_list);
			}
			else if (use.card->isKindOf("Duel")) {
				if (TriggerSkill::triggerable(player)) {
					room->broadcastSkillInvoke(objectName(), index);
					room->sendCompulsoryTriggerLog(player, objectName());

					QStringList wushuang_tag;
					foreach(ServerPlayer *to, use.to)
						wushuang_tag << to->objectName();
					player->tag["Wushuang_" + use.card->toString()] = wushuang_tag;
				}
				foreach(ServerPlayer *p, use.to.toSet()) {
					if (TriggerSkill::triggerable(p)) {
						room->broadcastSkillInvoke(objectName(), index);
						room->sendCompulsoryTriggerLog(p, objectName());

						p->tag["Wushuang_" + use.card->toString()] = QStringList(player->objectName());
					}
				}
			}
		}
		else if (triggerEvent == CardFinished) {
			CardUseStruct use = data.value<CardUseStruct>();
			if (use.card->isKindOf("Duel")) {
				foreach(ServerPlayer *p, room->getAllPlayers())
					p->tag.remove("Wushuang_" + use.card->toString());
			}
		}

		return false;
	}
};

class Mashu : public DistanceSkill
{
public:
	Mashu() : DistanceSkill("mashu")
	{
	}

	virtual int getCorrect(const Player *from, const Player *) const
	{
		if (from->hasSkill(this))
			return -1;
		else
			return 0;
	}
};

class Xiuluo : public PhaseChangeSkill
{
public:
	Xiuluo() : PhaseChangeSkill("xiuluo")
	{
	}

	virtual bool triggerable(const ServerPlayer *target) const
	{
		return PhaseChangeSkill::triggerable(target)
			&& target->getPhase() == Player::Start
			&& target->canDiscard(target, "h")
			&& hasDelayedTrick(target);
	}

	virtual bool onPhaseChange(ServerPlayer *target) const
	{
		Room *room = target->getRoom();
		while (hasDelayedTrick(target) && target->canDiscard(target, "h")) {
			QStringList suits;
			foreach(const Card *jcard, target->getJudgingArea()) {
				if (!suits.contains(jcard->getSuitString()))
					suits << jcard->getSuitString();
			}

			const Card *card = room->askForCard(target, QString(".|%1|.|hand").arg(suits.join(",")),
				"@xiuluo", QVariant(), objectName());
			if (!card || !hasDelayedTrick(target)) break;
			room->broadcastSkillInvoke(objectName());

			QList<int> avail_list, other_list;
			foreach(const Card *jcard, target->getJudgingArea()) {
				if (jcard->isKindOf("SkillCard")) continue;
				if (jcard->getSuit() == card->getSuit())
					avail_list << jcard->getEffectiveId();
				else
					other_list << jcard->getEffectiveId();
			}
			room->fillAG(avail_list + other_list, NULL, other_list);
			int id = room->askForAG(target, avail_list, false, objectName());
			room->clearAG();
			room->throwCard(id, NULL);
		}

		return false;
	}

private:
	static bool hasDelayedTrick(const ServerPlayer *target)
	{
		foreach(const Card *card, target->getJudgingArea())
		if (!card->isKindOf("SkillCard")) return true;
		return false;
	}
};

class Shenwei : public DrawCardsSkill
{
public:
	Shenwei() : DrawCardsSkill("#shenwei-draw")
	{
		frequency = Compulsory;
	}

	virtual int getDrawNum(ServerPlayer *player, int n) const
	{
		Room *room = player->getRoom();

		room->broadcastSkillInvoke("shenwei");
		room->sendCompulsoryTriggerLog(player, "shenwei");

		return n + 2;
	}
};

class ShenweiKeep : public MaxCardsSkill
{
public:
	ShenweiKeep() : MaxCardsSkill("shenwei")
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

class Shenji : public TargetModSkill
{
public:
	Shenji() : TargetModSkill("shenji")
	{
	}

	virtual int getExtraTargetNum(const Player *from, const Card *) const
	{
		if (from->hasSkill(this) && from->getWeapon() == NULL)
			return 2;
		else
			return 0;
	}
};

class Jiuchi : public OneCardViewAsSkill
{
public:
	Jiuchi() : OneCardViewAsSkill("jiuchi")
	{
		filter_pattern = ".|spade|.|hand";
		response_or_use = true;
	}

	virtual bool isEnabledAtPlay(const Player *player) const
	{
		return Analeptic::IsAvailable(player);
	}

	virtual bool isEnabledAtResponse(const Player *, const QString &pattern) const
	{
		return  pattern.contains("analeptic");
	}

	virtual const Card *viewAs(const Card *originalCard) const
	{
		Analeptic *analeptic = new Analeptic(originalCard->getSuit(), originalCard->getNumber());
		analeptic->setSkillName(objectName());
		analeptic->addSubcard(originalCard->getId());
		return analeptic;
	}
};

class Roulin : public TriggerSkill
{
public:
	Roulin() : TriggerSkill("roulin")
	{
		events << TargetConfirmed << TargetSpecified;
		frequency = Compulsory;
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		CardUseStruct use = data.value<CardUseStruct>();
		if (use.card->isKindOf("Slash")) {
			QVariantList jink_list = use.from->tag["Jink_" + use.card->toString()].toList();
			int index = 0;
			bool play_effect = false;
			if (triggerEvent == TargetSpecified) {
				foreach(ServerPlayer *p, use.to) {
					if (p->isFemale()) {
						play_effect = true;
						if (jink_list.at(index).toInt() == 1)
							jink_list.replace(index, QVariant(2));
					}
					index++;
				}
				use.from->tag["Jink_" + use.card->toString()] = QVariant::fromValue(jink_list);
				if (play_effect) {
					room->broadcastSkillInvoke(objectName(), 1);
					room->sendCompulsoryTriggerLog(use.from, objectName());
				}
			}
			else if (triggerEvent == TargetConfirmed && use.from->isFemale()) {
				foreach(ServerPlayer *p, use.to) {
					if (p == player) {
						if (jink_list.at(index).toInt() == 1) {
							play_effect = true;
							jink_list.replace(index, QVariant(2));
						}
					}
					index++;
				}
				use.from->tag["Jink_" + use.card->toString()] = QVariant::fromValue(jink_list);

				if (play_effect) {
					bool drunk = (use.card->tag.value("drunk", 0).toInt() > 0);
					int index = drunk ? 3 : 2;
					room->broadcastSkillInvoke(objectName(), index);
					room->sendCompulsoryTriggerLog(player, objectName());
				}
			}
		}

		return false;
	}
};

class Baonue : public TriggerSkill
{
public:
	Baonue() : TriggerSkill("baonue$")
	{
		events << Damage << PreDamageDone;
		global = true;
	}

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		DamageStruct damage = data.value<DamageStruct>();
		if (triggerEvent == PreDamageDone && damage.from)
			damage.from->tag["InvokeBaonue"] = damage.from->getKingdom() == "qun";
		else if (triggerEvent == Damage && player->tag.value("InvokeBaonue", false).toBool() && player->isAlive()) {
			QList<ServerPlayer *> dongzhuos;
			foreach(ServerPlayer *p, room->getOtherPlayers(player)) {
				if (p->hasLordSkill(this))
					dongzhuos << p;
			}

			while (!dongzhuos.isEmpty()) {
				ServerPlayer *dongzhuo = room->askForPlayerChosen(player, dongzhuos, objectName(), "@baonue-to", true);
				if (dongzhuo) {
					dongzhuos.removeOne(dongzhuo);

					LogMessage log;
					log.type = "#InvokeOthersSkill";
					log.from = player;
					log.to << dongzhuo;
					log.arg = objectName();
					room->sendLog(log);
					room->notifySkillInvoked(dongzhuo, objectName());

					JudgeStruct judge;
					judge.pattern = ".|spade";
					judge.good = true;
					judge.reason = objectName();
					judge.who = player;

					room->judge(judge);

					if (judge.isGood()) {

						room->broadcastSkillInvoke(objectName());

						room->recover(dongzhuo, RecoverStruct(player));
					}
				}
				else
					break;
			}
		}
		return false;
	}
};

class Wansha : public TriggerSkill
{
public:
	Wansha() : TriggerSkill("wansha")
	{
		// just to broadcast audio effects and to send log messages
		// main part in the AskForPeaches trigger of Game Rule
		events << AskForPeaches;
		frequency = Compulsory;
	}

	virtual bool triggerable(const ServerPlayer *target) const
	{
		return target != NULL;
	}

	virtual int getPriority(TriggerEvent) const
	{
		return 7;
	}

	virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
	{
		if (player == room->getAllPlayers().first()) {
			DyingStruct dying = data.value<DyingStruct>();
			ServerPlayer *jiaxu = room->getCurrent();
			if (!jiaxu || !TriggerSkill::triggerable(jiaxu) || jiaxu->getPhase() == Player::NotActive)
				return false;
			if (jiaxu->hasInnateSkill("wansha"))
				room->broadcastSkillInvoke(objectName());

			room->notifySkillInvoked(jiaxu, objectName());

			LogMessage log;
			log.from = jiaxu;
			log.arg = objectName();
			if (jiaxu != dying.who) {
				log.type = "#WanshaTwo";
				log.to << dying.who;
			}
			else {
				log.type = "#WanshaOne";
			}
			room->sendLog(log);
		}
		return false;
	}
};

TestPackage::TestPackage()
    : Package("test")
{
    // for test only
    General *zhiba_sunquan = new General(this, "zhiba_sunquan$", "wu", 4, true, true);
    zhiba_sunquan->addSkill(new SuperZhiheng);
    zhiba_sunquan->addSkill("jiuyuan");

    General *super_yuanshu = new General(this, "super_yuanshu", "qun", 4, true, true);
    super_yuanshu->addSkill(new SuperYongsi);
    super_yuanshu->addSkill(new MarkAssignSkill("@yongsi_test", 4));
    related_skills.insertMulti("super_yongsi", "#@yongsi_test-4");
    super_yuanshu->addSkill(new Weidi);

    General *super_caoren = new General(this, "super_caoren", "wei", 4, true, true);
    super_caoren->addSkill(new SuperJushou);
    super_caoren->addSkill(new MarkAssignSkill("@jushou_test", 5));
    related_skills.insertMulti("super_jushou", "#@jushou_test-5");

    General *nobenghuai_dongzhuo = new General(this, "nobenghuai_dongzhuo$", "qun", 4, true, true);
    nobenghuai_dongzhuo->addSkill(new Jiuchi);
    nobenghuai_dongzhuo->addSkill(new Roulin);
    nobenghuai_dongzhuo->addSkill(new Baonue);

	General *zombie = new General(this, "zombie", "die", 3, true, true);
	zombie->addSkill(new Xunmeng);
	zombie->addSkill(new Ganran);
	zombie->addSkill(new Zaibian);

	zombie->addSkill(new Paoxiao);
	zombie->addSkill(new Wansha);

	General *shenlvbu1 = new General(this, "shenlvbu1", "god", 8, true, true); // SP 008 (2-1)
	shenlvbu1->addSkill(new Mashu);
	shenlvbu1->addSkill(new Wushuang);

	General *shenlvbu2 = new General(this, "shenlvbu2", "god", 4, true, true); // SP 008 (2-2)
	shenlvbu2->addSkill("mashu");
	shenlvbu2->addSkill("wushuang");
	shenlvbu2->addSkill(new Xiuluo);
	shenlvbu2->addSkill(new ShenweiKeep);
	shenlvbu2->addSkill(new Shenwei);
	shenlvbu2->addSkill(new Shenji);
	related_skills.insertMulti("shenwei", "#shenwei-draw");

    new General(this, "sujiang", "god", 5, true, true);
    new General(this, "sujiangf", "god", 5, false, true);

    new General(this, "anjiang", "god", 4, true, true, true);

    skills << new SuperMaxCards << new SuperOffensiveDistance << new SuperDefensiveDistance;
}

ADD_PACKAGE(Test)

