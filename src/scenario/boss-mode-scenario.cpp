#include "boss-mode-scenario.h"
#include "engine.h"
#include "standard-skillcards.h"
#include "clientplayer.h"
#include "client.h"
#include "carditem.h"
#include "room.h"

#include <QTime>

class Silue : public PhaseChangeSkill
{
public:
    Silue() :PhaseChangeSkill("silue")
    {
        frequency = Compulsory;
    }

    virtual bool onPhaseChange(ServerPlayer *player) const
    {
        if (player->getPhase() != Player::Draw)  return false;
        Room *room = player->getRoom();
        QList<ServerPlayer *> players = room->getOtherPlayers(player);
        bool has_frantic = player->getMark("@frantic") > 0;
        room->broadcastSkillInvoke(objectName());

        if (has_frantic) {
            foreach (ServerPlayer *target, players) {
                if (target->getCards("he").length() == 0)
                    continue;
                int card_id = room->askForCardChosen(player, target, "he", objectName());
                room->obtainCard(player, card_id, room->getCardPlace(card_id) != Player::PlaceHand);
            }
            return true;
        } else {
            player->drawCards(player->getHp());
            return true;
        }
        return false;
    }
};

class Kedi : public MasochismSkill
{
public:
    Kedi() :MasochismSkill("kedi")
    {
        frequency = Frequent;
    }

    virtual void onDamaged(ServerPlayer *player, const DamageStruct &) const
    {
        Room *room = player->getRoom();
        QList<ServerPlayer *> players = room->getAlivePlayers();
        bool has_frantic = player->getMark("@frantic") > 0;

        if (!room->askForSkillInvoke(player, objectName()))
            return;

        room->broadcastSkillInvoke(objectName());
        int n = 0;
        if (has_frantic)
            n = players.length();
        else
            n = (player->getHp());
        player->drawCards(n);
    }
};

class Jishi : public PhaseChangeSkill
{
public:
    Jishi() :PhaseChangeSkill("jishi")
    {
        frequency = Compulsory;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->isLord();
    }

    virtual bool onPhaseChange(ServerPlayer *target) const
    {
        Room *room = target->getRoom();
        QList<ServerPlayer *> players = room->getAlivePlayers();
        QList<ServerPlayer *> others = room->getOtherPlayers(target);
        bool has_frantic = target->getMark("@frantic") > 0;

        if (target->getPhase() == Player::Start) {
            bool invoke_skill = false;
            if (has_frantic) {
                if (target->getHandcardNum() <= (target->getMaxHp() + players.length()))
                    invoke_skill = true;
            } else {
                if (target->getHandcardNum() <= target->getHp())
                    invoke_skill = true;
            }
            if (!invoke_skill)
                return false;

            LogMessage log;
            log.type = "#TriggerSkill";
            log.from = target;
            log.arg = objectName();
            room->sendLog(log);

            foreach (ServerPlayer *player, others) {
                if (player->getHandcardNum() == 0) {
                    if (has_frantic)
                        room->loseHp(player, 2);
                    else
                        room->loseHp(player);
                } else {
                    int card_id = room->askForCardChosen(target, player, "h", objectName());
                    room->obtainCard(target, card_id, false);
                }
            }
        } else
            if (target->getPhase() == Player::Discard) {
                int n = 0;
                n = target->getHandcardNum() - players.length();
                if (n > 0) {
                    room->askForDiscard(target, objectName(), n, n, false);
                    return true;
                }
            }
        return false;
    }
};

