#include "controlcenter.h"
#include "proghandle.h"

#include <QQmlEngine>
#include <QString>
#include <QTimer>
#include <QDebug>
#include <QVector>
#include <QVariant>


ControlCenter::ControlCenter(QObject *parent)
    : QObject{parent},

    m_socketModel(new SocketModel()),
    m_editor(new SocketModeEditor(m_socketModel,this)),
    m_handle(new ProgHandle(this)),
    m_progLoader(new ProgLoader(this)),
    m_periphery(new PeriphHandler(this)),
    m_linkStm(nullptr),
    m_saveTimer(new QTimer(this))
{
    QQmlEngine::setObjectOwnership(m_socketModel.data(), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_editor, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_handle, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_progLoader, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_periphery, QQmlEngine::CppOwnership);
    init();
}

ControlCenter::~ControlCenter()
{ }

void ControlCenter::registerHandles()
{
    qmlRegisterUncreatableType<SocketModel>("BackEnd", 1, 0, "SocketModel", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<SocketModeEditor>("BackEnd", 1, 0, "SocketModeEditor", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<ProgHandle>("BackEnd", 1, 0, "ProgHandle", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<PeriphHandler>("BackEnd", 1, 0, "PeriphHandle", "should be one and exist not only for qml");
}

QPointer<SocketModel> ControlCenter::getSocketModel() const
{
    return m_socketModel.data();
}

void ControlCenter::init()
{
    m_progLoader->setSocketModelPtr(m_socketModel);
    m_saveTimer->setSingleShot(true);
    m_saveTimer->setInterval(2000);  // 2 секунды
    prepareConnectios();
    initSockets();
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

void ControlCenter::initSockets()
{
    m_progLoader->defaultSocketInit();
    m_progLoader->loadCurrentState();
    m_handle->setScopeNameList(m_progLoader->getScopes());
}

void ControlCenter::prepareConnectios()
{
    makeHandleConnections();
    if (m_progLoader && m_saveTimer)
        connect(m_saveTimer, &QTimer::timeout,
                m_progLoader, &ProgLoader::saveCurrentState);

    if (m_progLoader && m_editor)
        connect(m_editor, &SocketModeEditor::editingFinished,
                this, [this] (bool success) {
            if (success)
                m_progLoader->saveCurrentState();
        });
}

QPointer<ProgHandle> ControlCenter::getHandle() const
{
    return m_handle;
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
        disconnect(m_linkStm, nullptr, nullptr, nullptr);
        m_linkStm->deleteLater();
        m_linkStm = nullptr;
    }
    
    m_linkStm = linkStm;
    
    // Подключаем обработчик входящих данных
    if (!m_linkStm.isNull()) {
        connect(m_linkStm, &LinkStm::sigUnitStateChanged,
                m_periphery, &PeriphHandler::unitStateHandler);
        
        // Инициализируем текущие значения состояния в LinkStm
        m_linkStm->setEnableActivation(m_periphery->enableActivation());
        m_linkStm->setNeutralElDivided(m_periphery->neutralElDivided());
        
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
        connect(m_linkStm, &LinkStm::sigStartActivation,
                m_socketModel.data(), &SocketModel::startActivation);
        connect(m_linkStm, &LinkStm::sigStopActivation,
                m_socketModel.data(), &SocketModel::stopActivation);
        
//-----------Коннекты получения перифейрийной информации
        connect(m_linkStm, &LinkStm::sigUnitStateChanged,
                m_periphery, &PeriphHandler::unitStateHandler);

//-----------Коннекты передачи пользовательских действий
        connect(m_periphery, &PeriphHandler::activCylinderFirstChanged,
                m_linkStm, &LinkStm::setActivCylinderFirst);
        connect(m_periphery, &PeriphHandler::neutralElDividedChanged,
                m_linkStm, &LinkStm::setNeutralElDivided);
        connect(m_periphery, &PeriphHandler::enableActivationChanged,
                m_linkStm,  &LinkStm::setEnableActivation);
        ///TODO реализовать метод приёма данных в linkStm
        // connect(m_periphery, &PeriphHandler::argonFlowRateChanged,
        //         m_linkStm, &LinkStm::set);

        // Инициализируем все сокеты текущими данными
        initSocketsForPeriphery();
        
        qDebug() << "LinkStm connected to ControlCenter";
    }
}

void ControlCenter::initSocketsForPeriphery()
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


QPointer<PeriphHandler> ControlCenter::getPeripheryHandle() const
{
    return m_periphery;
}

//не понял задумки в этих фнкциях
// void ControlCenter::uartChat(LinkStm::UartRx* rxData)
// {
//     rxData = nullptr;
// }

// void ControlCenter::uartError(quint8 errorState)
// {
//     switch (errorState) {
//     case (LinkStm::STATE_OK + 32):
//         // Все в порядке
//         break;
//     case (LinkStm::STATE_TX_ERR + 32):
//         // qWarning() << "UART TX Error";
//         break;
//     case (LinkStm::STATE_NO_RX + 32):
//         // qWarning() << "UART No RX";
//         break;
//     case (LinkStm::STATE_RX_ERR + 32):
//         // qWarning() << "UART RX Error";
//         break;
//     case (LinkStm::STATE_RX_LEN_ERR + 32):
//         // qWarning() << "UART RX Length Error";
//         break;
//     case (LinkStm::STATE_RX_CRC_ERR + 32):
//         // qWarning() << "UART RX CRC Error";
//         break;
//     default:
//         // qWarning() << "Some error: " << errorState;
//         break;
//     }
// }

