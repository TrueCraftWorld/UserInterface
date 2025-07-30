#include "controlcenter.h"
#include "socket.h"

#include <map>
#include <QQmlEngine>


ControlCenter::ControlCenter(QObject *parent)
    : QObject{parent},
    m_socketModel(new SocketModel),
    m_editor(new SocketModeEditor(m_socketModel,this))
{
    QQmlEngine::setObjectOwnership(m_socketModel, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_editor, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ControlCenter::~ControlCenter()
{
    if (!m_socketModel.isNull()) {
        m_socketModel->deleteLater();
    }
}

void ControlCenter::registerControl()
{
    qmlRegisterUncreatableType<SocketModel>("BackEnd", 1, 0, "SocketModel", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<SocketModeEditor>("BackEnd", 1, 0, "SocketModeEditor", "should be one and exist not only for qml");
}

QPointer<SocketModel> ControlCenter::getSocketModel() const
{
    return m_socketModel;
}

void ControlCenter::init()
{
    readConfigs();
    initComms();
    initSockets();
    prepareConnectios();
}

QPointer<SocketModeEditor> ControlCenter::editor() const
{
    return m_editor;
}

void ControlCenter::initComms()
{}

void ControlCenter::initSockets()
{
    ///todo read old socket (maybe Json or QSetting)
    // if (readPreviousSocketSettings()) {
    if (true) {
        if (m_dbReader.isNull())
            m_dbReader = new DataBaseReader("/home/kikorik/FOTEK/someShadyDB.db");
        dataBaseSocketInit();
    } else {
        defaultSocketInit();
    }
}

void ControlCenter::readConfigs()
{ }

void ControlCenter::prepareConnectios()
{ }

bool ControlCenter::readPreviousSocketSettings()
{
    ///todo REALIZE
    return false;
}

void ControlCenter::defaultSocketInit()
{
    // QList<QSharedPointer<SOCKET>> socketList;
    // // std::map<int, QSharedPointer<SOCKET>> socketMap;

    // //may change count based on config later
    // //NEED to parallel cause it is on start and it does some nasty sorting
    // for (int i = 0; i < 4; ++i) {
    //     SOCKET::SocType type = SOCKET::SocType(i+1);
    //     // socketMap.emplace(type, QSharedPointer<SOCKET>::create(type));
    //     QSharedPointer<SOCKET> socket = QSharedPointer<SOCKET>::create(i < SOCKET::MONOPOLAR_2 ? SOCKET::SocType(i+1) : SOCKET::EMPTY);

    //     int coagStart = 0;
    //     int cutStart = 0;
    //     int coagStop = 0;
    //     int cutStop = 0;
    //     QString socketName = "";
    //     QHash<QString, QSharedPointer<SurgicalMode>> cutModes;
    //     QHash<QString, QSharedPointer<SurgicalMode>> coagModes;
    //     switch (type) {
    //     case SOCKET::EMPTY:
    //         socketName = QString("EMPTY");
    //         cutStart = 0;  cutStop = 0;
    //         coagStart = 0;   coagStop = 0;
    //         break;
    //     case SOCKET::BIPOLAR_1:
    //         socketName = QString("BIPOLAR 1");
    //         cutStart = 1+1;  cutStop = 4+1+1;
    //         coagStart = 5+1;   coagStop = 6+1+1;
    //         break;
    //     case SOCKET::BIPOLAR_2:
    //         socketName = QString("BIPOLAR 2");
    //         cutStart = 1+1;  cutStop = 4+1+1;
    //         coagStart = 5+1;   coagStop = 7+1+1;
    //         break;
    //     case SOCKET::MONOPOLAR_1:
    //         socketName = QString("MONOPOLAR 1");
    //         cutStart = 8+1;   cutStop = 18+1+1;
    //         coagStart = 19+1;   coagStop = 26+1+1;
    //         break;
    //     case SOCKET::MONOPOLAR_2:
    //         socketName = QString("MONOPOLAR 2");
    //         cutStart = 8+1;  cutStop = 18+1+1;
    //         coagStart = 19+1;   coagStop = 22+1+1;
    //         break;
    //     }
    //     socket->setSocketName(socketName);
    //     cutModes.insert(ESHF::modesNames[0], QSharedPointer<SurgicalMode>::create(ESHF::modesNames[0],
    //                                                                      false,
    //                                                                      ESHF::modesMaxPowers[0],
    //                                                                      1));
    //     coagModes.insert(ESHF::modesNames[1], QSharedPointer<SurgicalMode>::create(ESHF::modesNames[1],
    //                                                                            true,
    //                                                                            ESHF::modesMaxPowers[1],
    //                                                                            1));

    //     for (int j = cutStart; j < cutStop; ++j) {
    //         cutModes.insert(ESHF::modesNames[j], QSharedPointer<SurgicalMode>::create(ESHF::modesNames[j],
    //                                                                               false,
    //                                                                               ESHF::modesMaxPowers[j],
    //                                                                               1));
    //     }
    //     for (int j = coagStart; j < coagStop; ++j) {
    //         coagModes.insert(ESHF::modesNames[j], QSharedPointer<SurgicalMode>::create(ESHF::modesNames[j],
    //                                                                                false,
    //                                                                                ESHF::modesMaxPowers[j],
    //                                                                                1));
    //     }
    //     socket->setCoagModes(coagModes, ESHF::modesNames);
    //     socket->setCutModes(cutModes, ESHF::modesNames);
    //     socketList.append(socket);
    // }
    // m_socketModel->setItems(socketList);
}

void ControlCenter::dataBaseSocketInit()
{
    std::map<int, SockPtr> socketMap;

    QString queryCondition = "BI_MONO = %1 AND CUT_COAG = %2";

    QList<QVariantList> modeNamesListV = m_dbReader->slotSendSelectQuery(QStringList{"Modes"},
                                                                        QStringList{"Name_RU","id"},
                                                                        "");
    QStringList modeNamesList;
    QList<int> modesIdList;
    for (const auto& iter : modeNamesListV) {
        modeNamesList.append(iter.at(0).toString());
        modesIdList.append(iter.at(1).toInt());
    }

    std::map<int, std::map<int, InstrInfo>> instrConstraintsByMode = getConstarints(modesIdList);

    for (int i = 0; i < 4; ++i) {
        SOCKET::SocType type = SOCKET::SocType(i+1);
        SockPtr socket = SockPtr::create(type);
        socketMap[i] = socket;

        QString socketName = "";
        switch (type) {
        case SOCKET::EMPTY:
            socketName = QString("EMPTY");
            break;
        case SOCKET::BIPOLAR_1:
            socketName = QString("BIPOLAR 1");
            break;
        case SOCKET::BIPOLAR_2:
            socketName = QString("BIPOLAR 2");
            break;
        case SOCKET::MONOPOLAR_1:
            socketName = QString("MONOPOLAR 1");
            break;
        case SOCKET::MONOPOLAR_2:
            socketName = QString("MONOPOLAR 2");
            break;
        }
        socket->setSocketName(socketName);
        QHash<QString, SurgModePtr> cutModes;
        QHash<QString, SurgModePtr> coagModes;


        QList<QVariantList> cutModesList = m_dbReader->slotSendSelectQuery(QStringList{"Modes"},
                    QStringList{"MaxPower","Name_RU"},
                    queryCondition.arg(socket->socketType() <= SOCKET::BIPOLAR_2 ? 0 : 1).arg(1));

        QList<QVariantList> coagModesList = m_dbReader->slotSendSelectQuery(QStringList{"Modes"},
                    QStringList{"MaxPower","Name_RU"},
                    queryCondition.arg(socket->socketType() <= SOCKET::BIPOLAR_2 ? 0 : 1).arg(0));

        cutModes.insert(ESHF::modesNames[0], SurgModePtr::create(ESHF::modesNames[0],
                                                                         false,
                                                                         1,
                                                                         1));
        coagModes.insert(ESHF::modesNames[0], SurgModePtr::create(ESHF::modesNames[0],
                                                                               true,
                                                                               1,
                                                                               1));
        for (const auto& item : cutModesList) {
            cutModes.insert(item.at(1).toString(),
                            SurgModePtr::create(item.at(1).toString(),
                                                false,
                                                item.at(0).toInt(),
                                                1,
                                                instrConstraintsByMode.at(modesIdList.at(modeNamesList.indexOf(item.at(1).toString())))));
        }
        for (const auto& item : coagModesList) {
            coagModes.insert(item.at(1).toString(),
                             SurgModePtr::create(item.at(1).toString(),
                                                true,
                                                item.at(0).toInt(),
                                                1,
                                                instrConstraintsByMode.at(modesIdList.at(modeNamesList.indexOf(item.at(1).toString())))));
        }
        socket->setCoagModes(coagModes, /*ESHF::modesNames*/modeNamesList);
        socket->setCutModes(cutModes, /*ESHF::modesNames*/modeNamesList);

    }
    m_socketModel->setItemsMap(socketMap);
    m_socketModel->setInstrumMap(getInstrums());

}

void ControlCenter::programmLoadSocketInit()
{
}

void ControlCenter::getListOfPrograms(int scopeID)
{
    //захардкодили, но это нужно знать
    bool isMyselfArgon = false;

    QString queryCondition = "Scope_ID = %1 AND (Argon = 0 OR Argon = %2)";

    QList<QVariantList> progList = m_dbReader->slotSendSelectQuery(QStringList{"Progs"},
                                                                        QStringList{"Name_RU","id"},
                                                                        queryCondition.arg(scopeID).arg(isMyselfArgon ? 2 : 1));

}

std::map<int, std::map<int, InstrInfo> > ControlCenter::getConstarints(const QList<int>& idList)
{
    std::map<int, std::map<int, InstrInfo> > result;
    QString queryCondition = "Mode_ID = %1";

    for (int i : idList) {
        QList<QVariantList> intstrListForMode = m_dbReader->slotSendSelectQuery(QStringList{"ModInstr"},
                                                                            QStringList{"Instr_ID","Min_Power","Mid_Power","Max_Power"},
                                                                            queryCondition.arg(i));
        std::map<int, InstrInfo>& modeMap = result[i];
        for (const auto& item : intstrListForMode) {
            int a = item.at(0).toInt();
            int b = item.at(1).toInt();
            int c = item.at(2).toInt();
            int d = item.at(3).toInt();
            InstrInfo bla = InstrInfo(a,
                                      b,
                                      c,
                                      d);
            modeMap[a] = bla;
        }
    }
    return result;
}

std::map<int, InstrPtr > ControlCenter::getInstrums()
{
    std::map<int, InstrPtr> result;
    QList<QVariantList> instrListForMode = m_dbReader->slotSendSelectQuery(QStringList{"Instruments"},
                                                                        QStringList{"id","Num","BI_MONO","Name_Ru","Brief_Ru"},
                                                                        "");
    /* int id, int legacyNumber, const QString& name, bool mono */
    for (const auto& item : instrListForMode) {
        InstrPtr ptr = InstrPtr::create(item.at(0).toInt(),
                                        item.at(1).toInt(),
                                        item.at(3).toString(),
                                        item.at(2).toInt() == 1 ? true : false);
        ptr->setDescription(item.at(4).toString());
        result[item.at(0).toInt()] = ptr;
    }
    return result;
}
