#include "HttpUploadController.h"
#include "jsonstorage.h"

#include <QAbstractSocket>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHostAddress>
#include <QNetworkInterface>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QProcess>
#include <QStandardPaths>
#include <QUrl>
#include <QUrlQuery>

namespace {

const char kDefaultUploadDir[] = "/var/lib/qtpr/incoming";

QString ipv4ToQString(const QHostAddress &a)
{
    return a.toString();
}

} // namespace

HttpUploadController::HttpUploadController(QObject *parent)
    : QObject(parent)
    , m_server(new QTcpServer(this))
{
    m_uploadDir = QString::fromUtf8(kDefaultUploadDir);
    m_sessionTimer.setParent(this);
    m_sessionTimer.setSingleShot(true);
    m_sessionTimer.setInterval(kSessionTimeoutMs);
    connect(&m_sessionTimer, &QTimer::timeout, this, &HttpUploadController::onSessionTimeout);
    connect(m_server, &QTcpServer::newConnection, this, &HttpUploadController::onNewConnection);
}

void HttpUploadController::setJsonStorage(JsonStorage *storage)
{
    m_json = storage;
}

void HttpUploadController::setActive(bool v)
{
    if (m_active == v) {
        return;
    }
    m_active = v;
    emit activeChanged();
}

void HttpUploadController::setLastError(const QString &e)
{
    if (m_lastError == e) {
        return;
    }
    m_lastError = e;
    emit lastErrorChanged();
}

QStringList HttpUploadController::localIpv4Addresses() const
{
    QStringList out;
    QStringList preferred;
    const QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : ifaces) {
        if (!(iface.flags() & QNetworkInterface::IsUp)
            || !(iface.flags() & QNetworkInterface::IsRunning)
            || (iface.flags() & QNetworkInterface::IsLoopBack)) {
            continue;
        }
        const QString name = iface.name();
        for (const QNetworkAddressEntry &e : iface.addressEntries()) {
            const QHostAddress a = e.ip();
            if (a.protocol() != QAbstractSocket::IPv4Protocol || a.isLoopback()) {
                continue;
            }
            const QString s = ipv4ToQString(a);
            if (name.startsWith(QStringLiteral("wlan"), Qt::CaseInsensitive)
                || name.startsWith(QStringLiteral("wl"), Qt::CaseInsensitive)) {
                preferred.append(s);
            } else {
                out.append(s);
            }
        }
    }
    preferred.sort();
    out.sort();
    for (const QString &s : out) {
        if (!preferred.contains(s)) {
            preferred.append(s);
        }
    }
    return preferred;
}

void HttpUploadController::updateBaseUrl()
{
    const QStringList ips = localIpv4Addresses();
    const QString ip = ips.isEmpty() ? QStringLiteral("127.0.0.1") : ips.first();
    const QString url = QStringLiteral("http://%1:%2/").arg(ip).arg(m_port);
    if (m_baseUrl == url) {
        return;
    }
    m_baseUrl = url;
    emit baseUrlChanged();
}

void HttpUploadController::updateLogDownloadUrl()
{
    const QString old = m_logDownloadUrl;
    if (!m_active || m_baseUrl.isEmpty() || m_sessionToken.isEmpty()) {
        m_logDownloadUrl.clear();
    } else {
        m_logDownloadUrl = m_baseUrl + QStringLiteral("download/logFile.txt?token=") + m_sessionToken;
    }
    if (old != m_logDownloadUrl) {
        emit logDownloadUrlChanged();
    }
}

QString HttpUploadController::resolveLogFilePath() const
{
    return QDir::homePath() + QStringLiteral("/OnyxLog/logFile.txt");
}

bool HttpUploadController::isValidTokenInPath(const QString &path) const
{
    const QUrl url = QUrl::fromEncoded(path.toUtf8());
    QUrlQuery q(url);
    return q.queryItemValue(QStringLiteral("token")) == m_sessionToken;
}

