#ifndef SOCKETMODEEDITOR_H
#define SOCKETMODEEDITOR_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

#include "socketmodel.h"

class SocketModeEditor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList modeNames READ modeNames CONSTANT)
    Q_PROPERTY(QVariantMap currentMode READ currentMode NOTIFY currentModeChanged)
    Q_PROPERTY(int currentModeIndex READ currentModeIndex WRITE setCurrentModeIndex NOTIFY currentModeIndexChanged)

public:
    explicit SocketModeEditor(SocketModel * model, QObject *parent = nullptr);

    Q_INVOKABLE void initialize(const QString& socket, const QString &mode);
    Q_INVOKABLE void loadModeParameters(int modeIndex);
    Q_INVOKABLE void updateCurrentParameters(const QVariantMap ms);
    Q_INVOKABLE void updateParameters(const QString& paramName, const QVariant& value);
    Q_INVOKABLE void commitChanges();
    Q_INVOKABLE void rollBack();

    QStringList modeNames() const;
    QVariantMap currentMode() const;
    int currentModeIndex() const;
    void setCurrentModeIndex(int index);
    bool hasChanges() const;

signals:
    void currentParamsChanged();
    void currentModeIndexChanged();
    void parametersLoaded();
    void editingFinished(bool);

private:

    int m_socketRow;
    QStringList m_modeNames;
    QVariantMap m_currentParameters;
    QString m_socketName;
    int m_currentModeIndex;
    int m_originalModeIndex;
    QVariantMap m_originalParameters;
    QVariantMap fetchModeParameters(int modeIndex);
    SocketModel * m_model;

    bool isParamsEqual(const QVariantMap& a, const QVariantMap& b) const;
};
#endif // SOCKETMODEEDITOR_H
