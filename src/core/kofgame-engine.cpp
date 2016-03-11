#include "kofgame-engine.h"
#include <QRegExp>
#include "engine.h"

KOFGameEngine *GameEX = NULL;

//****************KOFGameTeamLevel****************//

KOFGameTeamLevel::KOFGameTeamLevel(const QString &name, bool is_boss)
    :QObject(), boss(is_boss)
{
	setObjectName(name);
}

bool KOFGameTeamLevel::isBossLevel() const
{
	return this->boss;
}

//****************KOFGameTeam****************//

KOFGameTeam::KOFGameTeam(const QString &name, const QString &level)
    : QObject(), level(level), fix(false)
{
	setObjectName(name);
}

QString KOFGameTeam::getTeamLevel() const
{
	return this->level;
}

bool KOFGameTeam::isBossTeam() const
{
	KOFGameTeamLevel *team_level = GameEX->getTeamLevel(this->level);
	if (team_level)
		return team_level->isBossLevel();
	return false;
}

void KOFGameTeam::addGeneral(const QString &general)
{
	this->generals.append(general);
}

QStringList KOFGameTeam::getGenerals(bool certain) const
{
	if (!certain)
		return this->generals;

	QStringList names;
	foreach(QString format, this->generals) {
		if (!format.startsWith('?')) {
			names.append(format);
			continue;
		}
		QStringList candidates;
		QRegExp exp;
		exp.setCaseSensitivity(Qt::CaseInsensitive);
		exp.setMinimal(true);
		exp.setPattern("<kingdom=(.*)>");
		if (exp.indexIn(format) >= 0) {
			QString kingdom = exp.capturedTexts().at(1);
			candidates = Sanguosha->getRandomGenerals(-1, QSet<QString>(), kingdom);
		}
		else {
			candidates = Sanguosha->getRandomGenerals();
		}
		bool boss = false;
		General::Gender gender = General::Male;
		exp.setPattern("<boss=(.*)>");
		if (exp.indexIn(format) >= 0) {
			QString flag = exp.capturedTexts().at(1);
			boss = ((flag == "yes") || (flag == "true"));
		}
		exp.setPattern("<male=(.*)>");
		if (exp.indexIn(format) >= 0) {
			QString flag = exp.capturedTexts().at(1);
			bool male = ((flag == "yes") || (flag == "true"));
			gender = male ? General::Male : General::Female;
		}
		else{
			exp.setPattern("<female=(.*)>");
			if (exp.indexIn(format) >= 0) {
				QString flag = exp.capturedTexts().at(1);
				bool female = ((flag == "yes") || (flag == "true"));
				gender = female ? General::Female : General::Male;
			}
		}
		QStringList can_select;
		foreach(QString name, candidates) {
			if (boss != GameEX->isBossGeneral(name))
				continue;
			const General *general = Sanguosha->getGeneral(name);
			if (!general)
				continue;
			if (general->getGender() != gender)
				continue;
			can_select.append(name);
		}
		if (can_select.isEmpty())
			continue;
		names.append(can_select.at(qrand() % (can_select.length())));
	}
	return names;
}

void KOFGameTeam::setResourcePath(const QString &path)
{
	this->path = path;
}

QString KOFGameTeam::getResourcePath() const
{
	return this->path;
}

void KOFGameTeam::setOrderFixed(bool flag)
{
	this->fix = flag;
}

bool KOFGameTeam::isOrderFixed() const
{
	return this->fix;
}

QString KOFGameTeam::getDescription() const
{
	QString name = Sanguosha->translate(this->objectName());
	QString role = Sanguosha->translate(this->level);
	QStringList generalnames;
	foreach(QString general, this->generals) {
		if (general.startsWith("?")) {
			QStringList args;
			QRegExp exp;
			exp.setCaseSensitivity(Qt::CaseInsensitive);
			exp.setMinimal(true);
			exp.setPattern("<kingdom=(.*)>");
			if (exp.indexIn(general) >= 0){
				QString kingdom = exp.capturedTexts().at(1);
				args << tr("kingdom is %1").arg(Sanguosha->translate(kingdom));
			}
			QString sex;
			exp.setPattern("<male=(.*)>");
			if (exp.indexIn(general) >= 0) {
				QString flag = exp.capturedTexts().at(1);
				bool male = ((flag == "yes") || (flag == "true"));
				sex = male ? "male" : "female";
			}
			else{
				exp.setPattern("<female=(.*)>");
				if (exp.indexIn(general) >= 0) {
					QString flag = exp.capturedTexts().at(1);
					bool female = ((flag == "yes") || (flag == "true"));
					sex = female ? "female" : "male";
				}
			}
			if (!sex.isEmpty()) {
				args << tr("sex is %1").arg(Sanguosha->translate(sex));
			}
			exp.setPattern("<boss=(.*)>");
			if (exp.indexIn(general) >= 0) {
				QString flag = exp.capturedTexts().at(1);
				bool boss = ((flag == "yes") || (flag == "true"));
				if (boss)
					args << tr("role is a boss");
				else
					args << tr("role is not a boss");
			}
			if (args.isEmpty())
				generalnames.append(tr("another general ."));
			else
				generalnames.append(tr("a general whose %1 .").arg(args.join(tr(" and "))));
		}
		else {
			generalnames.append(Sanguosha->translate(general));
		}
	}
	QString description;
	description.append(QString("<font color=blue><b>%1</b></font>:<br/><br/>").arg(name));
	description.append(QString("<b>%1</b>:%2<br/><br/>").arg(tr("team level")).arg(role));
	description.append(QString("<b>%1</b>:%2<br/>").arg(tr("members")).arg(generalnames.join(",")));
	return description;
}

