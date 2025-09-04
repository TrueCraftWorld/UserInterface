#ifndef PROGHANDLE_H
#define PROGHANDLE_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

class ProgHandle : public QObject
{
    Q_OBJECT

public:
    explicit ProgHandle(QObject *parent = nullptr);

    Q_INVOKABLE void loadRecommendedProg(int recomProgId);
    Q_INVOKABLE void loadUserProg(int recomProgId);
    Q_INVOKABLE void changeSubProg(int subProgIndex);
    Q_INVOKABLE void loadEmptyProg();
    Q_INVOKABLE void permitAll();
    Q_INVOKABLE void saveProg(int id, const QString& name);

signals:
    void signalRecomProgChosen(int progId);
    void signalSubProgChosen(int progId);
    //может быть избыточно и проги сможем просто по id разделять
    void signalUserProgChosen(int progId);

    void signalLoadEmpty();
    void signalSave(int id, const QString& name);
    void signalUnlockProg();
    void currentModeIndexChanged();
};


#endif // PROGHANDLE_H
