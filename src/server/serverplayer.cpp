#include "serverplayer.h"
#include "skill.h"
#include "engine.h"
#include "standard.h"
#include "ai.h"
#include "settings.h"
#include "recorder.h"
#include "banpair.h"
#include "lua-wrapper.h"
#include "json.h"
#include "gamerule.h"

using namespace QSanProtocol;

const int ServerPlayer::S_NUM_SEMAPHORES = 6;

ServerPlayer::ServerPlayer(Room *room)
    : Player(room), m_isClientResponseReady(false), m_isWaitingReply(false),
    socket(NULL), room(room),
    ai(NULL), trust_ai(new TrustAI(this)), recorder(NULL),
    _m_phases_index(0), next(NULL)
{
    semas = new QSemaphore *[S_NUM_SEMAPHORES];
    for (int i = 0; i < S_NUM_SEMAPHORES; i++)
        semas[i] = new QSemaphore(0);
}

ServerPlayer::~ServerPlayer()
{
    for (int i = 0; i < S_NUM_SEMAPHORES; i++)
        delete semas[i];
    delete[] semas;
    delete trust_ai;
}

void ServerPlayer::drawCard(const Card *card)
{
    handcards << card;
}

Room *ServerPlayer::getRoom() const
{
    return room;
}

void ServerPlayer::broadcastSkillInvoke(const QString &card_name) const
{
    room->broadcastSkillInvoke(card_name, isMale(), -1);
}

void ServerPlayer::broadcastSkillInvoke(const Card *card) const
{
    if (card->isMute())
        return;

    QString skill_name = card->getSkillName();
    const Skill *skill = Sanguosha->getSkill(skill_name);
    if (skill == NULL) {
        if (card->getCommonEffectName().isNull())
            broadcastSkillInvoke(card->objectName());
        else
            room->broadcastSkillInvoke(card->getCommonEffectName(), "common");
        return;
    } else {
        int index = skill->getEffectIndex(this, card);
        if (index == 0) return;

        if ((index == -1 && skill->getSources().isEmpty()) || index == -2) {
            if (card->getCommonEffectName().isNull())
                broadcastSkillInvoke(card->objectName());
            else
                room->broadcastSkillInvoke(card->getCommonEffectName(), "common");
        } else
            room->broadcastSkillInvoke(skill_name, index);
    }
}

int ServerPlayer::getRandomHandCardId() const
{
    return getRandomHandCard()->getEffectiveId();
}

const Card *ServerPlayer::getRandomHandCard() const
{
    int index = qrand() % handcards.length();
    return handcards.at(index);
}

void ServerPlayer::obtainCard(const Card *card, bool unhide)
{
    CardMoveReason reason(CardMoveReason::S_REASON_GOTCARD, objectName());
    room->obtainCard(this, card, reason, unhide);
}

void ServerPlayer::throwAllEquips()
{
    QList<const Card *> equips = getEquips();

    if (equips.isEmpty()) return;

    DummyCard *card = new DummyCard;
    foreach (const Card *equip, equips) {
        if (!isJilei(card))
            card->addSubcard(equip);
    }
    if (card->subcardsLength() > 0)
        room->throwCard(card, this);
    delete card;
}

void ServerPlayer::throwAllHandCards()
{
    int card_length = getHandcardNum();
    room->askForDiscard(this, QString(), card_length, card_length);
}

void ServerPlayer::throwAllHandCardsAndEquips()
{
    int card_length = getCardCount();
    room->askForDiscard(this, QString(), card_length, card_length, false, true);
}

void ServerPlayer::throwAllMarks(bool visible_only)
{
    // throw all marks
    foreach (QString mark_name, marks.keys()) {
        if (mark_name == "@bossExp" || (visible_only && !mark_name.startsWith("@")))
            continue;

        int n = marks.value(mark_name, 0);
        if (n != 0)
            room->setPlayerMark(this, mark_name, 0);
    }
}

void ServerPlayer::clearOnePrivatePile(QString pile_name)
{
    if (!piles.contains(pile_name))
        return;
    QList<int> &pile = piles[pile_name];

    DummyCard *dummy = new DummyCard(pile);
    CardMoveReason reason(CardMoveReason::S_REASON_REMOVE_FROM_PILE, this->objectName());
    room->throwCard(dummy, reason, NULL);
    delete dummy;
    piles.remove(pile_name);
}

void ServerPlayer::clearPrivatePiles()
{
    foreach(QString pile_name, piles.keys())
        clearOnePrivatePile(pile_name);
    piles.clear();
}

void ServerPlayer::bury()
{
    clearFlags();
    clearHistory();
    throwAllCards();
    throwAllMarks();
    clearPrivatePiles();

    room->clearPlayerCardLimitation(this, false);
}

