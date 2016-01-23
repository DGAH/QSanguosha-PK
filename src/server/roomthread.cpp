#include "roomthread.h"
#include "room.h"
#include "engine.h"
#include "gamerule.h"
#include "scenario.h"
#include "ai.h"
#include "json.h"
#include "settings.h"
#include "standard.h"

#include <QTime>

#ifdef QSAN_UI_LIBRARY_AVAILABLE
#pragma message WARN("UI elements detected in server side!!!")
#endif

using namespace QSanProtocol;
LogMessage::LogMessage()
    : from(NULL)
{
}

QVariant LogMessage::toVariant() const
{
    QStringList tos;
    foreach(ServerPlayer *player, to)
        if (player != NULL) tos << player->objectName();

    QStringList log;
    log << type << (from ? from->objectName() : "") << tos.join("+") << card_str << arg << arg2;
    QVariant json_log = JsonUtils::toJsonArray(log);
    return json_log;
}

DamageStruct::DamageStruct()
    : from(NULL), to(NULL), card(NULL), damage(1), nature(Normal), chain(false),
    transfer(false), by_user(true), reason(QString()), transfer_reason(QString())
{
}

DamageStruct::DamageStruct(const Card *card, ServerPlayer *from, ServerPlayer *to, int damage, DamageStruct::Nature nature)
    : chain(false), transfer(false), by_user(true), reason(QString()), transfer_reason(QString()), prevented(false)
{
    this->card = card;
    this->from = from;
    this->to = to;
    this->damage = damage;
    this->nature = nature;
}

DamageStruct::DamageStruct(const QString &reason, ServerPlayer *from, ServerPlayer *to, int damage, DamageStruct::Nature nature)
    : card(NULL), chain(false), transfer(false), by_user(true), transfer_reason(QString()), prevented(false)
{
    this->from = from;
    this->to = to;
    this->damage = damage;
    this->nature = nature;
    this->reason = reason;
}

QString DamageStruct::getReason() const
{
    if (reason != QString())
        return reason;
    else if (card)
        return card->objectName();
    return QString();
}

CardEffectStruct::CardEffectStruct()
    : card(NULL), from(NULL), to(NULL), multiple(false), nullified(false)
{
}

SlashEffectStruct::SlashEffectStruct()
    : jink_num(1), slash(NULL), jink(NULL), from(NULL), to(NULL), drank(0), nature(DamageStruct::Normal), nullified(false)
{
}

DyingStruct::DyingStruct()
    : who(NULL), damage(NULL)
{
}

DeathStruct::DeathStruct()
    : who(NULL), damage(NULL)
{
}

RecoverStruct::RecoverStruct(ServerPlayer *who, const Card *card, int recover)
    : recover(recover), who(who), card(card)
{
}

PindianStruct::PindianStruct()
    : from(NULL), to(NULL), from_card(NULL), to_card(NULL), success(false)
{
}

bool PindianStruct::isSuccess() const
{
    return success;
}

JudgeStruct::JudgeStruct()
    : who(NULL), card(NULL), pattern("."), good(true), time_consuming(false),
    negative(false), play_animation(true), retrial_by_response(NULL),
    _m_result(TRIAL_RESULT_UNKNOWN)
{
}

bool JudgeStruct::isEffected() const
{
    return negative ? isBad() : isGood();
}

void JudgeStruct::updateResult()
{
    bool effected = (good == ExpPattern(pattern).match(who, card));
    if (effected)
        _m_result = TRIAL_RESULT_GOOD;
    else
        _m_result = TRIAL_RESULT_BAD;
}

bool JudgeStruct::isGood() const
{
    Q_ASSERT(_m_result != TRIAL_RESULT_UNKNOWN);
    return _m_result == TRIAL_RESULT_GOOD;
}

bool JudgeStruct::isBad() const
{
    return !isGood();
}

