#include "progloader.h"
#include "socket.h"
#include <unordered_set>
#include <cmath>


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
        socketName = QString("БИ 1");
        break;
    case SOCKET::BIPOLAR_2:
        socketName = QString("БИ 2");
        break;
    case SOCKET::MONOPOLAR_1:
        socketName = QString("МОНО 1");
        break;
    case SOCKET::MONOPOLAR_2:
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
                          "Pedal_1", "Pedal_2", "OutEnabled_MASK"};/* 27 28 29*/

}

ProgLoader::ProgLoader(QObject *parent)
    : QObject{parent}
{
    if (m_dbReaderPtr.isNull())
            m_dbReaderPtr = new DataBaseReader("/home/kikorik/FOTEK/someShadyDB.db");
}

void ProgLoader::saveCurrentState()
{
    if (m_socketModelPtr == nullptr || m_socketModelPtr->itemsMap() == nullptr) {
        // qWarning() << "Cannot save state: socket model not initialized";
        return;
    }

    // Собираем данные из всех сокетов (инициализируем значениями по умолчанию)
    QString bi1CutInstr = "0", bi1CutMode = "1000", bi1CutPower = "1";
    QString bi1CoagInstr = "0", bi1CoagMode = "1000", bi1CoagPower = "1";
    QString bi2CutInstr = "0", bi2CutMode = "1000", bi2CutPower = "1";
    QString bi2CoagInstr = "0", bi2CoagMode = "1000", bi2CoagPower = "1";
    QString mono1CutInstr = "0", mono1CutMode = "1000", mono1CutPower = "1";
    QString mono1CoagInstr = "0", mono1CoagMode = "1000", mono1CoagPower = "1";
    QString mono2CutInstr = "0", mono2CutMode = "1000", mono2CutPower = "1";
    QString mono2CoagInstr = "0", mono2CoagMode = "1000", mono2CoagPower = "1";

    for (int i = 0; i < 4; i++) {
        auto socket = m_socketModelPtr->itemsMap()->at(i);

        // Проверяем, что режимы не null
        if (socket.isNull() || socket->curCutMode().isNull() || socket->curCoagMode().isNull()) {
            // qWarning() << "Socket" << i << "has null mode, skipping";
            continue;
        }

        int cutInstrId = socket->curCutMode()->selectedInstrId();
        int cutModeId = socket->cutModeId();
        int cutPower = socket->cutModePower();

        int coagInstrId = socket->curCoagMode()->selectedInstrId();
        int coagModeId = socket->coagModeId();
        int coagPower = socket->coagModePower();

        QString cutInstrStr = QString::number(cutInstrId);
        QString cutModeStr = QString::number(cutModeId);
        QString cutPowerStr = QString::number(cutPower);
        QString coagInstrStr = QString::number(coagInstrId);
        QString coagModeStr = QString::number(coagModeId);
        QString coagPowerStr = QString::number(coagPower);

        switch(i) {
            case 0: // БИ1
                bi1CutInstr = cutInstrStr;
                bi1CutMode = cutModeStr;
                bi1CutPower = cutPowerStr;
                bi1CoagInstr = coagInstrStr;
                bi1CoagMode = coagModeStr;
                bi1CoagPower = coagPowerStr;
                break;
            case 1: // БИ2
                bi2CutInstr = cutInstrStr;
                bi2CutMode = cutModeStr;
                bi2CutPower = cutPowerStr;
                bi2CoagInstr = coagInstrStr;
                bi2CoagMode = coagModeStr;
                bi2CoagPower = coagPowerStr;
                break;
            case 2: // МОНО1
                mono1CutInstr = cutInstrStr;
                mono1CutMode = cutModeStr;
                mono1CutPower = cutPowerStr;
                mono1CoagInstr = coagInstrStr;
                mono1CoagMode = coagModeStr;
                mono1CoagPower = coagPowerStr;
                break;
            case 3: // МОНО2
                mono2CutInstr = cutInstrStr;
                mono2CutMode = cutModeStr;
                mono2CutPower = cutPowerStr;
                mono2CoagInstr = coagInstrStr;
                mono2CoagMode = coagModeStr;
                mono2CoagPower = coagPowerStr;
                break;
            default:
                // qWarning() << "Invalid socket index:" << i;
                continue;
        }
    }

    // Получаем текущие педали
    int pedal1 = -1;  // Сокет с single педалью
    int pedal2 = -1;  // Сокет с double педалью

    // Ищем сокеты с привязанными педалями
    for (int i = 0; i < 4; i++) {
        auto socket = m_socketModelPtr->itemsMap()->at(i);
        if (socket.isNull())
            continue;

        int pedalType = socket->pedal();

        if (pedalType == Pedal::SINGLE_PED) {
            pedal1 = i;  // Номер сокета (0-3)
        } else if (pedalType == Pedal::DOUBLE_PED) {
            pedal2 = i;  // Номер сокета (0-3)
        }
        // INSTR_BUTTON_BI и INSTR_BUTTON_MONO игнорируем
    }

    // OutEnabled_MASK - битовая маска доступности полусокетов
    // TODO: если нужно сохранять доступность, добавить логику
    int outEnabledMask = 255;  // По умолчанию все включены (11111111)

    // Формируем SQL запрос для REPLACE (INSERT OR UPDATE)
    QString query = QString(
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
        "1000, 1, 1000, "
        "'%1', '%2', %3, "
        "'%4', '%5', %6, "
        "'%7', '%8', %9, "
        "'%10', '%11', %12, "
        "'%13', '%14', %15, "
        "'%16', '%17', %18, "
        "'%19', '%20', %21, "
        "'%22', '%23', %24, "
        "%25, %26, %27"
        ")")
        .arg(bi1CutInstr).arg(bi1CutMode).arg(bi1CutPower)
        .arg(bi1CoagInstr).arg(bi1CoagMode).arg(bi1CoagPower)
        .arg(bi2CutInstr).arg(bi2CutMode).arg(bi2CutPower)
        .arg(bi2CoagInstr).arg(bi2CoagMode).arg(bi2CoagPower)
        .arg(mono1CutInstr).arg(mono1CutMode).arg(mono1CutPower)
        .arg(mono1CoagInstr).arg(mono1CoagMode).arg(mono1CoagPower)
        .arg(mono2CutInstr).arg(mono2CutMode).arg(mono2CutPower)
        .arg(mono2CoagInstr).arg(mono2CoagMode).arg(mono2CoagPower)
        .arg(pedal1).arg(pedal2).arg(outEnabledMask);

    if (!m_dbReaderPtr->executeUpdateQuery(query)) {
        // qWarning() << "Failed to save current state";
    }
}

