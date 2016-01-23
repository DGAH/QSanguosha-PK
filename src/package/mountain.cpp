#include "mountain.h"
#include "general.h"
#include "settings.h"
#include "skill.h"
#include "engine.h"
#include "standard.h"
#include "generaloverview.h"
#include "clientplayer.h"
#include "client.h"
#include "ai.h"
#include "json.h"

#include <QCommandLinkButton>

QiaobianCard::QiaobianCard()
{
    mute = true;
}

bool QiaobianCard::targetsFeasible(const QList<const Player *> &targets, const Player *Self) const
{
    Player::Phase phase = (Player::Phase)Self->getMark("qiaobianPhase");
    if (phase == Player::Draw)
        return targets.length() <= 2 && !targets.isEmpty();
    else if (phase == Player::Play)
        return targets.length() == 1;
    return false;
}

bool QiaobianCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    Player::Phase phase = (Player::Phase)Self->getMark("qiaobianPhase");
    if (phase == Player::Draw)
        return targets.length() < 2 && to_select != Self && !to_select->isKongcheng();
    else if (phase == Player::Play)
        return targets.isEmpty()
        && (!to_select->getJudgingArea().isEmpty() || !to_select->getEquips().isEmpty());
    return false;
}

void QiaobianCard::use(Room *room, ServerPlayer *zhanghe, QList<ServerPlayer *> &targets) const
{
    Player::Phase phase = (Player::Phase)zhanghe->getMark("qiaobianPhase");
    if (phase == Player::Draw) {
        if (targets.isEmpty())
            return;

        foreach (ServerPlayer *target, targets) {
            if (zhanghe->isAlive() && target->isAlive())
                room->cardEffect(this, zhanghe, target);
        }
    } else if (phase == Player::Play) {
        if (targets.isEmpty())
            return;

        ServerPlayer *from = targets.first();
        if (!from->hasEquip() && from->getJudgingArea().isEmpty())
            return;

        int card_id = room->askForCardChosen(zhanghe, from, "ej", "qiaobian");
        const Card *card = Sanguosha->getCard(card_id);
        Player::Place place = room->getCardPlace(card_id);

        int equip_index = -1;
        if (place == Player::PlaceEquip) {
            const EquipCard *equip = qobject_cast<const EquipCard *>(card->getRealCard());
            equip_index = static_cast<int>(equip->location());
        }

        QList<ServerPlayer *> tos;
        foreach (ServerPlayer *p, room->getAlivePlayers()) {
            if (equip_index != -1) {
                if (p->getEquip(equip_index) == NULL)
                    tos << p;
            } else {
                if (!zhanghe->isProhibited(p, card) && !p->containsTrick(card->objectName()))
                    tos << p;
            }
        }

        room->setTag("QiaobianTarget", QVariant::fromValue(from));
        ServerPlayer *to = room->askForPlayerChosen(zhanghe, tos, "qiaobian", "@qiaobian-to:::" + card->objectName());
        if (to)
            room->moveCardTo(card, from, to, place,
            CardMoveReason(CardMoveReason::S_REASON_TRANSFER,
            zhanghe->objectName(), "qiaobian", QString()));
        room->removeTag("QiaobianTarget");
    }
}

void QiaobianCard::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.from->getRoom();
    if (!effect.to->isKongcheng()) {
        int card_id = room->askForCardChosen(effect.from, effect.to, "h", "qiaobian");
        CardMoveReason reason(CardMoveReason::S_REASON_EXTRACTION, effect.from->objectName());
        room->obtainCard(effect.from, Sanguosha->getCard(card_id), reason, false);
    }
}

class QiaobianViewAsSkill : public ZeroCardViewAsSkill
{
public:
    QiaobianViewAsSkill() : ZeroCardViewAsSkill("qiaobian")
    {
        response_pattern = "@@qiaobian";
    }

    virtual const Card *viewAs() const
    {
        return new QiaobianCard;
    }
};

class Qiaobian : public TriggerSkill
{
public:
    Qiaobian() : TriggerSkill("qiaobian")
    {
        events << EventPhaseChanging;
        view_as_skill = new QiaobianViewAsSkill;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return TriggerSkill::triggerable(target) && target->canDiscard(target, "h");
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *zhanghe, QVariant &data) const
    {
        PhaseChangeStruct change = data.value<PhaseChangeStruct>();
        room->setPlayerMark(zhanghe, "qiaobianPhase", (int)change.to);
        int index = 0;
        switch (change.to) {
        case Player::RoundStart:
        case Player::Start:
        case Player::Finish:
        case Player::NotActive: return false;

        case Player::Judge: index = 1; break;
        case Player::Draw: index = 2; break;
        case Player::Play: index = 3; break;
        case Player::Discard: index = 4; break;
        case Player::PhaseNone: Q_ASSERT(false);
        }

        QString discard_prompt = QString("#qiaobian-%1").arg(index);
        QString use_prompt = QString("@qiaobian-%1").arg(index);
        if (index > 0 && room->askForDiscard(zhanghe, objectName(), 1, 1, true, false, discard_prompt)) {
            room->broadcastSkillInvoke("qiaobian", index);
            if (!zhanghe->isAlive()) return false;
            if (!zhanghe->isSkipped(change.to) && (index == 2 || index == 3))
                room->askForUseCard(zhanghe, "@@qiaobian", use_prompt, index);
            zhanghe->skip(change.to, true);
        }
        return false;
    }
};

