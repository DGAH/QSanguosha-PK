#ifndef _SPECIAL3V3_H
#define _SPECIAL3V3_H

#include "standard-equips.h"

class VSCrossbow : public Crossbow
{
    Q_OBJECT

public:
    Q_INVOKABLE VSCrossbow(Card::Suit suit, int number = 1);

    virtual bool match(const QString &pattern) const;
};

class New3v3CardPackage : public Package
{
    Q_OBJECT

public:
    New3v3CardPackage();
};

class New3v3_2013CardPackage : public Package
{
    Q_OBJECT

public:
    New3v3_2013CardPackage();
};

#endif

