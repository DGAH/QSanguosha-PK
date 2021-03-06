#include "general.h"
#include "engine.h"
#include "skill.h"
#include "package.h"
#include "client.h"

#include <QSize>
#include <QFile>
#include <QMessageBox>

General::General(Package *package, const QString &name, const QString &kingdom,
    int max_hp, bool male, bool hidden, bool never_shown)
    : QObject(package), kingdom(kingdom), max_hp(max_hp), gender(male ? Male : Female),
	hidden(hidden), never_shown(never_shown), crowded(false), order(0), real_name(name)
{
    setObjectName(name);
}

General::General(const QString &name, const QString &kingdom, int max_hp, bool male, bool hidden, bool never_shown)
	:QObject(NULL), kingdom(kingdom), max_hp(max_hp), gender(male ? Male : Female), 
	hidden(hidden), never_shown(never_shown), crowded(false), order(0), real_name(name)
{
	setObjectName(name);
}

int General::getMaxHp() const
{
    return max_hp;
}

QString General::getKingdom() const
{
    return kingdom;
}

bool General::isMale() const
{
    return gender == Male;
}

bool General::isFemale() const
{
    return gender == Female;
}

bool General::isNeuter() const
{
    return gender == Neuter;
}

void General::setGender(Gender gender)
{
    this->gender = gender;
}

General::Gender General::getGender() const
{
    return gender;
}

bool General::isHidden() const
{
    return hidden;
}

bool General::isTotallyHidden() const
{
    return never_shown;
}

bool General::isCrowded() const
{
	return this->crowded;
}

void General::setCrowded(bool flag)
{
	this->crowded = flag;
}

int General::getOrder() const
{
	return order;
}

void General::setOrder(int order)
{
	this->order = order;
}

QString General::getRealName() const
{
	return this->real_name;
}

void General::setRealName(const QString &name)
{
	this->real_name = name;
}

bool General::isGeneral(const QString &name) const
{
	return this->real_name == name;
}

QString General::getResourcePath() const
{
	return this->resource;
}

void General::setResourcePath(const QString &path)
{
	this->resource = path;
}

void General::addSkill(Skill *skill)
{
    if (!skill) {
        QMessageBox::warning(NULL, "", tr("Invalid skill added to general %1").arg(objectName()));
        return;
    }
    if (!skillname_list.contains(skill->objectName())) {
        skill->setParent(this);
        skillname_list << skill->objectName();
    }
}

void General::addSkill(const QString &skill_name)
{
    if (!skillname_list.contains(skill_name)) {
        extra_set.insert(skill_name);
        skillname_list << skill_name;
    }
}

bool General::hasSkill(const QString &skill_name) const
{
    return skillname_list.contains(skill_name);
}

QList<const Skill *> General::getSkillList() const
{
    QList<const Skill *> skills;
    foreach (QString skill_name, skillname_list) {
        if (skill_name == "mashu" && ServerInfo.DuringGame
            && ServerInfo.GameMode.contains("kof") && ServerInfo.GameMode != "03_kof")
            skill_name = "xiaoxi";
        const Skill *skill = Sanguosha->getSkill(skill_name);
        skills << skill;
    }
    return skills;
}

QList<const Skill *> General::getVisibleSkillList() const
{
    QList<const Skill *> skills;
    foreach (const Skill *skill, getSkillList()) {
        if (skill->isVisible())
            skills << skill;
    }

    return skills;
}

QSet<const Skill *> General::getVisibleSkills() const
{
    return getVisibleSkillList().toSet();
}

QSet<const TriggerSkill *> General::getTriggerSkills() const
{
    QSet<const TriggerSkill *> skills;
    foreach (QString skill_name, skillname_list) {
        const TriggerSkill *skill = Sanguosha->getTriggerSkill(skill_name);
        if (skill)
            skills << skill;
    }
    return skills;
}

void General::addRelateSkill(const QString &skill_name)
{
    related_skills << skill_name;
}

QStringList General::getRelatedSkillNames() const
{
    return related_skills;
}

QString General::getPackage() const
{
    QObject *p = parent();
    if (p)
        return p->objectName();
    else
        return QString(); // avoid null pointer exception;
}

QString General::getSkillDescription(bool include_name) const
{
    QString description;

    foreach (const Skill *skill, getVisibleSkillList()) {
        QString skill_name = Sanguosha->translate(skill->objectName());
        QString desc = skill->getDescription();
        desc.replace("\n", "<br/>");
		if (skill->inherits("DummySkill"))
			description.append(QString("<font color=gray><s><b>%1</b></s></font>: %2 <br/> <br/>").arg(skill_name).arg(desc));
		else
			description.append(QString("<b>%1</b>: %2 <br/> <br/>").arg(skill_name).arg(desc));
    }

    if (include_name) {
        QString color_str = Sanguosha->getKingdomColor(kingdom).name();
        QString name = QString("<font color=%1><b>%2</b></font>     ").arg(color_str).arg(Sanguosha->translate(objectName()));
        name.prepend(QString("<img src='image/kingdom/icon/%1.png'/>    ").arg(kingdom));
		if (max_hp > 20)
			name.append(QString("<img src='image/system/magatamas/5.png' height = 12><font color=green><b> %1 %2 </b></font>").arg(tr("X")).arg(QString::number(max_hp)));
		else {
			for (int i = 0; i < max_hp; i++)
				name.append("<img src='image/system/magatamas/5.png' height = 12/>");
		}
        name.append("<br/> <br/>");
        description.prepend(name);
    }

    return description;
}

void General::lastWord() const
{
	QString filename = QString("%1/death.ogg").arg(this->resource);
	if (!QFile::exists(filename)) {
		QString name = objectName();
		filename = QString("audio/death/%1.ogg").arg(name);
		if ((!QFile::exists(filename)) && (real_name != name)) {
			const General *original = Sanguosha->getGeneral(real_name);
			if (original)
				filename = QString("%1/death.ogg").arg(original->getResourcePath());
			if (!QFile::exists(filename))
				filename = QString("audio/death/%1.ogg").arg(real_name);
		}
	}
    Sanguosha->playAudioEffect(filename);
}

