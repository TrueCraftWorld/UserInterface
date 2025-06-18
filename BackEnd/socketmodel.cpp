#include "socketmodel.h"
// #include <QQmlEngine>

SocketModel::SocketModel(QObject *parent)
    : QAbstractListModel{parent}
{
    // QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}


int SocketModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_items.length();
}

QVariant SocketModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (index.row() >= m_items.size())
        return QVariant();

    const SOCKET& socketItem = *m_items.at(index.row());

    switch (role) {
    case Qt::DisplayRole:
        return QVariant();
    case SocketStatus:
        return socketItem.socketStatus();
    case SocketName:
        return socketItem.socketName();
    case SocketPolarity:
        return socketItem.socketType();
    case CoagModeIndex:
        return socketItem.coagModeIndex();
    case CoagModeName:
        return socketItem.coagModeName();
    case CoagModePower:
        return socketItem.coagModePower();
    case CoagModeMinPower:
        return socketItem.getCoagMode(socketItem.coagModeName())->minimumPower();
    case CoagModeMaxPower:
        return socketItem.getCoagMode(socketItem.coagModeName())->maximumPower();

        ///todo realize smthg
    case CoagModeInstrName:
    case CoagModeInstrImage:
    case CoagModeInstrIndex:
        return QVariant();

    case CutModeIndex:
        return socketItem.cutModeIndex();
    case CutModeName:
        return socketItem.cutModeName();
    case CutModePower:
        return socketItem.cutModePower();
    case CutModeMinPower:
        return socketItem.getCutMode(socketItem.cutModeName())->minimumPower();
    case CutModeMaxPower:
        return socketItem.getCutMode(socketItem.cutModeName())->maximumPower();

        ///todo realize smthg
    case CutModeInstrName:
    case CutModeInstrImage:
    case CutModeInstrIndex:
        return QVariant();
    default:
        return QVariant();
    }

    return QVariant();
}

bool SocketModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid())
        return false;
    if (index.row() >= m_items.length())
        return false;

    SOCKET& socketItem = *m_items[index.row()];

    switch (role) {
    case CoagModeIndex:
        return socketItem.setCoagModeIndex(value.toInt());
    case CutModeIndex:
        return socketItem.setCutModeIndex(value.toInt());
    case CutModePower:
        return socketItem.setCutModePower(value.toInt());
    case CoagModePower:
        return socketItem.setCoagModePower(value.toInt());
    default:
        break;
    }
    return false;
}

void SocketModel::setItems(const QList<QSharedPointer<SOCKET> > &newItems)
{
    beginResetModel();
    m_items = newItems;
    endResetModel();
}


QHash<int, QByteArray> SocketModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    roles[SocketStatus] = "socketstatus";
    roles[SocketName] = "socketname";
    roles[SocketPolarity] = "socketpolarity";
    roles[CoagModeIndex] = "coagmodeindex";
    roles[CoagModeName] = "coagmodename";
    roles[CoagModePower] = "coagmodepower";
    roles[CoagModeMinPower] = "coagmodeminpower";
    roles[CoagModeMaxPower] = "coagmodemaxpower";
    roles[CoagModeInstrName] = "coagmodeinstrname";
    roles[CoagModeInstrImage] = "coagmodeinstrimage";
    roles[CoagModeInstrIndex] = "coagmodeinstrindex";
    roles[CutModeIndex] = "cutmodeindex";
    roles[CutModeName] = "cutmodename";
    roles[CutModePower] = "cutmodepower";
    roles[CutModeMinPower] = "cutmodeminpower";
    roles[CutModeMaxPower] = "cutmodemaxpower";
    roles[CutModeInstrName] = "cutmodeinstrname";
    roles[CutModeInstrImage] = "cutmodeinstrimage";
    roles[CutModeInstrIndex] = "cutmodeinstrindex";
    return roles;
}