void ServerPlayer::throwAllCards()
{
    DummyCard *card = isKongcheng() ? new DummyCard : wholeHandCards();
    foreach(const Card *equip, getEquips())
        card->addSubcard(equip);
    if (card->subcardsLength() != 0)
        room->throwCard(card, this);
    delete card;

    QList<const Card *> tricks = getJudgingArea();
    foreach (const Card *trick, tricks) {
        CardMoveReason reason(CardMoveReason::S_REASON_THROW, this->objectName());
        room->throwCard(trick, reason, NULL);
    }
}

void ServerPlayer::drawCards(int n, const QString &reason)
{
    room->drawCards(this, n, reason);
}

bool ServerPlayer::askForSkillInvoke(const QString &skill_name, const QVariant &data)
{
    return room->askForSkillInvoke(this, skill_name, data);
}

bool ServerPlayer::askForSkillInvoke(const Skill *skill, const QVariant &data /* = QVariant() */)
{
    Q_ASSERT(skill != NULL);
    return askForSkillInvoke(skill->objectName(), data);
}

QList<int> ServerPlayer::forceToDiscard(int discard_num, bool include_equip, bool is_discard, const QString &pattern)
{
    QList<int> to_discard;

    QString flags = "h";
    if (include_equip)
        flags.append("e");

    QList<const Card *> all_cards = getCards(flags);
    qShuffle(all_cards);
    ExpPattern exp_pattern(pattern);

    for (int i = 0; i < all_cards.length(); i++) {
        if (!exp_pattern.match(this, all_cards.at(i)))
            continue;
        if (!is_discard || !isJilei(all_cards.at(i)))
            to_discard << all_cards.at(i)->getId();
        if (to_discard.length() == discard_num)
            break;
    }

    return to_discard;
}

int ServerPlayer::aliveCount() const
{
    return room->alivePlayerCount();
}

int ServerPlayer::getHandcardNum() const
{
    return handcards.length();
}

void ServerPlayer::setSocket(ClientSocket *socket)
{
    if (socket) {
        connect(socket, SIGNAL(disconnected()), this, SIGNAL(disconnected()));
        connect(socket, SIGNAL(message_got(const char *)), this, SLOT(getMessage(const char *)));
        connect(this, SIGNAL(message_ready(QString)), this, SLOT(sendMessage(QString)));
    } else {
        if (this->socket) {
            this->disconnect(this->socket);
            this->socket->disconnect(this);
            this->socket->disconnectFromHost();
            this->socket->deleteLater();
        }

        disconnect(this, SLOT(sendMessage(QString)));
    }

    this->socket = socket;
}

void ServerPlayer::kick()
{
    room->notifyProperty(this, this, "flags", "is_kicked");
    if (socket != NULL)
        socket->disconnectFromHost();
    setSocket(NULL);
}

void ServerPlayer::getMessage(const char *message)
{
    QString request = message;
    if (request.endsWith("\n"))
        request.chop(1);

    emit request_got(request);
}

void ServerPlayer::unicast(const QString &message)
{
    emit message_ready(message);

    if (recorder)
        recorder->recordLine(message);
}

void ServerPlayer::startNetworkDelayTest()
{
    test_time = QDateTime::currentDateTime();
    Packet packet(S_SRC_ROOM | S_TYPE_NOTIFICATION | S_DEST_CLIENT, S_COMMAND_NETWORK_DELAY_TEST);
    invoke(&packet);
}

qint64 ServerPlayer::endNetworkDelayTest()
{
    return test_time.msecsTo(QDateTime::currentDateTime());
}

void ServerPlayer::startRecord()
{
    recorder = new Recorder(this);
}

void ServerPlayer::saveRecord(const QString &filename)
{
    if (recorder)
        recorder->save(filename);
}

void ServerPlayer::addToSelected(const QString &general)
{
    selected.append(general);
}

QStringList ServerPlayer::getSelected() const
{
    return selected;
}

QString ServerPlayer::findReasonable(const QStringList &generals, bool no_unreasonable)
{
    foreach (QString name, generals) {
        if (Config.Enable2ndGeneral) {
            if (getGeneral()) {
                if (!BanPair::isBanned(getGeneralName()) && BanPair::isBanned(getGeneralName(), name)) continue;
            } else {
                if (BanPair::isBanned(name)) continue;
            }

            if (Config.EnableHegemony && getGeneral()
                && getGeneral()->getKingdom() != Sanguosha->getGeneral(name)->getKingdom())
                continue;
        }
        if (Config.EnableBasara) {
            QStringList ban_list = Config.value("Banlist/Basara").toStringList();
            if (ban_list.contains(name)) continue;
        }
        if (Config.GameMode == "zombie_mode") {
            QStringList ban_list = Config.value("Banlist/Zombie").toStringList();
            if (ban_list.contains(name))continue;
        }
        if (Config.GameMode.endsWith("p")
            || Config.GameMode.endsWith("pd")
            || Config.GameMode.endsWith("pz")
            || Config.GameMode.contains("_mini_")
            || Config.GameMode == "custom_scenario") {
            QStringList ban_list = Config.value("Banlist/Roles").toStringList();
            if (ban_list.contains(name)) continue;
        }

        return name;
    }

    if (no_unreasonable)
        return QString();

    return generals.first();
}

