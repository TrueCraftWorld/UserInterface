# Интеграция UART-коммуникации с ControlCenter

## Описание

Реализована связь между модулем UART-коммуникации (`LinkStm`) и основным контроллером приложения (`ControlCenter`). Теперь все данные, приходящие по UART, обрабатываются в `ControlCenter`, где может выполняться бизнес-логика и формироваться ответные команды.

## Архитектура

```
┌──────────────┐
│   LinkStm    │ ← Получает данные по UART (serial port ttyS3)
└──────┬───────┘
       │ signal: recieveData(UartRx*)
       ↓
┌──────────────────┐
│ ControlCenter    │ ← Обрабатывает данные в uartChat()
│  ::uartChat()    │ ← Формирует ответную команду
└──────┬───────────┘
       │ вызов: setTxCommand(UartTx)
       ↓
┌──────────────┐
│   LinkStm    │ ← Отправляет команду по UART
└──────────────┘
```

## Структуры данных

### LinkStm::UartRx (принимаемые данные)
```cpp
struct UartRx {
    RxCommand com;      // Код команды (enum)
    QByteArray data;    // Данные команды
    McUnit mc;          // Модуль-отправитель (MC_0, MC_1, MC_2, MC_3)
};
```

### LinkStm::UartTx (отправляемые данные)
```cpp
struct UartTx {
    TxCommand com;      // Код команды для отправки
    QByteArray data;    // Данные команды
    McUnit mc;          // Модуль-получатель
};
```

## Реализованные методы

### ControlCenter::setLinkStm()
**Назначение:** Устанавливает связь между `LinkStm` и `ControlCenter`.

**Параметры:**
- `linkStm` - указатель на объект `LinkStm`

**Что делает:**
- Отключает старые соединения (если были)
- Подключает сигнал `recieveData` к слоту `uartChat`
- Сохраняет указатель на `LinkStm` для последующей отправки команд

### ControlCenter::uartChat()
**Назначение:** Обработчик входящих UART-данных.

**Параметры:**
- `rxData` - указатель на принятую команду (структура `UartRx`)

**Что делает (текущая реализация):**
1. Проверяет валидность данных
2. Логирует принятую команду (код, модуль, размер данных)
3. Формирует ответную команду (пока просто `Allright`)
4. Отправляет команду через `setTxCommand()`

**TODO:** Здесь нужно реализовать логику обработки конкретных команд.

## Инициализация (main.cpp)

```cpp
// Создаём ControlCenter
QSharedPointer<ControlCenter> ctrl = QSharedPointer<ControlCenter>::create(nullptr);
ctrl->init();

// Создаём LinkStm
m_linkStm = new LinkStm();
m_linkStm->setBoot(static_cast<LinkStm::BootChoice>(boot.toInt()));

// Связываем их
ctrl->setLinkStm(m_linkStm);
```

## Пример логирования

При получении данных в консоль выводится:
```
LinkStm connected to ControlCenter
UART RX: command = <код команды> mc = <номер модуля> data size = <размер данных>
UART TX: command = 192 queued
```

## Следующие шаги

1. **Реализовать логику обработки команд** в `ControlCenter::uartChat()`:
   - Парсинг `rxData->data` в зависимости от `rxData->com`
   - Взаимодействие с сокетами (`m_socketModel`)
   - Формирование корректных ответных команд

2. **Добавить обработку ошибок:**
   - Подключить сигнал `LinkStm::error` для обработки ошибок связи
   - Добавить таймауты и повторные попытки

3. **Расширить API:**
   - Добавить методы для отправки конкретных команд из бизнес-логики
   - Добавить очередь команд (если нужно)

## Доступные команды UART

### Передаваемые (TxCommand):
- `Allright = 0xC0` - Базовый запрос/подтверждение
- `CurrentVersion = 0xF0` - Запрос версий ПО
- `Erase_1 = 0xF1` - Стереть банк 1
- `Erase_2 = 0xF2` - Стереть банк 2
- `StartUpdate_1 = 0xF3` - Начало обновления банка 1
- `StartUpdate_2 = 0xF4` - Начало обновления банка 2
- `SoftData = 0xF5` - Данные прошивки
- `UpdateFinish = 0xF6` - ПО передано
- `GoBoot = 0xF7` - Переключение на загрузчик
- `GoBank_1 = 0xF8` - Переключение на банк 1
- `GoBank_2 = 0xF9` - Переключение на банк 2
- `Reboot = 0xFA` - Перезагрузка STM
- `NoTxCommand = 0xFF` - Нет команды

### Принимаемые (RxCommand):
- `Whatsup = 0xC0` - Стандартный запрос
- И другие (см. `BackEnd/linkstm.h`)

## Файлы

- `BackEnd/controlcenter.h` - Объявление методов и член-данных
- `BackEnd/controlcenter.cpp` - Реализация `setLinkStm()` и `uartChat()`
- `BackEnd/linkstm.h` - Определение структур и команд UART
- `main.cpp` - Инициализация и связывание компонентов

