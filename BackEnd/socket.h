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
    /*! Перечисление возможных типов сокета */
    enum SocType {  EMPTY, /*!<  Пустой сокет - заглушка на случай ошибок*/
                    BIPOLAR_1, /*!< Биполяр 1 */
                    BIPOLAR_2, /*!< Биполяр 2 */
                    MONOPOLAR_1, /*!< Монополяр 1 */
                    MONOPOLAR_2 /*!< Монополяр 2 */
                        };

    /*! Перечисление возможных состояний сокета */
    enum SocStatus {S_OFF, /*!< Выключен, активация запрещена */
                    S_ENABLED, /*!< Включен, активация разрешена */
                    S_ACTIVE_COAG, /*!< Активирован, коагуляция */
                    S_ACTIVE_CUT, /*!< Активирован, резание */
                    S_ERROR /*!< Ошибка, активация запрещена */
                        };

    /*! Перечисление возможных типоа режима */
    enum ModeType { NONE = 0, /*!< Никакой - для режима-заглушки,  */
                    CUT, /*!< Режущий */
                    COAG /*!< Коагулирующий */
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

    /**
     * @brief устанавливает новый относительный индекс режима коагуляции
     * @param newCoagModeIndex - устанавливаемый относительный индекс
     * @return true - индекс установлен
     * @return false - индекс не установлен
     */
    bool setCoagModeIndex(int newCoagModeIndex);

    /**
     * @brief устанавливает новый относительный индекс режима резания
     * @param newCutModeIndex - устанавливаемый относительный индекс
     * @return true - индекс установлен
     * @return false - индекс не установлен
     */
    bool setCutModeIndex(int newCutModeIndex);

    bool setModeId(int id, bool isCoag);

    /**
     * @brief Проверка типа режима по его названию
     * @param modeName - текущее локализованное название режима
     * @return ModeType заданного режима
     */
    int checkMode(const QString& modeName) const;

    /**
     * @brief установка типа сокеты
     * @param newSocketType
     */
    void setSocketType(SOCKET::SocType newSocketType);

    /**
     * @brief смена текущего состояния сокета
     * @param newSocketStatus
     */
    void setSocketStatus(SocStatus newSocketStatus);

    /**
     * @brief Установка локализированного имени сокета
     * @param newSocketName
     */
    void setSocketName(const QString &newSocketName);

    /**
     * @brief Геттер режима
     * @param modeIndex относительный индекс режима в этом сокете
     * @param isCoag выбор между режимами резания и коагуляции
     * @return Указатель на КОНСТАНТНЫЙ режим
     */
    CSurgModePtr getMode(int modeIndex, bool isCoag) const;

    /**
     * @brief Возращает текущую мощность текущего режима коагуляции
     * @return
     */
    int coagModePower() const;

    /**
     * @brief Устанавливает текущую мощность текущего режима коагуляции
     * @param newCoagModePower - задаваемая мощность
     * @return true - смена мощности режима выполнена успешно
     * @return false - изменение мощности не прошло
     */
    bool setCoagModePower(int newCoagModePower);

    /**
     * @brief Возращает текущую мощность текущего режима резания
     * @return
     */
    int cutModePower() const;

    /**
     * @brief Устанавливает текущую мощность текущего режима резания
     * @param newCutModePower - задаваемая мощность
     * @return true - смена мощности режима выполнена успешно
     * @return false - изменение мощности не прошло
     */
    bool setCutModePower(int newCutModePower);

    /**
     * @brief Задаеёт перечень достпных режимов резания и порядок их отображения
     * @param newCutModes - хэш новых режимов по их имени
     * @param order - порядок в котором список имён режимов будет выводиться пользователю
     * @todo Возможно, с учётом локализаций, необходимо использовать индекс из БД как ключ
     */
    void setCutModes(const QHash<QString, SurgModePtr > &newCutModes,
                     const QStringList& order = {""});

    /**
     * @brief Задаеёт перечень достпных режимов коагуляции и порядок их отображения
     * @param newCoagModes - хэш новых режимов по их имени
     * @param order - порядок в котором список имён режимов будет выводиться пользователю
     * @todo Возможно, с учётом локализаций, необходимо использовать индекс из БД как ключ
     */
    void setCoagModes(const QHash<QString, SurgModePtr > &newCoagModes,
                      const QStringList& order = {""});

    /**
     * @brief имена доступных режимов коагуляции
     * @return
     */
    QStringList coagModeNames() const;

    /**
     * @brief имена доступных режимов резания
     * @return
     */
    QStringList cutModeNames() const;

    /**
     * @brief возвращает указатель на КОНСТАНТНЫЙ текущий режим коагуляции
     * @return
     */
    CSurgModePtr curCoagMode() const;

    /**
     * @brief возвращает указатель на КОНСТАНТНЫЙ текущий режим резания
     * @return
     */
    CSurgModePtr curCutMode() const;

    /**
     * @brief формарование байт-массива текущих настроек сокета
     * @return
     */
    QByteArray toByteArray();

    bool setInstrumIndex(int index, bool isCoag);
    bool setInstrumId(int id, bool isCoag);


private:

    CSurgModePtr getMode(const QString& name, ModeType type) const;
    CSurgModePtr m_curCoagMode;
    CSurgModePtr m_curCutMode;

    bool setModePower(int newPower, bool isCoag);
    bool setModeIndex(int index, bool isCoag);

    int m_coagModeIndex = 0;
    int m_cutModeIndex = 0;

    SocType m_socketType;
    SocStatus m_socketStatus;

    QString m_socketName;

    QStringList m_coagModeNames;
    QStringList m_cutModeNames;

    QHash<QString, SurgModePtr> m_cutModes;
    QHash<QString, SurgModePtr> m_coagModes;
};

using SockPtr=QSharedPointer<SOCKET>;

#endif // SOCKET_H
