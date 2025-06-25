#include "socketmodel.h"
#include <QQmlEngine>

SocketModel::SocketModel(QObject *parent)
    : QAbstractListModel{parent}
{

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
        return socketItem.getMode(socketItem.coagModeName())->minimumPower();
    case CoagModeMaxPower:
        return socketItem.getMode(socketItem.coagModeName())->maximumPower();

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
        return socketItem.getMode(socketItem.cutModeName())->minimumPower();
    case CutModeMaxPower:
        return socketItem.getMode(socketItem.cutModeName())->maximumPower();
    case CoagModesNames:
        return socketItem.coagModeNames();
    case CutModesNames:
        return socketItem.cutModeNames();

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

QVariantMap SocketModel::modeParam(const QString &socket, const QString &mode) const
{
    QSharedPointer<const SOCKET> itemPtr = socketByName(socket);

    QVariantMap result;
    if (itemPtr.isNull())
        return result;

    result = itemPtr->getMode(mode)->params();

    //other params can be added as well since it is variant map
    // result["other"] = whatever;
    return result;
}

QStringList SocketModel::modeNames(const QString &socket, const QString &mode) const
{
    QSharedPointer<const SOCKET> itemPtr = socketByName(socket);

    QStringList result;
    if (itemPtr.isNull())
        return result;

    result = itemPtr->getMode(mode)->isCoag()
                 ? itemPtr->coagModeNames()
                 : itemPtr->cutModeNames();

    //other params can be added as well since it is variant map
    // result["other"] = whatever;
    return result;

}

void SocketModel::acceptChanges(const QString &socket, const QString &mode, int power)
{
    QSharedPointer<SOCKET> itemPtr = socketByName(socket);

    if (itemPtr.isNull())
        return;

    QModelIndex idx = createIndex(m_items.indexOf(itemPtr), 0);

    int check = itemPtr->checkMode(mode);
    switch (check) {
    case SOCKET::COAG:
        itemPtr->setCoagModeIndex(mode);
        itemPtr->setCoagModePower(power);
        emit dataChanged(idx, idx);
        break;
    case SOCKET::CUT:
        itemPtr->setCutModeIndex(mode);
        itemPtr->setCoagModePower(power);
        emit dataChanged(idx, idx);
        break;
    default:
        break;
    }

}

bool SocketModel::commitModeChange(const QString &socket, const QString &mode, QVariantMap param)
{
    QSharedPointer<SOCKET> itemPtr = socketByName(socket);

    if (itemPtr.isNull())
        return false;

    QModelIndex idx = createIndex(m_items.indexOf(itemPtr), 0);

    int check = itemPtr->checkMode(mode);
    switch (check) {
    case SOCKET::COAG:
        if (itemPtr->setCoagModeIndex(mode)) {
            if (itemPtr->getNonConstMode(mode)->setParams(param)) {
                emit dataChanged(idx, idx);
                return true;
            }
        }
        break;
    case SOCKET::CUT:
        if (itemPtr->setCutModeIndex(mode)) {
            if (itemPtr->getNonConstMode(mode)->setParams(param)) {
                emit dataChanged(idx, idx);
                return true;
            }
        }
        break;
    default:
        break;
    }
    return false;
}

QSharedPointer<SOCKET> SocketModel::socketByName(const QString &socket) const
{
    QSharedPointer<SOCKET> itemPtr = nullptr;
    for (auto& item : m_items) {
        if (item->socketName() == socket) {
            itemPtr = item;
            break;
        }
    }
    return itemPtr;
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
    roles[CutModesNames] = "cutmodesnames";
    roles[CoagModesNames] = "coagmodesnames";
    return roles;
}
