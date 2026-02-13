#!/bin/bash

# Скрипт для генерации playlist.txt из видеофайлов в папке ~/FOTEK/Video

VIDEO_DIR="$HOME/FOTEK/Video"
PLAYLIST_FILE="$VIDEO_DIR/playlist.txt"

# Создаём папку, если её нет
mkdir -p "$VIDEO_DIR"

# Очищаем или создаём файл playlist.txt
> "$PLAYLIST_FILE"

# Ищем все видеофайлы и добавляем их в плейлист
find "$VIDEO_DIR" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.wmv" -o -iname "*.flv" -o -iname "*.webm" \) -exec basename {} \; | sort >> "$PLAYLIST_FILE"

echo "Playlist created at $PLAYLIST_FILE"
echo "Found $(wc -l < "$PLAYLIST_FILE") video files"

