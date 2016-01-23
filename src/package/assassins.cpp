#include "assassins.h"
#include "skill.h"
#include "standard.h"
#include "clientplayer.h"
#include "engine.h"

class Moukui : public TriggerSkill
{
public:
    Moukui() : TriggerSkill("moukui")
    {
        events << TargetSpecified << SlashMissed << CardFinished;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == TargetSpecified && TriggerSkill::triggerable(player)) {
            CardUseStruct use = data.value<CardUseStruct>();
            if (!use.card->isKindOf("Slash"))
                return false;
            foreach (ServerPlayer *p, use.to) {
                if (player->askForSkillInvoke(this, QVariant::fromValue(p))) {
                    QString choice;
                    if (!player->canDiscard(p, "he"))
                        choice = "draw";
                    else
                        choice = room->askForChoice(player, objectName(), "draw+discard", QVariant::fromValue(p));
                    if (choice == "draw") {
                        room->broadcastSkillInvoke(objectName(), 1);
                        player->drawCards(1, objectName());
                    } else {
                        room->broadcastSkillInvoke(objectName(), 2);
                        room->setTag("MoukuiDiscard", data);
                        int disc = room->askForCardChosen(player, p, "he", objectName(), false, Card::MethodDiscard);
                        room->removeTag("MoukuiDiscard");
                        room->throwCard(disc, p, player);
                    }
                    room->addPlayerMark(p, objectName() + use.card->toString());
                }
            }
        } else if (triggerEvent == SlashMissed) {
            SlashEffectStruct effect = data.value<SlashEffectStruct>();
            if (effect.to->isDead() || effect.to->getMark(objectName() + effect.slash->toString()) <= 0)
                return false;
            if (!effect.from->isAlive() || !effect.to->isAlive() || !effect.to->canDiscard(effect.from, "he"))
                return false;
            int disc = room->askForCardChosen(effect.to, effect.from, "he", objectName(), false, Card::MethodDiscard);
            room->broadcastSkillInvoke(objectName(), 3);
            room->throwCard(disc, effect.from, effect.to);
            room->removePlayerMark(effect.to, objectName() + effect.slash->toString());
        } else if (triggerEvent == CardFinished) {
            CardUseStruct use = data.value<CardUseStruct>();
            if (!use.card->isKindOf("Slash"))
                return false;
            foreach(ServerPlayer *p, room->getAllPlayers())
                room->setPlayerMark(p, objectName() + use.card->toString(), 0);
        }

        return false;
    }
};

class Tianming : public TriggerSkill
{
public:
    Tianming() : TriggerSkill("tianming")
    {
        events << TargetConfirming;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        CardUseStruct use = data.value<CardUseStruct>();
        if (use.card->isKindOf("Slash") && room->askForSkillInvoke(player, objectName())) {
            room->broadcastSkillInvoke(objectName(), 1);
            room->askForDiscard(player, objectName(), 2, 2, false, true);
            player->drawCards(2, objectName());

            int max = -1000;
            foreach (ServerPlayer *p, room->getAllPlayers()) {
                if (p->getHp() > max)
                    max = p->getHp();
            }
            if (player->getHp() == max)
                return false;

            QList<ServerPlayer *> maxs;
            foreach (ServerPlayer *p, room->getAllPlayers()) {
                if (p->getHp() == max)
                    maxs << p;
                if (maxs.size() > 1)
                    return false;
            }
            ServerPlayer *mosthp = maxs.first();
            if (room->askForSkillInvoke(mosthp, objectName())) {
                room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, player->objectName(), mosthp->objectName());
                int index = 2;
                if (mosthp->isFemale())
                    index = 3;
                room->broadcastSkillInvoke(objectName(), index);
                room->askForDiscard(mosthp, objectName(), 2, 2, false, true);
                mosthp->drawCards(2, objectName());
            }
        }

        return false;
    }
};

MizhaoCard::MizhaoCard()
{
    mute = true;
}

bool MizhaoCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select != Self;
}