bool JudgeStruct::isGood(const Card *card) const
{
    Q_ASSERT(card);
    return (good == ExpPattern(pattern).match(who, card));
}

PhaseChangeStruct::PhaseChangeStruct()
    : from(Player::NotActive), to(Player::NotActive)
{
}

CardUseStruct::CardUseStruct()
    : card(NULL), from(NULL), m_isOwnerUse(true), m_addHistory(true), nullified_list(QStringList())
{
}

CardUseStruct::CardUseStruct(const Card *card, ServerPlayer *from, QList<ServerPlayer *> to, bool isOwnerUse)
{
    this->card = card;
    this->from = from;
    this->to = to;
    this->m_isOwnerUse = isOwnerUse;
    this->m_addHistory = true;
}

CardUseStruct::CardUseStruct(const Card *card, ServerPlayer *from, ServerPlayer *target, bool isOwnerUse)
{
    this->card = card;
    this->from = from;
    Q_ASSERT(target != NULL);
    this->to << target;
    this->m_isOwnerUse = isOwnerUse;
    this->m_addHistory = true;
}

bool CardUseStruct::isValid(const QString &pattern) const
{
    Q_UNUSED(pattern)
        return card != NULL;
    /*if (card == NULL) return false;
    if (!card->getSkillName().isEmpty()) {
    bool validSkill = false;
    QString skillName = card->getSkillName();
    QSet<const Skill *> skills = from->getVisibleSkills();
    for (int i = 0; i < 4; i++) {
    const EquipCard *equip = from->getEquip(i);
    if (equip == NULL) continue;
    const Skill *skill = Sanguosha->getSkill(equip);
    if (skill)
    skills.insert(skill);
    }
    foreach (const Skill *skill, skills) {
    if (skill->objectName() != skillName) continue;
    const ViewAsSkill *vsSkill = ViewAsSkill::parseViewAsSkill(skill);
    if (vsSkill) {
    if (!vsSkill->isAvailable(from, m_reason, pattern))
    return false;
    else {
    validSkill = true;
    break;
    }
    } else if (skill->getFrequency() == Skill::Wake) {
    bool valid = (from->getMark(skill->objectName()) > 0);
    if (!valid)
    return false;
    else
    validSkill = true;
    } else
    return false;
    }
    if (!validSkill) return false;
    }
    if (card->targetFixed())
    return true;
    else {
    QList<const Player *> targets;
    foreach (const ServerPlayer *player, to)
    targets.push_back(player);
    return card->targetsFeasible(targets, from);
    }*/
}

bool CardUseStruct::tryParse(const QVariant &usage, Room *room)
{
    JsonArray use = usage.value<JsonArray>();
    if (use.size() < 2 || !JsonUtils::isString(use[0]) || !use[1].canConvert<JsonArray>())
        return false;

    card = Card::Parse(use[0].toString());
    JsonArray targets = use[1].value<JsonArray>();

    foreach(const QVariant &target, targets)
    {
        if (!JsonUtils::isString(target)) return false;
        this->to << room->findChild<ServerPlayer *>(target.toString());
    }
    return true;
}

void CardUseStruct::parse(const QString &str, Room *room)
{
    QStringList words = str.split("->", QString::KeepEmptyParts);
    Q_ASSERT(words.length() == 1 || words.length() == 2);

    QString card_str = words.at(0);
    QString target_str = ".";

    if (words.length() == 2 && !words.at(1).isEmpty())
        target_str = words.at(1);

    card = Card::Parse(card_str);

    if (target_str != ".") {
        QStringList target_names = target_str.split("+");
        foreach(const QString &target_name, target_names)
            to << room->findChild<ServerPlayer *>(target_name);
    }
}

QString EventTriplet::toString() const
{
    return QString("event[%1], room[%2], target = %3[%4]\n")
        .arg(_m_event)
        .arg(_m_room->getId())
        .arg(_m_target ? _m_target->objectName() : "NULL")
        .arg(_m_target ? _m_target->getGeneralName() : QString());
}

