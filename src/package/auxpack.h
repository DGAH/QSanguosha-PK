#ifndef _AUX_PACK_H
#define _AUX_PACK_H

#include "package.h"
#include "generaloverview.h"

class HuashenDialog : public GeneralOverview
{
	Q_OBJECT

public:
	HuashenDialog();

public slots:
	void popup();
};

class AuxPackage : public Package
{
	Q_OBJECT

public:
	AuxPackage();
};

#endif // _AUX_PACK_H