bool ProgLoader::readPreviousSocketSettings()
{
    ///todo REALIZE
    return false;
}

void ProgLoader::removeSubProg(int index)
{
    if (m_socketModelPtr.isNull())
        return;
    m_socketModelPtr->removeSubProg(index);
}

void ProgLoader::defaultSocketInit()
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
    instrumConstraints = getConstarints(allowedModesId);

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
                QMap<int, SurgModePtr> modes;
                QList<QVariantList> modesList = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
                            QStringList{"MaxPower","Name_RU", "id", "Num", "Brief_RU", "Descript_RU", "ENDO_REG"},
                            queryConditionModes
                                        .arg(socket->socketType() <= SOCKET::BIPOLAR_2 ? 0 : 1)
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
            socket->setDisplayMode(SOCKET::S_COLLAPSED);
        }
        instrMapVector.push_back(getInstrums());
    }

    m_socketModelPtr->loadProgs(socketMapVector, instrMapVector);
}

void ProgLoader::programmLoadSocketInit(int progId, bool clear)
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
        return;
    //--------------------------------------------------------------

    QList<int> allowedModesId;
    std::vector<int> allowedInstrId;

    //Шаг2---------------------------------------------------------
    QList<QVariantList> allowedModes = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableModes"},
                                                                      QStringList{"Mode_ID"},
                                                                      QString("Prog_ID = %1").arg(progId));
    for (const auto& item : allowedModes)
        allowedModesId.append(item.at(0).toInt());

    //Шаг3---------------------------------------------------------
    QList<QVariantList> allowedInstr = m_dbReaderPtr->slotSendSelectQuery(QStringList{"EnableInstr"},
                                                                       QStringList{"Instr_ID"},
                                                                       QString("Prog_ID = %1").arg(progId));

    for (const auto& item : allowedInstr)
        allowedInstrId.push_back(item.at(0).toInt());

    //Шаг4---------------------------------------------------------
    QString queryConditionModes = "BI_MONO = %1 AND CUT_COAG = %2 AND id IN (%3)";
    instrumConstraints = getConstarints(allowedModesId);

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
        socketMapVector.push_back(std::map<int, SockPtr>());
        std::map<int, SockPtr>& socketMap = socketMapVector[socketMapVector.size() - 1];
        for (int i = 0; i < 4; ++i) {
            SOCKET::SocType type = SOCKET::SocType(i+1);
            SockPtr socket = SockPtr::create(type);
            socketMap[i] = socket;

            socket->setSocketName(makeSocketName(type));

            for (int halfSocket = 0; halfSocket < 2; ++halfSocket ) {
                bool isCoag = (halfSocket == 0);
                QMap<int, SurgModePtr> modes;
                QList<QVariantList> modesList = m_dbReaderPtr->slotSendSelectQuery(QStringList{"Modes"},
                            QStringList{"MaxPower","Name_RU", "id", "Num", "Brief_RU", "Descript_RU", "ENDO_REG"},
                            queryConditionModes
                                        .arg(socket->socketType() <= SOCKET::BIPOLAR_2 ? 0 : 1)
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
                    if (endoCut < 1) endoCut = 1;
                    else if (endoCut > ENDO_MAX) endoCut = ENDO_MAX;
                    if (endoCoag < 1) endoCoag = 1;
                    else if (endoCoag > ENDO_MAX) endoCoag = ENDO_MAX;
                    defaultPower = endoCut * 10 + endoCoag;
                }

                isCoag ? socket->setCoagModePower(defaultPower)
                       : socket->setCutModePower(defaultPower);
            }
            bool coagEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) - 1 );
            bool cutEna = hasNonZeroDigit(progItem.at(29).toInt(), (8 - 2*i) );
            bool allowSock = cutEna || coagEna;
            socket->setAllowed(allowSock);
            socket->setDisplayMode(SOCKET::S_COLLAPSED);
        }
        instrMapVector.push_back(getInstrums());
    }

    m_socketModelPtr->loadProgs(socketMapVector, instrMapVector, !clear);
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

std::map<int, std::map<int, InstrInfo> > ProgLoader::getConstarints(const QList<int>& idList)
{
    std::map<int, std::map<int, InstrInfo> > result;
    QString queryCondition = "Mode_ID = %1";

    for (int i : idList) {
        QList<QVariantList> intstrListForMode = m_dbReaderPtr->slotSendSelectQuery(QStringList{"ModInstr"},
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

void ProgLoader::loadCurrentState()
{
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
                    "Pedal_1", "Pedal_2", "OutEnabled_MASK"},
        "id = 1000"
    );

    if (stateList.isEmpty()) {
        // qDebug() << "No saved state found (id=1000), using defaults";
        return;
    }

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
            int pedalType = Pedal::NO_PED;

            if (i == pedal1Socket) {
                pedalType = Pedal::SINGLE_PED;
            } else if (i == pedal2Socket) {
                pedalType = Pedal::DOUBLE_PED;
            }

            socket->setPedal(pedalType);
        }
        // TODO: Восстановить OutEnabled_MASK
        // int mask = state.at(26).toInt();
    }
    //поменяли напрочь всё
    emit m_socketModelPtr->dataChanged(QModelIndex(), QModelIndex(), {});
}
