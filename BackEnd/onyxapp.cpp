#include "onyxapp.h"

#include <QFileInfo>
#include <QStyleHints>

namespace {
const QString kEshfDbPath = QStringLiteral("/home/kikorik/FOTEK/eshfDb.db");
}

OnyxApp::OnyxApp(int &argc, char **argv, int flags) :
QGuiApplication(argc, argv, flags)
{
    m_dbReader = QSharedPointer<DataBaseReader>::create(
        kEshfDbPath,
        QStringLiteral("eshfCatalog"),
        true);

    const QFileInfo eshfInfo(kEshfDbPath);
    const QString userProgPath = eshfInfo.absolutePath() + QStringLiteral("/userProg.db");
    m_userProgDbReader = QSharedPointer<DataBaseReader>::create(
        userProgPath,
        QStringLiteral("userProgStore"),
        false);

    // Возвращаем исходные настройки styleHints, как было до отладки
    styleHints()->setMousePressAndHoldInterval(1200);
    styleHints()->setMouseDoubleClickInterval(400);
}

QSharedPointer<DataBaseReader> OnyxApp::getDbReader()
{
    return m_dbReader;
}

QSharedPointer<DataBaseReader> OnyxApp::getUserProgDbReader()
{
    return m_userProgDbReader;
}
