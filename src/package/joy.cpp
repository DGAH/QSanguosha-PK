#include "joy.h"
#include "engine.h"
#include "standard-skillcards.h"
#include "clientplayer.h"

Shit::Shit(Card::Suit suit, int number)
    :BasicCard(suit, number)
{
	setObjectName("shit");
	target_fixed = true;
}

QString Shit::getSubtype() const
{
	return "disgusting_card";
}

class ShitEffect : public TriggerSkill
{
public:
	ShitEffect() :TriggerSkill("#shit_effect")
	{
		events << CardsMoveOneTime;
		frequency = Compulsory;
		global = true;
	}

	virtual bool trigger(TriggerEvent , Room *room, ServerPlayer *player, QVariant &data) const
	{
		CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
		if (move.from != player)
			return false;
		if (move.to_place != Player::DiscardPile) {
			if (move.to_place != Player::PlaceTable) {
				if (move.to_place != Player::PlaceTable)
					return false;
			}
		}
		for (int i = 0; i < move.card_ids.length(); i++) {
			if (move.from_places.at(i) != Player::PlaceHand)
				continue;
			int id = move.card_ids.at(i);
			const Card *card = Sanguosha->getCard(id);
			if (!card->isKindOf("Shit"))
				continue;
			LogMessage msg;
			msg.from = player;
			msg.card_str = card->toString();
			Card::Suit suit = card->getSuit();
			if (suit == Card::Spade) {
				msg.type = "$ShitLostHp";
				room->sendLog(msg);
				room->loseHp(player);
			}
			else{
				msg.type = "$ShitDamage";
				room->sendLog(msg);
				DamageStruct damage;
				damage.from = player;
				damage.to = player;
				damage.card = card;
				switch (suit)
				{
				case Card::Club:
					damage.nature = DamageStruct::Thunder;
					break;
				case Card::Heart:
					damage.nature = DamageStruct::Fire;
					break;
				default:
					damage.nature = DamageStruct::Thunder;
					break;
				}
				room->damage(damage);
			}
			if (player->isDead())
				return false;
		}
	}

	virtual bool triggerable(ServerPlayer *target) const
	{
		return target && target->isAlive();
	}
};

// -----------  Deluge -----------------

Deluge::Deluge(Card::Suit suit, int number)
    :Disaster(suit, number)
{
    setObjectName("deluge");

    judge.pattern = ".|.|1,13";
    judge.good = false;
    judge.reason = objectName();
}

void Deluge::takeEffect(ServerPlayer *target) const
{
    QList<const Card *> cards = target->getCards("he");

    Room *room = target->getRoom();
    int n = qMin(cards.length(), target->aliveCount());
    if (n == 0)
        return;

    qShuffle(cards);
    cards = cards.mid(0, n);

    QList<int> card_ids;
    foreach (const Card *card, cards) {
        card_ids << card->getEffectiveId();
        room->throwCard(card, NULL);
    }

    room->fillAG(card_ids);

    QList<ServerPlayer *> players = room->getAllPlayers();
    players.removeAll(target);
    players << target;
    players = players.mid(0, n);
    foreach (ServerPlayer *player, players) {
        if (player->isAlive()) {
            int card_id = room->askForAG(player, card_ids, false, "deluge");
            card_ids.removeOne(card_id);

            room->takeAG(player, card_id);
        }
    }

    foreach(int card_id, card_ids)
        room->takeAG(NULL, card_id);

    room->clearAG();
}

// -----------  Typhoon -----------------

Typhoon::Typhoon(Card::Suit suit, int number)
    :Disaster(suit, number)
{
    setObjectName("typhoon");

    judge.pattern = ".|diamond|2~9";
    judge.good = false;
    judge.reason = objectName();
}

void Typhoon::takeEffect(ServerPlayer *target) const
{
    Room *room = target->getRoom();
    QList<ServerPlayer *> players = room->getAllPlayers();
    foreach (ServerPlayer *player, players) {
        if (target->distanceTo(player) == 1) {
            int discard_num = qMin(6, player->getHandcardNum());
            if (discard_num != 0) {
                room->askForDiscard(player, objectName(), discard_num, discard_num);
            }

            room->getThread()->delay();
        }
    }
}

// -----------  Earthquake -----------------

Earthquake::Earthquake(Card::Suit suit, int number)
    :Disaster(suit, number)
{
    setObjectName("earthquake");

    judge.pattern = ".|club|2~9";
    judge.good = false;
    judge.reason = objectName();
}