RoomThread::RoomThread(Room *room)
    : room(room)
{
}

void RoomThread::addPlayerSkills(ServerPlayer *player, bool invoke_game_start)
{
    QVariant void_data;
    bool invoke_verify = false;

    foreach (const TriggerSkill *skill, player->getTriggerSkills()) {
        addTriggerSkill(skill);

        if (invoke_game_start && skill->getTriggerEvents().contains(GameStart))
            invoke_verify = true;
    }

    //We should make someone trigger a whole GameStart event instead of trigger a skill only.
    if (invoke_verify)
        trigger(GameStart, room, player, void_data);
}

void RoomThread::constructTriggerTable()
{
    foreach(ServerPlayer *player, room->getPlayers())
        addPlayerSkills(player, true);
}

ServerPlayer *RoomThread::find3v3Next(QList<ServerPlayer *> &first, QList<ServerPlayer *> &second)
{
    bool all_actioned = true;
    foreach (ServerPlayer *player, room->m_alivePlayers) {
        if (!player->hasFlag("actioned")) {
            all_actioned = false;
            break;
        }
    }

    if (all_actioned) {
        foreach (ServerPlayer *player, room->m_alivePlayers) {
            room->setPlayerFlag(player, "-actioned");
            trigger(ActionedReset, room, player);
        }

        qSwap(first, second);
        QList<ServerPlayer *> first_alive;
        foreach (ServerPlayer *p, first) {
            if (p->isAlive())
                first_alive << p;
        }
        return room->askForPlayerChosen(first.first(), first_alive, "3v3-action", "@3v3-action");
    }

    ServerPlayer *current = room->getCurrent();
    if (current != first.first()) {
        ServerPlayer *another = NULL;
        if (current == first.last())
            another = first.at(1);
        else
            another = first.last();
        if (!another->hasFlag("actioned") && another->isAlive())
            return another;
    }

    QList<ServerPlayer *> targets;
    do {
        targets.clear();
        qSwap(first, second);
        foreach (ServerPlayer *player, first) {
            if (!player->hasFlag("actioned") && player->isAlive())
                targets << player;
        }
    } while (targets.isEmpty());

    return room->askForPlayerChosen(first.first(), targets, "3v3-action", "@3v3-action");
}

void RoomThread::run3v3(QList<ServerPlayer *> &first, QList<ServerPlayer *> &second, GameRule *game_rule, ServerPlayer *current)
{
    try {
        forever{
            room->setCurrent(current);
            trigger(TurnStart, room, room->getCurrent());
            room->setPlayerFlag(current, "actioned");
            current = find3v3Next(first, second);
        }
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken)
            _handleTurnBroken3v3(first, second, game_rule);
        else
            throw triggerEvent;
    }
}

void RoomThread::_handleTurnBroken3v3(QList<ServerPlayer *> &first, QList<ServerPlayer *> &second, GameRule *game_rule)
{
    try {
        ServerPlayer *player = room->getCurrent();
        trigger(TurnBroken, room, player);
        if (player->getPhase() != Player::NotActive) {
            QVariant v;
            game_rule->trigger(EventPhaseEnd, room, player, v);
            player->changePhase(player->getPhase(), Player::NotActive);
        }
        if (!player->hasFlag("actioned"))
            room->setPlayerFlag(player, "actioned");

        ServerPlayer *next = find3v3Next(first, second);
        run3v3(first, second, game_rule, next);
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken) {
            _handleTurnBroken3v3(first, second, game_rule);
        } else {
            throw triggerEvent;
        }
    }
}

