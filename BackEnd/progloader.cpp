#include "progloader.h"
#include "socket.h"
#include <unordered_set>
#include <cmath>
#include <vector>
#include <QDebug>


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

using namespace Onyx;

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

QString makeSocketName(Onyx::SocType type) {
    QString socketName = "";
    switch (type) {
    case Onyx::EMPTY:
        socketName = QString("EMPTY");
        break;
    case Onyx::BIPOLAR_1:
        socketName = QString("БИ 1");
        break;
    case Onyx::BIPOLAR_2:
        socketName = QString("БИ 2");
        break;
    case Onyx::MONOPOLAR_1:
        socketName = QString("МОНО 1");
        break;
    case Onyx::MONOPOLAR_2:
        socketName = QString("МОНО 2");
        break;
    }
    return socketName;
}

void makeModes(QMap<int, SurgModePtr>& container,
               const QList<QVariantList>& modes,
               const std::map<int, std::map<int, InstrInfo>>& instMap,
               const QVariantList& progItem,
               int socketNum,
               bool isCoag,
               const std::vector<int>& instrFilter = std::vector<int>()) {
    int start = isCoag ? 6 : 3;

    container.insert(1000, SurgModePtr::create(ESHF::modesNames.last(),
                                                                   false,
                                                                   1,
                                                                   1,
                                                                   1000,
                                                                   std::map<int, InstrInfo>(),
                                                                   1000,
                                                                   "",
                                                                   "",
                                                                   false));  // Num = 1000, Brief = "", Descript = "", isEndo = false


    for (const auto& item : modes) {
        int modeId = item.at(2).toInt();
        QString modeName = item.at(1).toString();
        int modeNum = item.size() > 3 ? item.at(3).toInt() : 0;  // Num для изображения
        QString modeBrief = item.size() > 4 ? item.at(4).toString() : "";  // Brief_RU для краткого описания
        QString modeDescript = item.size() > 5 ? item.at(5).toString() : "";  // Descript_RU для полного описания

        auto instrs = instMap.find(modeId);
        if (instrs == instMap.end()) {
            continue;
        }

        std::map<int, InstrInfo> tmp = instrs->second;

        // Используем переданный фильтр, если он не пуст, иначе берём из progItem
        if (!instrFilter.empty()) {
            filterMapByKey(tmp, instrFilter);
        } else {
            filterMapByKey(tmp, parseCommaSeparatedNumbers(progItem.at(start + 6*socketNum).toString()));
        }

        bool isEndo = item.size() > 6 ? item.at(6).toBool() : false;  // ENDO_REG

        SurgModePtr ptr = SurgModePtr::create(modeName,
                                              isCoag,
                                              item.at(0).toInt(),
                                              1,
                                              modeId,
                                              tmp,
                                              modeNum,
                                              modeBrief,
                                              modeDescript,
                                              isEndo);  // Передаём Brief, Descript и isEndo
        container.insert(modeId, ptr);
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

void filterModeMap(QMap<int, SurgModePtr>& container, const std::vector<int>& allow) {
    auto iter = container.begin();
    while (iter != container.end()) {
        bool contains = iter.key() == 1000;
        for (int a : allow) {
            if (iter.key() == a) {
                contains = true;
                break;
            }
        }
        if (contains) {
            ++iter;
        } else {
            iter = container.erase(iter);
        }
    }
}

    const QString queryCondition = "Prog_ID = %1";
    const QStringList fields = {"id", "Num", "Prog_ID", /* 0 1 2*/
                          "Bi1Cut_INSTR", "Bi1Cut_MODE", "Bi1Cut_POWER", /* 3 4 5*/
                          "Bi1Coag_INSTR", "Bi1Coag_MODE", "Bi1Coag_POWER", /* 6 7 8*/
                          "Bi2Cut_INSTR", "Bi2Cut_MODE", "Bi2Cut_POWER", /* 9 10 11*/
                          "Bi2Coag_INSTR", "Bi2Coag_MODE", "Bi2Coag_POWER", /* 12 13 14*/
                          "Mono1Cut_INSTR", "Mono1Cut_MODE", "Mono1Cut_POWER", /* 15 16 17*/
                          "Mono1Coag_INSTR", "Mono1Coag_MODE", "Mono1Coag_POWER", /* 18 19 20*/
                          "Mono2Cut_INSTR", "Mono2Cut_MODE", "Mono2Cut_POWER", /* 21 22 23*/
                          "Mono2Coag_INSTR", "Mono2Coag_MODE", "Mono2Coag_POWER", /* 24 25 26*/
                          "Pedal_1", "Pedal_2", "OutEnabled_MASK", "User_ID"};/* 27 28 29*/
    const   QString saveCurQuery = QString(
        "REPLACE INTO Lists ("
        "id, Num, Prog_ID, "
        "Bi1Cut_INSTR, Bi1Cut_MODE, Bi1Cut_POWER, "
        "Bi1Coag_INSTR, Bi1Coag_MODE, Bi1Coag_POWER, "
        "Bi2Cut_INSTR, Bi2Cut_MODE, Bi2Cut_POWER, "
        "Bi2Coag_INSTR, Bi2Coag_MODE, Bi2Coag_POWER, "
        "Mono1Cut_INSTR, Mono1Cut_MODE, Mono1Cut_POWER, "
        "Mono1Coag_INSTR, Mono1Coag_MODE, Mono1Coag_POWER, "
        "Mono2Cut_INSTR, Mono2Cut_MODE, Mono2Cut_POWER, "
        "Mono2Coag_INSTR, Mono2Coag_MODE, Mono2Coag_POWER, "
        "Pedal_1, Pedal_2, OutEnabled_MASK"
        ") VALUES ("
        "1000, %28, 1000, "
        "'%1', '%2', %3, "
        "'%4', '%5', %6, "
        "'%7', '%8', %9, "
        "'%10', '%11', %12, "
        "'%13', '%14', %15, "
        "'%16', '%17', %18, "
        "'%19', '%20', %21, "
        "'%22', '%23', %24, "
        "%25, %26, %27"
        ")");
    const   QString insertCurQuery = QString(
                                       "INSERT INTO Lists ("
                                       "Num, Prog_ID, "
                                       "Bi1Cut_INSTR, Bi1Cut_MODE, Bi1Cut_POWER, "
                                       "Bi1Coag_INSTR, Bi1Coag_MODE, Bi1Coag_POWER, "
                                       "Bi2Cut_INSTR, Bi2Cut_MODE, Bi2Cut_POWER, "
                                       "Bi2Coag_INSTR, Bi2Coag_MODE, Bi2Coag_POWER, "
                                       "Mono1Cut_INSTR, Mono1Cut_MODE, Mono1Cut_POWER, "
                                       "Mono1Coag_INSTR, Mono1Coag_MODE, Mono1Coag_POWER, "
                                       "Mono2Cut_INSTR, Mono2Cut_MODE, Mono2Cut_POWER, "
                                       "Mono2Coag_INSTR, Mono2Coag_MODE, Mono2Coag_POWER, "
                                       "Pedal_1, Pedal_2, OutEnabled_MASK"
                                       ") VALUES ("
                                       "%28, 1000, "
                                       "'%1', '%2', %3, "
                                       "'%4', '%5', %6, "
                                       "'%7', '%8', %9, "
                                       "'%10', '%11', %12, "
                                       "'%13', '%14', %15, "
                                       "'%16', '%17', %18, "
                                       "'%19', '%20', %21, "
                                       "'%22', '%23', %24, "
                                       "%25, %26, %27"
                                       ")");

}

ProgLoader::ProgLoader(QObject *parent)
    : QObject{parent}
{
    if (m_dbReaderPtr.isNull())
        m_dbReaderPtr = new DataBaseReader("/home/kikorik/FOTEK/eshfDb.db");
    // m_dbReaderPtr = new DataBaseReader("/home/kikorik/FOTEK/someShadyDB.db");
}

void ProgLoader::slotSaveCurrentState()
{
    if (m_socketModelPtr == nullptr
        || m_socketModelPtr->itemsMap() == nullptr) {
        // qWarning() << "Cannot save state: socket model not initialized";
        return;
    }

    auto fillState = [this] (std::array<QString, 3>& cut,
                            std::array<QString, 3>& coag,
                            std::pair<int, int>& pedals,
                            int _idx) {
        QModelIndex idx = m_socketModelPtr->index(_idx);
        if (idx.data(SocketModel::SocketStatus) == QVariant()
            || idx.data(SocketModel::CutModeNum).toInt() == 0
            || idx.data(SocketModel::CoagModeNum).toInt() == 0) {
            return;
        } else {
            cut[0] = QString::number(idx.data(SocketModel::CutModeInstrID).toInt());
            // cut[1] = QString::number(idx.data(SocketModel::CutModeNum).toInt());
            cut[1] = QString::number(idx.data(SocketModel::CutModeId).toInt());
            cut[2] = QString::number(idx.data(SocketModel::CutModePower).toInt());
            coag[0] = QString::number(idx.data(SocketModel::CoagModeInstrID).toInt());
            // coag[1] = QString::number(idx.data(SocketModel::CoagModeNum).toInt());
            coag[1] = QString::number(idx.data(SocketModel::CoagModeId).toInt());
            coag[2] = QString::number(idx.data(SocketModel::CoagModePower).toInt());
            int ped = idx.data(SocketModel::SocketPedal).toInt();
            if (ped == SINGLE_PED)
                pedals.first = _idx + 1;
            if (ped == DOUBLE_PED)
                pedals.second = _idx + 1;
        }
    };

    std::vector<SocketStrings> allStates;
    std::vector<std::pair<int, int>> allPedals;
    int subCount = m_socketModelPtr->subProgCount();
    int curSubIndex = m_socketModelPtr->subProgIdx();
    allStates.resize(subCount);
    allPedals.resize(subCount, {0, 0});
    m_socketModelPtr->blockSignals(true);
    for (int list = 0; list < subCount; ++list) {
        m_socketModelPtr->setSubProgIdx(list);
        SocketStrings & state = allStates[list];
        std::pair<int, int> & pedalState = allPedals[list];
        //bi1cut bi1coag
        fillState(state[0], state[1], pedalState, 0);
        fillState(state[2], state[3], pedalState, 1);
        fillState(state[4], state[5], pedalState, 2);
        fillState(state[6], state[7], pedalState, 3);
    }
    m_socketModelPtr->setSubProgIdx(curSubIndex);
    m_socketModelPtr->blockSignals(false);

    // OutEnabled_MASK - битовая маска доступности полусокетов
    // TODO: если нужно сохранять доступность, добавить логику
    int outEnabledMask = 11111111;  // По умолчанию все включены (11111111)

    // Формируем SQL запрос для REPLACE (INSERT OR UPDATE)
    QString removeQuerry = "DELETE FROM Lists WHERE Prog_ID = 1000";
    m_dbReaderPtr->executeUpdateQuery(removeQuerry);
    for (int i = 0; i < subCount; ++i) {
        const SocketStrings & state = allStates.at(i);
        const std::pair<int, int> & pedalState = allPedals.at(i);
        QString query = insertCurQuery
        // QString query = saveCurQuery
        .arg(state.at(0).at(0) == "-1" ? "" : state.at(0).at(0)).arg(state.at(0).at(1) == "1000" ? "" : state.at(0).at(1)).arg(state.at(0).at(2))
        .arg(state.at(1).at(0) == "-1" ? "" : state.at(1).at(0)).arg(state.at(1).at(1) == "1000" ? "" : state.at(1).at(1)).arg(state.at(1).at(2))
        .arg(state.at(2).at(0) == "-1" ? "" : state.at(2).at(0)).arg(state.at(2).at(1) == "1000" ? "" : state.at(2).at(1)).arg(state.at(2).at(2))
        .arg(state.at(3).at(0) == "-1" ? "" : state.at(3).at(0)).arg(state.at(3).at(1) == "1000" ? "" : state.at(3).at(1)).arg(state.at(3).at(2))
        .arg(state.at(4).at(0) == "-1" ? "" : state.at(4).at(0)).arg(state.at(4).at(1) == "1000" ? "" : state.at(4).at(1)).arg(state.at(4).at(2))
        .arg(state.at(5).at(0) == "-1" ? "" : state.at(5).at(0)).arg(state.at(5).at(1) == "1000" ? "" : state.at(5).at(1)).arg(state.at(5).at(2))
        .arg(state.at(6).at(0) == "-1" ? "" : state.at(6).at(0)).arg(state.at(6).at(1) == "1000" ? "" : state.at(6).at(1)).arg(state.at(6).at(2))
        .arg(state.at(7).at(0) == "-1" ? "" : state.at(7).at(0)).arg(state.at(7).at(1) == "1000" ? "" : state.at(7).at(1)).arg(state.at(7).at(2))
        .arg(pedalState.first).arg(pedalState.second).arg(outEnabledMask).arg(i+1);

        if (!m_dbReaderPtr->executeUpdateQuery(query)) {
            qDebug() << "Failed to save current state";
        }
    }
    // //проблема в запросе - меняем каждый раз одну и ту же строку - надо инкрементить id
    // for (int i = subCount; i < 4; ++i) {
    //     const SocketStrings state;
    //     const std::pair<int, int> pedalState = {-1, -1};
    //     QString query = saveCurQuery
    //                     .arg(state.at(0)[0]).arg(state.at(0)[1]).arg(state.at(0)[2])
    //                     .arg(state.at(1)[0]).arg(state.at(1)[1]).arg(state.at(1)[2])
    //                     .arg(state.at(2)[0]).arg(state.at(2)[1]).arg(state.at(2)[2])
    //                     .arg(state.at(3)[0]).arg(state.at(3)[1]).arg(state.at(3)[2])
    //                     .arg(state.at(4)[0]).arg(state.at(4)[1]).arg(state.at(4)[2])
    //                     .arg(state.at(5)[0]).arg(state.at(5)[1]).arg(state.at(5)[2])
    //                     .arg(state.at(6)[0]).arg(state.at(6)[1]).arg(state.at(6)[2])
    //                     .arg(state.at(7)[0]).arg(state.at(7)[1]).arg(state.at(7)[2])
    //                     .arg(pedalState.first).arg(pedalState.second).arg(outEnabledMask).arg(-1);

    //     if (!m_dbReaderPtr->executeUpdateQuery(query)) {
    //         // qWarning() << "Failed to save current state";
    //     }
    // }
}

bool ProgLoader::readPreviousSocketSettings()
{
    ///todo REALIZE
    return false;
}

void ProgLoader::defaultSocketInit(bool clear)
{
    std::vector<std::map<int, SockPtr>> socketMapVector;
    std::vector<std::map<int, InstrPtr >> instrMapVector;
    std::map<int, std::map<int, InstrInfo>>  instrumConstraints;
    QList<QVariantList> progListVariant;
    QList<int> allowedModesId;
    std::vector<int> allowedInstrId;

    // Создаём пустую запись с дефолтными значениями
    QVariantList dummyProgItem;
    dummyProgItem << 0 << 0 << 0;  // id, Num, Prog_ID

    // Добавляем пустые строки для всех полей инструментов/режимов/мощностей (24 поля)
    for (int i = 0; i < 24; ++i) {
        dummyProgItem << "";
    }

    // Добавляем дефолтные значения для педалей и маски
    dummyProgItem << 0 << 0 << 255;  // Pedal_1, Pedal_2, OutEnabled_MASK (все сокеты разрешены)

    progListVariant.append(dummyProgItem);
    // qDebug() << "progId = 0: Created dummy program item with" << dummyProgItem.size() << "fields";
            // Получаем все режимы из БД
    QList<QVariantList> allModes = m_dbReaderPtr->slotSendSelectQuery(
        QStringList{"Modes"},
        QStringList{"id"},
        ""
    );
    for (const auto& item : allModes)
        allowedModesId.append(item.at(0).toInt());

    // Получаем все инструменты из БД
    QList<QVariantList> allInstr = m_dbReaderPtr->slotSendSelectQuery(
        QStringList{"Instruments"},
        QStringList{"id"},
        ""
    );
    for (const auto& item : allInstr)
        allowedInstrId.push_back(item.at(0).toInt());

    // qDebug() << "progId = 0: Loading ALL modes (" << allowedModesId.size() << ") and instruments (" << allowedInstrId.size() << ")";

        //Шаг4---------------------------------------------------------
    QString queryConditionModes = "BI_MONO = %1 AND CUT_COAG = %2 AND id IN (%3)";
    instrumConstraints = getConstraints(allowedModesId);

    //Шаг 6--------------------------------------------------------
    QList<QVariantList> modeNamesListV = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
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
            Onyx::SocType type = Onyx::SocType(i+1);
            SockPtr socket = SockPtr::create(type);
            socketMap[i] = socket;

            socket->setSocketName(makeSocketName(type));

            for (int halfSocket = 0; halfSocket < 2; ++halfSocket ) {
                bool isCoag = (halfSocket == 0);
                QMap<int, SurgModePtr> modes;
                QList<QVariantList> modesList = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
                            QStringList{"MaxPower","Name_RU", "id", "Num", "Brief_RU", "Descript_RU", "ENDO_REG"},
                            queryConditionModes
                                        .arg(socket->socketType() <= Onyx::BIPOLAR_2 ? 0 : 1)
                                        .arg(halfSocket)
                                        .arg(makeCommaSeparatedNumbers(allowedModesId)));

                // Сортируем по Num (index 3)
                std::sort(modesList.begin(), modesList.end(),
                    [](const QVariantList& a, const QVariantList& b) {
                        return a.at(3).toInt() < b.at(3).toInt();
                    });

                std::vector<int> instIdLst;
                std::vector<int> modeIdLst;

                // Используем все инструменты и режимы
                instIdLst = allowedInstrId;
                for (const auto& mode : modesList) {
                    modeIdLst.push_back(mode.at(2).toInt());
                }

                makeModes(modes,
                          modesList,
                          instrumConstraints,
                          progItem,
                          i,
                          isCoag,
                          instIdLst);  // Передаём фильтр инструментов

                // Исключаем режим "Термошов" (ID=7) для сокета БИ2 (i=0)
                if (i == 0 && modes.contains(7)) {
                    modes.remove(7);
                }

                isCoag ? socket->setCoagModes(modes, modeNamesList)
                       : socket->setCutModes(modes, modeNamesList);

                int firstInstrId;
                int firstModeId;
                int defaultPower;

                firstInstrId = 0;
                firstModeId = 1000;
                defaultPower = 1;

                socket->setModeId(firstModeId, isCoag);
                socket->setInstrumId(firstInstrId, isCoag);

                // Проверка для эндоскопических режимов: если мощность = 1, устанавливаем 11
                auto mode = isCoag ? socket->curCoagMode() : socket->curCutMode();
                if (!mode.isNull() && mode->isEndo()) {
                    int endoCut = static_cast<int>(std::floor(defaultPower / 10.0));
                    int endoCoag = defaultPower % 10;
                    if (endoCut < 1) endoCut = 1;
                    else if (endoCut > ENDO_MAX) endoCut = ENDO_MAX;
                    if (endoCoag < 1) endoCoag = 1;
                    else if (endoCoag > ENDO_MAX) endoCoag = ENDO_MAX;
                    defaultPower = endoCut * 10 + endoCoag;
                }

                isCoag ? socket->setCoagModePower(defaultPower)
                       : socket->setCutModePower(defaultPower);
            }
            //МОНО2 КОАГ = 1, БИ1РЕЗ 8
            bool coagEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) - 1 );
            bool cutEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) );
            bool allowSock = cutEna || coagEna;
            socket->setAllowed(allowSock);
            socket->setDisplayMode(Onyx::S_COLLAPSED);
        }
        instrMapVector.push_back(getInstrums());
    }
    m_socketModelPtr->loadProgs(socketMapVector, instrMapVector, !clear);
}

