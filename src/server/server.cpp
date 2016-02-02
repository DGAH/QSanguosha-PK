#include "server.h"
#include "settings.h"
#include "room.h"
#include "engine.h"
#include "nativesocket.h"
#include "banpair.h"
#include "scenario.h"
#include "choosegeneraldialog.h"
#include "skin-bank.h"
#include "json.h"
#include "gamerule.h"
#include "general-level.h"

#include <QMessageBox>
#include <QFormLayout>
#include <QComboBox>
#include <QPushButton>
#include <QGroupBox>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QRadioButton>
#include <QApplication>
#include <QHostInfo>
#include <QAction>

using namespace QSanProtocol;

static QLayout *HLay(QWidget *left, QWidget *right)
{
    QHBoxLayout *layout = new QHBoxLayout;
    layout->addWidget(left);
    layout->addWidget(right);
    return layout;
}

ServerDialog::ServerDialog(QWidget *parent)
    : QDialog(parent), accept_type(0)
{
    setWindowTitle(tr("Start server"));

    QTabWidget *tab_widget = new QTabWidget;
    tab_widget->addTab(createBasicTab(), tr("Basic"));
    tab_widget->addTab(createPackageTab(), tr("Game Pacakge Selection"));
    tab_widget->addTab(createAdvancedTab(), tr("Advanced"));
    tab_widget->addTab(createMiscTab(), tr("Miscellaneous"));

	this->challenger_button = NULL;
	this->gatekeeper_button = NULL;
	tab_widget->addTab(createRankSettingsTab(), tr("Rank"));

    QVBoxLayout *layout = new QVBoxLayout;
    layout->addWidget(tab_widget);
    layout->addLayout(createButtonLayout());
    setLayout(layout);

    setMinimumWidth(300);
}

QWidget *ServerDialog::createBasicTab()
{
    server_name_edit = new QLineEdit;
    server_name_edit->setText(Config.ServerName);

    timeout_spinbox = new QSpinBox;
    timeout_spinbox->setMinimum(5);
    timeout_spinbox->setMaximum(60);
    timeout_spinbox->setValue(Config.OperationTimeout);
    timeout_spinbox->setSuffix(tr(" seconds"));
    nolimit_checkbox = new QCheckBox(tr("No limit"));
    nolimit_checkbox->setChecked(Config.OperationNoLimit);
    connect(nolimit_checkbox, SIGNAL(toggled(bool)), timeout_spinbox, SLOT(setDisabled(bool)));

    // add 1v1 banlist edit button
    QPushButton *edit_button = new QPushButton(tr("Banlist ..."));
    edit_button->setFixedWidth(100);
    connect(edit_button, SIGNAL(clicked()), this, SLOT(edit1v1Banlist()));

    QFormLayout *form_layout = new QFormLayout;
    form_layout->addRow(tr("Server name"), server_name_edit);
    QHBoxLayout *lay = new QHBoxLayout;
    lay->addWidget(timeout_spinbox);
    lay->addWidget(nolimit_checkbox);
    lay->addWidget(edit_button);
    form_layout->addRow(tr("Operation timeout"), lay);
    form_layout->addRow(createGameModeBox());

    QWidget *widget = new QWidget;
    widget->setLayout(form_layout);
    return widget;
}

QWidget *ServerDialog::createPackageTab()
{
    disable_lua_checkbox = new QCheckBox(tr("Disable Lua"));
    disable_lua_checkbox->setChecked(Config.DisableLua);
    disable_lua_checkbox->setToolTip(tr("The setting takes effect after reboot"));

    extension_group = new QButtonGroup;
    extension_group->setExclusive(false);

    QStringList extensions = Sanguosha->getExtensions();
    QSet<QString> ban_packages = Config.BanPackages.toSet();

    QGroupBox *box1 = new QGroupBox(tr("General package"));
    QGroupBox *box2 = new QGroupBox(tr("Card package"));

    QGridLayout *layout1 = new QGridLayout;
    QGridLayout *layout2 = new QGridLayout;
    box1->setLayout(layout1);
    box2->setLayout(layout2);

    int i = 0, j = 0;
    int row = 0, column = 0;
    foreach (QString extension, extensions) {
        const Package *package = Sanguosha->findChild<const Package *>(extension);
        if (package == NULL)
            continue;

        bool forbid_package = Config.value("ForbidPackages").toStringList().contains(extension);
        QCheckBox *checkbox = new QCheckBox;
        checkbox->setObjectName(extension);
        checkbox->setText(Sanguosha->translate(extension));
        checkbox->setChecked(!ban_packages.contains(extension) && !forbid_package);
        checkbox->setEnabled(!forbid_package);

        extension_group->addButton(checkbox);

        switch (package->getType()) {
        case Package::GeneralPack: {
            row = i / 5;
            column = i % 5;
            i++;

            layout1->addWidget(checkbox, row, column + 1);
            break;
        }
        case Package::CardPack: {
            row = j / 5;
            column = j % 5;
            j++;

            layout2->addWidget(checkbox, row, column + 1);
            break;
        }
        default:
            break;
        }
    }

    QWidget *widget = new QWidget;
    QVBoxLayout *layout = new QVBoxLayout;
    layout->addWidget(disable_lua_checkbox);
    layout->addWidget(box1);
    layout->addWidget(box2);

    widget->setLayout(layout);
    return widget;
}

