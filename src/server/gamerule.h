#ifndef _GAME_RULE_H
#define _GAME_RULE_H

#include "skill.h"

static QVariant _dummy_variant;

class GameRule : public TriggerSkill
{
    Q_OBJECT

public:
    enum BossModeDifficulty
    {
        BMDRevive,
        BMDRecover,
        BMDDraw,
        BMDReward,
        BMDIncMaxHp,
        BMDDecMaxHp
    };

    GameRule(QObject *parent);
    virtual bool triggerable(const ServerPlayer *target) const;
    virtual int getPriority(TriggerEvent triggerEvent) const;
    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data = _dummy_variant) const;

private:
    void onPhaseProceed(ServerPlayer *player) const;
    void rewardAndPunish(ServerPlayer *killer, ServerPlayer *victim) const;
    void changeGeneral1v1(ServerPlayer *player) const;
    void changeGeneralXMode(ServerPlayer *player) const;
    void changeGeneralBossMode(ServerPlayer *player) const;
    void acquireBossSkills(ServerPlayer *player, int level) const;
    void doBossModeDifficultySettings(ServerPlayer *lord) const;
    QString getWinner(ServerPlayer *victim) const;
};

class HulaoPassMode : public GameRule
{
    Q_OBJECT

public:
    HulaoPassMode(QObject *parent);
    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data = _dummy_variant) const;
};

class BasaraMode : public GameRule
{
    Q_OBJECT

public:
    BasaraMode(QObject *parent);

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data = _dummy_variant) const;
    virtual int getPriority(TriggerEvent triggerEvent) const;
    void playerShowed(ServerPlayer *player) const;
    void generalShowed(ServerPlayer *player, QString general_name) const;
    static QString getMappedRole(const QString &role);
};

#endif