ServerPlayer *RoomThread::findHulaoPassNext(ServerPlayer *shenlvbu, QList<ServerPlayer *> league, int stage)
{
    ServerPlayer *current = room->getCurrent();
    if (stage == 1) {
        if (current == shenlvbu) {
            foreach (ServerPlayer *p, league) {
                if (p->isAlive() && !p->hasFlag("actioned"))
                    return p;
            }
            foreach (ServerPlayer *p, league) {
                if (p->isAlive())
                    return p;
            }
            Q_ASSERT(false);
            return league.first();
        } else {
            return shenlvbu;
        }
    } else {
        Q_ASSERT(stage == 2);
        return current->getNextAlive();
    }
}

void RoomThread::actionHulaoPass(ServerPlayer *shenlvbu, QList<ServerPlayer *> league, GameRule *game_rule, int stage)
{
    try {
        if (stage == 1) {
            forever{
                ServerPlayer *current = room->getCurrent();
                trigger(TurnStart, room, current);

                ServerPlayer *next = findHulaoPassNext(shenlvbu, league, 1);
                if (current != shenlvbu) {
                    if (current->isAlive() && !current->hasFlag("actioned"))
                        room->setPlayerFlag(current, "actioned");
                } else {
                    bool all_actioned = true;
                    foreach (ServerPlayer *player, league) {
                        if (player->isAlive() && !player->hasFlag("actioned")) {
                            all_actioned = false;
                            break;
                        }
                    }
                    if (all_actioned) {
                        foreach (ServerPlayer *player, league) {
                            if (player->hasFlag("actioned"))
                                room->setPlayerFlag(player, "-actioned");
                        }
                        foreach (ServerPlayer *player, league) {
                            if (player->isDead())
                                trigger(TurnStart, room, player);
                        }
                    }
                }

                room->setCurrent(next);
            }
        } else {
            Q_ASSERT(stage == 2);
            forever{
                ServerPlayer *current = room->getCurrent();
                trigger(TurnStart, room, current);

                ServerPlayer *next = findHulaoPassNext(shenlvbu, league, 2);

                if (current == shenlvbu) {
                    foreach (ServerPlayer *player, league) {
                        if (player->isDead())
                            trigger(TurnStart, room, player);
                    }
                }
                room->setCurrent(next);
            }
        }
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == StageChange) {
            stage = 2;
            trigger(triggerEvent, room, NULL);
            foreach (ServerPlayer *player, room->getPlayers()) {
                if (player != shenlvbu) {
                    if (player->hasFlag("actioned"))
                        room->setPlayerFlag(player, "-actioned");

                    if (player->getPhase() != Player::NotActive) {
                        QVariant v;
                        game_rule->trigger(EventPhaseEnd, room, player, v);
                        player->changePhase(player->getPhase(), Player::NotActive);
                    }
                }
            }

            room->setCurrent(shenlvbu);
            actionHulaoPass(shenlvbu, league, game_rule, 2);
        } else if (triggerEvent == TurnBroken) {
            _handleTurnBrokenHulaoPass(shenlvbu, league, game_rule, stage);
        } else {
            throw triggerEvent;
        }
    }
}

void RoomThread::_handleTurnBrokenHulaoPass(ServerPlayer *shenlvbu, QList<ServerPlayer *> league, GameRule *game_rule, int stage)
{
    try {
        ServerPlayer *player = room->getCurrent();
        trigger(TurnBroken, room, player);
        ServerPlayer *next = findHulaoPassNext(shenlvbu, league, stage);
        if (player->getPhase() != Player::NotActive) {
            QVariant v;
            game_rule->trigger(EventPhaseEnd, room, player, v);
            player->changePhase(player->getPhase(), Player::NotActive);
            if (player != shenlvbu && stage == 1)
                room->setPlayerFlag(player, "actioned");
        }

        room->setCurrent(next);
        actionHulaoPass(shenlvbu, league, game_rule, stage);
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken)
            _handleTurnBrokenHulaoPass(shenlvbu, league, game_rule, stage);
        else
            throw triggerEvent;
    }
}

