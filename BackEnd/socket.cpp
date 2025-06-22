#include "socket.h"
#include <QDebug>
#include <QtQml/qqml.h>


namespace {
QStringList sortByExample(const QStringList& toSort, const QStringList& reference)
{
    //это отстойный по эффективности алгоритм, но применяем мы его только 8 раз на старте. (может как-то отпраллелить)
    //если будет мешать - можно вхардкодить
    QStringList result = toSort;

    std::stable_sort(result.begin(), result.end(),
                     [&reference](const QString& a, const QString& b) {
                         int indexA = reference.indexOf(a);
                         int indexB = reference.indexOf(b);

                         if (indexA != -1 && indexB != -1) return indexA < indexB;
                         if (indexA != -1) return true;
                         if (indexB != -1) return false;
                         return false;
                     });

    return result;
}
}


SOCKET::SOCKET(SOCKET::SocType type) :
    m_coagModeIndex(0),
    m_cutModeIndex(0),
    m_coagModePower(1),
    m_cutModePower(1),
    m_socketType(type),
    m_socketStatus(S_ENABLED)
{
    // m_socketStatus = S_ENABLED;
    // m_cutModeIndex = 0;
    // m_coagModeIndex = 0;
    // m_socketType = type;
}


int SOCKET::coagModeIndex() const
{
    return m_coagModeIndex;
}

bool SOCKET::setCoagModeIndex(int newCoagModeIndex)
{
    return setModeIndex(newCoagModeIndex, true);
}

int SOCKET::cutModeIndex() const
{
    return m_cutModeIndex;
}

bool SOCKET::setCutModeIndex(int newCutModeIndex)
{
    return setModeIndex(newCutModeIndex, false);
}

int SOCKET::checkMode(const QString &modeName)
{
    if (m_coagModeNames.contains(modeName))
        return COAG;
    if (m_cutModeNames.contains(modeName))
        return CUT;

    return NONE;
}

void SOCKET::setCoagModeIndex(const QString &coagModeName)
{
    setCoagModeIndex(m_coagModeNames.indexOf(coagModeName));
}

void SOCKET::setCutModeIndex(const QString &cutModeName)
{
    setCutModeIndex(m_cutModeNames.indexOf(cutModeName));
}

SOCKET::SocType SOCKET::socketType() const
{
    return m_socketType;
}

void SOCKET::setSocketType(SOCKET::SocType newSocketType)
{
    if (m_socketType == newSocketType)
        return;
    m_cutModeNames.clear();
    m_coagModeNames.clear();
    m_cutModes.clear();
    m_coagModes.clear();
    m_socketType = newSocketType;
}

EshfMode::EshfMode(QString name,
                   bool isCoag,
                   int maximum,
                   int minimum) :
    m_maximumPower(maximum),
    m_minimumPower(minimum),
    m_currentPower(1),
    m_modeName( name),
    m_isCoag(isCoag)
{
    // Q_UNUSED(parent);
}

int EshfMode::maximumPower() const
{
    return m_maximumPower;
}

void EshfMode::setMaximumPower(int newMaximumPower)
{
    if (m_maximumPower == newMaximumPower)
        return;
    m_maximumPower = newMaximumPower;
}

bool EshfMode::setCurrentpower(int newCurrentpower)
{
    if (newCurrentpower <= m_maximumPower
        && newCurrentpower >= m_minimumPower) {
        m_currentPower = newCurrentpower;
        return true;
    } else {
        return false;
    }
}

int EshfMode::minimumPower() const
{
    return m_minimumPower;
}

const QString &EshfMode::modeName() const
{
    return m_modeName;
}