bool ProgLoader::programmLoadSocketInit(int progId, bool clear)
{
    //начинаем прорабатывать прогрузку несекольких экранов
    std::vector<std::map<int, SockPtr>> socketMapVector;
    std::vector<std::map<int, InstrPtr >> instrMapVector;
    std::map<int, std::map<int, InstrInfo>>  instrumConstraints;

    //ПОТОМУ ЧТО ЕСЛИ SELECT * то Qt говорит, что порядок следования полей может быть случаен
    //Шаг1---------------------------------------------------------

    QList<QVariantList> progListVariant;

    // Если progId = 0, создаём фиктивную запись программы
    progListVariant = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Lists"},
                                                      fields,
                                                      queryCondition.arg(progId));
    if (progListVariant.size() == 0)
        return false;

    //Шаг5---------------------------------------------------------
    //тут какой-то затуп с базой на каких-то прогах, разрешено всего несколько инструментов
    //при этом для выбранных режимов эти инструменты не разрешены
    // for (auto iterItem = instrumConstraints.begin(); iterItem != instrumConstraints.end(); ++iterItem) {
    //     std::map<int, InstrInfo>& item = iterItem->second;
    //     filterMapByKey<InstrInfo>(item, allowedInstrId);
    // }

    //Шаг 6--------------------------------------------------------
    QList<QVariantList> modeNamesListV = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
                                                                        QStringList{"Name_RU","id"},
                                                                        "");
    QStringList modeNamesList;
    for (const auto& iter : modeNamesListV)
        modeNamesList.append(iter.at(0).toString());

    for (const auto& progItem : progListVariant) {
    //ограничения для каждого листа
        if (progItem.at(1).toInt() < 0
            || progItem.at(1).toInt() >= 4)
            continue;
        QList<int> allowedModesId;
        std::vector<int> allowedInstrId;

        //Шаг2---------------------------------------------------------
        QList<QVariantList> allowedModes
                = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableModes"},
                                                     QStringList{"Mode_ID"},
                                                     QString("List_ID = %1").arg(progItem.at(0).toUInt()));
        for (const auto& item : allowedModes)
            allowedModesId.append(item.at(0).toInt());

        std::vector<int> allowedModesId__;
        if (progId == 1000) {
            for (int i = 0; i < 8; ++i)
                allowedModesId__.push_back(progItem.at(4 + 3*i).toInt());
            std::sort(allowedModesId__.begin(), allowedModesId__.end());
            if (allowedModesId__.size() >1) {
                for (auto iter = allowedModesId__.begin()+1; iter < allowedModesId__.end(); ++iter) {
                    if ( *(iter-1) == *(iter) ) {
                        iter = allowedModesId__.erase(iter);
                    }
                }
            }
            allowedModesId = QList<int>::fromVector(QVector<int>::fromStdVector(allowedModesId__));
        }
        // allowedModes

        //Шаг3---------------------------------------------------------
        QList<QVariantList> allowedInstr
                = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableInstr"},
                                                       QStringList{"Instr_ID"},
                                                       QString("List_ID = %1").arg(progItem.at(0).toUInt()));

        for (const auto& item : allowedInstr)
            allowedInstrId.push_back(item.at(0).toInt());


        std::vector<int> allowedInstrId__;
        if (progId == 1000) {
            for (int i = 0; i < 8; ++i)
                allowedInstrId__.push_back(progItem.at(3 + 3*i).toInt());
            std::sort(allowedInstrId__.begin(), allowedInstrId__.end());
            if (allowedInstrId__.size() > 1) {
                for (auto iter = allowedInstrId__.begin()+1; iter < allowedInstrId__.end(); ++iter) {
                    if ( *(iter - 1) == *(iter) ) {
                        iter = allowedInstrId__.erase(iter);
                    }
                }
            }
            allowedInstrId = allowedInstrId__;
        }


        //Шаг4---------------------------------------------------------
        QString queryConditionModes = "BI_MONO = %1 AND CUT_COAG = %2 AND id IN (%3)";
        instrumConstraints = getConstraints(allowedModesId);
