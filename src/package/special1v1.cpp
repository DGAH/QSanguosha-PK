#include "special1v1.h"
#include "standard-equips.h"
#include "engine.h"
#include "maneuvering.h"

Drowning::Drowning(Suit suit, int number)
    : SingleTargetTrick(suit, number)
{
    setObjectName("drowning");
}

bool Drowning::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
    int total_num = 1 + Sanguosha->correctCardTarget(TargetModSkill::ExtraTarget, Self, this);
    return targets.length() < total_num && to_select != Self;
}

void Drowning::onEffect(const CardEffectStruct &effect) const
{
    Room *room = effect.to->getRoom();
    if (!effect.to->getEquips().isEmpty()
        && room->askForChoice(effect.to, objectName(), "throw+damage", QVariant::fromValue(effect)) == "throw")
        effect.to->throwAllEquips();
    else
        room->damage(DamageStruct(this, effect.from->isAlive() ? effect.from : NULL, effect.to));
}

New1v1CardPackage::New1v1CardPackage()
: Package("New1v1Card")
{
    QList<Card *> cards;
    cards << new Duel(Card::Spade, 1)
        << new EightDiagram(Card::Spade, 2)
        << new Dismantlement(Card::Spade, 3)
        << new Snatch(Card::Spade, 4)
        << new Slash(Card::Spade, 5)
        << new QinggangSword(Card::Spade, 6)
        << new Slash(Card::Spade, 7)
        << new Slash(Card::Spade, 8)
        << new IceSword(Card::Spade, 9)
        << new Slash(Card::Spade, 10)
        << new Snatch(Card::Spade, 11)
        << new Spear(Card::Spade, 12)
        << new SavageAssault(Card::Spade, 13);

    cards << new ArcheryAttack(Card::Heart, 1)
        << new Jink(Card::Heart, 2)
        << new Peach(Card::Heart, 3)
        << new Peach(Card::Heart, 4)
        << new Jink(Card::Heart, 5)
        << new Indulgence(Card::Heart, 6)
        << new ExNihilo(Card::Heart, 7)
        << new ExNihilo(Card::Heart, 8)
        << new Peach(Card::Heart, 9)
        << new Slash(Card::Heart, 10)
        << new Slash(Card::Heart, 11)
        << new Dismantlement(Card::Heart, 12)
        << new Nullification(Card::Heart, 13);

    cards << new Duel(Card::Club, 1)
        << new RenwangShield(Card::Club, 2)
        << new Dismantlement(Card::Club, 3)
        << new Slash(Card::Club, 4)
        << new Slash(Card::Club, 5)
        << new Slash(Card::Club, 6)
        << new Drowning(Card::Club, 7)
        << new Slash(Card::Club, 8)
        << new Slash(Card::Club, 9)
        << new Slash(Card::Club, 10)
        << new Slash(Card::Club, 11)
        << new SupplyShortage(Card::Club, 12)
        << new Nullification(Card::Club, 13);

    cards << new Crossbow(Card::Diamond, 1)
        << new Jink(Card::Diamond, 2)
        << new Jink(Card::Diamond, 3)
        << new Snatch(Card::Diamond, 4)
        << new Axe(Card::Diamond, 5)
        << new Slash(Card::Diamond, 6)
        << new Jink(Card::Diamond, 7)
        << new Jink(Card::Diamond, 8)
        << new Slash(Card::Diamond, 9)
        << new Jink(Card::Diamond, 10)
        << new Jink(Card::Diamond, 11)
        << new Peach(Card::Diamond, 12)
        << new Slash(Card::Diamond, 13);

    foreach(Card *card, cards)
        card->setParent(this);

    type = CardPack;
}

ADD_PACKAGE(New1v1Card)
