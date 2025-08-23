#include "socket.h"
#include <QDebug>
#include <QtQml/qqml.h>


namespace {
// QStringList sortByExample(const QStringList& toSort, const QStringList& reference)
// {
//     //это отстойный по эффективности алгоритм, но применяем мы его только 8 раз на старте. (может как-то отпраллелить)
//     //если будет мешать - можно вхардкодить
//     QStringList result = toSort;

//     std::stable_sort(result.begin(), result.end(),
//                      [&reference](const QString& a, const QString& b) {
//                          int indexA = reference.indexOf(a);
//                          int indexB = reference.indexOf(b);

//                          if (indexA != -1 && indexB != -1) return indexA < indexB;
//                          if (indexA != -1) return true;
//                          if (indexB != -1) return false;
//                          return false;
//                      });

//     return result;
// }
}

SOCKET::SOCKET(SOCKET::SocType type) :
    m_socketType(type),
    m_socketStatus(S_ENABLED),
    m_displayMode(S_COLLAPSED)
{
    // m_socketStatus = S_ENABLED;
    // m_cutModeIndex = 0;
    // m_coagModeIndex = 0;
    // m_socketType = type;
    m_cutHalf = HalfSockPtr::create(false);
    m_coagHalf = HalfSockPtr::create(true);
}


int SOCKET::coagModeIndex() const
{
    return m_coagHalf->modeIndex();
}

bool SOCKET::setCoagModeIndex(int newCoagModeIndex)
{
    return setModeIndex(newCoagModeIndex, true);
}

int SOCKET::cutModeIndex() const
{
    return m_cutHalf->modeIndex();
}

bool SOCKET::setCutModeIndex(int newCutModeIndex)
{
    return setModeIndex(newCutModeIndex, false);
}

bool SOCKET::setModeId(int id, bool isCoag)
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return false;
    return half->setModeId(id);
    // const QHash<QString, SurgModePtr>& modes = half->modes();
    // for (auto& item : modes) {
    //     if (item->id() == id) {
    //         half->curMode() = item : m_curCutMode = item;
    //         return true;
    //     }
    // }
    // return false;

}

SOCKET::SocType SOCKET::socketType() const
{
    return m_socketType;
}

void SOCKET::setSocketType(SOCKET::SocType newSocketType)
{
    if (m_socketType == newSocketType)
        return;
    // m_cutModeNames.clear();
    // m_coagModeNames.clear();
    // m_cutModes.clear();
    // m_coagModes.clear();
    m_socketType = newSocketType;
    m_cutHalf = HalfSockPtr::create(false);
    m_coagHalf = HalfSockPtr::create(true);
}

SOCKET::SocStatus SOCKET::socketStatus() const
{
    return m_socketStatus;
}

void SOCKET::setSocketStatus(SocStatus newSocketStatus)
{
    if (m_socketStatus == newSocketStatus)
        return;
    m_socketStatus = newSocketStatus;
}

const QString &SOCKET::socketName() const
{
    return m_socketName;
}

QString SOCKET::coagModeName() const
{
    if (m_coagHalf.isNull())
        return "";
    return m_coagHalf->modeName();
}

QString SOCKET::cutModeName() const
{
    if (m_cutHalf.isNull())
        return "";
    return m_cutHalf->modeName();
}

QStringList SOCKET::cutModeNames() const
{
    if (m_cutHalf.isNull())
        return {};
    return m_cutHalf->modeNames();
}

QStringList SOCKET::coagModeNames() const
{
    if (m_coagHalf.isNull())
        return {};
    return m_coagHalf->modeNames();
}

void SOCKET::setSocketName(const QString &newSocketName)
{
    if (m_socketName == newSocketName)
        return;
    m_socketName = newSocketName;
}


CSurgModePtr SOCKET::getMode(int modeIndex, bool isCoag) const
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return nullptr;
    bool hasMode = half->modeNames().size() > modeIndex;

    if (!hasMode)
        return nullptr;
    QString name = half->modeNames().at(modeIndex);
    return half->modes().value(name);
}

int SOCKET::coagModePower() const
{
    if (m_coagHalf.isNull())
        return 1;
    return m_coagHalf->modePower();
}

bool SOCKET::setCoagModePower(int newCoagModePower)
{
    return setModePower(newCoagModePower, true);
}

int SOCKET::cutModePower() const
{
    // return m_cutModePower;
    if (m_cutHalf.isNull())
        return 1;
    return m_cutHalf->modePower();
}

bool SOCKET::setCutModePower(int newCutModePower)
{
    return setModePower(newCutModePower, false);
}

CSurgModePtr SOCKET::getMode(const QString &name, bool isCoag) const
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return nullptr;

    const QHash<QString, SurgModePtr> & container =
        half->modes();

    const auto modeIter = container.find(name);
    if (modeIter == container.cend()) {
        return nullptr;
    } else {
        return *modeIter;
    }

}

