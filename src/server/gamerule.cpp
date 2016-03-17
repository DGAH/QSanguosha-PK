#include "gamerule.h"
#include "serverplayer.h"
#include "room.h"
#include "standard.h"
#include "maneuvering.h"
#include "engine.h"
#include "kofgame-engine.h"
#include "settings.h"
#include "json.h"

#include <QTime>

GameRule::GameRule(QObject *)
    : TriggerSkill("game_rule")
{
    //@todo: this setParent is illegitimate in QT and is equivalent to calling
    // setParent(NULL). So taking it off at the moment until we figure out
    // a way to do it.
    //setParent(parent);

    events << GameStart << TurnStart
        << EventPhaseProceeding << EventPhaseEnd << EventPhaseChanging
        << PreCardUsed << CardUsed << CardFinished << CardEffected
        << HpChanged
        << EventLoseSkill << EventAcquireSkill
        << AskForPeaches << AskForPeachesDone << BuryVictim << GameOverJudge
        << SlashHit << SlashEffected << SlashProceed
        << ConfirmDamage << DamageDone << DamageComplete
        << StartJudge << FinishRetrial << FinishJudge
        << ChoiceMade;
}

bool GameRule::triggerable(const ServerPlayer *) const
{
    return true;
}

int GameRule::getPriority(TriggerEvent) const
{
    return 0;
}

void GameRule::onPhaseProceed(ServerPlayer *player) const
{
    Room *room = player->getRoom();
    switch (player->getPhase()) {
    case Player::PhaseNone: {
        Q_ASSERT(false);
    }
    case Player::RoundStart:{
        break;
    }
    case Player::Start: {
        break;
    }
    case Player::Judge: {
        QList<const Card *> tricks = player->getJudgingArea();
        while (!tricks.isEmpty() && player->isAlive()) {
            const Card *trick = tricks.takeLast();
            bool on_effect = room->cardEffect(trick, NULL, player);
            if (!on_effect)
                trick->onNullified(player);
        }
        break;
    }
    case Player::Draw: {
        int num = 2;
        if (player->hasFlag("Global_FirstRound")) {
            room->setPlayerFlag(player, "-Global_FirstRound");
            if (room->getMode().contains("kof")) num--;
        }

        QVariant data = num;
        room->getThread()->trigger(DrawNCards, room, player, data);
        int n = data.toInt();
        if (n > 0)
            player->drawCards(n, "draw_phase");
        QVariant _n = n;
        room->getThread()->trigger(AfterDrawNCards, room, player, _n);
        break;
    }
    case Player::Play: {
        while (player->isAlive()) {
            CardUseStruct card_use;
            room->activate(player, card_use);
            if (card_use.card != NULL)
                room->useCard(card_use, true);
            else
                break;
        }
        break;
    }
    case Player::Discard: {
        int discard_num = player->getHandcardNum() - player->getMaxCards();
        if (discard_num > 0)
            room->askForDiscard(player, "gamerule", discard_num, discard_num);
        break;
    }
    case Player::Finish: {
        break;
    }
    case Player::NotActive:{
        break;
    }
    }
}