void ServerDialog::setMaxHpSchemeBox()
{
    if (!second_general_checkbox->isChecked()) {
        prevent_awaken_below3_checkbox->setVisible(false);

        scheme0_subtraction_label->setVisible(false);
        scheme0_subtraction_spinbox->setVisible(false);

        return;
    }
    int index = max_hp_scheme_ComboBox->currentIndex();
    if (index == 0) {
        prevent_awaken_below3_checkbox->setVisible(false);

        scheme0_subtraction_label->setVisible(true);
        scheme0_subtraction_spinbox->setVisible(true);
        scheme0_subtraction_spinbox->setValue(Config.value("Scheme0Subtraction", 3).toInt());
        scheme0_subtraction_spinbox->setEnabled(true);
    } else {
        prevent_awaken_below3_checkbox->setVisible(true);
        prevent_awaken_below3_checkbox->setChecked(Config.value("PreventAwakenBelow3", false).toBool());
        prevent_awaken_below3_checkbox->setEnabled(true);

        scheme0_subtraction_label->setVisible(false);
        scheme0_subtraction_spinbox->setVisible(false);
    }
}

QWidget *ServerDialog::createAdvancedTab()
{
    QVBoxLayout *layout = new QVBoxLayout;

    random_seat_checkbox = new QCheckBox(tr("Arrange the seats randomly"));
    random_seat_checkbox->setChecked(Config.RandomSeat);

    enable_cheat_checkbox = new QCheckBox(tr("Enable cheat"));
    enable_cheat_checkbox->setToolTip(tr("This option enables the cheat menu"));
    enable_cheat_checkbox->setChecked(Config.EnableCheat);

    free_choose_checkbox = new QCheckBox(tr("Choose generals and cards freely"));
    free_choose_checkbox->setChecked(Config.FreeChoose);
    free_choose_checkbox->setVisible(Config.EnableCheat);

    free_assign_checkbox = new QCheckBox(tr("Assign role and seat freely"));
    free_assign_checkbox->setChecked(Config.value("FreeAssign").toBool());
    free_assign_checkbox->setVisible(Config.EnableCheat);

    free_assign_self_checkbox = new QCheckBox(tr("Assign only your own role"));
    free_assign_self_checkbox->setChecked(Config.FreeAssignSelf);
    free_assign_self_checkbox->setEnabled(free_assign_checkbox->isChecked());
    free_assign_self_checkbox->setVisible(Config.EnableCheat);

    connect(enable_cheat_checkbox, SIGNAL(toggled(bool)), free_choose_checkbox, SLOT(setVisible(bool)));
    connect(enable_cheat_checkbox, SIGNAL(toggled(bool)), free_assign_checkbox, SLOT(setVisible(bool)));
    connect(enable_cheat_checkbox, SIGNAL(toggled(bool)), free_assign_self_checkbox, SLOT(setVisible(bool)));
    connect(free_assign_checkbox, SIGNAL(toggled(bool)), free_assign_self_checkbox, SLOT(setEnabled(bool)));

    pile_swapping_label = new QLabel(tr("Pile-swapping limitation"));
    pile_swapping_label->setToolTip(tr("-1 means no limitations"));
    pile_swapping_spinbox = new QSpinBox;
    pile_swapping_spinbox->setRange(-1, 15);
    pile_swapping_spinbox->setValue(Config.value("PileSwappingLimitation", 5).toInt());

    maxchoice_spinbox = new QSpinBox;
    maxchoice_spinbox->setRange(3, 21);
    maxchoice_spinbox->setValue(Config.value("MaxChoice", 5).toInt());

    forbid_same_ip_checkbox = new QCheckBox(tr("Forbid same IP with multiple connection"));
    forbid_same_ip_checkbox->setChecked(Config.ForbidSIMC);

    disable_chat_checkbox = new QCheckBox(tr("Disable chat"));
    disable_chat_checkbox->setChecked(Config.DisableChat);

    second_general_checkbox = new QCheckBox(tr("Enable second general"));
    second_general_checkbox->setChecked(Config.Enable2ndGeneral);

    max_hp_label = new QLabel(tr("Max HP scheme"));
    max_hp_scheme_ComboBox = new QComboBox;
    max_hp_scheme_ComboBox->addItem(tr("Sum - X"));
    max_hp_scheme_ComboBox->addItem(tr("Minimum"));
    max_hp_scheme_ComboBox->addItem(tr("Maximum"));
    max_hp_scheme_ComboBox->addItem(tr("Average"));
    max_hp_scheme_ComboBox->setCurrentIndex(Config.MaxHpScheme);

    prevent_awaken_below3_checkbox = new QCheckBox(tr("Prevent maxhp being less than 3 for awaken skills"));
    prevent_awaken_below3_checkbox->setChecked(Config.PreventAwakenBelow3);
    prevent_awaken_below3_checkbox->setEnabled(max_hp_scheme_ComboBox->currentIndex() != 0);

    scheme0_subtraction_label = new QLabel(tr("Subtraction for scheme 0"));
    scheme0_subtraction_label->setVisible(max_hp_scheme_ComboBox->currentIndex() == 0);
    scheme0_subtraction_spinbox = new QSpinBox;
    scheme0_subtraction_spinbox->setRange(-5, 12);
    scheme0_subtraction_spinbox->setValue(Config.Scheme0Subtraction);
    scheme0_subtraction_spinbox->setVisible(max_hp_scheme_ComboBox->currentIndex() == 0);

    connect(max_hp_scheme_ComboBox, SIGNAL(currentIndexChanged(int)), this, SLOT(setMaxHpSchemeBox()));

    updateButtonEnablility(mode_group->checkedButton());
    connect(mode_group, SIGNAL(buttonClicked(QAbstractButton *)), this, SLOT(updateButtonEnablility(QAbstractButton *)));

    address_edit = new QLineEdit;
    address_edit->setText(Config.Address);
#if QT_VERSION >= 0x040700
    address_edit->setPlaceholderText(tr("Public IP or domain"));
#endif

    QPushButton *detect_button = new QPushButton(tr("Detect my WAN IP"));
    connect(detect_button, SIGNAL(clicked()), this, SLOT(onDetectButtonClicked()));

    port_edit = new QLineEdit;
    port_edit->setText(QString::number(Config.ServerPort));
    port_edit->setValidator(new QIntValidator(1, 9999, port_edit));

    layout->addWidget(forbid_same_ip_checkbox);
    layout->addWidget(disable_chat_checkbox);
    layout->addWidget(random_seat_checkbox);
    layout->addWidget(enable_cheat_checkbox);
    layout->addWidget(free_choose_checkbox);
    layout->addLayout(HLay(free_assign_checkbox, free_assign_self_checkbox));
    layout->addLayout(HLay(pile_swapping_label, pile_swapping_spinbox));
    layout->addLayout(HLay(new QLabel(tr("Upperlimit for general")), maxchoice_spinbox));
    layout->addWidget(second_general_checkbox);
    layout->addLayout(HLay(max_hp_label, max_hp_scheme_ComboBox));
    layout->addLayout(HLay(scheme0_subtraction_label, scheme0_subtraction_spinbox));
    layout->addWidget(prevent_awaken_below3_checkbox);
    layout->addLayout(HLay(new QLabel(tr("Address")), address_edit));
    layout->addWidget(detect_button);
    layout->addLayout(HLay(new QLabel(tr("Port")), port_edit));
    layout->addStretch();

    QWidget *widget = new QWidget;
    widget->setLayout(layout);

    max_hp_label->setVisible(Config.Enable2ndGeneral);
    connect(second_general_checkbox, SIGNAL(toggled(bool)), max_hp_label, SLOT(setVisible(bool)));
    max_hp_scheme_ComboBox->setVisible(Config.Enable2ndGeneral);
    connect(second_general_checkbox, SIGNAL(toggled(bool)), max_hp_scheme_ComboBox, SLOT(setVisible(bool)));

    if (Config.Enable2ndGeneral) {
        prevent_awaken_below3_checkbox->setVisible(max_hp_scheme_ComboBox->currentIndex() != 0);
        scheme0_subtraction_label->setVisible(max_hp_scheme_ComboBox->currentIndex() == 0);
        scheme0_subtraction_spinbox->setVisible(max_hp_scheme_ComboBox->currentIndex() == 0);
    } else {
        prevent_awaken_below3_checkbox->setVisible(false);
        scheme0_subtraction_label->setVisible(false);
        scheme0_subtraction_spinbox->setVisible(false);
    }
    connect(second_general_checkbox, SIGNAL(toggled(bool)), this, SLOT(setMaxHpSchemeBox()));

    return widget;
}

