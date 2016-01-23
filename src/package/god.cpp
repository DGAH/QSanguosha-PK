#include "god.h"
#include "client.h"
#include "engine.h"
#include "maneuvering.h"
#include "general.h"
#include "settings.h"

class Wushen : public FilterSkill
{
public:
    Wushen() : FilterSkill("wushen")
    {
    }

    virtual bool viewFilter(const Card *to_select) const
    {
        Room *room = Sanguosha->currentRoom();
        Player::Place place = room->getCardPlace(to_select->getEffectiveId());
        return to_select->getSuit() == Card::Heart && place == Player::PlaceHand;
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        Slash *slash = new Slash(originalCard->getSuit(), originalCard->getNumber());
        slash->setSkillName(objectName());
        WrappedCard *card = Sanguosha->getWrappedCard(originalCard->getId());
        card->takeOver(slash);
        return card;
    }
};

class WushenTargetMod : public TargetModSkill
{
public:
    WushenTargetMod() : TargetModSkill("#wushen-target")
    {
    }

    virtual int getDistanceLimit(const Player *from, const Card *card) const
    {
        if (from->hasSkill("wushen") && card->getSuit() == Card::Heart)
            return 1000;
        else
            return 0;
    }
};

class Wuhun : public TriggerSkill
{
public:
    Wuhun() : TriggerSkill("wuhun")
    {
        events << PreDamageDone;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();

        if (damage.from && damage.from != player) {
            damage.from->gainMark("@nightmare", damage.damage);
            damage.from->getRoom()->broadcastSkillInvoke(objectName(), 1);
            room->notifySkillInvoked(player, objectName());
        }

        return false;
    }
};

class WuhunRevenge : public TriggerSkill
{
public:
    WuhunRevenge() : TriggerSkill("#wuhun")
    {
        events << Death;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->hasSkill("wuhun");
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *shenguanyu, QVariant &data) const
    {
        DeathStruct death = data.value<DeathStruct>();
        if (death.who != shenguanyu)
            return false;

        QList<ServerPlayer *> players = room->getOtherPlayers(shenguanyu);

        int max = 0;
        foreach(ServerPlayer *player, players)
            max = qMax(max, player->getMark("@nightmare"));
        if (max == 0) return false;

        QList<ServerPlayer *> foes;
        foreach (ServerPlayer *player, players) {
            if (player->getMark("@nightmare") == max)
                foes << player;
        }

        if (foes.isEmpty())
            return false;

        ServerPlayer *foe;
        if (foes.length() == 1)
            foe = foes.first();
        else
            foe = room->askForPlayerChosen(shenguanyu, foes, "wuhun", "@wuhun-revenge");

        room->notifySkillInvoked(shenguanyu, "wuhun");

        JudgeStruct judge;
        judge.pattern = "Peach,GodSalvation";
        judge.good = true;
        judge.negative = true;
        judge.reason = "wuhun";
        judge.who = foe;

        room->judge(judge);

        if (judge.isBad()) {
            room->broadcastSkillInvoke("wuhun", 2);
            //room->doLightbox("$WuhunAnimate", 3000);
            room->doSuperLightbox("shenguanyu", "wuhun");

            LogMessage log;
            log.type = "#WuhunRevenge";
            log.from = shenguanyu;
            log.to << foe;
            log.arg = QString::number(max);
            log.arg2 = "wuhun";
            room->sendLog(log);

            room->killPlayer(foe);
        } else
            room->broadcastSkillInvoke("wuhun", 3);
        QList<ServerPlayer *> killers = room->getAllPlayers();
        foreach(ServerPlayer *player, killers)
            player->loseAllMarks("@nightmare");

        return false;
    }
};

static bool CompareBySuit(int card1, int card2)
{
    const Card *c1 = Sanguosha->getCard(card1);
    const Card *c2 = Sanguosha->getCard(card2);

    int a = static_cast<int>(c1->getSuit());
    int b = static_cast<int>(c2->getSuit());

    return a < b;
}

class Shelie : public PhaseChangeSkill
{
public:
    Shelie() : PhaseChangeSkill("shelie")
    {
    }

    virtual bool onPhaseChange(ServerPlayer *shenlvmeng) const
    {
        if (shenlvmeng->getPhase() != Player::Draw)
            return false;

        Room *room = shenlvmeng->getRoom();
        if (!shenlvmeng->askForSkillInvoke(this))
            return false;

        room->broadcastSkillInvoke(objectName());

        QList<int> card_ids = room->getNCards(5);
        qSort(card_ids.begin(), card_ids.end(), CompareBySuit);
        room->fillAG(card_ids);

        QList<int> to_get, to_throw;
        while (!card_ids.isEmpty()) {
            int card_id = room->askForAG(shenlvmeng, card_ids, false, "shelie");
            card_ids.removeOne(card_id);
            to_get << card_id;
            // throw the rest cards that matches the same suit
            const Card *card = Sanguosha->getCard(card_id);
            Card::Suit suit = card->getSuit();

            room->takeAG(shenlvmeng, card_id, false);

            QList<int> _card_ids = card_ids;
            foreach (int id, _card_ids) {
                const Card *c = Sanguosha->getCard(id);
                if (c->getSuit() == suit) {
                    card_ids.removeOne(id);
                    room->takeAG(NULL, id, false);
                    to_throw.append(id);
                }
            }
        }
        DummyCard *dummy = new DummyCard;
        if (!to_get.isEmpty()) {
            dummy->addSubcards(to_get);
            shenlvmeng->obtainCard(dummy);
        }
        dummy->clearSubcards();
        if (!to_throw.isEmpty()) {
            dummy->addSubcards(to_throw);
            CardMoveReason reason(CardMoveReason::S_REASON_NATURAL_ENTER, shenlvmeng->objectName(), objectName(), QString());
            room->throwCard(dummy, reason, NULL);
        }
        delete dummy;
        room->clearAG();
        return true;
    }
};

