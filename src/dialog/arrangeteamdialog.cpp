#include "arrangeteamdialog.h"
#include "kofgame-engine.h"
#include "engine.h"
#include <QLayout>
#include <QLabel>
#include <QPushButton>
#include "skin-bank.h"
#include "choosegeneraldialog.h"
#include <QMessageBox>

ArrangeTeamDialog::ArrangeTeamDialog(int max_count, const QStringList &generals)
{
	setWindowTitle(tr("Please arrange the order for your generals:"));
	this->arrange_count = max_count;
	this->generals = generals;
	this->striker_mode = GameEX->useStrikerMode();
	this->striker_button = NULL;
	this->general_button_group = new QButtonGroup;
	this->arrange_button_group = new QButtonGroup;
	this->selected_button = NULL;
	this->initScene();
	connect(this, SIGNAL(rejected()), this, SLOT(onBtnCancel()));
}

void ArrangeTeamDialog::initScene()
{
	QLabel *general_hint = new QLabel(tr("team generals:"));
	QHBoxLayout *general_hint_layout = new QHBoxLayout;
	general_hint_layout->addWidget(general_hint);
	general_hint_layout->addStretch();

	QHBoxLayout *general_layout = new QHBoxLayout;
	QSize size = G_COMMON_LAYOUT.m_chooseGeneralBoxSparseIconSize;
	foreach(QString name, this->generals) {
		const General *general = Sanguosha->getGeneral(name);
		Q_ASSERT(general);
		OptionButton *button = new OptionButton("", Sanguosha->translate(name));
		button->setIconSize(size);
		button->setIcon(QIcon(G_ROOM_SKIN.getGeneralPixmap(name, QSanRoomSkin::S_GENERAL_ICON_SIZE_CARD)));
		button->setToolTip(general->getSkillDescription(true));
		button->setProperty("GeneralName", name);
		general_layout->addWidget(button);
		this->general_button_group->addButton(button);
		connect(button, SIGNAL(clicked()), this, SLOT(whenGeneralButtonClicked()));
	}

	QLabel *normal_hint = new QLabel(tr("selected generals:"));
	QHBoxLayout *normal_hint_layout = new QHBoxLayout;
	normal_hint_layout->addWidget(normal_hint);
	normal_hint_layout->addStretch();

	QHBoxLayout *normal_layout = new QHBoxLayout;
	int count = this->generals.length();
	if (count > this->arrange_count)
		count = this->arrange_count;
	for (int index = 0; index < count; index++) {
		OptionButton *button = new OptionButton("", "", NULL, true);
		button->setIconSize(size);
		button->setIcon(QIcon(G_ROOM_SKIN.getGeneralPixmap("anjiang", QSanRoomSkin::S_GENERAL_ICON_SIZE_CARD)));
		normal_layout->addWidget(button);
		this->arrange_button_group->addButton(button);
		connect(button, SIGNAL(clicked()), this, SLOT(whenGeneralButtonClicked()));
	}

	QVBoxLayout *arrange_normal_layout = new QVBoxLayout;
	arrange_normal_layout->addLayout(normal_hint_layout);
	arrange_normal_layout->addLayout(normal_layout);

	QHBoxLayout *striker_hint_layout = new QHBoxLayout;
	if (this->striker_mode) {
		QLabel *striker_hint = new QLabel(tr("striker:"));
		striker_hint_layout->addWidget(striker_hint);
		striker_hint_layout->addStretch();
	}

	QHBoxLayout *striker_layout = new QHBoxLayout;
	if (this->striker_mode) {
		this->striker_button = new OptionButton("", "", NULL, true);
		this->striker_button->setIconSize(size);
		this->striker_button->setIcon(QIcon(G_ROOM_SKIN.getGeneralPixmap("anjiang", QSanRoomSkin::S_GENERAL_ICON_SIZE_CARD)));
		striker_layout->addWidget(this->striker_button);
		connect(this->striker_button, SIGNAL(clicked()), this, SLOT(whenGeneralButtonClicked()));
	}

	QVBoxLayout *arrange_striker_layout = new QVBoxLayout;
	arrange_striker_layout->addLayout(striker_hint_layout);
	arrange_striker_layout->addLayout(striker_layout);

	QHBoxLayout *arrange_layout = new QHBoxLayout;
	arrange_layout->addLayout(arrange_normal_layout);
	arrange_layout->addStretch();
	arrange_layout->addLayout(arrange_striker_layout);
	
	this->ok_button = new QPushButton(tr("finished"));
	connect(this->ok_button, SIGNAL(clicked()), this, SLOT(onBtnOK()));
	QHBoxLayout *button_layout = new QHBoxLayout;
	button_layout->addStretch();
	button_layout->addWidget(this->ok_button);
	button_layout->addStretch();

	QVBoxLayout *main_layout = new QVBoxLayout;
	main_layout->addLayout(general_hint_layout);
	main_layout->addLayout(general_layout);
	main_layout->addLayout(arrange_layout);
	main_layout->addLayout(button_layout);
	this->setLayout(main_layout);
}

