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
    static QSize defaultSize = QSize(800, 300);
    static double widthToHeight = 160.0/60.0;

    QSize mySize;
    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        double reqWidthToHeight = double(requestedSize.width()) / double(requestedSize.height());

        if (reqWidthToHeight > widthToHeight)
            mySize = QSize(int(requestedSize.height() * widthToHeight), requestedSize.height());
        else
            mySize = QSize(requestedSize.width(), int(requestedSize.width()/ widthToHeight));

        if (size)
            *size = mySize;
    } else {
        if (size)
            *size = defaultSize;
        mySize = defaultSize;
    }
    
    if (m_cache.contains(id))
        return (m_cache.value(id).scaled(mySize, Qt::KeepAspectRatio));

    for (const auto& item : m_knownFiles) {
        if (item.baseName() == id) {
            // QPixmap
            m_cache.insert(id, QPixmap(item.absoluteFilePath()));
            return (m_cache.value(id).scaled(mySize, Qt::KeepAspectRatio));
        }
    }
    // pixmap = QPixmap::load();
    return (QPixmap("/home/kikorik/FOTEK/Images/miniInstr11.png").scaled(mySize, Qt::KeepAspectRatio));
}
