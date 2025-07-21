#include "surgicalmode.h"


SurgicalMode::SurgicalMode(QString name,
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

int SurgicalMode::maximumPower() const
{
    return m_maximumPower;
}

int SurgicalMode::currentPower() const
{
    return m_currentPower;
}

void SurgicalMode::setMaximumPower(int newMaximumPower)
{
    if (m_maximumPower == newMaximumPower)
        return;
    m_maximumPower = newMaximumPower;
}

bool SurgicalMode::isCoag() const
{
    return m_isCoag;
}

bool SurgicalMode::setCurrentPower(int newCurrentpower)
{
    if (newCurrentpower <= m_maximumPower
        && newCurrentpower >= m_minimumPower) {
        m_currentPower = newCurrentpower;
        return true;
    } else {
        return false;
    }
}

bool SurgicalMode::setParams(const QVariantMap &params)
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

QVariantMap SurgicalMode::params() const
{
    QVariantMap res;
    res["name"] = m_modeName;
    res["currentpower"] = m_currentPower;
    res["minpower"] = m_minimumPower;
    res["maxpower"] = m_maximumPower;
    res["iscoag"] = m_isCoag;
    return res;
}

int SurgicalMode::minimumPower() const
{
    return m_minimumPower;
}

const QString &SurgicalMode::modeName() const
{
    return m_modeName;
}

void SurgicalMode::setModeName(const QString &newModeName)
{
    if (m_modeName == newModeName)
        return;
    m_modeName = newModeName;
}

