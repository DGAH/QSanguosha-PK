#ifndef _KOF_GAME_ENGINE_H
#define _KOF_GAME_ENGINE_H

#include <QStringList>
#include <QHash>

class KOFGameTeamLevel : public QObject
{
	Q_OBJECT

public:
	KOFGameTeamLevel(const QString &name, bool is_boss = false);
	bool isBossLevel() const;

private:
	bool boss;
};

class KOFGameTeam : public QObject
{
	Q_OBJECT

public:
	KOFGameTeam(const QString &name, const QString &level);
	QString getTeamLevel() const;
	bool isBossTeam() const;
	void addGeneral(const QString &general);
	QStringList getGenerals(bool certain = false) const;
	void setResourcePath(const QString &path);
	QString getResourcePath() const;
	void setOrderFixed(bool flag = true);
	bool isOrderFixed() const;
	QString getDescription() const;
	bool hasUncertainGeneral() const;

private:
	QString level;
	QStringList generals;
	QString path;
	bool fix;
};

class KOFGameStage : public QObject
{
	Q_OBJECT

public:
	KOFGameStage(int stage = -1, bool is_boss = false, bool is_special = false);
	void setStage(int stage);
	int getStage() const;
	bool isBossStage() const;
	bool isSpecialStage() const;
	void addTeamLevel(const QString &level);
	QStringList getTeamLevels() const;
	bool containsLevel(const QString &level) const;

private:
	int stage;
	QStringList levels;
	bool boss;
	bool special;
};

class KOFGameEngine : public QObject
{
	Q_OBJECT

public:
	KOFGameEngine();
	~KOFGameEngine();

	void addTeamLevel(KOFGameTeamLevel *level);
	KOFGameTeamLevel *getTeamLevel(const QString &level) const;
	QStringList getAllLevelNames(bool include_boss = true) const;
	QList<KOFGameTeamLevel *> getAllLevels(bool include_boss = true) const;

	void addTeam(KOFGameTeam *team);
	KOFGameTeam *getTeam(const QString &team) const;
	QStringList getAllTeamNames(const QString &level = "") const;
	QList<KOFGameTeam *> getAllTeams(const QString &level = "") const;
	KOFGameTeam *getFreeChooseTeam() const;
	QString getFreeChooseTeamName() const;

	void addStage(KOFGameStage *stage);
	KOFGameStage *getStage(int stage) const;
	int getStageCount() const;

	bool isBossGeneral(const QString &general) const;

	void setStartStage(int stage);
	int getStartStage() const;
	void setFinalStage(int stage);
	int getFinalStage() const;
	void setBossTeamEnabled(bool flag);
	bool canSelectBossTeam() const;
	void setRecordChooseResult(bool flag);
	bool recordFreeChooseResult() const;
	void setTimeLimit(bool flag);
	bool isTimeLimited() const;
	void setStrikerMode(bool open);
	bool useStrikerMode() const;
	void setStrikerCount(int count);
	int getStrikerCount() const;
	void setStrikerSkill(const QString &skill);
	QString getStrikerSkill() const;
	void setCriticalMode(bool open);
	bool useCriticalMode() const;
	void setDefaultCriticalRate(int rate);
	int getDefaultCriticalRate() const;
	void setFightBossEnabled(bool flag);
	bool extraCriticalRateWhenFightBoss() const;
	void setEvolutionMode(bool open);
	bool useEvolutionMode() const;
	void setSendServerLog(bool flag);
	bool willSendServerLog() const;

	void addStrikerSkill(const QString &general, const QString &skill);
	QString getStrikerSkill(const QString &general) const;

	void addCriticalRate(const QString &general, int rate);
	int getCriticalRate(const QString &general) const;

private:
	QStringList level_names;
	QHash<QString, KOFGameTeamLevel *> team_levels;
	QStringList team_names;
	QHash<QString, KOFGameTeam *> teams;
	QStringList boss_generals;
	KOFGameTeam *free_choose_team;

	QList<KOFGameStage *> stages;
	int start_stage;
	int final_stage;

	bool can_select_boss_team;
	bool record_free_choose_result;
	bool time_limit;

	bool striker_mode;
	int striker_count;
	QString default_striker_skill;
	QHash<QString, QString> striker_skills;

	bool critical_mode;
	int default_critical_rate;
	bool fight_boss;
	QHash<QString, int> critical_rates;

	bool evolution_mode;
	bool send_server_log;
};

extern KOFGameEngine *GameEX;

#endif