#ifndef RECOMPROGLOADER_H
#define RECOMPROGLOADER_H

#include "progloaderbase.h"
#include <QList>
#include <QObject>
#include <QPair>

class RecomProgLoader : public ProgLoaderBase
{
	Q_OBJECT
public:
	explicit RecomProgLoader(QObject *parent = nullptr);
	explicit RecomProgLoader(bool deviceHasArgon, QObject *parent = nullptr);

	// ProgLoaderBase interface
public:
	virtual std::map<int, QString> getPrograms(int scopeID) override;
	virtual std::map<int, QString> getCategories() override;
	virtual int type() override {return 0;};
	const QList<QList<QPair<int, QString>>>& cachedSubLists() const { return m_cachedSubLists; }

private:
	QList<QList<QPair<int, QString>>> m_cachedSubLists;
};

#endif // RECOMPROGLOADER_H