void ServerPlayer::clearSelected()
{
    selected.clear();
}

void ServerPlayer::sendMessage(const QString &message)
{
    if (socket) {
#ifndef QT_NO_DEBUG
        printf("%s", qPrintable(objectName()));
#endif
        socket->send(message);
    }
}

void ServerPlayer::invoke(const AbstractPacket *packet)
{
    unicast(packet->toString());
}

QString ServerPlayer::reportHeader() const
{
    QString name = objectName();
    return QString("%1 ").arg(name.isEmpty() ? tr("Anonymous") : name);
}

void ServerPlayer::removeCard(const Card *card, Place place)
{
    switch (place) {
    case PlaceHand: {
        handcards.removeOne(card);
        break;
    }
    case PlaceEquip: {
        const EquipCard *equip = qobject_cast<const EquipCard *>(card->getRealCard());
        if (equip == NULL)
            equip = qobject_cast<const EquipCard *>(Sanguosha->getEngineCard(card->getEffectiveId()));
        Q_ASSERT(equip != NULL);
        equip->onUninstall(this);

        WrappedCard *wrapped = Sanguosha->getWrappedCard(card->getEffectiveId());
        removeEquip(wrapped);

        bool show_log = true;
        foreach(QString flag, flags)
            if (flag.endsWith("_InTempMoving")) {
                show_log = false;
                break;
            }
        if (show_log) {
            LogMessage log;
            log.type = "$Uninstall";
            log.card_str = wrapped->toString();
            log.from = this;
            room->sendLog(log);
        }
        break;
    }
    case PlaceDelayedTrick: {
        removeDelayedTrick(card);
        break;
    }
    case PlaceSpecial: {
        int card_id = card->getEffectiveId();
        QString pile_name = getPileName(card_id);

        //@todo: sanity check required
        if (!pile_name.isEmpty())
            piles[pile_name].removeOne(card_id);

        break;
    }
    default:
        break;
    }
}

void ServerPlayer::addCard(const Card *card, Place place)
{
    switch (place) {
    case PlaceHand: {
        handcards << card;
        break;
    }
    case PlaceEquip: {
        WrappedCard *wrapped = Sanguosha->getWrappedCard(card->getEffectiveId());
        const EquipCard *equip = qobject_cast<const EquipCard *>(wrapped->getRealCard());
        setEquip(wrapped);
        equip->onInstall(this);
        break;
    }
    case PlaceDelayedTrick: {
        addDelayedTrick(card);
        break;
    }
    default:
        break;
    }
}

bool ServerPlayer::isLastHandCard(const Card *card, bool contain) const
{
    if (!card->isVirtualCard()) {
        return handcards.length() == 1 && handcards.first()->getEffectiveId() == card->getEffectiveId();
    } else if (card->getSubcards().length() > 0) {
        if (!contain) {
            foreach (int card_id, card->getSubcards()) {
                if (!handcards.contains(Sanguosha->getCard(card_id)))
                    return false;
            }
            return handcards.length() == card->getSubcards().length();
        } else {
            foreach (const Card *ncard, handcards) {
                if (!card->getSubcards().contains(ncard->getEffectiveId()))
                    return false;
            }
            return true;
        }
    }
    return false;
}

QList<int> ServerPlayer::handCards() const
{
    QList<int> cardIds;
    foreach(const Card *card, handcards)
        cardIds << card->getId();
    return cardIds;
}

QList<const Card *> ServerPlayer::getHandcards() const
{
    return handcards;
}

QList<const Card *> ServerPlayer::getCards(const QString &flags) const
{
    QList<const Card *> cards;
    if (flags.contains("h"))
        cards << handcards;
    if (flags.contains("e"))
        cards << getEquips();
    if (flags.contains("j"))
        cards << getJudgingArea();

    return cards;
}

DummyCard *ServerPlayer::wholeHandCards() const
{
    if (isKongcheng()) return NULL;

    DummyCard *dummy_card = new DummyCard;
    foreach(const Card *card, handcards)
        dummy_card->addSubcard(card->getId());

    return dummy_card;
}

bool ServerPlayer::hasNullification() const
{
    foreach (const Card *card, handcards) {
        if (card->objectName() == "nullification")
            return true;
    }
    foreach (int id, getHandPile()) {
        if (Sanguosha->getCard(id)->objectName() == "nullification")
            return true;
    }

    foreach (const Skill *skill, getVisibleSkillList(true)) {
        if (!hasSkill(skill)) continue;
        if (skill->inherits("ViewAsSkill")) {
            const ViewAsSkill *vsskill = qobject_cast<const ViewAsSkill *>(skill);
            if (vsskill->isEnabledAtNullification(this)) return true;
        } else if (skill->inherits("TriggerSkill")) {
            const TriggerSkill *trigger_skill = qobject_cast<const TriggerSkill *>(skill);
            if (trigger_skill && trigger_skill->getViewAsSkill()) {
                const ViewAsSkill *vsskill = qobject_cast<const ViewAsSkill *>(trigger_skill->getViewAsSkill());
                if (vsskill && vsskill->isEnabledAtNullification(this)) return true;
            }
        }
    }

    return false;
}