bool KOFGameTeam::hasUncertainGeneral() const
{
	foreach(QString general, this->generals) {
		if (general.startsWith("?"))
			return true;
	}
	return false;
}

//****************KOFGameStage****************//

KOFGameStage::KOFGameStage(int stage, bool is_boss, bool is_special)
    : QObject(), stage(stage), boss(is_boss), special(is_special)
{
	if (stage > 0)
		setObjectName(QString("Stage - %1").arg(QString::number(stage)));
}

void KOFGameStage::setStage(int stage)
{
	if (this->stage > 0 || stage <= 0)
		return;

	this->stage = stage;
	setObjectName(QString("Stage - %1").arg(QString::number(stage)));
}

int KOFGameStage::getStage() const
{
	return this->stage;
}

bool KOFGameStage::isBossStage() const
{
	return this->boss;
}

bool KOFGameStage::isSpecialStage() const
{
	return this->special;
}

void KOFGameStage::addTeamLevel(const QString &level)
{
	this->levels.append(level);
}

QStringList KOFGameStage::getTeamLevels() const
{
	return this->levels;
}

bool KOFGameStage::containsLevel(const QString &level) const
{
	return this->levels.contains(level);
}

//****************KOFGameEngine****************//

KOFGameEngine::KOFGameEngine()
:QObject(), start_stage(1), final_stage(1), can_select_boss_team(false), record_free_choose_result(true), time_limit(false), 
striker_mode(false), striker_count(5), default_striker_skill("gedang"), 
critical_mode(false), default_critical_rate(20), fight_boss(true), evolution_mode(false), send_server_log(false)
{
	GameEX = this;
	
	this->free_choose_team = new KOFGameTeam("_FreeChooseTeam", "");
	for (int i = 1; i <= 5; i++) {
		this->free_choose_team->addGeneral("?");
	}
	this->free_choose_team->setResourcePath("image/system/06_teams");
	this->free_choose_team->setParent(this);
	this->teams.insert(this->free_choose_team->objectName(), this->free_choose_team);
}

KOFGameEngine::~KOFGameEngine()
{
}

void KOFGameEngine::addTeamLevel(KOFGameTeamLevel *level)
{
	if (this->level_names.contains(level->objectName()))
		return;

	this->level_names.append(level->objectName());
	this->team_levels.insert(level->objectName(), level);
}

KOFGameTeamLevel *KOFGameEngine::getTeamLevel(const QString &level) const
{
	return this->team_levels.value(level, NULL);
}

QStringList KOFGameEngine::getAllLevelNames(bool include_boss) const
{
	QStringList result;
	foreach(QString name, this->level_names) {
		KOFGameTeamLevel *level = this->getTeamLevel(name);
		if (!level)
			continue;
		if (level->isBossLevel() && !include_boss)
			continue;
		result << name;
	}
	return result;
}

QList<KOFGameTeamLevel *> KOFGameEngine::getAllLevels(bool include_boss) const
{
	QList<KOFGameTeamLevel *> result;
	foreach(QString name, this->level_names) {
		KOFGameTeamLevel *level = this->getTeamLevel(name);
		if (!level)
			continue;
		if (level->isBossLevel() && !include_boss)
			continue;
		result << level;
	}
	return result;
}

void KOFGameEngine::addTeam(KOFGameTeam *team)
{
	if (this->team_names.contains(team->objectName()))
		return;

	this->team_names.append(team->objectName());
	this->teams.insert(team->objectName(), team);

	if (team->isBossTeam()) {
		QStringList bosses = team->getGenerals();
		foreach(QString boss, bosses) {
			if (!this->boss_generals.contains(boss))
				this->boss_generals.append(boss);
		}
	}
}

KOFGameTeam *KOFGameEngine::getTeam(const QString &team) const
{
	return this->teams.value(team, NULL);
}

