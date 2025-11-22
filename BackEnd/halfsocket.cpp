#include "halfsocket.h"

#include <algorithm>
#include <utility>
#include <vector>

#include <QDebug>
#include <QVector>

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

HalfSocket::HalfSocket(bool isCoag, int state)
    : m_isCoag(isCoag),
      m_state(state)
{}

int HalfSocket::modeIndex() const
{
    return m_modeIndex;
}

int HalfSocket::modeId() const
{
    if (m_curMode.isNull())
        return 1000;
    return m_curMode->id();
}

Onyx::HS_State HalfSocket::halfSocketState() const
{
    return static_cast<Onyx::HS_State>(m_state);
}

QString HalfSocket::modeName() const
{
    return m_curMode->modeName();
}

QMap<int, SurgModePtr> HalfSocket::modes() const
{
    return m_modes;
}

QStringList HalfSocket::modeNames() const
{
    return m_modeNames;
}

bool HalfSocket::setModeIndex(int newModeIndex)
{
    if (newModeIndex < 0 || newModeIndex >= m_modeNames.size())
        return false;
    m_modeIndex = newModeIndex;
    QString tmp = m_modeNames.at(newModeIndex);
    for (const auto& item : m_modes) {
        if (tmp == item->modeName())
            m_curMode = item;
    }
    // qDebug() << "mode Change to" << m_curMode->id() << m_curMode->modeName() << Qt::endl;
    return true;
}

bool HalfSocket::setModeId(int id)
{
    return setModeIndex(getModeIndex(id));
}

void HalfSocket::setHalfSocketState(Onyx::HS_State newSocketStatus)
{
    Q_UNUSED(newSocketStatus)
}

int HalfSocket::modePower() const
{
    if (m_curMode.isNull())
        return -1;
    return m_curMode->currentPower();
}

bool HalfSocket::setModePower(int newPower)
{
    if (m_curMode.isNull() || m_curMode->id() == 1000)
        return false;
    SurgModePtr ptr = m_modes[m_curMode->id()];
    return ptr->setCurrentPower(newPower);
}

void HalfSocket::setModes(const QMap<int, SurgModePtr> &newModes, const QStringList &order)
{
    Q_UNUSED(order)
    m_modes = newModes;
    
    // Создаём вектор пар (Num, SurgModePtr) для сортировки
    std::vector<std::pair<int, SurgModePtr>> modesVector;
    for (auto it = m_modes.begin(); it != m_modes.end(); ++it) {
        modesVector.push_back(std::make_pair(it.value()->num(), it.value()));
    }
    
    // Сортируем по Num
    std::sort(modesVector.begin(), modesVector.end(), 
        [](const std::pair<int, SurgModePtr>& a, const std::pair<int, SurgModePtr>& b) {
            return a.first < b.first;
        });
    
    // Заполняем m_modeNames в отсортированном порядке
    m_modeNames.clear();
    for (const auto& pair : modesVector) {
        m_modeNames.append(pair.second->modeName());
    }
    
    setModeIndex(0);
}

CSurgModePtr HalfSocket::curMode() const
{
    return m_curMode;
}

QByteArray HalfSocket::toByteArray()
{
    return QByteArray{};
}

QStringList HalfSocket::modeNamesIds() const
{
    QStringList tmp;
    for (auto item : m_modes.keys())
        tmp.append(QString("%1").arg(item));

    return tmp;
}

bool HalfSocket::setInstrumIndex(int index)
{
    return m_modes[m_curMode->id()]->setSelectedInstrIndex(index);
}

bool HalfSocket::setInstrumId(int id)
{
    return m_modes[m_curMode->id()]->setSelectedInstrId(id);
}

CSurgModePtr HalfSocket::getMode(int index) const
{
    if (index < 0 || index >= m_modeNames.size())
        return nullptr;

    QString tmp = m_modeNames.at(index);
    for (const auto& item : m_modes) {
        if (tmp == item->modeName())
            return item;
    }
    return nullptr;
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
        int idx = m_modeNames.indexOf(item->modeName());
        return (idx);
    }
    return -1;
}