bool ServerPlayer::pindian(ServerPlayer *target, const QString &reason, const Card *card1)
{
    LogMessage log;
    log.type = "#Pindian";
    log.from = this;
    log.to << target;
    room->sendLog(log);

    const Card *card2;
    if (card1 == NULL) {
        QList<const Card *> cards = room->askForPindianRace(this, target, reason);
        card1 = cards.first();
        card2 = cards.last();
    } else {
        if (card1->isVirtualCard()) {
            int card_id = card1->getEffectiveId();
            card1 = Sanguosha->getCard(card_id);
        }
        card2 = room->askForPindian(target, this, target, reason);
    }

    if (card1 == NULL || card2 == NULL) return false;

    PindianStruct pindian_struct;
    pindian_struct.from = this;
    pindian_struct.to = target;
    pindian_struct.from_card = card1;
    pindian_struct.to_card = card2;
    pindian_struct.from_number = card1->getNumber();
    pindian_struct.to_number = card2->getNumber();
    pindian_struct.reason = reason;

    QList<CardsMoveStruct> moves;
    CardsMoveStruct move_table_1;
    move_table_1.card_ids << pindian_struct.from_card->getEffectiveId();
    move_table_1.from = pindian_struct.from;
    move_table_1.to = NULL;
    move_table_1.to_place = Player::PlaceTable;
    move_table_1.reason = CardMoveReason(CardMoveReason::S_REASON_PINDIAN, pindian_struct.from->objectName(),
        pindian_struct.to->objectName(), pindian_struct.reason, QString());

    CardsMoveStruct move_table_2;
    move_table_2.card_ids << pindian_struct.to_card->getEffectiveId();
    move_table_2.from = pindian_struct.to;
    move_table_2.to = NULL;
    move_table_2.to_place = Player::PlaceTable;
    move_table_2.reason = CardMoveReason(CardMoveReason::S_REASON_PINDIAN, pindian_struct.to->objectName());

    moves.append(move_table_1);
    moves.append(move_table_2);
    room->moveCardsAtomic(moves, true);

    LogMessage log2;
    log2.type = "$PindianResult";
    log2.from = pindian_struct.from;
    log2.card_str = QString::number(pindian_struct.from_card->getEffectiveId());
    room->sendLog(log2);

    log2.type = "$PindianResult";
    log2.from = pindian_struct.to;
    log2.card_str = QString::number(pindian_struct.to_card->getEffectiveId());
    room->sendLog(log2);

    RoomThread *thread = room->getThread();
    PindianStruct *pindian_star = &pindian_struct;
    QVariant data = QVariant::fromValue(pindian_star);
    thread->trigger(PindianVerifying, room, this, data);

    PindianStruct *new_star = data.value<PindianStruct *>();
    pindian_struct.from_number = new_star->from_number;
    pindian_struct.to_number = new_star->to_number;
    pindian_struct.success = (new_star->from_number > new_star->to_number);

    log.type = pindian_struct.success ? "#PindianSuccess" : "#PindianFailure";
    log.from = this;
    log.to.clear();
    log.to << target;
    log.card_str.clear();
    room->sendLog(log);

    JsonArray arg;
    arg << S_GAME_EVENT_REVEAL_PINDIAN << objectName() << pindian_struct.from_card->getEffectiveId() << target->objectName() << pindian_struct.to_card->getEffectiveId() << pindian_struct.success << reason;
    room->doBroadcastNotify(S_COMMAND_LOG_EVENT, arg);

    pindian_star = &pindian_struct;
    data = QVariant::fromValue(pindian_star);
    thread->trigger(Pindian, room, this, data);

    moves.clear();
    if (room->getCardPlace(pindian_struct.from_card->getEffectiveId()) == Player::PlaceTable) {
        CardsMoveStruct move_discard_1;
        move_discard_1.card_ids << pindian_struct.from_card->getEffectiveId();
        move_discard_1.from = pindian_struct.from;
        move_discard_1.to = NULL;
        move_discard_1.to_place = Player::DiscardPile;
        move_discard_1.reason = CardMoveReason(CardMoveReason::S_REASON_PINDIAN, pindian_struct.from->objectName(),
            pindian_struct.to->objectName(), pindian_struct.reason, QString());
        moves.append(move_discard_1);
    }

    if (room->getCardPlace(pindian_struct.to_card->getEffectiveId()) == Player::PlaceTable) {
        CardsMoveStruct move_discard_2;
        move_discard_2.card_ids << pindian_struct.to_card->getEffectiveId();
        move_discard_2.from = pindian_struct.to;
        move_discard_2.to = NULL;
        move_discard_2.to_place = Player::DiscardPile;
        move_discard_2.reason = CardMoveReason(CardMoveReason::S_REASON_PINDIAN, pindian_struct.to->objectName());
        moves.append(move_discard_2);
    }
    if (!moves.isEmpty())
        room->moveCardsAtomic(moves, true);

    QVariant decisionData = QVariant::fromValue(QString("pindian:%1:%2:%3:%4:%5")
        .arg(reason)
        .arg(this->objectName())
        .arg(pindian_struct.from_card->getEffectiveId())
        .arg(target->objectName())
        .arg(pindian_struct.to_card->getEffectiveId()));
    thread->trigger(ChoiceMade, room, this, decisionData);

    return pindian_struct.success;
}