void EshfMode::setModeName(const QString &newModeName)
{
    if (m_modeName == newModeName)
        return;
    m_modeName = newModeName;
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

const QString &SOCKET::coagModeName() const
{
    return m_coagModeNames.at(m_coagModeIndex);
}

const QString &SOCKET::cutModeName() const
{
    return m_cutModeNames.at(m_cutModeIndex);
}

const QStringList &SOCKET::cutModes() const
{
    return m_cutModeNames;
}

const QStringList &SOCKET::coagModes() const
{
    return m_coagModeNames;
}

void SOCKET::setSocketName(const QString &newSocketName)
{
    if (m_socketName == newSocketName)
        return;
    m_socketName = newSocketName;
}

int SOCKET::coagModePower() const
{
    return m_coagModePower;
}

bool SOCKET::setCoagModePower(int newCoagModePower)
{
    return setModePower(newCoagModePower, false);
}

int SOCKET::cutModePower() const
{
    return m_cutModePower;
}

bool SOCKET::setCutModePower(int newCutModePower)
{
    return setModePower(newCutModePower, false);
}

QSharedPointer<const EshfMode> SOCKET::getMode(const QString &name, bool isCoag) const
{
    const QHash<QString, QSharedPointer<EshfMode>> & container =
        isCoag ? m_coagModes : m_cutModes;

    const auto modeIter = container.find(name);
    if (modeIter == container.cend()) {
        return nullptr;
    } else {
        return *modeIter;
    }

}

bool SOCKET::setModePower(int newPower, bool isCoag)
{
    auto iter = isCoag
        ? m_coagModes.find(m_coagModeNames.at(m_coagModeIndex))
        : m_cutModes.find(m_cutModeNames.at(m_cutModeIndex));

    if ((*iter)->setCurrentpower(newPower)) {
        m_coagModePower = newPower;
        return true;
    } else {
        return false;
    }
}

bool SOCKET::setModeIndex(int index, bool isCoag)
{
    const QStringList& modeNames = isCoag ? m_coagModeNames : m_cutModeNames;
    int& compareIdx = isCoag ? m_coagModeIndex : m_cutModeIndex;

    if ((index == compareIdx) ||
        (index >= modeNames.size()) ||
        (index < 0)) {
        return false;
    } else {
        compareIdx = index;
        return true;
    }
}

QStringList SOCKET::cutModeNames() const
{
    return m_cutModeNames;
}

QStringList SOCKET::coagModeNames() const
{
    return m_coagModeNames;
}

void SOCKET::setCoagModes(const QHash<QString, QSharedPointer<EshfMode> > &newCoagModes,
                          const QStringList &order)
{
    m_coagModes = newCoagModes;
    if (!order.isEmpty() && order.size() == m_coagModes.size()) {
        m_coagModeNames = sortByExample(m_coagModes.keys(), order);
    } else {
        m_coagModeNames = m_coagModes.keys();
    }
}

void SOCKET::setCutModes(const QHash<QString, QSharedPointer<EshfMode> > &newCutModes,
                         const QStringList &order)
{
    m_cutModes = newCutModes;
    if (!order.isEmpty() && order.size() == m_cutModes.size()) {
        m_cutModeNames = sortByExample(m_cutModes.keys(), order);
    } else {
        m_cutModeNames = m_cutModes.keys();
    }
}

QSharedPointer<const EshfMode> SOCKET::getCoagMode(const QString &name) const
{
    return getMode(name, true);
}

QSharedPointer<const EshfMode> SOCKET::getCutMode(const QString &name) const
{
    return getMode(name, false);
}



/*
void SOCKET::generatingModeList(SOCKET* socket)
{
    int coagStart = 0;
    int cutStart = 0;
    int coagStop = 0;
    int cutStop = 0;
    switch (socket->socketType()) {
    case SocType::EMPTY:
        m_socketName = QString("EMPTY");
        cutStart = 0;  cutStop = 0;
        coagStart = 0;   coagStop = 0;
        break;
    case SocType::BIPOLAR_1:
        m_socketName = QString("BIPOLAR 1");
        cutStart = 1;  cutStop = 4+1;
        coagStart = 5;   coagStop = 6+1;
        break;
    case SocType::BIPOLAR_2:
        m_socketName = QString("BIPOLAR 2");
        cutStart = 1;  cutStop = 4+1;
        coagStart = 5;   coagStop = 7+1;
        break;
    case SocType::MONOPOLAR_1:
        m_socketName = QString("MONOPOLAR 1");
        cutStart = 8;   cutStop = 18+1;
        coagStart = 19;   coagStop = 26+1;
        break;
    case SocType::MONOPOLAR_2:
        m_socketName = QString("MONOPOLAR 2");
        cutStart = 8;  cutStop = 18+1;
        coagStart = 19;   coagStop = 22+1;
        break;
    }
    cutModes.append(new EshfMode(modesNames[0], modesMaxPowers[0], false, this));
    coagModes.append(new EshfMode(modesNames[0], modesMaxPowers[0],true, this));
    QQmlEngine::setObjectOwnership(cutModes.last(), QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(coagModes.last(), QQmlEngine::CppOwnership);

    for (int i = cutStart; i < cutStop; ++i) {
        cutModes.append(new EshfMode(modesNames[i], modesMaxPowers[i], false, this));
        QQmlEngine::setObjectOwnership(cutModes.last(), QQmlEngine::CppOwnership);
        connect(cutModes.last(), &EshfMode::currentPowerChanged, this, &SOCKET::cutPowerChange);
    }
    for (int i = coagStart; i < coagStop; ++i) {
        coagModes.append(new EshfMode(modesNames[i], modesMaxPowers[i], true, this));
        QQmlEngine::setObjectOwnership(coagModes.last(), QQmlEngine::CppOwnership);
        connect(coagModes.last(), &EshfMode::currentPowerChanged, this, &SOCKET::coagPowerChange);
    }
}
*/

// QByteArray SOCKET::outputInfo(SOCKET *changedSocket, bool isCoag)
// {
//     QByteArray message;
//     int outNum = ((static_cast<int>(changedSocket->socketType()))*2 - (isCoag ? 0 : 1));
//     int modeNum;
//     EshfMode *changedMode;
//     int power;

//     // if (isCoag) changedMode = changedSocket->getCoagMode(changedSocket->coagModeIndex());
//     // else changedMode = changedSocket->getCutMode(changedSocket->cutModeIndex());
//     modeNum = modesNames.indexOf(changedMode->modeName());
//     power = changedMode->currentPower();

//     QString outputInfo = QString("O%1 %2 %3     \n").arg(outNum).arg(modeNum).arg(power);
//     return message.append(outputInfo.toLatin1());
// }

