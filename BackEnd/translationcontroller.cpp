#include "translationcontroller.h"
#include "dblocale.h"

#include <QCoreApplication>
#include <QDebug>
#include <QQmlApplicationEngine>

TranslationController::TranslationController(QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
    , m_language(QStringLiteral("ru"))
    , m_availableLanguages({QStringLiteral("ru"), QStringLiteral("en"), QStringLiteral("es")})
{
}

QString TranslationController::language() const
{
    return m_language;
}

QStringList TranslationController::availableLanguages() const
{
    return m_availableLanguages;
}

QString TranslationController::normalizedLanguage(const QString &language) const
{
    const QString normalized = language.trimmed().toLower();
    return m_availableLanguages.contains(normalized) ? normalized : QStringLiteral("ru");
}

QString TranslationController::nextLanguage(const QString &language) const
{
    const QString normalized = normalizedLanguage(language);
    const int index = m_availableLanguages.indexOf(normalized);
    const int nextIndex = (index + 1) % m_availableLanguages.size();
    return m_availableLanguages.at(nextIndex);
}

bool TranslationController::setLanguage(const QString &language)
{
    const QString normalized = normalizedLanguage(language);

    if (normalized == m_language) {
        return true;
    }

    if (!installLanguage(normalized)) {
        return false;
    }

    m_language = normalized;
    DbLocale::setLanguage(normalized);
    emit languageChanged();
    return true;
}

bool TranslationController::installLanguage(const QString &language)
{
    QCoreApplication::removeTranslator(&m_translator);

    if (language != QStringLiteral("ru")) {
        const QString translationPath = QStringLiteral(":/translations/UserInterface_%1.qm").arg(language);
        if (!m_translator.load(translationPath)) {
            qWarning() << "Failed to load translation" << translationPath;
            return false;
        }

        QCoreApplication::installTranslator(&m_translator);
    }

    if (m_engine) {
        m_engine->retranslate();
    }

    return true;
}
