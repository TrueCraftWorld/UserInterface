#ifndef SOCKETMODEL_H
#define SOCKETMODEL_H

#include <QAbstractItemModel>
#include <QObject>
#include <QSharedPointer>

#include "socketConstants.h"



class SocketModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit SocketModel(QObject *parent = nullptr);
    void init(QList<QSharedPointer<SOCKET>> m_items );

    // QAbstractItemModel interface
public:
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;

private:
    QList<QSharedPointer<SOCKET>> m_items;

signals:
    void signalSocketStateChanged(int socketId, int state);
    void signalSocketContentChanged(int socketId, const QByteArray& content);
};

#endif // SOCKETMODEL_H
