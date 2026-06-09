#ifndef DEVICELOGMANAGER_H
#define DEVICELOGMANAGER_H

#include <QObject>
#include <QElapsedTimer>
#include <QDate>
#include <QDateTime>
#include <QMutex>
#include <QStringList>
#include <QTimer>

class JsonStorage;
class SocketModel;

class DeviceLogManager : public QObject
{
    Q_OBJECT
public:
    explicit DeviceLogManager(JsonStorage *jsonStorage,
                              SocketModel *socketModel,
                              QObject *parent = nullptr);

    Q_INVOKABLE QStringList readLogLines(const QString &filter, int maxLines = 1000) const;
    Q_INVOKABLE QStringList readLogLines(const QString &filter, const QString &date, int maxLines = 1000) const;
    Q_INVOKABLE QStringList availableLogDates() const;
    Q_INVOKABLE QString todayLogDate() const;
    Q_INVOKABLE QString adjacentLogDate(const QString &date, int direction) const;
    Q_INVOKABLE int logLineCount(const QString &filter, const QString &date) const;
    Q_INVOKABLE QString logFilePath() const;

public slots:
    void beginSession();
    void finalizeSession();
    void persistCounters();
    void onActivationStarted(quint8 socketId, bool isCut, quint16 mode, quint16 power,
                             bool autoMode, quint8 sourceCode);
    void onActivationStopped(quint8 stopReason);
    void onWarningCode(quint8 warningCode);
    void logPowerOff(const QString &message);

private:
    struct ActivationInfo {
        bool active = false;
        quint8 socketId = 0;
        bool isCut = false;
        quint16 mode = 0;
        quint16 power = 0;
        bool autoMode = false;
        quint8 sourceCode = 0;
        QString output;
        QString modeName;
        QString instrument;
        QDateTime startedAt;
        QElapsedTimer timer;
        qint64 persistedMs = 0;
    };

    QString logDirPath() const;
    bool ensureLogDir() const;
    QString logFilePathForDate(const QDate &date) const;
    QString logFileNameForDate(const QDate &date) const;
    QDate dateFromLogFileName(const QString &fileName) const;
    QString formatLogDate(const QDate &date) const;
    QDate normalizedLogDate(const QString &date) const;
    QStringList sortedLogDates() const;
    void migrateLegacyLogFile() const;
    bool isDailyLogOverSizeLimit(const QString &filePath) const;
    void appendEvent(const QString &category, const QString &message);
    bool appendOrUpdateRepeatedError(const QString &filePath, const QString &message);
    QString repeatedEventMessage(const QString &line, const QString &category) const;
    int repeatedEventCount(const QString &line) const;
    QString withRepeatedEventCount(const QString &line, int count) const;
    bool lineMatchesFilter(const QString &line, const QString &filter) const;
    QString formatDuration(qint64 milliseconds) const;
    QString formatTotalDuration(qint64 milliseconds) const;
    QString warningTextForCode(int code) const;
    QString sourceText(bool autoMode, quint8 sourceCode) const;
    QString socketData(int socketId, int role) const;
    qint64 readCounter(const QString &key) const;
    void saveCounter(const QString &key, qint64 value);

    JsonStorage *m_jsonStorage = nullptr;
    SocketModel *m_socketModel = nullptr;
    mutable QMutex m_mutex;
    QTimer m_persistTimer;
    QElapsedTimer m_sessionTimer;
    ActivationInfo m_activation;
    qint64 m_runtimeBaseMs = 0;
    bool m_sessionFinalized = false;
};

#endif // DEVICELOGMANAGER_H
