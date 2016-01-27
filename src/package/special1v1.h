#ifndef _SPECIAL1V1_H
#define _SPECIAL1V1_H

#include "standard.h"

class Drowning : public SingleTargetTrick
{
    Q_OBJECT

public:
    Q_INVOKABLE Drowning(Card::Suit suit, int number);

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
    virtual void onEffect(const CardEffectStruct &effect) const;
};

class New1v1CardPackage : public Package
{
    Q_OBJECT

public:
    New1v1CardPackage();
};

#endif