//--------------------------------------------------------------------------------------------------------------


        socketMapVector.push_back(std::map<int, SockPtr>());
        std::map<int, SockPtr>& socketMap = socketMapVector[socketMapVector.size() - 1];
        for (int i = 0; i < 4; ++i) {
            Onyx::SocType type = Onyx::SocType(i+1);
            SockPtr socket = SockPtr::create(type);
            socketMap[i] = socket;

            socket->setSocketName(makeSocketName(type));

            for (int halfSocket = 0; halfSocket < 2; ++halfSocket ) {
                bool isCoag = (halfSocket == 0);
                QMap<int, SurgModePtr> modes;
                QList<QVariantList> modesList = m_dbReaderPtr->slotSendSelectQuery(
                            QStringList{"Modes"},
                            QStringList{"MaxPower","Name_RU", "id", "Num",
                                        "Brief_RU", "Descript_RU", "ENDO_REG"},
                            queryConditionModes
                                        .arg(socket->socketType() <= Onyx::BIPOLAR_2 ? 0 : 1)
                                        .arg(halfSocket)
                                        .arg(makeCommaSeparatedNumbers(allowedModesId)));

                // Сортируем по Num (index 3)
                std::sort(modesList.begin(), modesList.end(),
                    [](const QVariantList& a, const QVariantList& b) {
                        return a.at(3).toInt() < b.at(3).toInt();
                    });

                int start = isCoag ? 6 : 3;
                std::vector<int> instIdLst;
                std::vector<int> modeIdLst;

                instIdLst = parseCommaSeparatedNumbers(progItem.at(start + 6*i).toString());
                modeIdLst = parseCommaSeparatedNumbers(progItem.at(start + 1 + 6*i).toString());

                makeModes(modes,
                          modesList,
                          instrumConstraints,
                          progItem,
                          i,
                          isCoag,
                          instIdLst);  // Передаём фильтр инструментов

                filterModeMap(modes, modeIdLst);

                // Исключаем режим "Термошов" (ID=7) для сокета БИ2 (i=0)
                if (i == 0 && modes.contains(7)) {
                    modes.remove(7);
                }

                isCoag ? socket->setCoagModes(modes, modeNamesList)
                       : socket->setCutModes(modes, modeNamesList);

                int firstInstrId;
                int firstModeId;
                int defaultPower;

                firstInstrId = instIdLst.size() == 0 ? 0 : instIdLst.at(0);
                firstModeId = modeIdLst.size() == 0 ? 1000 : modeIdLst.at(0);
                defaultPower = progItem.at(start + 2 + 6*i).toInt();
                defaultPower = std::max(1, defaultPower);

                socket->setModeId(firstModeId, isCoag);
                socket->setInstrumId(firstInstrId, isCoag);

                // Проверка для эндоскопических режимов: если мощность = 1, устанавливаем 11
                auto mode = isCoag ? socket->curCoagMode() : socket->curCutMode();
                if (!mode.isNull() && mode->isEndo()) {
                    int endoCut = static_cast<int>(std::floor(defaultPower / 10.0));
                    int endoCoag = defaultPower % 10;
                    if (endoCut < 1)
                        endoCut = 1;
                    else if (endoCut > ENDO_MAX)
                        endoCut = ENDO_MAX;
                    if (endoCoag < 1)
                        endoCoag = 1;
                    else if (endoCoag > ENDO_MAX)
                        endoCoag = ENDO_MAX;
                    defaultPower = endoCut * 10 + endoCoag;
                }

                isCoag ? socket->setCoagModePower(defaultPower)
                       : socket->setCutModePower(defaultPower);
            }
            bool coagEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) - 1 );
            bool cutEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) );
            bool allowSock = cutEna || coagEna;
            socket->setAllowed(allowSock);
            socket->setDisplayMode(Onyx::S_COLLAPSED);
        }
        instrMapVector.push_back(getInstrums());
    }

    if (socketMapVector.empty())
        return false;

    m_socketModelPtr->loadProgs(socketMapVector, instrMapVector, !clear);
    if (progId != 1000)
        slotSaveCurrentState();
    return (true);
}