class Beige : public TriggerSkill
{
public:
    Beige() : TriggerSkill("beige")
    {
        events << Damaged << FinishJudge;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == Damaged) {
            DamageStruct damage = data.value<DamageStruct>();
            if (damage.card == NULL || !damage.card->isKindOf("Slash") || damage.to->isDead())
                return false;

            foreach (ServerPlayer *caiwenji, room->getAllPlayers()) {
                if (!TriggerSkill::triggerable(caiwenji)) continue;
                if (caiwenji->canDiscard(caiwenji, "he") && room->askForCard(caiwenji, "..", "@beige", data, objectName())) {
                    JudgeStruct judge;
                    judge.good = true;
                    judge.play_animation = false;
                    judge.who = player;
                    judge.reason = objectName();

                    room->judge(judge);

                    Card::Suit suit = (Card::Suit)(judge.pattern.toInt());
                    switch (suit) {
                    case Card::Heart: {
                        room->broadcastSkillInvoke(objectName(), 4);
                        room->recover(player, RecoverStruct(caiwenji));

                        break;
                    }
                    case Card::Diamond: {
                        room->broadcastSkillInvoke(objectName(), 3);
                        player->drawCards(2, objectName());
                        break;
                    }
                    case Card::Club: {
                        room->broadcastSkillInvoke(objectName(), 1);
                        if (damage.from && damage.from->isAlive())
                            room->askForDiscard(damage.from, "beige", 2, 2, false, true);

                        break;
                    }
                    case Card::Spade: {
                        room->broadcastSkillInvoke(objectName(), 2);
                        if (damage.from && damage.from->isAlive())
                            damage.from->turnOver();

                        break;
                    }
                    default:
                        break;
                    }
                }
            }
        } else {
            JudgeStruct *judge = data.value<JudgeStruct *>();
            if (judge->reason != objectName()) return false;
            judge->pattern = QString::number(int(judge->card->getSuit()));
        }
        return false;
    }
};

class Duanchang : public TriggerSkill
{
public:
    Duanchang() : TriggerSkill("duanchang")
    {
        events << Death;
        frequency = Compulsory;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->hasSkill(this);
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DeathStruct death = data.value<DeathStruct>();
        if (death.who != player)
            return false;

        if (death.damage && death.damage->from) {
            LogMessage log;
            log.type = "#DuanchangLoseSkills";
            log.from = player;
            log.to << death.damage->from;
            log.arg = objectName();
            room->sendLog(log);
            room->broadcastSkillInvoke(objectName());
            room->notifySkillInvoked(player, objectName());

            QList<const Skill *> skills = death.damage->from->getVisibleSkillList();
            QStringList detachList;
            foreach (const Skill *skill, skills) {
                if (!skill->inherits("SPConvertSkill") && !skill->isAttachedLordSkill())
                    detachList.append("-" + skill->objectName());
            }
            room->handleAcquireDetachSkills(death.damage->from, detachList);
            if (death.damage->from->isAlive())
                death.damage->from->gainMark("@duanchang");
        }

        return false;
    }
};

class Tuntian : public TriggerSkill
{
public:
    Tuntian() : TriggerSkill("tuntian")
    {
        events << CardsMoveOneTime << FinishJudge;
        frequency = Frequent;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return TriggerSkill::triggerable(target) && target->getPhase() == Player::NotActive;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == CardsMoveOneTime) {
            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
            if (move.from == player && (move.from_places.contains(Player::PlaceHand) || move.from_places.contains(Player::PlaceEquip))
                && !(move.to == player && (move.to_place == Player::PlaceHand || move.to_place == Player::PlaceEquip))
                && player->askForSkillInvoke("tuntian", data)) {
                room->broadcastSkillInvoke("tuntian");
                JudgeStruct judge;
                judge.pattern = ".|heart";
                judge.good = false;
                judge.reason = "tuntian";
                judge.who = player;
                room->judge(judge);
            }
        } else if (triggerEvent == FinishJudge) {
            JudgeStruct *judge = data.value<JudgeStruct *>();
            if (judge->reason == "tuntian" && judge->isGood() && room->getCardPlace(judge->card->getEffectiveId()) == Player::PlaceJudge)
                player->addToPile("field", judge->card->getEffectiveId());
        }

        return false;
    }
};

class TuntianDistance : public DistanceSkill
{
public:
    TuntianDistance() : DistanceSkill("#tuntian-dist")
    {
    }

    virtual int getCorrect(const Player *from, const Player *) const
    {
        if (from->hasSkill("tuntian"))
            return -from->getPile("field").length();
        else
            return 0;
    }
};

class Zaoxian : public PhaseChangeSkill
{
public:
    Zaoxian() : PhaseChangeSkill("zaoxian")
    {
        frequency = Wake;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return PhaseChangeSkill::triggerable(target)
            && target->getPhase() == Player::Start
            && target->getMark("zaoxian") == 0
            && target->getPile("field").length() >= 3;
    }

    virtual bool onPhaseChange(ServerPlayer *dengai) const
    {
        Room *room = dengai->getRoom();
        room->notifySkillInvoked(dengai, objectName());

        LogMessage log;
        log.type = "#ZaoxianWake";
        log.from = dengai;
        log.arg = QString::number(dengai->getPile("field").length());
        log.arg2 = objectName();
        room->sendLog(log);

        room->broadcastSkillInvoke(objectName());
        //room->doLightbox("$ZaoxianAnimate", 4000);

        room->doSuperLightbox("dengai", "zaoxian");

        room->setPlayerMark(dengai, "zaoxian", 1);
        if (room->changeMaxHpForAwakenSkill(dengai) && dengai->getMark("zaoxian") == 1)
            room->acquireSkill(dengai, "jixi");

        return false;
    }
};