void ServerPlayer::turnOver()
{
    setFaceUp(!faceUp());
    room->broadcastProperty(this, "faceup");

    LogMessage log;
    log.type = "#TurnOver";
    log.from = this;
    log.arg = faceUp() ? "face_up" : "face_down";
    room->sendLog(log);

    room->getThread()->trigger(TurnedOver, room, this);
}

bool ServerPlayer::changePhase(Player::Phase from, Player::Phase to)
{
    RoomThread *thread = room->getThread();
    setPhase(PhaseNone);

    PhaseChangeStruct phase_change;
    phase_change.from = from;
    phase_change.to = to;
    QVariant data = QVariant::fromValue(phase_change);

    bool skip = thread->trigger(EventPhaseChanging, room, this, data);
    if (skip && to != NotActive) {
        setPhase(from);
        return true;
    }

    setPhase(to);
    room->broadcastProperty(this, "phase");

    if (!phases.isEmpty())
        phases.removeFirst();

    if (!thread->trigger(EventPhaseStart, room, this)) {
        if (getPhase() != NotActive)
            thread->trigger(EventPhaseProceeding, room, this);
    }
    if (getPhase() != NotActive)
        thread->trigger(EventPhaseEnd, room, this);

    return false;
}

void ServerPlayer::play(QList<Player::Phase> set_phases)
{
    if (!set_phases.isEmpty()) {
        if (!set_phases.contains(NotActive))
            set_phases << NotActive;
    } else
        set_phases << RoundStart << Start << Judge << Draw << Play
        << Discard << Finish << NotActive;

    phases = set_phases;
    _m_phases_state.clear();
    for (int i = 0; i < phases.size(); i++) {
        PhaseStruct _phase;
        _phase.phase = phases[i];
        _m_phases_state << _phase;
    }

    for (int i = 0; i < _m_phases_state.size(); i++) {
        if (isDead()) {
            changePhase(getPhase(), NotActive);
            break;
        }

        _m_phases_index = i;
        PhaseChangeStruct phase_change;
        phase_change.from = getPhase();
        phase_change.to = phases[i];

        RoomThread *thread = room->getThread();
        setPhase(PhaseNone);
        QVariant data = QVariant::fromValue(phase_change);

        bool skip = thread->trigger(EventPhaseChanging, room, this, data);
        phase_change = data.value<PhaseChangeStruct>();
        _m_phases_state[i].phase = phases[i] = phase_change.to;

        setPhase(phases[i]);
        room->broadcastProperty(this, "phase");

        if (phases[i] != NotActive && (skip || _m_phases_state[i].skipped != 0)) {
            QVariant isCost = QVariant::fromValue(_m_phases_state[i].skipped < 0);
            bool cancel_skip = thread->trigger(EventPhaseSkipping, room, this, isCost);
            if (!cancel_skip)
                continue;
        }

        if (!thread->trigger(EventPhaseStart, room, this)) {
            if (getPhase() != NotActive)
                thread->trigger(EventPhaseProceeding, room, this);
        }
        if (getPhase() != NotActive)
            thread->trigger(EventPhaseEnd, room, this);
        else
            break;
    }
}

QList<Player::Phase> &ServerPlayer::getPhases()
{
    return phases;
}

void ServerPlayer::skip(Player::Phase phase, bool isCost)
{
    for (int i = _m_phases_index; i < _m_phases_state.size(); i++) {
        if (_m_phases_state[i].phase == phase) {
            if (_m_phases_state[i].skipped != 0) {
                if (isCost && _m_phases_state[i].skipped == 1)
                    _m_phases_state[i].skipped = -1;
                return;
            }
            _m_phases_state[i].skipped = (isCost ? -1 : 1);
            break;
        }
    }

    static QStringList phase_strings;
    if (phase_strings.isEmpty())
        phase_strings << "round_start" << "start" << "judge" << "draw"
        << "play" << "discard" << "finish" << "not_active";
    int index = static_cast<int>(phase);

    LogMessage log;
    log.type = "#SkipPhase";
    log.from = this;
    log.arg = phase_strings.at(index);
    room->sendLog(log);
}

void ServerPlayer::insertPhase(Player::Phase phase)
{
    PhaseStruct _phase;
    _phase.phase = phase;
    phases.insert(_m_phases_index, phase);
    _m_phases_state.insert(_m_phases_index, _phase);
}