QMap<int, QString> ProgLoader::getListOfPrograms(int scopeID)
{
    //захардкодили, но это нужно знать
    bool isMyselfArgon = false;

    QString queryCondition = "Scope_ID = %1 AND (Argon = 0 OR Argon = %2)";

    QList<QVariantList> progListVariant = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Progs"},
                                                                        QStringList{"Name_RU","id", "Prog_NUM", "Subprog_RU"},
                                                                        queryCondition.arg(scopeID).arg(isMyselfArgon ? 2 : 1));

    QMap<int, QString> progList;
    for (const auto& item : progListVariant) {
        // Prog tmp;
        bool isMainProg = item.at(2).toInt() % 10 == 0 ? true : false;
        int id = item.at(1).toInt();
        QString name = item.at(isMainProg ? 0 : 3).toString();
        progList.insert(id, name);
    }
    return progList;
}

QMap<int, QString> ProgLoader::getScopes ()
{
    QList<QVariantList> scopeListVariant = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Scopes"},
                                                                        QStringList{"id", "Name_RU"},
                                                                        "");

    QMap<int, QString> scopeList;
    for (const auto& item : scopeListVariant) {
        bool ok;
        int id = item.at(0).toInt(&ok);
        QString name = item.at(1).toString();
        if (!ok)
            continue;
        scopeList.insert(id, name);
    }
    return scopeList;
}

