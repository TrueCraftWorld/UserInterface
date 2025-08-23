#ifndef SOCKETMODEL_H
#define SOCKETMODEL_H

#include <QAbstractItemModel>
#include <QObject>
#include <QSharedPointer>
#include <map>
#include "instrument.h"

#include "socket.h"

class SocketModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum SocketRoles {
        SocketStatus = Qt::UserRole+1,
        SocketEnabled,
        SocketAllowed,
        SocketDisplayMode,
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
        CoagModeInstrID,
        CutModeIndex,
        CutModeName,
        CutModePower,
        CutModeMinPower,
        CutModeMaxPower,
        CutModeInstrName,
        CutModeInstrImage,
        CutModeInstrIndex,
        CutModeInstrID,
        CutModesNames,
        CoagModesNames
    };
    Q_ENUM(SocketRoles)

    explicit SocketModel(QObject *parent = nullptr);
    void init(QList<SockPtr> m_items );

    // QAbstractItemModel interface
public:
    virtual int rowCount(const QModelIndex &parent) const override;
    virtual QVariant data(const QModelIndex &index, int role) const override;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Q_INVOKABLE QVariantMap modeParam(int socketId, int modeIndeex, bool isCoag) const;
    Q_INVOKABLE void expandSocket(int row);
    Q_INVOKABLE void collapseSocket(int row);
    QStringList modeNames(int socketID, bool isCoag) const;
    QStringList instrumNames(int socketId, int modeIndex, bool isCoag);

public:
    bool commitModeChange(int socketId, int modeINdex, const QVariantMap& param);
    SockPtr socketByName(const QString& socket) const;
    SockPtr socketById(int id) const;


signals:
    void signalSocketStateChanged(int socketId, int state);
    void signalSocketContentChanged(int socketId, const QByteArray& content);

    // QAbstractItemModel interface
public:
    virtual QHash<int, QByteArray> roleNames() const override final;
    void setItemsMap(const std::map<int, SockPtr > &newItemsMap, bool add = false);
    void setItemsMapVector(const std::vector<std::map<int, SockPtr >> &newItemsMapVector);
    void setInstrumMap(const std::map<int, QSharedPointer<Instrument> > &newInstrumMap);
    void setCurrentProgSubIndex(int newIndex);

private:
    std::map<int, SockPtr>* m_itemsMap = nullptr;
    std::vector<std::map<int, SockPtr >> m_itemsMapVect;
    int m_curMapIdx = 0;
    std::map<int, QSharedPointer<Instrument>> m_instrumMap;
    QStringList m_socketNames;
    // SocketModeEditor * editor;
};

#endif // SOCKETMODEL_H