GongxinCard::GongxinCard()
{
}

bool GongxinCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select != Self;
}

void GongxinCard::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.from->getRoom();
    if (!effect.to->isKongcheng()) {
        QList<int> ids;
        foreach (const Card *card, effect.to->getHandcards()) {
            if (card->getSuit() == Card::Heart)
                ids << card->getEffectiveId();
        }

        int card_id = room->doGongxin(effect.from, effect.to, ids);
        if (card_id == -1) return;

        QString result = room->askForChoice(effect.from, "gongxin", "discard+put");
        effect.from->tag.remove("gongxin");
        if (result == "discard") {
            CardMoveReason reason(CardMoveReason::S_REASON_DISMANTLE, effect.from->objectName(), QString(), "gongxin", QString());
            room->throwCard(Sanguosha->getCard(card_id), reason, effect.to, effect.from);
        } else {
            effect.from->setFlags("Global_GongxinOperator");
            CardMoveReason reason(CardMoveReason::S_REASON_PUT, effect.from->objectName(), QString(), "gongxin", QString());
            room->moveCardTo(Sanguosha->getCard(card_id), effect.to, NULL, Player::DrawPile, reason, true);
            effect.from->setFlags("-Global_GongxinOperator");
        }
    }
}

class Gongxin : public ZeroCardViewAsSkill
{
public:
    Gongxin() : ZeroCardViewAsSkill("gongxin")
    {
    }

    virtual const Card *viewAs() const
    {
        return new GongxinCard;
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->hasUsed("GongxinCard");
    }

    virtual int getEffectIndex(const ServerPlayer *player, const Card *) const
    {
        int index = qrand() % 2 + 1;
        if (!player->hasInnateSkill(this) && player->getMark("qinxue") > 0)
            index += 2;
        return index;
    }
};

void YeyanCard::damage(ServerPlayer *shenzhouyu, ServerPlayer *target, int point) const
{
    shenzhouyu->getRoom()->damage(DamageStruct("yeyan", shenzhouyu, target, point, DamageStruct::Fire));
}

GreatYeyanCard::GreatYeyanCard()
{
    mute = true;
    m_skillName = "yeyan";
}

bool GreatYeyanCard::targetFilter(const QList<const Player *> &, const Player *, const Player *) const
{
    Q_ASSERT(false);
    return false;
}

bool GreatYeyanCard::targetsFeasible(const QList<const Player *> &targets, const Player *) const
{
    if (subcards.length() != 4) return false;
    QList<Card::Suit> allsuits;
    foreach (int cardId, subcards) {
        const Card *card = Sanguosha->getCard(cardId);
        if (allsuits.contains(card->getSuit())) return false;
        allsuits.append(card->getSuit());
    }

    //We can only assign 2 damage to one player
    //If we select only one target only once, we assign 3 damage to the target
    if (targets.toSet().size() == 1)
        return true;
    else if (targets.toSet().size() == 2)
        return targets.size() == 3;
    return false;
}

bool GreatYeyanCard::targetFilter(const QList<const Player *> &targets, const Player *to_select,
    const Player *, int &maxVotes) const
{
    int i = 0;
    foreach(const Player *player, targets)
        if (player == to_select) i++;
    maxVotes = qMax(3 - targets.size(), 0) + i;
    return maxVotes > 0;
}

void GreatYeyanCard::use(Room *room, ServerPlayer *shenzhouyu, QList<ServerPlayer *> &targets) const
{
    int criticaltarget = 0;
    int totalvictim = 0;
    QMap<ServerPlayer *, int> map;

    foreach(ServerPlayer *sp, targets)
        map[sp]++;

    if (targets.size() == 1)
        map[targets.first()] += 2;

    foreach (ServerPlayer *sp, map.keys()) {
        if (map[sp] > 1) criticaltarget++;
        totalvictim++;
    }
    if (criticaltarget > 0) {
        room->removePlayerMark(shenzhouyu, "@flame");
        room->loseHp(shenzhouyu, 3);

        room->broadcastSkillInvoke("yeyan", (totalvictim > 1) ? 2 : 3);
        //room->doLightbox("$YeyanAnimate");
        room->doSuperLightbox("shenzhouyu", "yeyan");

        QList<ServerPlayer *> targets = map.keys();
        room->sortByActionOrder(targets);
        foreach(ServerPlayer *sp, targets)
            damage(shenzhouyu, sp, map[sp]);
    }
}

SmallYeyanCard::SmallYeyanCard()
{
    mute = true;
    m_skillName = "yeyan";
}

bool SmallYeyanCard::targetsFeasible(const QList<const Player *> &targets, const Player *) const
{
    return !targets.isEmpty();
}