void MizhaoCard::onEffect(const CardEffectStruct &effect) const
{
    DummyCard *handcards = effect.from->wholeHandCards();
    effect.to->obtainCard(handcards, false);
    delete handcards;
    if (effect.to->isKongcheng()) return;

    Room *room = effect.from->getRoom();
    room->broadcastSkillInvoke("mizhao", effect.to->getGeneralName().contains("liubei") ? 2 : 1);

    QList<ServerPlayer *> targets;
    foreach (ServerPlayer *p, room->getOtherPlayers(effect.to)) {
        if (!p->isKongcheng())
            targets << p;
    }

    if (!targets.isEmpty()) {
        ServerPlayer *target = room->askForPlayerChosen(effect.from, targets, "mizhao", "@mizhao-pindian:" + effect.to->objectName());
        room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, effect.to->objectName(), target->objectName());
        target->setFlags("MizhaoPindianTarget");
        effect.to->pindian(target, "mizhao", NULL);
        target->setFlags("-MizhaoPindianTarget");
    }
}

class MizhaoViewAsSkill : public ZeroCardViewAsSkill
{
public:
    MizhaoViewAsSkill() : ZeroCardViewAsSkill("mizhao")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->isKongcheng() && !player->hasUsed("MizhaoCard");
    }

    virtual const Card *viewAs() const
    {
        return new MizhaoCard;
    }
};

class Mizhao : public TriggerSkill
{
public:
    Mizhao() : TriggerSkill("mizhao")
    {
        events << Pindian;
        view_as_skill = new MizhaoViewAsSkill;
    }

    virtual int getPriority(TriggerEvent) const
    {
        return -1;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *, QVariant &data) const
    {
        PindianStruct *pindian = data.value<PindianStruct *>();
        if (pindian->reason != objectName() || pindian->from_number == pindian->to_number)
            return false;

        ServerPlayer *winner = pindian->isSuccess() ? pindian->from : pindian->to;
        ServerPlayer *loser = pindian->isSuccess() ? pindian->to : pindian->from;
        if (winner->canSlash(loser, NULL, false)) {
            Slash *slash = new Slash(Card::NoSuit, 0);
            slash->setSkillName("_mizhao");
            room->useCard(CardUseStruct(slash, winner, loser));
        }

        return false;
    }

    virtual int getEffectIndex(const ServerPlayer *, const Card *) const
    {
        return -2;
    }
};

class MizhaoSlashNoDistanceLimit : public TargetModSkill
{
public:
    MizhaoSlashNoDistanceLimit() : TargetModSkill("#mizhao-slash-ndl")
    {
    }

    virtual int getDistanceLimit(const Player *, const Card *card) const
    {
        if (card->isKindOf("Slash") && card->getSkillName() == "mizhao")
            return 1000;
        else
            return 0;
    }
};

class Jieyuan : public TriggerSkill
{
public:
    Jieyuan() : TriggerSkill("jieyuan")
    {
        events << DamageCaused << DamageInflicted;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DamageStruct damage = data.value<DamageStruct>();
        if (triggerEvent == DamageCaused) {
            if (damage.to && damage.to->isAlive()
                && damage.to->getHp() >= player->getHp() && damage.to != player && player->canDiscard(player, "h")
                && room->askForCard(player, ".black", "@jieyuan-increase:" + damage.to->objectName(), data, objectName())) {
                room->broadcastSkillInvoke(objectName(), 1);

                LogMessage log;
                log.type = "#JieyuanIncrease";
                log.from = player;
                log.arg = QString::number(damage.damage);
                log.arg2 = QString::number(++damage.damage);
                room->sendLog(log);

                data = QVariant::fromValue(damage);
            }
        } else if (triggerEvent == DamageInflicted) {
            if (damage.from && damage.from->isAlive()
                && damage.from->getHp() >= player->getHp() && damage.from != player && player->canDiscard(player, "h")
                && room->askForCard(player, ".red", "@jieyuan-decrease:" + damage.from->objectName(), data, objectName())) {
                room->broadcastSkillInvoke(objectName(), 2);

                LogMessage log;
                log.type = "#JieyuanDecrease";
                log.from = player;
                log.arg = QString::number(damage.damage);
                log.arg2 = QString::number(--damage.damage);
                room->sendLog(log);

                data = QVariant::fromValue(damage);
                if (damage.damage < 1)
                    return true;
            }
        }

        return false;
    }
};