class Jixi : public OneCardViewAsSkill
{
public:
    Jixi() : OneCardViewAsSkill("jixi")
    {
        filter_pattern = ".|.|.|field";
        expand_pile = "field";
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->getPile("field").isEmpty();
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        Snatch *snatch = new Snatch(originalCard->getSuit(), originalCard->getNumber());
        snatch->addSubcard(originalCard);
        snatch->setSkillName(objectName());
        return snatch;
    }
};

class Jiang : public TriggerSkill
{
public:
    Jiang() : TriggerSkill("jiang")
    {
        events << TargetSpecified << TargetConfirmed;
        frequency = Frequent;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *sunce, QVariant &data) const
    {
        CardUseStruct use = data.value<CardUseStruct>();
        if (triggerEvent == TargetSpecified || (triggerEvent == TargetConfirmed && use.to.contains(sunce))) {
            if (use.card->isKindOf("Duel") || (use.card->isKindOf("Slash") && use.card->isRed())) {
                if (sunce->askForSkillInvoke(this, data)) {
                    int index = 1;
                    if (!sunce->hasInnateSkill(this) && sunce->hasSkill("mouduan"))
                        index += 2;
                    room->broadcastSkillInvoke(objectName(), index + (use.from == sunce ? 0 : 1));
                    sunce->drawCards(1, objectName());
                }
            }
        }

        return false;
    }
};

class Hunzi : public PhaseChangeSkill
{
public:
    Hunzi() : PhaseChangeSkill("hunzi")
    {
        frequency = Wake;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return PhaseChangeSkill::triggerable(target)
            && target->getMark("hunzi") == 0
            && target->getPhase() == Player::Start
            && target->getHp() == 1;
    }

    virtual bool onPhaseChange(ServerPlayer *sunce) const
    {
        Room *room = sunce->getRoom();
        room->notifySkillInvoked(sunce, objectName());

        LogMessage log;
        log.type = "#HunziWake";
        log.from = sunce;
        log.arg = objectName();
        room->sendLog(log);

        room->broadcastSkillInvoke(objectName());
        //room->doLightbox("$HunziAnimate", 5000);

        room->doSuperLightbox("sunce", "hunzi");

        room->setPlayerMark(sunce, "hunzi", 1);
        if (room->changeMaxHpForAwakenSkill(sunce) && sunce->getMark("hunzi") == 1)
            room->handleAcquireDetachSkills(sunce, "yingzi|yinghun");
        return false;
    }
};

ZhibaCard::ZhibaCard()
{
    mute = true;
    m_skillName = "zhiba_pindian";
}

bool ZhibaCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select->hasLordSkill("zhiba") && to_select != Self
        && !to_select->isKongcheng() && !to_select->hasFlag("ZhibaInvoked");
}

void ZhibaCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const
{
    ServerPlayer *sunce = targets.first();
    room->setPlayerFlag(sunce, "ZhibaInvoked");
    room->notifySkillInvoked(sunce, "zhiba");
    if (sunce->getMark("hunzi") > 0 && room->askForChoice(sunce, "zhiba_pindian", "accept+reject") == "reject") {
        LogMessage log;
        log.type = "#ZhibaReject";
        log.from = sunce;
        log.to << source;
        log.arg = "zhiba_pindian";
        room->sendLog(log);

        room->broadcastSkillInvoke("zhiba", 4);
        return;
    }

    if (!sunce->isLord() && sunce->hasSkill("weidi"))
        room->broadcastSkillInvoke("weidi");
    else
        room->broadcastSkillInvoke("zhiba", 1);

    source->pindian(sunce, "zhiba_pindian", NULL);
    QList<ServerPlayer *> sunces;
    QList<ServerPlayer *> players = room->getOtherPlayers(source);
    foreach (ServerPlayer *p, players) {
        if (p->hasLordSkill("zhiba") && !p->hasFlag("ZhibaInvoked"))
            sunces << p;
    }
    if (sunces.isEmpty())
        room->setPlayerFlag(source, "ForbidZhiba");
}

class ZhibaPindian : public ZeroCardViewAsSkill
{
public:
    ZhibaPindian() : ZeroCardViewAsSkill("zhiba_pindian")
    {
        attached_lord_skill = true;
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return shouldBeVisible(player) && !player->isKongcheng() && !player->hasFlag("ForbidZhiba");
    }

    virtual bool shouldBeVisible(const Player *Self) const
    {
        return Self && Self->getKingdom() == "wu";
    }

    virtual const Card *viewAs() const
    {
        return new ZhibaCard;
    }
};

