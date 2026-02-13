#!/bin/bash

# Скрипт для запуска приложения с X11 backend вместо EGLFS

export QT_QPA_PLATFORM=xcb
export QT_GSTREAMER_VIDEOSINK=ximagesink
export GST_DEBUG=2
export GST_PLUGIN_FEATURE_RANK=v4l2slh264dec:NONE,avdec_h264:PRIMARY

# Путь к исполняемому файлу (замените на свой)
BUILD_DIR="$HOME/QtFolder/projects/UserInterface-build"
APP_NAME="UserInterface"

if [ -f "$BUILD_DIR/$APP_NAME" ]; then
    echo "Запуск $APP_NAME с X11 backend..."
    cd "$BUILD_DIR"
    ./"$APP_NAME"
else
    echo "Не найден исполняемый файл: $BUILD_DIR/$APP_NAME"
    echo "Укажите правильный путь к build директории"
fi