class Fenxin : public TriggerSkill
{
public:
    Fenxin() : TriggerSkill("fenxin")
    {
        events << BeforeGameOverJudge;
        frequency = Limited;
        limit_mark = "@burnheart";
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (!isNormalGameMode(room->getMode()))
            return false;
        DeathStruct death = data.value<DeathStruct>();
        if (death.damage == NULL)
            return false;
        ServerPlayer *killer = death.damage->from;
        if (killer == NULL || killer->isLord() || player->isLord() || player->getHp() > 0)
            return false;
        if (!TriggerSkill::triggerable(killer) || killer->getMark("@burnheart") == 0)
            return false;
        player->setFlags("FenxinTarget");
        bool invoke = room->askForSkillInvoke(killer, objectName(), QVariant::fromValue(player));
        player->setFlags("-FenxinTarget");
        if (invoke) {
            room->broadcastSkillInvoke(objectName());
            //room->doLightbox("$FenxinAnimate");
            room->doSuperLightbox("lingju", "fenxin");
            room->removePlayerMark(killer, "@burnheart");
            QString role1 = killer->getRole();
            killer->setRole(player->getRole());
            room->notifyProperty(killer, killer, "role", player->getRole());
            room->setPlayerProperty(player, "role", role1);
        }
        return false;
    }
};

MixinCard::MixinCard()
{
    will_throw = false;
    mute = true;
    handling_method = Card::MethodNone;
}

bool MixinCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    return targets.isEmpty() && to_select != Self;
}

void MixinCard::onEffect(const CardEffectStruct &effect) const
{
    ServerPlayer *source = effect.from;
    ServerPlayer *target = effect.to;
    Room *room = source->getRoom();
    room->broadcastSkillInvoke("mixin", 1);
    target->obtainCard(this, false);
    QList<ServerPlayer *> others;
    foreach (ServerPlayer *p, room->getOtherPlayers(target)) {
        if (target->canSlash(p, NULL, false))
            others << p;
    }
    if (others.isEmpty())
        return;

    ServerPlayer *target2 = room->askForPlayerChosen(source, others, "mixin");
    LogMessage log;
    log.type = "#CollateralSlash";
    log.from = source;
    log.to << target2;
    room->sendLog(log);
    room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, target->objectName(), target2->objectName());
    if (room->askForUseSlashTo(target, target2, "#mixin", false)) {
        room->broadcastSkillInvoke("mixin", 2);
    } else {
        room->broadcastSkillInvoke("mixin", 3);
        QList<int> card_ids = target->handCards();
        room->fillAG(card_ids, target2);
        int cdid = room->askForAG(target2, card_ids, false, objectName());
        room->obtainCard(target2, cdid, false);
        room->clearAG(target2);
    }
    return;
}

class Mixin :public OneCardViewAsSkill
{
public:
    Mixin() :OneCardViewAsSkill("mixin")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->hasUsed("MixinCard");
    }

    virtual bool viewFilter(const Card *card) const
    {
        return !card->isEquipped();
    }

    virtual const Card *viewAs(const Card *originalCard) const
    {
        MixinCard *card = new MixinCard;
        card->addSubcard(originalCard);
        return card;
    }
};

class Cangni : public TriggerSkill
{
public:
    Cangni() :TriggerSkill("cangni")
    {
        events << EventPhaseStart << CardsMoveOneTime;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == EventPhaseStart && player->getPhase() == Player::Discard && player->askForSkillInvoke(this)) {
            QStringList choices;
            choices << "draw";
            if (player->isWounded())
                choices << "recover";

            QString choice;
            if (choices.size() == 1)
                choice = choices.first();
            else
                choice = room->askForChoice(player, objectName(), choices.join("+"));

            if (choice == "recover") {
                RecoverStruct recover;
                recover.who = player;
                room->recover(player, recover);
            } else
                player->drawCards(2);

            room->broadcastSkillInvoke("cangni", 1);
            player->turnOver();
            return false;
        } else if (triggerEvent == CardsMoveOneTime && !player->faceUp()) {
            if (player->getPhase() != Player::NotActive)
                return false;

            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
            ServerPlayer *target = room->getCurrent();
            if (target->isDead())
                return false;

            if (move.from == player && move.to != player) {
                bool invoke = false;
                for (int i = 0; i < move.card_ids.size(); i++) {
                    if (move.from_places[i] == Player::PlaceHand || move.from_places[i] == Player::PlaceEquip) {
                        invoke = true;
                        break;
                    }
                }
                room->setPlayerFlag(player, "cangnilose");    //for AI

                if (invoke && !target->isNude() && player->askForSkillInvoke(this)) {
                    room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, player->objectName(), target->objectName());
                    room->broadcastSkillInvoke("cangni", 3);
                    room->askForDiscard(target, objectName(), 1, 1, false, true);
                }

                room->setPlayerFlag(player, "-cangnilose");    //for AI

                return false;
            }

