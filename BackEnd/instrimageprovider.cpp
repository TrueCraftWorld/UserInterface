#include "instrimageprovider.h"

#include <QDir>

InstrImageProvider::InstrImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
    QDir dir("/home/kikorik/FOTEK/Images");
    QStringList filters;
       filters << "*.png" << "*.PNG";
    if (dir.exists()) {
        m_knownFiles = dir.entryInfoList(filters, QDir::Files | QDir::NoDotAndDotDot | QDir::Readable);
    }
}


QPixmap InstrImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    static QSize defaultSize = QSize(160, 60);

    QSize mySize;
    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        if (size)
            *size = requestedSize;
        mySize = requestedSize;
    } else {
        if (size)
            *size = defaultSize;
        mySize = defaultSize;
    }
    
    if (m_cache.contains(id))
        return (m_cache.value(id).scaled(mySize, Qt::KeepAspectRatio));
    for (const auto& item : m_knownFiles){
        if (item.baseName() == id) {
            // QPixmap
            m_cache.insert(id, QPixmap(item.absoluteFilePath()));
            return (m_cache.value(id).scaled(mySize, Qt::KeepAspectRatio));
        }
    }
    // pixmap = QPixmap::load();
    return QPixmap(mySize);
}
