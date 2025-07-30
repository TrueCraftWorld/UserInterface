#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>
#include <map>

#include "BackEnd/socketmodeeditor.h"
#include "socketmodel.h"
#include "databasereader.h"
#include "instrument.h"
#include "surgicalmode.h"


/**
 * @brief Управляющий класс бэкэнда, осуществляющий
 * композицию моделей данных и классов связи с железом
 */
class ControlCenter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointer<SocketModel> socketModel READ getSocketModel CONSTANT FINAL)
public:
    explicit ControlCenter(QObject *parent = nullptr);
    ~ControlCenter();

    /**
     * @brief выполянет регистрацию класса в qml
     */
    static void registerControl();

    /**
     * @brief возвращает указатель на модель сокетов, используемоую для
     * отображения и редактирования текущих режимов
     * @return
     */
    Q_INVOKABLE QPointer<SocketModel> getSocketModel() const;

    /**
     * @brief возвращает указатель на класс-редактор
     * сокета для внемения изменений через QML
     * @return
     */
    QPointer<SocketModeEditor> editor() const;

    /**
     * @brief инициализация - чтение предыдущих настроек, загрузка режимов из БД и т.д.
     */
    void init();

private:
    QPointer<SocketModel> m_socketModel;
    QPointer<SocketModeEditor> m_editor;
    QPointer<DataBaseReader> m_dbReader;
    // some uart handler should be here
    void initComms();
    void initSockets();
    void readConfigs();
    void prepareConnectios();

    bool readPreviousSocketSettings();

    void defaultSocketInit();
    void dataBaseSocketInit();
    void programmLoadSocketInit();
    void getListOfPrograms(int scopeID);
    std::map<int, std::map<int, InstrInfo>> getConstarints(const QList<int> &idList);
    std::map<int, InstrPtr> getInstrums();

signals:
};

#endif // CONTROLCENTER_H
