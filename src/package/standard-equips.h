#ifndef _STANDARD_EQUIPS_H
#define _STANDARD_EQUIPS_H

#include "standard.h"

class Crossbow : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE Crossbow(Card::Suit suit, int number = 1);
};

class DoubleSword : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE DoubleSword(Card::Suit suit = Spade, int number = 2);
};

class QinggangSword : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE QinggangSword(Card::Suit suit = Spade, int number = 6);
};

class Blade : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE Blade(Card::Suit suit = Spade, int number = 5);
};

class Spear : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE Spear(Card::Suit suit = Spade, int number = 12);
};

class Axe : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE Axe(Card::Suit suit = Diamond, int number = 5);
};

class Halberd : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE Halberd(Card::Suit suit = Diamond, int number = 12);
};

class KylinBow : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE KylinBow(Card::Suit suit = Heart, int number = 5);
};

class EightDiagram : public Armor
{
    Q_OBJECT

public:
    Q_INVOKABLE EightDiagram(Card::Suit suit, int number = 2);
};

class IceSword : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE IceSword(Card::Suit suit, int number);
};

class RenwangShield : public Armor
{
    Q_OBJECT

public:
    Q_INVOKABLE RenwangShield(Card::Suit suit, int number);
};

class WoodenOxCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE WoodenOxCard();

    virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class WoodenOx : public Treasure
{
    Q_OBJECT

public:
    Q_INVOKABLE WoodenOx(Card::Suit suit, int number);

    virtual void onUninstall(ServerPlayer *player) const;
};

class StandardCardPackage : public Package
{
    Q_OBJECT

public:
    StandardCardPackage();
};

class StandardExCardPackage : public Package
{
    Q_OBJECT

public:
    StandardExCardPackage();
};

class LimitationBrokenPackage : public Package
{
    Q_OBJECT

public:
    LimitationBrokenPackage();
};

#endif