void HttpUploadController::updateQrCode()
{
    const QString oldPath = m_qrImagePath;
    const QString oldStatus = m_qrStatusText;
    m_qrImagePath.clear();
    m_qrStatusText.clear();

    if (!m_active || m_baseUrl.isEmpty()) {
        if (oldPath != m_qrImagePath) {
            emit qrImagePathChanged();
        }
        if (oldStatus != m_qrStatusText) {
            emit qrStatusTextChanged();
        }
        return;
    }

    const QString qrencodePath = QStandardPaths::findExecutable(QStringLiteral("qrencode"));
    if (qrencodePath.isEmpty()) {
        m_qrStatusText = QString::fromUtf8("QR недоступен: не установлен qrencode.");
        if (oldPath != m_qrImagePath) {
            emit qrImagePathChanged();
        }
        if (oldStatus != m_qrStatusText) {
            emit qrStatusTextChanged();
        }
        return;
    }

    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
            + QStringLiteral("/wifi_upload");
    QDir().mkpath(dir);
    const QString outPath = dir + QStringLiteral("/upload_qr.png");

    QProcess proc;
    const QStringList args = {
        QStringLiteral("-o"), outPath,
        QStringLiteral("-s"), QStringLiteral("8"),
        QStringLiteral("-m"), QStringLiteral("1"),
        m_baseUrl
    };
    proc.start(qrencodePath, args);
    if (!proc.waitForStarted(1000) || !proc.waitForFinished(3000) || proc.exitCode() != 0 || !QFile::exists(outPath)) {
        m_qrStatusText = QString::fromUtf8("QR недоступен: ошибка запуска qrencode.");
    } else {
        m_qrImagePath = QStringLiteral("file://") + outPath
                + QStringLiteral("?ts=") + QString::number(QDateTime::currentMSecsSinceEpoch());
        m_qrStatusText.clear();
    }

    if (oldPath != m_qrImagePath) {
        emit qrImagePathChanged();
    }
    if (oldStatus != m_qrStatusText) {
        emit qrStatusTextChanged();
    }
}

QString HttpUploadController::uploadSavePath() const
{
    return effectiveUploadDir();
}

QString HttpUploadController::effectiveUploadDir() const
{
    QString dir = m_uploadDir;
    if (dir.isEmpty()) {
        dir = QString::fromUtf8(kDefaultUploadDir);
    }
    QDir d;
    if (d.mkpath(dir)) {
        const QFileInfo fi(dir);
        if (fi.isDir() && fi.isWritable()) {
            return dir;
        }
    }
    const QString fallback = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
            + QStringLiteral("/wifi_upload");
    d.mkpath(fallback);
    return fallback;
}

static QString randomToken()
{
    const char alphabet[] = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    QString s;
    s.reserve(10);
    for (int i = 0; i < 10; ++i) {
        s.append(QLatin1Char(alphabet[QRandomGenerator::global()->bounded(int(sizeof(alphabet) - 2))]));
    }
    return s;
}

void HttpUploadController::startSession()
{
    setLastError(QString());
    if (m_active) {
        return;
    }

    if (m_json) {
        const QString p = m_json->readString(QStringLiteral("httpUploadPort"));
        if (!p.isEmpty()) {
            bool ok = false;
            const int parsed = p.toInt(&ok);
            if (ok && parsed > 0 && parsed < 65536 && m_port != parsed) {
                m_port = parsed;
                emit listenPortChanged();
            }
        }
        const QString d = m_json->readString(QStringLiteral("httpUploadDir"));
        if (!d.isEmpty()) {
            m_uploadDir = d;
        }
    }

    m_sessionToken = randomToken();
    emit sessionTokenChanged();

    QDir().mkpath(effectiveUploadDir());
    emit uploadSavePathChanged();

    if (!m_server->listen(QHostAddress::AnyIPv4, static_cast<quint16>(m_port))) {
        setLastError(QString::fromUtf8("Не удалось занять порт %1: %2")
                             .arg(m_port)
                             .arg(m_server->errorString()));
        m_sessionToken.clear();
        emit sessionTokenChanged();
        return;
    }

    updateBaseUrl();
    setActive(true);
    updateLogDownloadUrl();
    updateQrCode();
    m_sessionTimer.start();
}

