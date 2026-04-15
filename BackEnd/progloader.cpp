#include "progloader.h"
#include "BackEnd/recomprogloader.h"
#include "BackEnd/userprogloader.h"
#include "socket.h"
#include "onyxapp.h"

// #include <iostream>
#include <unordered_set>
#include <vector>
#include <QDebug>
#include <cstdlib>  // для abs()


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
               const std::vector<int>& instrFilter = std::vector<int>(),
               bool skipInstrFilter = false) {
    int start = isCoag ? 6 : 3;

    container.insert(1000, SurgModePtr::create(ESHF::modesNames.last(),
                                                                   isCoag,
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

        // Применяем фильтр только если skipInstrFilter = false
        if (!skipInstrFilter) {
            if (!instrFilter.empty()) {
                filterMapByKey(tmp, instrFilter);
            } else {
                filterMapByKey(tmp, parseCommaSeparatedNumbers(progItem.at(start + 6*socketNum).toString()));
            }
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

    // Вычисляем 10^digitPosition целочисленным способом (без pow)
    int powerOf10 = 1;
    for (int i = 0; i < digitPosition; ++i) {
        powerOf10 *= 10;
    }

    // Делим число на 10^digitPosition, чтобы перенести нужный разряд в конец
    int shiftedNumber = number / powerOf10;

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

QString makeDbStringMode( const QModelIndex& idx,
                                int listRole,
                                int firstItemRole) {
    QStringList list = idx.data(listRole).toStringList();
    int firstItem = idx.data(firstItemRole).toInt();
    list.removeOne(QString::number(firstItem));
    list.removeOne(QString::number(1000));
    list.prepend(QString::number(firstItem));
    return list.join(',');
}

QString makeDbStringInstr( const QModelIndex& idx,
                          int listRole,
                          int firstItemRole) {
    QStringList list = idx.data(listRole).toStringList();
    int firstItem = idx.data(firstItemRole).toInt();
    list.removeOne(QString::number(firstItem));
    list.prepend(QString::number(firstItem));
    return list.join(',');
}

    const QString queryConditionRecom = "Prog_ID = %1";
    const QString queryConditionUser = "User_ID = %1";
    const QStringList fields = {"id", "Num", "Prog_ID", /* 0 1 2*/
                          "Bi1Cut_INSTR", "Bi1Cut_MODE", "Bi1Cut_POWER", /* 3 4 5*/
                          "Bi1Coag_INSTR", "Bi1Coag_MODE", "Bi1Coag_POWER", /* 6 7 8*/
                          "Bi2Cut_INSTR", "Bi2Cut_MODE", "Bi2Cut_POWER", /* 9 10 11*/
                          "Bi2Coag_INSTR", "Bi2Coag_MODE", "Bi2Coag_POWER", /* 12 13 14*/
                          "Mono1Cut_INSTR", "Mono1Cut_MODE", "Mono1Cut_POWER", /* 15 16 17*/
                          "Mono1Coag_INSTR", "Mono1Coag_MODE", "Mono1Coag_POWER", /* 18 19 20*/
                          "Mono2Cut_INSTR", "Mono2Cut_MODE", "Mono2Cut_POWER", /* 21 22 23*/
                          "Mono2Coag_INSTR", "Mono2Coag_MODE", "Mono2Coag_POWER", /* 24 25 26*/
                          "Pedal_1", "Pedal_2", "OutEnabled_MASK"};/* 27 28 29*/
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
                                       "%28, 1000,"
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
    const   QString insertUserProgQuery = QString(
                                         "INSERT INTO Lists ("
                                         "Num, Prog_ID,"
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
                                         "%28, %29,"
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
    if (m_dbReaderPtr.isNull()) {
        OnyxApp* app = dynamic_cast<OnyxApp*>(qApp);
        if (app) {
            m_dbReaderPtr = app->getDbReader();
        }

    }
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
            cut[0] = makeDbStringInstr(idx, SocketModel::CutInstrIdList, SocketModel::CutModeInstrID);
            cut[1] = makeDbStringMode(idx, SocketModel::CutModeIdList, SocketModel::CutModeId);
            if (!cut[0].isEmpty() && !cut[1].isEmpty())
                cut[2] = QString::number(idx.data(SocketModel::CutModePower).toInt());

            coag[0] = makeDbStringInstr(idx, SocketModel::CoagInstrIdList, SocketModel::CoagModeInstrID);
            coag[1] = makeDbStringMode(idx, SocketModel::CoagModeIdList, SocketModel::CoagModeId);
            if (!coag[0].isEmpty() && !coag[1].isEmpty())
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
    // qDebug() << "saving N pages - " << subCount;
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
            // qDebug() << "Failed to save current state";
        }
    }
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
                    int endoCut = defaultPower / 10;  // Целочисленное деление вместо floor
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
    if (m_dbReaderPtr.isNull()) {
        return false;
    }
    
    qWarning() << "programmLoadSocketInit вызван с progId:" << progId;
    
    QList<QVariantList> progInfo = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Progs"},
                                                  QStringList{"Name_RU", "Scope_ID"},
                                                  QString("id = %1").arg(progId));
    qWarning() << "Получено строк:" << progInfo.size();
    
    if (!progInfo.isEmpty()) {
        QString progName = progInfo.first().at(0).toString();
        int scopeId = progInfo.first().at(1).toInt();
        qWarning() << "Найдена программа:" << progName << "ScopeId:" << scopeId << "ProgId:" << progId;
        
        if (scopeId >= 1000) {
            m_currentLoadedProgName = progName;
            m_currentLoadedScopeId = scopeId;
            qWarning() << "Это пользовательская программа (scopeId >= 1000), сохраняем название";
        } else {
            qWarning() << "Это рекомендованная программа (scopeId < 1000), сбрасываем saved name/scope";
            m_currentLoadedProgName.clear();
            m_currentLoadedScopeId = -1;
        }
    } else {
        qWarning() << "Запрос не вернул данных для progId:" << progId;
        m_currentLoadedProgName.clear();
        m_currentLoadedScopeId = -1;
    }
    
    //начинаем прорабатывать прогрузку несекольких экранов
    std::vector<std::map<int, SockPtr>> socketMapVector;
    std::vector<std::map<int, InstrPtr >> instrMapVector;
    std::map<int, std::map<int, InstrInfo>>  instrumConstraints;

    QList<QVariantList> progListVariant;

    // Если progId = 0, создаём фиктивную запись программы
    progListVariant = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Lists"},
                                                      fields,
                                                      queryConditionRecom.arg(progId));
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
            || progItem.at(1).toInt() >= 5)
            continue;
        QList<int> allowedModesId;
        std::vector<int> allowedInstrId;

        //Шаг2---------------------------------------------------------
        if (progId < 1000) {
            QList<QVariantList> allowedModes
                    = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableModes"},
                                                         QStringList{"Mode_ID"},
                                                         QString("List_ID = %1").arg(progItem.at(0).toUInt()));
            for (const auto& item : allowedModes)
                allowedModesId.append(item.at(0).toInt());
        } else {
            std::vector<int> allowedModesId__;
        //просто разрешаем все назначенные инструменты и режимы, если такие допустимы на сокетах, без дополнительных масок
            for (int i = 0; i < 8; ++i) {
                QString allowed = progItem.at(4 + 3*i).toString();
                QStringList list = allowed.split(',');
                for (const auto& mode : list) {
                    allowedModesId__.push_back(mode.toInt());
                }
            }
            std::sort(allowedModesId__.begin(), allowedModesId__.end());
            if (allowedModesId__.size() > 1) {
                // std::unordered_set<int> check;
                auto last = std::unique(allowedModesId__.begin(), allowedModesId__.end());
                allowedModesId__.erase(last, allowedModesId__.end());
            }
            allowedModesId = QList<int>::fromVector(QVector<int>(allowedModesId__.begin(), allowedModesId__.end()));
        }
        // allowedModes

        //Шаг3---------------------------------------------------------
        if (progId < 1000) {
            QList<QVariantList> allowedInstr
                    = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableInstr"},
                                                           QStringList{"Instr_ID"},
                                                           QString("List_ID = %1").arg(progItem.at(0).toUInt()));

            for (const auto& item : allowedInstr) {
                allowedInstrId.push_back(item.at(0).toInt());
            }
        } else {
            std::vector<int> allowedInstrId__;
            for (int i = 0; i < 8; ++i) {
                // allowedInstrId__.push_back(progItem.at(3 + 3*i).toInt());
                QString allowed = progItem.at(3 + 3*i).toString();
                QStringList list = allowed.split(',');
                for (const auto& instr : list) {
                    allowedInstrId__.push_back(instr.toInt());
                }
            }
            std::sort(allowedInstrId__.begin(), allowedInstrId__.end());
            auto last = std::unique(allowedInstrId__.begin(), allowedInstrId__.end());
            allowedInstrId__.erase(last, allowedInstrId__.end());
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
                    int endoCut = defaultPower / 10;  // Целочисленное деление вместо floor
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

            int monoPedSocket = progItem.at(27).toInt();
            if (i == monoPedSocket) {
                socket->setPedal(Onyx::SINGLE_PED);
            }
            int doubePedSocket = progItem.at(27).toInt();
            if (i == doubePedSocket) {
                socket->setPedal(Onyx::SINGLE_PED);
            }

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
    m_currentLoadedProgId = progId;
    return (true);
}

