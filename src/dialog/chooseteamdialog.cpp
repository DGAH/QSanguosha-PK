#include "chooseteamdialog.h"
#include "engine.h"
#include "skin-bank.h"
#include <QLayout>
#include <QScrollArea>
#include <QTabWidget>

//****************TeamButton****************//

TeamButton::TeamButton(const QString &name, QWidget *parent)
    :QToolButton(parent)
{
	setObjectName(name);
	this->team = GameEX->getTeam(name);
	if (this->team != NULL) {
		QString resource = this->team->getResourcePath();
		this->setIconSize(QSize(252, 36));
		QString teambar = QString("%1/%2").arg(resource).arg("teambar.png");
		this->setIcon(QIcon(teambar));
		this->setToolTip(this->team->getDescription());
		connect(this, SIGNAL(clicked()), this, SLOT(whenClicked()));
	}
}

void TeamButton::whenClicked()
{
	emit this->button_clicked(this->team->objectName());
}

//****************ChooseKOFGameTeamDialog****************//

ChooseKOFGameTeamDialog::ChooseKOFGameTeamDialog()
{
	setWindowTitle(tr("Please Choose A Team:"));
	setMinimumWidth(840);

	bool include_boss = GameEX->canSelectBossTeam();
	QStringList levels = GameEX->getAllLevelNames(include_boss);

	this->tab_widget = new QTabWidget;
	foreach(QString level, levels) {
		this->tab_widget->addTab(createTeamBox(level), Sanguosha->translate(level));
	}

	QToolButton *free_button = new QToolButton;
	free_button->setIconSize(QSize(252, 36));
	free_button->setIcon(QIcon(QString("%1/%2").arg(GameEX->getFreeChooseTeam()->getResourcePath()).arg("teambar.png")));
	free_button->setToolTip(tr("Create your own team by choose some generals freely."));
	connect(free_button, SIGNAL(clicked()), this, SLOT(onFreeButtonClicked()));

	QToolButton *random_button = new QToolButton;
	random_button->setIconSize(QSize(252, 36));
	random_button->setIcon(QIcon("image/system/06_teams/random_select.png"));
	random_button->setToolTip(tr("Select an existing team randomly."));
	connect(random_button, SIGNAL(clicked()), this, SLOT(onRandomButtonClicked()));

	QHBoxLayout *button_layout = new QHBoxLayout;
	button_layout->addStretch();
	button_layout->addWidget(free_button);
	button_layout->addStretch();
	button_layout->addWidget(random_button);
	button_layout->addStretch();

	QVBoxLayout *main_layout = new QVBoxLayout;
	main_layout->addWidget(tab_widget);
	main_layout->addLayout(button_layout);
	this->setLayout(main_layout);

	connect(this, SIGNAL(rejected()), this, SLOT(onCanceled()));
}

QWidget *ChooseKOFGameTeamDialog::createTeamBox(const QString &level)
{
	QScrollArea *area = new QScrollArea;
	area->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
	area->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
	QWidget *box = new QWidget;
	QStringList teams = GameEX->getAllTeamNames(level);
	QGridLayout *layout = new QGridLayout;
	int count = teams.length();
	int max_column = 3;
	int row = 0, column = 0;
	foreach(QString team, teams) {
		TeamButton *button = new TeamButton(team);
		layout->addWidget(button, row, column);
		connect(button, SIGNAL(button_clicked(QString)), this, SLOT(onTeamButtonClicked(QString)));
		column++;
		if (column >= max_column) {
			column = 0;
			row++;
		}
	}
	box->setLayout(layout);
	area->setWidget(box);
	return area;
}

void ChooseKOFGameTeamDialog::onTeamButtonClicked(const QString &team)
{
	emit this->team_chosen(team);
	this->accept();
}

void ChooseKOFGameTeamDialog::onFreeButtonClicked()
{
	emit this->team_chosen(GameEX->getFreeChooseTeamName());
	this->accept();
}

void ChooseKOFGameTeamDialog::onRandomButtonClicked()
{
	QWidget *widget = this->tab_widget->currentWidget();
	QList<TeamButton *> buttons = widget->findChildren<TeamButton *>();
	if (buttons.isEmpty()) {
		this->onFreeButtonClicked();
		return;
	}
	int index = qrand() % buttons.length();
	QString team = buttons.at(index)->objectName();
	emit this->team_chosen(team);
	this->accept();
}

void ChooseKOFGameTeamDialog::onCanceled()
{
	emit this->team_chosen(GameEX->getFreeChooseTeamName());
}

//****************ConfirmKOFGameGeneralsDialog****************//

ConfirmKOFGameGeneralsDialog::ConfirmKOFGameGeneralsDialog(const QString &team_name)
{
	this->team = GameEX->getTeam(team_name);
	if (this->team == NULL)
		this->team = GameEX->getFreeChooseTeam();
	// Waiting For More Details.
}