bool GameRule::trigger(TriggerEvent triggerEvent, Room *room, ServerPlayer *player, QVariant &data) const
{
    if (room->getTag("SkipGameRule").toBool()) {
        room->removeTag("SkipGameRule");
        return false;
    }

    // Handle global events
    if (player == NULL) {
        if (triggerEvent == GameStart) {
			bool striker_mode = (room->getMode() == "06_teams" && GameEX->useStrikerMode());
			int striker_count = GameEX->getStrikerCount();
            foreach (ServerPlayer *player, room->getPlayers()) {
                if (player->getGeneral()->getKingdom() == "god" && player->getGeneralName() != "anjiang")
                    room->setPlayerProperty(player, "kingdom", room->askForKingdom(player));
                foreach (const Skill *skill, player->getVisibleSkillList()) {
                    if (skill->getFrequency() == Skill::Limited && !skill->getLimitMark().isEmpty())
                        room->addPlayerMark(player, skill->getLimitMark());
                }
				if (striker_mode && striker_count > 0) {
					QString striker = player->tag["KOFGameStriker"].toString();
					if (!striker.isEmpty()) {
						QString striker_skill = GameEX->getStrikerSkill(striker);
						if (striker_skill == GameEX->getDefaultStrikerSkill())
							room->attachSkillToPlayer(player, striker_skill);
						else
							room->attachSkillToPlayer(player, "call_striker");
						room->addPlayerMark(player, "@striker", striker_count);
					}
				}
            }
            room->setTag("FirstRound", true);
			bool kof_mode = room->getMode().contains("kof") && room->getMode() != "03_kof";
            QList<int> n_list;
            foreach (ServerPlayer *p, room->getPlayers()) {
                int n = kof_mode ? p->getMaxHp() : 4;
                QVariant data = n;
                room->getThread()->trigger(DrawInitialCards, room, p, data);
                n_list << data.toInt();
            }
            room->drawCards(room->getPlayers(), n_list, QString());
            if (Config.EnableLuckCard)
                room->askForLuckCard();
            int i = 0;
            foreach (ServerPlayer *p, room->getPlayers()) {
                QVariant _nlistati = n_list.at(i);
                room->getThread()->trigger(AfterDrawInitialCards, room, p, _nlistati);
                i++;
            }
        }
        return false;
    }

    switch (triggerEvent) {
    case TurnStart: {
        player = room->getCurrent();
        if (room->getTag("FirstRound").toBool()) {
            room->setTag("FirstRound", false);
            room->setPlayerFlag(player, "Global_FirstRound");
        }

        LogMessage log;
        log.type = "$AppendSeparator";
        room->sendLog(log);
        room->addPlayerMark(player, "Global_TurnCount");
        if (!player->faceUp()) {
            room->setPlayerFlag(player, "-Global_FirstRound");
            player->turnOver();
        } else if (player->isAlive())
            player->play();

        break;
    }
    case EventPhaseProceeding: {
        onPhaseProceed(player);
        break;
    }
    case EventPhaseEnd: {
        if (player->getPhase() == Player::Play)
            room->addPlayerHistory(player, ".");
        break;
    }
    case EventPhaseChanging: {
        PhaseChangeStruct change = data.value<PhaseChangeStruct>();
        if (change.to == Player::NotActive) {
            foreach (ServerPlayer *p, room->getAllPlayers()) {
                if (p->getMark("drank") > 0) {
                    LogMessage log;
                    log.type = "#UnsetDrankEndOfTurn";
                    log.from = player;
                    log.to << p;
                    room->sendLog(log);

                    room->setPlayerMark(p, "drank", 0);
                }
            }
            room->setPlayerFlag(player, ".");
            room->clearPlayerCardLimitation(player, true);
        } else if (change.to == Player::Play) {
            room->addPlayerHistory(player, ".");
        }
        break;
    }
    case PreCardUsed: {
        if (data.canConvert<CardUseStruct>()) {
            CardUseStruct card_use = data.value<CardUseStruct>();
            if (card_use.from->hasFlag("Global_ForbidSurrender")) {
                card_use.from->setFlags("-Global_ForbidSurrender");
                room->doNotify(card_use.from, QSanProtocol::S_COMMAND_ENABLE_SURRENDER, QVariant(true));
            }

            card_use.from->broadcastSkillInvoke(card_use.card);
            if (!card_use.card->getSkillName().isNull() && card_use.card->getSkillName(true) == card_use.card->getSkillName(false)
                && card_use.m_isOwnerUse && card_use.from->hasSkill(card_use.card->getSkillName()))
                room->notifySkillInvoked(card_use.from, card_use.card->getSkillName());
        }
        break;
    }
    case CardUsed: {
        if (data.canConvert<CardUseStruct>()) {
            CardUseStruct card_use = data.value<CardUseStruct>();
            RoomThread *thread = room->getThread();

            if (card_use.card->hasPreAction())
                card_use.card->doPreAction(room, card_use);

            if (card_use.from && !card_use.to.isEmpty()) {
                thread->trigger(TargetSpecifying, room, card_use.from, data);
                CardUseStruct card_use = data.value<CardUseStruct>();
                QList<ServerPlayer *> targets = card_use.to;
                foreach (ServerPlayer *to, card_use.to) {
                    if (targets.contains(to)) {
                        thread->trigger(TargetConfirming, room, to, data);
                        CardUseStruct new_use = data.value<CardUseStruct>();
                        targets = new_use.to;
                    }
                }
            }
            card_use = data.value<CardUseStruct>();

            try {
                QVariantList jink_list_backup;
                if (card_use.card->isKindOf("Slash")) {
                    jink_list_backup = card_use.from->tag["Jink_" + card_use.card->toString()].toList();
                    QVariantList jink_list;
                    for (int i = 0; i < card_use.to.length(); i++)
                        jink_list.append(QVariant(1));
                    card_use.from->tag["Jink_" + card_use.card->toString()] = QVariant::fromValue(jink_list);
                }
                if (card_use.from && !card_use.to.isEmpty()) {
                    thread->trigger(TargetSpecified, room, card_use.from, data);
                    foreach(ServerPlayer *p, room->getAllPlayers())
                        thread->trigger(TargetConfirmed, room, p, data);
                }
                card_use = data.value<CardUseStruct>();
                room->setTag("CardUseNullifiedList", QVariant::fromValue(card_use.nullified_list));
                card_use.card->use(room, card_use.from, card_use.to);
                if (!jink_list_backup.isEmpty())
                    card_use.from->tag["Jink_" + card_use.card->toString()] = QVariant::fromValue(jink_list_backup);
            }
            catch (TriggerEvent triggerEvent) {
                if (triggerEvent == TurnBroken)
                    card_use.from->tag.remove("Jink_" + card_use.card->toString());
                throw triggerEvent;
            }
        }

        break;
    }
    case CardFinished: {
        CardUseStruct use = data.value<CardUseStruct>();
        room->clearCardFlag(use.card);

        if (use.card->isKindOf("AOE") || use.card->isKindOf("GlobalEffect")) {
            foreach(ServerPlayer *p, room->getAlivePlayers())
                room->doNotify(p, QSanProtocol::S_COMMAND_NULLIFICATION_ASKED, QVariant("."));
        }
        if (use.card->isKindOf("Slash"))
            use.from->tag.remove("Jink_" + use.card->toString());

        break;
    }
    case EventAcquireSkill:
    case EventLoseSkill: {
        QString skill_name = data.toString();
        const Skill *skill = Sanguosha->getSkill(skill_name);
        bool refilter = skill->inherits("FilterSkill");

        if (refilter)
            room->filterCards(player, player->getCards("he"), triggerEvent == EventLoseSkill);

        break;
    }
    case HpChanged: {
        if (player->getHp() > 0)
            break;
        if (data.isNull() || data.canConvert<RecoverStruct>())
            break;
        if (data.canConvert<DamageStruct>()) {
            DamageStruct damage = data.value<DamageStruct>();
            room->enterDying(player, &damage);
        } else {
            room->enterDying(player, NULL);
        }

        break;
    }
    case AskForPeaches: {
        DyingStruct dying = data.value<DyingStruct>();
        const Card *peach = NULL;

        while (dying.who->getHp() <= 0) {
            peach = NULL;

            if (dying.who->isAlive())
                peach = room->askForSinglePeach(player, dying.who);

            if (peach == NULL)
                break;
            room->useCard(CardUseStruct(peach, player, dying.who));
        }
        break;
    }
    case AskForPeachesDone: {
        if (player->getHp() <= 0 && player->isAlive()) {
            DyingStruct dying = data.value<DyingStruct>();
            room->killPlayer(player, dying.damage);
        }

        break;
    }
    case ConfirmDamage: {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.card && damage.to->getMark("SlashIsDrank") > 0) {
            LogMessage log;
            log.type = "#AnalepticBuff";
            log.from = damage.from;
            log.to << damage.to;
            log.arg = QString::number(damage.damage);

            damage.damage += damage.to->getMark("SlashIsDrank");
            damage.to->setMark("SlashIsDrank", 0);

            log.arg2 = QString::number(damage.damage);

            room->sendLog(log);

            data = QVariant::fromValue(damage);
        }

        break;
    }
    case DamageDone: {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.from && !damage.from->isAlive())
            damage.from = NULL;
        data = QVariant::fromValue(damage);

        LogMessage log;

        if (damage.from) {
            log.type = "#Damage";
            log.from = damage.from;
        } else {
            log.type = "#DamageNoSource";
        }

        log.to << damage.to;
        log.arg = QString::number(damage.damage);

        switch (damage.nature) {
        case DamageStruct::Normal: log.arg2 = "normal_nature"; break;
        case DamageStruct::Fire: log.arg2 = "fire_nature"; break;
        case DamageStruct::Thunder: log.arg2 = "thunder_nature"; break;
        }

        room->sendLog(log);

        int new_hp = damage.to->getHp() - damage.damage;

        QString change_str = QString("%1:%2").arg(damage.to->objectName()).arg(-damage.damage);
        switch (damage.nature) {
        case DamageStruct::Fire: change_str.append("F"); break;
        case DamageStruct::Thunder: change_str.append("T"); break;
        default: break;
        }

        JsonArray arg;
        arg << damage.to->objectName() << -damage.damage << damage.nature;
        room->doBroadcastNotify(QSanProtocol::S_COMMAND_CHANGE_HP, arg);

        room->setTag("HpChangedData", data);
        room->setPlayerProperty(damage.to, "hp", new_hp);

        if (damage.nature != DamageStruct::Normal && player->isChained() && !damage.chain) {
            int n = room->getTag("is_chained").toInt();
            n++;
            room->setTag("is_chained", n);
        }

        break;
    }
    case DamageComplete: {
        DamageStruct damage = data.value<DamageStruct>();
        if (damage.prevented)
            break;
        if (damage.nature != DamageStruct::Normal && player->isChained())
            room->setPlayerProperty(player, "chained", false);
        if (room->getTag("is_chained").toInt() > 0) {
            if (damage.nature != DamageStruct::Normal && !damage.chain) {
                // iron chain effect
                int n = room->getTag("is_chained").toInt();
                n--;
                room->setTag("is_chained", n);
                QList<ServerPlayer *> chained_players;
                if (room->getCurrent()->isDead())
                    chained_players = room->getOtherPlayers(room->getCurrent());
                else
                    chained_players = room->getAllPlayers();
                foreach (ServerPlayer *chained_player, chained_players) {
                    if (chained_player->isChained()) {
                        room->getThread()->delay();
                        LogMessage log;
                        log.type = "#IronChainDamage";
                        log.from = chained_player;
                        room->sendLog(log);

                        DamageStruct chain_damage = damage;
                        chain_damage.to = chained_player;
                        chain_damage.chain = true;

                        room->damage(chain_damage);
                    }
                }
            }
        }
        if (room->getMode().contains("kof")) {
            foreach (ServerPlayer *p, room->getAllPlayers()) {
                if (p->hasFlag("Global_DebutFlag")) {
                    p->setFlags("-Global_DebutFlag");
                    room->getThread()->trigger(Debut, room, p);
                }
            }
        }
        break;
    }
    case CardEffected: {
        if (data.canConvert<CardEffectStruct>()) {
            CardEffectStruct effect = data.value<CardEffectStruct>();
            if (!effect.card->isKindOf("Slash") && effect.nullified) {
                LogMessage log;
                log.type = "#CardNullified";
                log.from = effect.to;
                log.arg = effect.card->objectName();
                room->sendLog(log);

                return true;
            } else if (effect.card->getTypeId() == Card::TypeTrick) {
                if (room->isCanceled(effect)) {
                    effect.to->setFlags("Global_NonSkillNullify");
                    return true;
                } else {
                    room->getThread()->trigger(TrickEffect, room, effect.to, data);
                }
            }
            if (effect.to->isAlive() || effect.card->isKindOf("Slash"))
                effect.card->onEffect(effect);
        }

        break;
    }
    case SlashEffected: {
        SlashEffectStruct effect = data.value<SlashEffectStruct>();
        if (effect.nullified) {
            LogMessage log;
            log.type = "#CardNullified";
            log.from = effect.to;
            log.arg = effect.slash->objectName();
            room->sendLog(log);

            return true;
        }
        if (effect.jink_num > 0)
            room->getThread()->trigger(SlashProceed, room, effect.from, data);
        else
            room->slashResult(effect, NULL);
        break;
    }
    case SlashProceed: {
        SlashEffectStruct effect = data.value<SlashEffectStruct>();
        QString slasher = effect.from->objectName();
        if (!effect.to->isAlive())
            break;
        if (effect.jink_num == 1) {
            const Card *jink = room->askForCard(effect.to, "jink", "slash-jink:" + slasher, data, Card::MethodUse, effect.from);
            room->slashResult(effect, room->isJinkEffected(effect.to, jink) ? jink : NULL);
        } else {
            DummyCard *jink = new DummyCard;
            const Card *asked_jink = NULL;
            for (int i = effect.jink_num; i > 0; i--) {
                QString prompt = QString("@multi-jink%1:%2::%3").arg(i == effect.jink_num ? "-start" : QString())
                    .arg(slasher).arg(i);
                asked_jink = room->askForCard(effect.to, "jink", prompt, data, Card::MethodUse, effect.from);
                if (!room->isJinkEffected(effect.to, asked_jink)) {
                    delete jink;
                    room->slashResult(effect, NULL);
                    return false;
                } else {
                    jink->addSubcard(asked_jink->getEffectiveId());
                }
            }
            room->slashResult(effect, jink);
        }

        break;
    }
    case SlashHit: {
        SlashEffectStruct effect = data.value<SlashEffectStruct>();

        if (effect.drank > 0) effect.to->setMark("SlashIsDrank", effect.drank);
        room->damage(DamageStruct(effect.slash, effect.from, effect.to, 1, effect.nature));

        break;
    }
    case GameOverJudge: {
        if (room->getMode().contains("kof")) {
            QStringList list = player->tag["1v1Arrange"].toStringList();
			if (room->getMode() == "04_kof_2013") {
				if (list.length() > 3)
					break;
			}
			else{
				if (list.length() > 0)
					break;
			}
		}
		else if (room->getMode() == "06_teams") {
			QStringList list = player->tag["1v1Arrange"].toStringList();
			if (list.length() > 0)
				break;
		}
		else if (room->getMode() == "08_endless") {
			if (player->getTask() == "boss") {
				break;
			}
		}

        QString winner = getWinner(player);
        if (!winner.isNull()) {
            room->gameOver(winner);
            return true;
        }

        break;
    }
    case BuryVictim: {
        DeathStruct death = data.value<DeathStruct>();
		QString game_mode = room->getMode();
		
		int striker_count = 0;
		if (game_mode == "06_teams")
			striker_count = player->getMark("@striker");

        player->bury();

        if (room->getTag("SkipNormalDeathProcess").toBool())
            return false;

        ServerPlayer *killer = death.damage ? death.damage->from : NULL;
        if (killer)
            rewardAndPunish(killer, player);

        if (game_mode.contains("kof")) {
            QStringList list = player->tag["1v1Arrange"].toStringList();
			if (game_mode == "04_kof_2013") {
				if (list.length() <= 3)
					break;
			}
			else{
				if (list.length() <= 0)
					break;
			}
            if (game_mode == "03_kof") {
                player->tag["1v1ChangeGeneral"] = list.takeFirst();
                player->tag["1v1Arrange"] = list;
            } else {
                player->tag["1v1ChangeGeneral"] = list.first();
            }

            changeGeneral1v1(player);
            if (death.damage == NULL)
                room->getThread()->trigger(Debut, room, player);
            else
                player->setFlags("Global_DebutFlag");
            return false;
		}
		else if (game_mode == "06_teams") {
			QStringList list = player->tag["1v1Arrange"].toStringList();
			if (list.length() <= 0)
				break;
			player->tag["1v1ChangeGeneral"] = list.takeFirst();
			player->tag["1v1Arrange"] = list;
			changeGeneral1v1(player);
			room->setPlayerMark(player, "@striker", striker_count);
			if (death.damage == NULL)
				room->getThread()->trigger(Debut, room, player);
			else
				player->setFlags("Global_DebutFlag");
			return false;
		}
		else if (game_mode == "08_endless") {
			if (player->getTask() == "boss") {
				changeGeneralEndless(player);
				if (death.damage == NULL)
					room->getThread()->trigger(Debut, room, player);
				else
					player->setFlags("Global_DebutFlag");
				return false;
			}
		}

        break;
    }
    case StartJudge: {
        int card_id = room->drawCard();

        JudgeStruct *judge = data.value<JudgeStruct *>();
        judge->card = Sanguosha->getCard(card_id);

        LogMessage log;
        log.type = "$InitialJudge";
        log.from = player;
        log.card_str = QString::number(judge->card->getEffectiveId());
        room->sendLog(log);

        room->moveCardTo(judge->card, NULL, judge->who, Player::PlaceJudge,
            CardMoveReason(CardMoveReason::S_REASON_JUDGE,
            judge->who->objectName(),
            QString(), QString(), judge->reason), true);
        judge->updateResult();
        break;
    }
    case FinishRetrial: {
        JudgeStruct *judge = data.value<JudgeStruct *>();

        LogMessage log;
        log.type = "$JudgeResult";
        log.from = player;
        log.card_str = QString::number(judge->card->getEffectiveId());
        room->sendLog(log);

        int delay = Config.AIDelay;
        if (judge->time_consuming) delay /= 1.25;
        room->getThread()->delay(delay);
        if (judge->play_animation) {
            room->sendJudgeResult(judge);
            room->getThread()->delay(Config.S_JUDGE_LONG_DELAY);
        }

        break;
    }
    case FinishJudge: {
        JudgeStruct *judge = data.value<JudgeStruct *>();

        if (room->getCardPlace(judge->card->getEffectiveId()) == Player::PlaceJudge) {
            CardMoveReason reason(CardMoveReason::S_REASON_JUDGEDONE, judge->who->objectName(),
                judge->reason, QString());
            if (judge->retrial_by_response)
                reason.m_extraData = QVariant::fromValue(judge->retrial_by_response);
            room->moveCardTo(judge->card, judge->who, NULL, Player::DiscardPile, reason, true);
        }

        break;
    }
    case ChoiceMade: {
        foreach (ServerPlayer *p, room->getAlivePlayers()) {
            foreach (QString flag, p->getFlagList()) {
                if (flag.startsWith("Global_") && flag.endsWith("Failed"))
                    room->setPlayerFlag(p, "-" + flag);
            }
        }
        break;
    }
    default:
        break;
    }

    return false;
}