bool SmallYeyanCard::targetFilter(const QList<const Player *> &targets, const Player *, const Player *) const
{
    return targets.length() < 3;
}

void SmallYeyanCard::use(Room *room, ServerPlayer *shenzhouyu, QList<ServerPlayer *> &targets) const
{
    room->broadcastSkillInvoke("yeyan", 1);
    //room->doLightbox("$YeyanAnimate");
    room->doSuperLightbox("shenzhouyu", "yeyan");
    room->removePlayerMark(shenzhouyu, "@flame");
    Card::use(room, shenzhouyu, targets);
}

void SmallYeyanCard::onEffect(const CardEffectStruct &effect) const
{
    damage(effect.from, effect.to, 1);
}

class Yeyan : public ViewAsSkill
{
public:
    Yeyan() : ViewAsSkill("yeyan")
    {
        frequency = Limited;
        limit_mark = "@flame";
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return player->getMark("@flame") >= 1;
    }

    virtual bool viewFilter(const QList<const Card *> &selected, const Card *to_select) const
    {
        if (selected.length() >= 4)
            return false;

        if (to_select->isEquipped())
            return false;

        if (Self->isJilei(to_select))
            return false;

        foreach (const Card *item, selected) {
            if (to_select->getSuit() == item->getSuit())
                return false;
        }

        return true;
    }

    virtual const Card *viewAs(const QList<const Card *> &cards) const
    {
        if (cards.length() == 0)
            return new SmallYeyanCard;
        if (cards.length() != 4)
            return NULL;

        GreatYeyanCard *card = new GreatYeyanCard;
        card->addSubcards(cards);

        return card;
    }
};

class Qinyin : public TriggerSkill
{
public:
    Qinyin() : TriggerSkill("qinyin")
    {
        events << CardsMoveOneTime << EventPhaseEnd << EventPhaseChanging;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    void perform(ServerPlayer *shenzhouyu) const
    {
        Room *room = shenzhouyu->getRoom();
        QStringList choices;
        choices << "down" << "cancel";
        QList<ServerPlayer *> all_players = room->getAllPlayers();
        foreach (ServerPlayer *player, all_players) {
            if (player->isWounded()) {
                choices.prepend("up");
                break;
            }
        }
        QString result = room->askForChoice(shenzhouyu, objectName(), choices.join("+"));
        if (result == "cancel")
            return;
        else
            room->notifySkillInvoked(shenzhouyu, "qinyin");
        if (result == "up") {
            room->broadcastSkillInvoke(objectName(), 2);
            foreach(ServerPlayer *player, all_players)
                room->recover(player, RecoverStruct(shenzhouyu));
        } else if (result == "down") {
            foreach(ServerPlayer *player, all_players)
                room->loseHp(player);

            int index = 1;
            if (room->findPlayer("caocao+shencaocao+yt_shencaocao"))
                index = 3;

            room->broadcastSkillInvoke(objectName(), index);
        }
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *, ServerPlayer *shenzhouyu, QVariant &data) const
    {
        if (triggerEvent == CardsMoveOneTime) {
            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
            if (shenzhouyu->getPhase() == Player::Discard && move.from == shenzhouyu
                && (move.reason.m_reason & CardMoveReason::S_MASK_BASIC_REASON) == CardMoveReason::S_REASON_DISCARD) {
                shenzhouyu->addMark("qinyin", move.card_ids.size());
            }
        } else if (triggerEvent == EventPhaseEnd && TriggerSkill::triggerable(shenzhouyu)
            && shenzhouyu->getPhase() == Player::Discard && shenzhouyu->getMark("qinyin") >= 2) {
            perform(shenzhouyu);
        } else if (triggerEvent == EventPhaseChanging) {
            shenzhouyu->setMark("qinyin", 0);
        }
        return false;
    }
};

class Guixin : public MasochismSkill
{
public:
    Guixin() : MasochismSkill("guixin")
    {
    }

    virtual void onDamaged(ServerPlayer *shencc, const DamageStruct &damage) const
    {
        Room *room = shencc->getRoom();
        int n = shencc->getMark("GuixinTimes"); // mark for AI
        shencc->setMark("GuixinTimes", 0);
        QVariant data = QVariant::fromValue(damage);
        QList<ServerPlayer *> players = room->getOtherPlayers(shencc);
        try {
            for (int i = 0; i < damage.damage; i++) {
                shencc->addMark("GuixinTimes");
                if (shencc->askForSkillInvoke(this, data)) {
                    room->broadcastSkillInvoke(objectName());

                    shencc->setFlags("GuixinUsing");
                    /*
                    if (players.length() >= 4 && (shencc->getGeneralName() == "shencaocao" || shencc->getGeneral2Name() == "shencaocao"))
                    room->doLightbox("$GuixinAnimate");
                    */
                    if (shencc->getGeneralName() != "shencaocao" && (shencc->getGeneralName() == "pr_shencaocao" || shencc->getGeneral2Name() == "pr_shencaocao"))
                        ; // room->doSuperLightbox("pr_shencaocao", "guixin");  // todo:pr_shencaocao's avatar
                    else
                        room->doSuperLightbox("shencaocao", "guixin");

                    foreach (ServerPlayer *player, players) {
                        if (player->isAlive() && !player->isAllNude()) {
                            CardMoveReason reason(CardMoveReason::S_REASON_EXTRACTION, shencc->objectName());
                            int card_id = room->askForCardChosen(shencc, player, "hej", objectName());
                            room->obtainCard(shencc, Sanguosha->getCard(card_id),
                                reason, room->getCardPlace(card_id) != Player::PlaceHand);
                        }
                    }

                    shencc->turnOver();
                    shencc->setFlags("-GuixinUsing");
                } else
                    break;
            }
            shencc->setMark("GuixinTimes", n);
        }
        catch (TriggerEvent triggerEvent) {
            if (triggerEvent == TurnBroken || triggerEvent == StageChange) {
                shencc->setFlags("-GuixinUsing");
                shencc->setMark("GuixinTimes", n);
            }
            throw triggerEvent;
        }
    }
};

class Feiying : public DistanceSkill
{
public:
    Feiying() : DistanceSkill("feiying")
    {
    }