void HttpUploadController::stopSession()
{
    m_sessionTimer.stop();
    if (m_client) {
        m_client->disconnect(this);
        m_client->abort();
        m_client->deleteLater();
        m_client = nullptr;
    }
    m_rxBuffer.clear();
    m_headerComplete = false;
    m_contentLength = -1;
    m_requestHeaders.clear();
    if (m_server->isListening()) {
        m_server->close();
    }
    m_sessionToken.clear();
    emit sessionTokenChanged();
    m_rxBuffer.clear();
    m_headerComplete = false;
    m_contentLength = -1;
    m_requestHeaders.clear();
    setActive(false);
    m_baseUrl.clear();
    emit baseUrlChanged();
    updateLogDownloadUrl();
    updateQrCode();
}

void HttpUploadController::onSessionTimeout()
{
    stopSession();
}

void HttpUploadController::onNewConnection()
{
    if (m_client) {
        QTcpSocket *busy = m_server->nextPendingConnection();
        if (busy) {
            const QByteArray msg = "HTTP/1.1 503 Service Unavailable\r\nConnection: close\r\nContent-Length: 0\r\n\r\n";
            busy->write(msg);
            connect(busy, &QTcpSocket::disconnected, busy, &QTcpSocket::deleteLater);
            busy->disconnectFromHost();
        }
        return;
    }

    m_client = m_server->nextPendingConnection();
    if (!m_client) {
        return;
    }
    m_rxBuffer.clear();
    m_headerComplete = false;
    m_contentLength = -1;
    m_requestHeaders.clear();
    connect(m_client, &QTcpSocket::readyRead, this, &HttpUploadController::onClientReadyRead);
    connect(m_client, &QTcpSocket::disconnected, this, &HttpUploadController::onClientDisconnected);
}

void HttpUploadController::onClientDisconnected()
{
    if (m_client) {
        m_client->deleteLater();
        m_client = nullptr;
    }
    m_rxBuffer.clear();
    m_headerComplete = false;
    m_contentLength = -1;
    m_requestHeaders.clear();
}

void HttpUploadController::sendHttpResponse(QTcpSocket *socket, int statusCode, const QByteArray &contentType,
                                          const QByteArray &body)
{
    QByteArray line;
    switch (statusCode) {
    case 200:
        line = "HTTP/1.1 200 OK\r\n";
        break;
    case 204:
        line = "HTTP/1.1 204 No Content\r\n";
        break;
    case 400:
        line = "HTTP/1.1 400 Bad Request\r\n";
        break;
    case 403:
        line = "HTTP/1.1 403 Forbidden\r\n";
        break;
    case 404:
        line = "HTTP/1.1 404 Not Found\r\n";
        break;
    case 413:
        line = "HTTP/1.1 413 Payload Too Large\r\n";
        break;
    default:
        line = QByteArray("HTTP/1.1 ") + QByteArray::number(statusCode) + " Error\r\n";
        break;
    }
    QByteArray hdr = line;
    hdr += "Connection: close\r\n";
    if (!contentType.isEmpty()) {
        hdr += "Content-Type: ";
        hdr += contentType;
        hdr += "\r\n";
    }
    hdr += "Content-Length: ";
    hdr += QByteArray::number(body.size());
    hdr += "\r\n\r\n";
    socket->write(hdr);
    if (!body.isEmpty()) {
        socket->write(body);
    }
    socket->flush();
}

void HttpUploadController::sendFileDownloadResponse(QTcpSocket *socket, const QByteArray &downloadFileName,
                                                    const QByteArray &body)
{
    QByteArray hdr = "HTTP/1.1 200 OK\r\n";
    hdr += "Connection: close\r\n";
    hdr += "Content-Type: application/octet-stream\r\n";
    hdr += "Content-Disposition: attachment; filename=\"";
    hdr += downloadFileName;
    hdr += "\"\r\n";
    hdr += "Content-Length: ";
    hdr += QByteArray::number(body.size());
    hdr += "\r\n\r\n";
    socket->write(hdr);
    if (!body.isEmpty()) {
        socket->write(body);
    }
    socket->flush();
}

