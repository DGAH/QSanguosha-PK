#ifndef YITIANPACKAGE_H
#define YITIANPACKAGE_H

#include "standard.h"

class YitianSword :public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE YitianSword(Card::Suit suit = Spade, int number = 6);

    virtual void onUninstall(ServerPlayer *player) const;
};

class YitianCardPackage : public Package
{
    Q_OBJECT

public:
    YitianCardPackage();
};

#endif // YITIANPACKAGE_H
