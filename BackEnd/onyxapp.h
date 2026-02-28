#ifndef ONYXAPP_H
#define ONYXAPP_H

#include <QGuiApplication>
#include <QObject>

class OnyxApp : public QGuiApplication
{
	Q_OBJECT
public:
	OnyxApp();
};

#endif // ONYXAPP_H
