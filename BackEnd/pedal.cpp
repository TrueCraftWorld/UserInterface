#include "pedal.h"
#include "BackEnd/uartqmlbridge.h"

PEDAL::PEDAL(pedType pedId, QObject *parent) :
    QObject(parent),
    m_bindedSocket( nullptr),
    m_pedId( NO_PED )
{
    m_pedId = pedId;
}

SOCKET *PEDAL::bindedSocket() const
{
    return m_bindedSocket;
}

void PEDAL::setBindedSocket(SOCKET *bindedSocket)
{
//   if (bindedSocket)
   if (m_bindedSocket == bindedSocket)
        return;

    m_bindedSocket = bindedSocket;
    emit bindedSocketChanged(m_bindedSocket);
    emit pedalInfoUpdated(pedSettings());
}

QByteArray PEDAL::pedSettings()
{
    QByteArray message;
    int socketNum;
    socketNum = (m_bindedSocket == nullptr) ? static_cast<int>(NO_PED) : (static_cast<int>(m_bindedSocket->socketType()));
    int pedal = static_cast<int>(m_pedId);

    QString outputInfo = QString("P%1 %2     \n").arg(pedal).arg(socketNum);
    return message.append(outputInfo.toLatin1());
}
