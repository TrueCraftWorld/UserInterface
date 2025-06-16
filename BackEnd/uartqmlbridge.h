#ifndef UARTQMLBRIDGE_H
#define UARTQMLBRIDGE_H


#include <QObject>
#include <QString>
#include <QSerialPort>
#include <QDebug>
//#include "qqml.h"

class UartToQmlBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QByteArray command  READ command  WRITE writeData NOTIFY commandChanged)
    Q_PROPERTY(QByteArray response READ response WRITE writeData NOTIFY responseChanged)

public:
    UartToQmlBridge(QObject *parent = nullptr);
    ~UartToQmlBridge();

    QByteArray command();
    QByteArray response();

signals:
    void commandChanged();
    void responseChanged();

private:

    void openSerialPort();
    void closeSerialPort();
public slots:
    void writeData(const QByteArray &data);
    void readData();

private:
    QSerialPort *m_serial = nullptr;
    QByteArray m_command;
    QByteArray m_response;
//    bool m_moduleStatus[3];
};

#endif // UARTQMLBRIDGE_H
