#include "halfsocket.h"

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

HalfSocket::HalfSocket(bool isCoag, int state)
    : m_isCoag(isCoag),
      m_state(state)
{

}

int HalfSocket::modeIndex() const
{
    return m_modeIndex;
}

HalfSocket::HS_State HalfSocket::halfSocketState() const
{
    return static_cast<HS_State>(m_state);
}

const QString &HalfSocket::modeName() const
{
    return m_curMode->modeName();
}

QHash<QString, CSurgModePtr> &HalfSocket::modes() const
{
    return m_modes;
}

const QStringList &HalfSocket::modeNames() const
{
    return m_modeNames;
}

bool HalfSocket::setModeIndex(int newModeIndex)
{
    if (newModeIndex < 0 || newModeIndex >= m_modeNames.size())
        return false;
    m_modeIndex = newModeIndex;
    m_curMode = m_modes.value(m_modeNames.at(newModeIndex));
    return true;
}

bool HalfSocket::setModeId(int id)
{
    return setModeIndex(getModeIndex(id));
}

int HalfSocket::checkMode(const QString &modeName) const
{
//bad idea
    return -1;
}

void HalfSocket::setHalfSocketState(HS_State newSocketStatus)
{

}

int HalfSocket::modePower() const
{
    return m_curMode->currentPower();
}

bool HalfSocket::setModePower(int newPower)
{
    SurgModePtr ptr = m_modes[m_curMode->modeName()];
    return ptr->setCurrentPower(newPower);
}

void HalfSocket::setModes(const QHash<QString, SurgModePtr> &newModes, const QStringList &order)
{
    m_modeNames = sortByExample(newModes.keys(), order);
    m_modes = newModes;
    setModeIndex(0);
}

QStringList HalfSocket::modeNames() const
{
    return m_modeNames;
}

CSurgModePtr HalfSocket::curMode() const
{
    return m_curMode;
}

QByteArray HalfSocket::toByteArray()
{

}

bool HalfSocket::setInstrumIndex(int index)
{
    return m_modes[m_modeNames.at(m_modeIndex)]->setSelectedInstrIndex(index);
}

bool HalfSocket::setInstrumId(int id)
{
    return m_modes[m_modeNames.at(m_modeIndex)]->setSelectedInstrId(index);
}

CSurgModePtr HalfSocket::getMode(int index) const
{
    if (index < 0 || index >= m_modeNames.size())
        return nullptr;
    return m_modes.value(m_modeNames.at(index));
}

int HalfSocket::getModeIndex(const QString &name) const
{
    return m_modeNames.indexOf(name);
}

int HalfSocket::getModeIndex(int id) const
{
    for (const auto& item : m_modes) {
        if (item->id() != id)
            continue;
        return (m_modeNames.indexOf(item->modeName()));
    }
    return -1;
}

