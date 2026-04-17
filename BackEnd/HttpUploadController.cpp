#include "HttpUploadController.h"
#include "jsonstorage.h"
#include "linkstm.h"

#include <QAbstractSocket>
#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QCoreApplication>
#include <QHostAddress>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCryptographicHash>
#include <QNetworkInterface>
#include <QProcessEnvironment>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QProcess>
#include <QStandardPaths>
#include <QPointer>
#include <QTemporaryDir>
#include <QUrl>
#include <QUrlQuery>
#include <QMetaObject>

namespace {

const char kDefaultUploadDir[] = "/var/lib/qtpr/incoming";
const char kReleaseZipPassword[] = "Electrosurgical";
const QRegularExpression kReleaseZipNameRe(
    QStringLiteral("^.+-(\\d+)\\.(\\d+)-(\\d+)\\.(\\d+)-(\\d+)\\.zip$"),
    QRegularExpression::CaseInsensitiveOption);
const QRegularExpression kFirmwareFileRe(
    QStringLiteral("^(COM|ARG|GEN)-([0-9]+(?:\\.[0-9]+)*)\\.hex$"),
    QRegularExpression::CaseInsensitiveOption);
const QRegularExpression kSimpleVersionRe(
    QStringLiteral("^\\d+(?:\\.\\d+)*$"));
const char kUploadFirewallGuardPath[] = "/usr/local/sbin/upload-fw-guard";

QString ipv4ToQString(const QHostAddress &a)
{
    return a.toString();
}

QString normalizedBaseUrl(QString value)
{
    value = value.trimmed();
    if (value.isEmpty()) {
        return QString();
    }
    if (!value.endsWith(QLatin1Char('/'))) {
        value += QLatin1Char('/');
    }
    return value;
}

bool parseBoolString(const QString &value)
{
    const QString v = value.trimmed().toLower();
    return v == QStringLiteral("1")
            || v == QStringLiteral("true")
            || v == QStringLiteral("yes")
            || v == QStringLiteral("on");
}

QString selectPayloadRoot(const QString &extractRoot)
{
    QDir root(extractRoot);
    const QFileInfoList entries = root.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries, QDir::Name);
    if (entries.size() == 1 && entries.first().isDir()) {
        return entries.first().absoluteFilePath();
    }
    return extractRoot;
}

QString findManifestPathRecursive(const QString &rootDir)
{
    QDirIterator it(rootDir, QStringList() << QStringLiteral("update-manifest.json"),
                    QDir::Files, QDirIterator::Subdirectories);
    if (it.hasNext()) {
        return it.next();
    }
    return QString();
}

QString resolveUnzipProgramPath()
{
    QString program = QStandardPaths::findExecutable(QStringLiteral("unzip"));
    if (!program.isEmpty()) {
        return program;
    }
    const QStringList candidates = {
        QStringLiteral("/usr/bin/unzip"),
        QStringLiteral("/bin/unzip"),
        QStringLiteral("/usr/local/bin/unzip")
    };
    for (const QString &p : candidates) {
        if (QFileInfo::exists(p) && QFileInfo(p).isExecutable()) {
            return p;
        }
    }
    return QString();
}

QString payloadSha256Hex(const QString &payloadRoot)
{
    QFileInfo fi(payloadRoot);
    if (!fi.exists()) {
        return QString();
    }
    if (fi.isFile()) {
        QFile f(payloadRoot);
        if (!f.open(QIODevice::ReadOnly)) {
            return QString();
        }
        QCryptographicHash h(QCryptographicHash::Sha256);
        while (!f.atEnd()) {
            const QByteArray chunk = f.read(1024 * 1024);
            if (chunk.isEmpty() && !f.atEnd()) {
                return QString();
            }
            h.addData(chunk);
        }
        return QString::fromLatin1(h.result().toHex());
    }

    QStringList relFiles;
    QDirIterator it(payloadRoot, QDir::Files, QDirIterator::Subdirectories);
    QDir root(payloadRoot);
    while (it.hasNext()) {
        const QString rel = root.relativeFilePath(it.next());
        if (rel == QStringLiteral("update-manifest.json")) {
            continue;
        }
        relFiles.append(rel);
    }
    std::sort(relFiles.begin(), relFiles.end());

    QCryptographicHash h(QCryptographicHash::Sha256);
    for (const QString &rel : relFiles) {
        h.addData(rel.toUtf8());
        h.addData("\n", 1);
        QFile f(root.filePath(rel));
        if (!f.open(QIODevice::ReadOnly)) {
            return QString();
        }
        while (!f.atEnd()) {
            const QByteArray chunk = f.read(1024 * 1024);
            if (chunk.isEmpty() && !f.atEnd()) {
                return QString();
            }
            h.addData(chunk);
        }
        h.addData("\n", 1);
    }
    return QString::fromLatin1(h.result().toHex());
}

int compareVersionsDesc(const QString &lhs, const QString &rhs)
{
    const QStringList lparts = lhs.split(QLatin1Char('.'));
    const QStringList rparts = rhs.split(QLatin1Char('.'));
    const int n = qMax(lparts.size(), rparts.size());
    for (int i = 0; i < n; ++i) {
        const int lv = (i < lparts.size()) ? lparts.at(i).toInt() : 0;
        const int rv = (i < rparts.size()) ? rparts.at(i).toInt() : 0;
        if (lv > rv) {
            return -1;
        }
        if (lv < rv) {
            return 1;
        }
    }
    return 0;
}

QStringList scanFirmwareHexVersions(const QString &dirPath, const QString &prefix)
{
    QStringList versions;
    QDir dir(dirPath);
    const QFileInfoList files = dir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name);
    const QString upperPrefix = prefix.toUpper();
    for (const QFileInfo &fi : files) {
        const QString base = fi.fileName();
        const QRegularExpressionMatch m = kFirmwareFileRe.match(base);
        if (!m.hasMatch()) {
            continue;
        }
        if (m.captured(1).toUpper() != upperPrefix) {
            continue;
        }
        versions.append(m.captured(2));
    }
    versions.removeDuplicates();
    std::sort(versions.begin(), versions.end(), [](const QString &a, const QString &b) {
        return compareVersionsDesc(a, b) < 0;
    });
    return versions;
}

