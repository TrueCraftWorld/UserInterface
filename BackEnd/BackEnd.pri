QT += core quick qml
QT += serialport multimedia sql concurrent

CONFIG += c++17

# Линковка с математической библиотекой
LIBS += -lm

HEADERS += \
    $$PWD/Structures.h \
    $$PWD/controlcenter.h \
    $$PWD/databasereader.h \
    $$PWD/halfsocket.h \
    $$PWD/instrimageprovider.h \
    $$PWD/instrument.h \
    $$PWD/jsonstorage.h \
    $$PWD/keygenerator.h \
    $$PWD/linkstm.h \
    $$PWD/loggingcategories.h \
    $$PWD/pedal.h \
    $$PWD/periphhandler.h \
    $$PWD/proghandle.h \
    $$PWD/progloader.h \
    $$PWD/socket.h \
    $$PWD/socketmodeeditor.h \
    $$PWD/socketmodel.h \
    $$PWD/stmupdater.h \
    $$PWD/surgicalmode.h \
    $$PWD/systemmonitor.h \
    $$PWD/uartqmlbridge.h
    $$PWD/userprogsloadmodel.h

SOURCES += \
    $$PWD/controlcenter.cpp \
    $$PWD/databasereader.cpp \
    $$PWD/halfsocket.cpp \
    $$PWD/instrimageprovider.cpp \
    $$PWD/instrument.cpp \
    $$PWD/jsonstorage.cpp \
    $$PWD/keygenerator.cpp \
    $$PWD/linkstm.cpp \
    $$PWD/loggingcategories.cpp \
    $$PWD/pedal.cpp \
    $$PWD/periphhandler.cpp \
    $$PWD/proghandle.cpp \
    $$PWD/progloader.cpp \
    $$PWD/socket.cpp \
    $$PWD/socketmodeeditor.cpp \
    $$PWD/socketmodel.cpp \
    $$PWD/stmupdater.cpp \
    $$PWD/surgicalmode.cpp \
    $$PWD/systemmonitor.cpp \
    $$PWD/uartqmlbridge.cpp
    $$PWD/userprogsloadmodel.cpp

RESOURCES += \
    $$PWD/backend.qrc
