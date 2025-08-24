#include "instrument.h"


Instrument::Instrument(int id, int legacyNumber, const QString &name, bool mono)
    : m_Id(id),
      m_legacyNumber(legacyNumber),
      m_name(name),
      m_isMono(mono)
{

}

void Instrument::setDescription(const QString &newDescription)
{
    m_description = newDescription;
}

QString Instrument::name() const
{
    return m_name;
}

int Instrument::Id() const
{
    return m_Id;
}
