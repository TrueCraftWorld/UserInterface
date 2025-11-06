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
    
    /**
     * @brief Выполняет UPDATE/INSERT/DELETE запрос
     * @param queryStr SQL запрос
     * @return true если успешно, false если ошибка
     */
    bool executeUpdateQuery(const QString& queryStr);

signals:

    void signalResultReady(const QString& query, const QList<QVariantList> res);

private:

};

#endif // DATABASEREADER_H
