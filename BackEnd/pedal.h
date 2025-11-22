#ifndef PEDAL_H
#define PEDAL_H
#include <QString>
#include "Structures.h"

class Pedal
{
public:
    Pedal(Onyx::PedalType pedType = Onyx::NO_PED);

    int pedalType() const;
    bool setPedType(int newPedType);

private:
    Onyx::PedalType m_pedType;
    //может быть будем использовать сишные конструкции для image провайдера
    QString m_name;

};

#endif // PEDAL_H
