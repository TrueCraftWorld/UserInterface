#include "pedal.h"

Pedal::Pedal(Onyx::PedalType pedId)
    : m_pedType(pedId)
{}

int Pedal::pedalType() const
{
    return static_cast<int>(m_pedType);
}

bool Pedal::setPedType(int newPedId)
{
    if (newPedId < Onyx::NO_PED || newPedId > Onyx::INSTR_BUTTON_MONO)
        return false;
    m_pedType = static_cast<Onyx::PedalType>(newPedId);
    return true;
}
