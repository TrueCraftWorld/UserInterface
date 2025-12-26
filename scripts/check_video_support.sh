#!/bin/bash

# Скрипт для проверки поддержки видео в Qt Multimedia

echo "=== Проверка поддержки видео в Qt Multimedia ==="
echo ""

# Проверка установленных кодеков GStreamer
echo "1. Проверка GStreamer плагинов:"
if command -v gst-inspect-1.0 &> /dev/null; then
    echo "   ✓ GStreamer найден"
    
    # Проверяем важные плагины
    plugins=("playbin" "filesrc" "qtdemux" "h264parse" "avdec_h264" "videoconvert" "ximagesink")
    
    for plugin in "${plugins[@]}"; do
        if gst-inspect-1.0 "$plugin" &> /dev/null; then
            echo "   ✓ $plugin"
        else
            echo "   ✗ $plugin (отсутствует)"
        fi
    done
else
    echo "   ✗ GStreamer не найден"
    echo "   Установите: sudo apt-get install gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav"
fi

echo ""
echo "2. Проверка Qt Multimedia библиотек:"
if [ -f "/usr/lib/aarch64-linux-gnu/qt5/plugins/mediaservice/libgstmediaplayer.so" ] || \
   [ -f "/usr/lib/qt5/plugins/mediaservice/libgstmediaplayer.so" ]; then
    echo "   ✓ Qt GStreamer plugin найден"
else
    echo "   ✗ Qt GStreamer plugin не найден"
    echo "   Установите: sudo apt-get install libqt5multimedia5-plugins"
fi

echo ""
echo "3. Тестирование видеофайла:"
VIDEO_DIR="$HOME/FOTEK/Video"
if [ -d "$VIDEO_DIR" ]; then
    VIDEO_COUNT=$(find "$VIDEO_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" \) | wc -l)
    echo "   Найдено видеофайлов: $VIDEO_COUNT"
    
    if [ $VIDEO_COUNT -gt 0 ]; then
        FIRST_VIDEO=$(find "$VIDEO_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" \) | head -1)
        echo "   Тестовое видео: $FIRST_VIDEO"
        
        if command -v ffprobe &> /dev/null; then
            echo ""
            echo "   Информация о видео:"
            ffprobe -v error -show_format -show_streams "$FIRST_VIDEO" 2>&1 | grep -E "(codec_name|width|height|duration|bit_rate)"
        fi
        
        echo ""
        echo "   Попытка воспроизведения через GStreamer:"
        if command -v gst-play-1.0 &> /dev/null; then
            timeout 3 gst-play-1.0 "$FIRST_VIDEO" 2>&1 | head -20
        else
            echo "   gst-play-1.0 не найден"
        fi
    fi
else
    echo "   ✗ Папка $VIDEO_DIR не существует"
    echo "   Создайте папку: mkdir -p $VIDEO_DIR"
fi

echo ""
echo "=== Рекомендации ==="
echo "1. Для наилучшей совместимости используйте MP4 с кодеком H.264"
echo "2. Убедитесь, что установлены все необходимые пакеты:"
echo "   sudo apt-get install gstreamer1.0-plugins-base gstreamer1.0-plugins-good"
echo "   sudo apt-get install gstreamer1.0-plugins-bad gstreamer1.0-libav"
echo "   sudo apt-get install libqt5multimedia5 libqt5multimedia5-plugins"
echo "3. Проверьте права доступа к видеофайлам: chmod 644 ~/FOTEK/Video/*.mp4"