    virtual int getCorrect(const Player *, const Player *to) const
    {
        if (to->hasSkill(this))
            return +1;
        else
            return 0;
    }
};

class Kuangbao : public TriggerSkill
{
public:
    Kuangbao() : TriggerSkill("kuangbao")
    {
        events << Damage << Damaged;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();

        LogMessage log;
        log.type = triggerEvent == Damage ? "#KuangbaoDamage" : "#KuangbaoDamaged";
        log.from = player;
        log.arg = QString::number(damage.damage);
        log.arg2 = objectName();
        room->sendLog(log);
        room->notifySkillInvoked(player, objectName());

        room->addPlayerMark(player, "@wrath", damage.damage);
        room->broadcastSkillInvoke(objectName());
        return false;
    }
};

class Wumou : public TriggerSkill
{
public:
    Wumou() : TriggerSkill("wumou")
    {
        frequency = Compulsory;
        events << CardUsed;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        CardUseStruct use = data.value<CardUseStruct>();
        if (use.card->isNDTrick()) {
            room->broadcastSkillInvoke(objectName());
            room->sendCompulsoryTriggerLog(player, objectName());

            int num = player->getMark("@wrath");
            if (num >= 1 && room->askForChoice(player, objectName(), "discard+losehp") == "discard") {
                player->loseMark("@wrath");
            } else
                room->loseHp(player);
        }

        return false;
    }
};

class Shenfen : public ZeroCardViewAsSkill
{
public:
    Shenfen() : ZeroCardViewAsSkill("shenfen")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return player->getMark("@wrath") >= 6 && !player->hasUsed("ShenfenCard");
    }

    virtual const Card *viewAs() const
    {
        return new ShenfenCard;
    }
};

ShenfenCard::ShenfenCard()
{
    target_fixed = true;
    mute = true;
}

void ShenfenCard::use(Room *room, ServerPlayer *shenlvbu, QList<ServerPlayer *> &) const
{
    shenlvbu->setFlags("ShenfenUsing");
    room->broadcastSkillInvoke("shenfen");
    QString name = "shenlvbu";
    if (shenlvbu->getGeneralName() != "shenlvbu" && (shenlvbu->getGeneralName() == "sp_shenlvbu" || shenlvbu->getGeneral2Name() == "sp_shenlvbu"))
        name = "sp_shenlvbu";

    room->doSuperLightbox(name, "shenfen");

    shenlvbu->loseMark("@wrath", 6);

    try {
        QList<ServerPlayer *> players = room->getOtherPlayers(shenlvbu);
        foreach (ServerPlayer *player, players) {
            room->damage(DamageStruct("shenfen", shenlvbu, player));
            room->getThread()->delay();
        }

        foreach (ServerPlayer *player, players) {
            QList<const Card *> equips = player->getEquips();
            player->throwAllEquips();
            if (!equips.isEmpty())
                room->getThread()->delay();
        }

        foreach (ServerPlayer *player, players) {
            bool delay = !player->isKongcheng();
            room->askForDiscard(player, "shenfen", 4, 4);
            if (delay)
                room->getThread()->delay();
        }

        shenlvbu->turnOver();
        shenlvbu->setFlags("-ShenfenUsing");
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken || triggerEvent == StageChange)
            shenlvbu->setFlags("-ShenfenUsing");
        throw triggerEvent;
    }
}

WuqianCard::WuqianCard()
{
}

bool WuqianCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select != Self;
}

void WuqianCard::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.to->getRoom();

    effect.from->loseMark("@wrath", 2);
    room->acquireSkill(effect.from, "wushuang");
    effect.from->setFlags("WuqianSource");
    effect.to->setFlags("WuqianTarget");
    room->addPlayerMark(effect.to, "Armor_Nullified");
}

class WuqianViewAsSkill : public ZeroCardViewAsSkill
{
public:
    WuqianViewAsSkill() : ZeroCardViewAsSkill("wuqian")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return player->getMark("@wrath") >= 2;
    }

    virtual const Card *viewAs() const
    {
        return new WuqianCard;
    }
};

class Wuqian : public TriggerSkill
{
public:
    Wuqian() : TriggerSkill("wuqian")
    {
        events << EventPhaseChanging << Death;
        view_as_skill = new WuqianViewAsSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->hasFlag("WuqianSource");
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == EventPhaseChanging) {
            PhaseChangeStruct change = data.value<PhaseChangeStruct>();
            if (change.to != Player::NotActive)
                return false;
        }
        if (triggerEvent == Death) {
            DeathStruct death = data.value<DeathStruct>();
            if (death.who != player)
                return false;
        }

