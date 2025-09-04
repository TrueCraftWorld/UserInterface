#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>
#include <map>

#include "BackEnd/socketmodeeditor.h"
#include "socketmodel.h"
#include "databasereader.h"
#include "instrument.h"
#include "proghandle.h"
#include "surgicalmode.h"

struct Prog {
    QString name;
    int id;
    bool isMainProg;
};



/**
 * @brief Управляющий класс бэкэнда, осуществляющий
 * композицию моделей данных и классов связи с железом
 */
class ControlCenter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QPointer<SocketModel> socketModel READ getSocketModel CONSTANT FINAL)
    Q_PROPERTY(QPointer<ProgHandle> handle READ getHandle CONSTANT FINAL)
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

    Q_INVOKABLE QPointer<ProgHandle> getHandle() const;

private:
    void makeHandleConnections();
    QPointer<SocketModel> m_socketModel;
    QPointer<SocketModeEditor> m_editor;
    QPointer<ProgHandle> m_handle;
    QPointer<DataBaseReader> m_dbReader;
    // some uart handler should be here
    void initComms();
    void initSockets();
    void readConfigs();
    void prepareConnectios();

    bool readPreviousSocketSettings();

    void defaultSocketInit();
    void dataBaseSocketInit();

    /**
     * @brief ControlCenter::programmLoadSocketInit
     * @param progId
     * @details я тут с ума сойду - вся эта функция за раз в голове не помещается
     * Шаг 1 - получить строки таблицы Lists, с соответствующими id (каждая строка - 1 рабочий экран)
     * Шаг 2 - поличить строки таблицы EnabledMods, с соответствующими id
     *         (каждая строка - 1 разрещённый режим)
     * Шаг 3 - поличить строки таблицы EnabledInstr, с соответствующими id
     *         (каждая строка - 1 разрещённый инструмент)
     * Шаг 4 - из таблицы Instrum получить список допустимых инструментов
     *         для каждого режима в списке режимов (Шаг 2)
     * Шаг 5 - Проредить полученный список инструментов оставив в нём только
     *         те, которые разрешены в данной программе (Шаг 3)
     * Шаг 6 - Поселедовательная инициализация полусокетов по строкам из (Шаг 1)
     *         Если сокет включён:
     *         6.1 - для каждого полусокета прореживание списка режимов
     *         6.2 - для каждого полусокета прореживания списка инструментов
     *         6.3 инициализация сокета полученным списком допустимыз режимов и инструментов
     *         6.4 установка режима, мощностии и инструмента по умолчанию
     */
    void programmLoadSocketInit(int progId);

    /**
     * @brief getListOfPrograms получение списка доспуных программ в категории
     * @param scopeID
     * @return
     */
    QList<Prog> getListOfPrograms(int scopeID);

    std::map<int, std::map<int, InstrInfo>> getConstarints(const QList<int> &idList);
    std::map<int, InstrPtr> getInstrums();

signals:
};

#endif // CONTROLCENTER_H