bool ServerPlayer::isSkipped(Player::Phase phase)
{
    for (int i = _m_phases_index; i < _m_phases_state.size(); i++) {
        if (_m_phases_state[i].phase == phase)
            return (_m_phases_state[i].skipped != 0);
    }
    return false;
}

void ServerPlayer::gainMark(const QString &mark, int n)
{
    int value = getMark(mark) + n;

    LogMessage log;
    log.type = "#GetMark";
    log.from = this;
    log.arg = mark;
    log.arg2 = QString::number(n);

    room->sendLog(log);
    room->setPlayerMark(this, mark, value);
}

void ServerPlayer::loseMark(const QString &mark, int n)
{
    if (getMark(mark) == 0) return;
    int value = getMark(mark) - n;
    if (value < 0) {
        value = 0; n = getMark(mark);
    }

    LogMessage log;
    log.type = "#LoseMark";
    log.from = this;
    log.arg = mark;
    log.arg2 = QString::number(n);

    room->sendLog(log);
    room->setPlayerMark(this, mark, value);
}

void ServerPlayer::loseAllMarks(const QString &mark_name)
{
    loseMark(mark_name, getMark(mark_name));
}

void ServerPlayer::addSkill(const QString &skill_name)
{
    Player::addSkill(skill_name);
    JsonArray args;
    args << (int)QSanProtocol::S_GAME_EVENT_ADD_SKILL;
    args << objectName();
    args << skill_name;
    room->doBroadcastNotify(QSanProtocol::S_COMMAND_LOG_EVENT, args);
}

void ServerPlayer::loseSkill(const QString &skill_name)
{
    Player::loseSkill(skill_name);
    JsonArray args;
    args << (int)QSanProtocol::S_GAME_EVENT_LOSE_SKILL;
    args << objectName();
    args << skill_name;
    room->doBroadcastNotify(QSanProtocol::S_COMMAND_LOG_EVENT, args);
}

void ServerPlayer::setGender(General::Gender gender)
{
    if (gender == getGender())
        return;
    Player::setGender(gender);
    JsonArray args;
    args << (int)QSanProtocol::S_GAME_EVENT_CHANGE_GENDER;
    args << objectName();
    args << (int)gender;
    room->doBroadcastNotify(QSanProtocol::S_COMMAND_LOG_EVENT, args);
}

bool ServerPlayer::isOnline() const
{
    return getState() == "online";
}

void ServerPlayer::setAI(AI *ai)
{
    this->ai = ai;
}

AI *ServerPlayer::getAI() const
{
    if (getState() == "online")
        return NULL;
    else if (getState() == "trust" && !Config.EnableCheat)
        return trust_ai;
    else
        return ai;
}

AI *ServerPlayer::getSmartAI() const
{
    return ai;
}

void ServerPlayer::addVictim(ServerPlayer *victim)
{
    victims.append(victim);
}

QList<ServerPlayer *> ServerPlayer::getVictims() const
{
    return victims;
}

void ServerPlayer::setNext(ServerPlayer *next)
{
    this->next = next;
}

ServerPlayer *ServerPlayer::getNext() const
{
    return next;
}

ServerPlayer *ServerPlayer::getNextAlive(int n) const
{
    bool hasAlive = (room->getAlivePlayers().length() > 0);
    ServerPlayer *next = const_cast<ServerPlayer *>(this);
    if (!hasAlive) return next;
    for (int i = 0; i < n; i++) {
        do next = next->next; while (next->isDead());
    }
    return next;
}

int ServerPlayer::getGeneralMaxHp() const
{
    int max_hp = 0;

    if (getGeneral2() == NULL)
        max_hp = getGeneral()->getMaxHp();
    else {
        int first = getGeneral()->getMaxHp();
        int second = getGeneral2()->getMaxHp();

        int plan = Config.MaxHpScheme;
        if (Config.GameMode.contains("_mini_") || Config.GameMode == "custom_scenario") plan = 1;

        switch (plan) {
        case 3: max_hp = (first + second) / 2; break;
        case 2: max_hp = qMax(first, second); break;
        case 1: max_hp = qMin(first, second); break;
        default:
            max_hp = first + second - Config.Scheme0Subtraction; break;
        }

        max_hp = qMax(max_hp, 1);
    }

    if (room->hasWelfare(this))
        max_hp++;

    return max_hp;
}

QString ServerPlayer::getGameMode() const
{
    return room->getMode();
}

QString ServerPlayer::getIp() const
{
    if (socket)
        return socket->peerAddress();
    else
        return QString();
}

void ServerPlayer::introduceTo(ServerPlayer *player)
{
    QString screen_name = screenName().toUtf8().toBase64();
    QString avatar = property("avatar").toString();

    JsonArray introduce_str;
    introduce_str << objectName() << screen_name << avatar;

    if (player)
        room->doNotify(player, S_COMMAND_ADD_PLAYER, introduce_str);
    else {
        QList<ServerPlayer *> players = room->getPlayers();
        players.removeOne(this);
        room->doBroadcastNotify(players, S_COMMAND_ADD_PLAYER, introduce_str);
    }
}

