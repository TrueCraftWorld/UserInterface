#include "recomprogloader.h"
#include "dblocale.h"
#include "onyxapp.h"

#include <QMap>
#include <algorithm>
#include <vector>

namespace {

struct RawProg {
	int id = 0;
	int progNum = 0;
	QString name;
	QString subName;
	bool isMain = false;
};

QString parentNameFromSub(const RawProg& sub)
{
	const QString suffix = QStringLiteral(" ") + sub.subName;
	if (!sub.subName.isEmpty() && sub.name.endsWith(suffix, Qt::CaseInsensitive)) {
		return sub.name.left(sub.name.length() - suffix.length()).trimmed();
	}
	return sub.name;
}

QString subProgramSuffix(const QString& parentName, const RawProg& sub)
{
	if (!sub.subName.isEmpty()) {
		return sub.subName;
	}

	const QString prefix = parentName + QLatin1Char(' ');
	if (sub.name.startsWith(prefix, Qt::CaseInsensitive)) {
		return sub.name.mid(prefix.length());
	}

	if (sub.name.startsWith(parentName, Qt::CaseInsensitive)) {
		const QString rest = sub.name.mid(parentName.length()).trimmed();
		if (!rest.isEmpty()) {
			return rest;
		}
	}

	return sub.name;
}

} // namespace

RecomProgLoader::RecomProgLoader(QObject *parent)
    : RecomProgLoader(true, parent)
{}

RecomProgLoader::RecomProgLoader(bool deviceHasArgon, QObject *parent)
    : ProgLoaderBase{deviceHasArgon, parent}
{
	if (m_dbReader.isNull()) {
		OnyxApp* app = dynamic_cast<OnyxApp*>(qApp);
		if (app) {
			m_dbReader = app->getDbReader();
		}
	}
}

std::map<int, QString> RecomProgLoader::getPrograms(int scopeID)
{
	QString queryCondition = "Scope_ID = %1 AND (Argon = 0 OR Argon = %2)";

	QList<QVariantList> progListVariant = m_dbReader->slotSendSelectQuery(QStringList{"Progs"},
	                                                                      QStringList{DbLocale::column("Name"),"id", "Prog_NUM", DbLocale::column("Subprog")},
	                                                                      queryCondition.arg(scopeID).arg(m_deviceHasArgon ? 2 : 1));

	QMap<int, QList<RawProg>> groups;
	for (const auto& item : progListVariant) {
		RawProg prog;
		prog.id = item.at(1).toInt();
		prog.progNum = item.at(2).toInt();
		prog.name = item.at(0).toString();
		prog.subName = item.at(3).toString();
		prog.isMain = prog.progNum % 10 == 0;

		const int groupKey = prog.progNum - (prog.progNum % 10);
		groups[groupKey].append(prog);
	}

	struct DisplayEntry {
		int id = 0;
		QString name;
		QList<QPair<int, QString>> subPrograms;
	};

	std::vector<DisplayEntry> entries;
	entries.reserve(groups.size());

	for (auto groupIt = groups.constBegin(); groupIt != groups.constEnd(); ++groupIt) {
		const QList<RawProg>& members = groupIt.value();
		const RawProg* mainEntry = nullptr;
		QList<RawProg> subEntries;
		subEntries.reserve(members.size());

		for (const RawProg& member : members) {
			if (member.isMain) {
				mainEntry = &member;
			} else {
				subEntries.append(member);
			}
		}

		if (!subEntries.isEmpty()) {
			DisplayEntry entry;
			entry.name = mainEntry ? mainEntry->name : parentNameFromSub(subEntries.first());
			entry.id = mainEntry ? mainEntry->id : subEntries.first().id;
			for (const RawProg& sub : subEntries) {
				entry.subPrograms.append(qMakePair(sub.id, subProgramSuffix(entry.name, sub)));
			}
			entries.push_back(entry);
			continue;
		}

		if (mainEntry) {
			DisplayEntry entry;
			entry.id = mainEntry->id;
			entry.name = mainEntry->name;
			entries.push_back(entry);
		}
	}

	std::sort(entries.begin(), entries.end(),
	          [](const DisplayEntry& left, const DisplayEntry& right) {
		          return left.id < right.id;
	          });

	std::map<int, QString> progList;
	m_cachedSubLists.clear();
	m_cachedSubLists.reserve(static_cast<int>(entries.size()));
	for (const DisplayEntry& entry : entries) {
		progList.insert_or_assign(entry.id, entry.name);
		m_cachedSubLists.append(entry.subPrograms);
	}
	return progList;
}

std::map<int, QString> RecomProgLoader::getCategories()
{
	QList<QVariantList> scopeListVariant
	        = m_dbReader->slotSendSelectQuery(QStringList{"Scopes"},
	                                          QStringList{"id", DbLocale::column("Name")},
	                                          "id < 1000");

	std::map<int, QString> scopeList;
	for (const auto& item : scopeListVariant) {
		bool ok;
		int id = item.at(0).toInt(&ok);
		QString name = item.at(1).toString();
		if (!ok) {
			continue;
		}
		scopeList.insert_or_assign(id, name);
	}
	return scopeList;
}
