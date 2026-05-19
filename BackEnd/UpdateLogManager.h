#ifndef UPDATELOGMANAGER_H
#define UPDATELOGMANAGER_H

#include <QObject>
#include <QMutex>
#include <QStringList>

class UpdateLogManager : public QObject
{
    Q_OBJECT
public:
    explicit UpdateLogManager(QObject *parent = nullptr);

    Q_INVOKABLE void logUpdate(const QString &moduleName,
                               const QString &oldVersion,
                               const QString &newVersion);
    Q_INVOKABLE QStringList readLogLines(int maxLines = 2000) const;
    Q_INVOKABLE int lineCount() const;
    Q_INVOKABLE QString logFilePath() const;

private:
    QString logDirPath() const;
    bool ensureLogDir() const;
    bool isLogOverSizeLimit() const;

    mutable QMutex m_mutex;
};

#endif // UPDATELOGMANAGER_H