class Zhiba : public TriggerSkill
{
public:
    Zhiba() : TriggerSkill("zhiba$")
    {
        events << GameStart << EventAcquireSkill << EventLoseSkill << Pindian << EventPhaseChanging;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if ((triggerEvent == GameStart && player->isLord())
            || (triggerEvent == EventAcquireSkill && data.toString() == "zhiba")) {
            QList<ServerPlayer *> lords;
            foreach (ServerPlayer *p, room->getAlivePlayers()) {
                if (p->hasLordSkill(this))
                    lords << p;
            }
            if (lords.isEmpty()) return false;

            QList<ServerPlayer *> players;
            if (lords.length() > 1)
                players = room->getAlivePlayers();
            else
                players = room->getOtherPlayers(lords.first());
            foreach (ServerPlayer *p, players) {
                if (!p->hasSkill("zhiba_pindian"))
                    room->attachSkillToPlayer(p, "zhiba_pindian");
            }
        } else if (triggerEvent == EventLoseSkill && data.toString() == "zhiba") {
            QList<ServerPlayer *> lords;
            foreach (ServerPlayer *p, room->getAlivePlayers()) {
                if (p->hasLordSkill(this))
                    lords << p;
            }
            if (lords.length() > 2) return false;

            QList<ServerPlayer *> players;
            if (lords.isEmpty())
                players = room->getAlivePlayers();
            else
                players << lords.first();
            foreach (ServerPlayer *p, players) {
                if (p->hasSkill("zhiba_pindian"))
                    room->detachSkillFromPlayer(p, "zhiba_pindian", true);
            }
        } else if (triggerEvent == Pindian) {
            PindianStruct *pindian = data.value<PindianStruct *>();
            if (pindian->reason != "zhiba_pindian" || !pindian->to->hasLordSkill(this))
                return false;
            if (!pindian->isSuccess()) {
                room->broadcastSkillInvoke(objectName(), 2);
                if (room->getCardPlace(pindian->from_card->getEffectiveId()) == Player::PlaceTable)
                    pindian->to->obtainCard(pindian->from_card);
                if (room->getCardPlace(pindian->to_card->getEffectiveId()) == Player::PlaceTable)
                    pindian->to->obtainCard(pindian->to_card);
            } else
                room->broadcastSkillInvoke(objectName(), 3);
        } else if (triggerEvent == EventPhaseChanging) {
            PhaseChangeStruct phase_change = data.value<PhaseChangeStruct>();
            if (phase_change.from != Player::Play)
                return false;
            if (player->hasFlag("ForbidZhiba"))
                room->setPlayerFlag(player, "-ForbidZhiba");
            QList<ServerPlayer *> players = room->getOtherPlayers(player);
            foreach (ServerPlayer *p, players) {
                if (p->hasFlag("ZhibaInvoked"))
                    room->setPlayerFlag(p, "-ZhibaInvoked");
            }
        }

        return false;
    }
};

TiaoxinCard::TiaoxinCard()
{
}

bool TiaoxinCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select->inMyAttackRange(Self);
}

void TiaoxinCard::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.from->getRoom();
    bool use_slash = false;
    if (effect.to->canSlash(effect.from, NULL, false))
        use_slash = room->askForUseSlashTo(effect.to, effect.from, "@tiaoxin-slash:" + effect.from->objectName());
    if (!use_slash && effect.from->canDiscard(effect.to, "he"))
        room->throwCard(room->askForCardChosen(effect.from, effect.to, "he", "tiaoxin", false, Card::MethodDiscard), effect.to, effect.from);
}

class Tiaoxin : public ZeroCardViewAsSkill
{
public:
    Tiaoxin() : ZeroCardViewAsSkill("tiaoxin")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->hasUsed("TiaoxinCard");
    }

    virtual const Card *viewAs() const
    {
        return new TiaoxinCard;
    }

    virtual int getEffectIndex(const ServerPlayer *player, const Card *) const
    {
        int index = qrand() % 2 + 1;
        if (!player->hasInnateSkill(this) && player->hasSkill("baobian"))
            index += 3;
        else if (player->hasArmorEffect("eight_diagram") || player->hasArmorEffect("bazhen"))
            index = 3;
        return index;
    }
};

class Zhiji : public PhaseChangeSkill
{
public:
    Zhiji() : PhaseChangeSkill("zhiji")
    {
        frequency = Wake;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return PhaseChangeSkill::triggerable(target)
            && target->getMark("zhiji") == 0
            && target->getPhase() == Player::Start
            && target->isKongcheng();
    }

    virtual bool onPhaseChange(ServerPlayer *jiangwei) const
    {
        Room *room = jiangwei->getRoom();
        room->notifySkillInvoked(jiangwei, objectName());

        LogMessage log;
        log.type = "#ZhijiWake";
        log.from = jiangwei;
        log.arg = objectName();
        room->sendLog(log);

        room->broadcastSkillInvoke(objectName());
        //room->doLightbox("$ZhijiAnimate", 4000);

        room->doSuperLightbox("jiangwei", "zhiji");

        room->setPlayerMark(jiangwei, "zhiji", 1);
        if (room->changeMaxHpForAwakenSkill(jiangwei)) {
            if (jiangwei->isWounded() && room->askForChoice(jiangwei, objectName(), "recover+draw") == "recover")
                room->recover(jiangwei, RecoverStruct(jiangwei));
            else
                room->drawCards(jiangwei, 2, objectName());
            if (jiangwei->getMark("zhiji") == 1)
                room->acquireSkill(jiangwei, "guanxing");
        }

        return false;
    }
};

ZhijianCard::ZhijianCard()
{
    will_throw = false;
    handling_method = Card::MethodNone;
}

bool ZhijianCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    if (!targets.isEmpty() || to_select == Self)
        return false;

    const Card *card = Sanguosha->getCard(subcards.first());
    const EquipCard *equip = qobject_cast<const EquipCard *>(card->getRealCard());
    int equip_index = static_cast<int>(equip->location());
    return to_select->getEquip(equip_index) == NULL;
}

