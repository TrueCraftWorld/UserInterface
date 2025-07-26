#ifndef INSTRUMENT_H
#define INSTRUMENT_H

#include <QString>
#include <QSharedPointer>

class Instrument
{
public:
    explicit Instrument(int id, int legacyNumber, const QString& name, bool mono);
    void setDescription(const QString &newDescription);

    QString name() const;

private:
    QString m_coagImagePath;
    QString m_cutImagePath;
    int m_Id;
    int m_legacyNumber;
    QString m_name;
    QString m_description;
    bool m_isMono;
};

using InstrPtr = QSharedPointer<Instrument>;

#endif // INSTRUMENT_H
