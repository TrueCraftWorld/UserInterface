#ifndef LINKSTM_H
#define LINKSTM_H

#include <QObject>
#include <QTimer>
#include <QTime>
#include <QQueue>
#include <QThread>
#include <QDebug>
#include <QVariant>
#include <QElapsedTimer>
#include "uartqmlbridge.h"
#include "loggingcategories.h"
#include "Structures.h"

using namespace Onyx;

class LinkStm : public QObject
{
    Q_OBJECT
public:
    explicit LinkStm(QObject *parent = nullptr);
    enum TxCommand : quint8 {           // Передаваемые команды
        Allright = 0x00,                // Базовый запрос

        Activation = 0x20,              // Активация

        StopActivation = 0x40,          // Остановка активации

        AckNeutralResist = 0x61,        // Запрос сопротивления НЭ
        AckMonoHandleResist = 0x62,     // Запрос сопр. моно держателя
        AckBiHandleResist = 0x63,       // Запрос сопр. би держателя
        ReadMono2Id = 0x64,             // Прочитать данные в определителе Моно2
        ReadBi2Id = 0x65,               // Прочитать данные в определителе Би2
        WriteMono2Id = 0x66,            // Запись данных в определитель Моно2
        WriteBi2Id = 0x67,              // Запись данных в определитель Би2
        WirelessSearch = 0x68,          // Поиск беспроводных устройств
        TxAddrWireless = 0x69,          // Передача адреса для беспроводных устройств
        TxDataWireless = 0x6A,          // Передача данных для беспроводных устройств
        ArgonBlow = 0x6F,               // Продувка газового тракта

        SignalAlarm = 0x80,             // Выдача звукового сигнала (аварии)

        CurrentVersion = 0xE0,          // Запрос версий ПО
        Erase_1 = 0xE3,                 // Стереть банк 1
        Erase_2 = 0xE4,                 // Стереть банк 2
        StartUpdate_1 = 0xE5,           // Начало передачи ПО для банка 1
        StartUpdate_2 = 0xE6,           // Начало передачи ПО для банка 2
        SoftData = 0xE7,                // Данные прошивки
        UpdateFinish = 0xE8,            // ПО передано - версия ПО
        GoBoot = 0xE9,                  // Переключение на загрузчик
        GoBank_1 = 0xEA,                // Переключение на банк 1
        GoBank_2 = 0xEB,                // Переключение на банк 2
        Reboot = 0xEC,                  // Перезагрузка stm

        NoTxCommand = 0xFF
    };
    Q_ENUM(TxCommand);

    enum RxCommand : quint8 {           // Принимаемые команды
        Whatsup = 0x00,                 // Стандартная посылка

        GenActivation = 0x20,           // Посылка во время активации

        GenStop = 0x40,                 // Остановка активации
        GenStopХХ = 0x41,               // Остановка активации по холостому ходу в автостопе
        GenStopShort = 0x42,            // Остановка активации по короткому замыканию бранш
        GenStopNeBreak = 0x43,          // Остановка активации из-за обрыва НЭ
        GenStopNoArgon = 0x44,          // Остановка активации - закончился аргон
        GenStopBlockedArg = 0x45,       // Остановка активации - непроходимость газового тракта
        GenStopErr = 0x4F,              // Остановка активации из-за других ошибок

        SpecAnswer = 0x60,
        NeutralResist = 0x61,           // Сопротивление НЭ
        MonoHandleResist = 0x62,        // Сопротивление моно держателя
        BiHandleResist = 0x63,          // Сопротивление би держателя
        DataMono2Id = 0x64,             // Данные из определителя Моно2
        DataBi2Id = 0x65,               // Данные из определителя Би2
        ConfirmMono2Id = 0x66,          // Подтверждение записи данных в определитель Моно2
        ConfirmBi2Id = 0x67,            // Подтверждение записи данных в определитель Би2
        WirelessDetected = 0x68,        // Обнаружено беспроводное устройство
        ConfirmAddrWireless = 0x69,     // Подтверждение приёма адреса для беспроводных устройств
        DataWireless = 0x6A,            // Данные от беспроводного устройства

        ErrComm = 0x80,                 // Модуль связи не принимает сигналы от МИФ
        ErrGenComm = 0x81,              // Генератор не отвечает
        ErrArgComm = 0x82,              // Газовый модуль не отвечает
        ErrRadioModule = 0x83,          // Не отвечает радиомодуль
        ErrStuckButtons = 0x84,         // Кнопки или педали зажаты до старта
        ErrNeController = 0x85,         // МК НЭ не отвечает
        ErrRaskController = 0x86,       // МК раскачки не отвечает
        ErrPowerNe5V = 0x87,            // Питание НЭ 5В не соответствует норме
        ErrPowerNe3V3 = 0x88,           // Питание НЭ 3,3В не соответствует норме
        ErrNeOverheat = 0x89,           // Перегрев контроллера НЭ (выше 80)

