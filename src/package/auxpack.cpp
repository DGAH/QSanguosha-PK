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

AuxPackage::AuxPackage()
	:Package("auxpack")
{
	type = Package::SpecialPack;
}

ADD_PACKAGE(Aux)