#include "chooseteamdialog.h"
#include "engine.h"
#include "skin-bank.h"
#include <QLayout>
#include <QTabWidget>
#include <QLabel>
#include <QPushButton>
#include <QRegExp>
#include <QRadioButton>
#include <QButtonGroup>

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
	const int max_column = 3;
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
	this->group = NULL;
	QHBoxLayout *team_layout = new QHBoxLayout;
	QLabel *hint = new QLabel(QString("%1: ").arg(Sanguosha->translate(team->objectName())));
	team_layout->addWidget(hint);
	QStringList generals = team->getGenerals();
	QSize size = G_COMMON_LAYOUT.m_tinyAvatarSize;
	foreach(QString name, generals) {
		QToolButton *button = new QToolButton;
		bool need_confirm = true;
		if (name.startsWith("?")) {
			button->setProperty("GeneralFormat", name);
		} else {
			const General *general = Sanguosha->getGeneral(name);
			if (general != NULL) {
				button->setIconSize(size);
				QPixmap pixmap = G_ROOM_SKIN.getGeneralPixmap(name, QSanRoomSkin::S_GENERAL_ICON_SIZE_TINY);
				button->setIcon(QIcon(pixmap));
				button->setToolTip(general->getSkillDescription(true));
				button->setProperty("GeneralName", name);
				need_confirm = false;
			}
		}
		if (need_confirm) {
			button->setIconSize(size);
			QPixmap pixmap = G_ROOM_SKIN.getGeneralPixmap("anjiang", QSanRoomSkin::S_GENERAL_ICON_SIZE_TINY);
			button->setIcon(QIcon(pixmap));
			icons.append(button);
			connect(button, SIGNAL(clicked()), this, SLOT(onGeneralIconClicked()));
		}
		all_icons.append(button);
		team_layout->addWidget(button);
	}
	team_layout->addStretch();
	Q_ASSERT(!this->icons.isEmpty());
	this->tab_widget = new QTabWidget;
	this->ok_button = new QPushButton(tr("confirm"));
	connect(this->ok_button, SIGNAL(clicked()), this, SLOT(onBtnOK()));
	QHBoxLayout *button_layout = new QHBoxLayout;
	button_layout->addStretch();
	button_layout->addWidget(ok_button);
	button_layout->addStretch();

	QVBoxLayout *main_layout = new QVBoxLayout;
	main_layout->addLayout(team_layout);
	main_layout->addWidget(this->tab_widget);
	main_layout->addLayout(button_layout);
	this->setLayout(main_layout);

	this->icons.first()->click();
	connect(this, SIGNAL(rejected()), this, SLOT(onBtnCancel()));
}

QStringList ConfirmKOFGameGeneralsDialog::getUsableGeneralNames(const QString &format)
{
	if (!format.startsWith("?"))
		return Sanguosha->getLimitedGeneralNames();

	QStringList names;
	QString kingdom;
	bool male = false, female = false;
	bool boss = false;
	
	QStringList forbidden;
	foreach(QToolButton *icon, this->all_icons) {
		QString general = icon->property("GeneralName").toString();
		if (!general.isEmpty())
			forbidden.append(general);
	}

	QRegExp exp;
	exp.setCaseSensitivity(Qt::CaseInsensitive);
	exp.setMinimal(true);
	exp.setPattern("<kingdom=(.*)>");
	if (exp.indexIn(format) >= 0) {
		kingdom = exp.capturedTexts().at(1);
	}
	exp.setPattern("<boss=(.*)>");
	if (exp.indexIn(format) >= 0) {
		QString flag = exp.capturedTexts().at(1);
		boss = ((flag == "yes") || (flag == "true"));
	}
	exp.setPattern("<male=(.*)>");
	if (exp.indexIn(format) >= 0) {
		QString flag = exp.capturedTexts().at(1);
		male = ((flag == "yes") || (flag == "true"));
		female = !male;
	}
	else{
		exp.setPattern("<female=(.*)>");
		if (exp.indexIn(format) >= 0) {
			QString flag = exp.capturedTexts().at(1);
			female = ((flag == "yes") || (flag == "true"));
			male = !female;
		}
	}
	
	QStringList generals = Sanguosha->getLimitedGeneralNames(kingdom);
	foreach(QString name, generals) {
		if (forbidden.contains(name))
			continue;
		else if (boss && GameEX->isBossGeneral(name))
			continue;
		const General *general = Sanguosha->getGeneral(name);
		if (male && !general->isMale())
			continue;
		else if (female && !general->isFemale())
			continue;
		names.append(name);
	}

	return names;
}

