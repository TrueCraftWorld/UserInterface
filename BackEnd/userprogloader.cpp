#include "userprogloader.h"
#include "dblocale.h"
#include "onyxapp.h"


UserProgLoader::UserProgLoader(QObject *parent)
    : UserProgLoader(true, parent)
{}

UserProgLoader::UserProgLoader(bool deviceHasArgon, QObject *parent)
    : ProgLoaderBase{deviceHasArgon, parent}
{
    if (m_dbReader.isNull()) {
        OnyxApp* app = dynamic_cast<OnyxApp*>(qApp);
        if (app) {
            m_dbReader = app->getUserProgDbReader();
        }

    }
}


std::map<int, QString> UserProgLoader::getPrograms(int scopeID)
{
    QString queryCondition = "Scope_ID = %1 AND (Argon = 0 OR Argon = %2)";

    QList<QVariantList> progListVariant = m_dbReader->slotSendSelectQuery(QStringList{"Progs"},
                                                                        QStringList{DbLocale::column("Name"),"id", "Prog_NUM", DbLocale::column("Subprog")},
                                                                        queryCondition.arg(scopeID).arg(m_deviceHasArgon ? 2 : 1));

    std::map<int, QString> progList;
    for (const auto& item : progListVariant) {
        const bool isMainProg = item.at(2).toInt() % 10 == 0;
        if (!isMainProg) {
            continue;
        }
        int id = item.at(1).toInt();
        QString name = item.at(0).toString();
        progList.insert_or_assign(id, name);
    }
    return progList;
}

std::map<int, QString> UserProgLoader::getCategories()
{
    QList<QVariantList> scopeListVariant
                = m_dbReader->slotSendSelectQuery(QStringList{"Scopes"},
                                                     QStringList{"id", DbLocale::column("Name")},
                                                     "id > 1000");

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

// void UserProgLoader::deleteProg(int id)
// {
// }
