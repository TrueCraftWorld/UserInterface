QT += core quick qml
QT += serialport multimedia sql concurrent

HEADERS += \
    $$PWD/controlcenter.h \
    $$PWD/databasereader.h \
    $$PWD/pedal.h \
    $$PWD/socket.h \
    $$PWD/socketmodeeditor.h \
    $$PWD/socketmodel.h \
    $$PWD/surgicalmode.h \
    $$PWD/uartqmlbridge.h

SOURCES += \
    $$PWD/controlcenter.cpp \
    $$PWD/databasereader.cpp \
    $$PWD/pedal.cpp \
    $$PWD/socket.cpp \
    $$PWD/socketmodeeditor.cpp \
    $$PWD/socketmodel.cpp \
    $$PWD/surgicalmode.cpp \
    $$PWD/uartqmlbridge.cpp

RESOURCES += \
    $$PWD/backend.qrc
