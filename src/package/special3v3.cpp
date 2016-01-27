#include "special3v3.h"
#include "maneuvering.h"

VSCrossbow::VSCrossbow(Suit suit, int number)
    : Crossbow(suit, number)
{
    setObjectName("vscrossbow");
}

bool VSCrossbow::match(const QString &pattern) const
{
    QStringList patterns = pattern.split("+");
    if (patterns.contains("crossbow"))
        return true;
    else
        return Crossbow::match(pattern);
}

New3v3CardPackage::New3v3CardPackage()
    : Package("New3v3Card")
{
    QList<Card *> cards;
    cards << new SupplyShortage(Card::Spade, 1)
        << new SupplyShortage(Card::Club, 12)
        << new Nullification(Card::Heart, 12);

    foreach(Card *card, cards)
        card->setParent(this);

    type = CardPack;
}

ADD_PACKAGE(New3v3Card)

New3v3_2013CardPackage::New3v3_2013CardPackage()
: Package("New3v3_2013Card")
{
    QList<Card *> cards;
    cards << new VSCrossbow(Card::Club)
        << new VSCrossbow(Card::Diamond);

    foreach(Card *card, cards)
        card->setParent(this);

    type = CardPack;
}

ADD_PACKAGE(New3v3_2013Card)
