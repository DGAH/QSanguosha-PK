#ifndef _GENERAL_LEVEL_H
#define _GENERAL_LEVEL_H

#include <QObject>
#include <QStringList>

class GeneralLevel : public QObject
{
	Q_OBJECT

public:
	explicit GeneralLevel(const QString &name);

	void setParentLevel(const QString &name);
	void setLastLevel(const QString &name);
	void setNextLevel(const QString &name);
	void setSubLevels(const QStringList &names);
	void addSubLevel(const QString &name);
	QString getParentLevel() const;
	QString getLastLevel() const;
	QString getNextLevel() const;
	QStringList getSubLevels() const;
	bool isSubLevel(const QString &level) const;

	void setGateKeepers(const QStringList &generals);
	void addGateKeeper(const QString &general);
	QStringList getGateKeepers() const;
	void setShareGateKeepersLevel(const QString &level);
	QString getShareGateKeepersLevel() const;

	void setDescription(const QString &description);
	QString getDescription() const;

private:
	QString parent_level;
	QString last_level;
	QString next_level;
	QStringList m_sub_levels;
	QStringList m_gatekeepers;
	QString share_level;
	QString m_description;
};

#endif