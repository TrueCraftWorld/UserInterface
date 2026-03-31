#include "jsonstorage.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

JsonStorage::JsonStorage(QObject *parent, QVariantMap* initMap)
    : QObject{parent}
{
    QFileInfo info(JSON_FILE_NAME);
    QDir dir = info.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(dir.absolutePath());
    }

    // Одноразовая миграция со старого пути, если новый файл ещё не создан
    if (!QFile::exists(JSON_FILE_NAME) && QFile::exists(LEGACY_JSON_FILE_NAME)) {
        QFile::copy(LEGACY_JSON_FILE_NAME, JSON_FILE_NAME);
    }

    QFile jsonFile(JSON_FILE_NAME);
    if (QFile::exists(JSON_FILE_NAME) && jsonFile.open(QIODevice::ReadOnly)) {
        const QByteArray jsonData = jsonFile.readAll();
        m_document = QJsonDocument::fromJson(jsonData);
        m_object = m_document.object();
        jsonFile.close();
    } else {
        // Если файла нет или он не читается, создаём из дефолтной карты
        m_object = QJsonObject::fromVariantMap(*initMap);
        m_document.setObject(m_object);
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

    QFile jsonFile(JSON_FILE_NAME);
    if (!jsonFile.open(QIODevice::WriteOnly)) {
        // qDebug() << "не открывается json";
    }
    else {
        jsonFile.write(QJsonDocument(m_object).toJson(QJsonDocument::Indented));
        jsonFile.close();
//        qDebug() << "записали " << data << " в " << key;
    }
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
