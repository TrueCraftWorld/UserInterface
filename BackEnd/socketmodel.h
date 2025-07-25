#ifndef SOCKETMODEL_H
#define SOCKETMODEL_H

#include <QAbstractItemModel>
#include <QObject>
#include <QSharedPointer>
#include <map>

#include "socket.h"

class SocketModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum SocketRoles {
        SocketStatus = Qt::UserRole+1,
        SocketName,
        SocketPolarity,
        CoagModeIndex,
        CoagModeName,
        CoagModePower,
        CoagModeMinPower,
        CoagModeMaxPower,
        CoagModeInstrName,
        CoagModeInstrImage,
        CoagModeInstrIndex,
        CutModeIndex,
        CutModeName,
        CutModePower,
        CutModeMinPower,
        CutModeMaxPower,
        CutModeInstrName,
        CutModeInstrImage,
        CutModeInstrIndex,
        CutModesNames,
        CoagModesNames
    };
    explicit SocketModel(QObject *parent = nullptr);
    void init(QList<QSharedPointer<SOCKET>> m_items );

    // QAbstractItemModel interface
public:
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    // Q_INVOKABLE QVariantMap modeParam(const QString& socket, const QString& mode = "") const;
    Q_INVOKABLE QVariantMap modeParam(int socketId, int modeIndeex, bool isCoag) const;
    // QStringList modeNames(const QString& socket, const QString& mode) const;
    QStringList modeNames(int socketID, bool isCoag) const;

public:
    // Q_INVOKABLE void acceptChanges(const QString& socket, const QString& mode, int power);
    Q_INVOKABLE void acceptChanges(int socket, int mode, int power, bool isCoag);
    // bool commitModeChange(const QString &socket, const QString &mode, QVariantMap param);
    bool commitModeChange(int socketId, int modeINdex, const QVariantMap& param);
    QSharedPointer<SOCKET> socketByName(const QString& socket) const;
    // QList<QSharedPointer<SOCKET>> m_items;
    std::map<int, QSharedPointer<SOCKET>> m_itemsMap;
    QStringList m_socketNames;
private:
    // SocketModeEditor * editor;

signals:
    void signalSocketStateChanged(int socketId, int state);
    void signalSocketContentChanged(int socketId, const QByteArray& content);

    // QAbstractItemModel interface
public:
    virtual QHash<int, QByteArray> roleNames() const override;
    // void setItems(const QList<QSharedPointer<SOCKET> > &newItems);
    // SocketModeEditor *getEditor() const;
    void setItemsMap(const std::map<int, QSharedPointer<SOCKET> > &newItemsMap);
};

#endif // SOCKETMODEL_H
