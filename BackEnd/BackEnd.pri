QT += core quick qml
QT += serialport multimedia

HEADERS += \
    $$PWD/pedal.h \
    $$PWD/socketConstants.h \
    $$PWD/socketmodel.h \
    $$PWD/uartqmlbridge.h

SOURCES += \
    $$PWD/pedal.cpp \
    $$PWD/socketConstants.cpp \
    $$PWD/socketmodel.cpp \
    $$PWD/uartqmlbridge.cpp

RESOURCES += \
    $$PWD/backend.qrc
