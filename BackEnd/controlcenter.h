#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>

#include "socketmodel.h"


/**
 * @brief Управляющий класс бэкэнда, осуществляющий
 * композицию моделей данных и классов связи с железом
 */
class ControlCenter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointer<SocketModel> socketModel READ getSocketModel CONSTANT FINAL)
    // Q_PROPERTY(WiFiListModel* wifiModel READ wifiModel CONSTANT FINAL)
public:
    explicit ControlCenter(QObject *parent = nullptr);
    ~ControlCenter();

    /**
     * @brief выполянет регистрацию класса в qml
     */
    static void registerControl();

    Q_INVOKABLE QPointer<SocketModel> getSocketModel() const;

    void init();
private:
    QPointer<SocketModel> m_socketModel;
    // some uart handler should be here
    void initComms();
    void initSockets();
    void readConfigs();
    void prepareConnectios();

    bool readPreviousSocketSettings();

    void defaultSocketInit();

signals:
};

#endif // CONTROLCENTER_H