QMap<int, QString> ProgLoader::getUserProgList()
{
    QMap<int, QString> res;
    ///TODO
    /// нужна новая таблица в БД, с именами и айдишниками юзверских программ, откуда мы сможем читать
    return res;
}

void ProgLoader::saveUserProg(const QString &name)
{
    ///TODO
    /// по сути тут должен быть сэйв кар стэйт но с указнием другого id
    /// и добавление записив таблицу имён юзверских программ

}

void ProgLoader::deleteUserProg(int id)
{
    ///TODO
    /// надо удалить запись в таблице листов и в таблице имён программ
    /// может быть для удаления сделать коммит по закрытию базы???
    ///
}

std::map<int, std::map<int, Onyx::InstrInfo> > ProgLoader::getConstraints(const QList<int>& idList)
{
    std::map<int, std::map<int, Onyx::InstrInfo> > result;
    QString queryCondition = "Mode_ID = %1";

    for (int i : idList) {
        QList<QVariantList> intstrListForMode = m_dbReaderPtr->slotSendSelectQuery(QStringList{"ModInstr"},
                                                                            QStringList{"Instr_ID","Min_Power","Mid_Power","Max_Power"},
                                                                            queryCondition.arg(i));
        std::map<int, Onyx::InstrInfo>& modeMap = result[i];
        for (const auto& item : intstrListForMode) {
            int a = item.at(0).toInt();
            int b = item.at(1).toInt();
            int c = item.at(2).toInt();
            int d = item.at(3).toInt();
            Onyx::InstrInfo bla = Onyx::InstrInfo(a,
                                      b,
                                      c,
                                      d);
            modeMap[a] = bla;
        }
    }
    return result;
}

