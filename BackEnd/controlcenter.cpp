#include "controlcenter.h"
#include "socket.h"

#include <cmath>
#include <map>
#include <vector>
#include <unordered_set>

#include <QQmlEngine>
#include <QString>

namespace {

template <typename T>
void filterMapByKey(std::map<int, T>& map, const std::vector<int>& keys_to_keep) {
    // Создаем временный набор для быстрого поиска
    std::unordered_set<int> keep_set(keys_to_keep.begin(), keys_to_keep.end());

    // Используем идиому erase-remove для map
    auto it = map.begin();
    while (it != map.end()) {
        if (keep_set.find(it->first) == keep_set.end()) {
            it = map.erase(it);  // Удаляем элемент, если его ключа нет в векторе
        } else {
            ++it;
        }
    }
}

std::vector<int> parseCommaSeparatedNumbers(const QString& input) {
    std::vector<int> result;

    if (input.isEmpty()) {
        return result;  // Возвращаем пустой вектор, если строка пуста
    }

    // Разделяем строку по запятым
    QStringList parts = input.split(',', Qt::SkipEmptyParts);

    // Преобразуем каждую часть в число и добавляем в вектор
    for (const QString& part : parts) {
        bool ok = false;
        int number = part.trimmed().toInt(&ok);  // Удаляем пробелы и конвертируем

        if (ok) {
            result.push_back(number);
        }
        // Можно добавить обработку ошибок, если нужно
    }

    return result;
}

QString makeCommaSeparatedNumbers(QList<int> list) {
    QString res;
    for (int a : list) {
        res += QString("%1,").arg(a);
    }
    if (res.size() != 0)
        res = res.left(res.size()-1);
    return res;
}

QString makeSocketName(SOCKET::SocType type) {
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
    return socketName;
}

void makeModes(QHash<QString, SurgModePtr>& container,
               const QList<QVariantList>& modes,
               const std::map<int, std::map<int, InstrInfo>>& instMap,
               const QVariantList& progItem,
               int socketNum,
               bool isCoag ) {
    int start = isCoag ? 6 : 3;

    // const std::map<int, InstrPtr>tmp = inst;

    container.insert(ESHF::modesNames[0], SurgModePtr::create(ESHF::modesNames[0],
                                                                     false,
                                                                     1,
                                                                     1));


    for (const auto& item : modes) {
        auto instrs = instMap.find(item.at(2).toInt());
        if (instrs == instMap.end())
            continue;
        std::map<int, InstrInfo> tmp = instrs->second;
        filterMapByKey(tmp, parseCommaSeparatedNumbers(progItem.at(start + 6*socketNum).toString()));
        // if (tmp.size() == 0)
        //     continue;
        SurgModePtr ptr = SurgModePtr::create(item.at(1).toString(),
                                                                      isCoag,
                                                                      item.at(0).toInt(),
                                                                      1,
                                                                      tmp);
        container.insert(item.at(1).toString(),
                        ptr);

    }
}


bool hasNonZeroDigit(int number, int digitPosition) {
    // Проверяем, что позиция разряда корректна (начиная с 0)
    if (digitPosition < 0) {
        return false;
    }

    // Приводим число к положительному виду для упрощения
    number = abs(number);

    // Делим число на 10^digitPosition, чтобы перенести нужный разряд в конец
    int shiftedNumber = number / static_cast<int>(std::pow(10, digitPosition));

    // Если после сдвига число стало нулём, значит разряд отсутствует
    if (shiftedNumber == 0) {
        return false;
    }

    // Получаем последнюю цифру (нужный разряд)
    int digit = shiftedNumber % 10;

    // Проверяем, что цифра не равна нулю
    return (digit != 0);
}
}

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
        // dataBaseSocketInit();
        programmLoadSocketInit(5);
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

        socket->setSocketName(makeSocketName(type));
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
        for (const auto& item : cutModesList) {
            cutModes.insert(item.at(1).toString(),
                            SurgModePtr::create(item.at(1).toString(),
                                                false,
                                                item.at(0).toInt(),
                                                1,
                                                instrConstraintsByMode.at(modesIdList.at(modeNamesList.indexOf(item.at(1).toString())))));
        }
        coagModes.insert(ESHF::modesNames[0], SurgModePtr::create(ESHF::modesNames[0],
                                                                               true,
                                                                               1,
                                                                               1));
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