void Earthquake::takeEffect(ServerPlayer *target) const
{
    Room *room = target->getRoom();
    QList<ServerPlayer *> players = room->getAllPlayers();
    foreach (ServerPlayer *player, players) {
        bool plus1Horse = (player->getOffensiveHorse() != NULL);
        int distance = 2 - target->distanceTo(player, plus1Horse ? -1 : 0); // ignore plus 1 horse
        if (distance <= 1) {
            if (!player->getEquips().isEmpty())
                player->throwAllEquips();

            room->getThread()->delay();
        }
    }
}

// -----------  Volcano -----------------

Volcano::Volcano(Card::Suit suit, int number)
    :Disaster(suit, number)
{
    setObjectName("volcano");

    judge.pattern = ".|heart|2~9";
    judge.good = false;
    judge.reason = objectName();
}

void Volcano::takeEffect(ServerPlayer *target) const
{
    Room *room = target->getRoom();

    DamageStruct damage;
    damage.card = this;
    damage.damage = 2;
    damage.to = target;
    damage.nature = DamageStruct::Fire;
    room->damage(damage);

    QList<ServerPlayer *> players = room->getAllPlayers();
    players.removeAll(target);

    foreach (ServerPlayer *player, players) {
        bool plus1Horse = (player->getOffensiveHorse() != NULL);
        int distance = target->distanceTo(player, plus1Horse ? -1 : 0); // ignore plus 1 horse
        if (distance == 1) {
            DamageStruct damage;
            damage.card = this;
            damage.damage = 1;
            damage.to = player;
            damage.nature = DamageStruct::Fire;
            room->damage(damage);
        }
    }
}

// -----------  MudSlide -----------------
MudSlide::MudSlide(Card::Suit suit, int number)
    :Disaster(suit, number)
{
    setObjectName("mudslide");

    judge.pattern = ".|black|1,13,4,7";
    judge.good = false;
    judge.reason = objectName();
}

void MudSlide::takeEffect(ServerPlayer *target) const
{
    Room *room = target->getRoom();
    QList<ServerPlayer *> players = room->getAllPlayers();
    int to_destroy = 4;
    foreach (ServerPlayer *player, players) {
        QList<const Card *> equips = player->getEquips();
        if (equips.isEmpty()) {
            DamageStruct damage;
            damage.card = this;
            damage.to = player;
            room->damage(damage);
        } else {
            int n = qMin(equips.length(), to_destroy);
            for (int i = 0; i < n; i++) {
                CardMoveReason reason(CardMoveReason::S_REASON_DISCARD, QString(), QString(), "mudslide");
                room->throwCard(equips.at(i), reason, player);
            }

            to_destroy -= n;
            if (to_destroy == 0)
                break;
        }
    }
}

class GrabPeach : public TriggerSkill
{
public:
    GrabPeach() :TriggerSkill("grab_peach")
    {
        events << CardUsed;
        global = true;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent, Room* room, ServerPlayer *player, QVariant &data) const
    {
        CardUseStruct use = data.value<CardUseStruct>();
        if (use.card->isKindOf("Peach")) {
            QList<ServerPlayer *> players = room->getOtherPlayers(player);

            foreach (ServerPlayer *p, players) {
                if (p->getOffensiveHorse() != NULL && p->getOffensiveHorse()->isKindOf("Monkey") && p->getMark("Equips_Nullified_to_Yourself") == 0 &&
                    p->askForSkillInvoke("grab_peach", data)) {
                    room->throwCard(p->getOffensiveHorse(), p);
                    p->obtainCard(use.card);

                    use.to.clear();
                    data = QVariant::fromValue(use);
                }
            }
        }

        return false;
    }
};

Monkey::Monkey(Card::Suit suit, int number)
    :OffensiveHorse(suit, number)
{
    setObjectName("monkey");
}


class GaleShellSkill : public ArmorSkill
{
public:
    GaleShellSkill() :ArmorSkill("gale_shell")
    {
        events << DamageInflicted;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.nature == DamageStruct::Fire) {
            LogMessage log;
            log.type = "#GaleShellDamage";
            log.from = player;
            log.arg = QString::number(damage.damage);
            log.arg2 = QString::number(++damage.damage);
            room->sendLog(log);

            data = QVariant::fromValue(damage);
        }
        return false;
    }
};