std::map<int, InstrPtr > ProgLoader::getInstrums()
{
    std::map<int, InstrPtr> result;
    QList<QVariantList> instrListForMode = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Instruments"},
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

void ProgLoader::setSocketModelPtr(QSharedPointer<SocketModel> newSocketModelPtr)
{
    m_socketModelPtr = newSocketModelPtr;
}

bool ProgLoader::loadCurrentState()
{
    return programmLoadSocketInit(1000, true);
    // return ;
    /*

    // Проверяем, есть ли запись с id=1000
    QList<QVariantList> stateList = m_dbReaderPtr->slotSendSelectQuery(
        QStringList{"Lists"},
        QStringList{"Bi1Cut_INSTR", "Bi1Cut_MODE", "Bi1Cut_POWER",
                    "Bi1Coag_INSTR", "Bi1Coag_MODE", "Bi1Coag_POWER",
                    "Bi2Cut_INSTR", "Bi2Cut_MODE", "Bi2Cut_POWER",
                    "Bi2Coag_INSTR", "Bi2Coag_MODE", "Bi2Coag_POWER",
                    "Mono1Cut_INSTR", "Mono1Cut_MODE", "Mono1Cut_POWER",
                    "Mono1Coag_INSTR", "Mono1Coag_MODE", "Mono1Coag_POWER",
                    "Mono2Cut_INSTR", "Mono2Cut_MODE", "Mono2Cut_POWER",
                    "Mono2Coag_INSTR", "Mono2Coag_MODE", "Mono2Coag_POWER",
                    "Pedal_1", "Pedal_2", "OutEnabled_MASK", "Num"},
        "id = 1000"
    );
//последнее состояние - всегда 5 листов, просто не все заняты
    if (stateList.isEmpty() || stateList.size() != 5) {
        // qDebug() << "No saved state found (id=1000), using defaults";
        return;
    }
    // m_socketModelPtr->bl
    // for (int i = 0; i < 5; ++i) {
    //     const QVariantList& state = stateList.at(i);
    // }

    const QVariantList& state = stateList.at(0);

    // Проверяем, что в state достаточно полей (минимум 24 для сокетов)
    if (state.size() < 24) {
        // qWarning() << "Invalid state data: expected at least 24 fields, got" << state.size();
        return;
    }

    // Восстанавливаем состояние для каждого сокета
    for (int i = 0; i < 4; i++) {
        int baseIdx = i * 6;  // Каждый сокет занимает 6 полей

        // Резка - парсим строку (может быть пустой или содержать ID)
        QString cutInstrStr = state.at(baseIdx + 0).toString();
        QString cutModeStr = state.at(baseIdx + 1).toString();
        int cutPower = state.at(baseIdx + 2).toInt();

        // Коагуляция
        QString coagInstrStr = state.at(baseIdx + 3).toString();
        QString coagModeStr = state.at(baseIdx + 4).toString();
        int coagPower = state.at(baseIdx + 5).toInt();

        // Парсим ID (берём первое значение, если список через запятую)
        int cutInstrId = cutInstrStr.isEmpty() ? 0 : cutInstrStr.split(',').first().toInt();
        int cutModeId = cutModeStr.isEmpty() ? 1000 : cutModeStr.split(',').first().toInt();
        int coagInstrId = coagInstrStr.isEmpty() ? 0 : coagInstrStr.split(',').first().toInt();
        int coagModeId = coagModeStr.isEmpty() ? 1000 : coagModeStr.split(',').first().toInt();

        // Проверяем мощность
        cutPower = std::max(1, cutPower);
        coagPower = std::max(1, coagPower);

        auto socket = m_socketModelPtr->itemsMap()->at(i);

        if (socket.isNull()) {
            // qWarning() << "Socket" << i << "is null, skipping restore";
            continue;
        }

        // Устанавливаем режимы
        socket->setModeId(cutModeId, false);
        socket->setModeId(coagModeId, true);

        // Проверка для эндоскопических режимов: округление и валидация значений
        auto cutMode = socket->curCutMode();
        if (!cutMode.isNull() && cutMode->isEndo()) {
// если поделим инт на 10.0, округлим вниз и скастим к инту - будем целочисленное деление на 10
            // int endoCut = static_cast<int>(std::floor(cutPower / 10.0));
            int endoCut = cutPower / 10;
            int endoCoag = cutPower % 10;
            if (endoCut < 1) endoCut = 1;
            else if (endoCut > ENDO_MAX) endoCut = ENDO_MAX;
            if (endoCoag < 1) endoCoag = 1;
            else if (endoCoag > ENDO_MAX) endoCoag = ENDO_MAX;
            cutPower = endoCut * 10 + endoCoag;
        }

        auto coagMode = socket->curCoagMode();
        if (!coagMode.isNull() && coagMode->isEndo()) {
            int endoCut = cutPower / 10;
            int endoCoag = coagPower % 10;
            if (endoCut < 1) endoCut = 1;
            else if (endoCut > ENDO_MAX) endoCut = ENDO_MAX;
            if (endoCoag < 1) endoCoag = 1;
            else if (endoCoag > ENDO_MAX) endoCoag = ENDO_MAX;
            coagPower = endoCut * 10 + endoCoag;
        }

        // Устанавливаем мощность
        socket->setCutModePower(cutPower);
        socket->setCoagModePower(coagPower);

        // Устанавливаем инструменты
        socket->setInstrumId(cutInstrId, false);
        socket->setInstrumId(coagInstrId, true);
    }

    // Восстанавливаем педали
    if (state.size() >= 27) {
        int pedal1Socket = state.at(24).toInt();  // Номер сокета для single педали
        int pedal2Socket = state.at(25).toInt();  // Номер сокета для double педали

        // Устанавливаем педали напрямую в сокеты (без вызова dataChanged)
        for (int i = 0; i < 4; i++) {
            auto socket = m_socketModelPtr->itemsMap()->at(i);
            if (socket.isNull())
                continue;

            // Определяем тип педали для этого сокета
            int pedalType = Onyx::NO_PED;

            if (i == pedal1Socket) {
                pedalType = Onyx::SINGLE_PED;
            } else if (i == pedal2Socket) {
                pedalType = Onyx::DOUBLE_PED;
            }

            socket->setPedal(pedalType);
        }
        // TODO: Восстановить OutEnabled_MASK
        // int mask = state.at(26).toInt();
    }
    //поменяли напрочь всё
    emit m_socketModelPtr->dataChanged(QModelIndex(), QModelIndex(), {});
    */
}
