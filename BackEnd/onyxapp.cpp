#include "onyxapp.h"


OnyxApp::OnyxApp(int &argc, char **argv, int flags) :
    QGuiApplication(argc, argv, flags)
{
    m_dbReader = QSharedPointer<DataBaseReader>::create("/home/kikorik/FOTEK/eshfDb.db");

}

QSharedPointer<DataBaseReader> OnyxApp::getDbReader()
{
    return m_dbReader;
}
