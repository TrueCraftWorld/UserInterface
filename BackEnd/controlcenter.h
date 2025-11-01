#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>
#include <QTimer>
#include <map>

#include "BackEnd/socketmodeeditor.h"
#include "socketmodel.h"
#include "databasereader.h"
#include "instrument.h"
#include "proghandle.h"
#include "surgicalmode.h"
#include "linkstm.h"





/**
 * @brief Управляющий класс бэкэнда, осуществляющий
 * композицию моделей данных и классов связи с железом
 */
class ControlCenter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointer<SocketModel> socketModel READ getSocketModel CONSTANT FINAL)
    Q_PROPERTY(QPointer<ProgHandle> handle READ getHandle CONSTANT FINAL)
    Q_PROPERTY(bool neutralElConnected READ neutralElConnected NOTIFY neutralElConnectedChanged)
    Q_PROPERTY(bool neutralElDivided READ neutralElDivided WRITE setNeutralElDivided NOTIFY neutralElDividedChanged)
    Q_PROPERTY(bool argonCylinder1Connected READ argonCylinder1Connected NOTIFY argonCylinder1ConnectedChanged)
    Q_PROPERTY(bool argonCylinder2Connected READ argonCylinder2Connected NOTIFY argonCylinder2ConnectedChanged)
    Q_PROPERTY(quint8 argonFlowRate READ argonFlowRate WRITE setArgonFlowRate NOTIFY argonFlowRateChanged)
    Q_PROPERTY(quint8 argonRealRate READ argonRealRate NOTIFY argonRealRateChanged)
    Q_PROPERTY(bool enableActivation READ enableActivation WRITE setEnableActivation NOTIFY enableActivationChanged)
    Q_PROPERTY(bool activation READ activation NOTIFY activationChanged)
    Q_PROPERTY(QString activeSocketName READ activeSocketName NOTIFY activeSocketNameChanged)
    Q_PROPERTY(QString activeModeName READ activeModeName NOTIFY activeModeNameChanged)
    Q_PROPERTY(int activePower READ activePower NOTIFY activePowerChanged)
    Q_PROPERTY(bool activeIsCoag READ activeIsCoag NOTIFY activeIsCoagChanged)
    Q_PROPERTY(int activeSocketX READ activeSocketX WRITE setActiveSocketX NOTIFY activeSocketXChanged)
    Q_PROPERTY(int activeSocketY READ activeSocketY WRITE setActiveSocketY NOTIFY activeSocketYChanged)
    Q_PROPERTY(int activeSocketWidth READ activeSocketWidth WRITE setActiveSocketWidth NOTIFY activeSocketWidthChanged)
    Q_PROPERTY(int activeSocketHeight READ activeSocketHeight WRITE setActiveSocketHeight NOTIFY activeSocketHeightChanged)
    Q_PROPERTY(int activeSocketId READ activeSocketId NOTIFY activeSocketIdChanged FINAL)
public:
    explicit ControlCenter(QObject *parent = nullptr);
    ~ControlCenter();

    /**
     * @brief выполянет регистрацию класса в qml
     */
    static void registerControl();

    /**
     * @brief возвращает указатель на модель сокетов, используемоую для
     * отображения и редактирования текущих режимов
     * @return
     */
    Q_INVOKABLE QPointer<SocketModel> getSocketModel() const;

    /**
     * @brief возвращает указатель на класс-редактор
     * сокета для внемения изменений через QML
     * @return
     */
    QPointer<SocketModeEditor> editor() const;
    
    /**
     * @brief Возвращает состояние подключения нейтрального электрода
     * @return true если НЭ подключён, false если нет
     */
    bool neutralElConnected() const;
    
    /**
     * @brief Возвращает тип нейтрального электрода
     * @return true если разделённый, false если единый
     */
    bool neutralElDivided() const;
    
    /**
     * @brief Устанавливает тип нейтрального электрода
     * @param divided true если разделённый, false если единый
     */
    void setNeutralElDivided(bool divided);
    
    /**
     * @brief Возвращает статус подключения баллона аргона №1
     * @return true если баллон подключён, false если нет
     */
    bool argonCylinder1Connected() const;
    
    /**
     * @brief Возвращает статус подключения баллона аргона №2
     * @return true если баллон подключён, false если нет
     */
    bool argonCylinder2Connected() const;
    
    /**
     * @brief Возвращает скорость потока аргона
     * @return значение скорости потока аргона
     */
    quint8 argonFlowRate() const;
    
    /**
     * @brief Устанавливает скорость потока аргона
     * @param rate значение скорости потока аргона
     */
    void setArgonFlowRate(quint8 rate);
    
    /**
     * @brief Возвращает реальную скорость потока аргона
     * @return значение реальной скорости потока аргона
     */
    quint8 argonRealRate() const;
    
    /**
     * @brief Возвращает состояние разрешения активации
     * @return true если активация разрешена, false если запрещена (открыты popup)
     */
    bool enableActivation() const;
    
    /**
     * @brief Устанавливает состояние разрешения активации
     * @param enable true для разрешения, false для запрета
     */
    void setEnableActivation(bool enable);
    
    /**
     * @brief Возвращает состояние активации
     * @return true если активация выполняется, false если нет
     */
    bool activation() const;
    
    /**
     * @brief Возвращает имя активного сокета
     */
    QString activeSocketName() const;
    
    /**
     * @brief Возвращает имя активного режима
     */
    QString activeModeName() const;
    
    /**
     * @brief Возвращает мощность активного режима
     */
    int activePower() const;
    
    /**
     * @brief Возвращает тип активного режима (коагуляция/резка)
     */
    bool activeIsCoag() const;
    
    /**
     * @brief Возвращает X-координату активного сокета
     */
    int activeSocketX() const;
    
    /**
     * @brief Возвращает Y-координату активного сокета
     */
    int activeSocketY() const;
    
    /**
     * @brief Возвращает ширину активного сокета
     */
    int activeSocketWidth() const;
    
    /**
     * @brief Возвращает высоту активного сокета
     */
    int activeSocketHeight() const;
    
    /**
     * @brief Возвращает ID активного сокета
     */
    int activeSocketId() const;

    void setActiveSocketX(int x);
    void setActiveSocketY(int y);
    void setActiveSocketWidth(int width);
    void setActiveSocketHeight(int height);

    /**
     * @brief инициализация - чтение предыдущих настроек, загрузка режимов из БД и т.д.
     */
    void init();

    Q_INVOKABLE QPointer<ProgHandle> getHandle() const;
    
    /**
     * @brief Сохраняет текущее состояние всех сокетов в БД (таблица Lists, id=1000)
     */
    Q_INVOKABLE void saveCurrentState();
    
    /**
     * @brief Загружает последнее сохранённое состояние из БД
     */
    void loadCurrentState();
    
    /**
     * @brief Запускает отложенное сохранение (с задержкой 2 секунды)
     * Используется для частых изменений (мощность) чтобы не перегружать БД
     */
    Q_INVOKABLE void scheduleSave();
    
    /**
     * @brief Устанавливает указатель на объект LinkStm для UART-коммуникации
     * @param linkStm Указатель на объект LinkStm
     */
    void setLinkStm(LinkStm* linkStm);