void ServerPlayer::marshal(ServerPlayer *player) const
{
    room->notifyProperty(player, this, "maxhp");
    room->notifyProperty(player, this, "hp");
    room->notifyProperty(player, this, "gender");

    if (getKingdom() != getGeneral()->getKingdom())
        room->notifyProperty(player, this, "kingdom");

    if (isAlive()) {
        room->notifyProperty(player, this, "seat");
        if (getPhase() != Player::NotActive)
            room->notifyProperty(player, this, "phase");
    } else {
        room->notifyProperty(player, this, "alive");
        room->notifyProperty(player, this, "role");
        room->doNotify(player, S_COMMAND_KILL_PLAYER, objectName());
    }

    if (!faceUp())
        room->notifyProperty(player, this, "faceup");

    if (isChained())
        room->notifyProperty(player, this, "chained");

    QList<ServerPlayer*> players;
    players << player;

    QList<CardsMoveStruct> moves;

    if (!isKongcheng()) {
        CardsMoveStruct move;
        foreach (const Card *card, handcards) {
            move.card_ids << card->getId();
            if (player == this) {
                WrappedCard *wrapped = qobject_cast<WrappedCard *>(room->getCard(card->getId()));
                if (wrapped->isModified())
                    room->notifyUpdateCard(player, card->getId(), wrapped);
            }
        }
        move.from_place = DrawPile;
        move.to_player_name = objectName();
        move.to_place = PlaceHand;

        if (player == this)
            move.to = player;

        moves << move;
    }

    if (hasEquip()) {
        CardsMoveStruct move;
        foreach (const Card *card, getEquips()) {
            move.card_ids << card->getId();
            WrappedCard *wrapped = qobject_cast<WrappedCard *>(room->getCard(card->getId()));
            if (wrapped->isModified())
                room->notifyUpdateCard(player, card->getId(), wrapped);
        }
        move.from_place = DrawPile;
        move.to_player_name = objectName();
        move.to_place = PlaceEquip;

        moves << move;
    }

    if (!getJudgingAreaID().isEmpty()) {
        CardsMoveStruct move;
        foreach(int card_id, getJudgingAreaID())
            move.card_ids << card_id;
        move.from_place = DrawPile;
        move.to_player_name = objectName();
        move.to_place = PlaceDelayedTrick;

        moves << move;
    }

    if (!moves.isEmpty()) {
        room->notifyMoveCards(true, moves, false, players);
        room->notifyMoveCards(false, moves, false, players);
    }

    if (!getPileNames().isEmpty()) {
        CardsMoveStruct move;
        move.from_place = DrawPile;
        move.to_player_name = objectName();
        move.to_place = PlaceSpecial;
        foreach (QString pile, piles.keys()) {
            move.card_ids.clear();
            move.card_ids.append(piles[pile]);
            move.to_pile_name = pile;

            QList<CardsMoveStruct> moves2;
            moves2 << move;

            bool open = pileOpen(pile, player->objectName());

            room->notifyMoveCards(true, moves2, open, players);
            room->notifyMoveCards(false, moves2, open, players);
        }
    }

    foreach (QString mark_name, marks.keys()) {
        if (mark_name.startsWith("@")) {
            int value = getMark(mark_name);
            if (value > 0) {
                JsonArray arg;
                arg << objectName() << mark_name << value;
                room->doNotify(player, S_COMMAND_SET_MARK, arg);
            }
        }
    }

    foreach (const Skill *skill, getVisibleSkillList(true)) {
        QString skill_name = skill->objectName();
        JsonArray args1;
        args1 << S_GAME_EVENT_ACQUIRE_SKILL << objectName() << skill_name;
        room->doNotify(player, S_COMMAND_LOG_EVENT, args1);
    }

    foreach(QString flag, flags)
        room->notifyProperty(player, this, "flags", flag);

    foreach (QString item, history.keys()) {
        int value = history.value(item);
        if (value > 0) {
            JsonArray arg;
            arg << item << value;
            room->doNotify(player, S_COMMAND_ADD_HISTORY, arg);
        }
    }

    if (hasShownRole())
        room->notifyProperty(player, this, "role");
}

void ServerPlayer::addToPile(const QString &pile_name, const Card *card, bool open, QList<ServerPlayer *> open_players)
{
    QList<int> card_ids;
    if (card->isVirtualCard())
        card_ids = card->getSubcards();
    else
        card_ids << card->getEffectiveId();
    return addToPile(pile_name, card_ids, open, open_players);
}

void ServerPlayer::addToPile(const QString &pile_name, int card_id, bool open, QList<ServerPlayer *> open_players)
{
    QList<int> card_ids;
    card_ids << card_id;
    return addToPile(pile_name, card_ids, open, open_players);
}

void ServerPlayer::addToPile(const QString &pile_name, QList<int> card_ids, bool open, QList<ServerPlayer *> open_players)
{
    return addToPile(pile_name, card_ids, open, open_players, CardMoveReason());
}

