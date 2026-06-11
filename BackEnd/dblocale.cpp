#include "dblocale.h"

namespace {
QString g_language = QStringLiteral("ru");
QString g_suffix = QStringLiteral("RU");
}

namespace DbLocale
{

void setLanguage(const QString &language)
{
    const QString normalized = language.trimmed().toLower();
    if (normalized == QLatin1String("en")) {
        g_language = QStringLiteral("en");
        g_suffix = QStringLiteral("EN");
    } else if (normalized == QLatin1String("es")) {
        g_language = QStringLiteral("es");
        g_suffix = QStringLiteral("ES");
    } else {
        g_language = QStringLiteral("ru");
        g_suffix = QStringLiteral("RU");
    }
}

QString language()
{
    return g_language;
}

QString column(const QString &baseName)
{
    if (g_suffix == QLatin1String("RU")) {
        return baseName + QStringLiteral("_RU");
    }
    return QStringLiteral("COALESCE(NULLIF(%1_%2,''),%1_RU)").arg(baseName, g_suffix);
}

}
