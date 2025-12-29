#!/bin/bash

# Скрипт для проверки доступных шрифтов, поддерживающих эмодзи

echo "=== Проверка доступных шрифтов для эмодзи ==="
echo ""

# Проверяем наличие fc-list (fontconfig)
if command -v fc-list &> /dev/null; then
    echo "Доступные шрифты с поддержкой эмодзи:"
    echo "----------------------------------------"
    fc-list | grep -iE "(emoji|symbola|noto)" | head -20
    echo ""
    
    echo "Проверка конкретных шрифтов:"
    echo "----------------------------"
    for font in "Noto Color Emoji" "Apple Color Emoji" "Segoe UI Emoji" "Symbola" "DejaVu Sans"; do
        if fc-list | grep -qi "$font"; then
            echo "✓ $font - найден"
        else
            echo "✗ $font - не найден"
        fi
    done
else
    echo "fc-list не найден. Установите fontconfig:"
    echo "  sudo apt-get install fontconfig"
    echo ""
    echo "Альтернативно, проверьте шрифты вручную:"
    echo "  ls /usr/share/fonts/ | grep -i emoji"
fi

echo ""
echo "=== Проверка через Qt ==="
echo "Запустите приложение и проверьте консольный вывод"
echo "или используйте QML компонент для проверки шрифтов"