/**
 * @brief ControlCenter::programmLoadSocketInit
 * @param progId
 * @details я тут с ума сойду - вся эта функция за раз в голове не помещается
 * Шаг 1 - получить строки таблицы Lists, с соответствующими id (каждая строка - 1 рабочий экран)
 * Шаг 2 - поличить строки таблицы EnabledMods, с соответствующими id
 *         (каждая строка - 1 разрещённый режим)
 * Шаг 3 - поличить строки таблицы EnabledInstr, с соответствующими id
 *         (каждая строка - 1 разрещённый инструмент)
 * Шаг 4 - из таблицы Instrum получить список допустимых инструментов
 *         для каждого режима в списке режимов (Шаг 2)
 * Шаг 5 - Проредить полученный список инструментов оставив в нём только
 *         те, которые разрешены в данной программе (Шаг 3)
 * Шаг 6 - Поселедовательная инициализация полусокетов по строкам из (Шаг 1)
 *         Если сокет включён:
 *         6.1 - для каждого полусокета прореживания списка инструментов
 *         6.2 инициализация сокета полученным списком допустимыз режимов и инструментов
 *         6.3 установка режима, мощностии и инструмента по умолчанию
 *
 */
void ControlCenter::programmLoadSocketInit(int progId)
{
    //начинаем прорабатывать прогрузку несекольких экранов
    std::vector<std::map<int, SockPtr>> socketMapVector;
    std::map<int, std::map<int, InstrInfo>>  instrumConstraints;

    //ПОТОМУ ЧТО ЕСЛИ SELECT * то Qt говорит, что порядок следования полей может быть случаен
    //Шаг1---------------------------------------------------------
    QString queryCondition = "Prog_ID = %1";
    QStringList fields = {"id", "Num", "Prog_ID", /* 0 1 2*/
                          "Bi1Cut_INSTR", "Bi1Cut_MODE", "Bi1Cut_POWER", /* 3 4 5*/
                          "Bi1Coag_INSTR", "Bi1Coag_MODE", "Bi1Coag_POWER", /* 6 7 8*/
                          "Bi2Cut_INSTR", "Bi2Cut_MODE", "Bi2Cut_POWER", /* 9 10 11*/
                          "Bi2Coag_INSTR", "Bi2Coag_MODE", "Bi2Coag_POWER", /* 12 13 14*/
                          "Mono1Cut_INSTR", "Mono1Cut_MODE", "Mono1Cut_POWER", /* 15 16 17*/
                          "Mono1Coag_INSTR", "Mono1Coag_MODE", "Mono1Coag_POWER", /* 18 19 20*/
                          "Mono2Cut_INSTR", "Mono2Cut_MODE", "Mono2Cut_POWER", /* 21 22 23*/
                          "Mono2Coag_INSTR", "Mono2Coag_MODE", "Mono2Coag_POWER", /* 24 25 26*/
                          "Pedal_1", "Pedal_2", "OutEnabled_MASK"};/* 27 28 29*/

    QList<QVariantList> progListVariant = m_dbReader->slotSendSelectQuery(QStringList{"Lists"},
                                                                        fields,
                                                                        queryCondition.arg(progId));
    //--------------------------------------------------------------

    //Шаг2---------------------------------------------------------
    QList<QVariantList> allowedModes = m_dbReader->slotSendSelectQuery(QStringList{"EnableModes"},
                                                                      QStringList{"Mode_ID"},
                                                                      QString("Prog_ID = %1").arg(progId));
    QList<int> allowedModesId;
    for (const auto& item : allowedModes)
        allowedModesId.append(item.at(0).toInt());

    //Шаг3---------------------------------------------------------
    QList<QVariantList> allowedInstr = m_dbReader->slotSendSelectQuery(QStringList{"EnableInstr"},
                                                                       QStringList{"Instr_ID"},
                                                                       QString("Prog_ID = %1").arg(progId));
    // QList<int> allowedInstrId;
    std::vector<int> allowedInstrId;

    for (const auto& item : allowedInstr)
        allowedInstrId.push_back(item.at(0).toInt());

    //Шаг4---------------------------------------------------------
    QString queryConditionModes = "BI_MONO = %1 AND CUT_COAG = %2 AND id IN (%3)";
    instrumConstraints = getConstarints(allowedModesId);

    //Шаг5---------------------------------------------------------
    // for (auto item : instrumConstraints) {
    for (auto iterItem = instrumConstraints.begin(); iterItem != instrumConstraints.end(); ++iterItem) {
        std::map<int, InstrInfo>& item = iterItem->second;
        filterMapByKey<InstrInfo>(item, allowedInstrId);
    }


    //Шаг 6--------------------------------------------------------
    QList<QVariantList> modeNamesListV = m_dbReader->slotSendSelectQuery(QStringList{"Modes"},
                                                                        QStringList{"Name_RU","id"},
                                                                        "");
    QStringList modeNamesList;
    for (const auto& iter : modeNamesListV) {
        modeNamesList.append(iter.at(0).toString());
    }

    for (const auto& progItem : progListVariant) {
        socketMapVector.push_back(std::map<int, SockPtr>());
        std::map<int, SockPtr>& socketMap = socketMapVector[socketMapVector.size() - 1];
        for (int i = 0; i < 4; ++i) {
            SOCKET::SocType type = SOCKET::SocType(i+1);
            SockPtr socket = SockPtr::create(type);
            socketMap[i] = socket;

            socket->setSocketName(makeSocketName(type));

            for (int halfSocket = 0; halfSocket < 2; ++halfSocket ) {
                bool isCoag = (halfSocket == 0);
                QHash<QString, SurgModePtr> modes;
                QList<QVariantList> modesList = m_dbReader->slotSendSelectQuery(QStringList{"Modes"},
                            QStringList{"MaxPower","Name_RU", "id"},
                            queryConditionModes
                                        .arg(socket->socketType() <= SOCKET::BIPOLAR_2 ? 0 : 1)
                                        .arg(halfSocket)
                                        .arg(makeCommaSeparatedNumbers(allowedModesId)));

                makeModes(modes,
                          modesList,
                          instrumConstraints,
                          progItem,
                          i,
                          isCoag);

                if (isCoag) socket->setCoagModes(modes, modeNamesList);
                else socket->setCutModes(modes, modeNamesList);
                int start = isCoag ? 6 : 3;
                std::vector<int> instId = parseCommaSeparatedNumbers(progItem.at(start + 6*i).toString());
                int firstInstrId = instId.size() == 0 ? 0 : instId.at(0);
                std::vector<int> modeId = parseCommaSeparatedNumbers(progItem.at(start + 1 + 6*i).toString());
                int firstModeId = modeId.size() == 0 ? 0 : instId.at(0);
                int defaultPower = progItem.at(start + 2 + 6*i).toInt();
                defaultPower = std::max(1, defaultPower);
                // if (isCoag) {
                socket->setModeId(firstModeId, isCoag);
                socket->setInstrumId(firstInstrId, isCoag);
                isCoag ? socket->setCoagModePower(defaultPower) : socket->setCutModePower(defaultPower);
                // }

            }
            //МОНО2 КОАГ = 1, БИ1РЕЗ 8
            bool allowSock = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) - 1 )
                    || hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i));
            socket->setAllowed(allowSock);
        }
    }
    m_socketModel->setItemsMapVector(socketMapVector);
    m_socketModel->setInstrumMap(getInstrums());
}

QList<Prog> ControlCenter::getListOfPrograms(int scopeID)
{
    //захардкодили, но это нужно знать
    bool isMyselfArgon = false;

    QString queryCondition = "Scope_ID = %1 AND (Argon = 0 OR Argon = %2)";

    QList<QVariantList> progListVariant = m_dbReader->slotSendSelectQuery(QStringList{"Progs"},
                                                                        QStringList{"Name_RU","id", "Prog_NUM", "Subprog_RU"},
                                                                        queryCondition.arg(scopeID).arg(isMyselfArgon ? 2 : 1));

    QList<Prog> progList;
    progList.reserve(progListVariant.size());
    // QStringList progNameList;
    for (const auto& item : progListVariant) {
        Prog tmp;
        tmp.isMainProg = item.at(2).toInt() % 10 == 0 ? true : false;
        tmp.id = item.at(1).toInt();
        tmp.name = item.at(tmp.isMainProg ? 0 : 3).toString();
        progList.append(tmp);
    }
    return progList;
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
