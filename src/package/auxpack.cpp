#include "auxpack.h"
#include "engine.h"
#include "clientplayer.h"
#include <QCommandLinkButton>

WeidiDialog *WeidiDialog::getInstance()
{
	static WeidiDialog *instance;
	if (instance == NULL)
		instance = new WeidiDialog();

	return instance;
}

QList<const ViewAsSkill *> WeidiDialog::getLordViewAsSkills(const Player *player)
{
	const Player *lord = NULL;
	foreach(const Player *p, player->getAliveSiblings()) {
		if (p->isLord()) {
			lord = p;
			break;
		}
	}
	if (!lord) return QList<const ViewAsSkill *>();

	QList<const ViewAsSkill *> vs_skills;
	foreach(const Skill *skill, lord->getVisibleSkillList()) {
		if (skill->isLordSkill() && player->hasLordSkill(skill->objectName())) {
			const ViewAsSkill *vs = ViewAsSkill::parseViewAsSkill(skill);
			if (vs)
				vs_skills << vs;
		}
	}
	return vs_skills;
}

WeidiDialog::WeidiDialog()
{
	setObjectName("weidi");
	setWindowTitle(Sanguosha->translate("weidi"));
	group = new QButtonGroup(this);

	button_layout = new QVBoxLayout;
	setLayout(button_layout);
	connect(group, SIGNAL(buttonClicked(QAbstractButton *)), this, SLOT(selectSkill(QAbstractButton *)));
}

void WeidiDialog::popup()
{
	Self->tag.remove(objectName());
	foreach(QAbstractButton *button, group->buttons()) {
		button_layout->removeWidget(button);
		group->removeButton(button);
		delete button;
	}

	QList<const ViewAsSkill *> vs_skills = getLordViewAsSkills(Self);
	int count = 0;
	QString name;
	foreach(const ViewAsSkill *skill, vs_skills) {
		QAbstractButton *button = createSkillButton(skill->objectName());
		button->setEnabled(skill->isAvailable(Self, Sanguosha->currentRoomState()->getCurrentCardUseReason(),
			Sanguosha->currentRoomState()->getCurrentCardUsePattern()));
		if (button->isEnabled()) {
			count++;
			name = skill->objectName();
		}
		button_layout->addWidget(button);
	}

	if (count == 0) {
		emit onButtonClick();
		return;
	}
	else if (count == 1) {
		Self->tag[objectName()] = name;
		emit onButtonClick();
		return;
	}

	exec();
}

void WeidiDialog::selectSkill(QAbstractButton *button)
{
	Self->tag[objectName()] = button->objectName();
	emit onButtonClick();
	accept();
}

QAbstractButton *WeidiDialog::createSkillButton(const QString &skill_name)
{
	const Skill *skill = Sanguosha->getSkill(skill_name);
	if (!skill) return NULL;

	QCommandLinkButton *button = new QCommandLinkButton(Sanguosha->translate(skill_name));
	button->setObjectName(skill_name);
	button->setToolTip(skill->getDescription());

	group->addButton(button);
	return button;
}

HuashenDialog::HuashenDialog()
{
	setWindowTitle(Sanguosha->translate("huashen"));
}

void HuashenDialog::popup()
{
	QVariantList huashen_list = Self->tag["Huashens"].toList();
	QList<const General *> huashens;
	foreach(QVariant huashen, huashen_list)
		huashens << Sanguosha->getGeneral(huashen.toString());

	fillGenerals(huashens);
	show();
}

NosRendeCard::NosRendeCard()
{
	mute = true;
	will_throw = false;
	handling_method = Card::MethodNone;
}

void NosRendeCard::use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const
{
	ServerPlayer *target = targets.first();

	room->broadcastSkillInvoke("rende");
	CardMoveReason reason(CardMoveReason::S_REASON_GIVE, source->objectName(), target->objectName(), "nosrende", QString());
	room->obtainCard(target, this, reason, false);

	int old_value = source->getMark("nosrende");
	int new_value = old_value + subcards.length();
	room->setPlayerMark(source, "nosrende", new_value);

	if (old_value < 2 && new_value >= 2)
		room->recover(source, RecoverStruct(source));
}

GuhuoDialog *GuhuoDialog::getInstance(const QString &object, bool left, bool right,
	bool play_only, bool slash_combined, bool delayed_tricks)
{
	static GuhuoDialog *instance;
	if (instance == NULL || instance->objectName() != object)
		instance = new GuhuoDialog(object, left, right, play_only, slash_combined, delayed_tricks);

	return instance;
}

GuhuoDialog::GuhuoDialog(const QString &object, bool left, bool right, bool play_only,
	bool slash_combined, bool delayed_tricks)
	: object_name(object), play_only(play_only),
	slash_combined(slash_combined), delayed_tricks(delayed_tricks)
{
	setObjectName(object);
	setWindowTitle(Sanguosha->translate(object));
	group = new QButtonGroup(this);

	QHBoxLayout *layout = new QHBoxLayout;
	if (left) layout->addWidget(createLeft());
	if (right) layout->addWidget(createRight());
	setLayout(layout);

	connect(group, SIGNAL(buttonClicked(QAbstractButton *)), this, SLOT(selectCard(QAbstractButton *)));
}

