#include <QDebug>
#include "proghandle.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>
#include <QStringList>

#include "proghandle.h"

namespace {
template <typename T, typename P>
QList<T> keys(const std::map<T, P>& map) {
    QList<T> res;
    res.reserve(map.size());
    for (const auto&  item: map) {
        res.push_back(item.first);
    }
    return res;
}
template <typename T, typename P>
QList<P> values(const std::map<T, P>& map) {
    QList<P> res;
    res.reserve(map.size());
    for (const auto&  item: map) {
        res.push_back(item.second);
    }
    return res;
}
}

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
    for (int a = 0; a < recomProgIdx; a++) {
        iter++;
    }
    emit signalRecomProgChosen(iter->first, clear);
}

void ProgHandle::removeSubProg()
{
    emit signalRemoveSub();
}

void ProgHandle::loadUserProg(int progIndex)
{
    if (m_userProgs.size() <= static_cast<size_t>(progIndex))
        return;

    auto iter = m_userProgs.cbegin();
    for (int i = 0; i < progIndex; ++i) {
        iter++;
    }

    emit signalUserProgChosen(iter->first);
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
    setIsRecomProgs(false);
    emit signalUserProgsRequest();
}

void ProgHandle::permitAll()
{
    emit signalUnlockProg();
}

QStringList ProgHandle::scopeNameList() const
{
    return m_isRecomProgs ? values(m_scopes) : values(m_userScopes);
}

QStringList ProgHandle::progNameList() const
{
    return m_isRecomProgs ? values(m_progs) : values(m_userProgs);
}

QList<int> ProgHandle::scopeIdList() const
{
    return m_isRecomProgs ? keys(m_scopes) : keys(m_userProgs);
}

QList<int> ProgHandle::progIdList() const
{
    auto& progs = m_isRecomProgs ? m_progs : m_userScopes;
    QList<int> res;
    res.reserve(progs.size());
    for (const auto& item : progs) {
        res.append(item.first);
    }
    return res;
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
    for (int i = 0; i < newScopeIdx; ++i) {
        iter++;
    }
    // iter += newScopeIdx;
    emit signalScopeRequest(iter->first);
    emit scopeIdxChanged();
}


void ProgHandle::setProgList(const std::map<int, QString>& lst, bool isRecom)
{
    (isRecom ? m_progs : m_userProgs) = lst;
    emit progNameListChanged();
}

void ProgHandle::setScopeNameList(const std::map<int, QString> &scopes, bool isRecom)
{
    (isRecom ? m_scopes : m_userScopes) = scopes;

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

QString ProgHandle::readTextFile(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "ProgHandle: Cannot open file:" << filePath;
        return QString();
    }
    
    QTextStream in(&file);
    QString content = in.readAll();
    file.close();
    
    return content;
}

QStringList ProgHandle::scanVideoFiles(const QString& folderPath)
{
    QDir dir(folderPath);
    if (!dir.exists()) {
        qWarning() << "ProgHandle: Video folder does not exist:" << folderPath;
        return QStringList();
    }
    
    // Поддерживаемые форматы видео
    QStringList filters;
    filters << "*.mp4" << "*.MP4"
            << "*.avi" << "*.AVI"
            << "*.mkv" << "*.MKV"
            << "*.mov" << "*.MOV"
            << "*.wmv" << "*.WMV"
            << "*.flv" << "*.FLV"
            << "*.webm" << "*.WEBM"
            << "*.m4v" << "*.M4V"
            << "*.mpeg" << "*.MPEG"
            << "*.mpg" << "*.MPG";
    
    dir.setNameFilters(filters);
    dir.setFilter(QDir::Files | QDir::Readable);
    dir.setSorting(QDir::Name);
    
    QStringList videoFiles = dir.entryList();
    
    qDebug() << "ProgHandle: Found" << videoFiles.size() << "video files in" << folderPath;
    
    return videoFiles;
}

bool ProgHandle::isRecomProgs() const
{
    return m_isRecomProgs;
}

void ProgHandle::setIsRecomProgs(bool newIsRecomProgs)
{
    if (m_isRecomProgs == newIsRecomProgs)
        return;
    m_isRecomProgs = newIsRecomProgs;
    emit isRecomProgsChanged();
}