bool ProgLoader::freeSettingsSocketInit(bool clear)
{
    if (m_dbReaderPtr.isNull()) {
        return false;
    }
    
    std::vector<std::map<int, SockPtr>> socketMapVector;
    std::vector<std::map<int, InstrPtr >> instrMapVector;
    
    QList<QVariantList> modeNamesListV = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
                                                                        QStringList{"Name_RU","id"},
                                                                        "");
    QStringList modeNamesList;
    for (const auto& iter : modeNamesListV)
        modeNamesList.append(iter.at(0).toString());
    
    socketMapVector.push_back(std::map<int, SockPtr>());
    std::map<int, SockPtr>& socketMap = socketMapVector[socketMapVector.size() - 1];
    
    for (int i = 0; i < 4; ++i) {
        Onyx::SocType type = Onyx::SocType(i+1);
        SockPtr socket = SockPtr::create(type);
        socketMap[i] = socket;
        
        socket->setSocketName(makeSocketName(type));
        
        for (int halfSocket = 0; halfSocket < 2; ++halfSocket) {
            bool isCoag = (halfSocket == 0);
            QMap<int, SurgModePtr> modes;
            
            QString queryConditionModes = "BI_MONO = %1 AND CUT_COAG = %2";
            QList<QVariantList> modesList = m_dbReaderPtr->slotSendSelectQuery(
                        QStringList{"Modes"},
                        QStringList{"MaxPower","Name_RU", "id", "Num",
                                    "Brief_RU", "Descript_RU", "ENDO_REG"},
                        queryConditionModes
                                    .arg(socket->socketType() <= Onyx::BIPOLAR_2 ? 0 : 1)
                                    .arg(halfSocket));
            
            std::sort(modesList.begin(), modesList.end(),
                [](const QVariantList& a, const QVariantList& b) {
                    return a.at(3).toInt() < b.at(3).toInt();
                });
            
            QList<int> allModesId;
            for (const auto& mode : modesList) {
                allModesId.append(mode.at(2).toInt());
            }
            
            std::map<int, std::map<int, Onyx::InstrInfo>> instrumConstraints = getConstraints(allModesId);
            
            makeModes(modes, modesList, instrumConstraints, QVariantList(), i, isCoag, {}, true);
            
            if (i == 0 && modes.contains(7)) {
                modes.remove(7);
            }
            
            isCoag ? socket->setCoagModes(modes, modeNamesList)
                   : socket->setCutModes(modes, modeNamesList);
            
            int firstModeId = 1000;
            if (!modes.isEmpty() && modes.firstKey() != 1000) {
                firstModeId = modes.firstKey();
            }
            
            socket->setModeId(firstModeId, isCoag);
            socket->setInstrumId(1000, isCoag);
            isCoag ? socket->setCoagModePower(1) : socket->setCutModePower(1);
        }
        
        socket->setAllowed(true);
        socket->setDisplayMode(Onyx::S_COLLAPSED);
    }
    
    instrMapVector.push_back(getInstrums());
    
    if (socketMapVector.empty())
        return false;
    
    m_socketModelPtr->loadProgs(socketMapVector, instrMapVector, !clear);
    m_currentLoadedProgId = -1;
    m_currentLoadedProgName.clear();
    m_currentLoadedScopeId = -1;
    return true;
}