void HttpUploadController::sendSimpleHtml(QTcpSocket *socket, int statusCode, const QString &title,
                                        const QString &bodyHtml)
{
    const QString page = QStringLiteral("<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>%1</title></head>"
                                        "<body>%2</body></html>")
                                 .arg(title, bodyHtml);
    sendHttpResponse(socket, statusCode, "text/html; charset=utf-8", page.toUtf8());
}

QByteArray HttpUploadController::buildUploadPageHtml() const
{
    const QString token = m_sessionToken.toHtmlEscaped();
    const QString downloadHref = QStringLiteral("/download/logFile.txt?token=%1").arg(token);
    const QString html = QStringLiteral(
            "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, "
            "initial-scale=1\"><title>Загрузка файлов</title></head><body>"
            "<h1>Загрузка файлов</h1><p>Выберите один или несколько файлов и нажмите «Отправить».</p>"
            "<form method=\"post\" action=\"/upload\" enctype=\"multipart/form-data\">"
            "<input type=\"hidden\" name=\"token\" value=\"%1\">"
            "<p><input type=\"file\" name=\"file\" multiple></p>"
            "<p><button type=\"submit\">Отправить</button></p>"
            "</form>"
            "<hr><h2>Передача файла с устройства</h2>"
            "<p><a href=\"%2\">Скачать logFile.txt</a></p>"
            "</body></html>")
                                 .arg(token, downloadHref);
    return html.toUtf8();
}

bool HttpUploadController::extractMultipartBoundary(const QString &contentType, QByteArray *boundaryPrefixOut)
{
    const int idx = contentType.indexOf(QStringLiteral("boundary="), 0, Qt::CaseInsensitive);
    if (idx < 0) {
        return false;
    }
    QString b = contentType.mid(idx + 9).trimmed();
    if (b.startsWith(QLatin1Char('"'))) {
        const int end = b.indexOf(QLatin1Char('"'), 1);
        if (end > 1) {
            b = b.mid(1, end - 1);
        }
    } else {
        const int semi = b.indexOf(QLatin1Char(';'));
        if (semi >= 0) {
            b = b.left(semi).trimmed();
        }
    }
    if (b.isEmpty()) {
        return false;
    }
    *boundaryPrefixOut = QByteArray("--") + b.toUtf8();
    return true;
}

QString HttpUploadController::sanitizeFileName(const QString &rawName)
{
    QString base = rawName.trimmed();
    base.replace(QRegularExpression(QStringLiteral("[\\\\/]+")), QStringLiteral("_"));
    base.replace(QStringLiteral(".."), QStringLiteral("_"));
    if (base.length() > 200) {
        base = base.left(200);
    }
    return base;
}

QString HttpUploadController::makeUniquePath(const QString &fileName) const
{
    const QString dir = effectiveUploadDir();
    QString base = fileName;
    const int dot = base.lastIndexOf(QLatin1Char('.'));
    QString stem = dot > 0 ? base.left(dot) : base;
    QString ext = dot > 0 ? base.mid(dot) : QString();
    QString path = dir + QLatin1Char('/') + base;
    int n = 1;
    while (QFile::exists(path)) {
        path = dir + QLatin1Char('/') + stem + QLatin1Char('_') + QString::number(n) + ext;
        ++n;
    }
    return path;
}

