#ifndef DBLOCALE_H
#define DBLOCALE_H

#include <QString>

/**
 * @brief Подстановка локализованных колонок каталога (Name_RU/Name_EN/Name_ES и т.п.)
 * в SELECT-запросы. Язык задаётся TranslationController'ом.
 */
namespace DbLocale
{
/// @param language код языка ("ru"/"en"/"es"); неизвестный код трактуется как "ru".
void setLanguage(const QString &language);

QString language();

/// Возвращает выражение колонки для текущего языка с фолбэком на русский:
/// для "ru" — "Name_RU", иначе — "COALESCE(NULLIF(Name_EN,''),Name_RU)".
/// Использовать только для колонок, у которых в БД есть варианты _RU/_EN/_ES.
QString column(const QString &baseName);
}

#endif // DBLOCALE_H