private:
    const int ENDO_MAX = 3;
    bool m_argonCylinder1Connected;         // Подключение баллона 1
    bool m_argonCylinder2Connected;         // Баллона 2
    bool m_autoStStopTissue;                // Захвачена ткань в режиме АСС
    bool m_neutralElConnected;              // НЭ подключён
    bool m_neutralElDivided;                // НЭ разделённый
    quint8 m_autoSSmode;                    // Режим AutoStop
    quint8 m_argonFlowRate;                 // Скорость потока аргона (установленная)
    quint8 m_argonRealRate;                 // Реальная скорость потока аргона
    quint8 m_wirelessPedalCharge;           // Заряд беспроводной педали
    bool m_enableActivation;                // Запрет активации (открыты popup)
    bool m_activation;                      // Активация выполняется
    QString m_activeSocketName;             // Имя активного сокета
    QString m_activeModeName;               // Имя активного режима
    int m_activePower;                      // Мощность активного режима
    bool m_activeIsCoag;                    // Тип активного режима
    int m_activeSocketX;                    // X-координата активного сокета
    int m_activeSocketY;                    // Y-координата активного сокета
    int m_activeSocketWidth;                 // Ширина активного сокета
    int m_activeSocketHeight;                // Высота активного сокета
    int m_activeSocketId;                    // ID активного сокета


    void makeHandleConnections();
    QPointer<SocketModel> m_socketModel;
    QPointer<SocketModeEditor> m_editor;
    QPointer<ProgHandle> m_handle;
    QPointer<DataBaseReader> m_dbReader;
    QPointer<LinkStm> m_linkStm;
    
    /**
     * @brief Обработчик входящих UART-данных
     * @param rxData Указатель на принятую команду
     */
    void uartChat(LinkStm::UartRx* rxData);
    void uartError(quint8 errorState);
    void initializeAllSocketsInLinkStm();
    void onStartActivation(quint8 socketId, bool isCut);
    void onStopActivation(quint8 stopReason);
    
    void initComms();
    void initSockets();
    void readConfigs();
    void prepareConnectios();

    bool readPreviousSocketSettings();

    void defaultSocketInit();
    void dataBaseSocketInit();
    void removeSubProg(int index);

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
     *         6.1 - для каждого полусокета прореживание списка режимов
     *         6.2 - для каждого полусокета прореживания списка инструментов
     *         6.3 инициализация сокета полученным списком допустимыз режимов и инструментов
     *         6.4 установка режима, мощностии и инструмента по умолчанию
     */
    void programmLoadSocketInit(int progId, bool clear = true);

    /**
     * @brief getListOfPrograms получение списка доспуных программ в категории
     * @param scopeID
     * @return
     */
    QMap<int, QString> getListOfPrograms(int scopeID);

    QMap<int, QString> getScopes();

    std::map<int, std::map<int, InstrInfo>> getConstarints(const QList<int> &idList);
    std::map<int, InstrPtr> getInstrums();
    
    QTimer* m_saveTimer = nullptr;  // Таймер для отложенного сохранения
    
//    void setNeutralElConnected(bool connected);
    void unitStateHandler(LinkStm::UnitState state);
    void setArgonRealRate(quint8 rate);
    void setActivation(bool active);
    void setActiveSocketName(const QString& name);
    void setActiveModeName(const QString& name);
    void setActivePower(int power);
    void setActiveIsCoag(bool isCoag);
    void setActiveSocketId(int socketId);

signals:
    void neutralElConnectedChanged(bool connected);
    void neutralElDividedChanged(bool divided);
    void argonCylinder1ConnectedChanged(bool connected);
    void argonCylinder2ConnectedChanged(bool connected);
    void argonFlowRateChanged(quint8 rate);
    void argonRealRateChanged(quint8 rate);
    void enableActivationChanged(bool enable);
    void activationChanged(bool active);
    void activeSocketNameChanged(const QString& name);
    void activeModeNameChanged(const QString& name);
    void activePowerChanged(int power);
    void activeIsCoagChanged(bool isCoag);
    void activeSocketXChanged(int x);
    void activeSocketYChanged(int y);
    void activeSocketWidthChanged(int width);
    void activeSocketHeightChanged(int height);
    void activeSocketIdChanged(int socketId);
};

#endif // CONTROLCENTER_H
