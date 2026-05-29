#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H

#include <QObject>
#include <QPointer>
#include <QTimer>
#include <QStringList>

#include "BackEnd/socketmodeeditor.h"
#include "socketmodel.h"
#include "periphhandler.h"
#include "proghandle.h"
#include "progloader.h"
#include "linkstm.h"

/**
 * @brief Управляющий класс бэкэнда, осуществляющий
 * композицию моделей данных и классов связи с железом
 */
class ControlCenter : public QObject
{
	Q_OBJECT
    Q_PROPERTY(QString debugOverlayText READ debugOverlayText NOTIFY debugOverlayTextChanged)
    Q_PROPERTY(bool debugUartEnabled READ debugUartEnabled WRITE setDebugUartEnabled NOTIFY debugUartEnabledChanged)
    Q_PROPERTY(bool cpuMonitorVisible READ cpuMonitorVisible WRITE setCpuMonitorVisible NOTIFY cpuMonitorVisibleChanged)

public:
	explicit ControlCenter(QObject *parent = nullptr);
	~ControlCenter();

	/**
	 * @brief выполянет регистрацию класса в qml
	 */
	static void registerHandles();

	/**
	 * @brief возвращает указатель на модель сокетов, используемоую для
	 * отображения и редактирования текущих режимов
	 * @return
	 */
	QPointer<SocketModel> getSocketModel() const;

	/**
	 * @brief возвращает указатель на класс-редактор
	 * сокета для внемения изменений через QML
	 * @return
	 */
	QPointer<SocketModeEditor> getModeEditor() const;

	/**
	 * @brief инициализация - чтение предыдущих настроек, загрузка режимов из БД и т.д.
	 */
	void init();

	QPointer<ProgHandle> getHandle() const;

	/**
	 * @brief Запускает отложенное сохранение (с задержкой 2 секунды)
	 * Используется для частых изменений (мощность) чтобы не перегружать БД
	 */
	void scheduleSave();
	void flushPendingSave();

	/**
	 * @brief Устанавливает указатель на объект LinkStm для UART-коммуникации
	 * @param linkStm Указатель на объект LinkStm
	 */
	void setLinkStm(LinkStm* linkStm);

	QPointer<PeriphHandler> getPeripheryHandle() const;

	Q_INVOKABLE bool loadProgram(int progId, bool clear);
	Q_INVOKABLE void setNeutralResistPollEnabled(bool enabled);
    Q_INVOKABLE void appendDebugOverlayLine(const QString &line);
    Q_INVOKABLE void clearDebugOverlay();
    QString debugOverlayText() const;
    bool debugUartEnabled() const;
    void setDebugUartEnabled(bool enabled);
    bool cpuMonitorVisible() const;
    void setCpuMonitorVisible(bool visible);

signals:
    void debugOverlayTextChanged();
    void debugUartEnabledChanged();
    void cpuMonitorVisibleChanged();

private:
	QSharedPointer<SocketModel> m_socketModel;

	QPointer<SocketModeEditor> m_editor;
	QPointer<ProgHandle> m_handle;
	QPointer<ProgLoader> m_progLoader;
	QPointer<PeriphHandler> m_periphery;
	QPointer<LinkStm> m_linkStm;
    int m_autoDelay = 0; // Задержка автозапуска в мс (runtime)
    QStringList m_debugOverlayLines;
    QString m_debugOverlayText;
    bool m_debugUartEnabled = false;
    bool m_cpuMonitorVisible = false;
    static constexpr int kDebugOverlayMaxLines = 40;

	QTimer* m_saveTimer = nullptr;  // Таймер для отложенного сохранения

private:
	/**
	 * @brief Обработчик входящих UART-данных
	 * @param rxData Указатель на принятую команду
	 */
	void makeHandleConnections();
	void initSocketsForPeriphery();

	void initSockets();
	void prepareConnectios();

	// void uartChat(LinkStm::UartRx* rxData);
	// void uartError(quint8 errorState);
};
#endif // CONTROLCENTER_H
