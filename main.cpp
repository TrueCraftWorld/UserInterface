#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "SettingsScreen/wifimodule/NetworkDiscover.h"
#include "SettingsScreen/updatemodule/updateclient.h"
#include "BackEnd/controlcenter.h"
#include "BackEnd/instrimageprovider.h"
#include "qqmlcontext.h"

#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QLoggingCategory>
#include <QScopedPointer>
#include <QDateTime>
#include <QTextStream>
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

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("theModel", ctrl->getSocketModel());
    engine.rootContext()->setContextProperty("Editor", ctrl->getModeEditor());
    engine.rootContext()->setContextProperty("recomHandle", ctrl->getHandle());
    engine.rootContext()->setContextProperty("periphHandle", ctrl->getPeripheryHandle());

    engine.addImageProvider(QLatin1String("instrums"), new InstrImageProvider);
    engine.addImageProvider(QLatin1String("instruments"), new InstrImageProvider);
    engine.addImageProvider(QLatin1String("modes"), new InstrImageProvider);

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