QWidget *ServerDialog::createMiscTab()
{
    game_start_spinbox = new QSpinBox;
    game_start_spinbox->setRange(0, 10);
    game_start_spinbox->setValue(Config.CountDownSeconds);
    game_start_spinbox->setSuffix(tr(" seconds"));

    nullification_spinbox = new QSpinBox;
    nullification_spinbox->setRange(5, 15);
    nullification_spinbox->setValue(Config.NullificationCountDown);
    nullification_spinbox->setSuffix(tr(" seconds"));

    minimize_dialog_checkbox = new QCheckBox(tr("Minimize the dialog when server runs"));
    minimize_dialog_checkbox->setChecked(Config.EnableMinimizeDialog);

    surrender_at_death_checkbox = new QCheckBox(tr("Surrender at the time of Death"));
    surrender_at_death_checkbox->setChecked(Config.SurrenderAtDeath);

    luck_card_checkbox = new QCheckBox(tr("Enable the luck card"));
    luck_card_checkbox->setChecked(Config.EnableLuckCard);

    QGroupBox *ai_groupbox = new QGroupBox(tr("Artificial intelligence"));
    ai_groupbox->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    QVBoxLayout *layout = new QVBoxLayout;

    ai_enable_checkbox = new QCheckBox(tr("Enable AI"));
    ai_enable_checkbox->setChecked(Config.EnableAI);
    ai_enable_checkbox->setEnabled(false); // Force to enable AI for disabling it causes crashes!!

    ai_delay_spinbox = new QSpinBox;
    ai_delay_spinbox->setMinimum(0);
    ai_delay_spinbox->setMaximum(5000);
    ai_delay_spinbox->setValue(Config.OriginAIDelay);
    ai_delay_spinbox->setSuffix(tr(" millisecond"));

    ai_delay_altered_checkbox = new QCheckBox(tr("Alter AI Delay After Death"));
    ai_delay_altered_checkbox->setChecked(Config.AlterAIDelayAD);

    ai_delay_ad_spinbox = new QSpinBox;
    ai_delay_ad_spinbox->setMinimum(0);
    ai_delay_ad_spinbox->setMaximum(5000);
    ai_delay_ad_spinbox->setValue(Config.AIDelayAD);
    ai_delay_ad_spinbox->setSuffix(tr(" millisecond"));
    ai_delay_ad_spinbox->setEnabled(ai_delay_altered_checkbox->isChecked());
    connect(ai_delay_altered_checkbox, SIGNAL(toggled(bool)), ai_delay_ad_spinbox, SLOT(setEnabled(bool)));

    layout->addWidget(ai_enable_checkbox);
    layout->addLayout(HLay(new QLabel(tr("AI delay")), ai_delay_spinbox));
    layout->addWidget(ai_delay_altered_checkbox);
    layout->addLayout(HLay(new QLabel(tr("AI delay After Death")), ai_delay_ad_spinbox));

    ai_groupbox->setLayout(layout);

    QVBoxLayout *tablayout = new QVBoxLayout;
    tablayout->addLayout(HLay(new QLabel(tr("Game start count down")), game_start_spinbox));
    tablayout->addLayout(HLay(new QLabel(tr("Nullification count down")), nullification_spinbox));
    tablayout->addWidget(minimize_dialog_checkbox);
    tablayout->addWidget(surrender_at_death_checkbox);
    tablayout->addWidget(luck_card_checkbox);
    tablayout->addWidget(ai_groupbox);
    tablayout->addStretch();

    QWidget *widget = new QWidget;
    widget->setLayout(tablayout);
    return widget;
}

