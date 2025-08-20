#ifndef HALFSOCKET_H
#define HALFSOCKET_H

#include <QString>
#include <QStringList>
#include <QSharedPointer>

#include "surgicalmode.h"

class HalfSocket
{
public:
    HalfSocket(bool isCoag, int state = 1);

public:
    /*! Перечисление возможных состояний сокета */
    enum HS_State {HS_DISABLED, /*!< Выключен, активация запрещена */
                    HS_ENABLED, /*!< Включен, активация разрешена */
                        };

    /**
     * @brief Возвращает внутренний индекс текущего коаг режима
     * @return индекс
     */
    int modeIndex() const;

    /**
     * @brief Возвращает статус сокета
     * @return тип
     */
    HS_State halfSocketState() const;

    /**
     * @brief возвращает название текущего режима коаг
     * @return
     */
    const QString &modeName() const;

    /**
     * @brief Возвращает список доступных режимов реза
     * @return
     */
    QHash<QString, CSurgModePtr> &modes() const;

    // /**
    //  * @brief Возвращает список доступных режимов коаг
    //  * @return
    //  */
    // const QStringList& modeNames() const;

    /**
     * @brief устанавливает новый относительный индекс режима коагуляции
     * @param newCoagModeIndex - устанавливаемый относительный индекс
     * @return true - индекс установлен
     * @return false - индекс не установлен
     */
    bool setModeIndex(int newModeIndex);


    bool setModeId(int id);

    /**
     * @brief Проверка типа режима по его названию
     * @param modeName - текущее локализованное название режима
     * @return ModeType заданного режима
     */
    int checkMode(const QString& modeName) const;

    /**
     * @brief смена текущего состояния сокета
     * @param newSocketStatus
     */
    void setHalfSocketState(HS_State newSocketStatus);

    /**
     * @brief Геттер режима
     * @param modeIndex относительный индекс режима в этом сокете
     * @param isCoag выбор между режимами резания и коагуляции
     * @return Указатель на КОНСТАНТНЫЙ режим
     */
    CSurgModePtr getMode(int modeIndex) const;

    /**
     * @brief Возращает текущую мощность текущего режима коагуляции
     * @return
     */
    int modePower() const;

    /**
     * @brief Устанавливает текущую мощность текущего режима коагуляции
     * @param newCoagModePower - задаваемая мощность
     * @return true - смена мощности режима выполнена успешно
     * @return false - изменение мощности не прошло
     */
    bool setModePower(int newModePower);

    /**
     * @brief Задаеёт перечень достпных режимов резания и порядок их отображения
     * @param newCutModes - хэш новых режимов по их имени
     * @param order - порядок в котором список имён режимов будет выводиться пользователю
     * @todo Возможно, с учётом локализаций, необходимо использовать индекс из БД как ключ
     */
    void setModes(const QHash<QString, SurgModePtr > &newModes,
                     const QStringList& order = {""});

    /**
     * @brief имена доступных режимов коагуляции
     * @return
     */
    QStringList modeNames() const;

    /**
     * @brief возвращает указатель на КОНСТАНТНЫЙ текущий режим коагуляции
     * @return
     */
    CSurgModePtr curMode() const;

    /**
     * @brief формарование байт-массива текущих настроек сокета
     * @return
     */
    QByteArray toByteArray();

    bool setInstrumIndex(int index);
    bool setInstrumId(int id);

private:

    // CSurgModePtr getMode(const int index) const;
    int getModeIndex(const QString& name) const;
    int getModeIndex(int id) const;
    CSurgModePtr m_curMode;

    // bool setModePower(int newPower);
    // bool setModeIndex(int index);
    // bool setModeId(int id);

    int m_modeIndex = 0;

    QStringList m_modeNames;

    QHash<QString, SurgModePtr> m_modes;
    int m_state;
    bool m_isCoag;
};

using CHalfSockPtr = QSharedPointer<const HalfSocket>;
using HalfSockPtr = QSharedPointer<HalfSocket>;

#endif // HALFSOCKET_H
