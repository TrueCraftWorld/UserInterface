#include "jsonstorage.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>
#include <QDebug>

namespace {

bool writeJsonObjectToFile(const QString &filePath, const QJsonObject &object)
{
    QFile jsonFile(filePath);
    if (!jsonFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "JsonStorage: failed to open" << filePath
                   << "for writing:" << jsonFile.errorString();
        return false;
    }

    const QByteArray jsonBytes = QJsonDocument(object).toJson(QJsonDocument::Indented);
    const qint64 written = jsonFile.write(jsonBytes);
    if (written != jsonBytes.size()) {
        qWarning() << "JsonStorage: failed to fully write" << filePath
                   << "- written" << written << "of" << jsonBytes.size()
                   << "bytes:" << jsonFile.errorString();
        jsonFile.close();
        return false;
    }

    jsonFile.close();
    return true;
}

} // namespace

JsonStorage::JsonStorage(QObject *parent, QVariantMap* initMap)
    : QObject{parent}
{
    QFileInfo info(JSON_FILE_NAME);
    QDir dir = info.absoluteDir();
    if (!dir.exists() && !dir.mkpath(dir.absolutePath())) {
        qWarning() << "JsonStorage: failed to create directory" << dir.absolutePath();
    }

    // Одноразовая миграция со старого пути, если новый файл ещё не создан
    if (!QFile::exists(JSON_FILE_NAME) && QFile::exists(LEGACY_JSON_FILE_NAME)) {
        if (!QFile::copy(LEGACY_JSON_FILE_NAME, JSON_FILE_NAME)) {
            qWarning() << "JsonStorage: failed to migrate legacy file from"
                       << LEGACY_JSON_FILE_NAME << "to" << JSON_FILE_NAME;
        }
    }

    QFile jsonFile(JSON_FILE_NAME);
    if (QFile::exists(JSON_FILE_NAME) && jsonFile.open(QIODevice::ReadOnly)) {
        const QByteArray jsonData = jsonFile.readAll();
        m_document = QJsonDocument::fromJson(jsonData);
        m_object = m_document.object();
        jsonFile.close();
    } else {
        // Если файла нет или он не читается, создаём из дефолтной карты
        if (initMap) {
            m_object = QJsonObject::fromVariantMap(*initMap);
        } else {
            qWarning() << "JsonStorage: initMap is null, starting with empty object";
            m_object = QJsonObject();
        }
        m_document.setObject(m_object);
        writeJsonObjectToFile(JSON_FILE_NAME, m_object);
    }

}

JsonStorage::~JsonStorage()
{
   // save();
}

void JsonStorage::save(QString key, QJsonValue data)
//template <typename T> void JsonStorage::save(QString key, T data)
{
    m_object[key] = data;
    m_document.setObject(m_object);

    QFileInfo info(JSON_FILE_NAME);
    QDir dir = info.absoluteDir();
    if (!dir.exists() && !dir.mkpath(dir.absolutePath())) {
        qWarning() << "JsonStorage: failed to create directory" << dir.absolutePath();
        return;
    }

    writeJsonObjectToFile(JSON_FILE_NAME, m_object);
}

bool JsonStorage::read(QString key, QJsonValue* data)
{
    if (!m_object.contains(key))
        return false;
    QJsonValue savedData = m_object[key];
    *data = savedData;
//    qDebug() << "в " << key << " лежит " << savedData.toInt();
    return true;
}

void JsonStorage::saveString(const QString& key, const QString& value)
{
    save(key, QJsonValue(value));
}

QString JsonStorage::readString(const QString& key, const QString& defaultValue) const
{
    if (!m_object.contains(key))
        return defaultValue;
    return m_object.value(key).toString(defaultValue);
}