void ServerDialog::updateButtonEnablility(QAbstractButton *button)
{
    if (!button) return;
        second_general_checkbox->setEnabled(true);
}

void BanlistDialog::switchTo(int item)
{
    this->item = item;
    list = lists.at(item);
    if (add2nd) add2nd->setVisible((list->objectName() == "Pairs"));
}

BanlistDialog::BanlistDialog(QWidget *parent, bool view)
    : QDialog(parent), add2nd(NULL), card_to_ban(NULL)
{
    setWindowTitle(tr("Select generals that are excluded"));
    setMinimumWidth(455);

    if (ban_list.isEmpty())
        ban_list << "Roles" << "1v1" << "Pairs" << "Cards";
    QVBoxLayout *layout = new QVBoxLayout;

    QTabWidget *tab = new QTabWidget;
    layout->addWidget(tab);
    connect(tab, SIGNAL(currentChanged(int)), this, SLOT(switchTo(int)));

    foreach (QString item, ban_list) {
        QWidget *apage = new QWidget;

        list = new QListWidget;
        list->setObjectName(item);

        if (item == "Pairs") {
            foreach(QString banned, BanPair::getAllBanSet().toList())
                addGeneral(banned);
            foreach(QString banned, BanPair::getSecondBanSet().toList())
                add2ndGeneral(banned);
            foreach(BanPair pair, BanPair::getBanPairSet().toList())
                addPair(pair.first, pair.second);
        } else {
            QStringList banlist = Config.value(QString("Banlist/%1").arg(item)).toStringList();
            foreach(QString name, banlist)
                addGeneral(name);
        }

        lists << list;

        QVBoxLayout *vlay = new QVBoxLayout;
        vlay->addWidget(list);
        if (item == "Cards" && !view) {
            vlay->addWidget(new QLabel(tr("Input card pattern to ban:"), this));
            card_to_ban = new QLineEdit(this);
            vlay->addWidget(card_to_ban);
        }
        apage->setLayout(vlay);

        tab->addTab(apage, Sanguosha->translate(item));
    }

    QPushButton *add = new QPushButton(tr("Add ..."));
    QPushButton *remove = new QPushButton(tr("Remove"));
    if (!view) add2nd = new QPushButton(tr("Add 2nd general ..."));
    QPushButton *ok = new QPushButton(tr("OK"));

    connect(ok, SIGNAL(clicked()), this, SLOT(accept()));
    connect(this, SIGNAL(accepted()), this, SLOT(saveAll()));
    connect(remove, SIGNAL(clicked()), this, SLOT(doRemoveButton()));
    connect(add, SIGNAL(clicked()), this, SLOT(doAddButton()));
    if (!view) connect(add2nd, SIGNAL(clicked()), this, SLOT(doAdd2ndButton()));

    QHBoxLayout *hlayout = new QHBoxLayout;
    hlayout->addStretch();
    if (!view) {
        hlayout->addWidget(add2nd);
        add2nd->hide();
        hlayout->addWidget(add);
        hlayout->addWidget(remove);
        list = lists.first();
    }

    hlayout->addWidget(ok);
    layout->addLayout(hlayout);

    setLayout(layout);

    foreach (QListWidget *alist, lists) {
        if (alist->objectName() == "Pairs" || alist->objectName() == "Cards")
            continue;
        alist->setViewMode(QListView::IconMode);
        alist->setDragDropMode(QListView::NoDragDrop);
        alist->setResizeMode(QListView::Adjust);
    }
}

void BanlistDialog::addGeneral(const QString &name)
{
    if (list->objectName() == "Pairs") {
        if (banned_items["Pairs"].contains(name)) return;
        banned_items["Pairs"].append(name);
        QString text = QString(tr("Banned for all: %1")).arg(Sanguosha->translate(name));
        QListWidgetItem *item = new QListWidgetItem(text);
        item->setData(Qt::UserRole, QVariant::fromValue(name));
        list->addItem(item);
    } else if (list->objectName() == "Cards") {
        if (banned_items["Cards"].contains(name)) return;
        banned_items["Cards"].append(name);
        QListWidgetItem *item = new QListWidgetItem(name);
        item->setData(Qt::UserRole, QVariant::fromValue(name));
        list->addItem(item);
    } else {
        foreach (QString general_name, name.split("+")) {
            if (banned_items[list->objectName()].contains(general_name)) continue;
            banned_items[list->objectName()].append(general_name);
            QIcon icon(G_ROOM_SKIN.getGeneralPixmap(general_name, QSanRoomSkin::S_GENERAL_ICON_SIZE_TINY));
            QString text = Sanguosha->translate(general_name);
            QListWidgetItem *item = new QListWidgetItem(icon, text, list);
            item->setSizeHint(QSize(60, 60));
            item->setData(Qt::UserRole, general_name);
        }
    }
}

