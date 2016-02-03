#ifndef _AUX_PACK_H
#define _AUX_PACK_H

#include "package.h"
#include "generaloverview.h"
#include "card.h"
#include "skill.h"

class WeidiDialog : public QDialog
{
	Q_OBJECT

public:
	static WeidiDialog *getInstance();
	static QList<const ViewAsSkill *> getLordViewAsSkills(const Player *player);

public slots:
	void popup();
	void selectSkill(QAbstractButton *button);

private:
	explicit WeidiDialog();

	QAbstractButton *createSkillButton(const QString &skill_name);
	QButtonGroup *group;
	QVBoxLayout *button_layout;

signals:
	void onButtonClick();
};

class HuashenDialog : public GeneralOverview
{
	Q_OBJECT

public:
	HuashenDialog();

public slots:
	void popup();
};

class NosRendeCard : public SkillCard
{
	Q_OBJECT

public:
	Q_INVOKABLE NosRendeCard();
	virtual void use(Room *room, ServerPlayer *source, QList<ServerPlayer *> &targets) const;
};

class GuhuoDialog : public QDialog
{
	Q_OBJECT

public:
	static GuhuoDialog *getInstance(const QString &object, bool left = true, bool right = true,
		bool play_only = true, bool slash_combined = false, bool delayed_tricks = false);

	public slots:
	void popup();
	void selectCard(QAbstractButton *button);

protected:
	explicit GuhuoDialog(const QString &object, bool left = true, bool right = true,
		bool play_only = true, bool slash_combined = false, bool delayed_tricks = false);
	virtual bool isButtonEnabled(const QString &button_name) const;

private:
	QGroupBox *createLeft();
	QGroupBox *createRight();
	QAbstractButton *createButton(const Card *card);
	QButtonGroup *group;
	QHash<QString, const Card *> map;

	QString object_name;
	bool play_only; // whether the dialog will pop only during the Play phase
	bool slash_combined; // create one 'Slash' button instead of 'Slash', 'Fire Slash', 'Thunder Slash'
	bool delayed_tricks; // whether buttons of Delayed Tricks will be created

signals:
	void onButtonClick();
};

class AuxPackage : public Package
{
	Q_OBJECT

public:
	AuxPackage();
};

class DefaultPackage : public Package
{
	Q_OBJECT

public:
	DefaultPackage();
};

#endif // _AUX_PACK_H