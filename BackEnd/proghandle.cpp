#include "proghandle.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>
#include <QStringList>


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