QStringList scanSubdirectoryVersions(const QString &dirPath)
{
    QStringList versions;
    QDir dir(dirPath);
    const QFileInfoList dirs = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    for (const QFileInfo &fi : dirs) {
        const QString name = fi.fileName().trimmed();
        if (kSimpleVersionRe.match(name).hasMatch()) {
            versions.append(name);
        }
    }
    versions.removeDuplicates();
    std::sort(versions.begin(), versions.end(), [](const QString &a, const QString &b) {
        return compareVersionsDesc(a, b) < 0;
    });
    return versions;
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
    refreshReleaseVersions();
}

void HttpUploadController::setLinkStm(LinkStm *linkStm)
{
    m_linkStm = linkStm;
}

void HttpUploadController::setJsonStorage(JsonStorage *storage)
{
    m_json = storage;
    loadNetworkSettings();
    if (m_json) {
        setCurrentMediaVersion(m_json->readString(QStringLiteral("currentMediaVersion"), QStringLiteral("—")));
    } else {
        setCurrentMediaVersion(QStringLiteral("—"));
    }
    refreshReleaseVersions();
}

bool HttpUploadController::hasVersionListChanged(const QStringList &oldList, const QStringList &newList)
{
    return oldList != newList;
}

void HttpUploadController::setCurrentMediaVersion(const QString &version)
{
    const QString v = version.trimmed().isEmpty() ? QStringLiteral("—") : version.trimmed();
    if (m_currentMediaVersion == v) {
        return;
    }
    m_currentMediaVersion = v;
    emit currentMediaVersionChanged();
}

void HttpUploadController::refreshReleaseVersions()
{
    const QString home = QDir::homePath();
    const QStringList newMain = scanSubdirectoryVersions(home + QStringLiteral("/releases/main"));
    const QStringList newMedia = scanSubdirectoryVersions(home + QStringLiteral("/releases/media"));
    const QStringList newCom = scanFirmwareHexVersions(home + QStringLiteral("/releases/com"), QStringLiteral("COM"));
    const QStringList newArg = scanFirmwareHexVersions(home + QStringLiteral("/releases/arg"), QStringLiteral("ARG"));
    const QStringList newGen = scanFirmwareHexVersions(home + QStringLiteral("/releases/gen"), QStringLiteral("GEN"));

    bool changed = false;
    if (hasVersionListChanged(m_availableMainVersions, newMain)) {
        m_availableMainVersions = newMain;
        changed = true;
    }
    if (hasVersionListChanged(m_availableMediaVersions, newMedia)) {
        m_availableMediaVersions = newMedia;
        changed = true;
    }
    if (hasVersionListChanged(m_availableComVersions, newCom)) {
        m_availableComVersions = newCom;
        changed = true;
    }
    if (hasVersionListChanged(m_availableArgVersions, newArg)) {
        m_availableArgVersions = newArg;
        changed = true;
    }
    if (hasVersionListChanged(m_availableGenVersions, newGen)) {
        m_availableGenVersions = newGen;
        changed = true;
    }

    if (changed) {
        emit releaseVersionsChanged();
    }
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
    const QString url = !m_publicBaseUrl.isEmpty()
            ? normalizedBaseUrl(m_publicBaseUrl)
            : QStringLiteral("http://%1:%2/")
                  .arg(m_listenAddress.isNull() ? QStringLiteral("127.0.0.1") : ipv4ToQString(m_listenAddress))
                  .arg(m_port);
    if (m_baseUrl == url) {
        return;
    }
    m_baseUrl = url;
    emit baseUrlChanged();
}

QHostAddress HttpUploadController::preferredListenAddress() const
{
    if (m_json) {
        const QString configured = m_json->readString(QStringLiteral("httpUploadListenAddress")).trimmed();
        if (!configured.isEmpty()) {
            const QHostAddress configuredAddr(configured);
            if (!configuredAddr.isNull()) {
                return configuredAddr;
            }
        }
    }
    const QStringList ips = localIpv4Addresses();
    if (ips.isEmpty()) {
        return QHostAddress(QHostAddress::LocalHost);
    }
    return QHostAddress(ips.first());
}

void HttpUploadController::loadNetworkSettings()
{
    m_publicBaseUrl.clear();
    m_trustProxyHeaders = false;
    if (!m_json) {
        return;
    }
    m_publicBaseUrl = normalizedBaseUrl(m_json->readString(QStringLiteral("httpUploadPublicBaseUrl")));
    m_trustProxyHeaders = parseBoolString(m_json->readString(QStringLiteral("httpUploadTrustProxyHeaders")));
}