        foreach (ServerPlayer *p, room->getAllPlayers()) {
            if (p->hasFlag("WuqianTarget")) {
                p->setFlags("-WuqianTarget");
                if (p->getMark("Armor_Nullified") > 0)
                    room->removePlayerMark(p, "Armor_Nullified");
            }
        }
        room->detachSkillFromPlayer(player, "wushuang", false, true);

        return false;
    }
};

QixingCard::QixingCard()
{
    will_throw = false;
    handling_method = Card::MethodNone;
    target_fixed = true;
}

void QixingCard::onUse(Room *room, const CardUseStruct &card_use) const
{
    QList<int> pile = card_use.from->getPile("stars");
    QList<int> subCards = card_use.card->getSubcards();
    QList<int> to_handcard;
    QList<int> to_pile;
    foreach (int id, (subCards + pile).toSet()) {
        if (!subCards.contains(id))
            to_handcard << id;
        else if (!pile.contains(id))
            to_pile << id;
    }

    Q_ASSERT(to_handcard.length() == to_pile.length());

    if (to_pile.length() == 0 || to_handcard.length() != to_pile.length())
        return;

    room->broadcastSkillInvoke("qixing");
    room->notifySkillInvoked(card_use.from, "qixing");

    card_use.from->addToPile("stars", to_pile, false);

    DummyCard to_handcard_x(to_handcard);
    CardMoveReason reason(CardMoveReason::S_REASON_EXCHANGE_FROM_PILE, card_use.from->objectName());
    room->obtainCard(card_use.from, &to_handcard_x, reason, false);

    LogMessage log;
    log.type = "#QixingExchange";
    log.from = card_use.from;
    log.arg = to_pile.length();
    log.arg2 = "qixing";
    room->sendLog(log);
}

class QixingVS : public ViewAsSkill
{
public:
    QixingVS() : ViewAsSkill("qixing")
    {
        response_pattern = "@@qixing";
        expand_pile = "stars";
    }

    virtual bool viewFilter(const QList<const Card *> &selected, const Card *to_select) const
    {
        if (selected.length() < Self->getPile("stars").length())
            return !to_select->isEquipped();

        return false;
    }

    virtual const Card *viewAs(const QList<const Card *> &cards) const
    {
        if (cards.length() == Self->getPile("stars").length()) {
            QixingCard *c = new QixingCard;
            c->addSubcards(cards);
            return c;
        }

        return NULL;
    }
};


class Qixing : public TriggerSkill
{
public:
    Qixing() : TriggerSkill("qixing")
    {
        view_as_skill = new QixingVS;
        events << EventPhaseEnd;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return TriggerSkill::triggerable(target) && target->getPile("stars").length() > 0
            && target->getPhase() == Player::Draw;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *shenzhuge, QVariant &) const
    {
        room->askForUseCard(shenzhuge, "@@qixing", "@qixing-exchange", -1, Card::MethodNone);
        return false;
    }
};

class QixingStart : public TriggerSkill
{
public:
    QixingStart() : TriggerSkill("#qixing")
    {
        events << DrawInitialCards << AfterDrawInitialCards;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *shenzhuge, QVariant &data) const
    {
        if (triggerEvent == DrawInitialCards) {
            room->sendCompulsoryTriggerLog(shenzhuge, "qixing");
            data = data.toInt() + 7;
        } else if (triggerEvent == AfterDrawInitialCards) {
            room->broadcastSkillInvoke("qixing");
            const Card *exchange_card = room->askForExchange(shenzhuge, "qixing", 7, 7);
            shenzhuge->addToPile("stars", exchange_card->getSubcards(), false);
            delete exchange_card;
        }
        return false;
    }
};

class QixingAsk : public PhaseChangeSkill
{
public:
    QixingAsk() : PhaseChangeSkill("#qixing-ask")
    {
    }

    virtual bool onPhaseChange(ServerPlayer *target) const
    {
        Room *room = target->getRoom();
        if (target->getPhase() == Player::Finish) {
            if (target->getPile("stars").length() > 0 && target->hasSkill("kuangfeng"))
                room->askForUseCard(target, "@@kuangfeng", "@kuangfeng-card", -1, Card::MethodNone);

            if (target->getPile("stars").length() > 0 && target->hasSkill("dawu"))
                room->askForUseCard(target, "@@dawu", "@dawu-card", -1, Card::MethodNone);
        }

        return false;
    }
};

class QixingClear : public TriggerSkill
{
public:
    QixingClear() : TriggerSkill("#qixing-clear")
    {
        events << EventPhaseStart << Death << EventLoseSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == EventPhaseStart || triggerEvent == Death) {
            if (triggerEvent == Death) {
                DeathStruct death = data.value<DeathStruct>();
                if (death.who != player)
                    return false;
            }
            if (!player->tag.value("Qixing_user", false).toBool())
                return false;
            bool invoke = false;
            if ((triggerEvent == EventPhaseStart && player->getPhase() == Player::RoundStart) || triggerEvent == Death)
                invoke = true;
            if (!invoke)
                return false;
            QList<ServerPlayer *> players = room->getAllPlayers();
            foreach (ServerPlayer *player, players) {
                player->loseAllMarks("@gale");
                player->loseAllMarks("@fog");
            }
            player->tag.remove("Qixing_user");
        } else if (triggerEvent == EventLoseSkill && data.toString() == "qixing") {
            player->clearOnePrivatePile("stars");
        }