        CritIsnStart = 0x90,            // Критичные ошибки - ИСН при включении
        CritAdc1Ucont = 0x91,           // Ошибка АЦП1 - напряжение контура
        CritAdc2Icont = 0x92,           // Ошибка АЦП2 - ток контура
        CritAdc3Igen = 0x93,            // Ошибка АЦП3 - ток генератора
        CritAdc4Uisn = 0x94,            // Ошибка АЦП4 - напряжение ИСН
        CritRelay = 0x95,               // Ошибка реле
        CritIsnWork = 0x96,             // Ошибка ИСН при нормальной работе
        CritNeResonance = 0x97,         // Не найден резонанс при калибровке НЭ
        CritAdcNe = 0x98,               // Ошибка АЦП схемы НЭ

        Version_0 = 0xE0,               // Версии ПО, рабочих прошивок нет
        Version_1 = 0xE1,               // Версии ПО, основная прошивка в банке 1
        Version_2 = 0xE2,               // Версии ПО, основная прошивка в банке 2
        Erased_1 = 0xE3,                // Банк 1 стёрт
        Erased_2 = 0xE4,                // Банк 2 стёрт
        ReadyToUpdate_1 = 0xE5,         // Готов принять новую прошивку в банк 1
        ReadyToUpdate_2 = 0xE6,         // Готов принять новую прошивку в банк 2
        SoftDataAck = 0xE7,             // Принял данные прошивки
        UpdateResult = 0xE8,            // Результаты обновления
        BootAck = 0xE9,                 // Стандартный ответ загрузчика
        Start = 0xEC,                   // Запуск МК
        UpdateError = 0xEF              // Ошибка обновления

    };
    Q_ENUM(RxCommand);

    enum UartState : quint8 {
        STATE_OK = 0,
        STATE_TX_ERR,                   // Ошибка передачи
        STATE_NO_RX,                    // Приёмник не отвечает
        STATE_RX_ERR,                   // Приёмник отвечает не то, что нужно
        STATE_RX_LEN_ERR,               // Не та длина посылки
        STATE_RX_CRC_ERR,               // crc не совпадает
    };
    Q_ENUM(UartState);

    enum BootChoice : quint8 {
        BOOT_0 = 0,
        BOOT_APP_1 = 1,
        BOOT_APP_2 = 2
    };
    Q_ENUM(BootChoice);

    enum McUnit : quint8 {
        MC_COM = 0,                       // Модуль управления и связи
        MC_ARG = 0x20,                    // Модуль аргоновый (1 << 5)
        MC_GEN = 0x40,                    // Модуль генератора (2 << 5)
        MC_RAS = 0x60,                    // Модуль раскачки (3 << 5)
        MC_NEL = 0x80                     // Модуль нейтральника (4 << 5)
    };
    Q_ENUM(McUnit);

    struct UartTx {
        quint8 com;
        QByteArray data;
        McUnit mc;
    };

    struct UartRx {
        RxCommand com;
        QByteArray data;
        McUnit mc;
    };

    struct McVersions {
        McUnit mc;
        quint8 bootVer;
        quint8 bootSubVer;
        quint8 app0Ver;
        quint8 app0SubVer;
        quint8 app1Ver;
        quint8 app1SubVer;
    };

    struct HexString {
        uint32_t addr;
        QByteArray data;
    };

    struct ActiveSocket {
        quint8 id;
        bool isCut;
        bool isEnable;
        bool is3rdKnob;
        bool autoMode;
    };

    enum CommunicationState : quint8 {      // Состояние обмена
        IDLE = 0,                           // По умолчанию - просто передача состояния
        START_ACTIVATION = 1,               // Запуск активации
        ACTIVATION = 2,                     // В режиме активации
        UPDATING = 3,                       // В режиме обновления ПО МК
        SPECIAL = 4                         // Спец посылки
    };
    Q_ENUM(CommunicationState);


    // Получить строку с шестнадцатиричными данными
    static QString getHexStr(QByteArray byteArray);
    // Последняя отправленная команда
    UartTx getLastCommand() const;
    // Состояние uart соединения
    const UartState &state() const;


    void setTxCommand(const UartTx &newTxCommand);

    void setTxCommandBoot();

    const UartRx &rxCommand() const;

    void updateTransfer(QList<LinkStm::HexString> hexList, int bank, QString versionStr);

    const BootChoice &boot() const;

    void setBoot(const BootChoice &newBoot);

    void setMc(const McUnit &newMc);

    /// Упаковать mcVersions в QVariantList и отправить в sigFirmwareVersionsChanged.
    void publishFirmwareVersions();

