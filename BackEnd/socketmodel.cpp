#include "socketmodel.h"
#include <QQmlEngine>

SocketModel::SocketModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

int SocketModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_itemsMap.size();
}

QVariant SocketModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (index.row() >= m_socketNames.size())
        return QVariant();

    const auto socketIter = m_itemsMap.find(index.row());
    if (socketIter == m_itemsMap.cend())
        return QVariant();

    const SOCKET& socketItem = *(socketIter->second);

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
        return socketItem.curCoagMode()->minimumPower();
    case CoagModeMaxPower:
        return socketItem.curCutMode()->maximumPower();

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

    if (index.row() >= m_socketNames.size())
        return false;

    if (m_itemsMap.find(/*m_socketNames.at*/(index.row())) == m_itemsMap.end())
        return false;
    auto socketIter = m_itemsMap[/*m_socketNames.at*/(index.row())];
    // if (socketIter == m_itemsMap.end())
        // return QVariant();

    SOCKET& socketItem = *(socketIter);

    // if (index.row() >= m_items.length())
    //     return false;

    // SOCKET& socketItem = *m_items[index.row()];

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

QVariantMap SocketModel::modeParam(int socketId, int modeIndeex, bool isCoag) const
{
    auto iter = m_itemsMap.find(socketId);
    if (iter == m_itemsMap.end() || iter->second.isNull())
        return QVariantMap{};

    return iter->second->getMode(modeIndeex, isCoag)->params();
}

// QVariantMap SocketModel::modeParam(const QString &socket, const QString &mode) const
// {
//     QSharedPointer<const SOCKET> itemPtr = socketByName(socket);

//     QVariantMap result;
//     if (itemPtr.isNull())
//         return result;

//     result = itemPtr->getMode(mode)->params();

//     //other params can be added as well since it is variant map
//     // result["other"] = whatever;
//     return result;
// }

// QStringList SocketModel::modeNames(const QString &socket, const QString &mode) const
// {
//     QSharedPointer<const SOCKET> itemPtr = socketByName(socket);

//     QStringList result;
//     if (itemPtr.isNull())
//         return result;

//     result = itemPtr->getMode(mode)->isCoag()
//                  ? itemPtr->coagModeNames()
//                  : itemPtr->cutModeNames();

//     return result;
// }

QStringList SocketModel::modeNames(int socketID, bool isCoag) const
{
    auto iter = m_itemsMap.find(socketID);
    if (iter == m_itemsMap.end() || iter->second.isNull())
        return QStringList{};
    return isCoag ? iter->second->coagModeNames() : iter->second->cutModeNames();
}

void SocketModel::acceptChanges(int socket, int mode, int power, bool isCoag)
{
    // auto iter = m_itemsMap.find(socket);
    // if (iter == m_itemsMap.end())
    //     return;

    // QModelIndex idx = createIndex(socket, 0);

    // if (isCoag) {
    //     itemPtr->setCoagModeIndex(mode);
    //     itemPtr->setCoagModePower(power);
    //     emit dataChanged(idx, idx, {CoagModeIndex, CoagModePower});
    // } else {
    //     itemPtr->setCutModeIndex(mode);
    //     itemPtr->setCoagModePower(power);
    //     emit dataChanged(idx, idx, {CutModeIndex, CutModePower});
    // }
}

// void SocketModel::acceptChanges(const QString &socket, const QString &mode, int power)
// {
//     QSharedPointer<SOCKET> itemPtr = socketByName(socket);

//     if (itemPtr.isNull())
//         return;

//     QModelIndex idx = createIndex(m_items.indexOf(itemPtr), 0);

//     int check = itemPtr->checkMode(mode);
//     switch (check) {
//     case SOCKET::COAG:
//         itemPtr->setCoagModeIndex(mode);
//         itemPtr->setCoagModePower(power);
//         emit dataChanged(idx, idx, {CoagModeIndex, CoagModePower});
//         break;
//     case SOCKET::CUT:
//         itemPtr->setCutModeIndex(mode);
//         itemPtr->setCoagModePower(power);
//         emit dataChanged(idx, idx, {CutModeIndex, CutModePower});
//         break;
//     default:
//         break;
//     }
// }