        return false;
    }
};

KuangfengCard::KuangfengCard()
{
    handling_method = Card::MethodNone;
    will_throw = false;
}

bool KuangfengCard::targetFilter(const QList<const Player *> &targets, const Player *, const Player *) const
{
    return targets.isEmpty();
}

void KuangfengCard::onEffect(const CardEffectStruct &effect) const
{
    CardMoveReason reason(CardMoveReason::S_REASON_REMOVE_FROM_PILE, QString(), "kuangfeng", QString());
    effect.to->getRoom()->throwCard(this, reason, NULL);
    effect.from->tag["Qixing_user"] = true;
    effect.to->gainMark("@gale");
}

class KuangfengViewAsSkill : public OneCardViewAsSkill
{
public:
    KuangfengViewAsSkill() : OneCardViewAsSkill("kuangfeng")
    {
        response_pattern = "@@kuangfeng";
        filter_pattern = ".|.|.|stars";
        expand_pile = "stars";
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        KuangfengCard *kf = new KuangfengCard;
        kf->addSubcard(originalCard);
        return kf;
    }
};

class Kuangfeng : public TriggerSkill
{
public:
    Kuangfeng() : TriggerSkill("kuangfeng")
    {
        events << DamageForseen;
        view_as_skill = new KuangfengViewAsSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->getMark("@gale") > 0;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.nature == DamageStruct::Fire) {
            LogMessage log;
            log.type = "#GalePower";
            log.from = player;
            log.arg = QString::number(damage.damage);
            log.arg2 = QString::number(++damage.damage);
            room->sendLog(log);

            data = QVariant::fromValue(damage);
        }

        return false;
    }
};

DawuCard::DawuCard()
{
    handling_method = Card::MethodNone;
    will_throw = false;
}

bool DawuCard::targetFilter(const QList<const Player *> &targets, const Player *, const Player *) const
{
    return targets.length() < subcards.length();
}

bool DawuCard::targetsFeasible(const QList<const Player *> &targets, const Player *) const
{
    return targets.length() == subcards.length();
}

void DawuCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const
{
    CardMoveReason reason(CardMoveReason::S_REASON_REMOVE_FROM_PILE, QString(), "kuangfeng", QString());
    room->throwCard(this, reason, NULL);

    source->tag["Qixing_user"] = true;

    foreach(ServerPlayer *target, targets)
        target->gainMark("@fog");
}

class DawuViewAsSkill : public ViewAsSkill
{
public:
    DawuViewAsSkill() : ViewAsSkill("dawu")
    {
        response_pattern = "@@dawu";
        expand_pile = "stars";
    }

    virtual bool viewFilter(const QList<const Card *> &, const Card *to_select) const
    {
        return Self->getPile("stars").contains(to_select->getId());
    }

    virtual const Card *viewAs(const QList<const Card *> &cards) const
    {
        if (!cards.isEmpty()) {
            DawuCard *dw = new DawuCard;
            dw->addSubcards(cards);
            return dw;
        }

        return NULL;
    }
};

class Dawu : public TriggerSkill
{
public:
    Dawu() : TriggerSkill("dawu")
    {
        events << DamageForseen;
        view_as_skill = new DawuViewAsSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->getMark("@fog") > 0;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.nature != DamageStruct::Thunder) {
            LogMessage log;
            log.type = "#FogProtect";
            log.from = player;
            log.arg = QString::number(damage.damage);
            if (damage.nature == DamageStruct::Normal)
                log.arg2 = "normal_nature";
            else if (damage.nature == DamageStruct::Fire)
                log.arg2 = "fire_nature";
            room->sendLog(log);

            return true;
        } else
            return false;
    }
};

class Renjie : public TriggerSkill
{
public:
    Renjie() : TriggerSkill("renjie")
    {
        events << Damaged << CardsMoveOneTime;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == CardsMoveOneTime) {
            if (player->getPhase() == Player::Discard) {
                CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
                if (move.from == player && (move.reason.m_reason & CardMoveReason::S_MASK_BASIC_REASON) == CardMoveReason::S_REASON_DISCARD) {
                    int n = move.card_ids.length();
                    if (n > 0) {
                        room->broadcastSkillInvoke(objectName());
                        room->notifySkillInvoked(player, objectName());
                        player->gainMark("@bear", n);
                    }
                }
            }
        } else if (triggerEvent == Damaged) {
            room->broadcastSkillInvoke(objectName());
            room->notifySkillInvoked(player, objectName());
            DamageStruct damage = data.value<DamageStruct>();
            player->gainMark("@bear", damage.damage);
        }

        return false;
    }
};

class Baiyin : public PhaseChangeSkill
{
public:
    Baiyin() : PhaseChangeSkill("baiyin")
    {
        frequency = Wake;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && PhaseChangeSkill::triggerable(target)
            && target->getPhase() == Player::Start
            && target->getMark("baiyin") == 0
            && target->getMark("@bear") >= 4;
    }