            if (move.to == player && move.from != player) {
                if (move.to_place == Player::PlaceHand || move.to_place == Player::PlaceEquip) {
                    room->setPlayerFlag(player, "cangniget");    //for AI

                    if (!target->hasFlag("cangni_used") && player->askForSkillInvoke(this)) {
                        room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, player->objectName(), target->objectName());
                        room->setPlayerFlag(target, "cangni_used");
                        room->broadcastSkillInvoke("cangni", 2);
                        target->drawCards(1);
                    }

                    room->setPlayerFlag(player, "-cangniget");    //for AI
                }
            }
        }

        return false;
    }
};

DuyiCard::DuyiCard()
{
    target_fixed = true;
    mute = true;
}

void DuyiCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &) const
{
    QList<int> card_ids = room->getNCards(1);
    int id = card_ids.first();
    room->fillAG(card_ids, NULL);
    room->getThread()->delay();
    ServerPlayer *target = room->askForPlayerChosen(source, room->getAlivePlayers(), "duyi");
    const Card *card = Sanguosha->getCard(id);
    target->obtainCard(card);
    if (card->isBlack()) {
        room->setPlayerCardLimitation(target, "use,response", ".|.|.|hand", false);
        room->setPlayerMark(target, "duyi_target", 1);
        LogMessage log;
        log.type = "#duyi_eff";
        log.from = source;
        log.to << target;
        log.arg = "duyi";
        room->sendLog(log);
        room->broadcastSkillInvoke("duyi", 1);
    } else
        room->broadcastSkillInvoke("duyi", 2);

    room->getThread()->delay();
    room->clearAG();
}

class DuyiViewAsSkill :public ZeroCardViewAsSkill
{
public:
    DuyiViewAsSkill() :ZeroCardViewAsSkill("duyi")
    {
    }

    virtual bool isEnabledAtPlay(const Player *player) const
    {
        return !player->hasUsed("DuyiCard");
    }

    virtual const Card *viewAs() const
    {
        return new DuyiCard;
    }
};

class Duyi :public TriggerSkill
{
public:
    Duyi() :TriggerSkill("duyi")
    {
        view_as_skill = new DuyiViewAsSkill;
        events << EventPhaseChanging << Death;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->hasInnateSkill(this);
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == Death) {
            DeathStruct death = data.value<DeathStruct>();
            if (death.who != player)
                return false;
        } else {
            PhaseChangeStruct change = data.value<PhaseChangeStruct>();
            if (change.to != Player::NotActive)
                return false;
        }

        foreach (ServerPlayer *p, room->getAlivePlayers()) {
            if (p->getMark("duyi_target") > 0) {
                room->removePlayerCardLimitation(p, "use,response", ".|.|.|hand$0");
                room->setPlayerMark(p, "duyi_target", 0);
                LogMessage log;
                log.type = "#duyi_clear";
                log.from = p;
                log.arg = objectName();
                room->sendLog(log);
            }
        }

        return false;
    }
};

class Duanzhi : public TriggerSkill
{
public:
    Duanzhi() : TriggerSkill("duanzhi")
    {
        events << TargetConfirmed;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        CardUseStruct use = data.value<CardUseStruct>();
        if (use.card->getTypeId() == Card::TypeSkill || use.from == player || !use.to.contains(player))
            return false;

        if (player->askForSkillInvoke(this, data)) {
            room->setPlayerFlag(player, "duanzhi_InTempMoving");
            ServerPlayer *target = use.from;
            DummyCard *dummy = new DummyCard;
            QList<int> card_ids;
            QList<Player::Place> original_places;
            for (int i = 0; i < 2; i++) {
                if (!player->canDiscard(target, "he"))
                    break;
                if (room->askForChoice(player, objectName(), "discard+cancel") == "cancel")
                    break;
                card_ids << room->askForCardChosen(player, target, "he", objectName());
                original_places << room->getCardPlace(card_ids[i]);
                dummy->addSubcard(card_ids[i]);
                target->addToPile("#duanzhi", card_ids[i], false);
            }

            if (dummy->subcardsLength() > 0)
                for (int i = 0; i < dummy->subcardsLength(); i++)
                    room->moveCardTo(Sanguosha->getCard(card_ids[i]), target, original_places[i], false);

            room->setPlayerFlag(player, "-duanzhi_InTempMoving");

            if (dummy->subcardsLength() > 0)
                room->throwCard(dummy, target, player);
            delete dummy;
            room->loseHp(player);
        }
        return false;
    }
};