GaleShell::GaleShell(Suit suit, int number) :Armor(suit, number)
{
    setObjectName("gale_shell");

    target_fixed = false;
}

bool GaleShell::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && Self->distanceTo(to_select) <= 1;
}

/*
1.rende
2.jizhi
3.jieyin
4.guose
5.kurou
*/

FiveLinesRendeCard::FiveLinesRendeCard()
{
	will_throw = false;
	handling_method = Card::MethodNone;
	m_skillName = "FiveLinesRenDe";
}

void FiveLinesRendeCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const
{
	ServerPlayer *target = targets.first();

	CardMoveReason reason(CardMoveReason::S_REASON_GIVE, source->objectName(), target->objectName(), "FiveLinesRenDe", QString());
	room->obtainCard(target, this, reason, false);

	int old_value = source->getMark("fivelinesrende");
	int new_value = old_value + subcards.length();
	room->setPlayerMark(source, "fivelinesrende", new_value);

	if (old_value < 2 && new_value >= 2)
		room->recover(source, RecoverStruct(source));
}

FiveLinesJieyinCard::FiveLinesJieyinCard()
{
	m_skillName = "FiveLinesJieYin";
}

bool FiveLinesJieyinCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
	if (!targets.isEmpty())
		return false;

	return to_select->isMale() && to_select->isWounded() && to_select != Self;
}

void FiveLinesJieyinCard::onEffect(const CardEffectStruct &effect) const
{
	Room *room = effect.from->getRoom();
	RecoverStruct recover(effect.from);
	room->recover(effect.from, recover, true);
	room->recover(effect.to, recover, true);
}

FiveLinesKurouCard::FiveLinesKurouCard()
{
	target_fixed = true;
	m_skillName = "FiveLinesKuRou";
}

void FiveLinesKurouCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &) const
{
	room->loseHp(source);
	if (source->isAlive())
		room->drawCards(source, 2, "FiveLinesKuRou");
}

class FiveLinesVS : public ViewAsSkill
{
public:
    FiveLinesVS() : ViewAsSkill("five_lines")
    {
        //response_or_use = true;
    }

    virtual bool isResponseOrUse() const
    {
        return Self->getHp() == 4;
    }

    virtual bool viewFilter(const QList<const Card *> &selected, const Card *to_select) const
    {
        const Card *armor = Self->getArmor();
        if (armor != NULL) {
            if (to_select->getId() == armor->getId())
                return false;
        }

        int hp = Self->getHp();
        if (hp <= 0)
            hp = 1;
        else if (hp > 5)
            hp = 5;

        switch (hp) {
        case 1:
            return !to_select->isEquipped();
            break;
        case 2:
            return false; // Trigger Skill
            break;
        case 3:
            return selected.length() < 2 && !to_select->isEquipped() && !Self->isJilei(to_select);
            break;
        case 4:
            return selected.isEmpty() && to_select->getSuit() == Card::Diamond;
            break;
        case 5:
			return false; // Zero Card View As Skill
            break;
        }

        return false;
    }

    virtual const Card *viewAs(const QList<const Card *> &cards) const
    {
        int hp = Self->getHp();
        if (hp <= 0)
            hp = 1;
        else if (hp > 5)
            hp = 5;

        switch (hp) {
        case 1:
            if (cards.length() > 0) {
                FiveLinesRendeCard *rd = new FiveLinesRendeCard;
                rd->addSubcards(cards);
                return rd;
            }
            return NULL;
            break;
        case 2:
            return NULL; // Trigger Skill
            break;
        case 3:
            if (cards.length() == 2) {
                FiveLinesJieyinCard *jy = new FiveLinesJieyinCard;
                jy->addSubcards(cards);
                return jy;
            }
            return NULL;
            break;
        case 4:
            if (cards.length() == 1) {
				const Card *diamond = cards.first();
				Indulgence *gs = new Indulgence(diamond->getSuit(), diamond->getNumber());
				gs->addSubcard(diamond);
				gs->setSkillName("FiveLinesGuoSe");
                return gs;
            }
            return NULL;
            break;
        case 5:
			return new FiveLinesKurouCard;
            break;
        }

        return NULL;
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        int hp = Self->getHp();
        if (hp <= 0)
            hp = 1;
        else if (hp > 5)
            hp = 5;

        switch (hp) {
        case 1:
			return !player->isKongcheng(); // FiveLinesRendeCard
            break;
        case 2:
            return false; // Trigger Skill
            break;
        case 3:
            return !player->hasUsed("FiveLinesJieyinCard");
            break;
        case 4:
			return true; // Indulgence
            break;
        case 5:
			return true; // FiveLinesKurouCard
            break;
        }

        return false;
    }
};

