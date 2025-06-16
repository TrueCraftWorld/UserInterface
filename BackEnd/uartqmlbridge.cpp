#include <QDebug>
#include "uartqmlbridge.h"

UartToQmlBridge::UartToQmlBridge(QObject *parent) :
     QObject{parent},
     m_serial(new QSerialPort(this))
{
    Q_UNUSED(parent);
    openSerialPort();
    connect(m_serial, &QSerialPort::readyRead, this, &UartToQmlBridge::readData);
}

UartToQmlBridge::~UartToQmlBridge()
{
    closeSerialPort();
}

QByteArray UartToQmlBridge::command()
{
    return m_command;
}

QByteArray UartToQmlBridge::response()
{
    return m_response;
}

void UartToQmlBridge::openSerialPort()
{
//    for now lets hardcode params of tty
    m_serial->setPortName("ttyS3");
    m_serial->setBaudRate(QSerialPort::Baud115200);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);
    if (m_serial->open(QIODevice::ReadWrite)) {

    } else {

    }
}

void UartToQmlBridge::closeSerialPort()
{
    if (m_serial->isOpen())
        m_serial->close();
}


void UartToQmlBridge::writeData(const QByteArray &data)
{
    if (m_command == data)
        return;
    m_command = data;
//    qDebug()<<data;
    m_serial->write(m_command);
}

void UartToQmlBridge::readData()
{
    const QByteArray data = m_serial->readAll();
    qDebug() << data;
    if (data == m_response)
        return;
    m_response = data;
    emit responseChanged();
    return;
}
