#ifndef USERPROGLOADER_H
#define USERPROGLOADER_H

#include "progloaderbase.h"
#include <QObject>

class UserProgLoader : public ProgLoaderBase
{
	Q_OBJECT
public:
	explicit UserProgLoader(QObject *parent = nullptr);

	// ProgLoaderBase interface
public:
	virtual std::map<int, QString> getPrograms(int scopeID) override;
	virtual std::map<int, QString> getCategories() override;
	virtual int type() override {return 1;};
	// virtual void deleteProg(int id) override;
};

#endif // USERPROGLOADER_H