void ZhijianCard::onEffect(const CardEffectStruct &effect) const
{
    ServerPlayer *erzhang = effect.from;
    erzhang->getRoom()->moveCardTo(this, erzhang, effect.to, Player::PlaceEquip,
        CardMoveReason(CardMoveReason::S_REASON_PUT,
        erzhang->objectName(), "zhijian", QString()));

    LogMessage log;
    log.type = "$ZhijianEquip";
    log.from = effect.to;
    log.card_str = QString::number(getEffectiveId());
    erzhang->getRoom()->sendLog(log);

    erzhang->drawCards(1, "zhijian");
}

class Zhijian : public OneCardViewAsSkill
{
public:
    Zhijian() :OneCardViewAsSkill("zhijian")
    {
        filter_pattern = "EquipCard|.|.|hand";
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        ZhijianCard *zhijian_card = new ZhijianCard();
        zhijian_card->addSubcard(originalCard);
        return zhijian_card;
    }
};

class Guzheng : public TriggerSkill
{
public:
    Guzheng() : TriggerSkill("guzheng")
    {
        events << CardsMoveOneTime << EventPhaseEnd << EventPhaseChanging;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == CardsMoveOneTime && TriggerSkill::triggerable(player)) {
            ServerPlayer *current = room->getCurrent();
            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();

            if (!current || player == current || current->getPhase() != Player::Discard)
                return false;

            QVariantList guzhengToGet = player->tag["GuzhengToGet"].toList();
            QVariantList guzhengOther = player->tag["GuzhengOther"].toList();

            if ((move.reason.m_reason & CardMoveReason::S_MASK_BASIC_REASON) == CardMoveReason::S_REASON_DISCARD) {
                int i = 0;
                foreach (int card_id, move.card_ids) {
                    if (move.from == current && move.from_places[i] == Player::PlaceHand)
                        guzhengToGet << card_id;
                    else if (!guzhengToGet.contains(card_id))
                        guzhengOther << card_id;
                    i++;
                }
            }

            player->tag["GuzhengToGet"] = guzhengToGet;
            player->tag["GuzhengOther"] = guzhengOther;
        } else if (triggerEvent == EventPhaseEnd && player->getPhase() == Player::Discard) {
            ServerPlayer *erzhang = room->findPlayerBySkillName(objectName());
            if (erzhang == NULL)
                return false;

            QVariantList guzheng_cardsToGet = erzhang->tag["GuzhengToGet"].toList();
            QVariantList guzheng_cardsOther = erzhang->tag["GuzhengOther"].toList();
            erzhang->tag.remove("GuzhengToGet");
            erzhang->tag.remove("GuzhengOther");

            if (player->isDead())
                return false;

            QList<int> cardsToGet;
            foreach (QVariant card_data, guzheng_cardsToGet) {
                int card_id = card_data.toInt();
                if (room->getCardPlace(card_id) == Player::DiscardPile)
                    cardsToGet << card_id;
            }
            QList<int> cardsOther;
            foreach (QVariant card_data, guzheng_cardsOther) {
                int card_id = card_data.toInt();
                if (room->getCardPlace(card_id) == Player::DiscardPile)
                    cardsOther << card_id;
            }


            if (cardsToGet.isEmpty())
                return false;

            QList<int> cards = cardsToGet + cardsOther;

            if (erzhang->askForSkillInvoke(this, cards.length())) {
                room->broadcastSkillInvoke(objectName());
                room->fillAG(cards, erzhang, cardsOther);

                int to_back = room->askForAG(erzhang, cardsToGet, false, objectName());
                player->obtainCard(Sanguosha->getCard(to_back));

                cards.removeOne(to_back);

                room->clearAG(erzhang);

                DummyCard *dummy = new DummyCard(cards);
                room->obtainCard(erzhang, dummy);
                delete dummy;
            }
        } else if (triggerEvent == EventPhaseChanging) {
            PhaseChangeStruct change = data.value<PhaseChangeStruct>();
            if (change.to == Player::Discard) {
                ServerPlayer *erzhang = room->findPlayerBySkillName(objectName());
                if (erzhang == NULL)
                    return false;
                erzhang->tag.remove("GuzhengToGet");
                erzhang->tag.remove("GuzhengOther");
            }
        }

        return false;
    }
};

class Xiangle : public TriggerSkill
{
public:
    Xiangle() : TriggerSkill("xiangle")
    {
        events << TargetConfirming;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *liushan, QVariant &data) const
    {
        if (triggerEvent == TargetConfirming) {
            CardUseStruct use = data.value<CardUseStruct>();
            if (use.card->isKindOf("Slash")) {
                room->broadcastSkillInvoke(objectName());
                room->sendCompulsoryTriggerLog(liushan, objectName());

                QVariant dataforai = QVariant::fromValue(liushan);
                if (!room->askForCard(use.from, ".Basic", "@xiangle-discard", dataforai)) {
                    use.nullified_list << liushan->objectName();
                    data = QVariant::fromValue(use);
                }
            }
        }

        return false;
    }
};

FangquanCard::FangquanCard()
{
}

bool FangquanCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select != Self;
}

void FangquanCard::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.from->getRoom();
    ServerPlayer *liushan = effect.from, *player = effect.to;

    LogMessage log;
    log.type = "#Fangquan";
    log.from = liushan;
    log.to << player;
    room->sendLog(log);

    room->setTag("FangquanTarget", QVariant::fromValue(player));
}

