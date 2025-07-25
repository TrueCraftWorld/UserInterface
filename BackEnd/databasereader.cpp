#include "databasereader.h"

#include <QtConcurrent>
#include <QFuture>
#include <QFutureWatcher>



DataBaseReader::DataBaseReader(const QString& pathToDb)
    : QObject(nullptr)
{
    QSqlDatabase someDb = QSqlDatabase::addDatabase("QSQLITE", "kurwa");

    someDb.setDatabaseName(pathToDb);
    someDb.open();
    if (someDb.isOpen())
        qDebug() << "at least";
}

void DataBaseReader::slotSendQuery(const QString &queryStr, int valueNumbersAwaited)
{
    QList<QVariantList> result;
    QSqlDatabase db = QSqlDatabase::database("kurwa"); // Или создаем новое подключение
    db.open();
    if (db.isOpen())
        qDebug() << "at least";

    QSqlQuery query(db);
    query.prepare(queryStr);
    query.setForwardOnly(true);

    if (!query.exec()) {
        qDebug() << query.lastError().text();
    }

    while (query.next()) {
        QVariant res1 = query.value(0);
        QVariant res2 = query.value(1);

        result.append(QVariantList{res1, res2});
    }


    emit signalResultReady(queryStr, result);

}

QList<QVariantList> DataBaseReader::slotSendSelectQuery(const QStringList &tables,
                                         const QStringList &columns,
                                         const QString &conditions)
{
    QList<QVariantList> result;
    QSqlDatabase db = QSqlDatabase::database("kurwa"); // Или создаем новое подключение
    db.open();
    if (db.isOpen())
        qDebug() << "at least";

    QSqlQuery query(db);
    if (conditions.isEmpty()) {
        QString queryString("SELECT %1 FROM %2");
        QString tmp = queryString.arg(columns.join(',')).arg(tables.join(','));
        query.prepare(tmp);
    } else {
        QString queryString("SELECT %1 FROM %2 WHERE %3");
        QString tmp = queryString.arg(columns.join(',')).arg(tables.join(',')).arg(conditions);
        query.prepare(tmp);

    }
    query.setForwardOnly(true);

    if (!query.exec()) {
        qDebug() << query.lastError().text();
    }

    int colCount = columns.size();
    while (query.next()) {
        QVariantList rowRes;
        for (int i = 0; i < colCount; ++i)
            rowRes.append(query.value(i));

        result.append(rowRes);
    }

    return result;
    // emit signalResultReady(queryStr, result);

}
