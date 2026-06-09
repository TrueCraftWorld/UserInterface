#ifndef DATETIMECONTROLLER_H
#define DATETIMECONTROLLER_H

#include <QObject>
#include <QString>

class DateTimeController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentDateTime READ currentDateTime NOTIFY currentDateTimeChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit DateTimeController(QObject *parent = nullptr);

    QString currentDateTime() const;
    QString lastError() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool setDateTime(int year, int month, int day, int hour, int minute, int second);

signals:
    void currentDateTimeChanged();
    void lastErrorChanged();

private:
    void setLastError(const QString &error);

    QString m_lastError;
};

#endif // DATETIMECONTROLLER_H