QStringList KOFGameEngine::getAllTeamNames(const QString &level) const
{
	bool flag = !level.isEmpty();

	QStringList result;
	foreach(QString name, this->team_names) {
		KOFGameTeam *team = this->getTeam(name);
		if (!team)
			continue;
		if (flag && team->getTeamLevel() != level)
			continue;
		result << name;
	}
	return result;
}

QList<KOFGameTeam *> KOFGameEngine::getAllTeams(const QString &level) const
{
	bool flag = !level.isEmpty();

	QList<KOFGameTeam *> result;
	foreach(QString name, this->team_names) {
		KOFGameTeam *team = this->getTeam(name);
		if (!team)
			continue;
		if (flag && team->getTeamLevel() != level)
			continue;
		result << team;
	}
	return result;
}

KOFGameTeam *KOFGameEngine::getFreeChooseTeam() const
{
	return this->free_choose_team;
}

void KOFGameEngine::addStage(KOFGameStage *stage)
{
	this->stages.append(stage);
	stage->setStage(this->stages.length());
}

KOFGameStage *KOFGameEngine::getStage(int stage) const
{
	if (stage < 0)
		return NULL;

	if (stage >= this->stages.length())
		return NULL;
	
	return this->stages.at(stage - 1);
}

bool KOFGameEngine::isBossGeneral(const QString &general) const
{
	return this->boss_generals.contains(general);
}

void KOFGameEngine::setStartStage(int stage)
{
	if (stage < 1)
		return;

	if (stage >= this->stages.length())
		return;
	
	this->start_stage = stage - 1;
}

int KOFGameEngine::getStartStage() const
{
	return this->start_stage;
}

void KOFGameEngine::setFinalStage(int stage)
{
	if (stage < 1)
		return;

	if (stage >= this->stages.length())
		return;
	
	this->final_stage = stage;
}

int KOFGameEngine::getFinalStage() const
{
	return this->final_stage;
}

void KOFGameEngine::setBossTeamEnabled(bool flag)
{
	this->can_select_boss_team = flag;
}

bool KOFGameEngine::canSelectBossTeam() const
{
	return this->can_select_boss_team;
}

void KOFGameEngine::setRecordChooseResult(bool flag)
{
	this->record_free_choose_result = flag;
}

bool KOFGameEngine::recordFreeChooseResult() const
{
	return this->record_free_choose_result;
}

void KOFGameEngine::setTimeLimit(bool flag)
{
	this->time_limit = flag;
}

bool KOFGameEngine::isTimeLimited() const
{
	return this->time_limit;
}

void KOFGameEngine::setStrikerMode(bool open)
{
	this->striker_mode = open;
}

bool KOFGameEngine::useStrikerMode() const
{
	return this->striker_mode;
}

void KOFGameEngine::setStrikerCount(int count)
{
	if (count < 0)
		count = 0;

	this->striker_count = count;
}

int KOFGameEngine::getStrikerCount() const
{
	return this->striker_count;
}

void KOFGameEngine::setStrikerSkill(const QString &skill)
{
	this->default_striker_skill = skill;
}

QString KOFGameEngine::getStrikerSkill() const
{
	return this->default_striker_skill;
}

void KOFGameEngine::setCriticalMode(bool open)
{
	this->critical_mode = open;
}

bool KOFGameEngine::useCriticalMode() const
{
	return this->critical_mode;
}

void KOFGameEngine::setDefaultCriticalRate(int rate)
{
	this->default_critical_rate = rate;
}

int KOFGameEngine::getDefaultCriticalRate() const
{
	return this->default_critical_rate;
}

void KOFGameEngine::setFightBossEnabled(bool flag)
{
	this->fight_boss = flag;
}

bool KOFGameEngine::extraCriticalRateWhenFightBoss() const
{
	return this->fight_boss;
}

void KOFGameEngine::setEvolutionMode(bool open)
{
	this->evolution_mode = open;
}

bool KOFGameEngine::useEvolutionMode() const
{
	return this->critical_mode && this->evolution_mode;
}

void KOFGameEngine::setSendServerLog(bool flag)
{
	this->send_server_log = flag;
}

bool KOFGameEngine::willSendServerLog() const
{
	return this->send_server_log;
}

void KOFGameEngine::addStrikerSkill(const QString &general, const QString &skill)
{
	this->striker_skills.insert(general, skill);
}

QString KOFGameEngine::getStrikerSkill(const QString &general) const
{
	return this->striker_skills.value(general, this->default_striker_skill);
}

void KOFGameEngine::addCriticalRate(const QString &general, int rate)
{
	this->critical_rates.insert(general, rate);
}

int KOFGameEngine::getCriticalRate(const QString &general) const
{
	return this->critical_rates.value(general, this->default_critical_rate);
}
