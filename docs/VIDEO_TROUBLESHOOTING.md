# Быстрое решение проблем с видео

## Проблема: "Internal data stream error"

### Причина
Отсутствуют необходимые кодеки GStreamer для Qt Multimedia

### Решение (5 минут)

**Шаг 1: Установите кодеки**
```bash
sudo apt-get update
sudo apt-get install -y \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    libqt5multimedia5 \
    libqt5multimedia5-plugins \
    gstreamer1.0-tools
```

**Шаг 2: Проверьте установку**
```bash
gst-inspect-1.0 playbin
```
Должен показать информацию о плагине (не ошибку)

**Шаг 3: Создайте тестовое видео**
```bash
mkdir -p ~/FOTEK/Video
cd /home/kikorik/QtFolder/projects/UserInterface
chmod +x scripts/create_test_video.sh
./scripts/create_test_video.sh
```

**Шаг 4: Перезапустите приложение**

---

## Если не помогло

### Вариант А: Конвертируйте видео в H.264
```bash
# Установите ffmpeg если его нет
sudo apt-get install ffmpeg

# Конвертируйте ваше видео
ffmpeg -i your_video.avi \
       -c:v libx264 -preset fast -crf 23 \
       -c:a aac -b:a 128k \
       ~/FOTEK/Video/your_video.mp4
```

### Вариант Б: Используйте готовые MP4
Скачайте любое MP4 видео (например, с телефона) и скопируйте в `~/FOTEK/Video/`

---

## Диагностика

**Проверка кодеков:**
```bash
cd /home/kikorik/QtFolder/projects/UserInterface
chmod +x scripts/check_video_support.sh
./scripts/check_video_support.sh
```

**Проверка видеофайла:**
```bash
ffprobe ~/FOTEK/Video/your_video.mp4
```

**Тест воспроизведения через GStreamer:**
```bash
gst-play-1.0 ~/FOTEK/Video/your_video.mp4
```

---

## Поддерживаемые форматы

✅ **Работают на 100%:**
- MP4 (H.264 + AAC)
- MP4 (H.264 + MP3)

⚠️ **Могут работать (зависит от кодеков):**
- AVI (различные кодеки)
- MKV (различные кодеки)
- WebM (VP8/VP9)

❌ **Обычно НЕ работают:**
- Собственные форматы камер
- Недекодированные форматы
- DRM-защищённые файлы

---

## Быстрый тест

После установки кодеков:

1. Откройте приложение
2. Перейдите в главное меню → **Видео 🎬**
3. Если видите "Нет видеофайлов" - положите видео в `~/FOTEK/Video`
4. Если видите список файлов - кликните на любой
5. Если появляется ошибка - проверьте консоль Qt Creator

**Сообщения в консоли:**
```
ProgHandle: Found X video files    ← Файлы найдены
Attempting to play video: ...      ← Попытка воспроизведения
MediaPlayer status: 6              ← Status: 6 = Loaded (ОК)
MediaPlayer playbackState: 1       ← State: 1 = Playing (ОК)
```

Если Status = 8 (InvalidMedia) - формат не поддерживается, конвертируйте видео.