bool GuhuoDialog::isButtonEnabled(const QString &button_name) const
{
	const Card *card = map[button_name];
	return !Self->isCardLimited(card, Card::MethodUse, true) && card->isAvailable(Self);
}

void GuhuoDialog::popup()
{
	if (play_only && Sanguosha->currentRoomState()->getCurrentCardUseReason() != CardUseStruct::CARD_USE_REASON_PLAY) {
		emit onButtonClick();
		return;
	}

	bool has_enabled_button = false;
	foreach(QAbstractButton *button, group->buttons()) {
		bool enabled = isButtonEnabled(button->objectName());
		if (enabled)
			has_enabled_button = true;
		button->setEnabled(enabled);
	}
	if (!has_enabled_button) {
		emit onButtonClick();
		return;
	}

	Self->tag.remove(object_name);
	exec();
}

void GuhuoDialog::selectCard(QAbstractButton *button)
{
	const Card *card = map.value(button->objectName());
	Self->tag[object_name] = QVariant::fromValue(card);
	if (button->objectName().contains("slash")) {
		if (objectName() == "guhuo")
			Self->tag["GuhuoSlash"] = button->objectName();
	}
	emit onButtonClick();
	accept();
}

QGroupBox *GuhuoDialog::createLeft()
{
	QGroupBox *box = new QGroupBox;
	box->setTitle(Sanguosha->translate("basic"));

	QVBoxLayout *layout = new QVBoxLayout;

	QList<const Card *> cards = Sanguosha->findChildren<const Card *>();
	foreach(const Card *card, cards) {
		if (card->getTypeId() == Card::TypeBasic && !map.contains(card->objectName())
			&& !ServerInfo.Extensions.contains("!" + card->getPackage())
			&& !(slash_combined && map.contains("slash") && card->objectName().contains("slash"))) {
			Card *c = Sanguosha->cloneCard(card->objectName());
			c->setParent(this);
			layout->addWidget(createButton(c));

			if (!slash_combined && card->objectName() == "slash"
				&& !ServerInfo.Extensions.contains("!maneuvering")) {
				Card *c2 = Sanguosha->cloneCard(card->objectName());
				c2->setParent(this);
				layout->addWidget(createButton(c2));
			}
		}
	}

	layout->addStretch();
	box->setLayout(layout);
	return box;
}

QGroupBox *GuhuoDialog::createRight()
{
	QGroupBox *box = new QGroupBox(Sanguosha->translate("trick"));
	QHBoxLayout *layout = new QHBoxLayout;

	QGroupBox *box1 = new QGroupBox(Sanguosha->translate("single_target_trick"));
	QVBoxLayout *layout1 = new QVBoxLayout;

	QGroupBox *box2 = new QGroupBox(Sanguosha->translate("multiple_target_trick"));
	QVBoxLayout *layout2 = new QVBoxLayout;

	QGroupBox *box3 = new QGroupBox(Sanguosha->translate("delayed_trick"));
	QVBoxLayout *layout3 = new QVBoxLayout;

	QList<const Card *> cards = Sanguosha->findChildren<const Card *>();
	foreach(const Card *card, cards) {
		if (card->getTypeId() == Card::TypeTrick && (delayed_tricks || card->isNDTrick())
			&& !map.contains(card->objectName())
			&& !ServerInfo.Extensions.contains("!" + card->getPackage())) {
			Card *c = Sanguosha->cloneCard(card->objectName());
			c->setSkillName(object_name);
			c->setParent(this);

			QVBoxLayout *layout;
			if (c->isKindOf("DelayedTrick"))
				layout = layout3;
			else if (c->isKindOf("SingleTargetTrick"))
				layout = layout1;
			else
				layout = layout2;
			layout->addWidget(createButton(c));
		}
	}

	box->setLayout(layout);
	box1->setLayout(layout1);
	box2->setLayout(layout2);
	box3->setLayout(layout3);

	layout1->addStretch();
	layout2->addStretch();
	layout3->addStretch();

	layout->addWidget(box1);
	layout->addWidget(box2);
	if (delayed_tricks)
		layout->addWidget(box3);
	return box;
}

QAbstractButton *GuhuoDialog::createButton(const Card *card)
{
	if (card->objectName() == "slash" && map.contains(card->objectName()) && !map.contains("normal_slash")) {
		QCommandLinkButton *button = new QCommandLinkButton(Sanguosha->translate("normal_slash"));
		button->setObjectName("normal_slash");
		button->setToolTip(card->getDescription());

		map.insert("normal_slash", card);
		group->addButton(button);

		return button;
	}
	else {
		QCommandLinkButton *button = new QCommandLinkButton(Sanguosha->translate(card->objectName()));
		button->setObjectName(card->objectName());
		button->setToolTip(card->getDescription());

		map.insert(card->objectName(), card);
		group->addButton(button);

		return button;
	}
}

AuxPackage::AuxPackage()
	:Package("auxpack")
{
	type = Package::SpecialPack;
	addMetaObject<NosRendeCard>();
}

ADD_PACKAGE(Aux)