void ArrangeTeamDialog::swapButtons(OptionButton *a, OptionButton *b)
{
	QIcon icon_a = a->icon();
	QIcon icon_b = b->icon();
	a->setIcon(icon_b);
	b->setIcon(icon_a);

	QString text_a = a->text();
	QString text_b = b->text();
	a->setText(text_b);
	b->setText(text_a);
	if (!text_b.isEmpty()) {
		a->setToolButtonStyle(Qt::ToolButtonTextUnderIcon);
		QFont font = Config.SmallFont;
		font.setPixelSize(Config.SmallFont.pixelSize() - 8);
		a->setFont(font);
	}
	if (!text_a.isEmpty()) {
		b->setToolButtonStyle(Qt::ToolButtonTextUnderIcon);
		QFont font = Config.SmallFont;
		font.setPixelSize(Config.SmallFont.pixelSize() - 8);
		b->setFont(font);
	}

	QString tip_a = a->toolTip();
	QString tip_b = b->toolTip();
	a->setToolTip(tip_b);
	b->setToolTip(tip_a);

	QString name_a = a->property("GeneralName").toString();
	QString name_b = b->property("GeneralName").toString();
	a->setProperty("GeneralName", name_b);
	b->setProperty("GeneralName", name_a);
}

bool ArrangeTeamDialog::updateButtonSelectState(OptionButton *current)
{
	if (!this->selected_button) {
		this->selected_button = current;
		return false;
	}
	if (this->selected_button == current) {
		this->selected_button = NULL;
		return false;
	}
	this->swapButtons(this->selected_button, current);
	this->selected_button = NULL;
	return true;
}

void ArrangeTeamDialog::updateTeamGeneralsState()
{
	QList<QAbstractButton *> buttons = this->general_button_group->buttons();
	int count = buttons.length();
	for (int i = 0; i < count; i++) {
		OptionButton *button = (OptionButton *)(buttons.at(i));
		if (button->property("GeneralName").toString().isEmpty()) {
			bool swap = false;
			for (int j = i + 1; j < count; j++) {
				OptionButton *button2 = (OptionButton *)(buttons.at(j));
				if (!button2->property("GeneralName").toString().isEmpty()) {
					this->swapButtons(button, button2);
					swap = true;
					break;
				}
			}
			if (!swap)
				return;
		}
	}
}

void ArrangeTeamDialog::whenGeneralButtonClicked()
{
	OptionButton *button = (OptionButton *)(sender());
	bool changed = this->updateButtonSelectState(button);
	if (changed)
		this->updateTeamGeneralsState();
}

void ArrangeTeamDialog::onBtnOK()
{
	QStringList names;
	QList<QAbstractButton *> buttons = this->arrange_button_group->buttons();
	for (int i = 0; i < buttons.length(); i++) {
		OptionButton *button = (OptionButton *)(buttons.at(i));
		QString name = button->property("GeneralName").toString();
		if (!name.isEmpty())
			names << name;
	}
	if (names.isEmpty()) {
		QMessageBox::warning(NULL, tr("Warning!"), tr("You must select at least one general for your team to start this game."));
		return;
	}
	QString striker;
	if (this->striker_button)
		striker = this->striker_button->property("GeneralName").toString();
	emit this->team_arranged(names, striker);
	this->accept();
}

void ArrangeTeamDialog::onBtnCancel()
{
	emit this->team_arranged(this->generals, "");
}