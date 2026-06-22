#ifndef FEATUREUNLOCKCONTROLLER_H
#define FEATUREUNLOCKCONTROLLER_H

#include <QObject>
#include <QSet>
#include <QString>

class DataBaseReader;
class JsonStorage;
class KeyGenerator;

class FeatureUnlockController : public QObject
{
    Q_OBJECT

public:
    explicit FeatureUnlockController(QObject *parent = nullptr);

    void setJsonStorage(JsonStorage *storage);
    void setKeyGenerator(KeyGenerator *generator);
    void setDatabaseReader(DataBaseReader *reader);

    Q_INVOKABLE bool isKeyActivated(int keyNumber) const;
    Q_INVOKABLE bool isKeyRequirementMet(const QString &keyField) const;
    Q_INVOKABLE bool isScopeLocked(int scopeId) const;
    Q_INVOKABLE bool isModeLocked(int modeId) const;
    Q_INVOKABLE int tryActivateWithUnlockKey(int serialNumber,
                                             const QString &deviceType,
                                             const QString &key);
    Q_INVOKABLE void setKeyActivated(int keyNumber, bool activated);
    Q_INVOKABLE bool areAllKeysActivated(int maxKeyNumber = 9) const;
    Q_INVOKABLE void setAllKeysActivated(bool activated, int maxKeyNumber = 9);
    Q_INVOKABLE QString activatedKeysText() const;

    static QSet<int> parseKeyRequirement(const QString &keyField);
    static QString featureCodeForKey(int keyNumber);

signals:
    void activatedKeysChanged();

private:
    QSet<int> activatedKeys() const;
    void activateKey(int keyNumber);
    void deactivateKey(int keyNumber);
    void migrateLegacyEndoscopyFlag();
    QSet<int> discoverKeyNumbers() const;

    JsonStorage *m_jsonStorage = nullptr;
    KeyGenerator *m_keyGenerator = nullptr;
    DataBaseReader *m_dbReader = nullptr;
};

#endif // FEATUREUNLOCKCONTROLLER_H
