#ifndef SOCKETCONSTANTS_H
#define SOCKETCONSTANTS_H

#include <QObject>
#include <QString>
#include <QList>
#include <QStringList>
#include <QSharedPointer>


class EshfMode {
public:

    explicit EshfMode(QObject *parent = nullptr);
    EshfMode(QString, int, bool, QObject *parent = nullptr);
    int maximumPower() const;
    int currentPower() const;
    const QString &modeName() const;

private:
    void setModeName(const QString &newModeName);
    void setMaximumPower(int newMaximumPower);
    void setMinimumPower(int newMaximumPower);

    int m_maximumPower;
    int m_minimumPower;
    QString m_modeName;
    bool m_isCoag;
};


class SOCKET
{

public:
    enum SocType {  EMPTY,
                    BIPOLAR_1,
                    BIPOLAR_2,
                    MONOPOLAR_1,
                    MONOPOLAR_2
                        };
    enum SocStatus {S_OFF,
                    S_ENABLED,
                    S_ACTIVE_COAG,
                    S_ACTIVE_CUT
                        };

    SOCKET(SOCKET::SocType = MONOPOLAR_1);

    int coagModeIndex() const;
    int cutModeIndex() const;
    SocType socketType() const;
    SocStatus socketStatus() const;
    const QString &socketName() const;

    void setCoagModeIndex(int newCoagModeIndex);    
    void setcutModeIndex(int newCutModeIndex);    
    void setSocketType(SOCKET::SocType newSocketType);
    void setSocketStatus(SocStatus newSocketStatus);
    void setSocketName(const QString &newSocketName);

    QSharedPointer<EshfMode> getCutMode(int id);
    QSharedPointer<EshfMode> getCoagMode(int id);

    int coagModePower() const;
    void setCoagModePower(int newCoagModePower);

    int cutModePower() const;
    void setCutModePower(int newCutModePower);

private:

    int m_coagModeIndex;
    int m_cutModeIndex;

    int m_coagModePower;
    int m_cutModePower;

    SocType m_socketType;
    SocStatus m_socketStatus;

    QString m_socketName;

    QList<QSharedPointer<EshfMode>> cutModes;
    QList<QSharedPointer<EshfMode>> coagModes;

    QByteArray outputInfo(SOCKET *changedSocket, bool isCoag);
};

#endif // SOCKETCONSTANTS_H
