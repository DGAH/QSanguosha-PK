%{

#include "kofgame-engine.h"

%}

class KOFGameTeamLevel : public QObject
{
public:
	KOFGameTeamLevel(const char *name, bool is_boss = false);
	bool isBossLevel() const;
};

class KOFGameTeam : public QObject
{
public:
	KOFGameTeam(const char *name, const char *level);
	QString getTeamLevel() const;
	bool isBossTeam() const;
	void addGeneral(const char *general);
	QStringList getGenerals(bool certain = false) const;
	void setResourcePath(const char *path);
	QString getResourcePath() const;
	void setOrderFixed(bool flag = true);
	bool isOrderFixed() const;
	QString getDescription() const;
	bool hasUncertainGeneral() const;
};

class KOFGameStage : public QObject
{
public:
	KOFGameStage(int stage = -1, bool is_boss = false, bool is_special = false);
	void setStage(int stage);
	int getStage() const;
	bool isBossStage() const;
	bool isSpecialStage() const;
	void addTeamLevel(const char *level);
	QStringList getTeamLevels() const;
	bool containsLevel(const char *level) const;
};

class KOFGameEngine : public QObject
{
public:
	void addTeamLevel(KOFGameTeamLevel *level);
	KOFGameTeamLevel *getTeamLevel(const char *level) const;
	QStringList getAllLevelNames(bool include_boss = true) const;
	QList<KOFGameTeamLevel *> getAllLevels(bool include_boss = true) const;

	void addTeam(KOFGameTeam *team);
	KOFGameTeam *getTeam(const char *team) const;
	QStringList getAllTeamNames(const char *level = "") const;
	QList<KOFGameTeam *> getAllTeams(const char *level = "") const;
	KOFGameTeam *getFreeChooseTeam() const;
	QString getFreeChooseTeamName() const;

	void addStage(KOFGameStage *stage);
	KOFGameStage *getStage(int stage) const;
	int getStageCount() const;

	bool isBossGeneral(const char *general) const;

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
	void setDefaultStrikerSkill(const char *skill);
	QString getDefaultStrikerSkill() const;
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

	void addStrikerSkill(const char *general, const char *skill);
	QString getStrikerSkill(const char *general) const;

	void addCriticalRate(const char *general, int rate);
	int getCriticalRate(const char *general) const;
};

extern KOFGameEngine *GameEX;
