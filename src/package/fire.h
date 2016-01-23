#ifndef _FIRE_H
#define _FIRE_H

#include "package.h"
#include "card.h"

class FirePackage : public Package
{
    Q_OBJECT

public:
    FirePackage();
};

class QuhuCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE QuhuCard();

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class QiangxiCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE QiangxiCard();

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void onEffect(const CardEffectStruct &effect) const;
};

class TianyiCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE TianyiCard();

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

#endif

