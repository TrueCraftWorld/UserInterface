#ifndef DATABASEREADER_H
#define DATABASEREADER_H

#include <QObject>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSharedPointer>

class DataBaseReader : public QObject
{
    Q_OBJECT
public:
    DataBaseReader(const QString& pathToDb);
    void slotSendQuery(const QString& queryStr, int valueNumbersAwaited = 1);

signals:
    void signalResultReady(const QString& query, const QVector<QVariant>& res);

private:
    QSharedPointer<QSqlDatabase> dbPointer;

};

#endif // DATABASEREADER_H
