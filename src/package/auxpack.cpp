#include "auxpack.h"
#include "engine.h"
#include "clientplayer.h"

HuashenDialog::HuashenDialog()
{
	setWindowTitle(Sanguosha->translate("huashen"));
}

void HuashenDialog::popup()
{
	QVariantList huashen_list = Self->tag["Huashens"].toList();
	QList<const General *> huashens;
	foreach(QVariant huashen, huashen_list)
		huashens << Sanguosha->getGeneral(huashen.toString());

	fillGenerals(huashens);
	show();
}

NosRendeCard::NosRendeCard()
{
	mute = true;
	will_throw = false;
	handling_method = Card::MethodNone;
}

void NosRendeCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const
{
	ServerPlayer *target = targets.first();

	room->broadcastSkillInvoke("rende");
	CardMoveReason reason(CardMoveReason::S_REASON_GIVE, source->objectName(), target->objectName(), "nosrende", QString());
	room->obtainCard(target, this, reason, false);

	int old_value = source->getMark("nosrende");
	int new_value = old_value + subcards.length();
	room->setPlayerMark(source, "nosrende", new_value);

	if (old_value < 2 && new_value >= 2)
		room->recover(source, RecoverStruct(source));
}

AuxPackage::AuxPackage()
	:Package("auxpack")
{
	type = Package::SpecialPack;
	addMetaObject<NosRendeCard>();
}

ADD_PACKAGE(Aux)