bool HttpUploadController::parseMultipartAndSave(const QByteArray &body, const QString &contentType, int *filesSaved,
                                                 QString *errorMessage)
{
    *filesSaved = 0;
    QByteArray delim;
    if (!extractMultipartBoundary(contentType, &delim)) {
        *errorMessage = QStringLiteral("boundary");
        return false;
    }

    const QByteArray sep = QByteArray("\r\n") + delim;

    int pos = body.indexOf(delim);
    if (pos < 0) {
        *errorMessage = QStringLiteral("no boundary");
        return false;
    }
    pos += delim.size();
    if (pos + 1 < body.size() && body[pos] == '\r') {
        ++pos;
    }
    if (pos < body.size() && body[pos] == '\n') {
        ++pos;
    }

    QString formToken;

    while (pos < body.size()) {
        const int headerEnd = body.indexOf("\r\n\r\n", pos);
        if (headerEnd < 0) {
            *errorMessage = QStringLiteral("truncated headers");
            return false;
        }
        const QByteArray partHdr = body.mid(pos, headerEnd - pos);
        const int contentStart = headerEnd + 4;

        QString hdrStr = QString::fromUtf8(partHdr);
        QString nameField;
        QString fileName;
        const QRegularExpression nameRe(QStringLiteral("name=\"([^\"]*)\""));
        const QRegularExpression fnRe(QStringLiteral("filename=\"([^\"]*)\""));
        {
            const auto m = nameRe.match(hdrStr);
            if (m.hasMatch()) {
                nameField = m.captured(1);
            }
            const auto mf = fnRe.match(hdrStr);
            if (mf.hasMatch()) {
                fileName = mf.captured(1);
            }
        }

        const int sepPos = body.indexOf(sep, contentStart);
        if (sepPos < 0) {
            *errorMessage = QStringLiteral("truncated part");
            return false;
        }
        const QByteArray partBody = body.mid(contentStart, sepPos - contentStart);
        const int afterBoundary = sepPos + sep.size();
        const bool isClosing = (afterBoundary + 1 < body.size() && body[afterBoundary] == '-'
                                && body[afterBoundary + 1] == '-');

        if (nameField == QStringLiteral("token")) {
            formToken = QString::fromUtf8(partBody).trimmed();
        } else if (nameField == QStringLiteral("file") && !fileName.isEmpty()) {
            const QString safe = sanitizeFileName(QFileInfo(fileName).fileName());
            if (!safe.isEmpty()) {
                if (*filesSaved >= kMaxFilesPerRequest) {
                    *errorMessage = QStringLiteral("too many files");
                    return false;
                }
                const QString outPath = makeUniquePath(safe);
                QFile f(outPath);
                if (!f.open(QIODevice::WriteOnly)) {
                    *errorMessage = QStringLiteral("write");
                    return false;
                }
                if (f.write(partBody) != partBody.size()) {
                    *errorMessage = QStringLiteral("write");
                    return false;
                }
                f.close();
                ++(*filesSaved);
            }
        }

        if (isClosing) {
            break;
        }
        pos = afterBoundary;
        if (pos + 1 < body.size() && body[pos] == '\r' && body[pos + 1] == '\n') {
            pos += 2;
        } else if (pos < body.size() && body[pos] == '\n') {
            ++pos;
        }
    }

    if (formToken != m_sessionToken) {
        *errorMessage = QStringLiteral("token");
        return false;
    }
    if (*filesSaved == 0) {
        *errorMessage = QStringLiteral("no files");
        return false;
    }
    return true;
}

