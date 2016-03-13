#ifndef _ARRANGE_TEAM_DIALOG_H
#define _ARRANGE_TEAM_DIALOG_H

#include <QDialog>
#include <QStringList>
#include <QButtonGroup>

class OptionButton;

class ArrangeTeamDialog : public QDialog
{
	Q_OBJECT

public:
	ArrangeTeamDialog(int max_count, const QStringList &generals);

protected:
	void initScene();
	void swapButtons(OptionButton *a, OptionButton *b);
	bool updateButtonSelectState(OptionButton *current);
	void updateTeamGeneralsState();

private:
	int arrange_count;
	QStringList generals;
	bool striker_mode;
	QButtonGroup *general_button_group;
	QButtonGroup *arrange_button_group;
	OptionButton *striker_button;
	QPushButton *ok_button;
	OptionButton *selected_button;

signals:
	void team_arranged(QStringList generals, QString striker);

public slots:
	void whenGeneralButtonClicked();
	void onBtnOK();
	void onBtnCancel();
};

#endif