class FangquanViewAsSkill : public OneCardViewAsSkill
{
public:
    FangquanViewAsSkill() : OneCardViewAsSkill("fangquan")
    {
        filter_pattern = ".|.|.|hand!";
        response_pattern = "@@fangquan";
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        FangquanCard *fangquan = new FangquanCard;
        fangquan->addSubcard(originalCard);
        return fangquan;
    }
};

class Fangquan : public TriggerSkill
{
public:
    Fangquan() : TriggerSkill("fangquan")
    {
        events << EventPhaseChanging << EventPhaseStart;
        view_as_skill = new FangquanViewAsSkill;
    }

    virtual int getPriority(TriggerEvent triggerEvent) const
    {
        if (triggerEvent == EventPhaseStart)
            return 1;
        else
            return TriggerSkill::getPriority(triggerEvent);
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *liushan, QVariant &data) const
    {
        if (triggerEvent == EventPhaseChanging) {
            PhaseChangeStruct change = data.value<PhaseChangeStruct>();
            switch (change.to) {
            case Player::Play: {
                bool invoked = false;
                if (!TriggerSkill::triggerable(liushan) || liushan->isSkipped(Player::Play))
                    return false;
                invoked = liushan->askForSkillInvoke(this);
                if (invoked) {
                    liushan->setFlags(objectName());
                    liushan->skip(Player::Play, true);
                }
                break;
            }
            case Player::NotActive: {
                if (liushan->hasFlag(objectName())) {
                    if (!liushan->canDiscard(liushan, "h"))
                        return false;
                    room->askForUseCard(liushan, "@@fangquan", "@fangquan-give", -1, Card::MethodDiscard);
                }
                break;
            }
            default:
                break;
            }
        } else if (triggerEvent == EventPhaseStart && liushan->getPhase() == Player::NotActive) {
            Room *room = liushan->getRoom();
            if (!room->getTag("FangquanTarget").isNull()) {
                ServerPlayer *target = room->getTag("FangquanTarget").value<ServerPlayer *>();
                room->removeTag("FangquanTarget");
                if (target->isAlive())
                    target->gainAnExtraTurn();
            }
        }
        return false;
    }
};

class Ruoyu : public PhaseChangeSkill
{
public:
    Ruoyu() : PhaseChangeSkill("ruoyu$")
    {
        frequency = Wake;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->getPhase() == Player::Start
            && target->hasLordSkill("ruoyu")
            && target->isAlive()
            && target->getMark("ruoyu") == 0;
    }

    virtual bool onPhaseChange(ServerPlayer *liushan) const
    {
        Room *room = liushan->getRoom();

        bool can_invoke = true;
        foreach (ServerPlayer *p, room->getAllPlayers()) {
            if (liushan->getHp() > p->getHp()) {
                can_invoke = false;
                break;
            }
        }

        if (can_invoke) {
            room->notifySkillInvoked(liushan, objectName());

            LogMessage log;
            log.type = "#RuoyuWake";
            log.from = liushan;
            log.arg = QString::number(liushan->getHp());
            log.arg2 = objectName();
            room->sendLog(log);

            if (!liushan->isLord() && liushan->hasSkill("weidi")) {
                room->broadcastSkillInvoke("weidi");
                QString generalName = "yuanshu";
                if (liushan->getGeneralName() == "tw_yuanshu" || (liushan->getGeneral2() != NULL && liushan->getGeneral2Name() == "tw_yuanshu"))
                    generalName = "tw_yuanshu";

                room->doSuperLightbox(generalName, "ruoyu");
            } else {
                room->broadcastSkillInvoke(objectName());
                room->doSuperLightbox("liushan", "ruoyu");
            }

            room->setPlayerMark(liushan, "ruoyu", 1);
            if (room->changeMaxHpForAwakenSkill(liushan, 1)) {
                room->recover(liushan, RecoverStruct(liushan));
                if (liushan->getMark("ruoyu") == 1 && liushan->isLord())
                    room->acquireSkill(liushan, "jijiang");
            }
        }

        return false;
    }
};

class Huashen : public GameStartSkill
{
public:
    Huashen() : GameStartSkill("huashen")
    {
    }

    static void playAudioEffect(ServerPlayer *zuoci, const QString &skill_name)
    {
        zuoci->getRoom()->broadcastSkillInvoke(skill_name, zuoci->isMale(), -1);
    }

    static void AcquireGenerals(ServerPlayer *zuoci, int n)
    {
        Room *room = zuoci->getRoom();
        QVariantList huashens = zuoci->tag["Huashens"].toList();
        QStringList list = GetAvailableGenerals(zuoci);
        qShuffle(list);
        if (list.isEmpty()) return;
        n = qMin(n, list.length());

        QStringList acquired = list.mid(0, n);
        foreach (QString name, acquired) {
            huashens << name;
            const General *general = Sanguosha->getGeneral(name);
            if (general) {
                foreach (const TriggerSkill *skill, general->getTriggerSkills()) {
                    if (skill->isVisible())
                        room->getThread()->addTriggerSkill(skill);
                }
            }
        }
        zuoci->tag["Huashens"] = huashens;

        QStringList hidden;
        for (int i = 0; i < n; i++) hidden << "unknown";
        foreach (ServerPlayer *p, room->getAllPlayers()) {
            if (p == zuoci)
                room->doAnimate(QSanProtocol::S_ANIMATE_HUASHEN, zuoci->objectName(), acquired.join(":"), QList<ServerPlayer *>() << p);
            else
                room->doAnimate(QSanProtocol::S_ANIMATE_HUASHEN, zuoci->objectName(), hidden.join(":"), QList<ServerPlayer *>() << p);
        }

        LogMessage log;
        log.type = "#GetHuashen";
        log.from = zuoci;
        log.arg = QString::number(n);
        log.arg2 = QString::number(huashens.length());
        room->sendLog(log);

        LogMessage log2;
        log2.type = "#GetHuashenDetail";
        log2.from = zuoci;
        log2.arg = acquired.join("\\, \\");
        room->sendLog(log2, zuoci);

        room->setPlayerMark(zuoci, "@huashen", huashens.length());
    }

