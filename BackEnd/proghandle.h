#ifndef PROGHANDLE_H
#define PROGHANDLE_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

// #include "userprogsloadmodel.h"

class ProgHandle : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QStringList scopeNameList READ scopeNameList NOTIFY scopeNameListChanged FINAL)
    Q_PROPERTY(QList<int> scopeIdList READ scopeIdList NOTIFY scopeNameListChanged FINAL)
    Q_PROPERTY(QStringList progNameList READ progNameList NOTIFY progNameListChanged FINAL)
    Q_PROPERTY(QList<int> progIdList READ progIdList NOTIFY progNameListChanged FINAL)
    // Q_PROPERTY(QStringList userProgList READ userProgList NOTIFY userProgListChanged FINAL)
    Q_PROPERTY(int scopeIdx READ scopeIdx WRITE setScopeIdx NOTIFY scopeIdxChanged FINAL)
    Q_PROPERTY(bool isRecomProgs READ isRecomProgs WRITE setIsRecomProgs NOTIFY isRecomProgsChanged FINAL)

    explicit ProgHandle(QObject *parent = nullptr);

    // Q_INVOKABLE void loadSelected();
    Q_INVOKABLE void loadRecommendedProg(int recomProgId, bool clear = true);
    Q_INVOKABLE void loadFreeSettings();
    Q_INVOKABLE void removeSubProg();
    // Q_INVOKABLE void loadUserProg(int recomProgId);
    Q_INVOKABLE void permitAll();
    // Q_INVOKABLE void saveProg(int id, const QString& name);
    // Q_INVOKABLE void saveProg(const QString& name);
    Q_INVOKABLE void saveProg(const QString& scopeName,
                                const QString& progName);
    Q_INVOKABLE void addEmptyDefault();
    Q_INVOKABLE void copyCurrent();
    Q_INVOKABLE void deleteAllUserProgs();
    // Q_INVOKABLE void userProgs();
    Q_INVOKABLE QString readTextFile(const QString& filePath);
    Q_INVOKABLE QStringList scanVideoFiles(const QString& folderPath);

    QStringList scopeNameList() const;
    QStringList progNameList() const;
    QList<int> scopeIdList() const;
    QList<int> progIdList() const;

    int scopeIdx() const;
    void setScopeIdx(int newScopeIdx);

    void setProgList(const std::map<int, QString>& lst/*, bool isRecom = true*/);

    void setScopeList(const std::map<int, QString>& scopes/*, bool isRecom = true*/);

    // QStringList userProgList() const;
    // void setUserProgList(const std::map<int, QString>& progs);

    bool isRecomProgs() const;
    void setIsRecomProgs(bool newIsRecomProgs);

signals:
    //все этим методы и сигналы нужны т.к. возможно хочется сделать модель ридонли внутри qml
    // а редачить только через хендлеры для разграничения доступа

    void signalCopyCurrent();

    void signalAddEmptyDefault(bool clearLoad = true);

    void signalLoadRecommend(int scopeIdx, int progIdx, int subProgIdx);

    void signalRecomProgChosen(int progId, bool clear);
    void signalFreeSettingsRequested();
    void signalDeleteAllUserProgs();

    void signalRemoveSub();
    //может быть избыточно и проги сможем просто по id разделять
    void signalUserProgChosen(int progId);

    void signalLoadEmpty();
    void signalSave(int id, const QString& name);
    void signalSaveName(const QString& scopeName,
                        const QString& progName);
    void signalUnlockProg();

    void signalScopeRequest(int scopeId);

    void updateScopes(bool isRecom);

    void currentModeIndexChanged();
    void scopeNameListChanged();
    void progNameListChanged();

    void scopeIdxChanged();

    void isRecomProgsChanged();

private:
    int m_scopeIdx = 0;
    std::map<int, QString> m_scopes;
    std::map<int, QString> m_progs;
    // QStringList m_userProgList;
    // std::map<int, QString> m_userProgs;
    // std::map<int, QString> m_userScopes;
    bool m_isRecomProgs;
};


#endif // PROGHANDLE_H
