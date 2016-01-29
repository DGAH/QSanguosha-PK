#ifndef JOYPACKAGE_H
#define JOYPACKAGE_H

#include "package.h"
#include "standard.h"

class JoyPackage : public Package
{
    Q_OBJECT

public:
    JoyPackage();
};

class DisasterPackage : public Package
{
    Q_OBJECT

public:
    DisasterPackage();
};

class JoyEquipPackage : public Package
{
    Q_OBJECT

public:
    JoyEquipPackage();
};

/*class Shit:public BasicCard{
    Q_OBJECT

    public:
    Q_INVOKABLE Shit(Card::Suit suit, int number);
    virtual QString getSubtype() const;
    virtual void onMove(const CardMoveStruct &move) const;

    static bool HasShit(const Card *card);
    };*/



// five disasters:

class Deluge : public Disaster
{
    Q_OBJECT

public:
    Q_INVOKABLE Deluge(Card::Suit suit, int number);
    virtual void takeEffect(ServerPlayer *target) const;
};

class Typhoon : public Disaster
{
    Q_OBJECT

public:
    Q_INVOKABLE Typhoon(Card::Suit suit, int number);
    virtual void takeEffect(ServerPlayer *target) const;
};

class Earthquake : public Disaster
{
    Q_OBJECT

public:
    Q_INVOKABLE Earthquake(Card::Suit suit, int number);
    virtual void takeEffect(ServerPlayer *target) const;
};

class Volcano : public Disaster
{
    Q_OBJECT

public:
    Q_INVOKABLE Volcano(Card::Suit suit, int number);
    virtual void takeEffect(ServerPlayer *target) const;
};

class MudSlide : public Disaster
{
    Q_OBJECT

public:
    Q_INVOKABLE MudSlide(Card::Suit suit, int number);
    virtual void takeEffect(ServerPlayer *target) const;
};

class Monkey : public OffensiveHorse
{
    Q_OBJECT

public:
    Q_INVOKABLE Monkey(Card::Suit suit, int number);
};

class GaleShell :public Armor
{
    Q_OBJECT

public:
    Q_INVOKABLE GaleShell(Card::Suit suit, int number);

    virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
};

class YxSword : public Weapon
{
    Q_OBJECT

public:
    Q_INVOKABLE YxSword(Card::Suit suit, int number);
};

class RendeCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE RendeCard();
	virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class JieyinCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE JieyinCard();
	virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
	virtual void onEffect(const CardEffectStruct &effect) const;
};

class GuoseCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE GuoseCard();

	virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
	virtual const Card *validate(CardUseStruct &cardUse) const;
	virtual void onUse(Room *room, const CardUseStruct &use) const;
	virtual void onEffect(const CardEffectStruct &effect) const;
};

class KurouCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE KurouCard();

	virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class FiveLines : public Armor
{
    Q_OBJECT

public:
    Q_INVOKABLE FiveLines(Card::Suit suit, int number);

    virtual void onInstall(ServerPlayer *player) const;
};

#endif // JOYPACKAGE_H
