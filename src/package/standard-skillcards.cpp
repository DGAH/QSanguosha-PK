#include "standard-skillcards.h"
#include "room.h"
#include "clientplayer.h"
#include "engine.h"
#include "kofgame-engine.h"
#include "settings.h"

ZhihengCard::ZhihengCard()
{
    target_fixed = true;
    mute = true;
}

void ZhihengCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &) const
{
    if (source->hasInnateSkill("zhiheng"))
        room->broadcastSkillInvoke("zhiheng");

    if (source->isAlive())
        room->drawCards(source, subcards.length(), "zhiheng");
}

HuanhuoCard::HuanhuoCard()
{
	mute = true;
	will_throw = true;
	handling_method = Card::MethodNone;
}

bool HuanhuoCard::targetFilter(const QList<const Player *> &targets, const Player *to_select, const Player *Self) const
{
	if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE_USE) {
		const Card *card = NULL;
		if (!user_string.isEmpty())
			card = Sanguosha->cloneCard(user_string.split("+").first());
		return card && card->targetFilter(targets, to_select, Self) && !Self->isProhibited(to_select, card, targets);
	}
	else if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE) {
		return false;
	}

	const Card *card = Self->tag.value("crhuanhuo").value<const Card *>();
	return card && card->targetFilter(targets, to_select, Self) && !Self->isProhibited(to_select, card, targets);
}

bool HuanhuoCard::targetFixed() const
{
	if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE_USE) {
		const Card *card = NULL;
		if (!user_string.isEmpty())
			card = Sanguosha->cloneCard(user_string.split("+").first());
		return card && card->targetFixed();
	}
	else if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE) {
		return true;
	}

	const Card *card = Self->tag.value("crhuanhuo").value<const Card *>();
	return card && card->targetFixed();
}

bool HuanhuoCard::targetsFeasible(const QList<const Player *> &targets, const Player *Self) const
{
	if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE_USE) {
		const Card *card = NULL;
		if (!user_string.isEmpty())
			card = Sanguosha->cloneCard(user_string.split("+").first());
		return card && card->targetsFeasible(targets, Self);
	}
	else if (Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE) {
		return true;
	}

	const Card *card = Self->tag.value("crhuanhuo").value<const Card *>();
	return card && card->targetsFeasible(targets, Self);
}

const Card *HuanhuoCard::validate(CardUseStruct &card_use) const
{
	ServerPlayer *yuji = card_use.from;
	Room *room = yuji->getRoom();

	QString to_guhuo = user_string;
	if (user_string == "slash"
		&& Sanguosha->currentRoomState()->getCurrentCardUseReason() == CardUseStruct::CARD_USE_REASON_RESPONSE_USE) {
		QStringList guhuo_list;
		guhuo_list << "slash";
		if (!Config.BanPackages.contains("maneuvering"))
			guhuo_list << "normal_slash" << "thunder_slash" << "fire_slash";
		to_guhuo = room->askForChoice(yuji, "guhuo_slash", guhuo_list.join("+"));
	}
	room->broadcastSkillInvoke("crhuanhuo");

	LogMessage log;
	log.type = card_use.to.isEmpty() ? "#HuanhuoNoTarget" : "#Huanhuo";
	log.from = yuji;
	log.to = card_use.to;
	log.arg = to_guhuo;
	log.arg2 = "crhuanhuo";
	room->sendLog(log);

	QString user_str;
	if (to_guhuo == "normal_slash")
		user_str = "slash";
	else
		user_str = to_guhuo;
	Card *use_card = Sanguosha->cloneCard(user_str, Card::NoSuit, 0);
	use_card->setSkillName("crhuanhuo");
	use_card->deleteLater();
	return use_card;
}

const Card *HuanhuoCard::validateInResponse(ServerPlayer *yuji) const
{
	Room *room = yuji->getRoom();
	room->broadcastSkillInvoke("crhuanhuo");

	QString to_guhuo;
	if (user_string == "peach+analeptic") {
		QStringList guhuo_list;
		guhuo_list << "peach";
		if (!Config.BanPackages.contains("maneuvering"))
			guhuo_list << "analeptic";
		to_guhuo = room->askForChoice(yuji, "crhuanhuo_saveself", guhuo_list.join("+"));
	}
	else if (user_string == "slash") {
		QStringList guhuo_list;
		guhuo_list << "slash";
		if (!Config.BanPackages.contains("maneuvering"))
			guhuo_list << "normal_slash" << "thunder_slash" << "fire_slash";
		to_guhuo = room->askForChoice(yuji, "crhuanhuo_slash", guhuo_list.join("+"));
	}
	else
		to_guhuo = user_string;

	LogMessage log;
	log.type = "#crhuanhuoNoTarget";
	log.from = yuji;
	log.arg = to_guhuo;
	log.arg2 = "crhuanhuo";
	room->sendLog(log);

	QString user_str;
	if (to_guhuo == "normal_slash")
		user_str = "slash";
	else
		user_str = to_guhuo;
	Card *use_card = Sanguosha->cloneCard(user_str, Card::NoSuit, 0);
	use_card->setSkillName("crhuanhuo");
	use_card->deleteLater();
	return use_card;
}

XianzhuoCard::XianzhuoCard()
{
	target_fixed = true;
	will_throw = true;
	m_skillName = "crxianzhuo";
	handling_method = Card::MethodUse;
}

void XianzhuoCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &) const
{
	room->doSuperLightbox("cryuji", "crxianzhuo");
	source->loseMark("@crXianZhuoMark");
	QList<ServerPlayer *> others = room->getOtherPlayers(source);
	foreach (ServerPlayer *target, others)
	{
		target->throwAllHandCardsAndEquips();
	}
	foreach (ServerPlayer *target, others)
	{
		room->loseMaxHp(target);
	}
	room->killPlayer(source);
}

KOFGameYuanHuCard::KOFGameYuanHuCard()
{
	target_fixed = true;
	will_throw = true;
	mute = true;
	m_skillName = "call_striker";
}

void KOFGameYuanHuCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &) const
{
	QString striker = source->tag["KOFGameStriker"].toString();
	QString skill = GameEX->getStrikerSkill(striker);
	source->tag["StrikerSkill"] = skill;
	room->acquireSkill(source, skill);
	source->loseMark("@striker");
}