#include "controlcenter.h"
// #include "socket.h"
#include "proghandle.h"

// #include <algorithm>
// #include <cmath>
// #include <map>

#include <QQmlEngine>
#include <QString>
#include <QTimer>
#include <QDebug>
#include <QVector>
#include <QVariant>


ControlCenter::ControlCenter(QObject *parent)
    : QObject{parent},
    m_argonCylinder1Connected(false),
    m_argonCylinder2Connected(false),
    m_autoStStopTissue(false),
    m_neutralElConnected(false),
    m_neutralElDivided(true),
    m_autoSSmode(0),
    m_argonFlowRate(80),
    m_argonRealRate(0),
    m_activCylinderFirst(true),  // По умолчанию активен первый баллон
    m_wirelessPedalCharge(0),
    m_socketModel(new SocketModel()),
    m_editor(new SocketModeEditor(m_socketModel,this)),
    m_handle(new ProgHandle(this)),
    m_progLoader(new ProgLoader(this)),
    // m_dbReader(nullptr),
    m_linkStm(nullptr),
    m_saveTimer(new QTimer(this))
{
    QQmlEngine::setObjectOwnership(m_socketModel.data(), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_editor, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_handle, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_progLoader, QQmlEngine::CppOwnership);
    m_progLoader->setSocketModelPtr(m_socketModel);
    // QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    
    // Настройка таймера для отложенного сохранения
    m_saveTimer->setSingleShot(true);
    m_saveTimer->setInterval(2000);  // 2 секунды
    // connect(m_saveTimer, &QTimer::timeout, this, &ControlCenter::saveCurrentState);
    connect(m_saveTimer, &QTimer::timeout, m_progLoader, &ProgLoader::saveCurrentState);
    
    makeHandleConnections();
}

ControlCenter::~ControlCenter()
{
    // if (!m_socketModel.isNull()) {
    //     m_socketModel->deleteLater();
    // }
}

