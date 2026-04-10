# Baseline Reliability Measurement (ROC-RK3566)

## Goal
Collect reproducible metrics for touch keyboard reliability:
- `pressed`
- `released`
- `canceled`
- `lost_release = pressed - released`

## Preconditions
- Device: ROC-RK3566 target image
- App build includes `KBD-KEY` logs from `CuteKeyboard/Key.qml`
- Keyboard hotfix deployed

## Capture Procedure
1. Start app with clean logs.
2. On device, reproduce typing tests:
   - `abcdefghij` 20 times
   - mixed text with numbers and backspace
   - 2-minute continuous typing in `SerialNumberSettings`
3. Save app stdout/stderr to file, e.g. `/tmp/ui_keyboard.log`.

## Metrics Calculation
Run on host or device:

```bash
python3 scripts/keyboard_metrics.py /tmp/ui_keyboard.log
```

## Acceptance Thresholds (baseline for this hardware revision)
- `lost_release_rate_percent <= 1.00`
- `cancel_rate_percent <= 2.00`
- No burst deletes from Backspace (single tap deletes one symbol)

## Record Template
- Build/commit:
- Device serial:
- Kernel/OS:
- pressed:
- released:
- canceled:
- lost_release_rate_percent:
- cancel_rate_percent:
- Notes:
