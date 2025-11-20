#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>
#include <QTimer>

#include "BackEnd/socketmodeeditor.h"
#include "socketmodel.h"
#include "proghandle.h"
#include "progloader.h"
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
    // Q_PROPERTY(QPointer<ProgLoader> progLoader READ getLoader CONSTANT FINAL)
    Q_PROPERTY(bool neutralElConnected READ neutralElConnected NOTIFY neutralElConnectedChanged)
    Q_PROPERTY(bool neutralElDivided READ neutralElDivided WRITE setNeutralElDivided NOTIFY neutralElDividedChanged)
    Q_PROPERTY(quint8 argonFlowRate READ argonFlowRate WRITE setArgonFlowRate NOTIFY argonFlowRateChanged)
    Q_PROPERTY(quint8 argonRealRate READ argonRealRate NOTIFY argonRealRateChanged)
    Q_PROPERTY(bool enableActivation READ enableActivation WRITE setEnableActivation NOTIFY enableActivationChanged)
    Q_PROPERTY(bool activation READ activation NOTIFY activationChanged)
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
    
    // /**
    //  * @brief Устанавливает состояние разрешения активации
    //  * @param enable true для разрешения, false для запрета
    //  */
    void setEnableActivation(bool enable);
    
    // /**
    //  * @brief Возвращает состояние активации
    //  * @return true если активация выполняется, false если нет
    //  */
    bool activation() const;

    /**
     * @brief инициализация - чтение предыдущих настроек, загрузка режимов из БД и т.д.
     */
    void init();

    Q_INVOKABLE QPointer<ProgHandle> getHandle() const;
    
    // /**
    //  * @brief Сохраняет текущее состояние всех сокетов в БД (таблица Lists, id=1000)
    //  */
    // Q_INVOKABLE void saveCurrentState();
    
    // /**
    //  * @brief Загружает последнее сохранённое состояние из БД
    //  */
    // void loadCurrentState();
    
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
    // static constexpr int ENDO_MAX = 3;
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

    QSharedPointer<SocketModel> m_socketModel;
    QPointer<SocketModeEditor> m_editor;
    QPointer<ProgHandle> m_handle;
    QPointer<ProgLoader> m_progLoader;
    // QPointer<PeriphHandle> m_periphery;

    QPointer<LinkStm> m_linkStm;
    QTimer* m_saveTimer = nullptr;  // Таймер для отложенного сохранения

private:
    /**
     * @brief Обработчик входящих UART-данных
     * @param rxData Указатель на принятую команду
     */
    void makeHandleConnections();
    void uartChat(LinkStm::UartRx* rxData);
    void uartError(quint8 errorState);
    void initializeAllSocketsInLinkStm();
    void onStartActivation(quint8 socketId, bool isCut);
    void onStopActivation(quint8 stopReason);
    
    void initComms();
    void initSockets();
    void readConfigs();
    void prepareConnectios();
    
//    void setNeutralElConnected(bool connected);
    void unitStateHandler(LinkStm::UnitState state);
    void setArgonRealRate(quint8 rate);
    void setActivation(bool active, int socketId, bool isCoag);

signals:
    void neutralElConnectedChanged(bool connected);
    void neutralElDividedChanged(bool divided);
    void argonFlowRateChanged(quint8 rate);
    void argonRealRateChanged(quint8 rate);
    void enableActivationChanged(bool enable);
    void activationChanged(bool active);
};

#endif // CONTROLCENTER_H
