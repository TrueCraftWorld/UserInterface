#ifndef ONYXAPP_H
#define ONYXAPP_H

#include <QGuiApplication>
#include <QObject>
#include <QSharedPointer>

#include "databasereader.h"

class OnyxApp : public QGuiApplication
{
	Q_OBJECT
public:
	OnyxApp(int &argc, char **argv, int flags = ApplicationFlags);
	QSharedPointer<DataBaseReader> getDbReader();
private:
	QSharedPointer<DataBaseReader> m_dbReader;
};

#endif // ONYXAPP_H
