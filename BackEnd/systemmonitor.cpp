#include "systemmonitor.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_cpuUsage(0.0)
    , m_temperature(0.0)
    , m_updateInterval(1000)  // По умолчанию 1 секунда
    , m_prevTotal(0)
    , m_prevIdle(0)
{
    connect(m_timer, &QTimer::timeout, this, &SystemMonitor::updateStats);
    
    // Первое чтение для инициализации
    readCpuUsage();
}

SystemMonitor::~SystemMonitor()
{
    stop();
}

void SystemMonitor::start()
{
    if (!m_timer->isActive()) {
        m_timer->start(m_updateInterval);
        updateStats();  // Сразу обновляем данные
        // qDebug() << "SystemMonitor: Мониторинг запущен с интервалом" << m_updateInterval << "мс";
    }
}

void SystemMonitor::stop()
{
    if (m_timer->isActive()) {
        m_timer->stop();
        // qDebug() << "SystemMonitor: Мониторинг остановлен";
    }
}

void SystemMonitor::setUpdateInterval(int interval)
{
    if (m_updateInterval != interval && interval > 0) {
        m_updateInterval = interval;
        if (m_timer->isActive()) {
            m_timer->setInterval(m_updateInterval);
        }
        emit updateIntervalChanged();
    }
}

void SystemMonitor::updateStats()
{
    double newCpuUsage = readCpuUsage();
    if (qAbs(newCpuUsage - m_cpuUsage) > 0.01) {  // Обновляем если изменение > 0.01%
        m_cpuUsage = newCpuUsage;
        emit cpuUsageChanged();
    }
    
    double newTemp = readTemperature();
    if (qAbs(newTemp - m_temperature) > 0.1) {  // Обновляем если изменение > 0.1°C
        m_temperature = newTemp;
        emit temperatureChanged();
    }
}

double SystemMonitor::readCpuUsage()
{
    QFile file("/proc/stat");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "SystemMonitor: Не удалось открыть /proc/stat";
        return 0.0;
    }
    
    QTextStream in(&file);
    QString line = in.readLine();
    file.close();
    
    if (!line.startsWith("cpu ")) {
        return 0.0;
    }
//    qDebug() << line;
    // Формат: cpu user nice system idle iowait irq softirq steal guest guest_nice
    QStringList parts = line.split(' ', Qt::SkipEmptyParts);
    if (parts.size() < 5) {
        return 0.0;
    }
    
    // Суммируем все значения для получения total time
    unsigned long long user = parts[1].toULongLong();
    unsigned long long nice = parts[2].toULongLong();
    unsigned long long system = parts[3].toULongLong();
    unsigned long long idle = parts[4].toULongLong();
    unsigned long long iowait = parts.size() > 5 ? parts[5].toULongLong() : 0;
    unsigned long long irq = parts.size() > 6 ? parts[6].toULongLong() : 0;
    unsigned long long softirq = parts.size() > 7 ? parts[7].toULongLong() : 0;
    unsigned long long steal = parts.size() > 8 ? parts[8].toULongLong() : 0;
    
    unsigned long long totalIdle = idle + iowait;
    unsigned long long total = user + nice + system + idle + iowait + irq + softirq + steal;
    
    // Вычисляем разницу с предыдущими значениями
    unsigned long long totalDelta = total - m_prevTotal;
    unsigned long long idleDelta = totalIdle - m_prevIdle;
    
    double usage = 0.0;
    if (totalDelta > 0) {
        usage = 100.0 * (totalDelta - idleDelta) / totalDelta;
    }
    
    // Сохраняем текущие значения для следующего расчёта
    m_prevTotal = total;
    m_prevIdle = totalIdle;
    
    return usage;
}

double SystemMonitor::readTemperature()
{
    // Пробуем разные источники температуры для ROC-RK3566
    QString path = "/sys/class/thermal/thermal_zone0/temp";
//    QString path = "/sys/class/thermal/thermal_zone0/temp";     // на 2-3°C ниже
//    QString path = "/sys/class/thermal/thermal_zone0/temp";     // Те же самые значения
//    QString path = "/sys/class/thermal/thermal_zone0/temp";
    
    QFile file(path);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString tempStr = in.readLine().trimmed();
        file.close();

        bool ok;
        int tempMilliDegrees = tempStr.toInt(&ok);
        if (ok) {
            // Температура хранится в милли-градусах Цельсия
            double tempCelsius = tempMilliDegrees / 1000.0;
//            qDebug() << "Считываем температуру из " << path << " " << tempCelsius << "°C";
            // Проверяем разумность значения (от -50 до 150°C)
            if (tempCelsius >= -50.0 && tempCelsius <= 150.0) {
               return tempCelsius;
            }
        }
    }
    
    qWarning() << "SystemMonitor: Не удалось прочитать температуру";
    return 0.0;
}

QString SystemMonitor::getCpuModel()
{
    QFile file("/proc/cpuinfo");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return "Unknown CPU";
    }
    
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.startsWith("model name") || line.startsWith("Hardware")) {
            QStringList parts = line.split(':');
            if (parts.size() >= 2) {
                file.close();
                return parts[1].trimmed();
            }
        }
    }
    
    file.close();
    return "ROC-RK3566";
}