class FiveLinesSkill : public ArmorSkill
{
public:
    FiveLinesSkill() : ArmorSkill("five_lines")
    {
		events << EventPhaseChanging << CardUsed;
        view_as_skill = new FiveLinesVS;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
		return ArmorSkill::triggerable(target);
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
		int hp = player->getHp();
		if (triggerEvent == EventPhaseChanging) {
			PhaseChangeStruct change = data.value<PhaseChangeStruct>();
			if (change.to != Player::NotActive)
				return false;
			room->setPlayerMark(player, "fivelinesrende", 0);
			return false;
		}
		else if (triggerEvent == CardUsed && hp == 2) {
			CardUseStruct use = data.value<CardUseStruct>();
			if (use.card != NULL && use.card->isNDTrick() && player->askForSkillInvoke("FiveLinesJiZhi", data)) {
				room->broadcastSkillInvoke("FiveLinesJiZhi");
				player->drawCards(1, objectName());
			}
		}
        return false;
    }
};

FiveLines::FiveLines(Card::Suit suit, int number)
    : Armor(suit, number)
{
    setObjectName("five_lines");
}

DisasterPackage::DisasterPackage()
    :Package("Disaster")
{
    QList<Card *> cards;

    cards << new Deluge(Card::Spade, 1)
        << new Typhoon(Card::Spade, 4)
        << new Earthquake(Card::Club, 10)
        << new Volcano(Card::Heart, 13)
        << new MudSlide(Card::Heart, 7);

    foreach(Card *card, cards)
        card->setParent(this);

    type = CardPack;
}

JoyPackage::JoyPackage()
    :Package("joy")
{
    QList<Card *> cards;

    cards << new Shit(Card::Club, 1)
    << new Shit(Card::Heart, 8)
    << new Shit(Card::Diamond, 13)
    << new Shit(Card::Spade, 10);

    foreach(Card *card, cards)
    card->setParent(this);

	skills << new ShitEffect;

    type = CardPack;
}

class YxSwordSkill : public WeaponSkill
{
public:
    YxSwordSkill() :WeaponSkill("yx_sword")
    {
        events << DamageCaused;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.card && damage.card->isKindOf("Slash")) {
            QList<ServerPlayer *> players = room->getOtherPlayers(player);
            QMutableListIterator<ServerPlayer *> itor(players);

            while (itor.hasNext()) {
                itor.next();
                if (!player->inMyAttackRange(itor.value()))
                    itor.remove();
            }

            if (players.isEmpty())
                return false;

            QVariant _data = QVariant::fromValue(damage);
            room->setTag("YxSwordData", _data);
            ServerPlayer *target = room->askForPlayerChosen(player, players, objectName(), "@yxsword-select", true, true);
            room->removeTag("YxSwordData");
            if (target != NULL) {
                damage.from = target;
                data = QVariant::fromValue(damage);
                room->moveCardTo(player->getWeapon(), player, target, Player::PlaceHand,
                    CardMoveReason(CardMoveReason::S_REASON_TRANSFER, player->objectName(), objectName(), QString()));
            }
        }
        return damage.to->isDead();
    }
};

YxSword::YxSword(Suit suit, int number)
    :Weapon(suit, number, 3)
{
    setObjectName("yx_sword");
}

JoyEquipPackage::JoyEquipPackage()
    : Package("JoyEquip")
{
    (new Monkey(Card::Diamond, 5))->setParent(this);
    (new GaleShell(Card::Heart, 1))->setParent(this);
    (new YxSword(Card::Club, 9))->setParent(this);
    (new FiveLines(Card::Heart, 5))->setParent(this);

    type = CardPack;
    skills << new GaleShellSkill << new YxSwordSkill << new GrabPeach << new FiveLinesSkill;

	addMetaObject<FiveLinesRendeCard>();
	addMetaObject<FiveLinesJieyinCard>();
	addMetaObject<FiveLinesKurouCard>();
}

ADD_PACKAGE(Joy)
ADD_PACKAGE(Disaster)
ADD_PACKAGE(JoyEquip)
