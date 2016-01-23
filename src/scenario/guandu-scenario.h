#ifndef _GUANDU_SCENARIO_H
#define _GUANDU_SCENARIO_H

#include "scenario.h"
#include "card.h"
#include "standard.h"
#include "nostalgia.h"

class ZhanShuangxiongCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE ZhanShuangxiongCard();

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class SmallTuxiCard : public NosTuxiCard
{
    Q_OBJECT

public:
    Q_INVOKABLE SmallTuxiCard();
    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void onEffect(const CardEffectStruct &effect) const;
};

class GuanduScenario : public Scenario
{
    Q_OBJECT

public:
    GuanduScenario();

    virtual AI::Relation relationTo(const ServerPlayer *a, const ServerPlayer *b) const;
    virtual void onTagSet(Room *room, const QString &key) const;
};

#endif