CSurgModePtr SOCKET::curCutMode() const
{
    return m_cutHalf->curMode();
}

QByteArray SOCKET::toByteArray()
{
    /// Номер сокета (какой-нибудь индивидуальный код) 1байт (ну 256 сокетов это навсегда)
    /// Номер режима резания (индивидуальный код ) 2 байта (возможно второй байт для доп признаков)
    /// мощность режима резания (2 байта)
    /// Номер режима коагуляции (индивидуальный код )
    /// мощность режима коагуляции
    /// Итого 9 байт - 4 16бит значения и 1 8бит
    ///
    QByteArray res;
    // QDataStream stream();
    // stream << m_socketType << m_cutHalf->toByteArray() << m_coagHalf->toByteArray();

    return res;
}

bool SOCKET::setInstrumIndex(int index, bool isCoag)
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return false;


    QHash<QString, SurgModePtr> modes = half->modes();
    int curModeIdx = half->modeIndex();
    QStringList names = half->modeNames();

    if (curModeIdx >= names.size())
        return false;

    const QString& name = names.at(curModeIdx);

    SurgModePtr mode = modes[name];

    return mode->setSelectedInstrIndex(index);
}

bool SOCKET::setInstrumId(int id, bool isCoag)
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return false;

    QHash<QString, SurgModePtr> modes = half->modes();
    int curModeIdx = half->modeIndex();
    QStringList names = half->modeNames();

    if (curModeIdx >= names.size())
        return false;

    const QString& name = names.at(curModeIdx);

    SurgModePtr mode = modes[name];

    return mode->setSelectedInstrId(id);
}

void SOCKET::setAllowed(bool allow)
{
    if (m_socketStatus >= S_DISABLED && allow)
        return;
    if (m_socketStatus == S_OFF && (!allow))
        return;

    if (allow)
        m_socketStatus = S_ENABLED;
    else
        m_socketStatus = S_OFF;
}

CSurgModePtr SOCKET::curCoagMode() const
{
    return m_coagHalf->curMode();
}

bool SOCKET::setModePower(int newPower, bool isCoag)
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return false;
    return half->setModePower(newPower);
    // auto iter = isCoag
    //     ? m_coagModes.find(m_coagModeNames.at(m_coagModeIndex))
    //     : m_cutModes.find(m_cutModeNames.at(m_cutModeIndex));

    // if ((*iter)->setCurrentPower(newPower)) {
    //     return true;
    // } else {
    //     return false;
    // }
    // return false;
}

bool SOCKET::setModeIndex(int index, bool isCoag)
{
    HalfSockPtr half = isCoag ? m_coagHalf : m_cutHalf;
    if (half.isNull())
        return false;
    return half->setModeIndex(index);
/*    const QStringList& modeNames = half->modeNames();
    int& compareIdx = half->modeIndex();
    CSurgModePtr curMode = half->curMode();
    if (index == compareIdx) {
        return true;
    } else if (((index >= modeNames.size()) ||
            (index < 0)) && (!curMode.isNull())) {
        return false;
    } else {
        return half->setModeIndex(index);
        // compareIdx = index;
        // CSurgModePtr mode = isCoag ? m_coagModes[modeNames.at(compareIdx)] : m_cutModes[modeNames.at(compareIdx)];
        // (isCoag ? m_curCoagMode : m_curCutMode) = mode;
        return true;
    }
    */
}

int SOCKET::displayMode() const
{
    return m_displayMode;
}

void SOCKET::setDisplayMode(SocDisplayMode newDisplayMode)
{
    m_displayMode = newDisplayMode;
}

// QStringList SOCKET::cutModeNames() const
// {
//     return m_cutHalf->modeNames();
// }

// QStringList SOCKET::coagModeNames() const
// {
//     return m_coagHalf->modeNames();
// }

void SOCKET::setCoagModes(const QHash<QString, SurgModePtr > &newCoagModes,
                          const QStringList &order)
{
    if (m_coagHalf.isNull())
        return;
    m_coagHalf->setModes(newCoagModes, order);
    // m_coagModes = newCoagModes;
    // if (!order.isEmpty()) {
    //     m_coagModeNames = sortByExample(m_coagModes.keys(), order);
    // } else {
    //     m_coagModeNames = m_coagModes.keys();
    // }
    // if (m_coagModeNames.size())
    //     setCoagModeIndex(0);
}

void SOCKET::setCutModes(const QHash<QString, SurgModePtr > &newCutModes,
                         const QStringList &order)
{
    if (m_cutHalf.isNull())
        return;
    m_cutHalf->setModes(newCutModes, order);
    // m_cutModes = newCutModes;
    // if (!order.isEmpty()) {
    //     m_cutModeNames = sortByExample(m_cutModes.keys(), order);
    // } else {
    //     m_cutModeNames = m_cutModes.keys();
    // }
    // if (m_cutModeNames.size())
    //     setCutModeIndex(0);
}
