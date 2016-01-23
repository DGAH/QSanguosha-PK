#ifndef SCENERULE_H
#define SCENERULE_H

#include "gamerule.h"


class SceneRule : public GameRule
{
public:
    SceneRule(QObject *parent);
    virtual int getPriority(TriggerEvent) const;
    virtual bool trigger(TriggerEvent event, Room* room, ServerPlayer *player, QVariant &data) const;
};

#endif // SCENERULE_H
