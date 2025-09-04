#include "proghandle.h"


ProgHandle::ProgHandle(QObject *parent)
    : QObject{parent}
{

}

void ProgHandle::loadRecommendedProg(int recomProgId)
{
    emit signalRecomProgChosen(recomProgId);
}

void ProgHandle::loadUserProg(int recomProgId)
{
    emit signalUserProgChosen(recomProgId);
}

void ProgHandle::changeSubProg(int subProgIndex)
{
    emit signalSubProgChosen(subProgIndex);
}

void ProgHandle::loadEmptyProg()
{
    emit signalLoadEmpty();
}

void ProgHandle::saveProg(int id, const QString &name)
{
    emit signalSave(id, name);
}

void ProgHandle::permitAll()
{
    emit signalUnlockProg();
}

