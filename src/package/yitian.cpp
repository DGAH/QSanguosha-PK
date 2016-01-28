#include "yitian.h"
#include "engine.h"

class YitianSwordSkill : public WeaponSkill
{
public:
    YitianSwordSkill() :WeaponSkill("yitian_sword")
    {
        events << DamageComplete << CardsMoveOneTime;
    }

    virtual bool triggerable(const ServerPlayer *target) const
    {
        return target != NULL && target->isAlive();
    }

    virtual bool trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
    {
        if (triggerEvent == DamageComplete) {
            if (WeaponSkill::triggerable(player) && player->getPhase() == Player::NotActive) {
                room->askForUseCard(player, "slash", "@YitianSword-slash");
            }
        } else {
            if (player->hasFlag("YitianSwordDamage")) {
                CardsMoveOneTimeStruct move = data.value<CardsMoveOneTimeStruct>();
                if (move.from != player || !move.from_places.contains(Player::PlaceEquip))
                    return false;
                for (int i = 0; i < move.card_ids.size(); i++) {
                    if (move.from_places[i] != Player::PlaceEquip) continue;
                    const Card *card = Sanguosha->getEngineCard(move.card_ids[i]);
                    if (card->objectName() == objectName()) {
                        player->setFlags("-YitianSwordDamage");
                        ServerPlayer *target = room->askForPlayerChosen(player, room->getAlivePlayers(), "yitian_sword", "@YitianSword-lost", true, true);
                        if (target != NULL)
                            room->damage(DamageStruct("yitian_sword", player, target));
                        return false;
                    }
                }
            }
        }
        return false;
    }
};

YitianSword::YitianSword(Suit suit, int number)
    :Weapon(suit, number, 2)
{
    setObjectName("yitian_sword");
}

void YitianSword::onUninstall(ServerPlayer *player) const
{
    if (player->isAlive() && player->getMark("Equips_Nullified_to_Yourself") == 0 && player->hasWeapon(objectName()))
        player->setFlags("YitianSwordDamage");
}

YitianCardPackage::YitianCardPackage()
    :Package("yitian_cards")
{
    (new YitianSword)->setParent(this);

    type = CardPack;

    skills << new YitianSwordSkill;
}

ADD_PACKAGE(YitianCard)