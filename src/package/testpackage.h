#ifndef _TEST_PACKAGE_H
#define _TEST_PACKAGE_H

#include "package.h"
#include "maneuvering.h"

class TestPackage : public Package
{
	Q_OBJECT

public:
	TestPackage();
};

class GanranEquip : public IronChain
{
	Q_OBJECT

public:
	Q_INVOKABLE GanranEquip(Card::Suit suit, int number);
};

#endif