// bool SocketModel::commitModeChange(const QString &socket, const QString &mode, QVariantMap param)
// {
//     QSharedPointer<SOCKET> itemPtr = socketByName(socket);

//     if (itemPtr.isNull())
//         return false;

//     QModelIndex idx = createIndex(m_items.indexOf(itemPtr), 0);
//     const QString modeName = param.value("name").toString();
//     // acceptChanges(socket, modeName, param.value("currentpower").toInt());
//     // return true;
//     int check = itemPtr->checkMode(modeName);
//     bool res = false;
//     QVector<int> roles;
//     switch (check) {
//     case SOCKET::COAG:

//         if (itemPtr->setCoagModeIndex(modeName)) {
//             roles.append(CoagModeIndex);
//             roles.append(CoagModeName);
//             res = true;
//         }
//         if (itemPtr->setCoagModePower(param.value("currentpower").toInt())) {
//             roles.append(CoagModePower);
//             res = true;
//         }
//         if (res)
//             emit dataChanged(idx, idx, roles);
//         return res;
//         break;
//     case SOCKET::CUT:
//         if (itemPtr->setCutModeIndex(modeName)) {
//             roles.append(CutModeIndex);
//             roles.append(CutModeName);
//             res = true;
//         }
//         if (itemPtr->setCutModePower(param.value("currentpower").toInt())) {
//             roles.append(CutModePower);
//             res = true;
//         }
//         if (res)
//             emit dataChanged(idx, idx, roles);
//         return res;
//     default:
//         break;
//     }
//     return false;
// }

bool SocketModel::commitModeChange(int socketId, int modeINdex, const QVariantMap &param)
{
    auto iter = m_itemsMap.find(socketId);
    if (iter == m_itemsMap.end() || iter->second.isNull())
        return false;

    QModelIndex idx = createIndex(m_socketNames.indexOf(iter->second->socketName()), 0);

    const QString modeName = param.value("name").toString();
    // acceptChanges(socket, modeName, param.value("currentpower").toInt());
    // return true;
    int check = iter->second->checkMode(modeName);
    bool res = false;
    QVector<int> roles;
    switch (check) {
    case SOCKET::COAG:

        if (iter->second->setCoagModeIndex(modeINdex)) {
            roles.append(CoagModeIndex);
            roles.append(CoagModeName);
            res = true;
        }
        if (iter->second->setCoagModePower(param.value("currentpower").toInt())) {
            roles.append(CoagModePower);
            res = true;
        }
        if (res)
            emit dataChanged(idx, idx, roles);
        return res;
        break;
    case SOCKET::CUT:
        if (iter->second->setCutModeIndex(modeINdex)) {
            roles.append(CutModeIndex);
            roles.append(CutModeName);
            res = true;
        }
        if (iter->second->setCutModePower(param.value("currentpower").toInt())) {
            roles.append(CutModePower);
            res = true;
        }
        if (res)
            emit dataChanged(idx, idx, roles);
        return res;
    default:
        break;
    }
    return false;
}

QSharedPointer<SOCKET> SocketModel::socketByName(const QString &socket) const
{
    QSharedPointer<SOCKET> itemPtr = nullptr;
    for (auto& item : m_itemsMap) {
        if (item.second->socketName() == socket) {
            itemPtr = item.second;
            break;
        }
    }
    return itemPtr;
}

void SocketModel::setItemsMap(const std::map<int, QSharedPointer<SOCKET> > &newItemsMap)
{
    beginResetModel();
    m_itemsMap = newItemsMap;
    m_socketNames.clear();
    for (int i = SOCKET::BIPOLAR_1; i <= SOCKET::MONOPOLAR_2; ++i) {
        const auto iter = m_itemsMap.find(i - 1);
        if (iter == m_itemsMap.cend())
            continue;
        m_socketNames.append(iter->second->socketName());
    }
    // m_socketNames.append(m_itemsMap.SOCKET::BIPOLAR_1);
    endResetModel();
}

// void SocketModel::setItems(const QList<QSharedPointer<SOCKET> > &newItems)
// {
//     beginResetModel();
//     m_items = newItems;
//     endResetModel();
// }


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
