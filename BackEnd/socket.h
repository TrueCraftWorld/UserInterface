#ifndef SOCKET_H
#define SOCKET_H

#include <QObject>
#include <QString>
#include <QList>
#include <QStringList>
#include <QSharedPointer>

namespace ESHF {
enum eshfModes	{ NO_MODE = 0, BI_BLEND=1,
                 BI_TUR=2, BI_ARTRO=3, BI_GISTERO=4,
                 BI_COAG=5, BI_COAG_DISS=6, TERMOSHOV=7,
                 CUT=8, BLEND=9, BLEND1=10, TUR=11, VAP=12,
                 E_KNIFE1=13, E_KNIFE2=14, E_KNIFE3=15,
                 E_LOOP1=16, E_LOOP2=17, E_LOOP3=18,
                 FORCE=19, FULGUR=20, SOFT=21, SPRAY=22,
                 FULGUR_A=23, SPRAY_A=24,
                 FULGUR_P=25, SPRAY_P=26,
                 };
const QStringList modesNames = { "NO MODE", "BI BLEND",
                                "BI TUR", "BI ARTRO", "BI GISTERO",
                                "BI COAG", "BI COAG DISSECT", "TERMOSHOV",
                                "CUT", "BLEND", "BLEND1", "TUR", "VAP",
                                "ENDO KNIFE1", "ENDO KNIFE2", "ENDO KNIFE3",
                                "ENDO LOOP1", "ENDO LOOP2", "ENDO LOOP3",
                                "FORCE", "FULGUR", "SOFT", "SPRAY",
                                "FULGUR ARGON", "SPRAY ARGON",
                                "FULGUR PULSE ARGON", "SPRAY PULSE ARGON",
                                };

const QList<int> modesMaxPowers	{ 1, 75,
                                8, 8, 8,
                                150, 150, 5,
                                400, 400, 150, 400, 400,
                                27, 27, 27,
                                27, 27, 27,
                                150, 150, 300, 70,
                                150, 70,
                                70, 70,
                                };
};

class EshfMode {
public:

    EshfMode(QString name,
             bool isCoag,
             int maximum = 400,
             int minimum = 1);

    explicit EshfMode()  :
        EshfMode("NoMode", false, 1, 1) {};

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
    int m_currentPower;
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

    void setCutModes(const QHash<QString, QSharedPointer<EshfMode> > &newCutModes);

    void setCoagModes(const QHash<QString, QSharedPointer<EshfMode> > &newCoagModes);

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

#endif // SOCKET_H
