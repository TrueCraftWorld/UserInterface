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
    connect(this, &ProgHandle::isRecomProgsChanged,
            this, [this] () {
        emit updateScopes(m_isRecomProgs);

    });
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

void ProgHandle::saveProg(const QString &scopeName, const QString &progName)
{
    // qDebug() << "saveProg" << scopeName << progName;
    emit signalSaveName(scopeName, progName);
}

void ProgHandle::addEmptyDefault()
{
    emit signalAddEmptyDefault(false);
}

void ProgHandle::copyCurrent()
{
    emit signalCopyCurrent();
}

void ProgHandle::permitAll()
{
    emit signalUnlockProg();
}

QStringList ProgHandle::scopeNameList() const
{
    return values(m_scopes);
    // return m_isRecomProgs ? values(m_scopes) : values(m_userScopes);
}

QStringList ProgHandle::progNameList() const
{
    return values(m_progs);
    // return m_isRecomProgs ? values(m_progs) : values(m_userProgs);
}

QList<int> ProgHandle::scopeIdList() const
{
    return keys(m_scopes);
    // return m_isRecomProgs ? keys(m_scopes) : keys(m_userProgs);
}

QList<int> ProgHandle::progIdList() const
{
    // auto& progs = m_isRecomProgs ? m_progs : m_userScopes;
    const auto& progs = m_progs;
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
    // if (m_scopeIdx == newScopeIdx)
    //     return;
    m_scopeIdx = newScopeIdx;
    auto iter = m_scopes.begin();
    for (int i = 0; i < newScopeIdx; ++i) {
        iter++;
    }
    // iter += newScopeIdx;
    emit signalScopeRequest(iter->first);
    emit scopeIdxChanged();
}


void ProgHandle::setProgList(const std::map<int, QString>& lst/*, bool isRecom*/)
{
    m_progs = lst;
    emit progNameListChanged();
}

void ProgHandle::setScopeList(const std::map<int, QString> &scopes/*, bool isRecom*/)
{
    m_scopes = scopes;
    setScopeIdx(0);
    emit scopeNameListChanged();
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
///whyyyy on earth VIDEO got in PROG loader?
///
    QDir dir(folderPath);
    if (!dir.exists()) {
        // qWarning() << "ProgHandle: Video folder does not exist:" << folderPath;
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
    
    // qDebug() << "ProgHandle: Found" << videoFiles.size() << "video files in" << folderPath;
    
    return videoFiles;
}

bool ProgHandle::isRecomProgs() const
{
    return m_isRecomProgs;
}

void ProgHandle::setIsRecomProgs(bool newIsRecomProgs)
{
    m_isRecomProgs = newIsRecomProgs;
    emit isRecomProgsChanged();
}
