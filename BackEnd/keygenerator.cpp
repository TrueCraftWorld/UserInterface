#include "keygenerator.h"
#include <QByteArray>
#include <QDebug>

// Секретная соль - можно изменить на любую другую строку для уникальности ключей
const QString KeyGenerator::SECRET_SALT = "FotekSurgicalSystem2026SecretKey";

KeyGenerator::KeyGenerator(QObject *parent)
    : QObject(parent)
{
}

QString KeyGenerator::generateHash(int serialNumber)
{
    // Создаем строку из номера и соли
    QString input = QString::number(serialNumber) + SECRET_SALT;
    
    // Генерируем SHA-256 хеш
    QByteArray hash = QCryptographicHash::hash(
        input.toUtf8(),
        QCryptographicHash::Sha256
    );
    
    // Преобразуем в hex строку
    return QString(hash.toHex());
}

QString KeyGenerator::hashToKey(const QString &hash)
{
    // Извлекаем цифры из hex строки и формируем 10-значный ключ
    QString digits;
    
    for (int i = 0; i < hash.length() && digits.length() < 10; ++i) {
        QChar c = hash[i];
        if (c.isDigit()) {
            digits.append(c);
        }
    }
    
    // Если цифр недостаточно, используем ASCII коды букв
    if (digits.length() < 10) {
        for (int i = 0; i < hash.length() && digits.length() < 10; ++i) {
            QChar c = hash[i];
            if (c.isLetter()) {
                // Используем последнюю цифру ASCII кода
                int asciiCode = c.toLatin1();
                digits.append(QString::number(asciiCode % 10));
            }
        }
    }
    
    // Гарантируем ровно 10 цифр
    if (digits.length() > 10) {
        digits = digits.left(10);
    } else if (digits.length() < 10) {
        // Дополняем нулями если нужно (не должно произойти)
        while (digits.length() < 10) {
            digits.append('0');
        }
    }
    
    return digits;
}

QString KeyGenerator::generateKey(int serialNumber)
{
    // Проверка корректности входного номера (должен быть 6-значным)
    if (serialNumber < 0 || serialNumber > 999999) {
        qWarning() << "Serial number must be between 0 and 999999";
        return QString();
    }
    
    QString hash = generateHash(serialNumber);
    QString key = hashToKey(hash);
    
    qDebug() << "Generated key" << key << "for serial number" << serialNumber;
    
    return key;
}

bool KeyGenerator::validateKey(int serialNumber, const QString &key)
{
    // Проверка корректности входных данных
    if (serialNumber < 0 || serialNumber > 999999) {
        qWarning() << "Serial number must be between 0 and 999999";
        return false;
    }
    
    if (key.length() != 10) {
        qWarning() << "Key must be exactly 10 digits";
        return false;
    }
    
    // Проверка что ключ содержит только цифры
    for (QChar c : key) {
        if (!c.isDigit()) {
            qWarning() << "Key must contain only digits";
            return false;
        }
    }
    
    // Генерируем правильный ключ и сравниваем
    QString correctKey = generateKey(serialNumber);
    bool isValid = (key == correctKey);
    
    qDebug() << "Validation:" << (isValid ? "SUCCESS" : "FAILED")
             << "- Serial:" << serialNumber
             << "- Provided key:" << key
             << "- Expected key:" << correctKey;
    
    return isValid;
}
