#ifndef _SERVER_H
#define _SERVER_H

class Room;
class QGroupBox;
class QLabel;
class OptionButton;
class FreeChooseDialog;

#include "socket.h"
#include "detector.h"
#include "clientstruct.h"
#include "general-level.h"
#include "structs.h"

#include <QRadioButton>
#include <QDialog>
#include <QLineEdit>
#include <QSpinBox>
#include <QCheckBox>
#include <QButtonGroup>
#include <QComboBox>
#include <QLayoutItem>
#include <QListWidget>
#include <QSplitter>
#include <QTabWidget>
#include <QMultiHash>
#include <QGridLayout>
#include <QPushButton>

class Package;

class BanlistDialog : public QDialog
{
    Q_OBJECT

public:
    BanlistDialog(QWidget *parent, bool view = false);

private:
    QList<QListWidget *>lists;
    QListWidget *list;
    int item;
    QStringList ban_list;
    QPushButton *add2nd;
    QMap<QString, QStringList> banned_items;
    QLineEdit *card_to_ban;

private slots:
    void addGeneral(const QString &name);
    void add2ndGeneral(const QString &name);
    void addPair(const QString &first, const QString &second);
    void doAdd2ndButton();
    void doAddButton();
    void doRemoveButton();
    void save();
    void saveAll();
    void switchTo(int item);
};

class LevelButton : public QRadioButton
{
	Q_OBJECT

public:
	LevelButton(const QString &text = "");

	void setLevelName(const QString &name);
	void setGeneralLevel(GeneralLevel *level);
	QString getLevelName() const;
	GeneralLevel *getGeneralLevel() const;

private:
	QString name;
	GeneralLevel *level;
};

class ServerDialog : public QDialog
{
    Q_OBJECT

public:
    ServerDialog(QWidget *parent);
    int config();

private:
    QWidget *createBasicTab();
    QWidget *createPackageTab();
    QWidget *createAdvancedTab();
    QWidget *createMiscTab();
    QLayout *createButtonLayout();

    QGroupBox *createGameModeBox();
	QWidget *createRankSettingsTab();
	void updateLevelButtons(const QStringList &levels, const QString &current = "");
	void updateGatekeeperByCurrentLevel();
	void updateGatekeeper(const QString &gatekeeper);
	void updateGuideButtons();

	bool checkRankSettings();

	QTabWidget *tab_widget;
	QWidget *rank_page;
	OptionButton *challenger_button;
	OptionButton *gatekeeper_button;
	LevelButton *current_level_button;
	QList<LevelButton *> level_buttons;
	QGridLayout *level_buttons_layout;
	QPushButton *parent_button;
	QPushButton *sub_button;
	FreeChooseDialog *challenger_choose_dialog;
	QString m_current_challenger;
	QString m_current_gatekeeper;
	QPushButton *last_gatekeeper_button;
	QPushButton *next_gatekeeper_button;

	QSpinBox *total_spinbox;
	QSpinBox *warm_spinbox;
	QSpinBox *cold_spinbox;
	QButtonGroup *order_mode_group;

    QLineEdit *server_name_edit;
    QSpinBox *timeout_spinbox;
    QCheckBox *nolimit_checkbox;
    QCheckBox *random_seat_checkbox;
    QCheckBox *enable_cheat_checkbox;
    QCheckBox *free_choose_checkbox;
    QCheckBox *free_assign_checkbox;
    QCheckBox *free_assign_self_checkbox;
    QLabel *pile_swapping_label;
    QSpinBox *pile_swapping_spinbox;
    QSpinBox *maxchoice_spinbox;
    QCheckBox *forbid_same_ip_checkbox;
    QCheckBox *disable_chat_checkbox;
    QCheckBox *second_general_checkbox;
    QLabel *max_hp_label;
    QComboBox *max_hp_scheme_ComboBox;
    QLabel *scheme0_subtraction_label;
    QSpinBox *scheme0_subtraction_spinbox;
    QCheckBox *prevent_awaken_below3_checkbox;
    QComboBox *scenario_ComboBox;
    QLineEdit *address_edit;
    QLineEdit *port_edit;
    QSpinBox *game_start_spinbox;
    QSpinBox *nullification_spinbox;
    QCheckBox *minimize_dialog_checkbox;
    QCheckBox *ai_enable_checkbox;
    QSpinBox *ai_delay_spinbox;
    QCheckBox *ai_delay_altered_checkbox;
    QSpinBox *ai_delay_ad_spinbox;
    QCheckBox *surrender_at_death_checkbox;
    QCheckBox *luck_card_checkbox;
    QComboBox *role_choose_ComboBox;
    QCheckBox *exclude_disaster_checkbox;
    QComboBox *official_1v1_ComboBox;
    QCheckBox *kof_using_extension_checkbox;
    QCheckBox *kof_card_extension_checkbox;
    QCheckBox *disable_lua_checkbox;

    QButtonGroup *extension_group;
    QButtonGroup *mode_group;

    int accept_type; // -1 means console start while 1 means server start

private slots:
    void setMaxHpSchemeBox();

	void onGameModeRadioButtonClicked(int id);
    void onConsoleButtonClicked();
    void onServerButtonClicked();
    void onDetectButtonClicked();
    void edit1v1Banlist();
    void updateButtonEnablility(QAbstractButton *button);

	void onChallengerButtonClicked();
	void onChallengerGeneralChosen(const QString &general);
	void onLastGatekeeperButtonClicked();
	void onNextGatekeeperButtonClicked();
	void onGeneralLevelRatioSelected();
	void onParentLevelButtonClicked();
	void onSubLevelsButtonClicked();
};

class Scenario;
class ServerPlayer;

class Server : public QObject
{
    Q_OBJECT

public:
    explicit Server(QObject *parent);

    friend class BanIpDialog;

    void broadcast(const QString &msg);
    bool listen();
    void daemonize();
    Room *createNewRoom();
    void signupPlayer(ServerPlayer *player);

private:
    ServerSocket *server;
    Room *current;
    QSet<Room *> rooms;
    QHash<QString, ServerPlayer *> players;
    QSet<QString> addresses;
    QMultiHash<QString, QString> name2objname;
    bool created_successfully;

private slots:
    void processNewConnection(ClientSocket *socket);
    void processRequest(const char *request);
    void cleanup();
    void gameOver();

signals:
    void server_message(const QString &);
    void newPlayer(ServerPlayer *player);
};

#endif

