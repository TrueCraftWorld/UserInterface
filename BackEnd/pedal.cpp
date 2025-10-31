#include "pedal.h"

Pedal::Pedal(Pedal::PedalType pedId)
    : m_pedType(pedId)
{}

int Pedal::pedalType() const
{
    return static_cast<int>(m_pedType);
}

bool Pedal::setPedType(int newPedId)
{
    if (newPedId < Pedal::NO_PED || newPedId > Pedal::INSTR_BUTTON_MONO)
        return false;
    m_pedType = static_cast<PedalType>(newPedId);
    return true;
}
