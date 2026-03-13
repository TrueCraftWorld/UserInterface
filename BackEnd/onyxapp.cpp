#include "onyxapp.h"
#include <QStyleHints>

OnyxApp::OnyxApp(int &argc, char **argv, int flags) :
    QGuiApplication(argc, argv, flags)
{
    m_dbReader = QSharedPointer<DataBaseReader>::create("/home/kikorik/FOTEK/eshfDb.db");
    
    styleHints()->setMousePressAndHoldInterval(1200);
    styleHints()->setMouseDoubleClickInterval(400);
}

QSharedPointer<DataBaseReader> OnyxApp::getDbReader()
{
    return m_dbReader;
}
