#include "testpackage.h"
#include "auxpack.h"
#include "engine.h"
#include "clientplayer.h"
#include "standard-skillcards.h"
#include "maneuvering.h"

class SuperZhiheng : public ViewAsSkill
{
public:
	SuperZhiheng() : ViewAsSkill("super_zhiheng")
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
		return player->canDiscard(player, "he") && player->usedTimes("ZhihengCard") < (player->getLostHp() + 1);
	}

	virtual bool isEnabledAtResponse(const Player *, const QString &pattern) const
	{
		return pattern == "@zhiheng";
	}
};

class SuperYongsi : public TriggerSkill
{
public:
	SuperYongsi() : TriggerSkill("super_yongsi")
	{
		events << DrawNCards << EventPhaseStart;
		frequency = Compulsory;
	};

	virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *yuanshu, QVariant &data) const
	{
		if (triggerEvent == DrawNCards) {
			int x = yuanshu->getMark("@yongsi_test");
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
			int x = yuanshu->getMark("@yongsi_test");
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
	};
};

class SuperJushou : public PhaseChangeSkill
{
public:
	SuperJushou() : PhaseChangeSkill("super_jushou")
	{
	}

	virtual bool onPhaseChange(ServerPlayer *target) const
	{
		if (target->getPhase() == Player::Finish) {
			Room *room = target->getRoom();
			if (room->askForSkillInvoke(target, objectName())) {
				room->broadcastSkillInvoke(objectName());
				target->drawCards(target->getMark("@jushou_test"), objectName());
				target->turnOver();
			}
		}

		return false;
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

GanranEquip::GanranEquip(Card::Suit suit, int number)
:IronChain(suit, number)
{

}

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
			CardUseStruct use = data.value<CardUseStruct>();
			if (use.card->isKindOf("Slash") && TriggerSkill::triggerable(player)) {
				room->broadcastSkillInvoke(objectName());
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
					room->broadcastSkillInvoke(objectName());
					room->sendCompulsoryTriggerLog(player, objectName());

					QStringList wushuang_tag;
					foreach(ServerPlayer *to, use.to)
						wushuang_tag << to->objectName();
					player->tag["Wushuang_" + use.card->toString()] = wushuang_tag;
				}
				foreach(ServerPlayer *p, use.to.toSet()) {
					if (TriggerSkill::triggerable(p)) {
						room->broadcastSkillInvoke(objectName());
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

TestPackage::TestPackage()
: Package("test")
{
	//制霸孙权
	General *zhiba_sunquan = new General(this, "zhiba_sunquan", "wu");
	zhiba_sunquan->addSkill(new SuperZhiheng);
	zhiba_sunquan->addSkill("jiuyuan");
	zhiba_sunquan->setRealName("sunquan");
	//四庸袁术
	General *super_yuanshu = new General(this, "super_yuanshu", "qun");
	super_yuanshu->addSkill(new SuperYongsi);
	super_yuanshu->addSkill(new MarkAssignSkill("@yongsi_test", 4));
	related_skills.insertMulti("super_yongsi", "#@yongsi_test-4");
	super_yuanshu->addSkill(new DummySkill("weidi"));
	super_yuanshu->setRealName("yuanshu");
	//蹲坑曹仁
	General *super_caoren = new General(this, "super_caoren", "wei");
	super_caoren->addSkill(new SuperJushou);
	super_caoren->addSkill(new MarkAssignSkill("@jushou_test", 5));
	related_skills.insertMulti("super_jushou", "#@jushou_test-5");
	super_caoren->setRealName("caoren");
	//无崩董卓
	General *nobenghuai_dongzhuo = new General(this, "nobenghuai_dongzhuo", "qun");
	nobenghuai_dongzhuo->addSkill(new Jiuchi);
	nobenghuai_dongzhuo->addSkill(new Roulin);
	nobenghuai_dongzhuo->addSkill(new DummySkill("baonue", Skill::NotFrequent));
	nobenghuai_dongzhuo->setRealName("dongzhuo");
	nobenghuai_dongzhuo->setOrder(4);
	//最强神话
	General *zqsh = new General(this, "zqsh", "god", 8);
	zqsh->addSkill(new Mashu);
	zqsh->addSkill(new Wushuang);
	zqsh->setRealName("lvbu");
	zqsh->setOrder(10);
	//暴怒战神
	General *bnzs = new General(this, "bnzs", "god");
	bnzs->addSkill("mashu");
	bnzs->addSkill("wushuang");
	bnzs->addSkill(new Xiuluo);
	bnzs->addSkill(new ShenweiKeep);
	bnzs->addSkill(new Shenwei);
	bnzs->addSkill(new DummySkill("shenji"));
	related_skills.insertMulti("shenwei", "#shenwei-draw");
	bnzs->setRealName("lvbu");
	//僵尸
	General *zombie = new General(this, "zombie", "die", 3);
	zombie->addSkill(new Xunmeng);
	zombie->addSkill(new Ganran);
	zombie->addSkill(new Zaibian);
	zombie->addSkill(new Paoxiao);
	zombie->addSkill(new DummySkill("wansha"));
	zombie->setOrder(4);
	//素将
	General *sujiang = new General(this, "sujiang", "god", 5, true, true);
	sujiang->setOrder(3);
	//素将（女）
	General *sujiangf = new General(this, "sujiangf", "god", 5, false, true);
	sujiangf->setOrder(3);
	//暗将
	new General(this, "anjiang", "god", 4, true, true, true);

	skills << new SuperMaxCards << new SuperOffensiveDistance << new SuperDefensiveDistance;

	addMetaObject<GanranEquip>();
}

ADD_PACKAGE(Test)
