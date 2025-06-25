QT += core quick qml
QT += serialport multimedia

HEADERS += \
    $$PWD/controlcenter.h \
    $$PWD/pedal.h \
    $$PWD/socket.h \
    $$PWD/socketmodeeditor.h \
    $$PWD/socketmodel.h \
    $$PWD/uartqmlbridge.h

SOURCES += \
    $$PWD/controlcenter.cpp \
    $$PWD/pedal.cpp \
    $$PWD/socket.cpp \
    $$PWD/socketmodeeditor.cpp \
    $$PWD/socketmodel.cpp \
    $$PWD/uartqmlbridge.cpp

RESOURCES += \
    $$PWD/backend.qrc
