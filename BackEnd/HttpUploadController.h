#ifndef HTTPUPLOADCONTROLLER_H
#define HTTPUPLOADCONTROLLER_H

#include <QObject>
#include <QByteArray>
#include <QMap>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QTcpServer>
#include <QTcpSocket>

class JsonStorage;
class LinkStm;

/// Минимальный HTTP-приём файлов по Wi‑Fi (GET форма + POST multipart) для Qt 5.15.
class HttpUploadController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
    Q_PROPERTY(QString sessionToken READ sessionToken NOTIFY sessionTokenChanged)
    Q_PROPERTY(QString baseUrl READ baseUrl NOTIFY baseUrlChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(int listenPort READ listenPort NOTIFY listenPortChanged)
    Q_PROPERTY(QString uploadSavePath READ uploadSavePath NOTIFY uploadSavePathChanged)
    Q_PROPERTY(QString qrImagePath READ qrImagePath NOTIFY qrImagePathChanged)
    Q_PROPERTY(QString qrStatusText READ qrStatusText NOTIFY qrStatusTextChanged)
    Q_PROPERTY(QString logDownloadUrl READ logDownloadUrl NOTIFY logDownloadUrlChanged)
    Q_PROPERTY(bool uploadInProgress READ uploadInProgress NOTIFY uploadProgressChanged)
    Q_PROPERTY(double uploadProgress READ uploadProgress NOTIFY uploadProgressChanged)
    Q_PROPERTY(QString uploadStatusText READ uploadStatusText NOTIFY uploadProgressChanged)
    Q_PROPERTY(QString detectedReleaseVersion READ detectedReleaseVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString detectedBinaryVersion READ detectedBinaryVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString detectedMediaVersion READ detectedMediaVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString detectedComVersion READ detectedComVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString detectedArgVersion READ detectedArgVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString detectedGenVersion READ detectedGenVersion NOTIFY detectedReleaseChanged)
    Q_PROPERTY(QString currentMediaVersion READ currentMediaVersion NOTIFY currentMediaVersionChanged)
    Q_PROPERTY(QStringList availableMainVersions READ availableMainVersions NOTIFY releaseVersionsChanged)
    Q_PROPERTY(QStringList availableMediaVersions READ availableMediaVersions NOTIFY releaseVersionsChanged)
    Q_PROPERTY(QStringList availableComVersions READ availableComVersions NOTIFY releaseVersionsChanged)
    Q_PROPERTY(QStringList availableArgVersions READ availableArgVersions NOTIFY releaseVersionsChanged)
    Q_PROPERTY(QStringList availableGenVersions READ availableGenVersions NOTIFY releaseVersionsChanged)
    Q_PROPERTY(int mcFirmwareUpdateProgress READ mcFirmwareUpdateProgress NOTIFY mcFirmwareUpdateProgressChanged)

public:
    explicit HttpUploadController(QObject *parent = nullptr);

    void setJsonStorage(JsonStorage *storage);
    void setLinkStm(LinkStm *linkStm);

    bool isActive() const { return m_active; }
    QString sessionToken() const { return m_sessionToken; }
    QString baseUrl() const { return m_baseUrl; }
    QString lastError() const { return m_lastError; }
    int listenPort() const { return m_port; }
    QString uploadSavePath() const;
    QString qrImagePath() const { return m_qrImagePath; }
    QString qrStatusText() const { return m_qrStatusText; }
    QString logDownloadUrl() const { return m_logDownloadUrl; }
    bool uploadInProgress() const { return m_uploadInProgress; }
    double uploadProgress() const { return m_uploadProgress; }
    QString uploadStatusText() const { return m_uploadStatusText; }
    QString detectedReleaseVersion() const { return m_detectedReleaseVersion; }
    QString detectedBinaryVersion() const { return m_detectedBinaryVersion; }
    QString detectedMediaVersion() const { return m_detectedMediaVersion; }
    QString detectedComVersion() const { return m_detectedComVersion; }
    QString detectedArgVersion() const { return m_detectedArgVersion; }
    QString detectedGenVersion() const { return m_detectedGenVersion; }
    QString currentMediaVersion() const { return m_currentMediaVersion; }
    QStringList availableMainVersions() const { return m_availableMainVersions; }
    QStringList availableMediaVersions() const { return m_availableMediaVersions; }
    QStringList availableComVersions() const { return m_availableComVersions; }
    QStringList availableArgVersions() const { return m_availableArgVersions; }
    QStringList availableGenVersions() const { return m_availableGenVersions; }
    int mcFirmwareUpdateProgress() const { return m_mcFirmwareUpdateProgress; }

    Q_INVOKABLE void startSession();
    Q_INVOKABLE void stopSession();
    Q_INVOKABLE QStringList localIpv4Addresses() const;
    Q_INVOKABLE void refreshReleaseVersions();
    Q_INVOKABLE bool applyMainVersion(const QString &version);
    Q_INVOKABLE bool applyMediaVersion(const QString &version);
    Q_INVOKABLE bool applyComVersion(const QString &version);
    Q_INVOKABLE bool applyArgVersion(const QString &version);
    Q_INVOKABLE bool applyGenVersion(const QString &version);
    Q_INVOKABLE bool restartDemo1UserService();

public slots:
    void setMcFirmwareUpdateProgress(int progress);
    void onMcFirmwareParseError(const QString &message);

signals:
    void activeChanged();
    void sessionTokenChanged();
    void baseUrlChanged();
    void lastErrorChanged();
    void listenPortChanged();
    void uploadSavePathChanged();
    void qrImagePathChanged();
    void qrStatusTextChanged();
    void logDownloadUrlChanged();
    void uploadProgressChanged();
    void detectedReleaseChanged();
    void currentMediaVersionChanged();
    void releaseVersionsChanged();
    void filesReceived(int count);
    void mcFirmwareUpdateProgressChanged();

private slots:
    void onNewConnection();
    void onClientReadyRead();
    void onClientDisconnected();
    void onSessionTimeout();

private:
    void setActive(bool v);
    void setLastError(const QString &e);
    void updateBaseUrl();
    QHostAddress preferredListenAddress() const;
    QHostAddress effectiveClientAddress() const;
    void loadNetworkSettings();
    bool invokeUploadFirewallGuard(const QString &action, QString *errorText = nullptr) const;
    void tryProcessBuffer();
    void sendHttpResponse(QTcpSocket *socket, int statusCode, const QByteArray &contentType, const QByteArray &body);
    void sendFileDownloadResponse(QTcpSocket *socket, const QByteArray &downloadFileName, const QByteArray &body);
    void sendSimpleHtml(QTcpSocket *socket, int statusCode, const QString &title, const QString &bodyHtml);
    QByteArray buildUploadPageHtml() const;
    bool isAuthorizedClient(const QHostAddress &peer) const;
    bool parseMultipartAndSave(const QByteArray &body, const QString &contentType, int *filesSaved, QString *errorMessage);
    bool processReleaseArchiveBytes(const QString &sourceFileName, const QByteArray &archiveBytes, QString *errorMessage);
    static QString normalizeRelPath(const QString &rawRelPath);
    static bool copyFileReplace(const QString &srcPath, const QString &dstPath, QString *errorMessage);
    void releaseClientSocket();
    void setDetectedReleaseInfo(const QString &releaseVer,
                                const QString &binaryVer,
                                const QString &mediaVer,
                                const QString &comVer,
                                const QString &argVer,
                                const QString &genVer);

    static bool extractMultipartBoundary(const QString &contentType, QByteArray *boundaryPrefixOut);
    static QString sanitizeFileName(const QString &rawName);
    QString makeUniquePath(const QString &fileName) const;
    QString effectiveUploadDir() const;
    void updateQrCode();
    void updateLogDownloadUrl();
    bool isValidTokenInPath(const QString &path) const;
    QString resolveLogFilePath() const;
    static bool hasVersionListChanged(const QStringList &oldList, const QStringList &newList);
    static bool copyDirectoryContentsReplace(const QString &srcDirPath, const QString &dstDirPath, QString *errorMessage);
    void setCurrentMediaVersion(const QString &version);
    bool applyMcFirmwareFromReleases(const QString &version, const QString &releasesSubdir,
                                     const QString &filePrefixUpper, int mcUnitRaw);

    JsonStorage *m_json = nullptr;
    LinkStm *m_linkStm = nullptr;
    int m_mcFirmwareUpdateProgress = -1;
    QTcpServer *m_server = nullptr;
    QTcpSocket *m_client = nullptr;
    QByteArray m_rxBuffer;
    bool m_headerComplete = false;
    QString m_method;
    QString m_path;
    QMap<QString, QString> m_requestHeaders;
    qint64 m_contentLength = -1;
    bool m_active = false;
    QString m_sessionToken;
    QString m_baseUrl;
    QString m_lastError;
    QString m_qrImagePath;
    QString m_qrStatusText;
    QString m_logDownloadUrl;
    bool m_uploadInProgress = false;
    double m_uploadProgress = 0.0;
    QString m_uploadStatusText;
    QString m_detectedReleaseVersion;
    QString m_detectedBinaryVersion;
    QString m_detectedMediaVersion;
    QString m_detectedComVersion;
    QString m_detectedArgVersion;
    QString m_detectedGenVersion;
    QString m_currentMediaVersion;
    QStringList m_availableMainVersions;
    QStringList m_availableMediaVersions;
    QStringList m_availableComVersions;
    QStringList m_availableArgVersions;
    QStringList m_availableGenVersions;
    int m_port = 57891;
    QString m_uploadDir; // из JSON или по умолчанию
    QString m_publicBaseUrl;
    bool m_trustProxyHeaders = false;
    QHostAddress m_listenAddress;
    QHostAddress m_authorizedClientAddress;
    QTimer m_sessionTimer;

    static constexpr int kSessionTimeoutMs = 15 * 60 * 1000;
    static constexpr qint64 kMaxBodyBytes = 500LL * 1024 * 1024;
    static constexpr int kMaxFilesPerRequest = 20;
};

#endif // HTTPUPLOADCONTROLLER_H