void BanlistDialog::add2ndGeneral(const QString &name)
{
    foreach (QString general_name, name.split("+")) {
        if (banned_items["Pairs"].contains("+" + general_name)) continue;
        banned_items["Pairs"].append("+" + general_name);
        QString text = QString(tr("Banned for second general: %1")).arg(Sanguosha->translate(general_name));
        QListWidgetItem *item = new QListWidgetItem(text);
        item->setData(Qt::UserRole, QVariant::fromValue(QString("+%1").arg(general_name)));
        list->addItem(item);
    }
}

void BanlistDialog::addPair(const QString &first, const QString &second)
{
    if (banned_items["Pairs"].contains(QString("%1+%2").arg(first, second))
        || banned_items["Pairs"].contains(QString("%1+%2").arg(second, first))) return;
    banned_items["Pairs"].append(QString("%1+%2").arg(first, second));
    QString trfirst = Sanguosha->translate(first);
    QString trsecond = Sanguosha->translate(second);
    QListWidgetItem *item = new QListWidgetItem(QString("%1 + %2").arg(trfirst, trsecond));
    item->setData(Qt::UserRole, QVariant::fromValue(QString("%1+%2").arg(first, second)));
    list->addItem(item);
}

void BanlistDialog::doAddButton()
{
    if (list->objectName() == "Cards") {
        QString pattern;
        if (card_to_ban) {
            pattern = card_to_ban->text();
            card_to_ban->clear();
        }
        if (!pattern.isEmpty())
            addGeneral(pattern);
    } else {
        FreeChooseDialog *chooser = new FreeChooseDialog(this,
            (list->objectName() == "Pairs") ? FreeChooseDialog::Pair : FreeChooseDialog::Multi);
        connect(chooser, SIGNAL(general_chosen(QString)), this, SLOT(addGeneral(QString)));
        connect(chooser, SIGNAL(pair_chosen(QString, QString)), this, SLOT(addPair(QString, QString)));
        chooser->exec();
    }
}

void BanlistDialog::doAdd2ndButton()
{
    FreeChooseDialog *chooser = new FreeChooseDialog(this, FreeChooseDialog::Multi);
    connect(chooser, SIGNAL(general_chosen(QString)), this, SLOT(add2ndGeneral(QString)));
    chooser->exec();
}

void BanlistDialog::doRemoveButton()
{
    int row = list->currentRow();
    if (row != -1) {
        banned_items[list->objectName()].removeOne(list->item(row)->data(Qt::UserRole).toString());
        delete list->takeItem(row);
    }
}

void BanlistDialog::save()
{
    QSet<QString> banset;

    for (int i = 0; i < list->count(); i++)
        banset << list->item(i)->data(Qt::UserRole).toString();

    QStringList banlist = banset.toList();
    Config.setValue(QString("Banlist/%1").arg(ban_list.at(item)), QVariant::fromValue(banlist));
}

void BanlistDialog::saveAll()
{
    for (int i = 0; i < lists.length(); i++) {
        switchTo(i);
        save();
    }
    BanPair::loadBanPairs();
}

void ServerDialog::edit1v1Banlist()
{
    BanlistDialog *dialog = new BanlistDialog(this);
    dialog->exec();
}

QGroupBox *ServerDialog::createGameModeBox()
{
    QGroupBox *mode_box = new QGroupBox(tr("Game mode"));
    mode_group = new QButtonGroup;

    QObjectList item_list;

    // normal modes
    QMap<QString, QString> modes = Sanguosha->getAvailableModes();
    QMapIterator<QString, QString> itor(modes);
    while (itor.hasNext()) {
        itor.next();

        QRadioButton *button = new QRadioButton(itor.value());
        button->setObjectName(itor.key());
        mode_group->addButton(button);

            item_list << button;

        if (itor.key() == Config.GameMode) {
            button->setChecked(true);
        }
    }

    // ============

    QVBoxLayout *left = new QVBoxLayout;
    QVBoxLayout *right = new QVBoxLayout;

    for (int i = 0; i < item_list.length(); i++) {
        QObject *item = item_list.at(i);

        QVBoxLayout *side = i <= 9 ? left : right; // WARNING: Magic Number

        if (item->isWidgetType()) {
            QWidget *widget = qobject_cast<QWidget *>(item);
            side->addWidget(widget);
        } else {
            QLayout *item_layout = qobject_cast<QLayout *>(item);
            side->addLayout(item_layout);
        }
        if (i == item_list.length() / 2 - 4)
            side->addStretch();
    }

    right->addStretch();

    QHBoxLayout *layout = new QHBoxLayout;
    layout->addLayout(left);
    layout->addLayout(right);

    mode_box->setLayout(layout);

    return mode_box;
}

LevelButton::LevelButton(const QString &text)
	:QRadioButton(text)
{
	this->level = NULL;
}

void LevelButton::setLevelName(const QString &name)
{
	this->name = name;
}

void LevelButton::setGeneralLevel(GeneralLevel *level)
{
	this->level = level;
}

QString LevelButton::getLevelName() const
{
	return this->name;
}

GeneralLevel *LevelButton::getGeneralLevel() const
{
	return this->level;
}

