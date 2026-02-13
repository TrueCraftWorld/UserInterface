#!/bin/bash

# Скрипт для создания тестового видео

VIDEO_DIR="$HOME/FOTEK/Video"
OUTPUT_FILE="$VIDEO_DIR/test_video.mp4"

mkdir -p "$VIDEO_DIR"

echo "Создание тестового видео..."

if command -v ffmpeg &> /dev/null; then
    # Создаём простое тестовое видео с помощью ffmpeg
    # 10 секунд, разрешение 640x480, с временной меткой
    ffmpeg -f lavfi -i testsrc=duration=10:size=640x480:rate=30 \
           -f lavfi -i sine=frequency=1000:duration=10 \
           -c:v libx264 -preset ultrafast -pix_fmt yuv420p \
           -c:a aac -b:a 128k \
           "$OUTPUT_FILE" -y
    
    if [ $? -eq 0 ]; then
        echo "✓ Тестовое видео создано: $OUTPUT_FILE"
        echo "  Размер: $(du -h "$OUTPUT_FILE" | cut -f1)"
        ls -lh "$OUTPUT_FILE"
    else
        echo "✗ Ошибка при создании видео"
        exit 1
    fi
else
    echo "✗ ffmpeg не найден"
    echo "Установите: sudo apt-get install ffmpeg"
    exit 1
fi

echo ""
echo "Проверка созданного видео:"
if command -v ffprobe &> /dev/null; then
    ffprobe -v error -show_format -show_streams "$OUTPUT_FILE" 2>&1 | grep -E "(codec_name|width|height|duration)"
fi

