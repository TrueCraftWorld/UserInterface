#include "controlcenter.h"
#include "socket.h"


#include <QQmlEngine>



ControlCenter::ControlCenter(QObject *parent)
    : QObject{parent},
    m_socketModel(new SocketModel),
    m_editor(new SocketModeEditor(m_socketModel,this))
{
    QQmlEngine::setObjectOwnership(m_socketModel, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(m_editor, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ControlCenter::~ControlCenter()
{
    if (!m_socketModel.isNull()) {
        m_socketModel->deleteLater();
    }
    qDebug() << "COntrolDeleted";
}

void ControlCenter::registerControl()
{
    // qmlRegisterUncreatableType<ControlCenter>("BackEnd", 1, 0, "ControlCenter", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<SocketModel>("BackEnd", 1, 0, "SocketModel", "should be one and exist not only for qml");
    qmlRegisterUncreatableType<SocketModeEditor>("BackEnd", 1, 0, "SocketModeEditor", "should be one and exist not only for qml");
}

QPointer<SocketModel> ControlCenter::getSocketModel() const
{
    return m_socketModel;
}

void ControlCenter::init()
{
    readConfigs();
    initComms();
    initSockets();
    prepareConnectios();
}

QPointer<SocketModeEditor> ControlCenter::editor() const
{
    return m_editor;
}

void ControlCenter::initComms()
{

}

void ControlCenter::initSockets()
{
    ///todo read old socket (maybe Json or QSetting)
    if (readPreviousSocketSettings()) {

    } else {
        defaultSocketInit();
    }

}

void ControlCenter::readConfigs()
{

}

void ControlCenter::prepareConnectios()
{

}

bool ControlCenter::readPreviousSocketSettings()
{
    ///todo REALIZE
    return false;
}

void ControlCenter::defaultSocketInit()
{
    QList<QSharedPointer<SOCKET>> socketList;

    //may change count based on config later
    //NEED to parallel cause it is on start and it does some nasty sorting
    for (int i = 0; i < 4; ++i) {
        QSharedPointer<SOCKET> socket = QSharedPointer<SOCKET>::create(i < SOCKET::MONOPOLAR_2 ? SOCKET::SocType(i+1) : SOCKET::EMPTY);

        int coagStart = 0;
        int cutStart = 0;
        int coagStop = 0;
        int cutStop = 0;
        QString socketName = "";
        QHash<QString, QSharedPointer<EshfMode>> cutModes;
        QHash<QString, QSharedPointer<EshfMode>> coagModes;
        switch (socket->socketType()) {
        case SOCKET::EMPTY:
            socketName = QString("EMPTY");
            cutStart = 0;  cutStop = 0;
            coagStart = 0;   coagStop = 0;
            break;
        case SOCKET::BIPOLAR_1:
            socketName = QString("BIPOLAR 1");
            cutStart = 1+1;  cutStop = 4+1+1;
            coagStart = 5+1;   coagStop = 6+1+1;
            break;
        case SOCKET::BIPOLAR_2:
            socketName = QString("BIPOLAR 2");
            cutStart = 1+1;  cutStop = 4+1+1;
            coagStart = 5+1;   coagStop = 7+1+1;
            break;
        case SOCKET::MONOPOLAR_1:
            socketName = QString("MONOPOLAR 1");
            cutStart = 8+1;   cutStop = 18+1+1;
            coagStart = 19+1;   coagStop = 26+1+1;
            break;
        case SOCKET::MONOPOLAR_2:
            socketName = QString("MONOPOLAR 2");
            cutStart = 8+1;  cutStop = 18+1+1;
            coagStart = 19+1;   coagStop = 22+1+1;
            break;
        }
        socket->setSocketName(socketName);
        cutModes.insert(ESHF::modesNames[0], QSharedPointer<EshfMode>::create(ESHF::modesNames[0],
                                                                         false,
                                                                         ESHF::modesMaxPowers[0],
                                                                         1));
        coagModes.insert(ESHF::modesNames[1], QSharedPointer<EshfMode>::create(ESHF::modesNames[1],
                                                                               true,
                                                                               ESHF::modesMaxPowers[1],
                                                                               1));

        for (int j = cutStart; j < cutStop; ++j) {
            cutModes.insert(ESHF::modesNames[j], QSharedPointer<EshfMode>::create(ESHF::modesNames[j],
                                                                                  false,
                                                                                  ESHF::modesMaxPowers[j],
                                                                                  1));
        }
        for (int j = coagStart; j < coagStop; ++j) {
            coagModes.insert(ESHF::modesNames[j], QSharedPointer<EshfMode>::create(ESHF::modesNames[j],
                                                                                   false,
                                                                                   ESHF::modesMaxPowers[j],
                                                                                   1));
        }
        socket->setCoagModes(coagModes, ESHF::modesNames);
        socket->setCutModes(cutModes, ESHF::modesNames);
        socketList.append(socket);
    }
    m_socketModel->setItems(socketList);
}
