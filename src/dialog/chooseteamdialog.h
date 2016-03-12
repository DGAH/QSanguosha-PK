#ifndef _CHOOSE_TEAM_DIALOG_H
#define _CHOOSE_TEAM_DIALOG_H

#include <QDialog>
#include <QToolButton>
#include <QTabWidget>
#include "kofgame-engine.h"

class TeamButton : public QToolButton
{
	Q_OBJECT

public:
	TeamButton(const QString &team, QWidget *parent = NULL);

private:
	KOFGameTeam *team;

signals:
	void button_clicked(const QString &team);

public slots:
	void whenClicked();
};

class ChooseKOFGameTeamDialog : public QDialog
{
	Q_OBJECT

public:
	ChooseKOFGameTeamDialog();

protected:
	QWidget *createTeamBox(const QString &level);

private:
	QTabWidget *tab_widget;

signals:
	void team_chosen(QString team);

public slots:
	void onTeamButtonClicked(const QString &team);
	void onFreeButtonClicked();
	void onRandomButtonClicked();
	void onCanceled();
};

class ConfirmKOFGameGeneralsDialog : public QDialog
{
	Q_OBJECT

public:
	ConfirmKOFGameGeneralsDialog(const QString &team_name);

private:
	KOFGameTeam *team;
};

#endif