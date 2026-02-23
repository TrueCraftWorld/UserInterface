#ifndef RECOMPROGLOADER_H
#define RECOMPROGLOADER_H

#include "progloaderbase.h"
#include <QObject>

class RecomProgLoader : public ProgLoaderBase
{
	Q_OBJECT
public:
	explicit RecomProgLoader(QObject *parent = nullptr);

	// ProgLoaderBase interface
public:
	virtual std::map<int, QString> getPrograms(int scopeID) override;
	virtual std::map<int, QString> getCategories() override;
	// virtual void deleteProg(int /*id*/) override { ;};
};

#endif // RECOMPROGLOADER_H
