#ifndef DATABASEREADER_H
#define DATABASEREADER_H

#include <QObject>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>
#include <QSharedPointer>

class DataBaseReader : public QObject
{
    Q_OBJECT
public:
    DataBaseReader(const QString& pathToDb);
    void slotSendQuery(const QString& queryStr, int valueNumbersAwaited = 1);
    QList<QVariantList> slotSendSelectQuery(const QStringList &tables,
                             const QStringList& columns,
                             const QString& conditions);

signals:
    // void signalResultReady(const QString& query, const QVariantList res);
    void signalResultReady(const QString& query, const QList<QVariantList> res);

private:
    // QSharedPointer<QSqlDatabase> dbPointer;

};

#endif // DATABASEREADER_H
