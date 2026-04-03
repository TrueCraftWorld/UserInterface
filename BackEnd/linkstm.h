#ifndef LINKSTM_H
#define LINKSTM_H

#include <QObject>
#include <QTimer>
#include <QTime>
#include <QQueue>
#include <QThread>
#include <QDebug>
#include <QVariant>
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
        ArgonBlow = 0x3F,               // Продувка газового тракта
        Signal = 0x80,                  // Выдача звукового сигнала (аварии)

        ErrorMU = 0x80,                 // Ошибка модуля управления
        CurrentVersion = 0xF0,          // Запрос версий ПО
        Erase_1 = 0xF1,                 // Стереть банк 1
        Erase_2 = 0xF2,                 // Стереть банк 2
        StartUpdate_1 = 0xF3,           // Начало передачи ПО для банка 1
        StartUpdate_2 = 0xF4,           // Начало передачи ПО для банка 2
        UpdateFinish = 0xF5,            // ПО передано - версия ПО
        SoftData = 0xF6,                // Данные прошивки
        GoBoot = 0xF7,                  // Переключение на загрузчик
        GoBank_1 = 0xF8,                // Переключение на банк 1
        GoBank_2 = 0xF9,                // Переключение на банк 2
        Reboot = 0xFA,                  // Перезагрузка stm
        NoTxCommand = 0xFF,
    };
    Q_ENUM(TxCommand);

    enum RxCommand : quint8 {           // Принимаемые команды
        Whatsup = 0x00,                 // Стандартный запрос
        GenActivation = 0x20,           // Посылка во время активации
        GenStop = 0x40,                 // Остановка активации
        SpecAnswer = 0x60,
        ErrRecieve = 0x80,              // Модуль связи не принимает сигналы
        ErrCrc = 0x81,                  // Ошибка CRC
        ErrGenRx = 0x82,                // Генератор не отвечает
        ErrArgRx = 0x83,                // Газовый модуль не отвечает
        ErrNeRx = 0x84,                 // Нейтральник не отвечает
        ErrSwingRx = 0x84,              // Раскачка не отвечает
        MyVersion = 0xF0,               // Версии ПО
        Erased_1 = 0xF1,                // Банк 1 стёрт
        Erased_2 = 0xF2,                // Банк 2 стёрт
        ReadyToUpdate_1 = 0xF3,         // Готов принять новую прошивку в банк 1
        ReadyToUpdate_2 = 0xF4,         // Готов принять новую прошивку в банк 2
        UpdateResult = 0xF5,            // Результаты обновления
        SoftDataAck = 0xF6,             // Принял данные прошивки
        BootAck = 0xF7,                 // Стандартный ответ загрузчика
        Start = 0xFA,                   // Запуск МК
//        NoRxCommand = 0xFB,
        RxErrData = 0xFC,               // Ошибка: не те данные для прошивки
    };
    Q_ENUM(RxCommand);

    enum MC : quint8 {                  // Микроконтроллеры (старшие три бита)
        MAIN = 0x00,                    // Основной (модуль связи)
        SUB1 = 0x20,                    // Подчинённый (модуль генератора, например)
        SUB2 = 0x40,                    // Подчинённый (модуль генератора, например)
        SUB3 = 0x60,                    // Подчинённый (модуль генератора, например)
        SUB4 = 0x80,                    // Подчинённый (модуль генератора, например)
        SUB5 = 0xA0,                    // Подчинённый (модуль генератора, например)
        SUB6 = 0xC0,                    // Подчинённый (модуль генератора, например)
        SUB7 = 0xE0,                    // Подчинённый (модуль генератора, например)

    };
    Q_ENUM(MC);

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

private slots:
    void sendCommand();

private:
    // Подготовка передачи команды
    QByteArray packTxCommand();
    // Вычисление контрольной суммы
    quint16 calculateCrc16(QByteArray &buffer, quint8 len);
    // Инициализация версий ПО МК
    void initMcVersions();
    // Установка версий ПО МК
    void setMcVersions(const UartRx &rxCom);
    // Расшифровка команды
    void unpackRxCommand(const QByteArray &rxPacket);
    // Проверка на соответствие
    bool checkRxCommand();
    // Команды для процесса обновления
    void setNextCommand();

    void readRxCommand();

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
    bool m_update;
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

};

#endif // LINKSTM_H
