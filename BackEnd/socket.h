#ifndef SOCKET_H
#define SOCKET_H

#include <QObject>
#include <QString>
#include <QList>
#include <QStringList>
#include <QSharedPointer>

#include "surgicalmode.h"

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
    enum ModeType { NONE = 0,
                    CUT,
                    COAG
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

    int checkMode(const QString& modeName) const;

    bool setCoagModeIndex(const QString & coagModeName);
    bool setCutModeIndex(const QString & cutModeName);

    void setSocketType(SOCKET::SocType newSocketType);
    void setSocketStatus(SocStatus newSocketStatus);
    void setSocketName(const QString &newSocketName);

    QSharedPointer<const SurgicalMode> getMode(const QString& name) const;

    int coagModePower() const;
    bool setCoagModePower(int newCoagModePower);

    int cutModePower() const;
    bool setCutModePower(int newCutModePower);

    void setCutModes(const QHash<QString, QSharedPointer<SurgicalMode> > &newCutModes,
                     const QStringList& order = {""});

    void setCoagModes(const QHash<QString, QSharedPointer<SurgicalMode> > &newCoagModes,
                      const QStringList& order = {""});

    QStringList coagModeNames() const;

    QStringList cutModeNames() const;

    QSharedPointer<const SurgicalMode> curCoagMode() const;

    QSharedPointer<const SurgicalMode> curCutMode() const;

    /**
     * @brief формарование байт-массива текущих настроек сокета
     * @return
     */
    QByteArray toByteArray();

private:

    QSharedPointer<const SurgicalMode> getMode(const QString& name, ModeType type) const;
    QSharedPointer<const SurgicalMode> m_curCoagMode;
    QSharedPointer<const SurgicalMode> m_curCutMode;
    bool setModePower(int newPower, bool isCoag);
    bool setModeIndex(int index, bool isCoag);

    int m_coagModeIndex;
    int m_cutModeIndex;

    // int m_coagModePower;
    // int m_cutModePower;

    SocType m_socketType;
    SocStatus m_socketStatus;

    QString m_socketName;

    QStringList m_coagModeNames;
    QStringList m_cutModeNames;

    QHash<QString, QSharedPointer<SurgicalMode>> m_cutModes;
    QHash<QString, QSharedPointer<SurgicalMode>> m_coagModes;

    // QByteArray outputInfo(SOCKET *changedSocket, bool isCoag);
};

#endif // SOCKET_H