void RoomThread::actionNormal(GameRule *game_rule)
{
    try {
        forever{
            trigger(TurnStart, room, room->getCurrent());
            if (room->isFinished()) break;
            room->setCurrent(room->getCurrent()->getNextAlive());
        }
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken)
            _handleTurnBrokenNormal(game_rule);
        else
            throw triggerEvent;
    }
}

void RoomThread::_handleTurnBrokenNormal(GameRule *game_rule)
{
    try {
        ServerPlayer *player = room->getCurrent();
        trigger(TurnBroken, room, player);
        ServerPlayer *next = player->getNextAlive();
        if (player->getPhase() != Player::NotActive) {
            QVariant data = QVariant();
            game_rule->trigger(EventPhaseEnd, room, player, data);
            player->changePhase(player->getPhase(), Player::NotActive);
        }

        room->setCurrent(next);
        actionNormal(game_rule);
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken)
            _handleTurnBrokenNormal(game_rule);
        else
            throw triggerEvent;
    }
}

void RoomThread::run()
{
    qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));
    Sanguosha->registerRoom(room);
    GameRule *game_rule;
    if (room->getMode() == "04_1v3")
        game_rule = new HulaoPassMode(this);
    else
        game_rule = new GameRule(this);

    addTriggerSkill(game_rule);
    foreach(const TriggerSkill *triggerSkill, Sanguosha->getGlobalTriggerSkills())
        addTriggerSkill(triggerSkill);
    if (Config.EnableBasara) addTriggerSkill(new BasaraMode(this));

    if (room->getScenario() != NULL) {
        const ScenarioRule *rule = room->getScenario()->getRule();
        if (rule) addTriggerSkill(rule);
    }

    // start game
    try {
        QString order;
        QList<ServerPlayer *> warm, cool;
        QList<ServerPlayer *> first, second;
        if (room->getMode() == "06_3v3") {
            foreach (ServerPlayer *player, room->m_players) {
                switch (player->getRoleEnum()) {
                case Player::Lord: warm.prepend(player); break;
                case Player::Loyalist: warm.append(player); break;
                case Player::Renegade: cool.prepend(player); break;
                case Player::Rebel: cool.append(player); break;
                }
            }
            order = room->askForOrder(cool.first(), "cool");
            if (order == "warm") {
                first = warm;
                second = cool;
            } else {
                first = cool;
                second = warm;
            }
        }
        constructTriggerTable();
        trigger(GameStart, (Room *)room, NULL);
        if (room->getMode() == "06_3v3") {
            run3v3(first, second, game_rule, first.first());
        } else if (room->getMode() == "04_1v3") {
            ServerPlayer *shenlvbu = room->getLord();
            QList<ServerPlayer *> league = room->getPlayers();
            league.removeOne(shenlvbu);

            room->setCurrent(league.first());
            actionHulaoPass(shenlvbu, league, game_rule, 1);
        } else {
            if (room->getMode() == "02_1v1") {
                ServerPlayer *first = room->getPlayers().first();
                if (first->getRole() != "renegade")
                    first = room->getPlayers().at(1);
                ServerPlayer *second = first->getNext();
                trigger(Debut, (Room *)room, first);
                trigger(Debut, (Room *)room, second);
                room->setCurrent(first);
            }

            actionNormal(game_rule);
        }
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == GameFinished) {
            Sanguosha->unregisterRoom();
            return;
        } else if (triggerEvent == TurnBroken || triggerEvent == StageChange) { // caused in Debut trigger
            ServerPlayer *first = room->getPlayers().first();
            if (first->getRole() != "renegade")
                first = room->getPlayers().at(1);
            room->setCurrent(first);
            actionNormal(game_rule);
        } else {
            Q_ASSERT(false);
        }
    }
}

static bool CompareByPriority(const TriggerSkill *a, const TriggerSkill *b)
{
    if (a->getDynamicPriority() == b->getDynamicPriority())
        return b->inherits("WeaponSkill") || b->inherits("ArmorSkill") || b->inherits("GameRule");
    return a->getDynamicPriority() > b->getDynamicPriority();
}

