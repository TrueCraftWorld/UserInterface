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

int EshfMode::currentPower() const
{
    return m_currentPower;
}

void EshfMode::setMaximumPower(int newMaximumPower)
{
    if (m_maximumPower == newMaximumPower)
        return;
    m_maximumPower = newMaximumPower;
}

bool EshfMode::isCoag() const
{
    return m_isCoag;
}

bool EshfMode::setCurrentPower(int newCurrentpower)
{
    if (newCurrentpower <= m_maximumPower
        && newCurrentpower >= m_minimumPower) {
        m_currentPower = newCurrentpower;
        return true;
    } else {
        return false;
    }
}

bool EshfMode::setParams(const QVariantMap &params)
{
    QString tmpName = params.value("name").toString();
    int tmpMin = params.value("minpower").toInt();
    int tmpMax = params.value("maxpower").toInt();
    bool tmpIsCoag = params.value("iscoag").toBool();

    //проверяяем что прислали изменения к нашему режиму и не пытаются поменять константы
    if ((tmpName != m_modeName)
        || (tmpIsCoag != m_isCoag)
        || (tmpMin != m_minimumPower)
        || (tmpMax != m_maximumPower))
        return false;
    int tmpCur = params.value("currentpower").toInt();
    //проверяем что мощность удовлетворяет ограничениям
    if ( (tmpCur >= m_minimumPower)
        && (tmpCur <= m_maximumPower) ) {
        m_currentPower = tmpCur;
        return true;
    }
    return false;
    // QVariantMap param
}

QVariantMap EshfMode::params() const
{
    QVariantMap res;
    res["name"] = m_modeName;
    res["currentpower"] = m_currentPower;
    res["minpower"] = m_minimumPower;
    res["maxpower"] = m_maximumPower;
    res["iscoag"] = m_isCoag;
    return res;
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


SOCKET::SOCKET(SOCKET::SocType type) :
    m_coagModeIndex(0),
    m_cutModeIndex(0),
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

int SOCKET::checkMode(const QString &modeName) const
{

    ///ОШИБКА ЕСЛИ NO_MODE
    if (m_coagModeNames.contains(modeName))
        return COAG;
    if (m_cutModeNames.contains(modeName))
        return CUT;

    return NONE;
}

bool SOCKET::setCoagModeIndex(const QString &coagModeName)
{
    return setCoagModeIndex(m_coagModeNames.indexOf(coagModeName));
}

bool SOCKET::setCutModeIndex(const QString &cutModeName)
{
    return setCutModeIndex(m_cutModeNames.indexOf(cutModeName));
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

QSharedPointer<const EshfMode> SOCKET::getMode(const QString &name) const
{
    switch (checkMode(name)) {
    case CUT:
        if (m_cutModeNames.contains(name))
            return m_cutModes.value(name);
        else
            break;
    case COAG:
        if (m_coagModeNames.contains(name))
            return m_coagModes.value(name);
        else
            break;

    default:
        break;
    }
    return nullptr;
}

int SOCKET::coagModePower() const
{
    if (m_curCoagMode.isNull())
        return 1;
    return m_curCoagMode->currentPower();
}

bool SOCKET::setCoagModePower(int newCoagModePower)
{
    return setModePower(newCoagModePower, false);
}

int SOCKET::cutModePower() const
{
    // return m_cutModePower;
    if (m_curCutMode.isNull())
        return 1;
    return m_curCutMode->currentPower();
}

bool SOCKET::setCutModePower(int newCutModePower)
{
    return setModePower(newCutModePower, false);
}

QSharedPointer<const EshfMode> SOCKET::getMode(const QString &name, ModeType type) const
{
    if (type == NONE)
        return nullptr;

    const QHash<QString, QSharedPointer<EshfMode>> & container =
        type == COAG ? m_coagModes : m_cutModes;

    const auto modeIter = container.find(name);
    if (modeIter == container.cend()) {
        return nullptr;
    } else {
        return *modeIter;
    }

}

QSharedPointer<const EshfMode> SOCKET::curCutMode() const
{
    return m_curCutMode;
}

QSharedPointer<const EshfMode> SOCKET::curCoagMode() const
{
    return m_curCoagMode;
}

bool SOCKET::setModePower(int newPower, bool isCoag)
{
    auto iter = isCoag
        ? m_coagModes.find(m_coagModeNames.at(m_coagModeIndex))
        : m_cutModes.find(m_cutModeNames.at(m_cutModeIndex));

    if ((*iter)->setCurrentPower(newPower)) {
        return true;
    } else {
        return false;
    }
    return false;
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
        QSharedPointer<const EshfMode> mode = isCoag ? m_coagModes[modeNames.at(compareIdx)] : m_cutModes[modeNames.at(compareIdx)];
        (isCoag ? m_curCoagMode : m_curCutMode) = mode;
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
    if (!order.isEmpty()) {
        m_coagModeNames = sortByExample(m_coagModes.keys(), order);
    } else {
        m_coagModeNames = m_coagModes.keys();
    }
}

void SOCKET::setCutModes(const QHash<QString, QSharedPointer<EshfMode> > &newCutModes,
                         const QStringList &order)
{
    m_cutModes = newCutModes;
    if (!order.isEmpty()) {
        m_cutModeNames = sortByExample(m_cutModes.keys(), order);
    } else {
        m_cutModeNames = m_cutModes.keys();
    }
}