    // Методы для установки состояния из PeriphHandler
public slots:
    void start();
    /// Загрузка hex из файла (вызов из потока LinkStm). bankOrZero: 0 — неактивный банк относительно m_boot, иначе 1 или 2.
    void startFirmwareUpdateFromFile(const QString &filePath, int bankOrZero, const QString &versionStr, int mcUnitRaw);
    void argonBlow();
    void setEnableActivation(bool enable);
    void setNeutralElDivided(bool divided);
    void setAutoSSmode(quint8 mode);
    void setActivCylinderFirst(bool first);
    void setArgonFlowRate(quint8 rate);
    void updateSocketData(int socketIndex, quint16 cutModeNum, quint16 coagModeNum, 
                         quint16 cutModePower, quint16 coagModePower, quint8 pedal);
    void updateSocketData(int socketIndex, const Onyx::SocketState& info);
    void initializeAllSockets();

signals:
    //начинаем имена сигналов с sig или signal чтобы
    //при их наборе и автоподстановке было намного проще
    //их найти все, а не листать список полей и методов
    void sigUnitStateChanged(UnitState state);
//    void neutralElConnectedChanged(bool connected);
//    void txError();
//    void rxError();
    void sigRecieveData(UartRx* rxData);
    void sigError(quint8 error);
    void sigUpdateProgress(int progress);
    void sigReportTx(QString txStr);
    void sigReportRx(QString rxStr, int ms);
    void sigPressed3rdKnob(quint8 socket);
    void sigStartActivation(quint8 socket, bool isCut);
    void sigStopActivation(quint8 stopReason);
    /// Версии ПО модулей МК: список из 5 QVariantMap (числа для UI и сравнения с обновлениями).
    void sigFirmwareVersionsChanged(const QVariantList &modules);
    void firmwareUpdateParseError(const QString &message);

private slots:
    void sendCommand();

private:
    // Подготовка передачи команды
    QByteArray packTxCommand();
    // Вычисление контрольной суммы
    quint16 calculateCrc16(QByteArray &buffer, quint8 len);
    // Инициализация версий ПО МК
    void mcVersRequest();
    // Установка версий ПО МК
    void setMcVersions(const UartRx &rxCom);
    // Расшифровка команды
    void unpackRxCommand(const QByteArray &rxPacket);
    // Проверка на соответствие
    bool checkRxCommand();
    // Команды для процесса обновления
    void setNextCommand();

    void readRxCommand();
    void abortFirmwareUpdate(const QString &message);

    ActiveSocket determineSocket(const PedalKnobPressed &pedalKnob);

    void prepareDefaultCommand();
    // Проверка, есть ли команда уже в списке, чтобы не плодить дубликаты
    bool checkCommandList(const UartTx &newTxCommand);

    static const quint8 MAX_PACKET_LEN = 40;        // Длина пакета
     // Команды для байт-стаффинга
    static const quint8 FRAME_START = 0x8A;         // Начало посылки
    static const quint8 FRAME_ESCAPE_CHAR = 0x8B;   // Маскирующий символ
    static const quint8 FRAME_XOR_CHAR = 0x20;      // Значение для преобразования

    static const quint8 UART_ADDR = 0xE0;           // Маска адреса модуля в сети uart
    static const quint8 UART_LEN = 0x1F;            // Маска длины сообщения

private:
//    QByteArray* m_txPacket;
    UartTx m_lastCommand;
    QTimer* m_uartTimer;
    UartToQmlBridge* m_uart;
    UartState m_state;
    UartTx m_txCommand;
    UartRx m_rxCommand;
    /// Пока ждём ReadyToUpdate после StartUpdate — не подменять m_txCommand на Allright.
    bool m_fwUpdateAwaitingReady = false;
    int m_softSize;
    int m_transferredSize;
    QList<HexString> m_hexList;
    QString m_versionStr;
    QQueue<UartTx> m_txCommandQueue;
    QList<UartTx> m_txCommandList;
    bool m_waitAnswer;
    quint8 m_autoSSmode;
    BootChoice m_boot;
    McUnit m_mc;
    McVersions mcVersions[5];

    // Переменные состояния из ControlCenter
    bool m_enableActivation;
    bool m_neutralElDivided;
    quint8 m_argonFlowRate;
    bool m_activCylinderFirst;

    UnitState m_unitState;
    Onyx::SocketState m_socketList[4];
    CommunicationState m_comState;

    bool m_fwUpdateSessionActive = false;
    QElapsedTimer m_fwRxErrStreakTimer;
    bool m_abortFirmwareUpdatePending = false;
    bool m_moduleHasWorkingApp[5] = {true, true, true, true, true};
};

#endif // LINKSTM_H
