#ifndef JSONSTORAGE_H
#define JSONSTORAGE_H

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

class JsonStorage : public QObject
{
    Q_OBJECT
public:
    explicit JsonStorage(QObject *parent = nullptr, QVariantMap* initMap = nullptr);

    ~JsonStorage();


    void save(QString key, QJsonValue data);
    bool read(QString key, QJsonValue* data);

    Q_INVOKABLE void saveString(const QString& key, const QString& value);
    Q_INVOKABLE QString readString(const QString& key, const QString& defaultValue = QString()) const;
//    template <typename T> void save(QString key, T);
//    template <typename T> bool read(QString key, T*);

signals:

private:
    QJsonDocument m_document;
    QJsonObject m_object;

    // путь, где лежит документ с сохранениями
    // const QString JSON_FILE_NAME = "/home/kikorik/OnyxLog/save.json";
    const QString JSON_FILE_NAME = "/home/kikorik/FOTEK/OnyxLog/save.json";

};

#endif // JSONSTORAGE_H
