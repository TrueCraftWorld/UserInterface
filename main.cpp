#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "SettingsScreen/wifimodule/NetworkDiscover.h"
#include "SettingsScreen/updatemodule/updateclient.h"
#include "BackEnd/controlcenter.h"
#include "BackEnd/instrimageprovider.h"
#include "BackEnd/systemmonitor.h"
#include "BackEnd/keygenerator.h"
#include "qqmlcontext.h"

#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QScopedPointer>
#include <QDateTime>
#include <QTextStream>
#include <QThread>
#include <QProcess>
#include "BackEnd/loggingcategories.h"
#include "BackEnd/linkstm.h"
#include "BackEnd/jsonstorage.h"

// Умный указатель на файл логирования
QScopedPointer<QFile>   m_logFile;

// Класс для связи с stm по uart
LinkStm* m_linkStm;

// Класс для сохранения всяких настроечных штук
JsonStorage* m_savedJson;

// Объявляение обработчика для логов
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
    
    // Настройки для Qt Multimedia
    qputenv("QT_GSTREAMER_USE_PLAYBIN_VOLUME", "1");
    qputenv("GST_DEBUG", "1");  // Минимальная отладка (1=ERROR, 2=WARNING, 3=INFO)
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "gstreamer");
    
    // Настройка приоритетов декодеров H.264
    // В системе доступен только openh264dec (avdec_h264 отсутствует)
    // Для установки avdec_h264: sudo apt install gstreamer1.0-libav
    // v4l2slh264dec - аппаратный (не работает стабильно)
    qputenv("GST_PLUGIN_FEATURE_RANK", "v4l2slh264dec:NONE");
    
    // Используем ximagesink для вывода видео с отключенной синхронизацией
    // sync=false позволяет не сбрасывать буферы при отставании
    qputenv("QT_GSTREAMER_VIDEOSINK", "ximagesink");
    qputenv("QT_GSTREAMER_CAMERABIN_VIDEOSINK", "ximagesink");
    
    // Настройки буферизации и обработки кадров
    qputenv("GST_BUFFER_DURATION", "1000000000");  // 1 секунда буферизации (в наносекундах)
    
    // Настройки аудио - используем PulseAudio с явным указанием устройства
    // Доступные устройства (pactl list sinks):
    // - alsa_output.platform-hdmi-sound.stereo-fallback (HDMI)
    // - alsa_output.platform-rk809-sound.stereo-fallback (Analog/наушники) ✓
    qputenv("QT_GSTREAMER_PLAYBIN_AUDIOSINK", "pulsesink");
    
    // Указываем использовать аналоговый выход (RK809) вместо HDMI
    qputenv("PULSE_SINK", "alsa_output.platform-rk809-sound.stereo-fallback");
    
    // Переключаем RK809 на динамик (SPK) вместо наушников (HP)
    // Playback Mux: 0=HP (наушники), 1=SPK (динамик через GPIO)
    QProcess::execute("amixer", QStringList() << "-c" << "0" << "cset" << "numid=4" << "0");
    
    // Включаем аудио в playbin
    qputenv("QT_GSTREAMER_PLAYBIN_FLAGS", "audio+video+soft-colorbalance+soft-volume");
    
    ///Добавляем модуль клавиатуры
    qputenv("QT_IM_MODULE", QByteArray("cutekeyboard"));
    ///Отключаем курсор мыши на embedded-системе
    qputenv("QT_QPA_EGLFS_HIDECURSOR", "1");

    QGuiApplication app(argc, argv);

    // Устанавливаем кастомный обработчик для вывода только имени файла (без пути)
    qInstallMessageHandler(messageHandler);

    // Включаем QML debugger для удаленной отладки
    // Использование: приложение -qmljsdebugger=port:3768,block
    // Или через переменную окружения: QT_QML_DEBUG=1
    // Для удаленной отладки: -qmljsdebugger=port:3768,host:IP_АДРЕС_ХОСТА
    // Для локальной отладки: -qmljsdebugger=port:3768,block
    // Для отладки без блокировки: -qmljsdebugger=port:3768

    // Устанавливаем файл логирования,
    // m_logFile.reset(new QFile("/home/kikorik/OnyxLog/logFile.txt"));
    // Открываем файл логирования
    // m_logFile.data()->open(QFile::Append | QFile::Text);
    // Устанавливаем обработчик
    // qInstallMessageHandler(messageHandler);

    NetworkControl::registerNetworkControl();
    UpdateClient::registerUpdateClient();
    ControlCenter::registerHandles();

    QSharedPointer<ControlCenter> ctrl  = QSharedPointer<ControlCenter>::create(nullptr);

    // Создаём монитор системы
    SystemMonitor *sysMonitor = new SystemMonitor();
    
    // Создаём генератор секретных ключей
    KeyGenerator *keyGen = new KeyGenerator();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("theModel", ctrl->getSocketModel());
    engine.rootContext()->setContextProperty("Editor", ctrl->getModeEditor());
    engine.rootContext()->setContextProperty("recomHandle", ctrl->getHandle());
    engine.rootContext()->setContextProperty("periphHandle", ctrl->getPeripheryHandle());
    engine.rootContext()->setContextProperty("sysMonitor", sysMonitor);
    engine.rootContext()->setContextProperty("keyGenerator", keyGen);

    engine.addImageProvider(QLatin1String("instrums"), new InstrImageProvider);
    engine.addImageProvider(QLatin1String("instruments"), new InstrImageProvider);
    engine.addImageProvider(QLatin1String("modes"), new InstrImageProvider);
    engine.addImageProvider(QLatin1String("scopes"), new InstrImageProvider);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    //этот вызов для загрузки элемента pullToRefresshHandler
    engine.addImportPath("qrc:/");
    // Добавляем пути для поиска QML модулей на удалённой машине
    engine.addImportPath("/usr/lib/aarch64-linux-gnu/qt5/qml");
    engine.addImportPath("/usr/lib/qt5/qml");
    engine.load(url);

    // Сохраняемые значения лежат в json-файле
    QVariantMap* initMap = new QVariantMap();
    initMap->insert("boot", 0);
    m_savedJson = new JsonStorage(nullptr, initMap);
    QJsonValue boot;
    m_savedJson->read("boot", &boot);

    // Класс для связи с stm по uart
    m_linkStm = new LinkStm();
    // Откуда грузиться stm
    m_linkStm->setBoot(static_cast<LinkStm::BootChoice>(boot.toInt()));

    // Переносим LinkStm в отдельный поток для работы с UART
    QThread *linkStmThread = new QThread();
    m_linkStm->moveToThread(linkStmThread);

    QObject::connect(linkStmThread, &QThread::started,
                     m_linkStm, &LinkStm::start);
    QObject::connect(linkStmThread, &QThread::finished,
                     m_linkStm, &QObject::deleteLater);

    // Корректное завершение потока при выходе из приложения
    QObject::connect(&app, &QCoreApplication::aboutToQuit,
                     linkStmThread, &QThread::quit);
    QObject::connect(linkStmThread, &QThread::finished,
                     linkStmThread, &QObject::deleteLater);

    linkStmThread->start();

    // Связываем LinkStm с ControlCenter для обработки UART-данных
    ctrl->setLinkStm(m_linkStm);

    return app.exec();
}

