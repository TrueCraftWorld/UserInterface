# Автоуправление firewall для upload

Эта схема нужна, когда во время обновления нет SSH: приложение само открывает порт upload на время сессии и закрывает после завершения.

## Как это работает

- При `httpUpload.startSession()` приложение вызывает:
  - `sudo -n /usr/local/sbin/upload-fw-guard open`
- При `httpUpload.stopSession()` и по таймауту:
  - `sudo -n /usr/local/sbin/upload-fw-guard close`

Скрипт:

- определяет текущую IPv4 подсеть интерфейса `wlan0`;
- добавляет правило `ufw` только для этой подсети и порта `57891/tcp`;
- помечает правило комментарием `ui-upload-guard`;
- при `close` удаляет все правила с этим комментарием.

## Установка на устройстве

1. Скопировать helper:

```bash
sudo install -m 0755 deploy/firewall/upload-fw-guard.sh /usr/local/sbin/upload-fw-guard
```

2. Разрешить запуск helper без пароля для пользователя приложения:

```bash
sudo install -m 0440 deploy/firewall/99-upload-fw-guard-sudoers /etc/sudoers.d/99-upload-fw-guard
sudo visudo -cf /etc/sudoers.d/99-upload-fw-guard
```

Важно: в `99-upload-fw-guard-sudoers` замените `kikorik` на реального пользователя, под которым работает `UserInterface`.

3. Проверить вручную:

```bash
sudo /usr/local/sbin/upload-fw-guard open
sudo ufw status numbered | grep 57891
sudo /usr/local/sbin/upload-fw-guard close
sudo ufw status numbered | grep 57891
```

## Поведение при ошибке

- Если helper отсутствует, приложение работает как раньше (без автоуправления firewall).
- Если helper найден, но вызов `open` завершается с ошибкой, старт upload-сессии отменяется и в UI показывается текст ошибки.
- Ошибка `close` только логируется и не блокирует остановку сессии.