bool RoomThread::trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *target, QVariant &data)
{
    // push it to event stack
    EventTriplet triplet(triggerEvent, room, target);
    event_stack.push_back(triplet);

    bool broken = false;

    try {
        QList<const TriggerSkill *> triggered;
        QList<const TriggerSkill *> &skills = skill_table[triggerEvent];
        foreach (const TriggerSkill *skill, skills) {
            double priority = skill->getPriority(triggerEvent);
            int len = room->getPlayers().length();
            foreach (ServerPlayer *p, room->getAllPlayers(true)) {
                if (p->hasSkill(skill) || p->hasEquipSkill(skill->objectName())) {
                    priority += (double)len / 100;
                    break;
                }
                len--;
            }
            TriggerSkill *mutable_skill = const_cast<TriggerSkill *>(skill);
            mutable_skill->setDynamicPriority(priority);
        }
        qStableSort(skills.begin(), skills.end(), CompareByPriority);

        int current_priority = 1000;
        for (int i = 0; i < skills.size(); i++) {
            const TriggerSkill *skill = skills[i];
            if (!triggered.contains(skill) && !(current_priority == 0 && skill->getPriority(triggerEvent) > 0)) {
                triggered.append(skill);
                current_priority = skill->getPriority(triggerEvent);
                if (skill->triggerable(target, room)) {
                    room->tryPause();
                    broken = skill->trigger(triggerEvent, room, target, data);
                    if (broken) break;
                    i = 0;
                }
            }
        }

        if (target) {
            foreach(AI *ai, room->ais)
                ai->filterEvent(triggerEvent, target, data);
        }

        // pop event stack
        event_stack.pop_back();
    }
    catch (TriggerEvent throwed_event) {
        if (target) {
            foreach(AI *ai, room->ais)
                ai->filterEvent(triggerEvent, target, data);
        }

        // pop event stack
        event_stack.pop_back();

        throw throwed_event;
    }

    room->tryPause();
    return broken;
}

const QList<EventTriplet> *RoomThread::getEventStack() const
{
    return &event_stack;
}

bool RoomThread::trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *target)
{
    QVariant data;
    return trigger(triggerEvent, room, target, data);
}

void RoomThread::addTriggerSkill(const TriggerSkill *skill)
{
    if (skill == NULL || skillSet.contains(skill->objectName()))
        return;

    skillSet << skill->objectName();

    QList<TriggerEvent> events = skill->getTriggerEvents();
    foreach (TriggerEvent triggerEvent, events) {
        QList<const TriggerSkill *> &table = skill_table[triggerEvent];
        table << skill;
        foreach (const TriggerSkill *askill, table) {
            double priority = askill->getPriority(triggerEvent);
            int len = room->getPlayers().length();
            foreach (ServerPlayer *p, room->getAllPlayers(true)) {
                if (p->hasSkill(askill)) {
                    priority += (double)len / 100;
                    break;
                }
                len--;
            }
            TriggerSkill *mutable_skill = const_cast<TriggerSkill *>(askill);
            mutable_skill->setDynamicPriority(priority);
        }
        qStableSort(table.begin(), table.end(), CompareByPriority);
    }

    if (skill->isVisible()) {
        foreach (const Skill *skill, Sanguosha->getRelatedSkills(skill->objectName())) {
            const TriggerSkill *trigger_skill = qobject_cast<const TriggerSkill *>(skill);
            if (trigger_skill)
                addTriggerSkill(trigger_skill);
        }
    }
}

void RoomThread::delay(long secs)
{
    if (secs == -1) secs = Config.AIDelay;
    Q_ASSERT(secs >= 0);
    if (room->property("to_test").toString().isEmpty() && Config.AIDelay > 0)
        msleep(secs);
}