    virtual bool onPhaseChange(ServerPlayer *shensimayi) const
    {
        Room *room = shensimayi->getRoom();
        room->broadcastSkillInvoke(objectName());
        room->notifySkillInvoked(shensimayi, objectName());
        //room->doLightbox("$BaiyinAnimate");
        room->doSuperLightbox("shensimayi", "baiyin");

        LogMessage log;
        log.type = "#BaiyinWake";
        log.from = shensimayi;
        log.arg = QString::number(shensimayi->getMark("@bear"));
        room->sendLog(log);

        room->setPlayerMark(shensimayi, "baiyin", 1);
        if (room->changeMaxHpForAwakenSkill(shensimayi) && shensimayi->getMark("baiyin") == 1)
            room->acquireSkill(shensimayi, "jilve");

        return false;
    }
};

JilveCard::JilveCard()
{
    target_fixed = true;
    mute = true;
}

void JilveCard::onUse(Room *room, const CardUseStruct &card_use) const
{
    ServerPlayer *shensimayi = card_use.from;

    QStringList choices;
    if (!shensimayi->hasFlag("JilveZhiheng") && shensimayi->canDiscard(shensimayi, "he"))
        choices << "zhiheng";
    if (!shensimayi->hasFlag("JilveWansha"))
        choices << "wansha";
    choices << "cancel";

    if (choices.length() == 1)
        return;

    QString choice = room->askForChoice(shensimayi, "jilve", choices.join("+"));
    if (choice == "cancel") {
        room->addPlayerHistory(shensimayi, "JilveCard", -1);
        return;
    }

    shensimayi->loseMark("@bear");
    room->notifySkillInvoked(shensimayi, "jilve");

    if (choice == "wansha") {
        room->setPlayerFlag(shensimayi, "JilveWansha");
        room->acquireSkill(shensimayi, "wansha");
    } else {
        room->setPlayerFlag(shensimayi, "JilveZhiheng");
        room->askForUseCard(shensimayi, "@zhiheng", "@jilve-zhiheng", -1, Card::MethodDiscard);
    }
}

class JilveViewAsSkill : public ZeroCardViewAsSkill
{
public: // wansha & zhiheng
    JilveViewAsSkill() : ZeroCardViewAsSkill("jilve")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return player->usedTimes("JilveCard") < 2 && player->getMark("@bear") > 0;
    }

    virtual const Card *viewAs() const
    {
        return new JilveCard;
    }
};

class Jilve : public TriggerSkill
{
public:
    Jilve() : TriggerSkill("jilve")
    {
        events << CardUsed // JiZhi
            << AskForRetrial // GuiCai
            << Damaged; // FangZhu
        view_as_skill = new JilveViewAsSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return TriggerSkill::triggerable(target) && target->getMark("@bear") > 0;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        player->setMark("JilveEvent", (int)triggerEvent);
        try {
            if (triggerEvent == CardUsed) {
                const TriggerSkill *jizhi = Sanguosha->getTriggerSkill("jizhi");
                CardUseStruct use = data.value<CardUseStruct>();
                if (jizhi && use.card && use.card->getTypeId() == Card::TypeTrick && player->askForSkillInvoke("jilve_jizhi", data)) {
                    room->notifySkillInvoked(player, objectName());
                    player->loseMark("@bear");
                    jizhi->trigger(triggerEvent, room, player, data);
                }
            } else if (triggerEvent == AskForRetrial) {
                const TriggerSkill *guicai = Sanguosha->getTriggerSkill("guicai");
                if (guicai && !player->isKongcheng() && player->askForSkillInvoke("jilve_guicai", data)) {
                    room->notifySkillInvoked(player, objectName());
                    player->loseMark("@bear");
                    guicai->trigger(triggerEvent, room, player, data);
                }
            } else if (triggerEvent == Damaged) {
                const TriggerSkill *fangzhu = Sanguosha->getTriggerSkill("fangzhu");
                if (fangzhu && player->askForSkillInvoke("jilve_fangzhu", data)) {
                    room->notifySkillInvoked(player, objectName());
                    player->loseMark("@bear");
                    fangzhu->trigger(triggerEvent, room, player, data);
                }
            }
            player->setMark("JilveEvent", 0);
        }
        catch (TriggerEvent triggerEvent) {
            if (triggerEvent == StageChange || triggerEvent == TurnBroken)
                player->setMark("JilveEvent", 0);
            throw triggerEvent;
        }

        return false;
    }
};

class JilveClear : public TriggerSkill
{
public:
    JilveClear() : TriggerSkill("#jilve-clear")
    {
        events << EventPhaseChanging;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->hasFlag("JilveWansha");
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *target, QVariant &data) const
    {
        PhaseChangeStruct change = data.value<PhaseChangeStruct>();
        if (change.to != Player::NotActive)
            return false;
        room->detachSkillFromPlayer(target, "wansha", false, true);
        return false;
    }
};

class LianpoCount : public TriggerSkill
{
public:
    LianpoCount() : TriggerSkill("#lianpo-count")
    {
        events << Death << TurnStart;
        global = true;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == Death) {
            DeathStruct death = data.value<DeathStruct>();
            if (death.who != player)
                return false;
            ServerPlayer *killer = death.damage ? death.damage->from : NULL;
            ServerPlayer *current = room->getCurrent();

            if (killer && current && (current->isAlive() || death.who == current)
                && current->getPhase() != Player::NotActive) {
                killer->addMark("lianpo");

                if (player->isAlive() && player->hasSkill("lianpo")) {
                    LogMessage log;
                    log.type = "#LianpoRecord";
                    log.from = killer;
                    log.to << player;

                    log.arg = current->getGeneralName();
                    room->sendLog(log);
                }
            }
        } else {
            foreach(ServerPlayer *p, room->getAlivePlayers())
                p->setMark("lianpo", 0);
        }