void ServerPlayer::addToPile(const QString &pile_name, QList<int> card_ids,
    bool open, QList<ServerPlayer *> open_players, CardMoveReason reason)
{
    if (!open) {
        if (open_players.isEmpty()) {
            foreach (int id, card_ids) {
                ServerPlayer *owner = room->getCardOwner(id);
                if (owner && !open_players.contains(owner))
                    open_players << owner;
            }
        }
    } else {
        open_players = room->getAllPlayers();
    }
    foreach(ServerPlayer *p, open_players)
        setPileOpen(pile_name, p->objectName());
    piles[pile_name].append(card_ids);

    CardsMoveStruct move;
    move.card_ids = card_ids;
    move.to = this;
    move.to_place = Player::PlaceSpecial;
    move.reason = reason;
    room->moveCardsAtomic(move, open);
}

void ServerPlayer::exchangeFreelyFromPrivatePile(const QString &skill_name, const QString &pile_name, int upperlimit, bool include_equip)
{
    QList<int> pile = getPile(pile_name);
    if (pile.isEmpty()) return;

    QString tempMovingFlag = QString("%1_InTempMoving").arg(skill_name);
    room->setPlayerFlag(this, tempMovingFlag);

    int ai_delay = Config.AIDelay;
    Config.AIDelay = 0;

    QList<int> will_to_pile, will_to_handcard;
    while (!pile.isEmpty()) {
        room->fillAG(pile, this);
        int card_id = room->askForAG(this, pile, true, skill_name);
        room->clearAG(this);
        if (card_id == -1) break;

        pile.removeOne(card_id);
        will_to_handcard << card_id;
        if (pile.length() >= upperlimit) break;

        CardMoveReason reason(CardMoveReason::S_REASON_EXCHANGE_FROM_PILE, this->objectName());
        room->obtainCard(this, Sanguosha->getCard(card_id), reason, false);
    }

    Config.AIDelay = ai_delay;

    int n = will_to_handcard.length();
    if (n == 0) return;
    const Card *exchange_card = room->askForExchange(this, skill_name, n, n, include_equip);
    will_to_pile = exchange_card->getSubcards();
    delete exchange_card;

    QList<int> will_to_handcard_x = will_to_handcard, will_to_pile_x = will_to_pile;
    QList<int> duplicate;
    foreach (int id, will_to_pile) {
        if (will_to_handcard_x.contains(id)) {
            duplicate << id;
            will_to_pile_x.removeOne(id);
            will_to_handcard_x.removeOne(id);
            n--;
        }
    }

    if (n == 0) {
        addToPile(pile_name, will_to_pile, false);
        room->setPlayerFlag(this, "-" + tempMovingFlag);
        return;
    }

    LogMessage log;
    log.type = "#QixingExchange";
    log.from = this;
    log.arg = QString::number(n);
    log.arg2 = skill_name;
    room->sendLog(log);

    addToPile(pile_name, duplicate, false);
    room->setPlayerFlag(this, "-" + tempMovingFlag);
    addToPile(pile_name, will_to_pile_x, false);

    room->setPlayerFlag(this, tempMovingFlag);
    addToPile(pile_name, will_to_handcard_x, false);
    room->setPlayerFlag(this, "-" + tempMovingFlag);

    DummyCard *dummy = new DummyCard(will_to_handcard_x);
    CardMoveReason reason(CardMoveReason::S_REASON_EXCHANGE_FROM_PILE, this->objectName());
    room->obtainCard(this, dummy, reason, false);
    delete dummy;
}

void ServerPlayer::gainAnExtraTurn()
{
    ServerPlayer *current = room->getCurrent();
    try {
        room->setCurrent(this);
        room->getThread()->trigger(TurnStart, room, this);
        room->setCurrent(current);
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken) {
            if (getPhase() != Player::NotActive) {
                const GameRule *game_rule = NULL;
                if (room->getMode() == "04_1v3")
                    game_rule = qobject_cast<const GameRule *>(Sanguosha->getTriggerSkill("hulaopass_mode"));
                else
                    game_rule = qobject_cast<const GameRule *>(Sanguosha->getTriggerSkill("game_rule"));
                if (game_rule) {
                    QVariant v;
                    game_rule->trigger(EventPhaseEnd, room, this, v);
                }
                changePhase(getPhase(), Player::NotActive);
            }
            room->setCurrent(current);
        }
        throw triggerEvent;
    }
}

void ServerPlayer::copyFrom(ServerPlayer *sp)
{
    ServerPlayer *b = this;
    ServerPlayer *a = sp;

    b->handcards = QList<const Card *>(a->handcards);
    b->phases = QList<ServerPlayer::Phase>(a->phases);
    b->selected = QStringList(a->selected);

    Player *c = b;
    c->copyFrom(a);
}

bool ServerPlayer::CompareByActionOrder(ServerPlayer *a, ServerPlayer *b)
{
    Room *room = a->getRoom();
    return room->getFront(a, b) == a;
}