QWidget *ConfirmKOFGameGeneralsDialog::createPage(QList<const General *> &generals)
{
	QWidget *tab = new QWidget;

	QGridLayout *layout = new QGridLayout;
	layout->setOriginCorner(Qt::TopLeftCorner);

	const int columns = 5;

	for (int i = 0; i < generals.length(); i++) {
		const General *general = generals.at(i);
		QString general_name = general->objectName();
		QString text = QString("%1[%2]")
			.arg(Sanguosha->translate(general_name))
			.arg(Sanguosha->translate(general->getPackage()));

		QRadioButton *button = new QRadioButton(text);
		button->setObjectName(general_name);
		button->setToolTip(general->getSkillDescription(true));
		group->addButton(button);
		int row = i / columns;
		int column = i % columns;
		layout->addWidget(button, row, column);
	}

	QVBoxLayout *layout2 = new QVBoxLayout;
	layout2->addStretch();

	QVBoxLayout *tablayout = new QVBoxLayout;
	tablayout->addLayout(layout);
	tablayout->addLayout(layout2);

	tab->setLayout(tablayout);

	return tab;
}

void ConfirmKOFGameGeneralsDialog::onGeneralIconClicked()
{
	this->tab_widget->clear();
	foreach(QScrollArea *area, this->pages) {
		delete area;
	}
	this->pages.clear();
	if (this->group != NULL) {
		delete this->group;
	}
	this->group = new QButtonGroup;
	QToolButton *source = (QToolButton *)(sender());
	this->current_icon = source;
	QString format = source->property("GeneralFormat").toString();
	QStringList generals = this->getUsableGeneralNames(format);
	QMap<QString, QList<const General *>> map;
	foreach(QString name, generals) {
		const General *general = Sanguosha->getGeneral(name);
		map[general->getKingdom()] << general;
	}
	QStringList kingdoms = Sanguosha->getKingdoms();
	foreach(QString kingdom, kingdoms) {
		QList<const General *> generals = map[kingdom];
		if (generals.isEmpty())
			continue;
		QWidget *page = createPage(generals);
		QScrollArea *area = new QScrollArea;
		area->setMinimumWidth(page->width());
		area->setWidget(page);
		area->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
		area->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
		QIcon icon = QIcon(G_ROOM_SKIN.getPixmap(QSanRoomSkin::S_SKIN_KEY_KINGDOM_ICON, kingdom));
		tab_widget->addTab(area, icon, Sanguosha->translate(kingdom));
		pages.append(area);
	}
	connect(group, SIGNAL(buttonClicked(QAbstractButton *)), this, SLOT(onGeneralButtonClicked(QAbstractButton *)));
}

void ConfirmKOFGameGeneralsDialog::onGeneralButtonClicked(QAbstractButton *button)
{
	QString name = button->objectName();
	const General *general = Sanguosha->getGeneral(name);
	QPixmap pixmap = G_ROOM_SKIN.getGeneralPixmap(name, QSanRoomSkin::S_GENERAL_ICON_SIZE_TINY);
	this->current_icon->setIcon(QIcon(pixmap));
	this->current_icon->setToolTip(general->getSkillDescription(true));
	this->current_icon->setProperty("GeneralName", name);
}

void ConfirmKOFGameGeneralsDialog::onBtnOK()
{
	QStringList names;
	foreach(QToolButton *button, this->all_icons) {
		QString name = button->property("GeneralName").toString();
		if (!name.isEmpty())
			names << name;
	}
	if (names.isEmpty())
		names << "sujiang";
	emit this->generals_confirmed(names);
	this->accept();
}

void ConfirmKOFGameGeneralsDialog::onBtnCancel()
{
	QStringList names;
	foreach(QToolButton *button, this->all_icons) {
		QString name = button->property("GeneralName").toString();
		if (!name.isEmpty())
			names << name;
	}
	if (names.isEmpty())
		names << "sujiangf";
	emit this->generals_confirmed(names);
}