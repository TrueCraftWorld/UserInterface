#ifndef SOCKETMODEEDITOR_H
#define SOCKETMODEEDITOR_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

#include "socketmodel.h"

class SocketModeEditor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hasChanges READ hasChanges NOTIFY hasChangesChanged)
    Q_PROPERTY(QStringList modeNames READ modeNames NOTIFY parametersLoaded)
    Q_PROPERTY(QString socketName READ socketName NOTIFY parametersLoaded)
    Q_PROPERTY(QVariantMap currentMode READ currentMode NOTIFY currentParamsChanged)
    Q_PROPERTY(int currentModeIndex READ currentModeIndex WRITE setCurrentModeIndex NOTIFY currentModeIndexChanged)

public:
    explicit SocketModeEditor(SocketModel * model, QObject *parent = nullptr);

    Q_INVOKABLE void initialize(const QString& socket, const QString &mode);
    Q_INVOKABLE void loadModeParameters(int modeIndex);
    Q_INVOKABLE void updateCurrentParameters(const QVariantMap ms);
    Q_INVOKABLE void updateParameter(const QString& paramName, const QVariant& value);
    Q_INVOKABLE void commitChanges();
    Q_INVOKABLE void rollBack();

    Q_INVOKABLE QStringList modeNames() const;
    Q_INVOKABLE QVariantMap currentMode() const;
    Q_INVOKABLE QString socketName() const;
    Q_INVOKABLE int currentModeIndex() const;
    Q_INVOKABLE void setCurrentModeIndex(int index);

    Q_INVOKABLE bool hasChanges() const;

signals:
    void currentParamsChanged();
    void currentModeIndexChanged();
    void parametersLoaded();
    void editingFinished(bool);

    void hasChangesChanged();

private:
    bool checkChanges();

    int m_socketRow;
    QStringList m_modeNames;
    QVariantMap m_currentParameters;
    QString m_socketName;
    int m_currentModeIndex = -1;
    int m_originalModeIndex = -1;
    QVariantMap m_originalParameters;
    QVariantMap fetchModeParameters(int modeIndex);
    SocketModel * m_model;

    bool isParamsEqual(const QVariantMap& a, const QVariantMap& b) const;
    bool m_hasChanges;
};
#endif // SOCKETMODEEDITOR_H