// Реализация обработчика
void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    if (type == QtCriticalMsg || type == QtWarningMsg) {
        if (msg.startsWith("Failed to move cursor") ||
            msg.startsWith("Could not set cursor") ||
            msg.startsWith("Could not set DRM") ||
            msg.startsWith("Could not queue DRM")) return;    // фильтруем ворнинги, чтобы не забивать лог
    }

    // Извлекаем только имя файла из полного пути
    QFileInfo fileInfo(context.file);
    QString fileName = fileInfo.fileName();
    
    // Определяем префикс уровня сообщения
    QString levelPrefix;
    switch (type) {
    case QtInfoMsg:     levelPrefix = "INFO"; break;
    case QtDebugMsg:    levelPrefix = "DEBUG"; break;
    case QtWarningMsg:  levelPrefix = "WARNING"; break;
    case QtCriticalMsg:  levelPrefix = "CRITICAL"; break;
    case QtFatalMsg:    levelPrefix = "FATAL"; break;
    default: break;
    }

    // Формируем строку с информацией о файле и строке
    QString logLine = QString("%1 [%2:%3] %4")
                          .arg(levelPrefix)
                          .arg(fileName)
                          .arg(context.line)
                          .arg(msg);

    // Записываем в файл (если файл открыт)
    if (m_logFile && m_logFile->isOpen()) {
        QTextStream out(m_logFile.data());
        out << QDateTime::currentDateTime().toString("dd-MM-yyyy hh:mm:ss.zzz ") 
            << logLine << Qt::endl;
    }

    // Выводим в консоль
    QTextStream debugOut(stdout);
    debugOut << logLine << Qt::endl;
}