    static QStringList GetAvailableGenerals(ServerPlayer *zuoci)
    {
        QSet<QString> all = Sanguosha->getLimitedGeneralNames().toSet();
        Room *room = zuoci->getRoom();
        if (isNormalGameMode(room->getMode())
            || room->getMode().contains("_mini_")
            || room->getMode() == "custom_scenario")
            all.subtract(Config.value("Banlist/Roles", "").toStringList().toSet());
        else if (room->getMode() == "06_XMode") {
            foreach(ServerPlayer *p, room->getAlivePlayers())
                all.subtract(p->tag["XModeBackup"].toStringList().toSet());
        } else if (room->getMode() == "02_1v1") {
            all.subtract(Config.value("Banlist/1v1", "").toStringList().toSet());
            foreach(ServerPlayer *p, room->getAlivePlayers())
                all.subtract(p->tag["1v1Arrange"].toStringList().toSet());
        }
        QSet<QString> huashen_set, room_set;
        QVariantList huashens = zuoci->tag["Huashens"].toList();
        foreach(QVariant huashen, huashens)
            huashen_set << huashen.toString();
        foreach (ServerPlayer *player, room->getAlivePlayers()) {
            QString name = player->getGeneralName();
            if (Sanguosha->isGeneralHidden(name)) {
                QString fname = Sanguosha->findConvertFrom(name);
                if (!fname.isEmpty()) name = fname;
            }
            room_set << name;

            if (!player->getGeneral2()) continue;

            name = player->getGeneral2Name();
            if (Sanguosha->isGeneralHidden(name)) {
                QString fname = Sanguosha->findConvertFrom(name);
                if (!fname.isEmpty()) name = fname;
            }
            room_set << name;
        }

        static QSet<QString> banned;
        if (banned.isEmpty()) {
            banned << "zuoci" << "guzhielai" << "dengshizai" << "yt_caochong" << "jiangboyue";
        }

        return (all - banned - huashen_set - room_set).toList();
    }

    static void SelectSkill(ServerPlayer *zuoci)
    {
        Room *room = zuoci->getRoom();
        playAudioEffect(zuoci, "huashen");
        QStringList ac_dt_list;

        QString huashen_skill = zuoci->tag["HuashenSkill"].toString();
        if (!huashen_skill.isEmpty())
            ac_dt_list.append("-" + huashen_skill);

        QVariantList huashens = zuoci->tag["Huashens"].toList();
        if (huashens.isEmpty()) return;

        QStringList huashen_generals;
        foreach(QVariant huashen, huashens)
            huashen_generals << huashen.toString();

        QStringList skill_names;
        QString skill_name;
        const General *general = NULL;
        AI* ai = zuoci->getAI();
        if (ai) {
            QHash<QString, const General *> hash;
            foreach (QString general_name, huashen_generals) {
                const General *general = Sanguosha->getGeneral(general_name);
                foreach (const Skill *skill, general->getVisibleSkillList()) {
                    if (skill->isLordSkill()
                        || skill->getFrequency() == Skill::Limited
                        || skill->getFrequency() == Skill::Wake)
                        continue;

                    if (!skill_names.contains(skill->objectName())) {
                        hash[skill->objectName()] = general;
                        skill_names << skill->objectName();
                    }
                }
            }
            if (skill_names.isEmpty()) return;
            skill_name = ai->askForChoice("huashen", skill_names.join("+"), QVariant());
            general = hash[skill_name];
            Q_ASSERT(general != NULL);
        } else {
            QString general_name = room->askForGeneral(zuoci, huashen_generals);
            general = Sanguosha->getGeneral(general_name);

            foreach (const Skill *skill, general->getVisibleSkillList()) {
                if (skill->isLordSkill()
                    || skill->getFrequency() == Skill::Limited
                    || skill->getFrequency() == Skill::Wake)
                    continue;

                skill_names << skill->objectName();
            }

            if (!skill_names.isEmpty())
                skill_name = room->askForChoice(zuoci, "huashen", skill_names.join("+"));
        }
        //Q_ASSERT(!skill_name.isNull() && !skill_name.isEmpty());

        QString kingdom = general->getKingdom();
        if (zuoci->getKingdom() != kingdom) {
            if (kingdom == "god")
                kingdom = room->askForKingdom(zuoci);
            room->setPlayerProperty(zuoci, "kingdom", kingdom);
        }

        if (zuoci->getGender() != general->getGender())
            zuoci->setGender(general->getGender());

        JsonArray arg;
        arg << QSanProtocol::S_GAME_EVENT_HUASHEN << zuoci->objectName() << general->objectName() << skill_name;
        room->doBroadcastNotify(QSanProtocol::S_COMMAND_LOG_EVENT, arg);

        zuoci->tag["HuashenSkill"] = skill_name;
        if (!skill_name.isEmpty())
            ac_dt_list.append(skill_name);
        room->handleAcquireDetachSkills(zuoci, ac_dt_list, true);
    }

