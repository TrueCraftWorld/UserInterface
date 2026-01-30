#include <QDebug>

#include "proghandle.h"

ProgHandle::ProgHandle(QObject *parent)
    : QObject{parent}
{

}

void ProgHandle::loadSelected()
{

}

void ProgHandle::loadRecommendedProg(int recomProgIdx, bool clear)
{
    if (recomProgIdx >= m_progs.size())
        return;
    auto iter = m_progs.begin();
    iter += recomProgIdx;
    emit signalRecomProgChosen(iter.key(), clear);
}

void ProgHandle::removeSubProg()
{
    emit signalRemoveSub();
}

void ProgHandle::loadUserProg(int recomProgId)
{
    emit signalUserProgChosen(recomProgId);
}

void ProgHandle::saveProg(int id, const QString &name)
{
    emit signalSave(id, name);
}

void ProgHandle::saveProg(const QString &name)
{
    emit signalSaveName(name);
    qDebug() << "saving" << name;
}

void ProgHandle::addEmptyDefault()
{
    emit signalAddEmptyDefault(false);
}

void ProgHandle::copyCurrent()
{
    emit signalCopyCurrent();
}

void ProgHandle::userProgs()
{
    qDebug() << "call userProgs";
    emit signalUserProgsRequest();
}

void ProgHandle::permitAll()
{
    emit signalUnlockProg();
}

QStringList ProgHandle::scopeNameList() const
{
    return m_scopes.values();
}

QStringList ProgHandle::progNameList() const
{
    return m_progs.values();
}

QList<int> ProgHandle::scopeIdList() const
{
    return m_scopes.keys();
}

QList<int> ProgHandle::progIdList() const
{
    return m_progs.keys();
}

int ProgHandle::scopeIdx() const
{
    return m_scopeIdx;
}

void ProgHandle::setScopeIdx(int newScopeIdx)
{
    if (m_scopes.size() <= newScopeIdx)
        return;
    if (m_scopeIdx == newScopeIdx)
        return;
    m_scopeIdx = newScopeIdx;
    auto iter = m_scopes.begin();
    iter += newScopeIdx;
    emit signalScopeRequest(iter.key());
    emit scopeIdxChanged();
}


void ProgHandle::setProgList(QMap<int, QString> lst)
{
    m_progs = lst;
    emit progNameListChanged();
}

void ProgHandle::setScopeNameList(QMap<int, QString> scopes)
{
    m_scopes = scopes;

    // m_scopeNameList = m_scopes.values();
    setScopeIdx(0);
    emit scopeNameList();
}

QStringList ProgHandle::userProgList() const
{
    QStringList res;
    for (const auto& item : m_userProgs) {
        res.push_back(item.second);
    }
    return res;
}

void ProgHandle::setUserProgList(const std::map<int, QString> &progs)
{
    qDebug() << "setUserProgList";

    m_userProgs = (progs);
    emit userProgListChanged();
}
