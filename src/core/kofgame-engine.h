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

private:
	QString level;
	QStringList generals;
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
	void addTeam(KOFGameTeam *team);
	KOFGameTeam *getTeam(const QString &team) const;
	void addStage(KOFGameStage *stage);
	KOFGameStage *getStage(int stage) const;
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

private:
	QHash<QString, KOFGameTeamLevel *> team_levels;
	QHash<QString, KOFGameTeam *> teams;
	QStringList boss_generals;

	QList<KOFGameStage *> stages;
	int start_stage;
	int final_stage;

	bool can_select_boss_team;
	bool record_free_choose_result;
	bool time_limit;

	bool striker_mode;
	int striker_count;
	QString striker_skill;

	bool critical_mode;
	int critical_rate;
	bool fight_boss;

	bool evolution_mode;
	bool send_server_log;
};

extern KOFGameEngine *GameEX;

#endif