#include "databasereader.h"

#include <QtConcurrent>
#include <QFuture>
#include <QFutureWatcher>


DataBaseReader::DataBaseReader(const QString& pathToDb)
    : QObject(nullptr)
{
    dbPointer = QSharedPointer<QSqlDatabase>::create("QSQLITE");
    if (dbPointer.isNull())
        return;
    dbPointer->setDatabaseName(pathToDb);
    if (!dbPointer->open());
        return;


}

void DataBaseReader::slotSendQuery(const QString &queryStr, int valueNumbersAwaited)
{
    QFuture<QVector<QVariant>> future = QtConcurrent::run([](QSharedPointer<QSqlDatabase> ptr, const QString &queryStr) {
        QVector<QVariant> result;
        // QSqlDatabase db = QSqlDatabase::database(); // Или создаем новое подключение

        QSqlQuery query(queryStr, *ptr);
        while (query.next()) {
            QVector<QVariant> singleRes;
            for (int b:valueNumbersAwaited)
                singleRes.append(query.value(b));
            result.append(singleRes);
        }

        return result;
    });

    QFutureWatcher<QVector<QVariant>> *watcher = new QFutureWatcher<QVector<QVariant>>(this);
    connect(watcher, &QFutureWatcher<QVector<QVariant>>::finished, [this, watcher, &queryStr]() {
        // QVector<Employee> employees = watcher->result();
        // Обновление UI
        emit signalResultReady(queryStr, watcher->result());
    });
    watcher->setFuture(future);
}
