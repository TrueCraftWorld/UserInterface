#ifndef SYSTEMMONITOR_H
#define SYSTEMMONITOR_H

#include <QObject>
#include <QTimer>
#include <QString>

/**
 * @brief Класс для мониторинга системных параметров (CPU, температура)
 * 
 * Используется для отображения информации о загрузке процессора
 * и температуре в реальном времени для платформы ROC-RK3566 на Armbian
 */
class SystemMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
    Q_PROPERTY(double temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(int updateInterval READ updateInterval WRITE setUpdateInterval NOTIFY updateIntervalChanged)

public:
    explicit SystemMonitor(QObject *parent = nullptr);
    ~SystemMonitor();

    // Геттеры для свойств
    double cpuUsage() const { return m_cpuUsage; }
    double temperature() const { return m_temperature; }
    int updateInterval() const { return m_updateInterval; }

    // Сеттеры
    void setUpdateInterval(int interval);

    // Методы для QML
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE QString getCpuModel();

signals:
    void cpuUsageChanged();
    void temperatureChanged();
    void updateIntervalChanged();

private slots:
    void updateStats();

private:
    // Методы для получения данных
    double readCpuUsage();
    double readTemperature();
    
    // Таймер для обновления данных
    QTimer *m_timer;
    
    // Текущие значения
    double m_cpuUsage;
    double m_temperature;
    int m_updateInterval;  // В миллисекундах
    
    // Для расчёта CPU usage
    unsigned long long m_prevTotal;
    unsigned long long m_prevIdle;
};

#endif // SYSTEMMONITOR_H

