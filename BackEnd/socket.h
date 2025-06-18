#ifndef SOCKETCONSTANTS_H
#define SOCKETCONSTANTS_H

#include <QObject>
#include <QString>
#include <QList>
#include <QStringList>
#include <QSharedPointer>


class EshfMode {
public:

    EshfMode(QString name,
             bool isCoag,
             int maximum = 400,
             int minimum = 1,
             QObject *parent = nullptr);

    explicit EshfMode(QObject *parent = nullptr)  :
        EshfMode("NoMode", false, 1, 1, parent) {};

    int maximumPower() const;
    int currentPower() const;
    const QString &modeName() const;

    int minimumPower() const;

    bool setCurrentpower(int newCurrentpower);

private:
    void setModeName(const QString &newModeName);
    void setMaximumPower(int newMaximumPower);
    void setMinimumPower(int newMaximumPower);

    int m_maximumPower;
    int m_minimumPower;
    int m_currentpower;
    QString m_modeName;
    bool m_isCoag;
};

/**
 * @brief Класс описывающий один электрический сокет.
 * @details Содержит полный список присущих этому сокеты режимов,
 * поддерживает смену режима, настройку можности, выключение выключение режима
 * Предполагается взаимодействие с объектами типа SOCKET через модель
 */
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

    /**
     * @brief Возвращает внутренний индекс текущего коаг режима
     * @return индекс
     */
    int coagModeIndex() const;

    /**
     * @brief Возвращает внутренний индекс текущего рез режима
     * @return индекс
     */
    int cutModeIndex() const;

    /**
     * @brief Возвращает тип сокета - МОНО1\2 Би1\2
     * @return тип
     */
    SocType socketType() const;

    /**
     * @brief Возвращает статус сокета
     * @return тип
     */
    SocStatus socketStatus() const;

    /**
     * @brief возвращает назание сокета
     * @return
     */
    const QString &socketName() const;

    /**
     * @brief возвращает название текущего режима коаг
     * @return
     */
    const QString &coagModeName() const;

    /**
     * @brief возвращает название текущего режима рез
     * @return
     */
    const QString &cutModeName() const;

    /**
     * @brief Возвращает список доступных режимов реза
     * @return
     */
    const QStringList& cutModes() const;

    /**
     * @brief Возвращает список доступных режимов коаг
     * @return
     */
    const QStringList& coagModes() const;

    bool setCoagModeIndex(int newCoagModeIndex);
    bool setCutModeIndex(int newCutModeIndex);

    void setCoagModeIndex(const QString & coagModeName);
    void setCutModeIndex(const QString & cutModeName);

    void setSocketType(SOCKET::SocType newSocketType);
    void setSocketStatus(SocStatus newSocketStatus);
    void setSocketName(const QString &newSocketName);

    QSharedPointer<const EshfMode> getCutMode(const QString& name) const;
    QSharedPointer<const EshfMode> getCoagMode(const QString& name) const;

    int coagModePower() const;
    bool setCoagModePower(int newCoagModePower);

    int cutModePower() const;
    bool setCutModePower(int newCutModePower);

private:

    QSharedPointer<const EshfMode> getMode(const QString& name, bool isCoag) const;
    bool setModePower(int newPower, bool isCoag);
    bool setModeIndex(int index, bool isCoag);

    int m_coagModeIndex;
    int m_cutModeIndex;

    int m_coagModePower;
    int m_cutModePower;

    SocType m_socketType;
    SocStatus m_socketStatus;

    QString m_socketName;

    QStringList m_coagModeNames;
    QStringList m_cutModeNames;

    QHash<QString, QSharedPointer<EshfMode>> m_cutModes;
    QHash<QString, QSharedPointer<EshfMode>> m_coagModes;

    // QByteArray outputInfo(SOCKET *changedSocket, bool isCoag);
};

#endif // SOCKETCONSTANTS_H
