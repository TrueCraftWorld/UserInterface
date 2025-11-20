#include "controlcenter.h"
#include "socket.h"
#include "proghandle.h"

// #include <algorithm>
// #include <cmath>
#include <map>

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
            this, [this](bool success) {
        if (success) {
            m_progLoader->saveCurrentState();
        }
    });

    connect(m_handle, &ProgHandle::signalScopeRequest,
            this, [this] (int id) {
        m_handle->setProgList(m_progLoader->getListOfPrograms(id));
    });

    //     void signalCopyCurrent();

    // void signalAddEmptyDefault(bool clearLoad);
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
                this, [this] (const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>()) {
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
        connect(m_linkStm, &LinkStm::startActivation, this, &ControlCenter::onStartActivation);
        connect(m_linkStm, &LinkStm::stopActivation, this, &ControlCenter::onStopActivation);
        
        // Инициализируем все сокеты текущими данными
        initializeAllSocketsInLinkStm();
        
        qDebug() << "LinkStm connected to ControlCenter";
    }
}

void ControlCenter::initializeAllSocketsInLinkStm()
{
    if (m_linkStm.isNull() || !m_socketModel || !m_socketModel->itemsMap()) {
        qWarning() << "Cannot initialize sockets in LinkStm: missing dependencies";
        return;
    }
    
    // Инициализируем все сокеты текущими данными
    for (int i = 0; i < 4; i++) {
        auto iter = m_socketModel->itemsMap()->find(i);
        if (iter != m_socketModel->itemsMap()->end() && !iter->second.isNull()) {
            auto socket = iter->second;
            
            // Получаем текущие данные сокета
            quint16 cutModeNum = 1000;  // По умолчанию
            quint16 coagModeNum = 1000; // По умолчанию
            quint16 cutModePower = socket->cutModePower();
            quint16 coagModePower = socket->coagModePower();
            quint8 pedal = socket->pedal();
            
            // Получаем Num режимов (не ID!)
            auto cutMode = socket->curCutMode();
            if (!cutMode.isNull()) {
                cutModeNum = cutMode->num();
            }
            
            auto coagMode = socket->curCoagMode();
            if (!coagMode.isNull()) {
                coagModeNum = coagMode->num();
            }
            
            // Обновляем данные в LinkStm
            m_linkStm->updateSocketData(i, cutModeNum, coagModeNum, 
                                      cutModePower, coagModePower, pedal);
        }
    }
    
    qDebug() << "All sockets initialized in LinkStm";
}

void ControlCenter::onStartActivation(quint8 socketId, bool isCut)
{
    if (!m_socketModel || !m_socketModel->itemsMap()) {
        qWarning() << "Cannot start activation: socket model not available";
        return;
    }
    
    auto iter = m_socketModel->itemsMap()->find(socketId);
    if (iter == m_socketModel->itemsMap()->end() || iter->second.isNull()) {
        qWarning() << "Cannot start activation: socket" << socketId << "not found";
        return;
    }
    auto socket = iter->second;
    // Получаем данные для активации
    QString socketName = socket->socketName();
    QString modeName = "Режим не выбран";
    quint16 power = 0;
    // bool isCoag = !isCut;
    
    // Получаем режим и мощность
    if (isCut) {
        auto cutMode = socket->curCutMode();
        if (!cutMode.isNull()) {
            modeName = cutMode->modeName();
            power = socket->cutModePower();
        }
    } else {
        auto coagMode = socket->curCoagMode();
        if (!coagMode.isNull()) {
            modeName = coagMode->modeName();
            power = socket->coagModePower();
        }
    }
    
    
    // Запускаем активацию с минимальной задержкой, чтобы сокет успел развернуться

    QTimer::singleShot(0, this, [this, socketId, isCut]() {
        if (m_socketModel) {
            m_socketModel->expandSocket(socketId);
            m_socketModel->qmlSetData(socketId, isCut ? SOCKET::S_ACTIVE_CUT : SOCKET::S_ACTIVE_COAG, "socketstatus");
        }
    });
    
    qDebug() << "Activation started: socket" << socketId << "mode:" << modeName << "power:" << power;
}

void ControlCenter::onStopActivation(quint8 stopReason)
{
    // Останавливаем активацию
    m_socketModel->stopActivation();
    
    qDebug() << "Activation stopped, reason:" << stopReason;
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