class Daji : public TriggerSkill
{
public:
    Daji() :TriggerSkill("daji")
    {
        events << Damaged << EventPhaseStart << TargetConfirmed << CardFinished << CardEffected << DamageInflicted;
        frequency = Compulsory;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room* room, ServerPlayer *player, QVariant &data) const
    {
        room->broadcastSkillInvoke(objectName());
        QList<ServerPlayer *> players = room->getAlivePlayers();
        bool has_frantic = player->getMark("@frantic") > 0;

        if (TriggerSkill::triggerable(player) && triggerEvent == EventPhaseStart && player->getPhase() == Player::Finish) {
            if (has_frantic)
                player->drawCards(players.length());
            else
                player->drawCards(player->getMaxHp());
        }

        if (has_frantic) {
            if (TriggerSkill::triggerable(player) && player->isWounded() && triggerEvent == TargetConfirmed) {
                CardUseStruct use = data.value<CardUseStruct>();
                if (use.to.length() > 0 && player == use.to.first()) {
                    foreach (ServerPlayer *p, use.to) {
                        if (p != player)
                            return false;
                    }
                    player->addMark("DajiOnlyTarget");
                }
            } else if (player->getMark("DajiOnlyTarget") > 0 && triggerEvent == CardEffected) {
                CardEffectStruct effect = data.value<CardEffectStruct>();
                if (effect.card->isKindOf("TrickCard") && player->getPhase() == Player::NotActive) {
                    LogMessage log;
                    log.type = "#DajiAvoid";
                    log.from = effect.from;
                    log.to << player;
                    log.arg = effect.card->objectName();
                    log.arg2 = objectName();

                    room->sendLog(log);

                    return true;
                }
            } else if (triggerEvent == CardFinished) {
                CardUseStruct use = data.value<CardUseStruct>();
                if (use.to.length() > 0 && use.to.first()->getMark("DajiOnlyTarget") > 0)
                    use.to.first()->removeMark("DajiOnlyTarget");
            }
        }

        if (TriggerSkill::triggerable(player) && triggerEvent == DamageInflicted) {
            DamageStruct damage = data.value<DamageStruct>();
            if (damage.damage > 1) {
                damage.damage = damage.damage - 1;
                data = QVariant::fromValue(damage);

                LogMessage log;
                log.type = "#TriggerSkill";
                log.from = player;
                log.arg = objectName();
                room->sendLog(log);
                return false;
            }
        }
        return false;
    }
};

class Guzhan : public TriggerSkill
{
public:
    Guzhan() :TriggerSkill("guzhan")
    {
        events << CardsMoveOneTime;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room* room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == CardsMoveOneTime) {
            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
            if (move.from != player)
                return false;

            if (player->getWeapon() == NULL) {
                if (!player->hasSkill("paoxiao"))
                    room->acquireSkill(player, "paoxiao");
            } else {
                if (player->hasSkill("paoxiao"))
                    room->detachSkillFromPlayer(player, "paoxiao");
            }
        }
        return false;
    }
};

class Jizhan : public TriggerSkill
{
public:
    Jizhan() :TriggerSkill("jizhan")
    {
        events << Damage << CardsMoveOneTime;
        frequency = Compulsory;
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room* room, ServerPlayer *player, QVariant &data) const
    {
        if (player->getPhase() != Player::Play) return false;

        if (player->getHp() != player->getMaxHp() && triggerEvent == Damage) {
            RecoverStruct recover;
            recover.who = player;
            recover.recover = 1;
            room->recover(player, recover);
        } else if (triggerEvent == CardsMoveOneTime) {
            CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
            if (move.from != player)
                return false;
            QList<ServerPlayer *> players = room->getAlivePlayers();
            if (player->getHandcardNum() < players.length())
                player->drawCards(1);
        }
        return false;
    }
};

class Duduan : public ProhibitSkill
{
public:
    Duduan() :ProhibitSkill("duduan")
    {
    }

    virtual bool isProhibited(const Player *, const Player *to, const Card *card, const QList<const Player *> &) const
    {
        return to->hasSkill(this) && card->isKindOf("DelayedTrick");
    }
};

class ImpasseRule : public ScenarioRule
{
public:
    ImpasseRule(Scenario *scenario)
        :ScenarioRule(scenario)
    {
        events << GameStart << TurnStart << EventPhaseStart
            << BuryVictim << GameOverJudge << Damaged << PreHpLost;

        boss_banlist << "yuanshao" << "yanliangwenchou" << "zhaoyun" << "guanyu" << "shencaocao";

        boss_skillbanned << "luanji" << "shuangxiong" << "longdan" << "wusheng" << "guixin" << "fenyong" << "xuehen";

        dummy_skills << "xinsheng" << "wuhu" << "kuangfeng" << "dawu" << "wumou" << "wuqian"
            << "shenfen" << "renjie" << "weidi" << "danji" << "shiyong" << "zhiba"
            << "super_guanxing" << "chongzhen" << "tongxin"
            << "liqian" << "shenjun" << "xunzhi" << "shenli" << "yishe" << "yitian"
            << "fenyong" << "xuehen";

        available_wake_skills << "hunzi" << "zhiji";
    }

