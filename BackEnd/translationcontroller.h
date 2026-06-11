#ifndef TRANSLATIONCONTROLLER_H
#define TRANSLATIONCONTROLLER_H

#include <QObject>
#include <QPointer>
#include <QStringList>
#include <QTranslator>

class QQmlApplicationEngine;

class TranslationController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QStringList availableLanguages READ availableLanguages CONSTANT)

public:
    explicit TranslationController(QQmlApplicationEngine *engine, QObject *parent = nullptr);

    QString language() const;
    QStringList availableLanguages() const;

    Q_INVOKABLE QString normalizedLanguage(const QString &language) const;
    Q_INVOKABLE QString nextLanguage(const QString &language) const;

public Q_SLOTS:
    bool setLanguage(const QString &language);

Q_SIGNALS:
    void languageChanged();

private:
    bool installLanguage(const QString &language);

    QPointer<QQmlApplicationEngine> m_engine;
    QTranslator m_translator;
    QString m_language;
    const QStringList m_availableLanguages;
};

#endif // TRANSLATIONCONTROLLER_H
