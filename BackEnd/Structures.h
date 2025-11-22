#ifndef STRUCTURES_H
#define STRUCTURES_H

#include "qglobal.h"
#include <QVariant>
#include <QMetaType>

/*
 * Это неймспес со свсем вспомогательными енумами и структурами нужными более
 * чем 1 классу для общения между ними. Таким образом избегает жёсткой связи разных классов,
 * сохраняя возможность использовать именованные структыры для облегчения общения
 * */
namespace Onyx {


struct SocketState {
	quint16 cutModeNum;
	quint16 cutModePower;
	quint16 coagModeNum;
	quint16 coagModePower;
	quint8 pedal;
	quint8 autoMode;
};

struct InstrInfo {
	int id;
	int miniPower;
	int midiPower;
	int maxiPower;
	// int legacyNumber;
	InstrInfo() = default;
	InstrInfo(int _id, int min, int mid, int max/*, int _legacyNumber*/)
	    : id(_id), miniPower(min), midiPower(mid), maxiPower(max)/*, legacyNumber(_legacyNumber)*/
	{;}
};

/*! Перечисление возможных типов сокета */
enum SocType {  EMPTY, /*!<  Пустой сокет - заглушка на случай ошибок*/
	            BIPOLAR_1, /*!< Биполяр 1 */
	            BIPOLAR_2, /*!< Биполяр 2 */
	            MONOPOLAR_1, /*!< Монополяр 1 */
	            MONOPOLAR_2 /*!< Монополяр 2 */
                    };

/*! Перечисление возможных состояний сокета */
enum SocStatus  {S_OFF = 0, /*!< ОТКЛЮЧЕН */
	            S_DISABLED, /*!< Выключен, активация запрещена */
	            S_ENABLED, /*!< Включен, активация разрешена */
	            S_ACTIVE_COAG, /*!< Активирован, коагуляция 3*/
	            S_ACTIVE_CUT, /*!< Активирован, резание 4*/
	            S_ERROR /*!< Ошибка, активация запрещена */
                    };

/*! Перечисление возможных отображений сокета */
enum SocDisplayMode : int {   S_COLLAPSED = 0, /*!< свёрнут  */
	                    S_EXPANDED, /*!< развёрнут */
                    };

enum PedalType : int {  NO_PED = 0,
	                    SINGLE_PED,
	                    DOUBLE_PED,
	                    INSTR_BUTTON_BI,
	                    INSTR_BUTTON_MONO,
	                    PED_COUNT
                     };

enum HS_State {HS_DISABLED, /*!< Выключен, активация запрещена */
	            HS_ENABLED, /*!< Включен, активация разрешена */
                    };

}
Q_DECLARE_METATYPE(Onyx::SocketState);

#endif // STRUCTURES_H