std::map<int, QString> ProgLoader::getProgs(int scopeID)
{
    //захардкодили, но это нужно знать
    const std::unique_ptr<ProgLoaderBase> loader{getLoader(m_curLoaderType)};
    return loader->getPrograms(scopeID);
}

std::map<int, QString> ProgLoader::getCategories()
{
    const std::unique_ptr<ProgLoaderBase> loader{getLoader(m_curLoaderType)};
    return loader->getCategories();
}

void ProgLoader::deleteUserProg(int id)
{
    QString removeQuery = "DELETE FROM Lists WHERE Prog_ID = %1";
    m_dbReaderPtr->executeUpdateQuery(removeQuery.arg(id));

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

void ProgLoader::saveUserProg(const QString &scopeName, const QString &progName)
{
    if (m_socketModelPtr == nullptr
        || m_socketModelPtr->itemsMap() == nullptr) {
        // qWarning() << "Cannot save state: socket model not initialized";
        return;
    }
    qWarning() << "=== ProgLoader::saveUserProg начало ===" << scopeName << progName;
    qWarning() << "currentLoadedProgId:" << m_currentLoadedProgId;
    qWarning() << "m_currentLoadedProgName:" << m_currentLoadedProgName;
    qWarning() << "m_currentLoadedScopeId:" << m_currentLoadedScopeId;
    int idToUse = -1;
    int biggestKnownId = -1;

    auto getScopeId = [this](const QString& name, int& bigId) -> int {
        int res = -1;
        const std::unique_ptr<ProgLoaderBase> loader{getLoader(ptUser)};

        auto list = loader->getCategories();
        for (const auto& item : list) {
            if (item.second == name) {
                res = item.first;
                break;
            }
        }
        if (!list.empty()) {
            bigId = list.rbegin()->first;
        }
        return res;
    };

    int scopeId = getScopeId(scopeName, biggestKnownId);

    if (scopeId == -1) {
        //тут добавить новый скоуп
        const   QString insertUserProgNameQuery = QString(
                                         "INSERT INTO Scopes ("
                                         "id, Num, Name_RU, Name_EN, Name_ES"
                                         ") VALUES ("
                                         "%1, %1, '%2', '%2', '%2')");
        int id = biggestKnownId > 1000 ? biggestKnownId + 1 : 1001;
        if (!m_dbReaderPtr->executeUpdateQuery(insertUserProgNameQuery
                                                .arg(id)
                                                .arg(scopeName))) {
            qDebug() << "Failed to add new SCOPE";
            return;
        } else {
            m_dbReaderPtr->commit();
            scopeId = id;
        }
    }

    qWarning() << "scopeId:" << scopeId << "saved name:" << m_currentLoadedProgName << "saved scopeId:" << m_currentLoadedScopeId;

    // Логика обновления:
    // 1. Для пользовательских областей (scopeId >= 1000) сначала ищем программу
    //    с таким же именем и этим же scopeId в таблице Progs.
    // 2. Если находим – обновляем её (idToUse = найденный id), независимо от того,
    //    была ли она загружена из списка пользовательских или рекомендованных программ.
    // 3. Если не находим – создаём новую программу.
    if (scopeId >= 1000) {
        QList<QVariantList> existingProg = m_dbReaderPtr->slotSendSelectQuery(
                    QStringList{"Progs"},
                    QStringList{"id"},
                    QString("Name_RU = '%1' AND Scope_ID = %2").arg(progName).arg(scopeId));

        if (!existingProg.isEmpty()) {
            idToUse = existingProg.first().at(0).toInt();
            qWarning() << "ВНИМАНИЕ: будет перезаписана существующая пользовательская программа, ID:" << idToUse;
        } else {
            qWarning() << "Пользовательская программа с таким именем не найдена, создаем новую";
        }
    } else {
        qWarning() << "scopeId < 1000 (нерелевантно для пользовательских программ), создаем новую";
    }
    
    if (idToUse == -1) {
        const QString insertUserProgNameQuery = QString(
                                             "INSERT INTO Progs ("
                                             "Prog_NUM, Argon, Name_RU, Name_EN, Name_ES, Scope_ID, Sub_NUM"
                                             ") VALUES ("
                                             "0, 0, '%1', '%1', '%1', %2, 0)");

        if (!m_dbReaderPtr->executeUpdateQuery(insertUserProgNameQuery
                                                        .arg(progName)
                                                        .arg(scopeId))) {
            qDebug() << "Failed to add Prog";
            return;
        } else {
            m_dbReaderPtr->commit();
        }

        QList<QVariantList> progListVariant = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Progs"},
                                                      QStringList{"id", "Name_RU"},
                                                      QString("Scope_ID = %1 AND Name_RU = '%2'").arg(scopeId).arg(progName));
        
        if (progListVariant.isEmpty()) {
            qDebug() << "нету таких прог";
            return;
        }
        
        idToUse = progListVariant.first().at(0).toInt();
        qWarning() << "Создана новая программа с ID:" << idToUse;
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
            cut[0] = makeDbStringInstr(idx, SocketModel::CutInstrIdList, SocketModel::CutModeInstrID);
            cut[1] = makeDbStringMode(idx, SocketModel::CutModeIdList, SocketModel::CutModeId);
            if (!cut[0].isEmpty() && !cut[1].isEmpty()) {
                cut[2] = QString::number(idx.data(SocketModel::CutModePower).toInt());
            } else {
                cut[2] = "";
            }

            coag[0] = makeDbStringInstr(idx, SocketModel::CoagInstrIdList, SocketModel::CoagModeInstrID);
            coag[1] = makeDbStringMode(idx, SocketModel::CoagModeIdList, SocketModel::CoagModeId);
            if (!coag[0].isEmpty() && !coag[1].isEmpty()) {
                coag[2] = QString::number(idx.data(SocketModel::CoagModePower).toInt());
            } else {
                coag[2] = "";
            }

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

    // Удаляем старые записи для этой программы перед вставкой новых
    QString deleteOldListsQuery = QString("DELETE FROM Lists WHERE Prog_ID = %1").arg(idToUse);
    if (!m_dbReaderPtr->executeUpdateQuery(deleteOldListsQuery)) {
        qWarning() << "Failed to delete old Lists entries for Prog_ID:" << idToUse;
    } else {
        m_dbReaderPtr->commit();
        qWarning() << "Старые записи Lists удалены для Prog_ID:" << idToUse;
    }

    // Формируем SQL запрос для INSERT
// using SocketStrings = std::array<std::array<QString, 3>, 8>; //instrId, modeId, power

    qDebug() << "saving N Upages - " << subCount;
    for (int i = 0; i < subCount; ++i) {
        const SocketStrings & state = allStates.at(i);
        const std::pair<int, int> & pedalState = allPedals.at(i);
        QString query = insertUserProgQuery

        .arg(state.at(0).at(0) == "-1" ? "" : state.at(0).at(0))
            .arg(state.at(0).at(1) == "1000" ? "" : state.at(0).at(1))
                .arg(state.at(0).at(2))
        .arg(state.at(1).at(0) == "-1" ? "" : state.at(1).at(0))
            .arg(state.at(1).at(1) == "1000" ? "" : state.at(1).at(1))
                .arg(state.at(1).at(2))
        .arg(state.at(2).at(0) == "-1" ? "" : state.at(2).at(0))
            .arg(state.at(2).at(1) == "1000" ? "" : state.at(2).at(1))
                .arg(state.at(2).at(2))
        .arg(state.at(3).at(0) == "-1" ? "" : state.at(3).at(0))
            .arg(state.at(3).at(1) == "1000" ? "" : state.at(3).at(1))
                .arg(state.at(3).at(2))
        .arg(state.at(4).at(0) == "-1" ? "" : state.at(4).at(0))
            .arg(state.at(4).at(1) == "1000" ? "" : state.at(4).at(1))
                .arg(state.at(4).at(2))
        .arg(state.at(5).at(0) == "-1" ? "" : state.at(5).at(0))
            .arg(state.at(5).at(1) == "1000" ? "" : state.at(5).at(1))
                .arg(state.at(5).at(2))
        .arg(state.at(6).at(0) == "-1" ? "" : state.at(6).at(0))
            .arg(state.at(6).at(1) == "1000" ? "" : state.at(6).at(1))
                .arg(state.at(6).at(2))
        .arg(state.at(7).at(0) == "-1" ? "" : state.at(7).at(0))
            .arg(state.at(7).at(1) == "1000" ? "" : state.at(7).at(1))
                .arg(state.at(7).at(2))
        .arg(pedalState.first).arg(pedalState.second).arg(outEnabledMask).arg(i+1).arg(idToUse);

        qDebug() <<query;
        if (!m_dbReaderPtr->executeUpdateQuery(query)) {
            qWarning() << "Failed to save userProg";
        }
    }
    
    m_dbReaderPtr->commit();
    qWarning() << "Программа сохранена с ID:" << idToUse;
}

void ProgLoader::deleteAllUserProgs()
{
    if (m_dbReaderPtr.isNull()) {
        qWarning() << "Cannot delete user progs: database not initialized";
        return;
    }
    
    QList<QVariantList> userProgs = m_dbReaderPtr->slotSendSelectQuery(
        QStringList{"Progs"},
        QStringList{"id"},
        "Scope_ID >= 1000");
    
    qWarning() << "Найдено пользовательских программ:" << userProgs.size();
    
    for (const auto& prog : userProgs) {
        int progId = prog.at(0).toInt();
        
        QString deleteListsQuery = QString("DELETE FROM Lists WHERE Prog_ID = %1").arg(progId);
        if (!m_dbReaderPtr->executeUpdateQuery(deleteListsQuery)) {
            qWarning() << "Failed to delete Lists for prog ID:" << progId;
        }
    }
    
    QString deleteProgsQuery = "DELETE FROM Progs WHERE Scope_ID >= 1000";
    if (!m_dbReaderPtr->executeUpdateQuery(deleteProgsQuery)) {
        qWarning() << "Failed to delete user programs";
    } else {
        m_dbReaderPtr->commit();
        qWarning() << "Все пользовательские программы удалены";
    }
}

ProgLoaderBase *ProgLoader::getLoader(progType type)
{

    switch (type) {
    case ptRecom:
        return new RecomProgLoader();
    case ptUser:
        return new UserProgLoader();
    default:
        break;
    }
    return nullptr;
}

void ProgLoader::setSocketModelPtr(QSharedPointer<SocketModel> newSocketModelPtr)
{
    m_socketModelPtr = newSocketModelPtr;
}

int ProgLoader::addUserScope(const QString &name)
{
    const   QString insertUserProgNameQuery = QString(
                                     "INSERT INTO Scopes ("
                                     "id, Num, Name"
                                     ") VALUES ("
                                     "'%1', '%1', '%2')");

    int scopeId = -1;
    QVariantList scope;
    {
        QList<QVariantList> scopes = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Scopes"},
                                              QStringList{"id", "Name"},
                                              "");
        int lastIndex = scopes.last().at(0).toInt();
        if (lastIndex < 1000) {
            scopeId = 1000;
        } else {
            scopeId = lastIndex + 1;
        }
    }
    if (scopeId == -1) {
        return scopeId;
    }
    if (!m_dbReaderPtr->executeUpdateQuery(insertUserProgNameQuery.arg(scopeId).arg(name))) {
        qDebug() << "Failed to save new scope";
        return scopeId;
    }
    m_dbReaderPtr->commit();
    return scopeId;
}

bool ProgLoader::loadCurrentState()
{
    if (m_socketModelPtr.isNull())
        return false;
    qWarning() << "loadCurrentState вызван, сбрасываем saved name/scope";
    bool res = programmLoadSocketInit(1000, true);
    m_currentLoadedProgId = 1000;
    m_currentLoadedProgName.clear();
    m_currentLoadedScopeId = -1;
    return res;
}

void ProgLoader::setCurLoaderType(progType newCurLoaderType)
{
    m_curLoaderType = newCurLoaderType;
}

