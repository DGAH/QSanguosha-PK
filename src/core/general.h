#ifndef _GENERAL_H
#define _GENERAL_H

class Skill;
class TriggerSkill;
class Package;
class QSize;

#include <QObject>
#include <QSet>
#include <QMap>
#include <QStringList>

class General : public QObject
{
    Q_OBJECT
    Q_ENUMS(Gender)
    Q_PROPERTY(QString kingdom READ getKingdom CONSTANT)
    Q_PROPERTY(int maxhp READ getMaxHp CONSTANT)
    Q_PROPERTY(bool male READ isMale STORED false CONSTANT)
    Q_PROPERTY(bool female READ isFemale STORED false CONSTANT)
    Q_PROPERTY(Gender gender READ getGender CONSTANT)
    Q_PROPERTY(bool hidden READ isHidden CONSTANT)
	Q_PROPERTY(int order READ getOrder CONSTANT)

public:
    explicit General(Package *package, const QString &name, const QString &kingdom,
        int max_hp = 4, bool male = true, bool hidden = false, bool never_shown = false);
	explicit General(const QString &name, const QString &kingdom, int max_hp = 4, bool male = true, bool hidden = false, bool never_shown = false);

    // property getters/setters
    int getMaxHp() const;
    QString getKingdom() const;
    bool isMale() const;
    bool isFemale() const;
    bool isNeuter() const;
    bool isHidden() const;
    bool isTotallyHidden() const;

    enum Gender
    {
        Sexless, Male, Female, Neuter
    };
    Gender getGender() const;
    void setGender(Gender gender);
	int getOrder() const;
	void setOrder(int order);
	QString getRealName() const;
	void setRealName(const QString &name);
	QString getResourcePath() const;
	void setResourcePath(const QString &path);

    void addSkill(Skill *skill);
    void addSkill(const QString &skill_name);
    bool hasSkill(const QString &skill_name) const;
    QList<const Skill *> getSkillList() const;
    QList<const Skill *> getVisibleSkillList() const;
    QSet<const Skill *> getVisibleSkills() const;
    QSet<const TriggerSkill *> getTriggerSkills() const;

    void addRelateSkill(const QString &skill_name);
    QStringList getRelatedSkillNames() const;

    QString getPackage() const;
    QString getSkillDescription(bool include_name = false) const;

    inline QSet<QString> getExtraSkillSet() const
    {
        return extra_set;
    }

public slots:
    void lastWord() const;

private:
	QString real_name;
    QString kingdom;
    int max_hp;
    Gender gender;
    QSet<QString> extra_set;
    QStringList skillname_list;
    QStringList related_skills;
    bool hidden;
    bool never_shown;
	int order;
	QString resource;
};

#endif