void ControlCenter::registerControl()
{
    qmlRegisterUncreatableType<SocketModel>("BackEnd", 1, 0, "SocketModel", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<SocketModeEditor>("BackEnd", 1, 0, "SocketModeEditor", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<ProgHandle>("BackEnd", 1, 0, "ProgHandle", "should be one and exist not only for qml");
    // qmlRegisterUncreatableType<P>("BackEnd", 1, 0, "ControlCenter", "should be one and exist not only for qml");
}

QPointer<SocketModel> ControlCenter::getSocketModel() const
{
    return m_socketModel.data();
}

void ControlCenter::init()
{
    readConfigs();
    initComms();
    initSockets();
    prepareConnectios();
}

void ControlCenter::makeHandleConnections()
{
    if (m_handle.isNull())
        return;

    connect(m_handle, &ProgHandle::signalRemoveSub,
            m_socketModel.data(), &SocketModel::slotRemoveSubProg);

    connect(m_handle, &ProgHandle::signalRecomProgChosen, 
            m_progLoader, &ProgLoader::programmLoadSocketInit);
    
    connect(m_handle, &ProgHandle::signalLoadEmpty, 
            this, [this] () {
            m_progLoader->defaultSocketInit(true);
    });
    
    // Автосохранение при успешном изменении режима
    connect(m_editor, &SocketModeEditor::editingFinished, 
            this, [this] (bool success) {
        if (success)
            m_progLoader->saveCurrentState();
    });

    connect(m_handle, &ProgHandle::signalScopeRequest,
            this, [this] (int id) {
        m_handle->setProgList(m_progLoader->getListOfPrograms(id));
    });

    connect(m_handle, &ProgHandle::signalAddEmptyDefault,
            m_progLoader, &ProgLoader::defaultSocketInit);

    connect(m_handle, &ProgHandle::signalCopyCurrent,
            m_socketModel.data(), &SocketModel::copyCurrentList);
}

QPointer<SocketModeEditor> ControlCenter::editor() const
{
    return m_editor;
}

void ControlCenter::initComms()
{}

void ControlCenter::initSockets()
{
    m_progLoader->defaultSocketInit();
    m_progLoader->loadCurrentState();
    m_handle->setScopeNameList(m_progLoader->getScopes());
}

void ControlCenter::readConfigs()
{ }

void ControlCenter::prepareConnectios()
{ }


QPointer<ProgHandle> ControlCenter::getHandle() const
{
    return m_handle;
}

bool ControlCenter::neutralElConnected() const
{
    return m_neutralElConnected;
}

void ControlCenter::unitStateHandler(LinkStm::UnitState state)
{
    if (m_neutralElConnected != state.neutraElConnected) {
       m_neutralElConnected = state.neutraElConnected;
       emit neutralElConnectedChanged(m_neutralElConnected);
    }
    
    bool cylinder1Changed = false;
    bool cylinder2Changed = false;
    
    if (m_argonCylinder1Connected != state.argonCylinder1) {
        m_argonCylinder1Connected = state.argonCylinder1;
        cylinder1Changed = true;
        emit argonCylinder1ConnectedChanged(m_argonCylinder1Connected);
    }
    
    if (m_argonCylinder2Connected != state.argonCylinder2) {
        m_argonCylinder2Connected = state.argonCylinder2;
        cylinder2Changed = true;
        emit argonCylinder2ConnectedChanged(m_argonCylinder2Connected);
    }
    
    // Обновляем реальный расход аргона
    if (m_argonRealRate != state.argonRealRate) {
        m_argonRealRate = state.argonRealRate;
        qDebug() << "РЕАЛЬНЫЙ РАСХОД: " << m_argonRealRate;
        emit argonRealRateChanged(m_argonRealRate);
    }
    
    // Автоматическое переключение активного баллона
    if (cylinder1Changed || cylinder2Changed) {
        // Если второй баллон подключён, а первый нет - переключаемся на второй
        if (m_argonCylinder2Connected && !m_argonCylinder1Connected) {
            if (m_activCylinderFirst) {
                setActivCylinderFirst(false);
            }
        }
        // Если первый баллон подключён, а второй нет - переключаемся на первый
        else if (m_argonCylinder1Connected && !m_argonCylinder2Connected) {
            if (!m_activCylinderFirst) {
                setActivCylinderFirst(true);
            }
        }
    }
}
//void ControlCenter::setNeutralElConnected(bool connected)
//{
//    if (m_neutralElConnected == connected)
//        return;

//    m_neutralElConnected = connected;
//    emit neutralElConnectedChanged(connected);
//}

bool ControlCenter::neutralElDivided() const
{
    return m_neutralElDivided;
}

void ControlCenter::setNeutralElDivided(bool divided)
{
    if (m_neutralElDivided == divided)
        return;
    
    m_neutralElDivided = divided;
    emit neutralElDividedChanged(divided);
    
    // Обновляем состояние в LinkStm
    if (!m_linkStm.isNull()) {
        m_linkStm->setNeutralElDivided(divided);
    }
}

bool ControlCenter::argonCylinder1Connected() const
{
    return m_argonCylinder1Connected;
}

bool ControlCenter::argonCylinder2Connected() const
{
    return m_argonCylinder2Connected;
}

quint8 ControlCenter::argonFlowRate() const
{
    return m_argonFlowRate;
}

void ControlCenter::setArgonFlowRate(quint8 rate)
{
    if (m_argonFlowRate == rate)
        return;
    
    m_argonFlowRate = rate;
    emit argonFlowRateChanged(rate);
    // TODO: Отправить команду установки расхода в LinkStm при необходимости
}

void ControlCenter::argonBlow()
{
    // TODO: Отправить команду продувки аргона через LinkStm
    // Например: m_linkStm->sendArgonBlowCommand();
    qDebug() << "Argon blow command triggered";
}

quint8 ControlCenter::argonRealRate() const
{
    return m_argonRealRate;
}

bool ControlCenter::activCylinderFirst() const
{
    return m_activCylinderFirst;
}

void ControlCenter::setActivCylinderFirst(bool first)
{
    if (m_activCylinderFirst == first)
        return;
    
    m_activCylinderFirst = first;
    emit activCylinderFirstChanged(first);
    
    // Передаём значение в LinkStm
    if (m_linkStm) {
        m_linkStm->setActivCylinderFirst(first);
    }
}

void ControlCenter::setArgonRealRate(quint8 rate)
{
    if (m_argonRealRate == rate)
        return;
    
    m_argonRealRate = rate;
    emit argonRealRateChanged(rate);
}

bool ControlCenter::enableActivation() const
{
    return m_enableActivation;
}

void ControlCenter::setEnableActivation(bool enable)
{
    if (m_enableActivation == enable)
        return;
    
    m_enableActivation = enable;
    emit enableActivationChanged(enable);
    
    // Обновляем состояние в LinkStm
    if (!m_linkStm.isNull()) {
        m_linkStm->setEnableActivation(enable);
    }
}

bool ControlCenter::activation() const
{
    return m_activation;
}

void ControlCenter::scheduleSave()
{
    // Перезапускаем таймер (если он уже запущен, он сбросится)
    m_saveTimer->start();
}

void ControlCenter::setLinkStm(LinkStm* linkStm)
{
    if (m_linkStm == linkStm)
        return;
        
    // Отключаем старые соединения, если они были
    if (!m_linkStm.isNull()) {
        disconnect(m_linkStm, &LinkStm::recieveData, this, &ControlCenter::uartChat);
        disconnect(m_linkStm, &LinkStm::error, this, &ControlCenter::uartError);
    }
    
    m_linkStm = linkStm;
    
    // Подключаем обработчик входящих данных
    if (!m_linkStm.isNull()) {
        connect(m_linkStm, &LinkStm::recieveData, this, &ControlCenter::uartChat);
        connect(m_linkStm, &LinkStm::error, this, &ControlCenter::uartError);
//        connect(m_linkStm, &LinkStm::neutralElConnectedChanged, this, &ControlCenter::setNeutralElConnected);
        connect(m_linkStm, &LinkStm::unitStateChanged, this, &ControlCenter::unitStateHandler);
        
        // Инициализируем текущие значения состояния в LinkStm
        m_linkStm->setEnableActivation(m_enableActivation);
        m_linkStm->setNeutralElDivided(m_neutralElDivided);
        
        // Подключаем сигнал обновления данных сокетов
        // чуть громоздко но без лишних сигналов, полностью нативно
        connect(m_socketModel.data(), &SocketModel::dataChanged,
                this, [this] (const QModelIndex &topLeft,
                                const QModelIndex &bottomRight,
                                const QVector<int> &/*roles = QVector<int>()*/) {
            int idxStart = topLeft.row();
            int idxStop = bottomRight.row();
            for (int i = idxStart; i <= idxStop; ++i) {
                m_linkStm->updateSocketData(i,
                                            topLeft.siblingAtRow(i).data(SocketModel::CutModeNum).value<quint16>(),
                                            topLeft.siblingAtRow(i).data(SocketModel::CoagModeNum).value<quint16>(),
                                            topLeft.siblingAtRow(i).data(SocketModel::CutModePower).value<quint16>(),
                                            topLeft.siblingAtRow(i).data(SocketModel::CoagModePower).value<quint16>(),
                                            topLeft.siblingAtRow(i).data(SocketModel::SocketPedal).value<quint8>()
                                            );
            }
        });
        
        // Подключаем сигналы активации
        connect(m_linkStm, &LinkStm::startActivation, m_socketModel.data(), &SocketModel::startActivation);
        connect(m_linkStm, &LinkStm::stopActivation, m_socketModel.data(), &SocketModel::stopActivation);
        
        // Инициализируем все сокеты текущими данными
        initializeAllSocketsInLinkStm();
        
        qDebug() << "LinkStm connected to ControlCenter";
    }
}

void ControlCenter::initializeAllSocketsInLinkStm()
{
    if (m_linkStm.isNull() || !m_socketModel) {
        qWarning() << "Cannot initialize sockets in LinkStm: missing dependencies";
        return;
    }
    
    for (int i = 0; i < m_socketModel->rowCount(QModelIndex()); ++i) {
        m_linkStm->updateSocketData(i,
                                    m_socketModel->index(i).data(
                                        SocketModel::SocketUartInfo).value<Onyx::SocketState>());
    }
}

void ControlCenter::uartChat(LinkStm::UartRx* rxData)
{
    rxData = nullptr;
}

void ControlCenter::uartError(quint8 errorState)
{
    switch (errorState) {
    case (LinkStm::STATE_OK + 32):
        // Все в порядке
        break;
    case (LinkStm::STATE_TX_ERR + 32):
        // qWarning() << "UART TX Error";
        break;
    case (LinkStm::STATE_NO_RX + 32):
        // qWarning() << "UART No RX";
        break;
    case (LinkStm::STATE_RX_ERR + 32):
        // qWarning() << "UART RX Error";
        break;
    case (LinkStm::STATE_RX_LEN_ERR + 32):
        // qWarning() << "UART RX Length Error";
        break;
    case (LinkStm::STATE_RX_CRC_ERR + 32):
        // qWarning() << "UART RX CRC Error";
        break;
    default:
        // qWarning() << "Some error: " << errorState;
        break;
    }
}