QWidget *ServerDialog::createRankSettingsTab()
{
	this->challenger_button = new OptionButton("image/system/02_rank/unknown.jpg", tr("challenger"));
	this->challenger_button->setIconSize(G_COMMON_LAYOUT.m_chooseGeneralBoxSparseIconSize);
	QVBoxLayout *left_layout = new QVBoxLayout;
	left_layout->addWidget(this->challenger_button);
	left_layout->addStretch();

	this->gatekeeper_button = new OptionButton("image/system/02_rank/unknown.jpg", tr("gatekeeper"));
	this->gatekeeper_button->setIconSize(G_COMMON_LAYOUT.m_chooseGeneralBoxSparseIconSize);
	QVBoxLayout *right_layout = new QVBoxLayout;
	right_layout->addWidget(this->gatekeeper_button);
	right_layout->addStretch();

	QGroupBox *level_group_box = new QGroupBox(tr("general levels"));
	this->level_buttons_layout = new QGridLayout;
	this->parent_button = new QPushButton(tr("parent level"));
	connect(this->parent_button, SIGNAL(clicked()), this, SLOT(onParentLevelButtonClicked()));
	this->sub_button = new QPushButton(tr("sub levels"));
	connect(this->sub_button, SIGNAL(clicked()), this, SLOT(onSubLevelsButtonClicked()));
	QStringList levels = Sanguosha->getGeneralLevels();
	this->updateLevelButtons(levels);
	QHBoxLayout *level_button_layout = new QHBoxLayout;
	level_button_layout->addStretch();
	level_button_layout->addWidget(parent_button);
	level_button_layout->addStretch();
	level_button_layout->addWidget(sub_button);
	level_button_layout->addStretch();
	QVBoxLayout *level_group_layout = new QVBoxLayout;
	level_group_layout->addLayout(this->level_buttons_layout);
	level_group_layout->addLayout(level_button_layout);
	level_group_box->setLayout(level_group_layout);
	QVBoxLayout *mid_layout = new QVBoxLayout;
	mid_layout->addWidget(level_group_box);
	mid_layout->addStretch();

	QHBoxLayout *layout = new QHBoxLayout;
	layout->addLayout(left_layout);
	layout->addLayout(mid_layout);
	layout->addLayout(right_layout);

	QWidget *widget = new QWidget;
	widget->setLayout(layout);
	return widget;
}

void ServerDialog::updateLevelButtons(const QStringList &levels, const QString &current)
{
	if (levels.isEmpty())
		return;
	QString checked = (current == "") ? levels.first() : current;
	while (!this->level_buttons.isEmpty()){
		LevelButton *button = this->level_buttons.first();
		this->level_buttons.removeFirst();
		this->level_buttons_layout->removeWidget(button);
		delete button;
	}
	int row = 0, column = 0;
	for each (QString name in levels)
	{
		LevelButton *button = new LevelButton(Sanguosha->translate(name));
		button->setLevelName(name);
		GeneralLevel *level = Sanguosha->getGeneralLevel(name);
		if (!level){
			delete button;
			continue;
		}
		button->setGeneralLevel(level);
		if (name == checked){
			button->setChecked(true);
			this->current_level_button = button;
		}
		this->level_buttons_layout->addWidget(button, row, column);
		this->level_buttons.append(button);
		connect(button, SIGNAL(clicked()), this, SLOT(onGeneralLevelRatioSelected()));
		column++;
		if (column >= 5){
			column = 0;
			row++;
		}
	}
	GeneralLevel *level = this->current_level_button->getGeneralLevel();
	this->parent_button->setEnabled(level->getParentLevel() != "");
	this->sub_button->setEnabled(!level->getSubLevels().isEmpty());
	this->updateGatekeeper();
}

void ServerDialog::updateGatekeeper()
{
	if (!this->current_level_button)
		return;
	QString name = this->current_level_button->getLevelName();
	GeneralLevel *level = Sanguosha->getGeneralLevel(name);
	if (!level)
		return;
	QStringList gatekeepers = level->getGateKeepers();
	if (gatekeepers.isEmpty()) {
		QString share_level_name = level->getShareGateKeepersLevel();
		GeneralLevel *share_level = Sanguosha->getGeneralLevel(share_level_name);
		if (share_level) {
			gatekeepers = share_level->getGateKeepers();
		}
	}
	if (gatekeepers.isEmpty()){
		this->gatekeeper_button->setIcon(QIcon("image/system/02_rank/unknown.jpg"));
		this->gatekeeper_button->setText(tr("gatekeeper"));
	}
	else{
		QString gatekeeper = gatekeepers.first();
		this->gatekeeper_button->setIcon(QIcon(G_ROOM_SKIN.getGeneralPixmap(gatekeeper, QSanRoomSkin::S_GENERAL_ICON_SIZE_CARD)));
		this->gatekeeper_button->setText(Sanguosha->translate(gatekeeper));
	}
}

void ServerDialog::onGeneralLevelRatioSelected()
{
	LevelButton *button = (LevelButton *)(sender());
	if (!button->isChecked())
		return;
	if (this->current_level_button == button)
		return;
	this->current_level_button = button;
	GeneralLevel *level = this->current_level_button->getGeneralLevel();
	this->parent_button->setEnabled(level->getParentLevel() != "");
	this->sub_button->setEnabled(!level->getSubLevels().isEmpty());
	this->updateGatekeeper();
}

void ServerDialog::onParentLevelButtonClicked()
{
	if (!this->current_level_button)
		return;
	GeneralLevel *level = this->current_level_button->getGeneralLevel();
	QString parent_name = level->getParentLevel();
	GeneralLevel *parent = Sanguosha->getGeneralLevel(parent_name);
	if (!parent)
		return;
	QStringList super_levels = Sanguosha->getGeneralLevels(parent->getParentLevel());
	this->updateLevelButtons(super_levels, parent_name);
}

void ServerDialog::onSubLevelsButtonClicked()
{
	if (!this->current_level_button)
		return;
	GeneralLevel *level = this->current_level_button->getGeneralLevel();
	QStringList sub_levels = level->getSubLevels();
	if (sub_levels.isEmpty())
		return;
	this->updateLevelButtons(sub_levels);
}