class Fengyin :public TriggerSkill
{
public:
    Fengyin() :TriggerSkill("fengyin")
    {
        //        view_as_skill = new FengyinViewAsSkill;
        events << EventPhaseChanging << EventPhaseStart;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        ServerPlayer *splayer = room->findPlayerBySkillName(objectName());
        if (!splayer || splayer == player)
            return false;

        if (triggerEvent == EventPhaseChanging && data.value<PhaseChangeStruct>().to == Player::Start
            && player->getHp() >= splayer->getHp()) {
            const Card *card = room->askForCard(splayer, "Slash|.|.|hand", "@fengyin", QVariant(), Card::MethodNone);
            if (card) {
                room->doAnimate(QSanProtocol::S_ANIMATE_INDICATE, splayer->objectName(), player->objectName());
                player->obtainCard(card);
                room->broadcastSkillInvoke("fengyin");
                room->setPlayerFlag(player, "fengyin_target");
            }
        }

        if (triggerEvent == EventPhaseStart && player->hasFlag("fengyin_target")) {
            player->skip(Player::Play);
            player->skip(Player::Discard);
        }

        return false;
    }
};

class ChizhongKeep : public MaxCardsSkill
{
public:
    ChizhongKeep() :MaxCardsSkill("chizhong")
    {
    }

    virtual int getFixed(const Player *target) const
    {
        if (target->hasSkill(this))
            return target->getMaxHp();
        else
            return -1;
    }
};

class Chizhong : public TriggerSkill
{
public:
    Chizhong() :TriggerSkill("#chizhong")
    {
        events << Death;
    }

    virtual bool trigger(TriggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        DeathStruct death = data.value<DeathStruct>();
        if (death.who == player)
            return false;

        room->setPlayerProperty(player, "maxhp", player->getMaxHp() + 1);
        // @todo_P: log message here
        LogMessage log;
        log.type = "#TriggerSkill";
        log.from = player;
        log.arg = "chizhong";
        room->sendLog(log);
        room->broadcastSkillInvoke("chizhong", 2);

        return false;
    }
};

AssassinsPackage::AssassinsPackage() : Package("assassins")
{
    General *fuhuanghou = new General(this, "as_fuhuanghou", "qun", 3, false);
    fuhuanghou->addSkill(new Mixin);
    fuhuanghou->addSkill(new Cangni);

    General *jiben = new General(this, "as_jiben", "qun", 3);
    jiben->addSkill(new Duyi);
    jiben->addSkill(new Duanzhi);
    jiben->addSkill(new FakeMoveSkill("duanzhi"));
    related_skills.insertMulti("duanzhi", "#duanzhi-fake-move");

    General *fuwan = new General(this, "as_fuwan", "qun", 3);
    fuwan->addSkill(new Fengyin);
    fuwan->addSkill(new ChizhongKeep);
    fuwan->addSkill(new Chizhong);
    related_skills.insertMulti("chizhong", "#chizhong");

    General *mushun = new General(this, "as_mushun", "qun");
    mushun->addSkill(new Moukui);

    General *hanxiandi = new General(this, "as_liuxie", "qun", 3);
    hanxiandi->addSkill(new Tianming);
    hanxiandi->addSkill(new Mizhao);
    hanxiandi->addSkill(new MizhaoSlashNoDistanceLimit);
    related_skills.insertMulti("mizhao", "#mizhao-slash-ndl");

    General *lingju = new General(this, "as_lingju", "qun", 3, false);
    lingju->addSkill(new Jieyuan);
    lingju->addSkill(new Fenxin);

    addMetaObject<MizhaoCard>();
    addMetaObject<MixinCard>();
    addMetaObject<DuyiCard>();
}

ADD_PACKAGE(Assassins)