void GameRule::changeGeneral1v1(ServerPlayer *player) const
{
    Config.AIDelay = Config.OriginAIDelay;

    Room *room = player->getRoom();
	const QString mode = Config.value("GameMode", "04_kof_2013").toString();
    bool classical = (mode == "03_kof" || mode == "06_teams");
    QString new_general;
    if (classical) {
        new_general = player->tag["1v1ChangeGeneral"].toString();
        player->tag.remove("1v1ChangeGeneral");
    } else {
        QStringList list = player->tag["1v1Arrange"].toStringList();
        if (player->getAI())
            new_general = list.first();
        else
            new_general = room->askForGeneral(player, list);
        list.removeOne(new_general);
        player->tag["1v1Arrange"] = QVariant::fromValue(list);
    }

    if (player->getPhase() != Player::NotActive)
        player->changePhase(player->getPhase(), Player::NotActive);

    room->revivePlayer(player);
    room->changeHero(player, new_general, true, true);

	if (player->getKingdom() != player->getGeneral()->getKingdom())
		room->setPlayerProperty(player, "kingdom", player->getGeneral()->getKingdom());

    if (player->getGeneral()->getKingdom() == "god")
        room->setPlayerProperty(player, "kingdom", room->askForKingdom(player));

    room->addPlayerHistory(player, ".");

    QList<ServerPlayer *> notified = classical ? room->getOtherPlayers(player, true) : room->getPlayers();
    room->doBroadcastNotify(notified, QSanProtocol::S_COMMAND_REVEAL_GENERAL, JsonArray() << player->objectName() << new_general);

    if (!player->faceUp())
        player->turnOver();

    if (player->isChained())
        room->setPlayerProperty(player, "chained", false);

    room->setTag("FirstRound", true); //For Manjuan
    int draw_num = classical ? 4 : player->getMaxHp();
    QVariant data = draw_num;
    room->getThread()->trigger(DrawInitialCards, room, player, data);
    draw_num = data.toInt();
    try {
        player->drawCards(draw_num);
        room->setTag("FirstRound", false);
    }
    catch (TriggerEvent triggerEvent) {
        if (triggerEvent == TurnBroken)
            room->setTag("FirstRound", false);
        throw triggerEvent;
    }
    QVariant _drawnum = draw_num;
    room->getThread()->trigger(AfterDrawInitialCards, room, player, _drawnum);
}

