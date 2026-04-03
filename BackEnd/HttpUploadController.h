#ifndef HTTPUPLOADCONTROLLER_H
#define HTTPUPLOADCONTROLLER_H

#include <QObject>
#include <QByteArray>
#include <QMap>
#include <QString>
#include <QTimer>
#include <QTcpServer>
#include <QTcpSocket>

class JsonStorage;

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

public:
    explicit HttpUploadController(QObject *parent = nullptr);

    void setJsonStorage(JsonStorage *storage);

    bool isActive() const { return m_active; }
    QString sessionToken() const { return m_sessionToken; }
    QString baseUrl() const { return m_baseUrl; }
    QString lastError() const { return m_lastError; }
    int listenPort() const { return m_port; }
    QString uploadSavePath() const;
    QString qrImagePath() const { return m_qrImagePath; }
    QString qrStatusText() const { return m_qrStatusText; }
    QString logDownloadUrl() const { return m_logDownloadUrl; }

    Q_INVOKABLE void startSession();
    Q_INVOKABLE void stopSession();
    Q_INVOKABLE QStringList localIpv4Addresses() const;

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
    void filesReceived(int count);

private slots:
    void onNewConnection();
    void onClientReadyRead();
    void onClientDisconnected();
    void onSessionTimeout();

private:
    void setActive(bool v);
    void setLastError(const QString &e);
    void updateBaseUrl();
    void tryProcessBuffer();
    void sendHttpResponse(QTcpSocket *socket, int statusCode, const QByteArray &contentType, const QByteArray &body);
    void sendFileDownloadResponse(QTcpSocket *socket, const QByteArray &downloadFileName, const QByteArray &body);
    void sendSimpleHtml(QTcpSocket *socket, int statusCode, const QString &title, const QString &bodyHtml);
    QByteArray buildUploadPageHtml() const;
    bool parseMultipartAndSave(const QByteArray &body, const QString &contentType, int *filesSaved, QString *errorMessage);

    static bool extractMultipartBoundary(const QString &contentType, QByteArray *boundaryPrefixOut);
    static QString sanitizeFileName(const QString &rawName);
    QString makeUniquePath(const QString &fileName) const;
    QString effectiveUploadDir() const;
    void updateQrCode();
    void updateLogDownloadUrl();
    bool isValidTokenInPath(const QString &path) const;
    QString resolveLogFilePath() const;

    JsonStorage *m_json = nullptr;
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
    int m_port = 57891;
    QString m_uploadDir; // из JSON или по умолчанию
    QTimer m_sessionTimer;

    static constexpr int kSessionTimeoutMs = 15 * 60 * 1000;
    static constexpr qint64 kMaxBodyBytes = 500LL * 1024 * 1024;
    static constexpr int kMaxFilesPerRequest = 20;
};

#endif // HTTPUPLOADCONTROLLER_H
