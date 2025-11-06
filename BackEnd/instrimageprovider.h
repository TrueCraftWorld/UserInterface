#ifndef INSTRIMAGEPROVIDER_H
#define INSTRIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QFileInfoList>
#include <QHash>

class InstrImageProvider : public QQuickImageProvider
{
public:
    InstrImageProvider();

    // QQuickImageProvider interface
public:
    virtual QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
    
private:
    QHash<QString, QPixmap> m_cache;
    QFileInfoList m_knownFiles;
};

#endif // INSTRIMAGEPROVIDER_H
