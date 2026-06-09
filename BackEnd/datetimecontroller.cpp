#include "datetimecontroller.h"

#include <QDate>
#include <QDateTime>
#include <QDebug>
#include <QProcess>
#include <QTime>

namespace {

QString processOutputError(QProcess &process, const QString &fallback)
{
    const QString stderrText = QString::fromLocal8Bit(process.readAllStandardError()).trimmed();
    if (!stderrText.isEmpty()) {
        return stderrText;
    }

    const QString stdoutText = QString::fromLocal8Bit(process.readAllStandardOutput()).trimmed();
    return stdoutText.isEmpty() ? fallback : stdoutText;
}

bool runTimedatectl(const QStringList &arguments, QString *errorMessage)
{
    QProcess process;
    process.start(QStringLiteral("timedatectl"), arguments);

    if (!process.waitForStarted(3000)) {
        if (errorMessage) {
            *errorMessage = QStringLiteral("Не удалось запустить timedatectl");
        }
        return false;
    }

    if (!process.waitForFinished(5000)) {
        process.kill();
        process.waitForFinished(1000);
        if (errorMessage) {
            *errorMessage = QStringLiteral("timedatectl не завершился за отведённое время");
        }
        return false;
    }

    if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
        if (errorMessage) {
            *errorMessage = processOutputError(
                        process,
                        QStringLiteral("timedatectl завершился с ошибкой"));
        }
        return false;
    }

    return true;
}

} // namespace

DateTimeController::DateTimeController(QObject *parent)
    : QObject(parent)
{
}

QString DateTimeController::currentDateTime() const
{
    return QDateTime::currentDateTime().toString(QStringLiteral("dd.MM.yyyy HH:mm:ss"));
}

QString DateTimeController::lastError() const
{
    return m_lastError;
}

void DateTimeController::refresh()
{
    emit currentDateTimeChanged();
}

bool DateTimeController::setDateTime(int year, int month, int day, int hour, int minute, int second)
{
    const QDate date(year, month, day);
    const QTime time(hour, minute, second);

    if (!date.isValid() || !time.isValid()) {
        setLastError(QStringLiteral("Некорректная дата или время"));
        return false;
    }

    const QString value = QDateTime(date, time).toString(QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    QString timedateError;

    if (!runTimedatectl(QStringList{QStringLiteral("set-ntp"), QStringLiteral("false")},
                        &timedateError)) {
        qWarning() << "DateTimeController: Не удалось отключить NTP:" << timedateError;
    }

    if (!runTimedatectl(QStringList{QStringLiteral("set-time"), value}, &timedateError)) {
        setLastError(timedateError);
        return false;
    }

    setLastError(QString());
    emit currentDateTimeChanged();
    return true;
}

void DateTimeController::setLastError(const QString &error)
{
    if (m_lastError == error) {
        return;
    }

    m_lastError = error;
    emit lastErrorChanged();
}
