#include "general-level.h"

GeneralLevel::GeneralLevel(const QString &name)
{
	this->setObjectName(name);
}

void GeneralLevel::setParentLevel(const QString &name)
{
	this->parent_level = name;
}

void GeneralLevel::setLastLevel(const QString &name)
{
	this->last_level = name;
}

void GeneralLevel::setNextLevel(const QString &name)
{
	this->next_level = name;
}

void GeneralLevel::setSubLevels(const QStringList &names)
{
	this->m_sub_levels = names;
}

void GeneralLevel::addSubLevel(const QString &name)
{
	this->m_sub_levels.append(name);
}

QString GeneralLevel::getParentLevel() const
{
	return this->parent_level;
}

QString GeneralLevel::getLastLevel() const
{
	return this->last_level;
}

QString GeneralLevel::getNextLevel() const
{
	return this->next_level;
}

QStringList GeneralLevel::getSubLevels() const
{
	return this->m_sub_levels;
}

bool GeneralLevel::isSubLevel(const QString &level) const
{
	return this->m_sub_levels.contains(level);
}

void GeneralLevel::setGateKeepers(const QStringList &generals)
{
	this->m_gatekeepers = generals;
}

void GeneralLevel::addGateKeeper(const QString &general)
{
	this->m_gatekeepers.append(general);
}

QStringList GeneralLevel::getGateKeepers() const
{
	return this->m_gatekeepers;
}

void GeneralLevel::setShareGateKeepersLevel(const QString &level)
{
	this->share_level = level;
}

QString GeneralLevel::getShareGateKeepersLevel() const
{
	return this->share_level;
}

void GeneralLevel::setDescription(const QString &description)
{
	this->m_description = description;
}

QString GeneralLevel::getDescription() const
{
	return this->m_description;
}