void GameRule::rewardAndPunish(ServerPlayer *killer, ServerPlayer *victim) const
{
    if (killer->isDead())
        return;

        if (victim->getRole() == "rebel" && killer != victim)
            killer->drawCards(3, "kill");
        else if (victim->getRole() == "loyalist" && killer->getRole() == "lord")
            killer->throwAllHandCardsAndEquips();
}

QString GameRule::getWinner(ServerPlayer *victim) const
{
    Room *room = victim->getRoom();
    QString winner;
    
        QStringList alive_roles = room->aliveRoles(victim);
        switch (victim->getRoleEnum()) {
        case Player::Lord: {
            if (alive_roles.length() == 1 && alive_roles.first() == "renegade")
                winner = room->getAlivePlayers().first()->objectName();
            else
                winner = "rebel";
            break;
        }
        case Player::Rebel:
        case Player::Renegade: {
            if (!alive_roles.contains("rebel") && !alive_roles.contains("renegade"))
                winner = "lord+loyalist";
            break;
        }
        default:
            break;
        }

    return winner;
}

// 08_endless

void GameRule::changeGeneralEndless(ServerPlayer *player) const
{
	Config.AIDelay = Config.OriginAIDelay;
	Room *room = player->getRoom();
	QStringList candidates = Sanguosha->getLimitedGeneralNames();
	qShuffle(candidates);
	QString new_general = candidates.first();

	if (player->getPhase() != Player::NotActive)
		player->changePhase(player->getPhase(), Player::NotActive);

	room->revivePlayer(player);
	room->changeHero(player, new_general, true, true);

	if (player->getKingdom() != player->getGeneral()->getKingdom())
		room->setPlayerProperty(player, "kingdom", player->getGeneral()->getKingdom());

	if (player->getGeneral()->getKingdom() == "god")
		room->setPlayerProperty(player, "kingdom", room->askForKingdom(player));

	room->addPlayerHistory(player, ".");

	if (!player->faceUp())
		player->turnOver();

	if (player->isChained())
		room->setPlayerProperty(player, "chained", false);

	room->setTag("FirstRound", true); //For Manjuan
	QVariant data = 4;
	room->getThread()->trigger(DrawInitialCards, room, player, data);
	int draw_num = data.toInt();
	try {
		player->drawCards(draw_num);
		room->setTag("FirstRound", false);
	}
	catch (TriggerEvent triggerEvent) {
		if (triggerEvent == TurnBroken)
			room->setTag("FirstRound", false);
		throw triggerEvent;
	}
	room->getThread()->trigger(AfterDrawInitialCards, room, player, QVariant(draw_num));
}