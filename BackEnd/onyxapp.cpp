#include "onyxapp.h"

#include <QCoreApplication>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QMessageBox>

OnyxApp::OnyxApp(int &argc, char **argv, int flags) :
    QGuiApplication(argc, argv, flags)
{
    //это деплой под винду - просто база в папке с деплоем
#ifdef Q_OS_WIN
    QString tmp = QCoreApplication::applicationDirPath();
    QFileInfo inf = QFileInfo(QDir(tmp), "eshfDb.db");
    if (inf.exists()) {
        m_dbReader = QSharedPointer<DataBaseReader>::create(inf.absoluteFilePath());
    }
#else
    m_dbReader = QSharedPointer<DataBaseReader>::create("/home/kikorik/FOTEK/eshfDb.db");
#endif

}

QSharedPointer<DataBaseReader> OnyxApp::getDbReader()
{
    return m_dbReader;
}