    void getRandomSkill(ServerPlayer *player, bool need_trans = false) const
    {
        Room *room = player->getRoom();
        qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));

        QStringList all_generals = Sanguosha->getLimitedGeneralNames();
        QList<ServerPlayer *> players = room->getAllPlayers();
        foreach (ServerPlayer *player, players) {
            all_generals.removeOne(player->getGeneralName());
        }

        if (need_trans) {
            QString new_lord;

            do {
                int seed = qrand() % all_generals.length();
                new_lord = all_generals[seed];
            } while (boss_banlist.contains(new_lord));

            room->changeHero(player, new_lord, false);
            return;
        }

        QStringList all_skills;
        foreach (QString one, all_generals) {
            const General *general = Sanguosha->getGeneral(one);
            QList<const Skill *> skills = general->findChildren<const Skill *>();
            foreach (const Skill *skill, skills) {
                if (!skill->isLordSkill() && !skill->inherits("SPConvertSkill")) {
                    if (dummy_skills.contains(skill->objectName()))
                        continue;

                    if (skill->getFrequency() == Skill::Wake
                        && !available_wake_skills.contains(skill->objectName()))
                        continue;

                    if (!skill->objectName().startsWith("#"))
                        all_skills << skill->objectName();
                }
            }
        }

        QString got_skill;
        do {
            int index;
            do {
                index = qrand() % all_skills.length();
            } while (player->isLord() && boss_skillbanned.contains(all_skills[index]));
            got_skill = all_skills[index];

        } while (hasSameSkill(room, got_skill));
        room->acquireSkill(player, got_skill);
    }

    bool hasSameSkill(Room *room, QString skill_name) const
    {
        foreach (ServerPlayer *player, room->getAllPlayers()) {
            QList<const Skill *> skills = player->getVisibleSkillList();
            const Skill *skill = Sanguosha->getSkill(skill_name);
            if (skills.contains(skill))
                return true;
        }

        return false;
    }

    void removeLordSkill(ServerPlayer *player) const
    {
        const General *lord = Sanguosha->getGeneral(player->getGeneralName());
        QList<const Skill *> lord_skills = lord->findChildren<const Skill *>();
        foreach (const Skill *skill, lord_skills) {
            if (skill->isLordSkill())
                player->getRoom()->detachSkillFromPlayer(player, skill->objectName());
        }
    }

    void startDeadJudge(ServerPlayer *lord) const
    {
        Room *room = lord->getRoom();

        LogMessage log;
        log.type = "#BaozouOver";
        log.from = lord;
        room->sendLog(log);

        QList<ServerPlayer *> players = room->getOtherPlayers(lord);
        foreach (ServerPlayer *player, players) {
            JudgeStruct judge;
            judge.pattern = "Peach,Analeptic";
            judge.good = true;
            judge.who = player;

            room->judge(judge);
            if (judge.isBad())
                room->loseHp(player, player->getHp());
        }
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room* room, ServerPlayer *player, QVariant &data) const
    {
        switch (triggerEvent) {
        case GameStart:{
            if (player == NULL) {
                player = room->getLord();
                if (boss_banlist.contains(player->getGeneralName()))
                    getRandomSkill(player, true);

                removeLordSkill(player);

                room->installEquip(player, "SilverLion");
                qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));
                if ((qrand() % 2) == 1) {
                    room->acquireSkill(player, "silue");
                    room->acquireSkill(player, "kedi");
                } else {
                    room->acquireSkill(player, "jishi");
                    room->acquireSkill(player, "daji");
                }

                int maxhp = 8 - ((player->getMaxHp() % 3) % 2);
                room->setPlayerProperty(player, "maxhp", maxhp);
                room->setPlayerProperty(player, "hp", maxhp);

                foreach (ServerPlayer* serverPlayer, room->getPlayers()) {
                    getRandomSkill(serverPlayer);
                }

                room->setTag("FirstRound", true);
            }
            break;
        }

        case TurnStart:{
            if (player->isLord() && player->faceUp()) {
                bool hasLoseMark = false;
                if (player->getMark("@frantic") > 0) {
                    player->loseMark("@frantic");
                    hasLoseMark = true;
                }

                if (hasLoseMark && player->getMark("@frantic") == 0) {
                    startDeadJudge(player);
                    player->addMark("frantic_over");
                }
            }
            break;
        }

        case EventPhaseStart:{
            if (player->isLord() && player->getMark("frantic_over") > 0 && player->getPhase() == Player::Finish)
                player->getRoom()->killPlayer(player);
            break;
        }

        case GameOverJudge:{
            return true;
            break;
        }

        case BuryVictim:{
            QList<ServerPlayer *> players = room->getAlivePlayers();
            ServerPlayer *lord = room->getLord();

            if (player->isLord()) room->gameOver("rebel");
            if (players.length() == 1 && lord->isAlive()) room->gameOver("lord");

            if (lord->getMaxHp() > 3)
                room->setPlayerProperty(lord, "maxhp", lord->getMaxHp() - 1);

            if (lord->getMark("@frantic") > (players.length() - 1))
                lord->loseMark("@frantic");

            QStringList alive_roles = room->aliveRoles();
            if (alive_roles.contains("rebel") && !alive_roles.contains("lord"))
                room->gameOver("rebel");
            if (alive_roles.contains("lord") && !alive_roles.contains("rebel"))
                room->gameOver("lord");

            DeathStruct death = data.value<DeathStruct>();
            DamageStruct *damage = death.damage;
            if (damage && damage->from) {
                if (damage->from->getRole() == damage->to->getRole())
                    damage->from->throwAllHandCards();
                else {
                    if (damage->to->hasSkill("huilei")) {
                        damage->from->throwAllHandCards();
                        damage->from->throwAllEquips();
                    }

                    damage->from->drawCards(2);
                }

                damage = NULL;
                data = QVariant::fromValue(death);
            }
            break;
        }

        case PreHpLost:
        case Damaged:{
            if (player->isLord()) {
                if (player->getHp() <= 3 && player->getMark("@frantic") <= 0) {
                    LogMessage log;
                    log.type = "#Baozou";
                    log.from = player;
                    room->sendLog(log);

                    QList<ServerPlayer *> others = room->getOtherPlayers(player);
                    player->gainMark("@frantic", others.length());
                    room->setPlayerProperty(player, "maxhp", 3);
                    room->acquireSkill(player, "guzhan");
                    room->acquireSkill(player, "duduan");
                    room->acquireSkill(player, "jizhan");
                    if (player->getWeapon() == NULL) {
                        room->acquireSkill(player, "paoxiao");
                    }

                    QList<const Card *> judges = player->getCards("j");
                    foreach(const Card *card, judges)
                        room->throwCard(card->getEffectiveId(), NULL);
                }
            }
            break;
        }

        default:
            break;
        }

        return false;
    }

private:
    QStringList boss_banlist, boss_skillbanned;
    QStringList dummy_skills, available_wake_skills;
};

bool ImpasseScenario::exposeRoles() const
{
    return true;
}

void ImpasseScenario::assign(QStringList &generals, QStringList &roles) const
{
    Q_UNUSED(generals);

    roles << "lord";
    int i;
    for (i = 0; i < 7; i++)
        roles << "rebel";

    qShuffle(roles);
}

int ImpasseScenario::getPlayerCount() const
{
    return 8;
}

QString ImpasseScenario::getRoles() const
{
    return "ZFFFFFFF";
}

void ImpasseScenario::onTagSet(Room *, const QString &) const
{
    // dummy
}

bool ImpasseScenario::generalSelection() const
{
    return true;
}

ImpasseScenario::ImpasseScenario()
    :Scenario("impasse_fight")
{
    rule = new ImpasseRule(this);

    skills << new Silue << new Kedi
        << new Daji << new Jishi
        << new Guzhan << new Jizhan << new Duduan;

}

