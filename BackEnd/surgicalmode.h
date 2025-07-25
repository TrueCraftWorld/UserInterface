#ifndef SURGICALMODE_H
#define SURGICALMODE_H

#include <QString>
#include <QVariantMap>
#include <QList>
#include <QObject>

namespace ESHF {
enum eshfModes	{ NO_CUT_MODE = 0, NO_COAG_MODE = 0, BI_BLEND=1,
                 BI_TUR=2, BI_ARTRO=3, BI_GISTERO=4,
                 BI_COAG=5, BI_COAG_DISS=6, TERMOSHOV=7,
                 CUT=8, BLEND=9, BLEND1=10, TUR=11, VAP=12,
                 E_KNIFE1=13, E_KNIFE2=14, E_KNIFE3=15,
                 E_LOOP1=16, E_LOOP2=17, E_LOOP3=18,
                 FORCE=19, FULGUR=20, SOFT=21, SPRAY=22,
                 FULGUR_A=23, SPRAY_A=24,
                 FULGUR_P=25, SPRAY_P=26,
                 };
const QStringList modesNames = { /*QObject::tr("РЕЖИМ РЕЗ НЕ ВЫБРАН"), QObject::tr("РЕЖИМ КОАГ НЕ ВЫБРАН"),*/
                                 QObject::tr("РЕЖИМ НЕ ВЫБРАН"),
                                 QObject::tr("БИ-СМЕСЬ"),
                                 QObject::tr("БИ-ТУР"), QObject::tr("БИ-АРТРО"),
                                 QObject::tr("БИ-ГИСТЕРО"),
                                 QObject::tr("БИ-КОАГ"), QObject::tr("БИ-КОАГ-ДИССЕКТ"),
                                 QObject::tr("ТЕРМОШОВ"),
                                 QObject::tr("РЕЗАНИЕ"), QObject::tr("СМЕСЬ"),
                                 QObject::tr("СМЕСЬ-1"), QObject::tr("ТУР"), QObject::tr("ВАП"),
                                 QObject::tr("ЭНДОНОЖ-1"), QObject::tr("ЭНДОНОЖ-2"),
                                 QObject::tr("ЭНДОНОЖ-3"),
                                 QObject::tr("ЭНДОПЕТЛЯ-"), QObject::tr("ЭНДОПЕТЛЯ-2"), QObject::tr("ЭНДОПЕТЛЯ-3"),
                                 QObject::tr("ФОРС"), QObject::tr("ФУЛЬГУР"),
                                 QObject::tr("МЯГКАЯ"), QObject::tr("СПРЕЙ"),
                                 QObject::tr("ФУЛЬГУР АРГОН"), QObject::tr("СПРЕЙ АРГОН"),
                                 QObject::tr("ФУЛЬГУР ПУЛЬС АРГОН"), QObject::tr("СПРЕЙ ПУЛЬС АРГОН")
                                };
// const QStringList modesNames = { "NO CUT MODE", "NO COAG MODE", "BI BLEND",
//                                  "BI TUR", "BI ARTRO", "BI GISTERO",
//                                  "BI COAG", "BI COAG DISSECT", "TERMOSHOV",
//                                  "CUT", "BLEND", "BLEND1", "TUR", "VAP",
//                                  "ENDO KNIFE1", "ENDO KNIFE2", "ENDO KNIFE3",
//                                  "ENDO LOOP1", "ENDO LOOP2", "ENDO LOOP3",
//                                  "FORCE", "FULGUR", "SOFT", "SPRAY",
//                                  "FULGUR ARGON", "SPRAY ARGON",
//                                  "FULGUR PULSE ARGON", "SPRAY PULSE ARGON",
//                                };

const QList<int> modesMaxPowers	{ 1, /*1,*/ 75,
                                8, 8, 8,
                                150, 150, 5,
                                400, 400, 150, 400, 400,
                                27, 27, 27,
                                27, 27, 27,
                                150, 150, 300, 70,
                                150, 70,
                                70, 70,
                                };
}

class SurgicalMode {
public:


    SurgicalMode(QString name,
             bool isCoag,
             int maximum = 400,
             int minimum = 1);

    explicit SurgicalMode()  :
        SurgicalMode("NoMode", false, 1, 1) {}

    int maximumPower() const;
    int currentPower() const;
    const QString &modeName() const;

    int minimumPower() const;

    bool setCurrentPower(int newCurrentpower);

    bool setParams(const QVariantMap& params);

    QVariantMap params() const;

    bool isCoag() const;

private:
    void setModeName(const QString &newModeName);
    void setMaximumPower(int newMaximumPower);
    void setMinimumPower(int newMaximumPower);

    int m_maximumPower;
    int m_minimumPower;
    int m_currentPower;
    QString m_modeName;
    bool m_isCoag;
};
#endif // SURGICALMODE_H
