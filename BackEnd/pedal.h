#ifndef PEDAL_H
#define PEDAL_H
#include <QtQml/qqml.h>
#include <QObject>
#include "BackEnd/socket.h"

class PEDAL : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SOCKET* bindedSocket READ bindedSocket WRITE setBindedSocket NOTIFY bindedSocketChanged)
    QML_ELEMENT
public:
    enum pedType {  NO_PED,
                    DOUBLE_PED,
                    SINGLE_PED };
explicit PEDAL(pedType pedId, QObject *parent = nullptr);
SOCKET* bindedSocket() const;

public slots:
void setBindedSocket(SOCKET* bindedSocket);

signals:
void bindedSocketChanged(SOCKET* bindedSocket);
void pedalInfoUpdated(const QByteArray &data);

private:
SOCKET* m_bindedSocket;
pedType m_pedId;
QByteArray pedSettings();
};

#endif // PEDAL_H