        return false;
    }
};

class Lianpo : public PhaseChangeSkill
{
public:
    Lianpo() : PhaseChangeSkill("lianpo")
    {
        frequency = Frequent;
    }

    virtual int getPriority(TriggerEvent) const
    {
        return 1;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool onPhaseChange(ServerPlayer *player) const
    {
        Room *room = player->getRoom();
        if (player->getPhase() == Player::NotActive) {
            ServerPlayer *shensimayi = room->findPlayerBySkillName("lianpo");
            if (shensimayi == NULL || shensimayi->getMark("lianpo") <= 0 || !shensimayi->askForSkillInvoke("lianpo"))
                return false;

            LogMessage log;
            log.type = "#LianpoCanInvoke";
            log.from = shensimayi;
            log.arg = QString::number(shensimayi->getMark("lianpo"));
            log.arg2 = objectName();
            room->sendLog(log);

            room->broadcastSkillInvoke(objectName());
            shensimayi->gainAnExtraTurn();
        }
        return false;
    }
};

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
        } else
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
    foreach (const Card *card, player->getHandcards() + player->getEquips()) {
        if (card->getSuit() == Card::Spade) count++;
        if (count >= n) return true;
    }
    return false;
}

int Longhun::getEffHp(const Player *zhaoyun) const
{
    return qMax(1, zhaoyun->getHp());
}

GodPackage::GodPackage()
    : Package("god")
{
    General *shenguanyu = new General(this, "shenguanyu", "god", 5); // LE 001
    shenguanyu->addSkill(new Wushen);
    shenguanyu->addSkill(new WushenTargetMod);
    shenguanyu->addSkill(new Wuhun);
    shenguanyu->addSkill(new WuhunRevenge);
    related_skills.insertMulti("wushen", "#wushen-target");
    related_skills.insertMulti("wuhun", "#wuhun");

    General *shenlvmeng = new General(this, "shenlvmeng", "god", 3); // LE 002
    shenlvmeng->addSkill(new Shelie);
    shenlvmeng->addSkill(new Gongxin);

    General *shenzhouyu = new General(this, "shenzhouyu", "god"); // LE 003
    shenzhouyu->addSkill(new Qinyin);
    shenzhouyu->addSkill(new Yeyan);

    General *shenzhugeliang = new General(this, "shenzhugeliang", "god", 3); // LE 004
    shenzhugeliang->addSkill(new Qixing);
    shenzhugeliang->addSkill(new QixingStart);
    shenzhugeliang->addSkill(new QixingAsk);
    shenzhugeliang->addSkill(new QixingClear);
    shenzhugeliang->addSkill(new FakeMoveSkill("qixing"));
    shenzhugeliang->addSkill(new Kuangfeng);
    shenzhugeliang->addSkill(new Dawu);
    related_skills.insertMulti("qixing", "#qixing");
    related_skills.insertMulti("qixing", "#qixing-ask");
    related_skills.insertMulti("qixing", "#qixing-clear");
    related_skills.insertMulti("qixing", "#qixing-fake-move");

    General *shencaocao = new General(this, "shencaocao", "god", 3); // LE 005
    shencaocao->addSkill(new Guixin);
    shencaocao->addSkill(new Feiying);

    General *shenlvbu = new General(this, "shenlvbu", "god", 5); // LE 006
    shenlvbu->addSkill(new Kuangbao);
    shenlvbu->addSkill(new MarkAssignSkill("@wrath", 2));
    shenlvbu->addSkill(new Wumou);
    shenlvbu->addSkill(new Wuqian);
    shenlvbu->addSkill(new Shenfen);
    related_skills.insertMulti("kuangbao", "#@wrath-2");

    General *shenzhaoyun = new General(this, "shenzhaoyun", "god", 2); // LE 007
    shenzhaoyun->addSkill(new JuejingKeep);
    shenzhaoyun->addSkill(new Juejing);
    shenzhaoyun->addSkill(new Longhun);
    related_skills.insertMulti("juejing", "#juejing-draw");

    General *shensimayi = new General(this, "shensimayi", "god", 4); // LE 008
    shensimayi->addSkill(new Renjie);
    shensimayi->addSkill(new Baiyin);
    shensimayi->addRelateSkill("jilve");
    related_skills.insertMulti("jilve", "#jilve-clear");
    shensimayi->addSkill(new Lianpo);
    shensimayi->addSkill(new LianpoCount);
    related_skills.insertMulti("lianpo", "#lianpo-count");

    addMetaObject<GongxinCard>();
    addMetaObject<YeyanCard>();
    addMetaObject<ShenfenCard>();
    addMetaObject<GreatYeyanCard>();
    addMetaObject<SmallYeyanCard>();
    addMetaObject<QixingCard>();
    addMetaObject<KuangfengCard>();
    addMetaObject<DawuCard>();
    addMetaObject<WuqianCard>();
    addMetaObject<JilveCard>();

    skills << new Jilve << new JilveClear;
}

ADD_PACKAGE(God)