QLayout *ServerDialog::createButtonLayout()
{
    QHBoxLayout *button_layout = new QHBoxLayout;
    button_layout->addStretch();

    QPushButton *console_button = new QPushButton(tr("PC Console Start"));
    QPushButton *server_button = new QPushButton(tr("Start Server"));
    QPushButton *cancel_button = new QPushButton(tr("Cancel"));

    button_layout->addWidget(console_button);
    button_layout->addWidget(server_button);
    button_layout->addWidget(cancel_button);

    connect(console_button, SIGNAL(clicked()), this, SLOT(onConsoleButtonClicked()));
    connect(server_button, SIGNAL(clicked()), this, SLOT(onServerButtonClicked()));
    connect(cancel_button, SIGNAL(clicked()), this, SLOT(reject()));

    return button_layout;
}

void ServerDialog::onDetectButtonClicked()
{
    QHostInfo vHostInfo = QHostInfo::fromName(QHostInfo::localHostName());
    QList<QHostAddress> vAddressList = vHostInfo.addresses();
    foreach (QHostAddress address, vAddressList) {
        if (!address.isNull() && address != QHostAddress::LocalHost
            && address.protocol() == QAbstractSocket::IPv4Protocol) {
            address_edit->setText(address.toString());
            return;
        }
    }
}

void ServerDialog::onConsoleButtonClicked()
{
    accept_type = -1;
    accept();
}

void ServerDialog::onServerButtonClicked()
{
    accept_type = 1;
    accept();
}

int ServerDialog::config()
{
    exec();

    if (result() != Accepted)
        return 0;

    Config.ServerName = server_name_edit->text();
    Config.OperationTimeout = timeout_spinbox->value();
    Config.OperationNoLimit = nolimit_checkbox->isChecked();
    Config.RandomSeat = random_seat_checkbox->isChecked();
    Config.EnableCheat = enable_cheat_checkbox->isChecked();
    Config.FreeChoose = Config.EnableCheat && free_choose_checkbox->isChecked();
    Config.FreeAssignSelf = Config.EnableCheat && free_assign_self_checkbox->isChecked() && free_assign_checkbox->isEnabled();
    Config.ForbidSIMC = forbid_same_ip_checkbox->isChecked();
    Config.DisableChat = disable_chat_checkbox->isChecked();
    Config.Enable2ndGeneral = second_general_checkbox->isChecked();
    Config.MaxHpScheme = max_hp_scheme_ComboBox->currentIndex();
    if (Config.MaxHpScheme == 0) {
        Config.Scheme0Subtraction = scheme0_subtraction_spinbox->value();
        Config.PreventAwakenBelow3 = false;
    } else {
        Config.Scheme0Subtraction = 3;
        Config.PreventAwakenBelow3 = prevent_awaken_below3_checkbox->isChecked();
    }
    Config.Address = address_edit->text();
    Config.CountDownSeconds = game_start_spinbox->value();
    Config.NullificationCountDown = nullification_spinbox->value();
    Config.EnableMinimizeDialog = minimize_dialog_checkbox->isChecked();
    Config.EnableAI = ai_enable_checkbox->isChecked();
    Config.OriginAIDelay = ai_delay_spinbox->value();
    Config.AIDelay = Config.OriginAIDelay;
    Config.AIDelayAD = ai_delay_ad_spinbox->value();
    Config.AlterAIDelayAD = ai_delay_altered_checkbox->isChecked();
    Config.ServerPort = port_edit->text().toInt();
    Config.DisableLua = disable_lua_checkbox->isChecked();
    Config.SurrenderAtDeath = surrender_at_death_checkbox->isChecked();
    Config.EnableLuckCard = luck_card_checkbox->isChecked();

    // game mode
    if (mode_group->checkedButton()) {
        QString objname = mode_group->checkedButton()->objectName();
        if (objname == "scenario")
            Config.GameMode = scenario_ComboBox->itemData(scenario_ComboBox->currentIndex()).toString();
        else
            Config.GameMode = objname;
    }

    Config.setValue("ServerName", Config.ServerName);
    Config.setValue("GameMode", Config.GameMode);
    Config.setValue("OperationTimeout", Config.OperationTimeout);
    Config.setValue("OperationNoLimit", Config.OperationNoLimit);
    Config.setValue("RandomSeat", Config.RandomSeat);
    Config.setValue("EnableCheat", Config.EnableCheat);
    Config.setValue("FreeChoose", Config.FreeChoose);
    Config.setValue("FreeAssign", Config.EnableCheat && free_assign_checkbox->isChecked());
    Config.setValue("FreeAssignSelf", Config.FreeAssignSelf);
    Config.setValue("PileSwappingLimitation", pile_swapping_spinbox->value());
    Config.setValue("MaxChoice", maxchoice_spinbox->value());
    Config.setValue("ForbidSIMC", Config.ForbidSIMC);
    Config.setValue("DisableChat", Config.DisableChat);
    Config.setValue("Enable2ndGeneral", Config.Enable2ndGeneral);
    Config.setValue("MaxHpScheme", Config.MaxHpScheme);
    Config.setValue("Scheme0Subtraction", Config.Scheme0Subtraction);
    Config.setValue("PreventAwakenBelow3", Config.PreventAwakenBelow3);
    Config.setValue("CountDownSeconds", game_start_spinbox->value());
    Config.setValue("NullificationCountDown", nullification_spinbox->value());
    Config.setValue("EnableMinimizeDialog", Config.EnableMinimizeDialog);
    Config.setValue("EnableAI", Config.EnableAI);
    Config.setValue("OriginAIDelay", Config.OriginAIDelay);
    Config.setValue("AlterAIDelayAD", ai_delay_altered_checkbox->isChecked());
    Config.setValue("AIDelayAD", Config.AIDelayAD);
    Config.setValue("SurrenderAtDeath", Config.SurrenderAtDeath);
    Config.setValue("EnableLuckCard", Config.EnableLuckCard);
    Config.setValue("ServerPort", Config.ServerPort);
    Config.setValue("Address", Config.Address);
    Config.setValue("DisableLua", disable_lua_checkbox->isChecked());

    QSet<QString> ban_packages;
    QList<QAbstractButton *> checkboxes = extension_group->buttons();
    foreach (QAbstractButton *checkbox, checkboxes) {
        if (!checkbox->isChecked()) {
            QString package_name = checkbox->objectName();
            Sanguosha->addBanPackage(package_name);
            ban_packages.insert(package_name);
        }
    }

    Config.BanPackages = ban_packages.toList();
    Config.setValue("BanPackages", Config.BanPackages);

    return accept_type;
}

