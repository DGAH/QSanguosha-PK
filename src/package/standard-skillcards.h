#ifndef _STANDARD_SKILLCARDS_H
#define _STANDARD_SKILLCARDS_H

#include "card.h"

class ZhihengCard : public SkillCard
{
    Q_OBJECT

public:
    Q_INVOKABLE ZhihengCard();
    virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class HuanhuoCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE HuanhuoCard();

	virtual bool targetFixed() const;
	virtual bool targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const;
	virtual bool targetsFeasible(const QList<const Player *> &targets, const Player *Self) const;

	virtual const Card *validate(CardUseStruct &card_use) const;
	virtual const Card *validateInResponse(ServerPlayer *user) const;
};

class XianzhuoCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE XianzhuoCard();

	virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

#endif