void HttpUploadController::tryProcessBuffer()
{
    if (!m_client) {
        return;
    }

    if (!m_headerComplete) {
        const int sep = m_rxBuffer.indexOf("\r\n\r\n");
        if (sep < 0) {
            if (m_rxBuffer.size() > 65536) {
                sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Слишком длинные заголовки</p>"));
                if (m_client) {
                    m_client->disconnectFromHost();
                }
            }
            return;
        }

        const QByteArray headerBlob = m_rxBuffer.left(sep);
        m_rxBuffer.remove(0, sep + 4);

        const QList<QByteArray> lines = headerBlob.split('\n');
        if (lines.isEmpty()) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Некорректный запрос</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }

        const QByteArray reqLine = lines.first().trimmed();
        const QList<QByteArray> parts = reqLine.split(' ');
        if (parts.size() < 2) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Некорректная строка запроса</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }
        m_method = QString::fromLatin1(parts[0]);
        m_path = QString::fromLatin1(parts[1]);
        const int q = m_path.indexOf(QLatin1Char('?'));
        if (q >= 0) {
            m_path = m_path.left(q);
        }

        m_requestHeaders.clear();
        for (int i = 1; i < lines.size(); ++i) {
            const QByteArray ln = lines.at(i).trimmed();
            const int c = ln.indexOf(':');
            if (c > 0) {
                const QString k = QString::fromLatin1(ln.left(c).trimmed().toLower());
                const QString v = QString::fromLatin1(ln.mid(c + 1).trimmed());
                m_requestHeaders.insert(k, v);
            }
        }

        m_headerComplete = true;

        if (m_method == QStringLiteral("GET")) {
            if (m_path == QStringLiteral("/") || m_path.isEmpty()) {
                sendHttpResponse(m_client, 200, "text/html; charset=utf-8", buildUploadPageHtml());
            } else if (m_path.startsWith(QStringLiteral("/download/logFile.txt"))) {
                if (!isValidTokenInPath(QString::fromLatin1(parts[1]))) {
                    sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                                   QStringLiteral("<p>Неверный токен для скачивания файла.</p>"));
                } else {
                    const QString logPath = resolveLogFilePath();
                    QFile f(logPath);
                    if (!f.exists() || !f.open(QIODevice::ReadOnly)) {
                        sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"),
                                       QStringLiteral("<p>Файл лога не найден: %1</p>").arg(logPath.toHtmlEscaped()));
                    } else {
                        sendFileDownloadResponse(m_client, "logFile.txt", f.readAll());
                    }
                }
            } else if (m_path == QStringLiteral("/favicon.ico")) {
                sendHttpResponse(m_client, 204, QByteArray(), QByteArray());
            } else {
                sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"), QStringLiteral("<p>Страница не найдена</p>"));
            }
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }

        if (m_method != QStringLiteral("POST")) {
            sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"), QStringLiteral("<p>Метод не поддерживается</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }

        if (m_path != QStringLiteral("/upload")) {
            sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"), QStringLiteral("<p>Страница не найдена</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }

        const QString cl = m_requestHeaders.value(QStringLiteral("content-length"));
        if (cl.isEmpty()) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Нужен заголовок Content-Length</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }
        bool okLen = false;
        m_contentLength = cl.toLongLong(&okLen);
        if (!okLen || m_contentLength < 0 || m_contentLength > kMaxBodyBytes) {
            sendSimpleHtml(m_client, 413, QStringLiteral("Слишком большой"),
                           QStringLiteral("<p>Размер запроса превышает допустимый</p>"));
            if (m_client) {
                m_client->disconnectFromHost();
            }
            return;
        }
    }

    // body
    if (m_contentLength < 0) {
        return;
    }
    if (m_rxBuffer.size() > m_contentLength) {
        sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Лишние данные в теле запроса</p>"));
        if (m_client) {
            m_client->disconnectFromHost();
        }
        return;
    }
    if (m_rxBuffer.size() < m_contentLength) {
        return;
    }

    const QByteArray body = m_rxBuffer.left(static_cast<int>(m_contentLength));
    m_rxBuffer.clear();

    const QString ct = m_requestHeaders.value(QStringLiteral("content-type"));
    if (!ct.contains(QStringLiteral("multipart/form-data"), Qt::CaseInsensitive)) {
        sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Ожидается multipart/form-data</p>"));
        if (m_client) {
            m_client->disconnectFromHost();
        }
        return;
    }

    int nFiles = 0;
    QString err;
    if (!parseMultipartAndSave(body, ct, &nFiles, &err)) {
        if (err == QStringLiteral("token")) {
            sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                           QStringLiteral("<p>Неверный или устаревший токен. Откройте страницу снова с устройства.</p>"));
        } else if (err == QStringLiteral("no files")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Файлы не выбраны</p>"));
        } else if (err == QStringLiteral("too many files")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Слишком много файлов за один раз</p>"));
        } else {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Не удалось разобрать данные формы</p>"));
        }
        if (m_client) {
            m_client->disconnectFromHost();
        }
        return;
    }

    emit filesReceived(nFiles);
    sendSimpleHtml(m_client, 200, QStringLiteral("Готово"),
                   QStringLiteral("<p>Успешно загружено файлов: %1</p><p><a href=\"/\">Загрузить ещё</a></p>").arg(nFiles));
    if (m_client) {
        m_client->disconnectFromHost();
    }
}

void HttpUploadController::onClientReadyRead()
{
    if (!m_client) {
        return;
    }
    m_rxBuffer.append(m_client->readAll());
    tryProcessBuffer();
}