Server::Server(QObject *parent)
    : QObject(parent), created_successfully(true)
{
    server = new NativeServerSocket;
    server->setParent(this);

    //synchronize ServerInfo on the server side to avoid ambiguous usage of Config and ServerInfo
    ServerInfo.parse(Sanguosha->getSetupString());

    current = NULL;
    if (!createNewRoom()) created_successfully = false;

    connect(server, SIGNAL(new_connection(ClientSocket *)), this, SLOT(processNewConnection(ClientSocket *)));
}

void Server::broadcast(const QString &msg)
{
    QString to_sent = msg.toUtf8().toBase64();
    JsonArray arg;
    arg << "." << to_sent;

    Packet packet(S_SRC_ROOM | S_TYPE_NOTIFICATION | S_DEST_CLIENT, S_COMMAND_SPEAK);
    packet.setMessageBody(arg);
    foreach(Room *room, rooms)
        room->broadcastInvoke(&packet);
}

bool Server::listen()
{
    return created_successfully && server->listen();
}

void Server::daemonize()
{
    server->daemonize();
}

Room *Server::createNewRoom()
{
    Room *new_room = new Room(this, Config.GameMode);
    if (!new_room->getLuaState()) {
        delete new_room;
        return NULL;
    }
    current = new_room;
    rooms.insert(current);

    connect(current, SIGNAL(room_message(QString)), this, SIGNAL(server_message(QString)));
    connect(current, SIGNAL(game_over(QString)), this, SLOT(gameOver()));

    return current;
}

void Server::processNewConnection(ClientSocket *socket)
{
    QString addr = socket->peerAddress();
    if (Config.ForbidSIMC) {
        if (addresses.contains(addr)) {
            socket->disconnectFromHost();
            emit server_message(tr("Forbid the connection of address %1").arg(addr));
            return;
        } else
            addresses.insert(addr);
    }

    if (Config.value("BannedIP").toStringList().contains(addr)) {
        socket->disconnectFromHost();
        emit server_message(tr("Forbid the connection of address %1").arg(addr));
        return;
    }


    connect(socket, SIGNAL(disconnected()), this, SLOT(cleanup()));
    Packet packet(S_SRC_ROOM | S_TYPE_NOTIFICATION | S_DEST_CLIENT, S_COMMAND_CHECK_VERSION);
    packet.setMessageBody((Sanguosha->getVersion()));
    socket->send((packet.toString()));

    Packet packet2(S_SRC_ROOM | S_TYPE_NOTIFICATION | S_DEST_CLIENT, S_COMMAND_SETUP);
    packet2.setMessageBody((Sanguosha->getSetupString()));
    socket->send((packet2.toString()));

    emit server_message(tr("%1 connected").arg(socket->peerName()));

    connect(socket, SIGNAL(message_got(const char *)), this, SLOT(processRequest(const char *)));
}

void Server::processRequest(const char *request)
{
    ClientSocket *socket = qobject_cast<ClientSocket *>(sender());
    socket->disconnect(this, SLOT(processRequest(const char *)));

    Packet signup;
    if (!signup.parse(request) || signup.getCommandType() != S_COMMAND_SIGNUP) {
        emit server_message(tr("Invalid signup string: %1").arg(request));
        QSanProtocol::Packet packet(S_SRC_ROOM | S_TYPE_NOTIFICATION | S_DEST_CLIENT, S_COMMAND_WARN);
        packet.setMessageBody("INVALID_FORMAT");
        socket->send(packet.toString());
        socket->disconnectFromHost();
        return;
    }

    const JsonArray &body = signup.getMessageBody().value<JsonArray>();
    bool reconnection_enabled = body[0].toBool();
    QString screen_name = body[1].toString();
    QString avatar = body[2].toString();

    if (reconnection_enabled) {
        foreach (QString objname, name2objname.values(screen_name)) {
            ServerPlayer *player = players.value(objname);
            if (player && player->getState() == "offline" && !player->getRoom()->isFinished()) {
                player->getRoom()->reconnect(player, socket);
                return;
            }
        }
    }

    if (current == NULL || current->isFull() || current->isFinished()) {
        if (!createNewRoom()) return;
    }

    ServerPlayer *player = current->addSocket(socket);
    current->signup(player, screen_name, avatar, false);
    emit newPlayer(player);
}

void Server::cleanup()
{
    const ClientSocket *socket = qobject_cast<const ClientSocket *>(sender());
    if (Config.ForbidSIMC)
        addresses.remove(socket->peerAddress());
}

void Server::signupPlayer(ServerPlayer *player)
{
    name2objname.insert(player->screenName(), player->objectName());
    players.insert(player->objectName(), player);
}

void Server::gameOver()
{
    Room *room = qobject_cast<Room *>(sender());
    rooms.remove(room);

    foreach(ServerPlayer *player, room->findChildren<ServerPlayer *>())
    {
        name2objname.remove(player->screenName(), player->objectName());
        players.remove(player->objectName());
    }
}