bool HttpUploadController::invokeUploadFirewallGuard(const QString &action, QString *errorText) const
{
    const QFileInfo helper(QString::fromLatin1(kUploadFirewallGuardPath));
    if (!helper.exists()) {
        return true;
    }
    if (!helper.isExecutable()) {
        const QString msg = QString::fromUtf8("Скрипт управления firewall найден, но не исполняемый: %1")
                                    .arg(QString::fromLatin1(kUploadFirewallGuardPath));
        if (errorText) {
            *errorText = msg;
        }
        return false;
    }

    QProcess proc;
    const QStringList args = {
        QStringLiteral("-n"),
        QString::fromLatin1(kUploadFirewallGuardPath),
        action
    };
    proc.start(QStringLiteral("sudo"), args);
    if (!proc.waitForStarted(1000)) {
        const QString msg = QString::fromUtf8("Не удалось запустить helper firewall.");
        if (errorText) {
            *errorText = msg;
        }
        return false;
    }
    if (!proc.waitForFinished(5000)) {
        proc.kill();
        proc.waitForFinished(1000);
        const QString msg = QString::fromUtf8("Timeout вызова helper firewall.");
        if (errorText) {
            *errorText = msg;
        }
        return false;
    }
    if (proc.exitStatus() != QProcess::NormalExit || proc.exitCode() != 0) {
        const QString details = QString::fromUtf8(proc.readAllStandardError()).trimmed();
        const QString msg = details.isEmpty()
                ? QString::fromUtf8("Helper firewall завершился с ошибкой.")
                : QString::fromUtf8("Helper firewall завершился с ошибкой: %1").arg(details);
        if (errorText) {
            *errorText = msg;
        }
        return false;
    }
    return true;
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

bool HttpUploadController::isAuthorizedClient(const QHostAddress &peer) const
{
    if (peer.isNull()) {
        return false;
    }
    if (m_authorizedClientAddress.isNull()) {
        return true;
    }
    return peer == m_authorizedClientAddress;
}

QHostAddress HttpUploadController::effectiveClientAddress() const
{
    if (!m_client) {
        return QHostAddress();
    }
    const QHostAddress peer = m_client->peerAddress();
    if (!m_trustProxyHeaders || !peer.isLoopback()) {
        return peer;
    }

    const QString forwarded = m_requestHeaders.value(QStringLiteral("x-forwarded-for")).trimmed();
    if (forwarded.isEmpty()) {
        return peer;
    }

    const QString first = forwarded.split(QLatin1Char(','), Qt::SkipEmptyParts).value(0).trimmed();
    if (first.isEmpty()) {
        return peer;
    }

    const QHostAddress forwardedAddr(first);
    return forwardedAddr.isNull() ? peer : forwardedAddr;
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

    loadNetworkSettings();
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
    m_authorizedClientAddress = QHostAddress();

    QDir().mkpath(effectiveUploadDir());
    emit uploadSavePathChanged();

    m_listenAddress = preferredListenAddress();
    if (!m_server->listen(m_listenAddress, static_cast<quint16>(m_port))) {
        setLastError(QString::fromUtf8("Не удалось занять порт %1: %2")
                             .arg(m_port)
                             .arg(m_server->errorString()));
        m_listenAddress = QHostAddress();
        m_sessionToken.clear();
        emit sessionTokenChanged();
        return;
    }

    QString fwError;
    if (!invokeUploadFirewallGuard(QStringLiteral("open"), &fwError)) {
        if (m_server->isListening()) {
            m_server->close();
        }
        m_listenAddress = QHostAddress();
        m_sessionToken.clear();
        emit sessionTokenChanged();
        setLastError(fwError);
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
    QString fwError;
    if (!invokeUploadFirewallGuard(QStringLiteral("close"), &fwError)) {
        qWarning() << "HttpUploadController:" << fwError;
    }

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
    m_uploadInProgress = false;
    m_uploadProgress = 0.0;
    m_uploadStatusText.clear();
    emit uploadProgressChanged();
    if (m_server->isListening()) {
        m_server->close();
    }
    m_listenAddress = QHostAddress();
    m_authorizedClientAddress = QHostAddress();
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
    if (m_client && m_client->state() != QAbstractSocket::ConnectedState) {
        m_client->deleteLater();
        m_client = nullptr;
        m_rxBuffer.clear();
        m_headerComplete = false;
        m_contentLength = -1;
        m_requestHeaders.clear();
    }

    if (m_client) {
        // Во время приёма большого файла браузер может открыть дополнительное соединение
        // (например, favicon/параллельный запрос). Не отвечаем 503, оставляем его в pending,
        // обработаем после освобождения активного m_client.
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

    // Браузер может открыть "пустой" keep-alive сокет и не отправлять запрос.
    // Чтобы не блокировать очередь pending-коннектов, освобождаем такой сокет по таймауту.
    QPointer<QTcpSocket> acceptedSock(m_client);
    QTimer::singleShot(2500, this, [this, acceptedSock]() {
        if (!acceptedSock) {
            return;
        }
        if (m_client == acceptedSock && m_rxBuffer.isEmpty() && !m_headerComplete) {
            releaseClientSocket();
        }
    });
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

void HttpUploadController::releaseClientSocket()
{
    if (m_client) {
        QTcpSocket *sock = m_client;
        m_client = nullptr;
        sock->disconnect(this);
        sock->disconnectFromHost();
        sock->deleteLater();
    }
    m_rxBuffer.clear();
    m_headerComplete = false;
    m_contentLength = -1;
    m_requestHeaders.clear();

    if (m_server && m_server->hasPendingConnections()) {
        QMetaObject::invokeMethod(this, "onNewConnection", Qt::QueuedConnection);
    }
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
    QString serialHtml = QStringLiteral("—");
    QString typeHtml = QStringLiteral("—");
    if (m_json) {
        const QString s = m_json->readString(QStringLiteral("serialNumber"), QString()).trimmed();
        if (!s.isEmpty()) {
            serialHtml = s.toHtmlEscaped();
        }
        const QString t = m_json->readString(QStringLiteral("deviceType"), QString()).trimmed();
        if (!t.isEmpty()) {
            typeHtml = t.toHtmlEscaped();
        }
    }
    const QString html = QStringLiteral(
            "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, "
            "initial-scale=1\"><title>Загрузка файлов</title></head><body>"
            "<h1>Загрузка файлов</h1>"
            "<p><strong>Серийный номер:</strong> %3<br><strong>Тип аппарата:</strong> %4</p>"
            "<p><strong>Важно:</strong> эта ссылка действует только для текущей сессии и только для устройства, которое первым открыло страницу. После перезапуска приёма или таймаута откройте страницу заново.</p>"
            "<p>Выберите файл обновления в формате <b>имя-a.b-c.d-e.zip</b> (например: onyx-5.6-3.4-1.zip)</p>"
            "<form id=\"uploadForm\" method=\"post\" action=\"/upload\" enctype=\"multipart/form-data\">"
            "<input type=\"hidden\" name=\"token\" value=\"%1\">"
            "<p>"
            "<input id=\"fileInput\" type=\"file\" name=\"file\" multiple style=\"display:none;\">"
            "<button id=\"pickFileBtn\" type=\"button\">Выбрать файл</button> "
            "<span id=\"selectedFiles\" style=\"color:#555;\">Файл не выбран</span>"
            "</p>"
            "<p><button type=\"submit\">Отправить</button></p>"
            "</form>"
            "<div id=\"progressWrap\" style=\"display:none;max-width:520px;\">"
            "<div style=\"height:10px;background:#ddd;border-radius:5px;overflow:hidden;\">"
            "<div id=\"progressBar\" style=\"height:10px;width:0%%;background:#1976d2;\"></div>"
            "</div>"
            "<p id=\"progressText\" style=\"margin:6px 0 0 0;color:#333;\">0%%</p>"
            "</div>"
            "<div id=\"result\"></div>"
            "<hr><h2>Передача файла с устройства</h2>"
            "<p><a href=\"%2\">Скачать logFile.txt</a></p>"
            "<script>"
            "(function(){"
            "var form=document.getElementById('uploadForm');"
            "if(!form) return;"
            "var fileInput=document.getElementById('fileInput');"
            "var pickBtn=document.getElementById('pickFileBtn');"
            "var selectedFiles=document.getElementById('selectedFiles');"
            "if(pickBtn && fileInput){"
            "pickBtn.addEventListener('click',function(){ fileInput.click(); });"
            "fileInput.addEventListener('change',function(){"
            "if(!selectedFiles) return;"
            "var n=(fileInput.files&&fileInput.files.length)?fileInput.files.length:0;"
            "if(n===0){ selectedFiles.textContent='Файл не выбран'; return; }"
            "selectedFiles.textContent='Выбран ' + fileInput.files[0].name;"
            "});"
            "}"
            "form.addEventListener('submit',function(ev){"
            "ev.preventDefault();"
            "var res=document.getElementById('result');"
            "var wrap=document.getElementById('progressWrap');"
            "var bar=document.getElementById('progressBar');"
            "var txt=document.getElementById('progressText');"
            "if(!fileInput || !fileInput.files || fileInput.files.length===0){"
            "if(res){res.innerHTML='<p>Файлы не выбраны</p>';}"
            "if(wrap){wrap.style.display='none';}"
            "return;"
            "}"
            "var nameRe=/.+-\\d+\\.\\d+-\\d+\\.\\d+-\\d+\\.zip$/i;"
            "for(var i=0;i<fileInput.files.length;i++){"
            "var fname=(fileInput.files[i]&&fileInput.files[i].name)?fileInput.files[i].name:'';"
            "if(!nameRe.test(fname)){"
            "if(res){res.innerHTML='<p>Имя файла должно быть в формате name-a.b-c.d-e.zip</p>';}"
            "if(wrap){wrap.style.display='none';}"
            "return;"
            "}"
            "}"
            "var fd=new FormData(form);"
            "wrap.style.display='block';"
            "bar.style.width='0%';"
            "txt.textContent='0%';"
            "res.innerHTML='';"
            "var xhr=new XMLHttpRequest();"
            "xhr.open('POST','/upload',true);"
            "xhr.upload.onprogress=function(e){"
            "if(!e.lengthComputable) return;"
            "var p=Math.max(0,Math.min(100,Math.round((e.loaded/e.total)*100)));"
            "bar.style.width=p+'%';"
            "txt.textContent='Отправка: '+p+'%';"
            "};"
            "xhr.onload=function(){"
            "res.innerHTML=xhr.responseText||'';"
            "if(xhr.status>=200 && xhr.status<300){"
            "bar.style.width='100%'; txt.textContent='Отправка завершена';"
            "}else{"
            "txt.textContent='Ошибка отправки ('+xhr.status+')';"
            "}"
            "};"
            "xhr.onerror=function(){ txt.textContent='Ошибка сети при отправке'; };"
            "xhr.send(fd);"
            "});"
            "})();"
            "</script>"
            "</body></html>")
                                 .arg(token, downloadHref, serialHtml, typeHtml);
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

QString HttpUploadController::normalizeRelPath(const QString &rawRelPath)
{
    const QString clean = QDir::cleanPath(rawRelPath.trimmed());
    if (clean.isEmpty() || clean == QStringLiteral(".")
        || clean.startsWith(QLatin1Char('/'))
        || clean.startsWith(QStringLiteral("../"))
        || clean.contains(QStringLiteral("/../"))) {
        return QString();
    }
    return clean;
}

bool HttpUploadController::copyFileReplace(const QString &srcPath, const QString &dstPath, QString *errorMessage)
{
    QFileInfo srcFi(srcPath);
    if (!srcFi.exists() || !srcFi.isFile()) {
        *errorMessage = QStringLiteral("file not found");
        return false;
    }
    if (!QDir().mkpath(QFileInfo(dstPath).absolutePath())) {
        *errorMessage = QStringLiteral("mkdir");
        return false;
    }
    if (QFile::exists(dstPath) && !QFile::remove(dstPath)) {
        *errorMessage = QStringLiteral("remove old");
        return false;
    }
    if (!QFile::copy(srcPath, dstPath)) {
        *errorMessage = QStringLiteral("copy");
        return false;
    }
    QFile::setPermissions(dstPath, QFile::permissions(srcPath));
    return true;
}

bool HttpUploadController::copyDirectoryContentsReplace(const QString &srcDirPath, const QString &dstDirPath, QString *errorMessage)
{
    QDir srcDir(srcDirPath);
    if (!srcDir.exists()) {
        *errorMessage = QStringLiteral("source dir missing");
        return false;
    }

    if (!QDir().mkpath(dstDirPath)) {
        *errorMessage = QStringLiteral("mkdir target");
        return false;
    }

    QDirIterator it(srcDirPath, QDir::AllEntries | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        const QString srcPath = it.next();
        const QFileInfo srcFi(srcPath);
        const QString rel = srcDir.relativeFilePath(srcPath);
        const QString dstPath = QDir(dstDirPath).filePath(rel);
        if (srcFi.isDir()) {
            if (!QDir().mkpath(dstPath)) {
                *errorMessage = QStringLiteral("mkdir child");
                return false;
            }
            continue;
        }
        if (srcFi.isFile()) {
            QString copyErr;
            if (!copyFileReplace(srcPath, dstPath, &copyErr)) {
                *errorMessage = QStringLiteral("copy file");
                return false;
            }
        }
    }
    return true;
}

void HttpUploadController::setDetectedReleaseInfo(const QString &releaseVer,
                                                  const QString &binaryVer,
                                                  const QString &mediaVer,
                                                  const QString &comVer,
                                                  const QString &argVer,
                                                  const QString &genVer)
{
    if (m_detectedReleaseVersion == releaseVer
        && m_detectedBinaryVersion == binaryVer
        && m_detectedMediaVersion == mediaVer
        && m_detectedComVersion == comVer
        && m_detectedArgVersion == argVer
        && m_detectedGenVersion == genVer) {
        return;
    }
    m_detectedReleaseVersion = releaseVer;
    m_detectedBinaryVersion = binaryVer;
    m_detectedMediaVersion = mediaVer;
    m_detectedComVersion = comVer;
    m_detectedArgVersion = argVer;
    m_detectedGenVersion = genVer;
    emit detectedReleaseChanged();
}

bool HttpUploadController::processReleaseArchiveBytes(const QString &sourceFileName,
                                                      const QByteArray &archiveBytes,
                                                      QString *errorMessage)
{
    const QString baseName = QFileInfo(sourceFileName).fileName();
    const QRegularExpressionMatch fileMatch = kReleaseZipNameRe.match(baseName);
    if (!fileMatch.hasMatch()) {
        *errorMessage = QStringLiteral("invalid release name");
        return false;
    }

    const QString releaseVersion = QStringLiteral("%1.%2-%3.%4-%5")
                                   .arg(fileMatch.captured(1),
                                        fileMatch.captured(2),
                                        fileMatch.captured(3),
                                        fileMatch.captured(4),
                                        fileMatch.captured(5));
    const QString fallbackBinaryVersion = QStringLiteral("%1.%2")
                                          .arg(fileMatch.captured(1), fileMatch.captured(2));
    const QString fallbackMediaVersion = QStringLiteral("%1.%2")
                                         .arg(fileMatch.captured(3), fileMatch.captured(4));

    QTemporaryDir tmpRoot;
    if (!tmpRoot.isValid()) {
        *errorMessage = QStringLiteral("tmp");
        return false;
    }
    const QString archivePath = tmpRoot.path() + QStringLiteral("/incoming.zip");
    QFile af(archivePath);
    if (!af.open(QIODevice::WriteOnly) || af.write(archiveBytes) != archiveBytes.size()) {
        *errorMessage = QStringLiteral("write archive");
        return false;
    }
    af.close();

    const QString unpackRoot = tmpRoot.path() + QStringLiteral("/unpacked");
    if (!QDir().mkpath(unpackRoot)) {
        *errorMessage = QStringLiteral("mkdir unpack");
        return false;
    }

    const QString unzipProgram = resolveUnzipProgramPath();
    if (unzipProgram.isEmpty()) {
        *errorMessage = QStringLiteral("unzip");
        return false;
    }

    auto tryUnzip = [&](const QStringList &args, QString *stderrOut) -> bool {
        QProcess unzipProc;
        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
        const QString oldPath = env.value(QStringLiteral("PATH"));
        env.insert(QStringLiteral("PATH"),
                   oldPath.isEmpty()
                   ? QStringLiteral("/usr/local/bin:/usr/bin:/bin")
                   : oldPath + QStringLiteral(":/usr/local/bin:/usr/bin:/bin"));
        unzipProc.setProcessEnvironment(env);
        unzipProc.start(unzipProgram, args);
        if (!unzipProc.waitForStarted(2000)) {
            if (stderrOut) {
                *stderrOut = QStringLiteral("unzip start failed: %1").arg(unzipProgram);
            }
            return false;
        }
        if (!unzipProc.waitForFinished(120000)) {
            if (stderrOut) {
                *stderrOut = QStringLiteral("unzip timeout");
            }
            return false;
        }
        const QString stderrText = QString::fromUtf8(unzipProc.readAllStandardError());
        if (stderrOut) {
            *stderrOut = stderrText.trimmed();
        }
        return unzipProc.exitCode() == 0;
    };

    QString unzipErr;
    if (!tryUnzip(QStringList()
                  << QStringLiteral("-P") << QString::fromUtf8(kReleaseZipPassword)
                  << QStringLiteral("-o") << archivePath
                  << QStringLiteral("-d") << unpackRoot,
                  &unzipErr)) {
        QDir(unpackRoot).removeRecursively();
        QDir().mkpath(unpackRoot);
        if (!tryUnzip(QStringList()
                      << QStringLiteral("-o") << archivePath
                      << QStringLiteral("-d") << unpackRoot,
                      &unzipErr)) {
            *errorMessage = QStringLiteral("unzip");
            return false;
        }
    }

    QString payloadRoot = selectPayloadRoot(unpackRoot);
    QString manifestPath = QDir(payloadRoot).filePath(QStringLiteral("update-manifest.json"));
    if (!QFileInfo::exists(manifestPath)) {
        const QString foundManifest = findManifestPathRecursive(unpackRoot);
        if (!foundManifest.isEmpty()) {
            manifestPath = foundManifest;
            payloadRoot = QFileInfo(foundManifest).absolutePath();
        }
    }

    QFile mf(manifestPath);
    if (!mf.open(QIODevice::ReadOnly)) {
        *errorMessage = QStringLiteral("manifest missing");
        return false;
    }
    const QJsonDocument manifestDoc = QJsonDocument::fromJson(mf.readAll());
    mf.close();
    if (!manifestDoc.isObject()) {
        *errorMessage = QStringLiteral("manifest invalid");
        return false;
    }
    const QJsonObject manifestObj = manifestDoc.object();

    QJsonArray deployPaths = manifestObj.value(QStringLiteral("deployPaths")).toArray();
    if (deployPaths.isEmpty()) {
        // Для ручной загрузки допускаем минимальный манифест без deployPaths:
        // берём все файлы payload, кроме update-manifest.json.
        QDirIterator it(payloadRoot, QDir::Files, QDirIterator::Subdirectories);
        QDir root(payloadRoot);
        QStringList allFiles;
        while (it.hasNext()) {
            const QString rel = root.relativeFilePath(it.next());
            if (rel != QStringLiteral("update-manifest.json")) {
                allFiles.append(rel);
            }
        }
        std::sort(allFiles.begin(), allFiles.end());
        for (const QString &rel : allFiles) {
            deployPaths.append(rel);
        }
        if (deployPaths.isEmpty()) {
            *errorMessage = QStringLiteral("manifest deployPaths empty");
            return false;
        }
    }

    const QString expectedPayloadSha256 =
        manifestObj.value(QStringLiteral("payloadSha256")).toString().trimmed().toLower();
    if (expectedPayloadSha256.isEmpty()) {
        *errorMessage = QStringLiteral("manifest payload sha missing");
        return false;
    }
    const QString actualPayloadSha256 = payloadSha256Hex(payloadRoot).trimmed().toLower();
    if (actualPayloadSha256.isEmpty()) {
        *errorMessage = QStringLiteral("payload sha calc");
        return false;
    }
    if (expectedPayloadSha256 != actualPayloadSha256) {
        *errorMessage = QStringLiteral("payload sha mismatch");
        return false;
    }

    QString binaryVersion = manifestObj.value(QStringLiteral("binaryVersion")).toString().trimmed();
    if (binaryVersion.isEmpty()) {
        binaryVersion = fallbackBinaryVersion;
    }
    QString mediaVersion = manifestObj.value(QStringLiteral("mediaVersion")).toString().trimmed();
    if (mediaVersion.isEmpty()) {
        mediaVersion = fallbackMediaVersion;
    }

    QString fwCom;
    QString fwArg;
    QString fwGen;
    const QJsonObject fwObj = manifestObj.value(QStringLiteral("firmware")).toObject();
    if (!fwObj.isEmpty()) {
        fwCom = fwObj.value(QStringLiteral("com")).toString().trimmed();
        fwArg = fwObj.value(QStringLiteral("arg")).toString().trimmed();
        fwGen = fwObj.value(QStringLiteral("gen")).toString().trimmed();
    }

    const QString home = QDir::homePath();
    const QString mainRoot = home + QStringLiteral("/releases/main/") + binaryVersion;
    const QString mediaRoot = home + QStringLiteral("/releases/media/") + mediaVersion;
    const QString comRoot = home + QStringLiteral("/releases/com");
    const QString argRoot = home + QStringLiteral("/releases/arg");
    const QString genRoot = home + QStringLiteral("/releases/gen");

    for (const QJsonValue &v : deployPaths) {
        const QString rel = normalizeRelPath(v.toString());
        if (rel.isEmpty()) {
            *errorMessage = QStringLiteral("manifest path invalid");
            return false;
        }
        const QString srcPath = QDir(payloadRoot).filePath(rel);
        if (!QFileInfo::exists(srcPath)) {
            *errorMessage = QStringLiteral("manifest path missing");
            return false;
        }

        const QString base = QFileInfo(rel).fileName();
        const QRegularExpressionMatch fwMatch = kFirmwareFileRe.match(base);
        QString dstPath;
        if (base == QStringLiteral("UserInterface")) {
            dstPath = QDir(mainRoot).filePath(QStringLiteral("UserInterface"));
        } else if (fwMatch.hasMatch()) {
            const QString kind = fwMatch.captured(1).toLower();
            const QString ver = fwMatch.captured(2);
            if (kind == QStringLiteral("com")) {
                dstPath = QDir(comRoot).filePath(base);
                if (fwCom.isEmpty()) {
                    fwCom = ver;
                }
            } else if (kind == QStringLiteral("arg")) {
                dstPath = QDir(argRoot).filePath(base);
                if (fwArg.isEmpty()) {
                    fwArg = ver;
                }
            } else if (kind == QStringLiteral("gen")) {
                dstPath = QDir(genRoot).filePath(base);
                if (fwGen.isEmpty()) {
                    fwGen = ver;
                }
            }
        } else {
            dstPath = QDir(mediaRoot).filePath(rel);
        }

        QString copyErr;
        if (!copyFileReplace(srcPath, dstPath, &copyErr)) {
            *errorMessage = QStringLiteral("copy failed");
            return false;
        }
    }

    setDetectedReleaseInfo(releaseVersion, binaryVersion, mediaVersion, fwCom, fwArg, fwGen);
    refreshReleaseVersions();
    if (m_json) {
        m_json->saveString(QStringLiteral("currentBinaryVersion"), binaryVersion);
        m_json->saveString(QStringLiteral("currentMediaVersion"), mediaVersion);
    }
    setCurrentMediaVersion(mediaVersion);
    return true;
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
    bool sawInvalidReleaseZipName = false;

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
                // Разрешаем отправлять вместе с архивом сопутствующие файлы,
                // но обрабатываем только zip-релизы формата name-a.b-c.d-e.zip.
                if (!safe.endsWith(QStringLiteral(".zip"), Qt::CaseInsensitive)) {
                    if (isClosing) {
                        break;
                    }
                    pos = afterBoundary;
                    if (pos + 1 < body.size() && body[pos] == '\r' && body[pos + 1] == '\n') {
                        pos += 2;
                    } else if (pos < body.size() && body[pos] == '\n') {
                        ++pos;
                    }
                    continue;
                }
                if (!kReleaseZipNameRe.match(safe).hasMatch()) {
                    sawInvalidReleaseZipName = true;
                    if (isClosing) {
                        break;
                    }
                    pos = afterBoundary;
                    if (pos + 1 < body.size() && body[pos] == '\r' && body[pos + 1] == '\n') {
                        pos += 2;
                    } else if (pos < body.size() && body[pos] == '\n') {
                        ++pos;
                    }
                    continue;
                }
                QString processError;
                if (!processReleaseArchiveBytes(safe, partBody, &processError)) {
                    if (processError == QStringLiteral("invalid release name")) {
                        *errorMessage = QStringLiteral("invalid release name");
                    } else if (processError == QStringLiteral("manifest missing")) {
                        *errorMessage = QStringLiteral("manifest-missing");
                    } else if (processError == QStringLiteral("manifest invalid")) {
                        *errorMessage = QStringLiteral("manifest-invalid");
                    } else if (processError == QStringLiteral("manifest deployPaths empty")) {
                        *errorMessage = QStringLiteral("manifest-deploypaths");
                    } else if (processError == QStringLiteral("manifest payload sha missing")) {
                        *errorMessage = QStringLiteral("manifest-sha-missing");
                    } else if (processError == QStringLiteral("manifest path invalid")
                               || processError == QStringLiteral("manifest path missing")) {
                        *errorMessage = QStringLiteral("manifest-path");
                    } else if (processError == QStringLiteral("payload sha calc")
                               || processError == QStringLiteral("payload sha mismatch")) {
                        *errorMessage = QStringLiteral("checksum");
                    } else if (processError == QStringLiteral("unzip")) {
                        *errorMessage = QStringLiteral("unzip");
                    } else {
                        *errorMessage = QStringLiteral("write");
                    }
                    return false;
                }
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

    if (!m_active || m_sessionToken.isEmpty() || formToken != m_sessionToken) {
        *errorMessage = QStringLiteral("token");
        return false;
    }
    if (*filesSaved == 0) {
        *errorMessage = sawInvalidReleaseZipName
                ? QStringLiteral("invalid release name")
                : QStringLiteral("no files");
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
        const QHostAddress peerAddress = effectiveClientAddress();
        const QString peerText = peerAddress.toString();

        if (m_method == QStringLiteral("GET")) {
            if (m_path == QStringLiteral("/") || m_path.isEmpty()) {
                if (m_authorizedClientAddress.isNull()) {
                    m_authorizedClientAddress = peerAddress;
                    qWarning() << "HttpUploadController: session bound to client" << peerText;
                } else if (!isAuthorizedClient(peerAddress)) {
                    qWarning() << "HttpUploadController: rejected GET from unauthorized client" << peerText;
                    sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                                   QStringLiteral("<p>Сессия уже открыта на другом устройстве.</p>"));
                    releaseClientSocket();
                    return;
                }
                sendHttpResponse(m_client, 200, "text/html; charset=utf-8", buildUploadPageHtml());
            } else if (m_path.startsWith(QStringLiteral("/download/logFile.txt"))) {
                if (!isAuthorizedClient(peerAddress)) {
                    qWarning() << "HttpUploadController: rejected log download from unauthorized client" << peerText;
                    sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                                   QStringLiteral("<p>Скачивание доступно только с устройства, открывшего сессию.</p>"));
                } else if (!isValidTokenInPath(QString::fromLatin1(parts[1]))) {
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
            releaseClientSocket();
            return;
        }

        if (m_method != QStringLiteral("POST")) {
            sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"), QStringLiteral("<p>Метод не поддерживается</p>"));
            releaseClientSocket();
            return;
        }

        if (m_path != QStringLiteral("/upload")) {
            sendSimpleHtml(m_client, 404, QStringLiteral("Не найдено"), QStringLiteral("<p>Страница не найдена</p>"));
            releaseClientSocket();
            return;
        }
        if (!m_active || m_sessionToken.isEmpty()) {
            qWarning() << "HttpUploadController: rejected upload without active session from" << peerText;
            sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                           QStringLiteral("<p>Сессия загрузки не активна. Откройте страницу заново с устройства.</p>"));
            releaseClientSocket();
            return;
        }
        if (!isAuthorizedClient(peerAddress)) {
            qWarning() << "HttpUploadController: rejected upload from unauthorized client" << peerText;
            sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                           QStringLiteral("<p>Загрузка доступна только с устройства, открывшего сессию.</p>"));
            releaseClientSocket();
            return;
        }

        const QString cl = m_requestHeaders.value(QStringLiteral("content-length"));
        if (cl.isEmpty()) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Нужен заголовок Content-Length</p>"));
            releaseClientSocket();
            return;
        }
        bool okLen = false;
        m_contentLength = cl.toLongLong(&okLen);
        if (!okLen || m_contentLength < 0 || m_contentLength > kMaxBodyBytes) {
            sendSimpleHtml(m_client, 413, QStringLiteral("Слишком большой"),
                           QStringLiteral("<p>Размер запроса превышает допустимый</p>"));
            releaseClientSocket();
            return;
        }
        m_uploadInProgress = true;
        m_uploadProgress = 0.0;
        m_uploadStatusText = QString::fromUtf8("Получение файла...");
        emit uploadProgressChanged();
    }

    // body
    if (m_contentLength < 0) {
        return;
    }
    if (m_rxBuffer.size() > m_contentLength) {
        sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Лишние данные в теле запроса</p>"));
        releaseClientSocket();
        return;
    }
    if (m_rxBuffer.size() < m_contentLength) {
        if (m_contentLength > 0 && m_uploadInProgress) {
            const double p = static_cast<double>(m_rxBuffer.size()) / static_cast<double>(m_contentLength);
            m_uploadProgress = p;
            if (m_uploadProgress < 0.0) m_uploadProgress = 0.0;
            if (m_uploadProgress > 1.0) m_uploadProgress = 1.0;
            m_uploadStatusText = QString::fromUtf8("Получение файла: %1%")
                                 .arg(QString::number(m_uploadProgress * 100.0, 'f', 0));
            emit uploadProgressChanged();
        }
        return;
    }

    const QByteArray body = m_rxBuffer.left(static_cast<int>(m_contentLength));
    m_rxBuffer.clear();

    const QString ct = m_requestHeaders.value(QStringLiteral("content-type"));
    if (!ct.contains(QStringLiteral("multipart/form-data"), Qt::CaseInsensitive)) {
        sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Ожидается multipart/form-data</p>"));
        releaseClientSocket();
        return;
    }

    int nFiles = 0;
    QString err;
    if (!parseMultipartAndSave(body, ct, &nFiles, &err)) {
        m_uploadInProgress = false;
        m_uploadProgress = 0.0;
        m_uploadStatusText = QString::fromUtf8("Ошибка загрузки");
        emit uploadProgressChanged();
        if (err == QStringLiteral("token")) {
            sendSimpleHtml(m_client, 403, QStringLiteral("Доступ запрещён"),
                           QStringLiteral("<p>Неверный или устаревший токен. Откройте страницу снова с устройства.</p>"));
        } else if (err == QStringLiteral("no files")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Файлы не выбраны</p>"));
        } else if (err == QStringLiteral("too many files")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"), QStringLiteral("<p>Слишком много файлов за один раз</p>"));
        } else if (err == QStringLiteral("invalid release name")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Имя файла должно быть в формате name-a.b-c.d-e.zip</p>"));
        } else if (err == QStringLiteral("manifest-missing")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>В архиве не найден update-manifest.json</p>"));
        } else if (err == QStringLiteral("manifest-invalid")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>update-manifest.json повреждён или не является JSON-объектом</p>"));
        } else if (err == QStringLiteral("manifest-deploypaths")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>В архиве нет файлов для раскладки (deployPaths пуст и payload пуст)</p>"));
        } else if (err == QStringLiteral("manifest-sha-missing")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>В update-manifest.json отсутствует поле payloadSha256</p>"));
        } else if (err == QStringLiteral("manifest-path")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Пути из update-manifest.json некорректны или отсутствуют в payload</p>"));
        } else if (err == QStringLiteral("checksum")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Контрольная сумма payloadSha256 не прошла проверку</p>"));
        } else if (err == QStringLiteral("unzip")) {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Не удалось открыть zip-архив. Проверьте пароль/целостность архива.</p>"));
        } else {
            sendSimpleHtml(m_client, 400, QStringLiteral("Ошибка"),
                           QStringLiteral("<p>Не удалось разобрать данные формы</p>"));
        }
        releaseClientSocket();
        return;
    }

    emit filesReceived(nFiles);
    m_uploadInProgress = false;
    m_uploadProgress = 1.0;
    m_uploadStatusText = QString::fromUtf8("Загрузка завершена");
    emit uploadProgressChanged();
    sendSimpleHtml(m_client, 200, QStringLiteral("Готово"),
                   QStringLiteral("<p>Успешно загружено файлов: %1</p><p><a href=\"/\">Загрузить ещё</a></p>").arg(nFiles));
    releaseClientSocket();
}

void HttpUploadController::onClientReadyRead()
{
    if (!m_client) {
        return;
    }
    m_rxBuffer.append(m_client->readAll());
    tryProcessBuffer();
}

bool HttpUploadController::applyMainVersion(const QString &version)
{
    const QString v = version.trimmed();
    if (!kSimpleVersionRe.match(v).hasMatch()) {
        setLastError(QString::fromUtf8("Некорректная версия интерфейса"));
        return false;
    }

    const QString srcPath = QDir::homePath() + QStringLiteral("/releases/main/") + v + QStringLiteral("/UserInterface");
    const QString dstPath = QStringLiteral("/usr/share/qtpr/UserInterface");
    const QString bakPath = QStringLiteral("/usr/share/qtpr/UserInterface.bak");

    if (QFile::exists(dstPath)) {
        if (QFile::exists(bakPath) && !QFile::remove(bakPath)) {
            setLastError(QString::fromUtf8("Не удалось удалить старый backup UserInterface.bak"));
            return false;
        }
        if (!QFile::copy(dstPath, bakPath)) {
            setLastError(QString::fromUtf8("Не удалось создать backup UserInterface.bak"));
            return false;
        }
    }

    QString copyErr;
    if (!copyFileReplace(srcPath, dstPath, &copyErr)) {
        setLastError(QString::fromUtf8("Не удалось обновить модуль интерфейса (%1)").arg(copyErr));
        return false;
    }

    const QFileDevice::Permissions execPerms =
        QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ExeOwner |
        QFileDevice::ReadGroup | QFileDevice::ExeGroup |
        QFileDevice::ReadOther | QFileDevice::ExeOther;
    if (!QFile::setPermissions(dstPath, execPerms) || !QFileInfo(dstPath).isExecutable()) {
        setLastError(QString::fromUtf8("Не удалось выставить права на запуск для UserInterface"));
        return false;
    }

    if (m_json) {
        m_json->saveString(QStringLiteral("currentBinaryVersion"), v);
    }
    setLastError(QString());
    return true;
}

bool HttpUploadController::applyMediaVersion(const QString &version)
{
    const QString v = version.trimmed();
    if (!kSimpleVersionRe.match(v).hasMatch()) {
        setLastError(QString::fromUtf8("Некорректная версия медиафайлов"));
        return false;
    }

    const QString srcDir = QDir::homePath() + QStringLiteral("/releases/media/") + v;
    const QString dstDir = QDir::homePath() + QStringLiteral("/FOTEK");
    QString copyErr;
    if (!copyDirectoryContentsReplace(srcDir, dstDir, &copyErr)) {
        setLastError(QString::fromUtf8("Не удалось обновить медиафайлы"));
        return false;
    }

    if (m_json) {
        m_json->saveString(QStringLiteral("currentMediaVersion"), v);
    }
    setCurrentMediaVersion(v);
    setLastError(QString());
    return true;
}

void HttpUploadController::setMcFirmwareUpdateProgress(int progress)
{
    if (m_mcFirmwareUpdateProgress == progress) {
        return;
    }
    m_mcFirmwareUpdateProgress = progress;
    emit mcFirmwareUpdateProgressChanged();
}

void HttpUploadController::onMcFirmwareParseError(const QString &message)
{
    setMcFirmwareUpdateProgress(-1);
    setLastError(message);
}

bool HttpUploadController::applyMcFirmwareFromReleases(const QString &version, const QString &releasesSubdir,
                                                       const QString &filePrefixUpper, int mcUnitRaw)
{
    if (!m_linkStm) {
        setMcFirmwareUpdateProgress(-1);
        setLastError(QString::fromUtf8("Обновление МК недоступно"));
        return false;
    }
    const QString v = version.trimmed();
    if (v.isEmpty() || v == QStringLiteral("—")) {
        setMcFirmwareUpdateProgress(-1);
        setLastError(QString::fromUtf8("Не выбрана версия"));
        return false;
    }
    const QString path = QDir::homePath() + QStringLiteral("/releases/") + releasesSubdir + QLatin1Char('/')
            + filePrefixUpper + QLatin1Char('-') + v + QStringLiteral(".hex");
    if (!QFileInfo::exists(path)) {
        setMcFirmwareUpdateProgress(-1);
        setLastError(QString::fromUtf8("Файл не найден: %1").arg(path));
        return false;
    }
    const bool invoked = QMetaObject::invokeMethod(m_linkStm, "startFirmwareUpdateFromFile", Qt::QueuedConnection,
                                                   Q_ARG(QString, path),
                                                   Q_ARG(int, 0),
                                                   Q_ARG(QString, v),
                                                   Q_ARG(int, mcUnitRaw));
    if (!invoked) {
        setMcFirmwareUpdateProgress(-1);
        setLastError(QString::fromUtf8("Не удалось поставить обновление в очередь"));
        return false;
    }
    setMcFirmwareUpdateProgress(0);
    setLastError(QString());
    return true;
}

bool HttpUploadController::applyComVersion(const QString &version)
{
    return applyMcFirmwareFromReleases(version, QStringLiteral("com"), QStringLiteral("COM"),
                                       static_cast<int>(LinkStm::MC_COM));
}

bool HttpUploadController::applyArgVersion(const QString &version)
{
    return applyMcFirmwareFromReleases(version, QStringLiteral("arg"), QStringLiteral("ARG"),
                                       static_cast<int>(LinkStm::MC_ARG));
}

bool HttpUploadController::applyGenVersion(const QString &version)
{
    return applyMcFirmwareFromReleases(version, QStringLiteral("gen"), QStringLiteral("GEN"),
                                       static_cast<int>(LinkStm::MC_GEN));
}

bool HttpUploadController::restartDemo1UserService()
{
    setLastError(QString());
    QCoreApplication::exit(0);
    return true;
}
