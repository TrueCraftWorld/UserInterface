#include "socketConstants.h"
#include <QDebug>
#include <QtQml/qqml.h>

enum eshfModes	{ NO_MODE = 0, BI_BLEND=1,
                            BI_TUR=2, BI_ARTRO=3, BI_GISTERO=4,
                            BI_COAG=5, BI_COAG_DISS=6, TERMOSHOV=7,
                            CUT=8, BLEND=9, BLEND1=10, TUR=11, VAP=12,
                            E_KNIFE1=13, E_KNIFE2=14, E_KNIFE3=15,
                            E_LOOP1=16, E_LOOP2=17, E_LOOP3=18,
                            FORCE=19, FULGUR=20, SOFT=21, SPRAY=22,
                            FULGUR_A=23, SPRAY_A=24,
                            FULGUR_P=25, SPRAY_P=26,
                            };
const QStringList modesNames = { "NO MODE", "BI BLEND",
                           "BI TUR", "BI ARTRO", "BI GISTERO",
                           "BI COAG", "BI COAG DISSECT", "TERMOSHOV",
                           "CUT", "BLEND", "BLEND1", "TUR", "VAP",
                           "ENDO KNIFE1", "ENDO KNIFE2", "ENDO KNIFE3",
                           "ENDO LOOP1", "ENDO LOOP2", "ENDO LOOP3",
                           "FORCE", "FULGUR", "SOFT", "SPRAY",
                           "FULGUR ARGON", "SPRAY ARGON",
                           "FULGUR PULSE ARGON", "SPRAY PULSE ARGON",
                           };

const QList<int> modesMaxPowers	{ 1, 75,
                            8, 8, 8,
                            150, 150, 5,
                            400, 400, 150, 400, 400,
                            27, 27, 27,
                            27, 27, 27,
                            150, 150, 300, 70,
                            150, 70,
                            70, 70,
                            };


SOCKET::SOCKET(SOCKET::SocType type)
{
    m_socketStatus = S_ENABLED;
    m_cutModeIndex = 0;
    m_coagModeIndex = 0;
    m_socketType = type;
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
                   int minimum,
                   QObject *parent)
{
    Q_UNUSED(parent);
    m_modeName = name;
    m_maximumPower = maximum;
    m_minimumPower = minimum;
    m_isCoag = isCoag;
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
        m_currentpower = newCurrentpower;
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
    return m_coagModeNames.at(m_cutModeIndex);
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

