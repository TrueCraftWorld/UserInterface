#include "socketmodel.h"
#include <QQmlEngine>

SocketModel::SocketModel(QObject *parent)
    : QAbstractListModel{parent}
{

}

int SocketModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    if (m_itemsMap == nullptr)
        return 0;
    return m_itemsMap->size();
}

QVariant SocketModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (index.row() >= m_socketNames.size())
        return QVariant();

    if (m_itemsMap == nullptr)
        return QVariant();

    const auto socketIter = m_itemsMap->find(index.row());
    if (socketIter == m_itemsMap->cend())
        return QVariant();

    const SOCKET& socketItem = *(socketIter->second);

    switch (role) {
    case Qt::DisplayRole:
        return QVariant();
    case SocketEnabled:
        return socketItem.socketStatus() >= SOCKET::S_ENABLED;
    case SocketAllowed:
        return socketItem.socketStatus() != SOCKET::S_OFF;
    case SocketStatus:
        return static_cast<int>(socketItem.socketStatus());
    case SocketDisplayMode:
        return static_cast<int>(socketItem.displayMode());
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
        return socketItem.curCoagMode()->maximumPower();

        ///todo realize smthg
    case CoagModeInstrName:
    {
        auto iter = m_instrumMap.find(socketItem.curCoagMode()->selectedInstrId());
        if (iter != m_instrumMap.end())
            return iter->second->name();
        else
        return tr("Не выбран");
    }
    case CoagModeInstrID:
        //это по боевому
        // return socketItem.curCoagMode()->selectedInstrId();
        // а это для альфа теста
        return socketItem.curCoagMode()->selectedInstrIndex();

    case CoagModeInstrImage:
        //тут можно возращеть строку с именем или даже целиком с нужным ImageProvider
    case CoagModeInstrIndex:
        return QVariant();

    case CutModeIndex:
        return socketItem.cutModeIndex();
    case CutModeName:
        return socketItem.cutModeName();
    case CutModePower:
        return socketItem.cutModePower();
    case CutModeMinPower:
        return socketItem.curCutMode()->minimumPower();
    case CutModeMaxPower:
        return socketItem.curCutMode()->maximumPower();
    case CoagModesNames:
        return socketItem.coagModeNames();
    case CutModesNames:
        return socketItem.cutModeNames();

        ///todo realize smthg
    case CutModeInstrName:
    {
        auto iter = m_instrumMap.find(socketItem.curCutMode()->selectedInstrId());
        if (iter != m_instrumMap.end())
            return iter->second->name();
        else
            return QVariant();
    }
        // return socketItem.curCutMode()->curInstrName();
    case CutModeInstrID:
        //это по боевому
        // return socketItem.curCutMode()->selectedInstrId();
        // а это для альфа теста
        return socketItem.curCutMode()->selectedInstrIndex();
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

    if (m_itemsMap == nullptr)
        return false;

    if (m_itemsMap->find((index.row())) == m_itemsMap->end())
        return false;
    auto socketIter = (*m_itemsMap)[(index.row())];

    SOCKET& socketItem = *(socketIter);

    switch (role) {
    case SocketEnabled:
    {
        if (socketItem.socketStatus() == SOCKET::S_OFF)
            return false;
        bool isOk = value.toBool();
        socketItem.setSocketStatus(isOk ? SOCKET::S_ENABLED : SOCKET::S_DISABLED);
        return true;
    }
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
    if (m_itemsMap == nullptr)
        return QVariantMap{};

    auto iter = m_itemsMap->find(socketId);
    if (iter == m_itemsMap->end() || iter->second.isNull())
        return QVariantMap{};

    return iter->second->getMode(modeIndeex, isCoag)->params();
}

QStringList SocketModel::modeNames(int socketID, bool isCoag) const
{
    if (m_itemsMap == nullptr)
        return QStringList{};

    auto iter = m_itemsMap->find(socketID);
    if (iter == m_itemsMap->end() || iter->second.isNull())
        return QStringList{};
    return isCoag ? iter->second->coagModeNames() : iter->second->cutModeNames();
}

QStringList SocketModel::instrumNames(int socketId, int modeIndex, bool isCoag)
{
    if (m_itemsMap == nullptr)
        return QStringList{};

    auto iter = m_itemsMap->find(socketId);
    if (iter == m_itemsMap->end() || iter->second.isNull())
        return {};

    SockPtr sock = iter->second;
    CSurgModePtr mode = sock->getMode(modeIndex, isCoag);
    const std::map<int, InstrInfo>& compatible = mode->InstrConstraints();

    QStringList names;
    for (const auto&[key, item] : compatible) {
        const auto instIter = m_instrumMap.find(item.id);
        if (instIter != m_instrumMap.end())
            names.append(instIter->second->name());
    }
    return names;
}

bool SocketModel::commitModeChange(int socketId, int modeINdex, const QVariantMap &param)
{
    if (m_itemsMap == nullptr)
        return false;

    auto iter = m_itemsMap->find(socketId);
    if (iter == m_itemsMap->end() || iter->second.isNull())
        return false;

    QModelIndex idx = createIndex(m_socketNames.indexOf(iter->second->socketName()), 0);

    const QString modeName = param.value("name").toString();
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
        if (iter->second->setInstrumIndex(param.value("instrindex").toInt(), true)) {
            roles.append(CoagModeInstrName);
            roles.append(CoagModeInstrIndex);
            roles.append(CoagModeInstrID);
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
        if (iter->second->setInstrumIndex(param.value("instrindex").toInt(), false)) {
            roles.append(CutModeInstrName);
            roles.append(CutModeInstrIndex);
            roles.append(CutModeInstrID);
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

SockPtr SocketModel::socketByName(const QString &socket) const
{
    SockPtr itemPtr = nullptr;

    if (m_itemsMap == nullptr)
        return itemPtr;

    for (auto& item : (*m_itemsMap)) {
        if (item.second->socketName() == socket) {
            itemPtr = item.second;
            break;
        }
    }
    return itemPtr;
}

SockPtr SocketModel::socketById(int id) const
{
    if (m_itemsMap == nullptr)
        return nullptr;

    auto iter = m_itemsMap->find(id);
    if (iter == m_itemsMap->end())
        return nullptr;
    return iter->second;
}

void SocketModel::setInstrumMap(const std::map<int, QSharedPointer<Instrument>> &newInstrumMap)
{
    m_instrumMap = newInstrumMap;
}

bool SocketModel::setCurrentProgSubIndex(int newIndex)
{
    if (newIndex >= m_itemsMapVect.size() || newIndex < 0)
        return false;
    // if (newIndex == m_curMapIdx)
    //     return true;

    beginResetModel();
    m_curMapIdx = newIndex;
    m_itemsMap = &(m_itemsMapVect.at(m_curMapIdx));
    m_socketNames.clear();
    for (int i = SOCKET::BIPOLAR_1; i <= SOCKET::MONOPOLAR_2; ++i) {
        const auto iter = m_itemsMap->find(i - 1);
        if (iter == m_itemsMap->cend())
            continue;
        m_socketNames.append(iter->second->socketName());
    }
    // m_socketNames.append(m_itemsMap->SOCKET::BIPOLAR_1);
    endResetModel();

}

void SocketModel::setItemsMap(const std::map<int, SockPtr > &newItemsMap, bool add)
{
    beginResetModel();
    m_itemsMap = nullptr;
    if (!add) m_itemsMapVect.clear();
    m_itemsMapVect.push_back(newItemsMap);
    // setCurrentProgSubIndex(m_itemsMapVect.size() - 1);

    m_curMapIdx = m_itemsMapVect.size() - 1;
    m_itemsMap = &(m_itemsMapVect.at(m_curMapIdx));
    m_socketNames.clear();
    for (int i = SOCKET::BIPOLAR_1; i <= SOCKET::MONOPOLAR_2; ++i) {
        const auto iter = m_itemsMap->find(i - 1);
        if (iter == m_itemsMap->cend())
            continue;
        m_socketNames.append(iter->second->socketName());
    }
    // m_curMapIdx = 0;
    // m_itemsMap = newItemsMap;
    endResetModel();

}

void SocketModel::setItemsMapVector(const std::vector<std::map<int, SockPtr> > &newItemsMapVector)
{
    beginResetModel();
    m_itemsMap = nullptr;
    m_itemsMapVect.clear();
    m_itemsMapVect = newItemsMapVector;

    m_curMapIdx = 0;
    m_itemsMap = &(m_itemsMapVect.at(m_curMapIdx));
    m_socketNames.clear();
    for (int i = SOCKET::BIPOLAR_1; i <= SOCKET::MONOPOLAR_2; ++i) {
        const auto iter = m_itemsMap->find(i - 1);
        if (iter == m_itemsMap->cend())
            continue;
        m_socketNames.append(iter->second->socketName());
    }

    // setCurrentProgSubIndex(0);,
    // m_curMapIdx = 0;
    endResetModel();
}


QHash<int, QByteArray> SocketModel::roleNames() const
{
    //грёбаная мета-магия, но это приятное
    QMetaEnum metaEnum = QMetaEnum::fromType<SocketRoles>();
    static QHash<int, QByteArray> roles;
    for (int k = 0; k < metaEnum.keyCount(); k++)
    {
        int roleKey = metaEnum.value(k);
        QString roleName = metaEnum.valueToKey(roleKey);
        roleName = roleName.toLower();
        roles.insert(roleKey, roleName.toUtf8());
    }
    return roles;
}
