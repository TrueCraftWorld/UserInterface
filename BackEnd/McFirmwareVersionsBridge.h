#ifndef MCFIRMWAREVERSIONSBRIDGE_H
#define MCFIRMWAREVERSIONSBRIDGE_H

#include <QObject>
#include <QVariantList>

/// Прокси на GUI-потоке: версии МК из LinkStm (числа для отображения и сравнения с пакетами обновления).
class McFirmwareVersionsBridge : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList modules READ modules NOTIFY modulesChanged)

public:
    explicit McFirmwareVersionsBridge(QObject *parent = nullptr);

    QVariantList modules() const { return m_modules; }

public slots:
    void setModules(const QVariantList &list);

signals:
    void modulesChanged();

private:
    static bool modulesDataEqual(const QVariantList &a, const QVariantList &b);

    QVariantList m_modules;
};

#endif // MCFIRMWAREVERSIONSBRIDGE_H