    virtual void onGameStart(ServerPlayer *zuoci) const
    {
        zuoci->getRoom()->notifySkillInvoked(zuoci, "huashen");
        AcquireGenerals(zuoci, 2);
        SelectSkill(zuoci);
    }

    virtual QDialog *getDialog() const
    {
        static HuashenDialog *dialog;

        if (dialog == NULL)
            dialog = new HuashenDialog;

        return dialog;
    }
};

HuashenDialog::HuashenDialog()
{
    setWindowTitle(Sanguosha->translate("huashen"));
}

void HuashenDialog::popup()
{
    QVariantList huashen_list = Self->tag["Huashens"].toList();
    QList<const General *> huashens;
    foreach(QVariant huashen, huashen_list)
        huashens << Sanguosha->getGeneral(huashen.toString());

    fillGenerals(huashens);
    show();
}

class HuashenSelect : public PhaseChangeSkill
{
public:
    HuashenSelect() : PhaseChangeSkill("#huashen-select")
    {
    }

    virtual int getPriority(TriggerEvent) const
    {
        return 4;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return PhaseChangeSkill::triggerable(target)
            && (target->getPhase() == Player::RoundStart || target->getPhase() == Player::NotActive);
    }

    virtual bool onPhaseChange(ServerPlayer *zuoci) const
    {
        if (zuoci->askForSkillInvoke("huashen"))
            Huashen::SelectSkill(zuoci);
        return false;
    }
};

class HuashenClear : public DetachEffectSkill
{
public:
    HuashenClear() : DetachEffectSkill("huashen")
    {
    }

    virtual void onSkillDetached(Room *room, ServerPlayer *player) const
    {
        if (player->getKingdom() != player->getGeneral()->getKingdom() && player->getGeneral()->getKingdom() != "god")
            room->setPlayerProperty(player, "kingdom", player->getGeneral()->getKingdom());
        if (player->getGender() != player->getGeneral()->getGender())
            player->setGender(player->getGeneral()->getGender());
        QString huashen_skill = player->tag["HuashenSkill"].toString();
        if (!huashen_skill.isEmpty())
            room->detachSkillFromPlayer(player, huashen_skill, false, true);
        player->tag.remove("Huashens");
        room->setPlayerMark(player, "@huashen", 0);
    }
};

class Xinsheng : public MasochismSkill
{
public:
    Xinsheng() : MasochismSkill("xinsheng")
    {
        frequency = Frequent;
    }

    virtual void onDamaged(ServerPlayer *zuoci, const DamageStruct &damage) const
    {
        if (zuoci->askForSkillInvoke(this)) {
            Huashen::playAudioEffect(zuoci, objectName());
            Huashen::AcquireGenerals(zuoci, damage.damage);
        }
    }
};

MountainPackage::MountainPackage()
    : Package("mountain")
{
    General *zhanghe = new General(this, "zhanghe", "wei"); // WEI 009
    zhanghe->addSkill(new Qiaobian);

    General *dengai = new General(this, "dengai", "wei", 4); // WEI 015
    dengai->addSkill(new Tuntian);
    dengai->addSkill(new TuntianDistance);
    dengai->addSkill(new Zaoxian);
    dengai->addRelateSkill("jixi");
    related_skills.insertMulti("tuntian", "#tuntian-dist");

    General *jiangwei = new General(this, "jiangwei", "shu"); // SHU 012
    jiangwei->addSkill(new Tiaoxin);
    jiangwei->addSkill(new Zhiji);

    General *liushan = new General(this, "liushan$", "shu", 3); // SHU 013
    liushan->addSkill(new Xiangle);
    liushan->addSkill(new Fangquan);
    liushan->addSkill(new Ruoyu);

    General *sunce = new General(this, "sunce$", "wu"); // WU 010
    sunce->addSkill(new Jiang);
    sunce->addSkill(new Hunzi);
    sunce->addSkill(new Zhiba);

    General *erzhang = new General(this, "erzhang", "wu", 3); // WU 015
    erzhang->addSkill(new Zhijian);
    erzhang->addSkill(new Guzheng);

    General *zuoci = new General(this, "zuoci", "qun", 3); // QUN 009
    zuoci->addSkill(new Huashen);
    zuoci->addSkill(new HuashenSelect);
    zuoci->addSkill(new HuashenClear);
    zuoci->addSkill(new Xinsheng);
    related_skills.insertMulti("huashen", "#huashen-select");
    related_skills.insertMulti("huashen", "#huashen-clear");

    General *caiwenji = new General(this, "caiwenji", "qun", 3, false); // QUN 012
    caiwenji->addSkill(new Beige);
    caiwenji->addSkill(new Duanchang);

    addMetaObject<QiaobianCard>();
    addMetaObject<TiaoxinCard>();
    addMetaObject<ZhijianCard>();
    addMetaObject<ZhibaCard>();
    addMetaObject<FangquanCard>();

    skills << new ZhibaPindian << new Jixi;
}

ADD_PACKAGE(Mountain)

