#ifndef _AUX_PACK_H
#define _AUX_PACK_H

#include "package.h"
#include "generaloverview.h"
#include "card.h"

class HuashenDialog : public GeneralOverview
{
	Q_OBJECT

public:
	HuashenDialog();

public slots:
	void popup();
};

class NosRendeCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE NosRendeCard();
	virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class AuxPackage : public Package
{
	Q_OBJECT

public:
	AuxPackage();
};

#endif // _AUX_PACK_H